-- FloodFill -- Copyright (c) Christian Neumüller 2012--2013
-- This file is subject to the terms of the BSD 2-Clause License.
-- See LICENSE.txt or http://opensource.org/licenses/BSD-2-Clause

local oo = require 'oo'
local strings = require 'data.strings'
local ContinueScreen = require 'ContinueScreen'

local C = oo.cppclass('CreditsState', jd.State)

function C:prepare()
    self.screen = ContinueScreen()
    self.screen:show(
        function()
            jd.stateManager:pop()
        end,
        jd.Texture.request "credits")
end

function C:pause()
    self.screen:reset()
    self.screen = nil
end

return CreditsState()
