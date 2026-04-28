classdef Measurement < handle
% Measurement  MATLAB wrapper for py4200A.results.Measurement.
%
%   Represents a single named measurement channel on the KI4200A and provides
%   access to its results after a test.  Instances are returned by board
%   objects (e.g. SMU.voltage_measurement) and by KI4200A.all_measurements;
%   they are never constructed directly.
%
%   Properties (read-only from MATLAB):
%     name       - Measurement label used in KXCI commands (max 6 chars, uppercase).
%     unit       - MAT4200A.consts.SourceType (VOLT or AMPERE).
%     steps      - Number of steps configured for this measurement.
%     order      - Sweep nesting order (-1 if unconfigured, 0 = innermost sweep).
%     min_value  - Lower bound of the display range.
%     max_value  - Upper bound of the display range.
%
%   Example:
%     results = smu.voltage_measurement.getAllResults();  % 1×N double

    properties (SetAccess = private, GetAccess = public)
        % name  Measurement label (uppercase, max 6 alphanumeric characters).
        name        (1,:) char

        % unit  Electrical unit: MAT4200A.consts.SourceType.
        unit        MAT4200A.consts.SourceType
    end

    properties (Dependent)
        % steps  Total number of configured measurement points.
        steps

        % order  Nesting order in a multi-loop sweep.  0 = innermost (sweep),
        %        positive integer = outer step loop, -1 = not configured.
        order

        % min_value  Lower bound used for display / axis scaling.
        min_value

        % max_value  Upper bound used for display / axis scaling.
        max_value
    end

    properties (Access = private)
        pyobj   % underlying py4200A.results.Measurement instance
    end

    % ======================================================================
    methods

        function obj = Measurement(pyMeasurement)
        % Measurement  Wrap a Python Measurement object.
        %
        %   obj = Measurement(pyMeasurement) should not be called directly;
        %   obtain Measurement instances from board objects.
            obj.pyobj    = pyMeasurement;
            obj.name     = char(pyMeasurement.name);
            obj.unit     = MAT4200A.consts.SourceType.fromPy(pyMeasurement.unit);
        end

        % ------------------------------------------------------------------
        function result = getResultAt(obj, index)
        % getResultAt  Fetch the raw measurement result at a specific index.
        %
        %   result = getResultAt(index) returns a char string with the raw
        %   KXCI response at the given 1-based index.
            result = char(obj.pyobj.getResultAt(int32(index)));
        end

        % ------------------------------------------------------------------
        function valid = isResultValid(obj, value)
        % isResultValid  Return true if value is a valid (non-zero) numeric string.
        %
        %   valid = isResultValid(value) accepts a char or string VALUE.
            valid = logical(obj.pyobj.isResultValid(char(value)));
        end

        % ------------------------------------------------------------------
        function results = getResultSerie(obj, precedent_dimensions)
        % getResultSerie  Fetch one value per step, skipping inner-loop repetitions.
        %
        %   results = getResultSerie() returns a 1×steps double vector with one
        %   value per unique output level of this measurement.
        %
        %   results = getResultSerie(precedent_dimensions) where
        %   precedent_dimensions is a cell array of Measurement objects whose
        %   loops are nested inside this one (used to compute the stride).
            if nargin < 2 || isempty(precedent_dimensions)
                pyResult = obj.pyobj.getResultSerie();
            else
                if ~iscell(precedent_dimensions)
                    precedent_dimensions = {precedent_dimensions};
                end
                pyInner = cellfun(@(m) m.pyobj, precedent_dimensions, ...
                                  'UniformOutput', false);
                pyResult = obj.pyobj.getResultSerie(py.list(pyInner));
            end
            results = pyList2double_(pyResult);
        end

        % ------------------------------------------------------------------
        function results = getAllResults(obj)
        % getAllResults  Retrieve all measurement values from the instrument buffer.
        %
        %   results = getAllResults() returns a 1×N double row vector.
            results = pyList2double_(obj.pyobj.getAllResults());
        end

        % ------------------------------------------------------------------
        function s = toStr(obj)
        % toStr  Return a short human-readable description of this measurement.
            s = char(obj.pyobj.__str__());
        end

    end

    % ======================================================================
    %  Dependent property accessors
    % ======================================================================
    methods

        function v = get.steps(obj)
            v = double(obj.pyobj.steps);
        end
        function set.steps(obj, value)
            obj.pyobj.steps = int32(value);
        end

        function v = get.order(obj)
            v = double(obj.pyobj.order);
        end
        function set.order(obj, value)
            obj.pyobj.order = int32(value);
        end

        function v = get.min_value(obj)
            v = double(obj.pyobj.min_value);
        end
        function set.min_value(obj, value)
            obj.pyobj.min_value = double(value);
        end

        function v = get.max_value(obj)
            v = double(obj.pyobj.max_value);
        end
        function set.max_value(obj, value)
            obj.pyobj.max_value = double(value);
        end

    end

end
