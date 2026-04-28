function dep = pyBlob2Dependent_(pyBlob)
% PYBLOB2DEPENDENT_  Convert a Python BlobDependent to a MATLAB Dependent object.
%
%   dep = pyBlob2Dependent_(pyBlob) converts the py4200A BlobDependent returned
%   by KI4200A.makeDependentFrom into a native MATLAB Dependent object.
%
%   Axis ordering:
%     The first dimension of the data (rows) = outermost parameter loop.
%     The last  dimension of the data (cols) = innermost sweep axis.
%   This matches both the BlobDependent convention and the Dependent class
%   field-ordering convention.
%
%   Requires: Dependent class (from the Dependant toolbox) on the MATLAB path.

    % ── Data array ────────────────────────────────────────────────────────
    data = pyNdArray2double_(pyBlob.value);

    % ── Parameter struct ──────────────────────────────────────────────────
    pyDep  = cell(pyBlob.dependency);          % py.list of name strings
    pyPars = pyBlob.parameters;                % py.dict

    names  = cellfun(@char, pyDep, 'UniformOutput', false);
    params = struct();
    for k = 1:numel(names)
        n          = names{k};
        coords     = pyList2double_(py.list(pyPars{n}.tolist()));
        params.(n) = coords;                   % 1×N row vector
    end

    % ── Build Dependent ───────────────────────────────────────────────────
    dep = Dependent(data, ...
                    Parameters = params, ...
                    Label      = string(char(pyBlob.label)), ...
                    Log        = string(char(pyBlob.log)));
end
