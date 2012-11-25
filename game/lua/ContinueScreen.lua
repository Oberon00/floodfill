local oo = require 'oo'
local strings = require 'data.strings'
local text = require 'text'
local evt = require 'evt'
local C = lclass 'ContinueScreen'

local CONT_TEXT_PADDING = 20

function C:show(onEnd, bgtexture)
	-- "Press any key to continue", bottom-center
	local tx = text.create(strings.press_any_key)
	self.continueText = tx
	text.centerX(tx)
	local vr = text.defaultLayer.view.rect
	local posY = vr.bottom - tx.bounds.h - CONT_TEXT_PADDING
	tx.position = jd.Vec2(tx.position.x, posY)

	if bgtexture then
		local bglayer = jd.drawService:layer(1)
		self.background = jd.Sprite(bglayer.group)
		self.background.texture = bgtexture
		local tsz = self.background.localBounds.size
		local lsz = bglayer.view.size
		self.background.scale = jd.Vec2(lsz.x / tsz.x, lsz.y / tsz.y)
	end
	
	self.kevents = evt.Table()
	self.kevents:connect(jd.eventDispatcher, 'keyPressed', function(event)
		local k = event.code
		self.kevents:connect(
			jd.eventDispatcher, 'keyReleased', function(event)
				if event.code == k then
					onEnd(self)
				end
			end)
	end)
end

function C:reset()
	self.onEnd = nil
	self.kevents:disconnect()
	self.kevents = nil
	self.continueText:release()
	self.continueText = nil
	if self.background then
		self.background:release()
		self.background = nil
	end
end

return C
