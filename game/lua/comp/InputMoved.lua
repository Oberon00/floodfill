local C = component 'InputMovedComponent'

local possibleDirections = {
    [jd.kb.LEFT]  = jd.Vec2(-1,  0),
    [jd.kb.RIGHT] = jd.Vec2( 1,  0),
    [jd.kb.UP]    = jd.Vec2( 0, -1),
    [jd.kb.DOWN]  = jd.Vec2( 0,  1)
}

local SPEED = 2

function C:initComponent()
	self.pos = self.parent:require 'PositionComponent'
	local keyPressed = jd.kb.isKeyPressed
	local pairs = pairs
	local Vec2 = jd.Vec2
	self.evts:connect(jd.mainloop, "update", function()
		local direction = Vec2()
		for k, d in pairs(possibleDirections) do
			if keyPressed(k) then
				direction = direction + d
			end
		end
		if direction:isZero() then
			return
		end
		direction = direction / #direction
		local newPos = self.pos.position + direction * SPEED
		-- TODO: Collision handling
		self.pos.position = newPos
	end)
end

return C
