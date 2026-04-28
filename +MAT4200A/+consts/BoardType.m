classdef BoardType < int32
% BoardType  Hardware module type equipped in the KI4200A mainframe.
%
%   Mirrors py4200A.consts.BoardType.
%
%   Values:
%     NONE    (0)  Unrecognised or absent board.
%     SMU     (1)  Source Measure Unit.
%     CVU     (2)  Capacitance-Voltage Unit.
%     PMU_RPM (3)  Pulse Measurement Unit / Remote Pulse Measure card.

    enumeration
        NONE    (0)
        SMU     (1)
        CVU     (2)
        PMU_RPM (3)
    end

    methods (Static)
        function pyEnum = toPy(val)
        % TOPY  Convert to the corresponding Python BoardType enum member.
            mod = pyimport_('py4200A.src.consts');
            pyEnum = mod.BoardType(int32(val));
        end

        function mlEnum = fromPy(pyEnum)
        % FROMPY  Wrap a Python BoardType enum as a MATLAB BoardType.
            mlEnum = MAT4200A.consts.BoardType(int32(py.getattr(pyEnum, 'value')));
        end
    end
end
