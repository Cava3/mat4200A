classdef CurrentSourceRange < int32
% CurrentSourceRange  Current source range code for the DI real-time command.
%
%   Mirrors py4200A.realtime.consts.CurrentSourceRange.
%
%   Values:
%     AUTORANGE    (0)   Automatic range selection.
%     R_100PA      (1)   100 pA range.
%     R_1NA        (2)   1 nA range.
%     R_10NA       (3)   10 nA range.
%     R_100NA      (4)   100 nA range.
%     R_1UA        (5)   1 µA range.
%     R_10UA       (6)   10 µA range.
%     R_100UA      (7)   100 µA range.
%     R_1MA        (8)   1 mA range.
%     R_10MA       (9)   10 mA range.
%     R_100MA      (10)  100 mA range.
%     R_1A         (11)  1 A range (HP SMU only).
%     LIMITED_AUTO (12)  Limited auto-range.
%     FIXED_AUTO   (13)  Fixed auto-range.
%
%   Example:
%     smu.setCurrentOutput(1e-6, 10, MAT4200A.consts.CurrentSourceRange.R_10UA);

    enumeration
        AUTORANGE    (0)
        R_100PA      (1)
        R_1NA        (2)
        R_10NA       (3)
        R_100NA      (4)
        R_1UA        (5)
        R_10UA       (6)
        R_100UA      (7)
        R_1MA        (8)
        R_10MA       (9)
        R_100MA      (10)
        R_1A         (11)
        LIMITED_AUTO (12)
        FIXED_AUTO   (13)
    end

    methods (Static)
        function pyEnum = toPy(val)
        % TOPY  Convert to the corresponding Python CurrentSourceRange enum member.
            mod = pyimport_('py4200A.src.realtime.consts');
            pyEnum = mod.CurrentSourceRange(int32(val));
        end

        function mlEnum = fromPy(pyEnum)
        % FROMPY  Wrap a Python CurrentSourceRange enum as a MATLAB CurrentSourceRange.
            mlEnum = MAT4200A.consts.CurrentSourceRange(int32(py.getattr(pyEnum, 'value')));
        end
    end
end
