local M = { }

local defFont = jd.Font.request(jd.conf.misc.defaultFont)
local defLayer = jd.drawService:layer(3)

function M.create(s, p, layer, font)
	if type(font) == 'string' then
		font = jd.Font.request(font)
	else
		font = font or defFont
	end
	layer = layer or defLayer.group
	p = p or jd.Vec2()
	local text = jd.Text(layer)
	text.font = font
	text.string = s
	text.position = p
	return text
end

function M.center(t, layer)
	layer = layer or defLayer
	local r = t.bounds
	local d = r.position - t.position
	r.center = layer.view.center
	t.position = r.position - d
end

return M
