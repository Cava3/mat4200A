classdef SourceFunction < int32
% SourceFunction  Waveform function assigned to an SMU source.
%
%   Mirrors py4200A.consts.SourceFunction.
%
%   Values:
%     NONE     (0)  Not configured.
%     SWEEP    (1)  Sweep from start to stop in steps.
%     STEP     (2)  Outer step loop for a nested SMU sweep.
%     CONSTANT (3)  Fixed output level.

    enumeration
        NONE     (0)
        SWEEP    (1)
        STEP     (2)
        CONSTANT (3)
    end

    methods (Static)
        function pyEnum = toPy(val)
        % TOPY  Convert to the corresponding Python SourceFunction enum member.
            mod = pyimport_('py4200A.src.consts');
            pyEnum = mod.SourceFunction(int32(val));
        end

        function mlEnum = fromPy(pyEnum)
        % FROMPY  Wrap a Python SourceFunction enum as a MATLAB SourceFunction.
            mlEnum = MAT4200A.consts.SourceFunction(int32(py.getattr(pyEnum, 'value')));
        end
    end
end
