local C = component 'CollisionInfoComponent'

local util = require 'util'

function C:init(tile)
	self.tile = tile
end

function C:canEnter(entity, dir, from, to)
	return self.tile.enterable[dir]
end

function C:canLeave(entity, dir, from, to)
	return self.tile.leaveable[dir]
end

return C
