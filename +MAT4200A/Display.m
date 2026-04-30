classdef Display < handle
% Display  MATLAB wrapper for py4200A.results.Display.
%
%   Controls the KXCI display of the Keithley 4200A: list mode (tabular
%   numeric output) and graph mode (X–Y plot with optional second Y-axis).
%
%   An instance is returned by KI4200A.display_ctrl; do not construct directly.
%
%   Properties:
%     display_mode  - Active mode: 0=none, 1=graph, 2=list
%                     (read/write, mirroring py4200A.consts.DisplayMode).
%
%   Example – list mode:
%     ki.display_ctrl.displayList({'VGS','IDS'});
%
%   Example – graph mode:
%     ki.display_ctrl.displayGraph(smu1.voltage_measurement, smu2.current_measurement);

    properties (Dependent)
        % display_mode  Active KXCI display mode.
        %   0 = DisplayMode.NONE, 1 = DisplayMode.GRAPH, 2 = DisplayMode.LIST
        display_mode
    end

    properties (Access = private)
        pyobj   % underlying py4200A.results.Display instance
    end

    % ======================================================================
    methods

        function obj = Display(pyDisplay)
        % Display  Wrap a Python Display object (called internally by KI4200A).
            obj.pyobj = pyDisplay;
        end

        % ------------------------------------------------------------------
        function displayList(obj, measurement_names)
        % displayList  Show a list of named measurements in KXCI LIST mode.
        %
        %   displayList(measurement_names) where measurement_names is a
        %   cell array of char / string measurement labels, e.g. {'VGS','IDS'}.
            arguments
                obj              (1,1) MAT4200A.Display
                measurement_names
            end
            if ~iscell(measurement_names)
                measurement_names = {measurement_names};
            end
            pyNames = py.list(cellfun(@char, measurement_names, 'UniformOutput', false));
            obj.pyobj.displayList(pyNames);
        end

        % ------------------------------------------------------------------
        function displayGraph(obj, x, y1, y2)
        % displayGraph  Configure the KXCI graph display.
        %
        %   displayGraph(x, y1) plots y1 vs x.
        %   displayGraph(x, y1, y2) adds a second Y-axis.
        %
        %   x, y1, y2 must be MAT4200A.Measurement objects.
        %   Use a Measurement with name='T' for the time axis.
            arguments
                obj (1,1) MAT4200A.Display
                x   (1,1) MAT4200A.Measurement
                y1  (1,1) MAT4200A.Measurement
                y2             MAT4200A.Measurement = MAT4200A.Measurement.empty()
            end
            if isempty(y2)
                obj.pyobj.displayGraph(x.pyobj, y1.pyobj);
            else
                obj.pyobj.displayGraph(x.pyobj, y1.pyobj, y2.pyobj);
            end
        end

    end

    % ======================================================================
    methods

        function v = get.display_mode(obj)
            v = double(py.getattr(obj.pyobj.display_mode, 'value'));
        end

        function set.display_mode(obj, value)
            mod = pyimport_('py4200A.src.consts');
            obj.pyobj.display_mode = mod.DisplayMode(int32(value));
        end

    end

end
