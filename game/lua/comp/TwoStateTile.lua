local C = component 'TwoStateTileComponent'

function C:init(map, tid1, tid2)
	self.map = map
	self.tid1 = tid1
	self.tid2 = tid2
end

function C:initComponent()
	self.tpos = self.parent:require 'TilePositionComponent'
	local tid = self.map:get(self.tpos.tilePosition)
	self._state = tid == self.tid1
	assert(self.state or tid == self.tid2, "undefined state")
end

function C:cleanupComponent()
	self.tpos = nil
	self.map = nil
end

function C:setState(state)
	self._state = state
	self.map:set(self.tpos.tilePosition, self._state and self.tid1 or self.tid2)
end

function C:state()
	return not not self._state
end

function C:toggleState()
	self:setState(not self._state)
end

return C
