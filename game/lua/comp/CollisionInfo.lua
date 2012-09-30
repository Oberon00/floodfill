local C = component 'CollisionInfoComponent'

local util = require 'util'

local function checkVec(v, ok)
	if type(v) == 'string' then
		return ok[v]
	end
	local result = true
	if v.x < 0 then
		result = result and ok.w
	elseif v.x > 0 then
		result = result and ok.e
	end
	if v.y < 0 then
		result = result and ok.n
	elseif v.y > 0 then
		result = result and ok.s
	end
	return result
end

function C:init(tile)
	self.tile = tile
end

function C:canEnter(entity, dir, from, to)
	return checkVec(dir, self.tile.enterable)
end

function C:canLeave(entity, dir, from, to)
	return checkVec(dir, self.tile.leaveable)
end

return C
