function arr = pyList2double_(pyList)
% PYLIST2DOUBLE_  Convert a Python list of numbers to a MATLAB double row vector.
%
%   arr = pyList2double_(pyList) converts a py.list of numeric values
%   returned by a py4200A method into a MATLAB 1×N double array.
%
%   This is a package-private helper used by Measurement wrappers.

    c = cell(pyList);
    if isempty(c)
        arr = double.empty(1, 0);
    else
        arr = cellfun(@double, c);
    end
end
