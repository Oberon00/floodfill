local oo = require 'oo'
local strings = require 'data.strings'

local C = oo.cppclass('CreditsState', jd.State)

function C:prepare()
	local bglayer = jd.drawService:layer(1)
	self.background = jd.Sprite(bglayer.group)
	self.background.texture = jd.Texture.request "credits"
	--self.background.size = 
	jd.timer:callAfter(jd.seconds(0.1), function()
		self.onKeyPressCon = jd.connect(
			jd.eventDispatcher, 'keyReleased', function()
				jd.stateManager:pop()
			end)
	end)
end

function C:pause()
	self.onKeyPressCon:disconnect()
	self.onKeyPressCon = nil
	self.background:release()
	self.background = nil
end

return CreditsState()
