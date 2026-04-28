classdef VoltageSourceRange < int32
% VoltageSourceRange  Voltage source range code for the DV real-time command.
%
%   Mirrors py4200A.realtime.consts.VoltageSourceRange.
%
%   Values:
%     AUTORANGE    (0)  Automatic range selection.
%     R_20V        (1)  20 V range.
%     R_200V       (2)  200 V range.
%     R_200MV      (3)  200 mV range.
%     R_2V         (4)  2 V range.
%     LIMITED_AUTO (5)  Limited auto-range.
%
%   Example:
%     smu.setVoltageOutput(1.5, 0.01, MAT4200A.consts.VoltageSourceRange.R_2V);

    enumeration
        AUTORANGE    (0)
        R_20V        (1)
        R_200V       (2)
        R_200MV      (3)
        R_2V         (4)
        LIMITED_AUTO (5)
    end

    methods (Static)
        function pyEnum = toPy(val)
        % TOPY  Convert to the corresponding Python VoltageSourceRange enum member.
            mod = pyimport_('py4200A.src.realtime.consts');
            pyEnum = mod.VoltageSourceRange(int32(val));
        end

        function mlEnum = fromPy(pyEnum)
        % FROMPY  Wrap a Python VoltageSourceRange enum as a MATLAB VoltageSourceRange.
            mlEnum = MAT4200A.consts.VoltageSourceRange(int32(py.getattr(pyEnum, 'value')));
        end
    end
end
