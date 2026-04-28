classdef PMUSourceRange < int32
% PMUSourceRange  Voltage source and measurement range of a PMU channel.
%
%   Mirrors py4200A.consts.PMUSourceRange.
%
%   Values:
%     V10 (10)  10 V range (default after PMU init).
%     V40 (40)  40 V range (extended range).
%
%   Example:
%     rpm.source_range = MAT4200A.consts.PMUSourceRange.V40;

    enumeration
        V10 (10)
        V40 (40)
    end

    methods (Static)
        function pyEnum = toPy(val)
        % TOPY  Convert to the corresponding Python PMUSourceRange enum member.
            mod = pyimport_('py4200A.src.consts');
            pyEnum = mod.PMUSourceRange(int32(val));
        end

        function mlEnum = fromPy(pyEnum)
        % FROMPY  Wrap a Python PMUSourceRange enum as a MATLAB PMUSourceRange.
            mlEnum = MAT4200A.consts.PMUSourceRange(int32(pyEnum.value));
        end
    end
end
