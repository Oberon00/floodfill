local oo = require 'oo'
local util = require 'util'
local tabutil = require 'tabutil'
local CollisionInfoComponent = require 'comp.CollisionInfo'

local C = lclass('Tile', oo.NIL_ENV)

local function parseDirections(dirs)
	if dirs == true then
		return {n = true, e = true, s = true, w = true}
	end
	if not dirs then
		return { }
	end
	
	local result = { }
	local function entry(dir)
		if dirs:find(dir, 1, true) then
			result[dir] = true
		end
	end
	entry 'n' entry 'e' entry 's' entry 'w'
	return result
end

function C:__init(enter, leave, replObj)
	self.enterable = parseDirections(enter)
	if leave then
		self.leaveable = parseDirections(leave)
	else
		 self.leaveable = tabutil.copy(self.enterable)
	end
	
	if replObj then
		self.isPlaceholder = true
		if type(replObj) == 'function' then
			self.substitute = replObj
		else
			self.substitute = replObj.createSubstitute
		end
		assert(util.isCallable(self.substitute),
			"replObj is not a valid substitute")
	end
end

function C:__call(group, name, id, map) -- create proxy entity
	local entity = jd.Entity()
	return
		entity,
		jd.TileCollisionComponent(entity),
		CollisionInfoComponent(entity)
end

function C.logicalName(name)
	local result = name:match("([^#]+)#%d+")
	return result, result ~= nil
end

return C