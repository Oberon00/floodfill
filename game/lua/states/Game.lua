local compsys = require 'compsys'
require 'comp.InputMoved'
require 'comp.Graphic'
local oo = require 'oo'
local loadMap = (require 'maploader').loadMap

oo.cppclass('Game', jd.State)

local Player = compsys.entity {
	jd.PositionComponent,
	InputMovedComponent,
	GraphicComponent
}

function Game:prepare()
	local maplayer = jd.drawService:layer(2)
	self.tilemap = jd.Tilemap(maplayer.group)
	self.world = loadMap(self.tilemap, "level1")
	maplayer.view.rect = self.tilemap.bounds
end

function Game:stop()

end

_G.states = _G.states or { }
_G.states.game = Game()

return states.game
