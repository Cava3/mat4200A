function data = pyNdArray2double_(pyArr)
% PYNDARRAY2DOUBLE_  Convert a numpy ndarray to a MATLAB double array.
%
%   data = pyNdArray2double_(pyArr) converts a Python numpy.ndarray returned
%   by a py4200A method into a MATLAB double array with matching dimensions.
%
%   Notes:
%     - numpy uses row-major (C) storage while MATLAB uses column-major
%       (Fortran) storage.  For 2-D arrays the result is automatically
%       transposed so that data(i,j) in MATLAB corresponds to arr[i-1,j-1]
%       in Python (row = outer parameter, column = inner sweep axis).
%     - For N > 2 dimensions the raw column-major data is returned reshaped
%       to the *reversed* numpy shape; consult the BlobDependent.shape
%       property to understand axis ordering.
%
%   This is a package-private helper used by BlobDependent.

    % Retrieve the numpy shape as a MATLAB row vector of doubles
    pyShape = pyArr.shape;
    sz = cellfun(@double, cell(pyShape));   % e.g. [3 5] for a (3,5) array

    % Flatten to 1-D (C order = row-major), convert to MATLAB double
    flat = double(py.array.array('d', pyArr.flatten().tolist()));

    ndim = numel(sz);
    if ndim == 0
        data = flat;                        % scalar
    elseif ndim == 1
        data = flat(:)';                    % row vector
    elseif ndim == 2
        % reshape into [cols, rows] then transpose → [rows, cols]
        data = reshape(flat, fliplr(sz))';
    else
        % N-D: reshape with reversed dimension order.
        % Axis k in numpy corresponds to dimension (ndim-k) in MATLAB.
        data = reshape(flat, fliplr(sz));
    end
end
