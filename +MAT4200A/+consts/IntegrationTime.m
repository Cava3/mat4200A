classdef IntegrationTime < int32
% IntegrationTime  SMU analog-to-digital converter integration time.
%
%   Mirrors py4200A.consts.IntegrationTime.
%
%   Values:
%     SHORT  (1)  Fast, lower accuracy.
%     NORMAL (2)  Balanced (default).
%     LONG   (3)  Slow, higher accuracy.
%
%   Example:
%     ki.integration_time = MAT4200A.consts.IntegrationTime.LONG;

    enumeration
        SHORT  (1)
        NORMAL (2)
        LONG   (3)
    end

    methods (Static)
        function pyEnum = toPy(val)
        % TOPY  Convert to the corresponding Python IntegrationTime enum member.
            mod = pyimport_('py4200A.src.consts');
            pyEnum = mod.IntegrationTime(int32(val));
        end

        function mlEnum = fromPy(pyEnum)
        % FROMPY  Wrap a Python IntegrationTime enum as a MATLAB IntegrationTime.
            mlEnum = MAT4200A.consts.IntegrationTime(int32(py.getattr(pyEnum, 'value')));
        end
    end
end
