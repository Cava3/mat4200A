classdef PMUPulseMode < int32
% PMUPulseMode  Voltage parameter swept or stepped by a PMU channel.
%
%   Mirrors py4200A.consts.PMUPulseMode.
%
%   Values:
%     AMPLITUDE (1)  Sweep / step the pulse high-level voltage;
%                    the base voltage is held constant.
%     BASE      (2)  Sweep / step the pulse base voltage;
%                    the amplitude is held constant.
%     DC        (3)  Sweep / step a DC voltage level (no pulse);
%                    typically used on a second channel alongside a pulsed channel.
%
%   Example:
%     rpm.setPulseSweep(MAT4200A.consts.PMUPulseMode.AMPLITUDE, 0, 2, 0.1, false, 0);

    enumeration
        AMPLITUDE (1)
        BASE      (2)
        DC        (3)
    end

    methods (Static)
        function pyEnum = toPy(val)
        % TOPY  Convert to the corresponding Python PMUPulseMode enum member.
            mod = pyimport_('py4200A.src.consts');
            pyEnum = mod.PMUPulseMode(int32(val));
        end

        function mlEnum = fromPy(pyEnum)
        % FROMPY  Wrap a Python PMUPulseMode enum as a MATLAB PMUPulseMode.
            mlEnum = MAT4200A.consts.PMUPulseMode(int32(pyEnum.value));
        end
    end
end
