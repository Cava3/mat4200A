% MAT4200A  MATLAB toolbox for the Keithley 4200A-SCS Parameter Analyzer.
% Version 1.0.0   (requires py4200A >= 0.2.2 and MATLAB R2019b or newer)
%
% All classes live in the MAT4200A package.  Install once via the Add-On
% Manager (MAT4200A.mltbx) — no setup call required.
%
% ── Main instrument classes ───────────────────────────────────────────────
%   MAT4200A.KI4200A       - Full sweep-mode instrument controller.
%   MAT4200A.RT_KI4200A    - Real-time User Mode (US) controller.
%
% ── Board wrappers ────────────────────────────────────────────────────────
%   MAT4200A.SMU           - Source Measure Unit channel.
%   MAT4200A.CVU           - Capacitance-Voltage Unit channel.
%   MAT4200A.PMU_RPM       - PMU / Remote Pulse Measure channel.
%   MAT4200A.RT_SMU        - Real-time SMU channel (User Mode).
%   MAT4200A.RT_PMU_RPM    - Real-time RPM channel (User Mode).
%
% ── Result classes ────────────────────────────────────────────────────────
%   MAT4200A.Measurement   - Named measurement channel and data retrieval.
%   MAT4200A.Display       - KXCI display controller (list / graph mode).
%
% ── Constants (enumerations) ─────────────────────────────────────────────
%   MAT4200A.consts.SMUMode           - SMU | VS | VM
%   MAT4200A.consts.SourceType        - VOLT | AMPERE | COMMON
%   MAT4200A.consts.SourceFunction    - SWEEP | STEP | CONSTANT
%   MAT4200A.consts.BoardType         - SMU | CVU | PMU_RPM
%   MAT4200A.consts.SweepType         - LINEAR | LOG10 | LOG25 | LOG50
%   MAT4200A.consts.RPMMode           - PMU | SMU | CV_2W | CV_4W
%   MAT4200A.consts.IntegrationTime   - SHORT | NORMAL | LONG
%   MAT4200A.consts.PMUMeasureMode    - SPOT_MEAN_DISCRETE | WAVEFORM_DISCRETE | ...
%   MAT4200A.consts.PMUPulseMode      - AMPLITUDE | BASE | DC
%   MAT4200A.consts.PMUSourceRange    - V10 | V40
%   MAT4200A.consts.CurrentSourceRange- AUTORANGE | R_100PA | R_1NA | ...
%   MAT4200A.consts.VoltageSourceRange- AUTORANGE | R_20V | R_200V | ...
%
% See also: setup, MAT4200A.KI4200A, MAT4200A.RT_KI4200A
