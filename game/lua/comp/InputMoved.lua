local C = component 'InputMovedComponent'

local possibleDirections = {
    [jd.kb.LEFT]  = jd.Vec2(-1,  0),
    [jd.kb.RIGHT] = jd.Vec2( 1,  0),
    [jd.kb.UP]    = jd.Vec2( 0, -1),
    [jd.kb.DOWN]  = jd.Vec2( 0,  1)
}

function C:initComponent()
	self.pos = self.parent:require 'PositionComponent'
	self.evts:connect(jd.mainloop, "update", function()
		local direction = jd.Vec2()
		for k, d in pairs(possibleDirections) do
			if jd.kb.isKeyPressed(k) then
				direction = direction + d
			end
		end
		self.pos:move(direction)
	end)
end

return C
