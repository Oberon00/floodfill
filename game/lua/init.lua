-- Create names which every module can assume to be loaded
-- (except configuration.lua)

-- jd.svc.foo() -> jd.foo
local function e(n) jd[n] = jd.svc[n]() end
e 'mainloop'
e 'stateManager'
e 'drawService'
e 'eventDispatcher'
e 'timer'
e 'soundManager'
e = nil

-- make pseudo keywords available
require 'oo' -- lclass
require 'compsys' -- component

--------

local evt = require 'evt'
local pst = require 'persistence'

jd.drawService.backgroundColor =
    jd.conf.misc.backgroundColor or jd.colors.BLACK

evt.connectForever(jd.mainloop, 'quitting', function(exitcode)
    -- avoid warnings
    jd.Image.releaseAll()
    jd.Texture.releaseAll()
    jd.SoundBuffer.releaseAll()
    if exitcode == 0 then -- Do not save configuration in case of errors
        pst.store('userconf', require 'data.userconf')
    end
end)

if jd.DEBUG and jd.kb.isKeyPressed(jd.conf.misc.debugKey) then
    jd.log.i "Debug session..."
    debug.debug()
    jd.log.i "Debug session finished."
end

evt.connectForever(jd.eventDispatcher, 'closed', function()
    jd.mainloop:quit()
end)

evt.connectToKeyPress(jd.kb.F11, function()
    local before = collectgarbage 'count'
    collectgarbage()
    local after = collectgarbage 'count'
    local freed = before - after
    jd.log.d(("GC freed %f kB (%f --> %f)"):format(freed, before, after))
end)

jd.stateManager:push(jd.conf.misc.initialState)
collectgarbage()
-- jd will start the Mainloop automatically
