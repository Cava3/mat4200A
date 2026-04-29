classdef RT_SMU < handle
% RT_SMU  MATLAB wrapper for py4200A.realtime.RT_SMU.
%
%   Controls a single SMU channel of the Keithley 4200A in User Mode (US).
%   Provides direct real-time source and measure operations without a
%   pre-programmed sweep setup.
%
%   User Mode must be active before calling any method.  If this object
%   was obtained via RT_KI4200A.getSMU(), this is guaranteed.
%
%   ── Source setup ────────────────────────────────────────────────────────
%     setCurrentOutput(output, compliance)
%     setCurrentOutput(output, compliance, range_code)
%     setVoltageOutput(output, compliance)
%     setVoltageOutput(output, compliance, range_code)
%     setVoltageOutputForVS(voltage)
%
%   ── Measurement triggers ────────────────────────────────────────────────
%     I = measureCurrent()   – trigger TI, return current in amperes.
%     V = measureVoltage()   – trigger TV, return voltage in volts.
%
%   ── Range and calibration ───────────────────────────────────────────────
%     setCurrentRange(range_amps, compliance)
%     setVoltageRange(range_volts, compliance)
%     setLowestCurrentRange(range_amps)
%
%   ── Data retrieval ──────────────────────────────────────────────────────
%     val = getTimestampData(channel_name)
%
%   ── Properties ──────────────────────────────────────────────────────────
%     slot  – SMU slot number (read-only).
%     hp    – true for HP SMU (read-only).

    properties (SetAccess = private)
        % slot  SMU slot number (1–8).
        slot    (1,1) double

        % hp  True for a 4210/4211-SMU (high-power).
        hp      (1,1) logical
    end

    properties (Access = private)
        pyobj   % underlying py4200A.realtime.RT_SMU instance
    end

    % ======================================================================
    methods

        function obj = RT_SMU(pyRTSMU)
        % RT_SMU  Wrap a Python RT_SMU object (returned by RT_KI4200A.getSMU).
            obj.pyobj = pyRTSMU;
            obj.slot  = double(pyRTSMU.slot);
            obj.hp    = logical(pyRTSMU.hp);
        end

        % ------------------------------------------------------------------
        function deactivate(obj)
        % deactivate  Reset this SMU channel (DV command).
            obj.pyobj.deactivate();
        end

        % ==================================================================
        %  Source setup
        % ==================================================================

        function setCurrentOutput(obj, output, compliance, range_code)
        % setCurrentOutput  DI – Configure this SMU as a current source.
        %
        %   setCurrentOutput(output, compliance)
        %   setCurrentOutput(output, compliance, range_code)
        %
        %   output     – Output current in amperes.
        %   compliance – Voltage compliance in volts.
        %   range_code – MAT4200A.consts.CurrentSourceRange (default AUTORANGE).
            if nargin < 4
                range_code = MAT4200A.consts.CurrentSourceRange.AUTORANGE;
            end
            pyRange = MAT4200A.consts.CurrentSourceRange.toPy(range_code);
            obj.pyobj.setCurrentOutput(double(output), double(compliance), pyRange);
        end

        % ------------------------------------------------------------------
        function setVoltageOutput(obj, output, compliance, range_code)
        % setVoltageOutput  DV – Configure this SMU as a voltage source.
        %
        %   setVoltageOutput(output, compliance)
        %   setVoltageOutput(output, compliance, range_code)
        %
        %   output     – Output voltage in volts (clamped to ±200 V).
        %   compliance – Current compliance in amperes.
        %   range_code – MAT4200A.consts.VoltageSourceRange (default AUTORANGE).
            if nargin < 4
                range_code = MAT4200A.consts.VoltageSourceRange.AUTORANGE;
            end
            pyRange = MAT4200A.consts.VoltageSourceRange.toPy(range_code);
            obj.pyobj.setVoltageOutput(double(output), double(compliance), pyRange);
        end

        % ------------------------------------------------------------------
        function setVoltageOutputForVS(obj, voltage)
        % setVoltageOutputForVS  DS – Update the output of a VS-mode channel.
        %
        %   setVoltageOutputForVS(voltage)
        %
        %   voltage – Target voltage in volts (clamped to ±200 V).
            obj.pyobj.setVoltageOutputForVS(double(voltage));
        end

        % ==================================================================
        %  Measurement triggers
        % ==================================================================

        function I = measureCurrent(obj)
        % measureCurrent  TI – Trigger an immediate current measurement.
        %
        %   I = measureCurrent()  returns current in amperes.
            I = double(obj.pyobj.measure_current());
        end

        % ------------------------------------------------------------------
        function V = measureVoltage(obj)
        % measureVoltage  TV – Trigger an immediate voltage measurement.
        %
        %   V = measureVoltage()  returns voltage in volts.
            V = double(obj.pyobj.measure_voltage());
        end

        % ==================================================================
        %  Range and calibration
        % ==================================================================

        function setCurrentRange(obj, range_amps, compliance)
        % setCurrentRange  RI – Switch to a specific current measurement range.
        %
        %   setCurrentRange(range_amps, compliance)
            obj.pyobj.set_current_range(double(range_amps), double(compliance));
        end

        % ------------------------------------------------------------------
        function setVoltageRange(obj, range_volts, compliance)
        % setVoltageRange  RV – Switch to a specific voltage measurement range.
        %
        %   setVoltageRange(range_volts, compliance)
            obj.pyobj.set_voltage_range(double(range_volts), double(compliance));
        end

        % ------------------------------------------------------------------
        function setLowestCurrentRange(obj, range_amps)
        % setLowestCurrentRange  RG – Set the minimum autorange floor.
        %
        %   setLowestCurrentRange(range_amps)
        %
        %   range_amps – Minimum current range in amperes (e.g. 1e-9 for 1 nA).
            obj.pyobj.set_lowest_current_range(double(range_amps));
        end

        % ==================================================================
        %  Data retrieval
        % ==================================================================

        function val = getTimestampData(obj, channel_name)
        % getTimestampData  DO – Retrieve timestamp or scalar for a named channel.
        %
        %   val = getTimestampData(channel_name)
        %
        %   channel_name – char label as set in DE/CH.
            val = double(obj.pyobj.get_timestamp_data(char(channel_name)));
        end

    end

end
