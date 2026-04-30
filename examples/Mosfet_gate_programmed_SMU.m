%% MOSFET Gate — Programmed SMU
% Measures MOSFET output characteristics (Isource vs Vsource) using
% two SMUs in programmed sweep mode.
%
%   SMU2 (gate)   — steps Vgate  from 0 V to 5 V in 1 V steps.
%   SMU3 (source) — sweeps Vsource from 0 V to 15 V in 0.1 V steps.
%
% Results are assembled into a 2-D Dependent and plotted as a family of
% Isrc(Vsrc) curves, one per gate voltage.

%% Connect and reset
INST_RESOURCE_STR = 'GPIB0::17::INSTR';
% INST_RESOURCE_STR = 'TCPIP0::192.0.2.0::1225::SOCKET';

ki4200 = MAT4200A.KI4200A(INST_RESOURCE_STR);
ki4200.reset();
ki4200.test_mode = MAT4200A.consts.RPMMode.SMU;

%% Get the SMUs
source = ki4200.getSMU(3);
gate   = ki4200.getSMU(2);
unused = ki4200.getSMU(1);
unused.deactivate();

%% Configure the SMUs
gate.setupSMU('VGT', 'IGT', ...
    MAT4200A.consts.SourceType.VOLT, ...
    MAT4200A.consts.SourceFunction.STEP);
gate.setStepFunction(0, 5, 1, 0.1);

source.setupSMU('VSRC', 'ISRC', ...
    MAT4200A.consts.SourceType.VOLT, ...
    MAT4200A.consts.SourceFunction.SWEEP);
source.setSweepFunction(MAT4200A.consts.SweepType.LINEAR, 0, 15, 0.1, 0.05);

%% Configure the display
ki4200.display_ctrl.displayGraph(source.voltage_measurement, source.current_measurement);

%% Run and wait for test
fprintf('Starting test.\n');
t_start = tic;
ki4200.runTest();
ki4200.waitForTestEnd();

%% Collect results as a Dependent
result = ki4200.makeDependentFrom( ...
    source.current_measurement, ...
    {source.voltage_measurement, gate.voltage_measurement});

fprintf('Done. (%.1fs)\n', toc(t_start));
ki4200.disconnect();

%% Plot Isource vs Vsource — one curve per gate voltage
colors = {'red', 'green', 'blue', 'magenta', 'yellow', 'cyan'};

vgt_values  = result.Parameters.VGT;
vsrc_values = result.Parameters.VSRC;

figure;
hold on;
for i = 1 : numel(vgt_values)
    % result{vgt_values(i), :} selects the row by physical gate voltage value.
    plot(vsrc_values, result{vgt_values(i), :}, ...
        'Color', colors{mod(i-1, numel(colors)) + 1}, ...
        'DisplayName', sprintf('Gate = %.2f V', vgt_values(i)));
end
hold off;
xlabel('Vsource (V)');
ylabel('Isource (A)');
legend('Location', 'northwest');
grid on;
