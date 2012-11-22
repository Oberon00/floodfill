local oo = require 'oo'
local Level = require 'Level'
local text = require 'text'
local strings = require 'data.strings'

local C = oo.cppclass('SplashState', jd.State)

local CONT_TEXT_PADDING = 20

local maplayer = jd.drawService:layer(2)

local function skipIntro()
	return jd.stateManager:switchTo('Menu')
end

function C:prepare()
	local tx = text.create(strings.press_any_key)
	self.continueText = tx
	text.centerX(tx)
	local vr = text.defaultLayer.view.rect
	local posY = vr.bottom - tx.bounds.h - CONT_TEXT_PADDING
	tx.position = jd.Vec2(tx.position.x, posY)
	tx.color = jd.Color(60, 255, 100, 200)
	self.level = Level(jd.conf.misc.splashLevel, maplayer.group)
	self.level:start()
	maplayer.view.rect = self.level.world.map.bounds
	self.level.world.winLevel = skipIntro
	self.onKeyPressCon = jd.connect(
		jd.eventDispatcher, 'keyReleased', skipIntro)
end

function C:pause()
	self.level:stop()
	self.level = nil
	self.onKeyPressCon:disconnect()
	self.onKeyPressCon = nil
	self.continueText:release()
	self.continueText = nil
end

return SplashState()
