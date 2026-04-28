classdef KI4200A < handle
% KI4200A  MATLAB wrapper for py4200A.KI4200A.
%
%   Represents the Keithley 4200A-SCS Semiconductor Characterization System.
%   Provides a fully native MATLAB interface (no 'py.' prefix required) to
%   control SMU, CVU and PMU/RPM boards, configure sweeps, run tests, and
%   retrieve results.
%
%   ── Getting started ─────────────────────────────────────────────────────
%     ki = MAT4200A.KI4200A('GPIB0::17::INSTR');
%     % or TCP/IP:
%     ki = MAT4200A.KI4200A('TCPIP0::192.168.1.10::INSTR');
%
%   ── Instrument management ───────────────────────────────────────────────
%     scan()            – Re-scan modules, refresh l_smus / l_rpms / id.
%     reset()           – Reset to default state.
%     disconnect()
%     reconnect()
%     getError()        – Return the last KXCI error string.
%     write(command)    – Send a raw KXCI command.
%     response = query(command)
%
%   ── Test execution ──────────────────────────────────────────────────────
%     runTest()
%     runTest(clear_buffer)
%     abortTest()
%     initPMU()
%     running = isTestRunning()
%     waitForTestEnd()
%
%   ── Board access ────────────────────────────────────────────────────────
%     smu = getSMU(slot)    – Returns MAT4200A.SMU.
%     rpm = getRPM(slot)    – Returns MAT4200A.PMU_RPM.
%     ki.l_smus             – cell array of MAT4200A.SMU (sorted by slot).
%     ki.l_rpms             – cell array of MAT4200A.PMU_RPM (sorted by slot).
%     ki.l_equipment        – cell array of all board wrappers.
%
%   ── Results ─────────────────────────────────────────────────────────────
%     blob = makeDependentFrom(data, params)
%     ki.all_measurements   – cell array of MAT4200A.Measurement.
%
%   ── Display ─────────────────────────────────────────────────────────────
%     ki.display_ctrl       – MAT4200A.Display object.
%
%   ── Configurable properties ─────────────────────────────────────────────
%     integration_time      – MAT4200A.consts.IntegrationTime.
%     test_mode             – MAT4200A.consts.RPMMode.
%     pmu_measure_mode      – MAT4200A.consts.PMUMeasureMode.
%     pulse_burst_count     – integer [1, 10000].
%     pmu_sample_rate       – integer [1000, 200000000] Sa/s.
%     exit_on_compliance    – logical.
%     write_termination     – char.
%     read_termination      – char.
%
%   ── Instrument identity ─────────────────────────────────────────────────
%     ki.id   – struct with fields Brand, Model, SerialNumber, SoftwareVersion.
%     ki.status – char string.

    % ── Updated by scan() ─────────────────────────────────────────────────
    properties (SetAccess = private)
        % id  Instrument identity struct.
        %   Fields: Brand, Model, SerialNumber, SoftwareVersion.
        id          struct

        % l_equipment  All detected boards as a cell array of wrapper objects.
        l_equipment cell

        % l_smus  SMU boards sorted by slot. Each element is a MAT4200A.SMU.
        l_smus      cell

        % l_rpms  PMU/RPM boards sorted by slot. Each element is MAT4200A.PMU_RPM.
        l_rpms      cell

        % display_ctrl  Display controller for the KXCI screen.
        display_ctrl    MAT4200A.Display

        % all_measurements  Flat cell array of all Measurement objects across boards.
        all_measurements cell
    end

    % ── Instrument-backed properties ──────────────────────────────────────
    properties (Dependent)
        % status  Current instrument state as a char string.
        status

        % exit_on_compliance  If true, sweep stops when a compliance limit is hit.
        exit_on_compliance

        % integration_time  ADC integration time for SMU measurements.
        integration_time

        % test_mode  RPM mode used when running a test.
        test_mode

        % pmu_measure_mode  Acquisition mode for all PMU channels.
        pmu_measure_mode

        % pulse_burst_count  Number of pulses per test run [1, 10000].
        pulse_burst_count

        % pmu_sample_rate  Waveform capture rate in Sa/s [1000, 200000000].
        pmu_sample_rate

        % write_termination  Command termination character(s) sent to the instrument.
        write_termination

        % read_termination  Response termination character(s) expected from the instrument.
        read_termination
    end

    properties (Access = private)
        pyobj   % underlying py4200A.KI4200A instance
    end

    % ======================================================================
    methods

        function obj = KI4200A(instrument_resource_string)
        % KI4200A  Connect to the instrument and initialise.
        %
        %   ki = KI4200A(instrument_resource_string)
        %
        %   instrument_resource_string – VISA resource string, e.g.
        %     'GPIB0::17::INSTR'   (IEEE-488 / GPIB)
        %     'TCPIP0::192.168.1.10::INSTR'  (Ethernet / TCP-IP)
        %
        %   The constructor scans the mainframe for equipped modules,
        %   populates l_smus, l_rpms, and id automatically.
            mod          = pyimport_('py4200A');
            obj.pyobj    = mod.KI4200A(char(instrument_resource_string));
            obj.syncState_();
        end

        % ==================================================================
        %  Instrument management
        % ==================================================================

        function scan(obj)
        % scan  Re-scan for equipped modules and refresh all board lists.
        %
        %   Repopulates id, l_equipment, l_smus, l_rpms, and all_measurements.
            obj.pyobj.scan();
            obj.syncState_();
        end

        % ------------------------------------------------------------------
        function reset(obj)
        % reset  Reset the instrument to its default state.
        %
        %   Clears the buffer and all errors, resets all instruments, and
        %   deactivates all SMU channels.
            obj.pyobj.reset();
        end

        % ------------------------------------------------------------------
        function disconnect(obj)
        % disconnect  Close the connection to the instrument.
            obj.pyobj.disconnect();
        end

        % ------------------------------------------------------------------
        function reconnect(obj)
        % reconnect  Reconnect after a previous disconnect.
            obj.pyobj.reconnect();
            obj.syncState_();
        end

        % ------------------------------------------------------------------
        function err = getError(obj)
        % getError  Query and return the last KXCI error message.
        %
        %   err = getError()  returns a char string.
            err = char(obj.pyobj.getError());
        end

        % ------------------------------------------------------------------
        function write(obj, command)
        % write  Send a raw KXCI command string to the instrument.
        %
        %   write(command)  does not read a response.
        %   On TCP/IP connections this is automatically redirected to query.
            obj.pyobj.write(char(command));
        end

        % ------------------------------------------------------------------
        function response = query(obj, command)
        % query  Send a KXCI command and return the response.
        %
        %   response = query(command)  returns a char string.
            response = char(obj.pyobj.query(char(command)));
        end

        % ==================================================================
        %  Test execution
        % ==================================================================

        function runTest(obj, clear_buffer)
        % runTest  Start the configured test sequence.
        %
        %   runTest()
        %   runTest(clear_buffer)  – logical; clear result buffer first (default true).
        %                            Only applies in SMU mode.
            if nargin < 2
                obj.pyobj.runTest();
            else
                obj.pyobj.runTest(logical(clear_buffer));
            end
        end

        % ------------------------------------------------------------------
        function abortTest(obj)
        % abortTest  Abort the currently running test.
            obj.pyobj.abortTest();
        end

        % ------------------------------------------------------------------
        function initPMU(obj)
        % initPMU  Initialise the PMU in standard pulse mode.
        %
        %   Must be called before any PMU channel configuration.
            obj.pyobj.initPMU();
        end

        % ------------------------------------------------------------------
        function running = isTestRunning(obj)
        % isTestRunning  Return true if a test is currently executing.
        %
        %   running = isTestRunning()
            running = logical(obj.pyobj.isTestRunning());
        end

        % ------------------------------------------------------------------
        function waitForTestEnd(obj)
        % waitForTestEnd  Block until the instrument finishes its current test.
        %
        %   On GPIB connections with NI-VISA, this uses the hardware SRQ line.
        %   On all other connections it polls isTestRunning().
            obj.pyobj.waitForTestEnd();
        end

        % ==================================================================
        %  Board access
        % ==================================================================

        function smu = getSMU(obj, slot)
        % getSMU  Get the SMU wrapper for a given slot number.
        %
        %   smu = getSMU(slot)
        %
        %   Returns a MAT4200A.SMU handle.
        %   Raises an error if no SMU was found at that slot.
            pySMU = obj.pyobj.getSMU(int32(slot));
            smu   = MAT4200A.SMU(pySMU);
        end

        % ------------------------------------------------------------------
        function rpm = getRPM(obj, slot)
        % getRPM  Get the PMU_RPM wrapper for a given slot number.
        %
        %   rpm = getRPM(slot)
        %
        %   Slot numbering: PMU1RPM1-1 → slot 11, PMU1RPM1-2 → slot 12, etc.
        %   Returns a MAT4200A.PMU_RPM handle.
            pyRPM = obj.pyobj.getRPM(int32(slot));
            rpm   = MAT4200A.PMU_RPM(pyRPM);
        end

        % ==================================================================
        %  Results
        % ==================================================================

        function dep = makeDependentFrom(obj, data, params)
        % makeDependentFrom  Build an N-D result from a data measurement and parameters.
        %
        %   dep = makeDependentFrom(data, params)
        %
        %   data   – MAT4200A.Measurement containing the raw result values.
        %   params – MAT4200A.Measurement or cell array of MAT4200A.Measurement
        %            defining the sweep axes (may be in any order).
        %
        %   Returns a Dependent object (from the Dependant toolbox) with data
        %   shaped as [outermost_param × ... × innermost_sweep].
        %
        %   The Dependent class must be on the MATLAB path (run setup.m).
            if ~iscell(params)
                params = {params};
            end
            pyData   = data.pyobj;
            pyParams = cellfun(@(m) m.pyobj, params, 'UniformOutput', false);
            pyBlob   = obj.pyobj.makeDependentFrom(pyData, py.list(pyParams));
            dep      = pyBlob2Dependent_(pyBlob);
        end

        % ------------------------------------------------------------------
        function delete(obj)
        % Destructor – disconnect from the instrument when the object is cleared.
            try
                if ~isempty(obj.pyobj)
                    obj.pyobj.disconnect();
                end
            catch
                % Silently ignore errors during cleanup.
            end
        end

    end

    % ======================================================================
    %  Dependent property accessors
    % ======================================================================
    methods

        function v = get.status(obj)
            v = char(obj.pyobj.status.value);
        end

        % ------------------------------------------------------------------
        function v = get.exit_on_compliance(obj)
            v = logical(obj.pyobj.exit_on_compliance);
        end
        function set.exit_on_compliance(obj, value)
            obj.pyobj.exit_on_compliance = logical(value);
        end

        % ------------------------------------------------------------------
        function v = get.integration_time(obj)
            v = MAT4200A.consts.IntegrationTime.fromPy(obj.pyobj.integration_time);
        end
        function set.integration_time(obj, value)
            obj.pyobj.integration_time = MAT4200A.consts.IntegrationTime.toPy(value);
        end

        % ------------------------------------------------------------------
        function v = get.test_mode(obj)
            v = MAT4200A.consts.RPMMode.fromPy(obj.pyobj.test_mode);
        end
        function set.test_mode(obj, value)
            obj.pyobj.test_mode = MAT4200A.consts.RPMMode.toPy(value);
        end

        % ------------------------------------------------------------------
        function v = get.pmu_measure_mode(obj)
            v = MAT4200A.consts.PMUMeasureMode.fromPy(obj.pyobj.pmu_measure_mode);
        end
        function set.pmu_measure_mode(obj, value)
            obj.pyobj.pmu_measure_mode = MAT4200A.consts.PMUMeasureMode.toPy(value);
        end

        % ------------------------------------------------------------------
        function v = get.pulse_burst_count(obj)
            v = double(obj.pyobj.pulse_burst_count);
        end
        function set.pulse_burst_count(obj, value)
            obj.pyobj.pulse_burst_count = int32(value);
        end

        % ------------------------------------------------------------------
        function v = get.pmu_sample_rate(obj)
            v = double(obj.pyobj.pmu_sample_rate);
        end
        function set.pmu_sample_rate(obj, value)
            obj.pyobj.pmu_sample_rate = int32(value);
        end

        % ------------------------------------------------------------------
        function v = get.write_termination(obj)
            v = char(obj.pyobj.write_termination);
        end
        function set.write_termination(obj, value)
            obj.pyobj.write_termination = char(value);
        end

        % ------------------------------------------------------------------
        function v = get.read_termination(obj)
            v = char(obj.pyobj.read_termination);
        end
        function set.read_termination(obj, value)
            obj.pyobj.read_termination = char(value);
        end

    end

    % ======================================================================
    %  Private helpers
    % ======================================================================
    methods (Access = private)

        function syncState_(obj)
        % syncState_  Refresh all cached MATLAB-side properties from Python state.
            inst = obj.pyobj;

            % id struct
            pyId                    = inst.id;
            s.Brand                 = char(pyId{'Brand'});
            s.Model                 = char(pyId{'Model'});
            s.SerialNumber          = char(pyId{'Serial Number'});
            s.SoftwareVersion       = char(pyId{'Software Version'});
            obj.id                  = s;

            % Display controller
            obj.display_ctrl        = MAT4200A.Display(inst.display);

            % SMU list
            pySmus = cell(inst.l_smus);
            obj.l_smus = cellfun(@(s) MAT4200A.SMU(s), pySmus, ...
                                 'UniformOutput', false);

            % RPM list
            pyRpms = cell(inst.l_rpms);
            obj.l_rpms = cellfun(@(r) MAT4200A.PMU_RPM(r), pyRpms, ...
                                  'UniformOutput', false);

            % Full equipment list (mixed board types)
            pyEquip     = cell(inst.l_equipment);
            obj.l_equipment = cellfun(@(b) obj.wrapBoard_(b), pyEquip, ...
                                      'UniformOutput', false);

            % Flat measurement list
            pyMeas = cell(inst.all_measurements);
            obj.all_measurements = cellfun(@(m) MAT4200A.Measurement(m), pyMeas, ...
                                           'UniformOutput', false);
        end

        % ------------------------------------------------------------------
        function w = wrapBoard_(~, pyBoard)
        % wrapBoard_  Convert a Python board object to the appropriate MATLAB wrapper.
            typeName = char(pyBoard.board_type.name);
            switch typeName
                case 'SMU'
                    w = MAT4200A.SMU(pyBoard);
                case 'CVU'
                    w = MAT4200A.CVU(pyBoard);
                case 'PMU_RPM'
                    w = MAT4200A.PMU_RPM(pyBoard);
                otherwise
                    % Unknown board: return a minimal struct with name and type
                    w = struct('name', char(pyBoard.name), 'board_type', typeName);
            end
        end

    end

end
