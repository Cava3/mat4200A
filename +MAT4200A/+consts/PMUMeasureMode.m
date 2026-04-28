classdef PMUMeasureMode < int32
% PMUMeasureMode  Acquisition mode for the Pulse Measurement Unit.
%
%   Mirrors py4200A.consts.PMUMeasureMode.
%
%   Values:
%     NONE               (0)  No measurement acquired.
%     SPOT_MEAN_DISCRETE (1)  One averaged V/I point per pulse (default).
%     WAVEFORM_DISCRETE  (2)  Full time-sampled waveform per pulse.
%     SPOT_MEAN_AVERAGE  (3)  Spot-mean points averaged across all burst pulses.
%     WAVEFORM_AVERAGE   (4)  Waveforms averaged sample-by-sample across burst.
%
%   Example:
%     ki.pmu_measure_mode = MAT4200A.consts.PMUMeasureMode.WAVEFORM_DISCRETE;

    enumeration
        NONE               (0)
        SPOT_MEAN_DISCRETE (1)
        WAVEFORM_DISCRETE  (2)
        SPOT_MEAN_AVERAGE  (3)
        WAVEFORM_AVERAGE   (4)
    end

    methods (Static)
        function pyEnum = toPy(val)
        % TOPY  Convert to the corresponding Python PMUMeasureMode enum member.
            mod = pyimport_('py4200A.src.consts');
            pyEnum = mod.PMUMeasureMode(int32(val));
        end

        function mlEnum = fromPy(pyEnum)
        % FROMPY  Wrap a Python PMUMeasureMode enum as a MATLAB PMUMeasureMode.
            mlEnum = MAT4200A.consts.PMUMeasureMode(int32(pyEnum.value));
        end
    end
end
