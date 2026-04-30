%% MOSFET Gate — Programmed PMU
% Measures MOSFET output characteristics using two PMU-RPM channels in
% programmed pulse mode.
%
%   RPM11 (gate)   — steps pulse amplitude from 0 V to 5 V in 1 V steps.
%   RPM12 (source) — sweeps pulse amplitude from 0 V to 15 V in 0.1 V steps.
%
% Only high-pulse levels (VH, IH) are acquired. Results are assembled into
% a 2-D Dependent and plotted as a family of Isrc(Vsrc) curves.

%% Connect and reset
INST_RESOURCE_STR = 'GPIB0::17::INSTR';
% INST_RESOURCE_STR = 'TCPIP0::192.0.2.0::1225::SOCKET';

ki4200 = MAT4200A.KI4200A(INST_RESOURCE_STR);
ki4200.reset();
ki4200.test_mode = MAT4200A.consts.RPMMode.PMU;

%% Init PMU and test mode
ki4200.initPMU();
ki4200.pmu_measure_mode = MAT4200A.consts.PMUMeasureMode.SPOT_MEAN_DISCRETE;

%% Get the RPMs
source = ki4200.getRPM(12);
source.activated = true;
gate   = ki4200.getRPM(11);
gate.activated = true;

%% Configure pulse times
% Constraints: period 60 ns–1 s, width > 0.5*(riset+fallt), etc.
period = 1e-3;
width  = 500e-6;
riset  = 100e-9;
fallt  = 100e-9;

source.setPulseTimes(period, width, riset, fallt);
gate.setPulseTimes(period, width, riset, fallt);

%% Configure sweep and step
% Gate steps from 0 to 5 V
gate.setPulseStep(MAT4200A.consts.PMUPulseMode.AMPLITUDE, 0, 5, 1, 0);
gate.setMeasurePIV(true, false);

% Source sweeps from 0 to 15 V
source.setPulseSweep(MAT4200A.consts.PMUPulseMode.AMPLITUDE, 0, 15, 0.1, false, 0);
source.setMeasurePIV(true, false);
source.source_range = MAT4200A.consts.PMUSourceRange.V40;

%% Run and wait for test
fprintf('Starting test.\n');
t_start = tic;
ki4200.runTest();
ki4200.waitForTestEnd();

%% Collect results as a Dependent
result = ki4200.makeDependentFrom( ...
    source.ih_measurement, ...
    {source.vh_measurement, gate.vh_measurement});

ki4200.disconnect();
fprintf('Done. (%.1fs)\n', toc(t_start));

%% Plot Isource vs Vsource — one curve per gate voltage
colors = {'red', 'green', 'blue', 'magenta', 'yellow', 'cyan'};

vgt_values  = result.Parameters.(gate.vh_measurement.name);
vsrc_values = result.Parameters.(source.vh_measurement.name);

figure;
hold on;
for i = 1 : numel(vgt_values)
    % result{vgt_values(i), :} selects the row by physical gate voltage value.
    plot(vsrc_values, result{vgt_values(i), :}, ...
        'Color', colors{mod(i-1, numel(colors)) + 1}, ...
        'DisplayName', sprintf('Gate V = %.2f V', vgt_values(i)));
end
hold off;
xlabel('Source Voltage (V)');
ylabel('Source Current (A)');
legend('Location', 'northwest');
grid on;
