local C = component 'InputMovedComponent'

local ctrls = jd.conf.ctrls or { }
local possibleDirections = {
    [ctrls.moveLeft  or jd.kb.A] = jd.Vec2(-1,  0),
    [ctrls.moveRight or jd.kb.D] = jd.Vec2( 1,  0),
    [ctrls.moveUp    or jd.kb.W] = jd.Vec2( 0, -1),
    [ctrls.moveDown  or jd.kb.S] = jd.Vec2( 0,  1)
}

local SPEED = 128 -- 4 tiles/s

function C:init(colliding)
	self.colliding = colliding
end

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
		local movement = direction * SPEED * jd.timer.frameDuration:asSeconds()
		local newPos = self.pos.position + movement
		local canEnter = true
		if self.colliding then
			local newRect = jd.Rect(newPos, self.pos.size)
			local colliding = self.colliding(newRect, self.parent)
			for c in colliding:iter() do
				local cinfo = c.entity:component 'CollisionInfoComponent'
				if cinfo and not cinfo:canEnter(
				   self.parent, direction, self.pos.position, newPos) then
					canEnter = false
					break					
				end -- if cinfo
			end -- for each colliding
		end -- if self.colliding
		if canEnter then
			self.pos.position = newPos
		end
	end)
end

return C
