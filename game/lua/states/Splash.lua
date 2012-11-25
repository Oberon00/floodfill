local oo = require 'oo'
local Level = require 'Level'
local ContinueScreen = require 'ContinueScreen'

local C = oo.cppclass('SplashState', jd.State)

local CONT_TEXT_PADDING = 20

local maplayer = jd.drawService:layer(2)

local function skipIntro()
	return jd.stateManager:switchTo('Menu')
end

function C:prepare()
	self.screen = ContinueScreen()
	self.screen:show(skipIntro)
	self.screen.continueText.color = jd.Color(60, 255, 100, 200)
	self.level = Level(jd.conf.misc.splashLevel, maplayer.group)
	self.level:start()
	maplayer.view.rect = self.level.world.map.bounds
	self.level.world.winLevel = skipIntro
end

function C:pause()
	self.level:stop()
	self.level = nil
	self.screen:reset()
	self.screen = nil

end

return SplashState()
