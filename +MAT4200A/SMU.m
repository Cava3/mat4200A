classdef SMU < handle
% SMU  MATLAB wrapper for py4200A.boards.SMU.
%
%   Represents a Source Measure Unit channel of the Keithley 4200A.
%   Instances are returned by KI4200A.getSMU(slot) and KI4200A.l_smus.
%
%   ── Channel definition ──────────────────────────────────────────────────
%     deactivate()
%     setupVoltmeter(name)
%     setupVoltageSource(name, source_function)
%     setupSMU(v_name, i_name, source_type, source_function)
%
%   ── Source configuration ────────────────────────────────────────────────
%     setConstantSourceValue(value, compliance)
%     setSweepFunction(sweep_type, start, stop, step, compliance)
%     setStepFunction(start, stop, step, compliance)
%     setStepFunction2(start, step, num_steps, compliance)
%     setListSweep(values, compliance, master)
%
%   ── Read-only hardware info ─────────────────────────────────────────────
%     name, slot, hp
%
%   ── Configurable properties ─────────────────────────────────────────────
%     smu_type, source_type, source_function, sweep_type
%     constant_value, compliance
%     func_start, func_stop, func_step, num_steps
%     power_off_after_test
%     delay_before_measure_during_sweep
%     hold_before_sweep_during_step
%     wait_time_after_constant_before_stepping
%
%   ── Measurement access ──────────────────────────────────────────────────
%     voltage_measurement, current_measurement

    % ── Fixed hardware info (set on construction) ─────────────────────────
    properties (SetAccess = private)
        % name  Board identifier as reported by the instrument (e.g. 'SMU1').
        name    (1,:) char

        % slot  Physical mainframe slot number.
        slot    (1,1) double

        % hp  True for a 4210/4211-SMU (high-power); raises current limit to ±1.05 A.
        hp      (1,1) logical
    end

    % ── Instrument-backed properties ─────────────────────────────────────
    properties (Dependent)
        % board_type  MAT4200A.consts.BoardType (always BoardType.SMU).
        board_type

        % smu_type  Active operating mode: SMUMode.SMU | VS | VM.
        %   Setting this property sends the MP command to the instrument.
        smu_type

        % source_type  Electrical quantity sourced: SourceType.VOLT | AMPERE | COMMON.
        source_type

        % source_function  Waveform type: SourceFunction.SWEEP | STEP | CONSTANT.
        source_function

        % sweep_type  Sweep spacing: SweepType.LINEAR | LOG10 | LOG25 | LOG50.
        sweep_type

        % constant_value  Source level for CONSTANT mode. Clamped to hardware range.
        constant_value

        % compliance  Compliance limit. Clamped to hardware range.
        compliance

        % func_start  Sweep/step start value. Clamped to hardware range.
        func_start

        % func_stop  Sweep stop value. Clamped to hardware range.
        func_stop

        % func_step  Sweep/step increment. Clamped to hardware range.
        func_step

        % num_steps  Number of steps for STEP mode. Clamped to [0, 32].
        num_steps

        % power_off_after_test  If true, the SMU output is disabled after the test.
        %   Setting this property sends the ST command immediately.
        power_off_after_test

        % delay_before_measure_during_sweep  Delay (s) before each sweep point.
        %   Setting this property sends the DT command immediately.
        delay_before_measure_during_sweep

        % hold_before_sweep_during_step  Hold time (s) at each step level.
        %   Setting this property sends the HT command immediately.
        hold_before_sweep_during_step

        % wait_time_after_constant_before_stepping  Wait (s) after constant phase.
        %   Setting this property sends the WT command immediately.
        wait_time_after_constant_before_stepping

        % voltage_measurement  MAT4200A.Measurement for the voltage channel.
        voltage_measurement

        % current_measurement  MAT4200A.Measurement for the current channel.
        current_measurement
    end

    properties (Access = private)
        pyobj   % underlying py4200A.boards.SMU instance
        % Cache wrapped Measurement objects to preserve handle identity
        v_meas_cache    MAT4200A.Measurement
        i_meas_cache    MAT4200A.Measurement
    end

    % ======================================================================
    methods

        function obj = SMU(pySMU)
        % SMU  Wrap a Python SMU object (returned by KI4200A.getSMU).
            obj.pyobj = pySMU;
            obj.name  = char(pySMU.name);
            obj.slot  = double(pySMU.slot);
            obj.hp    = logical(pySMU.hp);
            % Build cached Measurement wrappers
            obj.v_meas_cache = MAT4200A.Measurement(pySMU.voltage_measurement);
            obj.i_meas_cache = MAT4200A.Measurement(pySMU.current_measurement);
        end

        % ==================================================================
        %  Channel definition
        % ==================================================================

        function deactivate(obj)
        % deactivate  Reset / power off this SMU channel (DE + CH command).
            arguments
                obj (1,1) MAT4200A.SMU
            end
            obj.pyobj.deactivate();
        end

        % ------------------------------------------------------------------
        function setupVoltmeter(obj, voltage_measure_name)
        % setupVoltmeter  Configure this SMU as a voltmeter only (no source).
        %
        %   setupVoltmeter()
        %   setupVoltmeter(voltage_measure_name)
        %
        %   voltage_measure_name (optional) – KXCI label for the voltage
        %   measurement (max 6 uppercase alphanumeric chars).  Defaults to
        %   the current measurement name.
            arguments
                obj                  (1,1) MAT4200A.SMU
                voltage_measure_name (1,:) char = ''
            end
            obj.pyobj.setupVoltmeter(char(voltage_measure_name));
            obj.v_meas_cache = MAT4200A.Measurement(obj.pyobj.voltage_measurement);
        end

        % ------------------------------------------------------------------
        function setupVoltageSource(obj, voltage_measure_name, source_function)
        % setupVoltageSource  Configure this SMU as a voltage source (VS mode).
        %
        %   setupVoltageSource()
        %   setupVoltageSource(voltage_measure_name)
        %   setupVoltageSource(voltage_measure_name, source_function)
        %
        %   source_function – MAT4200A.consts.SourceFunction value.
            arguments
                obj                  (1,1) MAT4200A.SMU
                voltage_measure_name (1,:) char                          = ''
                source_function      (1,1) MAT4200A.consts.SourceFunction = MAT4200A.consts.SourceFunction.NONE
            end
            obj.pyobj.setupVoltageSource(char(voltage_measure_name), MAT4200A.consts.SourceFunction.toPy(source_function));
            obj.v_meas_cache = MAT4200A.Measurement(obj.pyobj.voltage_measurement);
        end

        % ------------------------------------------------------------------
        function setupSMU(obj, voltage_measure_name, current_measure_name, source_type, source_function)
        % setupSMU  Configure this SMU as a full source-measure unit.
        %
        %   setupSMU(v_name, i_name, source_type, source_function)
        %
        %   All four arguments must be supplied (or left empty to keep the
        %   current value):
        %     v_name         – char label for the voltage measurement.
        %     i_name         – char label for the current measurement.
        %     source_type    – MAT4200A.consts.SourceType.
        %     source_function– MAT4200A.consts.SourceFunction.
            arguments
                obj                  (1,1) MAT4200A.SMU
                voltage_measure_name (1,:) char                           = ''
                current_measure_name (1,:) char                           = ''
                source_type          (1,1) MAT4200A.consts.SourceType     = MAT4200A.consts.SourceType.NONE
                source_function      (1,1) MAT4200A.consts.SourceFunction = MAT4200A.consts.SourceFunction.NONE
            end
            obj.pyobj.setupSMU(char(voltage_measure_name), char(current_measure_name), ...
                MAT4200A.consts.SourceType.toPy(source_type), MAT4200A.consts.SourceFunction.toPy(source_function));
            % Refresh measurement wrappers (names may have changed)
            obj.v_meas_cache = MAT4200A.Measurement(obj.pyobj.voltage_measurement);
            obj.i_meas_cache = MAT4200A.Measurement(obj.pyobj.current_measurement);
        end

        % ==================================================================
        %  Source configuration
        % ==================================================================

        function setConstantSourceValue(obj, value, compliance)
        % setConstantSourceValue  Set a fixed source level for CONSTANT mode.
        %
        %   setConstantSourceValue()
        %   setConstantSourceValue(value)
        %   setConstantSourceValue(value, compliance)
            arguments
                obj        (1,1) MAT4200A.SMU
                value      (1,1) double = 0.0
                compliance (1,1) double = 0.0
            end
            obj.pyobj.setConstantSourceValue(double(value), double(compliance));
        end

        % ------------------------------------------------------------------
        function setSweepFunction(obj, sweep_type, start, stop, step, compliance)
        % setSweepFunction  Configure a linear or log voltage/current sweep.
        %
        %   setSweepFunction(sweep_type, start, stop, step)
        %   setSweepFunction(sweep_type, start, stop, step, compliance)
        %
        %   sweep_type – MAT4200A.consts.SweepType (default: LINEAR).
        %   Limits: max 1024 steps.
            arguments
                obj        (1,1) MAT4200A.SMU
                sweep_type (1,1) MAT4200A.consts.SweepType = MAT4200A.consts.SweepType.LINEAR
                start      (1,1) double = 0.0
                stop       (1,1) double = 0.0
                step       (1,1) double = 0.0
                compliance (1,1) double = 0.0
            end
            obj.pyobj.setSweepFunction(MAT4200A.consts.SweepType.toPy(sweep_type), double(start), double(stop), double(step), double(compliance));
        end

        % ------------------------------------------------------------------
        function setStepFunction(obj, start, stop, step, compliance)
        % setStepFunction  Configure a step function by start / stop / step.
        %
        %   setStepFunction(start, stop, step)
        %   setStepFunction(start, stop, step, compliance)
        %
        %   The number of steps is computed automatically as
        %   floor(|stop-start|/step) + 1.  Maximum 32 steps.
            arguments
                obj        (1,1) MAT4200A.SMU
                start      (1,1) double = 0.0
                stop       (1,1) double = 0.0
                step       (1,1) double = 0.0
                compliance (1,1) double = 0.0
            end
            obj.pyobj.setStepFunction(double(start), double(stop), double(step), double(compliance));
        end

        % ------------------------------------------------------------------
        function setStepFunction2(obj, start, step, num_steps, compliance)
        % setStepFunction2  Configure a step function by start / step / count.
        %
        %   setStepFunction2(start, step, num_steps)
        %   setStepFunction2(start, step, num_steps, compliance)
        %
        %   Maximum 32 steps.
            arguments
                obj        (1,1) MAT4200A.SMU
                start      (1,1) double = 0.0
                step       (1,1) double = 0.0
                num_steps  (1,1) double = 0
                compliance (1,1) double = 0.0
            end
            obj.pyobj.setStepFunction2(double(start), double(step), int32(num_steps), double(compliance));
        end

        % ------------------------------------------------------------------
        function setListSweep(obj, values, compliance, master)
        % setListSweep  Sweep through an arbitrary list of source values.
        %
        %   setListSweep(values)
        %   setListSweep(values, compliance)
        %   setListSweep(values, compliance, master)
        %
        %   values     – 1×N double vector (1 to 4096 elements).
        %   compliance – compliance limit (default 0, keeps current value).
        %   master     – logical; true if this channel triggers the other
        %                synchronized list channels (default false).
            arguments
                obj        (1,1) MAT4200A.SMU
                values     (1,:) double
                compliance (1,1) double  = 0.0
                master     (1,1) logical = false
            end
            pyVals = py.list(num2cell(double(values)));
            obj.pyobj.setListSweep(pyVals, double(compliance), logical(master));
        end

    end

    % ======================================================================
    %  Dependent property accessors
    % ======================================================================
    methods

        function v = get.board_type(obj)
            v = MAT4200A.consts.BoardType.fromPy(obj.pyobj.board_type);
        end

        % ------------------------------------------------------------------
        function v = get.smu_type(obj)
            v = MAT4200A.consts.SMUMode.fromPy(obj.pyobj.smu_type);
        end
        function set.smu_type(obj, value)
            obj.pyobj.smu_type = MAT4200A.consts.SMUMode.toPy(value);
        end

        % ------------------------------------------------------------------
        function v = get.source_type(obj)
            v = MAT4200A.consts.SourceType.fromPy(obj.pyobj.source_type);
        end
        function set.source_type(obj, value)
            obj.pyobj.source_type = MAT4200A.consts.SourceType.toPy(value);
        end

        % ------------------------------------------------------------------
        function v = get.source_function(obj)
            v = MAT4200A.consts.SourceFunction.fromPy(obj.pyobj.source_function);
        end
        function set.source_function(obj, value)
            obj.pyobj.source_function = MAT4200A.consts.SourceFunction.toPy(value);
        end

        % ------------------------------------------------------------------
        function v = get.sweep_type(obj)
            v = MAT4200A.consts.SweepType.fromPy(obj.pyobj.sweep_type);
        end
        function set.sweep_type(obj, value)
            obj.pyobj.sweep_type = MAT4200A.consts.SweepType.toPy(value);
        end

        % ------------------------------------------------------------------
        function v = get.constant_value(obj)
            v = double(obj.pyobj.constant_value);
        end
        function set.constant_value(obj, value)
            obj.pyobj.constant_value = double(value);
        end

        % ------------------------------------------------------------------
        function v = get.compliance(obj)
            v = double(obj.pyobj.compliance);
        end
        function set.compliance(obj, value)
            obj.pyobj.compliance = double(value);
        end

        % ------------------------------------------------------------------
        function v = get.func_start(obj)
            v = double(obj.pyobj.func_start);
        end
        function set.func_start(obj, value)
            obj.pyobj.func_start = double(value);
        end

        % ------------------------------------------------------------------
        function v = get.func_stop(obj)
            v = double(obj.pyobj.func_stop);
        end
        function set.func_stop(obj, value)
            obj.pyobj.func_stop = double(value);
        end

        % ------------------------------------------------------------------
        function v = get.func_step(obj)
            v = double(obj.pyobj.func_step);
        end
        function set.func_step(obj, value)
            obj.pyobj.func_step = double(value);
        end

        % ------------------------------------------------------------------
        function v = get.num_steps(obj)
            v = double(obj.pyobj.num_steps);
        end
        function set.num_steps(obj, value)
            obj.pyobj.num_steps = int32(value);
        end

        % ------------------------------------------------------------------
        function v = get.power_off_after_test(obj)
            v = logical(obj.pyobj.power_off_after_test);
        end
        function set.power_off_after_test(obj, value)
            obj.pyobj.power_off_after_test = logical(value);
        end

        % ------------------------------------------------------------------
        function v = get.delay_before_measure_during_sweep(obj)
            v = double(obj.pyobj.delay_before_measure_during_sweep);
        end
        function set.delay_before_measure_during_sweep(obj, value)
            obj.pyobj.delay_before_measure_during_sweep = double(value);
        end

        % ------------------------------------------------------------------
        function v = get.hold_before_sweep_during_step(obj)
            v = double(obj.pyobj.hold_before_sweep_during_step);
        end
        function set.hold_before_sweep_during_step(obj, value)
            obj.pyobj.hold_before_sweep_during_step = double(value);
        end

        % ------------------------------------------------------------------
        function v = get.wait_time_after_constant_before_stepping(obj)
            v = double(obj.pyobj.wait_time_after_constant_before_stepping);
        end
        function set.wait_time_after_constant_before_stepping(obj, value)
            obj.pyobj.wait_time_after_constant_before_stepping = double(value);
        end

        % ------------------------------------------------------------------
        function v = get.voltage_measurement(obj)
            v = obj.v_meas_cache;
        end

        function v = get.current_measurement(obj)
            v = obj.i_meas_cache;
        end

    end

end
