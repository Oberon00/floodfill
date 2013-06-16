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
