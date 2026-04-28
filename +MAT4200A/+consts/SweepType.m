classdef SweepType < int32
% SweepType  Spacing of source points in an SMU sweep.
%
%   Mirrors py4200A.consts.SweepType.
%
%   Values:
%     LINEAR (1)  Linearly-spaced steps.
%     LOG10  (2)  Logarithmic spacing with 10 points per decade.
%     LOG25  (3)  Logarithmic spacing with 25 points per decade.
%     LOG50  (4)  Logarithmic spacing with 50 points per decade.

    enumeration
        LINEAR (1)
        LOG10  (2)
        LOG25  (3)
        LOG50  (4)
    end

    methods (Static)
        function pyEnum = toPy(val)
        % TOPY  Convert to the corresponding Python SweepType enum member.
            mod = pyimport_('py4200A.src.consts');
            pyEnum = mod.SweepType(int32(val));
        end

        function mlEnum = fromPy(pyEnum)
        % FROMPY  Wrap a Python SweepType enum as a MATLAB SweepType.
            mlEnum = MAT4200A.consts.SweepType(int32(py.getattr(pyEnum, 'value')));
        end
    end
end
