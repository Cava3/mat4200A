classdef SourceType < int32
% SourceType  Electrical quantity sourced or measured by an SMU.
%
%   Mirrors py4200A.consts.SourceType.
%
%   Values:
%     NONE   (0)  Not configured.
%     VOLT   (1)  Voltage source / measurement.
%     AMPERE (2)  Current source / measurement.
%     COMMON (3)  Common (ground) connection; no active source.

    enumeration
        NONE   (0)
        VOLT   (1)
        AMPERE (2)
        COMMON (3)
    end

    methods (Static)
        function pyEnum = toPy(val)
        % TOPY  Convert to the corresponding Python SourceType enum member.
            mod = pyimport_('py4200A.src.consts');
            pyEnum = mod.SourceType(int32(val));
        end

        function mlEnum = fromPy(pyEnum)
        % FROMPY  Wrap a Python SourceType enum as a MATLAB SourceType.
            mlEnum = MAT4200A.consts.SourceType(int32(pyEnum.value));
        end
    end
end
