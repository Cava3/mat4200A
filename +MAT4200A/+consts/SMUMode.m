classdef SMUMode < int32
% SMUMode  Operating mode of an SMU channel.
%
%   Mirrors py4200A.consts.SMUMode.
%
%   Values:
%     SMU  (0)  Full source-measure unit (voltage or current source with measurement).
%     VS   (1)  Voltage source only.
%     VM   (2)  Voltage meter only (no source).
%
%   Example:
%     smu.setupSMU('VGS', 'IDS', MAT4200A.consts.SourceType.VOLT, ...
%                  MAT4200A.consts.SourceFunction.SWEEP);

    enumeration
        SMU (0)
        VS  (1)
        VM  (2)
    end

    methods (Static)
        function pyEnum = toPy(val)
        % TOPY  Convert to the corresponding Python SMUMode enum member.
            mod = pyimport_('py4200A.src.consts');
            pyEnum = mod.SMUMode(int32(val));
        end

        function mlEnum = fromPy(pyEnum)
        % FROMPY  Wrap a Python SMUMode enum as a MATLAB SMUMode.
            mlEnum = MAT4200A.consts.SMUMode(int32(pyEnum.value));
        end
    end
end
