local oo = require 'oo'
local Level = require 'Level'
local ContinueScreen = require 'ContinueScreen'
local text = require 'text'

local C = oo.cppclass('SplashState', jd.State)


local maplayer = jd.drawService:layer(2)

local function skipIntro()
    -- Switch state in next frame, otherwise, if this is called from
    -- proc.Flood.onFlow, it disconnects while calling the signal, which leads
    -- to a crash.
    local con
    con = jd.connect(jd.mainloop, 'preFrame', function()
        jd.stateManager:switchTo('Menu')
        con:disconnect()
    end)
end

function C:prepare()
    self.screen = ContinueScreen()
    self.screen:show(skipIntro)
    self.screen.continueText.color = jd.Color(60, 255, 100, 200)
    self.level = Level(jd.conf.misc.splashLevel, maplayer.group)
    self.level:start()
    maplayer.view.rect = self.level.world.map.bounds
    if not jd.conf.misc.keepSplash then
        self.level.world.winLevel = skipIntro
    else
        self.level.world.winLevel = function() end -- do nothing
    end
end

function C:pause()
    self.level:stop()
    self.level = nil
    self.screen:reset()
    self.screen = nil

end

return SplashState()
