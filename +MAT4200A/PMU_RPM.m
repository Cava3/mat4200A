classdef PMU_RPM < handle
% PMU_RPM  MATLAB wrapper for py4200A.boards.PMU_RPM.
%
%   Represents a Power Measurement Unit / Remote Pulse Measure (PMU_RPM)
%   channel of the Keithley 4200A.  Instances are returned by
%   KI4200A.getRPM(slot) and KI4200A.l_rpms.
%
%   ── Activation ──────────────────────────────────────────────────────────
%     activated         – logical; enable/disable the PMU output (read/write).
%     deactivate()      – set activated = false.
%
%   ── Pulse configuration ─────────────────────────────────────────────────
%     setMeasurePIV(acquire_high, acquire_low)
%     setPulseTimes(period, width, riset, fallt)
%     setPulseTimes(period, width, riset, fallt, delay)
%     setPulseTrain(vbase, vamplitude)
%     setPulseStep(mode, start, stop, step)
%     setPulseStep(mode, start, stop, step, constant_v)
%     setPulseSweep(mode, start, stop, step)
%     setPulseSweep(mode, start, stop, step, dual_sweep)
%     setPulseSweep(mode, start, stop, step, dual_sweep, constant_v)
%
%   ── Configurable properties ─────────────────────────────────────────────
%     source_range  – MAT4200A.consts.PMUSourceRange.
%     load          – Device impedance in ohms [1, 10e6].
%     llec          – Load-line effect compensation enable.
%     retain_config – Retain channel configuration between test runs.
%
%   ── Measurement access ──────────────────────────────────────────────────
%     vh_measurement, ih_measurement – High-pulse V/I Measurement objects.
%     vl_measurement, il_measurement – Low-pulse V/I Measurement objects.

    properties (SetAccess = private)
        % name  Board identifier (e.g. 'PMU1RPM1-1').
        name    (1,:) char

        % slot  Numeric slot code (e.g. 11 for PMU1RPM1-1, 12 for PMU1RPM1-2).
        slot    (1,1) double

        % channel  PMU channel number derived from the board name.
        channel (1,1) double
    end

    properties (Dependent)
        % board_type  Always BoardType.PMU_RPM.
        board_type

        % activated  Output enable state.  Setting to true enables the channel.
        activated

        % source_range  Voltage source and measurement range.
        source_range

        % load  Device impedance in ohms [1, 10 MΩ].
        load

        % llec  Load-line effect compensation; true = enabled.
        llec

        % retain_config  Retain PMU configuration across consecutive test runs.
        retain_config

        % vh_measurement  Measurement for the high-pulse voltage (VH).
        vh_measurement

        % ih_measurement  Measurement for the high-pulse current (IH).
        ih_measurement

        % vl_measurement  Measurement for the low-pulse voltage (VL).
        vl_measurement

        % il_measurement  Measurement for the low-pulse current (IL).
        il_measurement
    end

    properties (Access = private)
        pyobj       % underlying py4200A.boards.PMU_RPM instance
        % Cached Measurement wrappers
        vh_cache    MAT4200A.Measurement
        ih_cache    MAT4200A.Measurement
        vl_cache    MAT4200A.Measurement
        il_cache    MAT4200A.Measurement
    end

    % ======================================================================
    methods

        function obj = PMU_RPM(pyRPM)
        % PMU_RPM  Wrap a Python PMU_RPM object (returned by KI4200A.getRPM).
            obj.pyobj   = pyRPM;
            obj.name    = char(pyRPM.name);
            obj.slot    = double(pyRPM.slot);
            obj.channel = double(pyRPM.channel);
            obj.vh_cache = MAT4200A.Measurement(pyRPM.vh_measurement);
            obj.ih_cache = MAT4200A.Measurement(pyRPM.ih_measurement);
            obj.vl_cache = MAT4200A.Measurement(pyRPM.vl_measurement);
            obj.il_cache = MAT4200A.Measurement(pyRPM.il_measurement);
        end

        % ==================================================================

        function deactivate(obj)
        % deactivate  Disable this PMU channel output.
            arguments
                obj (1,1) MAT4200A.PMU_RPM
            end
            obj.pyobj.deactivate();
        end

        % ------------------------------------------------------------------
        function setMeasurePIV(obj, acquire_high, acquire_low)
        % setMeasurePIV  Select which pulse levels are acquired.
        %
        %   setMeasurePIV(acquire_high, acquire_low)
        %
        %   acquire_high – logical; enable VH/IH measurement.
        %   acquire_low  – logical; enable VL/IL measurement.
        %   At least one must be true.
            arguments
                obj          (1,1) MAT4200A.PMU_RPM
                acquire_high (1,1) logical
                acquire_low  (1,1) logical
            end
            obj.pyobj.setMeasurePIV(logical(acquire_high), logical(acquire_low));
        end

        % ------------------------------------------------------------------
        function setPulseTimes(obj, period, width, riset, fallt, delay)
        % setPulseTimes  Set pulse timing parameters for this channel.
        %
        %   setPulseTimes(period, width, riset, fallt)
        %   setPulseTimes(period, width, riset, fallt, delay)
        %
        %   All times in seconds.
        %   period : 60 ns – 1 s   (must be the same on all channels).
        %   width  : 40 ns – (period − 10 ns); > 0.5*(riset+fallt).
        %   riset  : 20 ns – 33 ms.
        %   fallt  : 20 ns – 33 ms.
        %   delay  : 0 or ≥ 20 ns; < period − width − 0.5*(riset+fallt).
            arguments
                obj    (1,1) MAT4200A.PMU_RPM
                period (1,1) double
                width  (1,1) double
                riset  (1,1) double
                fallt  (1,1) double
                delay  (1,1) double = 0.0
            end
            obj.pyobj.setPulseTimes(double(period), double(width), double(riset), double(fallt), double(delay));
        end

        % ------------------------------------------------------------------
        function setPulseTrain(obj, vbase, vamplitude)
        % setPulseTrain  Set base and amplitude voltage levels.
        %
        %   setPulseTrain(vbase, vamplitude)
        %
        %   |vamplitude - vbase| must not exceed 10 V.
            arguments
                obj        (1,1) MAT4200A.PMU_RPM
                vbase      (1,1) double
                vamplitude (1,1) double
            end
            obj.pyobj.setPulseTrain(double(vbase), double(vamplitude));
        end

        % ------------------------------------------------------------------
        function setPulseStep(obj, mode, start, stop, step, constant_v)
        % setPulseStep  Configure a voltage step pattern for this channel.
        %
        %   setPulseStep(mode, start, stop, step)
        %   setPulseStep(mode, start, stop, step, constant_v)
        %
        %   mode      – MAT4200A.consts.PMUPulseMode.
        %   start/stop/step – voltages in volts; step must not be 0.
        %   constant_v – required when mode is AMPLITUDE or BASE.
            arguments
                obj        (1,1) MAT4200A.PMU_RPM
                mode       (1,1) MAT4200A.consts.PMUPulseMode
                start      (1,1) double
                stop       (1,1) double
                step       (1,1) double
                constant_v (1,1) double = 0.0
            end
            obj.pyobj.setPulseStep(MAT4200A.consts.PMUPulseMode.toPy(mode), double(start), double(stop), double(step), double(constant_v));
        end

        % ------------------------------------------------------------------
        function setPulseSweep(obj, mode, start, stop, step, dual_sweep, constant_v)
        % setPulseSweep  Configure a voltage sweep pattern for this channel.
        %
        %   setPulseSweep(mode, start, stop, step)
        %   setPulseSweep(mode, start, stop, step, dual_sweep)
        %   setPulseSweep(mode, start, stop, step, dual_sweep, constant_v)
        %
        %   dual_sweep – logical; back-and-forth sweep (default false).
        %   constant_v – required when mode is AMPLITUDE or BASE.
            arguments
                obj        (1,1) MAT4200A.PMU_RPM
                mode       (1,1) MAT4200A.consts.PMUPulseMode
                start      (1,1) double
                stop       (1,1) double
                step       (1,1) double
                dual_sweep (1,1) logical = false
                constant_v (1,1) double  = 0.0
            end
            obj.pyobj.setPulseSweep(MAT4200A.consts.PMUPulseMode.toPy(mode), double(start), double(stop), double(step), logical(dual_sweep), double(constant_v));
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
        function v = get.activated(obj)
            v = logical(obj.pyobj.activated);
        end
        function set.activated(obj, value)
            obj.pyobj.activated = logical(value);
        end

        % ------------------------------------------------------------------
        function v = get.source_range(obj)
            v = MAT4200A.consts.PMUSourceRange.fromPy(obj.pyobj.source_range);
        end
        function set.source_range(obj, value)
            obj.pyobj.source_range = MAT4200A.consts.PMUSourceRange.toPy(value);
        end

        % ------------------------------------------------------------------
        function v = get.load(obj)
            v = double(obj.pyobj.load);
        end
        function set.load(obj, value)
            obj.pyobj.load = double(value);
        end

        % ------------------------------------------------------------------
        function v = get.llec(obj)
            v = logical(obj.pyobj.llec);
        end
        function set.llec(obj, value)
            obj.pyobj.llec = logical(value);
        end

        % ------------------------------------------------------------------
        function v = get.retain_config(obj)
            v = logical(obj.pyobj.retain_config);
        end
        function set.retain_config(obj, value)
            obj.pyobj.retain_config = logical(value);
        end

        % ------------------------------------------------------------------
        function v = get.vh_measurement(obj), v = obj.vh_cache; end
        function v = get.ih_measurement(obj), v = obj.ih_cache; end
        function v = get.vl_measurement(obj), v = obj.vl_cache; end
        function v = get.il_measurement(obj), v = obj.il_cache; end

    end

end
