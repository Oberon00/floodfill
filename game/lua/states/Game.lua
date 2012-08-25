local compsys = require 'compsys'
require 'comp.InputMoved'
require 'comp.Graphic'
local oo = require 'oo'

oo.cppclass('Game', jd.State)

local Player = compsys.entity {
	jd.PositionComponent,
	InputMovedComponent,
	GraphicComponent
}

function Game:__init()
	jd.State.__init(self)
end


function Game:prepare()
	local maplayer = jd.drawService:layer(2)
	self.tilemap = jd.Tilemap(maplayer.group)
	self.tilemap:loadFromFile "maps/level1.tmx"
	maplayer.view.rect = self.tilemap.bounds
	-- local tprops = transformSpriteProps(props.tileProperties)
	-- jd.drawService:layer(2).view.rect = self.tilemap.bounds;
	
	-- local plSprite = jd.Sprite(jd.drawService:layer(2).group)
	-- local tileset = self.tilemap.tileset
	-- plSprite.texture = tileset.texture
	-- plSprite.textureRect = jd.Rect(
		-- tileset:texturePosition(tonumber(tprops.player:get 'id')),
		-- tileset.size)
	-- local pl = Player(jd.entityRoot, {[GraphicComponent] = plSprite})
end

function Game:stop()

end

states = states or { }
states.game = Game()

return states.game
