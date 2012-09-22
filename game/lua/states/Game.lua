local oo = require 'oo'
local loadMap = (require 'maploader').loadMap

oo.cppclass('Game', jd.State)

function Game:prepare()
	local maplayer = jd.drawService:layer(2)
	self.tilemap = jd.Tilemap(maplayer.group)
	self.world = loadMap(self.tilemap, "level1")
	maplayer.view.rect = self.tilemap.bounds
end

function Game:stop()
	self.tilemap = nil
	self.world = nil
end

_G.states = _G.states or { }
_G.states.game = Game()

return states.game
