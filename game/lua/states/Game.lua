-- FloodFill -- Copyright (c) Christian Neumüller 2012--2013
-- This file is subject to the terms of the BSD 2-Clause License.
-- See LICENSE.txt or http://opensource.org/licenses/BSD-2-Clause

local oo = require 'oo'
local evt = require 'evt'
local levelnamelist = require 'data.levels'
local LevelList = require 'LevelList'
local Level = require 'Level'
local text = require 'text'
local strings = require 'data.strings'
local ContinueScreen = require 'ContinueScreen'
local pst = require 'persistence'

local C = oo.cppclass('GameState', jd.State)

local maplayer = jd.drawService:layer(2)

local nextLevel

local function clearMessage(self)
    if self.message then
        self.message:release()
        self.message = nil
    end
    if self.msgcon then
        self.msgcon:disconnect()
        self.msgcon = nil
    end
end

local function showMessage(self, msg, color, size, fadeoutDelay)
    clearMessage(self)

    -- Show "Level %i" message and fade out
    local tx = text.create(msg)
    self.message = tx
    tx.color = color or tx.color
    tx.characterSize = size or tx.characterSize
    tx.bold = true
    text.center(tx)

    local function fadeOut()
        local tm = jd.Clock()
        self.msgcon = jd.connect(jd.mainloop, 'update', function()
            local a = 255 - tm.elapsedTime:asSeconds() * (255 / 2)
            if a < 0 or not self.message then
                clearMessage(self)
            end
            local cl = tx.color
            cl.a = a
            tx.color = cl
        end)
    end

    if fadeoutDelay then
        self.msgcon = jd.timer:callAfter(fadeoutDelay, fadeOut)
    else
        fadeOut()
    end
end


local function startLoadedLevel(self)
    self.level:start()
    function self.level.world.winLevel()
        nextLevel(self)
    end
    function self.level.world.loseLevel()
        jd.soundManager:playSound "splash"
        self.level:stop()
        startLoadedLevel(self)
        showMessage(self, strings.lose_level, jd.Color.RED, 170, jd.seconds(1))
    end
end

local function startLevel(self)
    local levelEntry = self.levels:currentLevel()
    levelEntry.unlocked = true
    self.level = Level(levelEntry.name, maplayer.group)
    evt.connectToKeyPress(jd.kb.F5, function(event)
        self.level:stop()
        if event.shift then
            startLevel(self)
        else
            startLoadedLevel(self)
        end
    end)
    startLoadedLevel(self)
    maplayer.view.rect = self.level.world.map.bounds

    -- Show "Level %i" message and fade out
    showMessage(
        self, strings.level_i:format(self.levels.currentIndex),
        jd.Color.GREEN, 200, jd.seconds(2))
end

--[[local]] function nextLevel(self)
    clearMessage(self)
    evt.connectToKeyPress(jd.kb.F5, nil)
    self.level:stop()
    if not self.levels:advance() then
        jd.soundManager:playSound "game_complete"
        self.winningScreen = ContinueScreen()
        evt.connectToKeyPress(jd.kb.ESCAPE, nil)
        self.winningScreen:show(
            function()
                jd.stateManager:pop() -- pop game
                jd.stateManager:switchTo('Splash') -- replace menu with splash
                jd.stateManager:push('Credits')
            end,
            jd.Texture.request "win")
    else
        jd.soundManager:playSound "level_complete"
        startLevel(self)
    end
end

function C:__init()
    jd.State.__init(self)
    self.levels = LevelList.default
    jd.Image.keepLoaded "tileset.png"
    jd.Texture.keepLoaded "tileset.png"
end

function C:prepare()
    evt.connectToKeyPress(jd.kb.ESCAPE, function() jd.stateManager:pop() end)
    startLevel(self)
end

function C:pause()
    if self.winningScreen then
        self.winningScreen:reset()
        self.winningScreen = nil
    end

    evt.connectToKeyPress(jd.kb.F5, nil)
    evt.connectToKeyPress(jd.kb.ESCAPE, nil)
    clearMessage(self)
    pst.zstore(
        "unlocked",
        math.max(pst.zload("unlocked"), self.levels.currentIndex))
end

function C:stop()
    self.levels.currentIndex = 1
    self.level:stop()
    self.level = nil
end

return GameState()
