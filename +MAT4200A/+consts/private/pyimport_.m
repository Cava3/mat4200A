function mod = pyimport_(modname)
% PYIMPORT_  Cached Python module import for the MAT4200A package.
%
%   mod = pyimport_(modname) imports the Python module identified by
%   MODNAME (e.g. 'py4200A.src.consts') and caches it so that repeated
%   calls within a session avoid redundant import overhead.
%
%   This is a package-private helper; call it from any class inside
%   +MAT4200A/ as  mod = pyimport_('py4200A.src.consts').

    persistent cache;
    if isempty(cache)
        cache = containers.Map('KeyType', 'char', 'ValueType', 'any');
    end

    if ~cache.isKey(modname)
        cache(modname) = py.importlib.import_module(modname);
    end

    mod = cache(modname);
end
