-- Create/require names which every module can assume to be loaded
-- (except configuration.lua)

local function e(n) jd[n] = jd.svc[n]() end
e 'mainloop'
e 'stateManager'
e 'drawService'
e 'eventDispatcher'
e 'entityRoot'
e 'collisionManager'
e 'timer'
e = nil

-- make pseudo keywords available
require 'oo' -- lclass
require 'compsys' -- component

local evt = require 'evt'

jd.drawService.backgroundColor =
	jd.conf.misc.backgroundColor or jd.colors.BLACK

evt.connectForever(jd.mainloop, 'quitting', function()
	jd.log.i "Quitting."
	jd.entityRoot:tidy()
	jd.Image.releaseAll()
	jd.Texture.releaseAll()
end)

if jd.DEBUG and jd.kb.isKeyPressed(jd.conf.misc.debugKey) then
    jd.log.i "Debug session..."
    debug.debug()
    jd.log.i "Debug session finished."
end

evt.connectForever(jd.eventDispatcher, 'closed', function()
	jd.mainloop:quit()
end)

jd.stateManager:push(jd.conf.misc.initialState)

collectgarbage()
