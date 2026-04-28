%% MOSFET Gate — Real-Time SMU
% Measures MOSFET output characteristics using RT_KI4200A (User Mode).
% Each (Vgate, Vsource) point is set and measured individually in a
% nested loop, matching the sweep range of Mosfet_gate_programmed_SMU.m.
%
%   SMU2 (gate)   — Vgate  stepped through 0, 1, 2, 3, 4, 5 V.
%   SMU3 (source) — Vsource swept from 0 V to 15 V in 0.1 V steps.

%% Connect
INST_RESOURCE_STR = 'GPIB0::17::INSTR';
% INST_RESOURCE_STR = 'TCPIP0::192.0.2.0::1225::SOCKET';

setup;

rt = MAT4200A.RT_KI4200A(INST_RESOURCE_STR);

%% Get the SMUs
source = rt.getSMU(3);
gate   = rt.getSMU(2);
unused = rt.getSMU(1);
unused.deactivate();

%% Define sweep ranges (matching Mosfet_gate_programmed_SMU.m)
vgt_values  = linspace(0, 5,  6);    % 0, 1, 2, 3, 4, 5 V
vsrc_values = linspace(0, 15, 151);  % 0 to 15 V, step 0.1 V
results     = zeros(numel(vgt_values), numel(vsrc_values));

%% Run the sweep
fprintf('Starting test.\n');
t_start = tic;
for i = 1 : numel(vgt_values)
    gate.setVoltageOutput(vgt_values(i), 0.1);
    for j = 1 : numel(vsrc_values)
        source.setVoltageOutput(vsrc_values(j), 0.05);
        results(i, j) = source.measure_current();
    end
end
fprintf('Done. (%.1fs)\n', toc(t_start));

rt.disconnect();

%% Plot Isource vs Vsource — one curve per gate voltage
colors = {'red', 'green', 'blue', 'magenta', 'yellow', 'cyan'};

figure;
hold on;
for i = 1 : numel(vgt_values)
    plot(vsrc_values, results(i, :), ...
        'Color', colors{mod(i-1, numel(colors)) + 1}, ...
        'DisplayName', sprintf('Gate = %.2f V', vgt_values(i)));
end
hold off;
xlabel('Vsource (V)');
ylabel('Isource (A)');
legend('Location', 'northwest');
grid on;
