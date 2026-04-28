classdef RPMMode < int32
% RPMMode  Switching mode for a Remote Pulse Measure (RPM) module.
%
%   Mirrors py4200A.consts.RPMMode.
%
%   Values:
%     PMU    (0)  PMU pulse mode (default).
%     CV_2W  (1)  CVU 2-wire mode.
%     SMU    (2)  SMU pass-through mode (required for real-time US operations).
%     CV_4W  (3)  CVU 4-wire mode.

    enumeration
        PMU   (0)
        CV_2W (1)
        SMU   (2)
        CV_4W (3)
    end

    methods (Static)
        function pyEnum = toPy(val)
        % TOPY  Convert to the corresponding Python RPMMode enum member.
            mod = pyimport_('py4200A.src.consts');
            pyEnum = mod.RPMMode(int32(val));
        end

        function mlEnum = fromPy(pyEnum)
        % FROMPY  Wrap a Python RPMMode enum as a MATLAB RPMMode.
            mlEnum = MAT4200A.consts.RPMMode(int32(pyEnum.value));
        end
    end
end
