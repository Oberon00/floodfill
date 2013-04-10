local C = component 'InputMovedComponent'

local evt = require 'evt'

local ctrls = jd.conf.ctrls or { }
local possibleDirections = {
    [ctrls.moveLeft  or jd.kb.A] = jd.Vec2(-1,  0),
    [ctrls.moveRight or jd.kb.D] = jd.Vec2( 1,  0),
    [ctrls.moveUp    or jd.kb.W] = jd.Vec2( 0, -1),
    [ctrls.moveDown  or jd.kb.S] = jd.Vec2( 0,  1)
}

local SPEED = 128 -- 4 tiles/s


--[[
    Constructor. If specified, [moveLimitCallback] must be a function, which is
    then called with the following arguments:
        targetRect:  The jd.Rect to which the component wants to move.
        currentRect: The jd.Rect from which the movement starts.
        direction:   A jd.Vec2 specifying the direction of the movement,
                     normalized (i.e. #direction == 1)
        movement:    A jd.Vec2, so that
                     targetRect.position - currentRect.position == movement
        self:        The calling InputMovedComponent.
    It *must* return a jd.Vec2 which becomes the new position of the Entity. If
    it returns e.g. nil an error() will occur.
--]]
function C:init(moveLimitCallback)
    self.moveLimit = moveLimitCallback
    self.onStart = evt.Signal()
    self.onStop = evt.Signal()
end

function C:initComponent()
    self.firstMove = true
    self.pos = self.parent:require 'PositionComponent'
    local keyPressed = jd.kb.isKeyPressed
    local pairs = pairs
    local Vec2 = jd.Vec2
    local isZero = jd.Vec2.isZero
    
    self.evts:connect(jd.mainloop, "update", function()
        local direction = Vec2()
        for k, d in pairs(possibleDirections) do
            if keyPressed(k) then
                direction = direction + d
            end
        end
        
        if isZero(direction) then
            if not self.firstMove then
                self.onStop(self, false)
                self.firstMove = true
            end
            return
        end

        direction = direction / #direction
        local factor = SPEED * jd.timer.frameDuration:asSeconds()

        local function move(direction)
            if isZero(direction) then
                return
            end
            local movement = direction * factor
            local targetPos = self.pos.position + movement
            local canEnter = true
            if self.moveLimit then
                local targetRect = jd.Rect(targetPos, self.pos.size)
                targetPos = self.moveLimit(
                    targetRect, self.pos.rect,
                    direction, movement,
                    self)
            end -- if self.moveLimit
            self.pos.position = targetPos
        end

        move(jd.Vec2(direction.x, 0))
        move(jd.Vec2(0, direction.y))
        if self.firstMove then
            self.onStart(self);
            self.firstMove = false
        end
    end)
end

function C:cleanup()
    if not self.firstMove then
        self.onStop(self, true)
    end
    self.onStart:clear()
    self.onStop:clear()
    self.moveLimit = nil
end

return C
