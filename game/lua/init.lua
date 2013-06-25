-- FloodFill -- Copyright (c) Christian Neumüller 2012--2013
-- This file is subject to the terms of the BSD 2-Clause License.
-- See LICENSE.txt or http://opensource.org/licenses/BSD-2-Clause

-- Create names which every module can assume to be loaded
-- (except configuration.lua)

--setmetatable(_G, {__newindex = function(self, k, v)
--    jd.log.w(debug.traceback(("created global '%s'"):format(k), 2))
--    rawset(self, k, v)
--end})

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

evt.connectToKeyPress(jd.kb.P, function()
    jd.window.mouseCursorVisible = not jd.window.mouseCursorVisible
    jd.window:setMouseCursorVisible(jd.window.mouseCursorVisible)
end)

jd.stateManager:push(jd.conf.misc.initialState)
collectgarbage()
-- jd will start the Mainloop automatically
