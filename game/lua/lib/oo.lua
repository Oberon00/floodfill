--[[
	module oo (object orientation)
--]]

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

-- class([name, [env]], [super])
-- class([super])
function M.class(name, env, super)
	env = env or _ENV
	if name and not super and type(name) ~= 'string' then
		super, name = name, nil
	end
	local cls = {super = super, clsName = name}
	cls.__index = cls
	setmetatable(cls, {__index = super, __call = construct})
	if name  and env then
		env[name] = cls
	end
	return cls
end

M.lclass = M.class -- alias for consistence with pseudo keyword

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
	return classobj
end

if not OO_NO_KEYWORDS then
	(require 'tabutil').copyEntry(_G, 'lclass', M)
end

return M
