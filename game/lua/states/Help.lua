local oo = require 'oo'
local ContinueScreen = require 'ContinueScreen'
local text = require 'text'

local C = oo.cppclass('HelpState', jd.State)

local HELP_TEXT = (require 'data.strings').help_text
local PADDING = 50

local function proceed()
    local con
    con = jd.connect(jd.mainloop, 'preFrame', function()
        con:disconnect()
        jd.stateManager:pop()
    end)
end

function C:prepare()
    self.screen = ContinueScreen()
    self.screen:show(proceed, jd.Texture.request "menubg")
    self.screen.background.color = jd.Color(127, 127, 127)

    self.help = text.create(HELP_TEXT)
    self.help.characterSize = 23
    self.help:breakLines(text.defaultLayer.view.rect.right - PADDING)
    text.center(self.help)
end

function C:pause()
    self.help:release()
    self.help = nil
    self.screen:reset()
    self.screen = nil
end

return HelpState()
