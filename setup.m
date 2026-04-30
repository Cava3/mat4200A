%SETUP  Optional diagnostic script for the MAT4200A toolbox.
%
%   When the toolbox is installed via the Add-On Manager (MAT4200A.mltbx)
%   this script is NOT required — the constructor validates the Python
%   environment automatically on first use.
%
%   Run this script manually to diagnose Python setup issues, or if you are
%   using the toolbox directly from source (without installing the .mltbx).
%
%   What this script does:
%     1. Adds the MAT4200A toolbox folder to the MATLAB path.
%     2. Verifies that a compatible Python environment is active.
%     3. Checks that the py4200A Python package is importable.
%
%   Python environment requirements:
%     - Python 3.10–3.12 (3.10+ for X|Y union syntax; 3.13 not yet supported by MATLAB R2025b).
%     - py4200A installed: pip install py4200a
%     - pyvisa, numpy, gpib-ctypes (installed automatically with py4200A).
%
%   To point MATLAB at a specific Python environment:
%     pyenv('Version', '/path/to/python')   % before calling setup
%   or set the environment from the MATLAB Preferences dialog.

%% ── 1. Add toolbox root and dependencies to path ────────────────────────
toolboxRoot   = fileparts(mfilename('fullpath'));

if ~any(strcmp(strsplit(path, pathsep), toolboxRoot))
    addpath(toolboxRoot);
    fprintf('[MAT4200A] Added to MATLAB path: %s\n', toolboxRoot);
end

% Verify accessibility by asking MATLAB to resolve the Dependent class.
% It may be installed anywhere — this check is location-independent.
if isempty(which('Dependent'))
    warning('MAT4200A:setup:dependantNotFound Dependent class is not on the MATLAB path. makeDependentFrom() will not work until Dependent.m is accessible.');
else
    fprintf('[MAT4200A] Dependent toolbox accessible.\n');
end

%% ── 2. Python environment check ─────────────────────────────────────────
pe = pyenv();
if strcmp(pe.Status, 'NotLoaded')
    warning('MAT4200A:setup:pythonNotLoadedPython environment is not loaded. MATLAB will load it on the first py.* call. If you need a specific environment run pyenv(''Version'', ''/path/to/python'') first.');
else
    fprintf('[MAT4200A] Python %s  (%s)\n', char(pe.Version), char(pe.Executable));
    verParts = sscanf(char(pe.Version), '%d.%d');
    if numel(verParts) < 2 || verParts(1) < 3 || (verParts(1) == 3 && verParts(2) < 10)
        error('MAT4200A:setup:pythonTooOld', 'Python 3.10 or newer is required (found %s).\npy4200A uses the X | Y union type syntax introduced in Python 3.10.\nInstall Python 3.11 (recommended): winget install Python.Python.3.11\nThen point MATLAB to it:\n    pyenv(''Version'', ''C:\\path\\to\\python3.11\\python.exe'')', char(pe.Version));
    end
    if verParts(1) == 3 && verParts(2) >= 13
        error('MAT4200A:setup:pythonTooNew', 'Python %s is not supported by MATLAB R2025b (max: 3.12).\nInstall Python 3.12 from https://python.org and point MATLAB to it:\n    pyenv(''Version'', ''C:\\path\\to\\python3.12\\python.exe'')', char(pe.Version));
    end
end

%% ── 3. Import check ──────────────────────────────────────────────────────
try
    py.importlib.import_module('py4200A');
    fprintf('[MAT4200A] py4200A imported successfully.\n');
catch ME
    pyExe = char(pe.Executable);
    fprintf('[MAT4200A] Import error  : %s\n', ME.message);
    fprintf('[MAT4200A] MATLAB Python : %s\n', pyExe);

    % Show where Python searches for packages.
    [~, sysPathOut] = system(['"' pyExe '" -c "import sys; print(chr(10).join(sys.path))" 2>&1']);
    fprintf('[MAT4200A] Python sys.path:\n');
    sysPathLines = strsplit(strtrim(sysPathOut), newline);
    for k = 1:numel(sysPathLines)
        fprintf('    %s\n', sysPathLines{k});
    end

    % Check whether py4200a is visible to this exact Python executable.
    [pipStatus, pipOut] = system(['"' pyExe '" -m pip show py4200a 2>&1']);
    if pipStatus == 0
        fprintf('[MAT4200A] pip show py4200a:\n%s\n', strtrim(pipOut));
        error('MAT4200A:setup:notImportable', 'py4200A is installed (see pip show above) but cannot be imported.\nCommon causes on Windows:\n  1. Bitness mismatch: MATLAB is 64-bit but Python or a dependency is 32-bit.\n  2. Missing Visual C++ runtime required by a native extension.\n  3. A dependency (pyvisa, numpy, gpib-ctypes) failed to load.\nTry force-reinstalling into MATLAB''s Python:\n    "%s" -m pip install --force-reinstall py4200a[visa-py]\nthen restart MATLAB and run setup again.', pyExe);
    end

    answer = input('Install py4200a now via pip? [y/N]: ', 's');
    if strcmpi(strtrim(answer), 'y')
        fprintf('[MAT4200A] Running: pip install py4200a\n');
        [status, out] = system(['"' pyExe '" -m pip install py4200a[visa-py]']);
        if status == 0
            % terminate() is not supported in InProcess mode, so the only
            % reliable way to pick up the new package is a MATLAB restart.
            error('MAT4200A:setup:restartRequired', 'py4200A was installed successfully.\nPlease restart MATLAB and run setup again to complete setup.');
        else
            error('MAT4200A:setup:installFailed', 'pip install failed:\n%s', out);
        end
    else
        error('MAT4200A:setup:importFailed', 'py4200A is not installed.\nInstall it with:  pip install py4200a\nThen restart MATLAB and run setup again.');
    end
end

fprintf('[MAT4200A] Setup complete. You can now use MAT4200A.KI4200A(...).\n');
