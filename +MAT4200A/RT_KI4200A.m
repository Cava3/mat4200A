classdef RT_KI4200A < handle
% RT_KI4200A  MATLAB wrapper for py4200A.realtime.RT_KI4200A.
%
%   Controls the Keithley 4200A in User Mode (US), enabling real-time
%   source and measure operations without a pre-programmed sweep.
%
%   This class is the lightweight alternative to KI4200A when you need
%   immediate, interactive voltage/current control — for example, biasing
%   a device while making live measurements.
%
%   ── Getting started ─────────────────────────────────────────────────────
%     rt = MAT4200A.RT_KI4200A('GPIB0::17::INSTR');
%     smu = rt.getSMU(1);
%     smu.setVoltageOutput(1.5, 0.01);
%     V = smu.measure_voltage();
%     I = smu.measure_current();
%     rt.disconnect();
%
%   ── Instrument management ───────────────────────────────────────────────
%     reset()
%     disconnect()
%     userMode()      – Re-enter User Mode (US) after another page command.
%     smu = getSMU(slot)  – Returns MAT4200A.RT_SMU.
%
%   ── Configurable properties ─────────────────────────────────────────────
%     integration_time  – MAT4200A.consts.IntegrationTime.
%     resolution        – Measurement resolution in significant digits [3–7].
%
%   ── Board lists ─────────────────────────────────────────────────────────
%     l_smus  – cell array of MAT4200A.RT_SMU (sorted by slot).
%     l_rpms  – cell array of MAT4200A.RT_PMU_RPM.

    properties (SetAccess = private)
        % l_smus  Real-time SMU channel wrappers, sorted by slot.
        l_smus  cell

        % l_rpms  Real-time RPM channel wrappers.
        l_rpms  cell
    end

    properties (Dependent)
        % integration_time  ADC integration time for all SMU channels.
        integration_time

        % resolution  Measurement resolution in significant digits (3–7).
        resolution
    end

    properties (Access = private)
        pyobj   % underlying py4200A.realtime.RT_KI4200A instance
    end

    % ======================================================================
    methods

        function obj = RT_KI4200A(instrument_resource_string)
        % RT_KI4200A  Connect to the instrument and enter User Mode.
        %
        %   rt = RT_KI4200A(instrument_resource_string)
        %
        %   instrument_resource_string – VISA resource string, e.g.
        %     'GPIB0::17::INSTR' or 'TCPIP0::192.168.1.10::INSTR'.
        %
        %   On construction the object scans for equipped boards, switches
        %   all RPMs to SMU mode, and enters User Mode automatically.
            mod       = pyimport_('py4200A.src.realtime.RT_KI4200A');
            obj.pyobj = mod.RT_KI4200A(char(instrument_resource_string));
            obj.syncState_();
        end

        % ==================================================================

        function userMode(obj)
        % userMode  Re-enter User Mode (US command).
        %
        %   Call this if a page-select command has temporarily left User Mode.
            obj.pyobj.userMode();
        end

        % ------------------------------------------------------------------
        function reset(obj)
        % reset  Reset the instrument to its default state.
        %
        %   Clears buffer and errors, resets all instruments, deactivates
        %   SMU channels, restores RPMs to SMU mode, and re-enters User Mode.
            obj.pyobj.reset();
        end

        % ------------------------------------------------------------------
        function disconnect(obj)
        % disconnect  Restore RPMs to PMU mode and close the connection.
            obj.pyobj.disconnect();
        end

        % ------------------------------------------------------------------
        function smu = getSMU(obj, slot)
        % getSMU  Get the RT_SMU wrapper for a given slot number.
        %
        %   smu = getSMU(slot)
        %
        %   Returns a MAT4200A.RT_SMU handle.
        %   Raises an error if no SMU was found at that slot.
            arguments (Output)
                smu (1,1) MAT4200A.RT_SMU
            end
            pyRTSMU = obj.pyobj.getSMU(int32(slot));
            smu     = MAT4200A.RT_SMU(pyRTSMU);
        end

        % ------------------------------------------------------------------
        function delete(obj)
        % Destructor – disconnect cleanly when the object is cleared.
            try
                if ~isempty(obj.pyobj)
                    obj.pyobj.disconnect();
                end
            catch
            end
        end

    end

    % ======================================================================
    %  Dependent property accessors
    % ======================================================================
    methods

        function v = get.integration_time(obj)
            v = MAT4200A.consts.IntegrationTime.fromPy(obj.pyobj.integration_time);
        end
        function set.integration_time(obj, value)
            obj.pyobj.integration_time = MAT4200A.consts.IntegrationTime.toPy(value);
        end

        function v = get.resolution(obj)
            v = double(obj.pyobj.resolution);
        end
        function set.resolution(obj, value)
            obj.pyobj.resolution = int32(value);
        end

    end

    % ======================================================================
    methods (Access = private)

        function syncState_(obj)
        % syncState_  Populate l_smus and l_rpms from Python state.
            pySmus = cell(obj.pyobj.l_smus);
            obj.l_smus = cellfun(@(s) MAT4200A.RT_SMU(s), pySmus, ...
                                 'UniformOutput', false);

            pyRpms = cell(obj.pyobj.l_rpms);
            obj.l_rpms = cellfun(@(r) MAT4200A.RT_PMU_RPM(r), pyRpms, ...
                                  'UniformOutput', false);
        end

    end

end
