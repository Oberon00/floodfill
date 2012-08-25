-- data.tileset

local TEXTURE_NAME = "tileset"
local TILESIZE   = jd.Vec2(32, 32)

local M = {}

M.tiles = {
	GROUND_DRY      = 1,
	WATER           = 2,
	FOUNT           = { first = 3, last = 6 },
	WALL            = 9,
	LEVER_OFF       = 58,
	LEVER_ON        = 59,
	LOCK_OPEN       = 60,
	LOCK_CLOSED_H   = 61,
	LOCK_CLOSED_V   = 62,
	PLAYER          = 63,
	GOAL            = 64
}

local tileset = nil

function M.get()
	if not tileset then
		local texture = jd.Image.request(TEXTURE_NAME)
		texture:createTransparentMask(jd.Color(255, 0, 255))
		texture = jd.Texture.keepLoaded(TEXTURE_NAME)
		tileset = jd.Tileset(TILESIZE, texture)
	end
	return tileset
end

return M
