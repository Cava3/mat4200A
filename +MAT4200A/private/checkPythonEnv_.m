function checkPythonEnv_()
% CHECKPYTHONENV_  Validate the Python environment before first instrument use.
%
%   Called automatically by KI4200A and RT_KI4200A constructors.
%   Checks that Python 3.10–3.12 is active and that py4200A is importable,
%   with actionable error messages for each failure mode.

    pe = pyenv();
    if ~strcmp(pe.Status, 'NotLoaded')
        assertVersion_(pe);
    end

    try
        pyimport_('py4200A');
    catch ME
        error('MAT4200A:checkPythonEnv:importFailed', 'py4200A cannot be imported: %s\nInstall it with:  pip install py4200a\nIf MATLAB is using the wrong Python, run:\n    pyenv(''Version'', ''/path/to/python3.11'')', ME.message);
    end

    if strcmp(pe.Status, 'NotLoaded')
        assertVersion_(pyenv());
    end
end

% ── local helper ──────────────────────────────────────────────────────────
function assertVersion_(pe)
    v = sscanf(char(pe.Version), '%d.%d');
    if numel(v) < 2, return; end
    if v(1) < 3 || (v(1) == 3 && v(2) < 10)
        error('MAT4200A:checkPythonEnv:pythonTooOld', 'Python 3.10+ required (found %s).\nRun: pyenv(''Version'', ''/path/to/python3.11'')', char(pe.Version));
    end
end
