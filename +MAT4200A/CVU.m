classdef CVU < handle
% CVU  MATLAB wrapper for py4200A.boards.CVU.
%
%   Represents a Capacitance-Voltage Unit (CVU) board equipped in the
%   Keithley 4200A.  Instances are returned by KI4200A.l_equipment when
%   a CVU is detected.
%
%   Properties:
%     name       – Board identifier (e.g. 'CVU1'), read-only.
%     slot       – Mainframe slot number, read-only.
%     board_type – MAT4200A.consts.BoardType.CVU (read-only).

    properties (SetAccess = private)
        % name  Board identifier as reported by the instrument.
        name    (1,:) char

        % slot  Physical mainframe slot number.
        slot    (1,1) double

        % board_type  Always BoardType.CVU.
        board_type  MAT4200A.consts.BoardType
    end

    properties (Access = private)
        pyobj   % underlying py4200A.boards.CVU instance
    end

    % ======================================================================
    methods

        function obj = CVU(pyCVU)
        % CVU  Wrap a Python CVU object (returned by KI4200A.l_equipment).
            obj.pyobj      = pyCVU;
            obj.name       = char(pyCVU.name);
            obj.slot       = double(pyCVU.slot);
            obj.board_type = MAT4200A.consts.BoardType.CVU;
        end

    end

end
