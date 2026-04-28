classdef RT_PMU_RPM < handle
% RT_PMU_RPM  MATLAB wrapper for py4200A.realtime.RT_PMU_RPM.
%
%   Controls a single RPM (Remote Preamplifier/Switch Module) in real-time
%   User Mode.  The RPM must be switched to SMU mode before it passes
%   voltage or current from an SMU channel.  RT_KI4200A does this
%   automatically on construction.
%
%   Methods:
%     set_mode(mode)  – Configure the RPM switching mode.
%
%   Properties:
%     name  – Board name as reported by the instrument (read-only).

    properties (SetAccess = private)
        % name  Board name (e.g. 'PMU1RPM1-1').
        name    (1,:) char
    end

    properties (Access = private)
        pyobj   % underlying py4200A.realtime.RT_PMU_RPM instance
    end

    % ======================================================================
    methods

        function obj = RT_PMU_RPM(pyRTRPM)
        % RT_PMU_RPM  Wrap a Python RT_PMU_RPM object.
            obj.pyobj = pyRTRPM;
            obj.name  = char(pyRTRPM.name);
        end

        % ------------------------------------------------------------------
        function set_mode(obj, mode)
        % set_mode  Configure the RPM switching mode.
        %
        %   set_mode(mode)
        %
        %   mode – MAT4200A.consts.RPMMode value.
        %          Use RPMMode.SMU to pass SMU signals through the RPM.
        %          Use RPMMode.PMU to restore pulse operation.
            obj.pyobj.set_mode(MAT4200A.consts.RPMMode.toPy(mode));
        end

    end

end
