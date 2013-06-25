-- FloodFill -- Copyright (c) Christian Neumüller 2012--2013
-- This file is subject to the terms of the BSD 2-Clause License.
-- See LICENSE.txt or http://opensource.org/licenses/BSD-2-Clause

local C = lclass 'Level'

local maploader = require 'maploader'
local evt = require 'evt'
local tabutil = require 'tabutil'

function C:__init(name, drawgroup)
    self.onStart = evt.Signal()
    self.onStop  = evt.Signal()

    local map = jd.Tilemap()
    self.drawgroup = drawgroup
    self._levelData = {
        name = name,
        map = map,
        props = map:loadFromFile(maploader.mapFile(name)),
        onStart = self.onStart,
        onStop = self.onStop,
    }
end

function C:start()
    local world = tabutil.copy(self._levelData)

    -- add self reference here and not in ctor, to speed up the GC
    world.level = self

    local map = jd.Tilemap(world.map)
    map.group = self.drawgroup

    world._animationCon = jd.connect(jd.mainloop, 'update', function()
        map:animate(jd.timer.frameDuration)
    end)

    world.map = map
    world.procs = { }

    self.world = maploader.initializeMap(world)

    self.onStart()
end

function C:stop()
    if not self.world then
        return false
    end

    self.onStop()
    for _, entity in pairs(self.world.tileProxies) do
        entity:kill()
    end
    for _, entity in ipairs(self.world.substituteObjects) do
        entity:kill()
    end
    for _, group in pairs(self.world.mapObjects) do
        for _, entity in ipairs(group) do
            entity:kill()
        end
    end
    self.world.map:release()
    self.world._animationCon:disconnect()
    tabutil.clear(self.world)
    self.world = nil
    return true
end

function C:restart()
    self:stop()
    self:start()
end

return C
