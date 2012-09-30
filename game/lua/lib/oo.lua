--[[
	module oo (object orientation)
--]]

local util = require 'util'

local M = { }

local function construct(cls, ...)
	local self = { }
	setmetatable(self, cls)
	local constructor = self.__init
	local cret = { }
	if constructor then
		cret = table.pack(constructor(self, ...))		
	end
	return self, table.unpack(cret)
end

local id = debug.id or util.rawtostring

function M.objectToString(obj)
	local name = getmetatable(obj).clsName
	if not name then
		return "Object: " .. id(obj)
	end
	return name .. ": " .. id(obj) 
end

function M.classToString(cls)
	return "class: " .. cls.clsName or id(cls)
end

-- class([name, [env]], [super])
-- class([super])
-- use an empty table as [env] to create a named class without exporting it
function M.class(name, env, super)
	env = env or _ENV
	if name and not super and type(name) ~= 'string' then
		super, name = name, nil
	end
	local cls = {super = super, clsName = name, __tostring = M.objectToString}
	cls.__index = cls
	setmetatable(cls, {
		__index = super,
		__call = construct,
		__tostring = M.classToString
	})
	if name and env then
		env[name] = cls
	end
	return cls
end

M.NIL_ENV = { }

M.lclass = M.class -- alias for consistence with pseudo keyword

M.mustOverride = util.failMsg "must override this method"

-- cppclass(name, [env], super)
function M.cppclass(name, env, super)
	if type(env) == 'userdata' then
		super, env = env, _ENV
	elseif not env then
		env = _ENV
	end
	assert(
		type(super) == 'userdata',
		"Only use cppclass for deriving from C++ classes! Use lclass instead.")
	assert(env[name] == nil, "oo.cppclass: name conflict")
	local oldval = _G[name]
	class(name)(super) -- create the actual class
	local classobj = _G[name]
	if env ~= _G then
		env[name], _G[name] = classobj, oldval
	end
	function classobj:__init()
		super.__init(self)
	end
	return classobj
end

if not OO_NO_KEYWORDS then
	(require 'tabutil').copyEntry(_G, 'lclass', M)
end

return M
