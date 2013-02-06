local videoconf = (require 'data.userconf').video
local miscconf = jd.conf.misc

local function reinitialize(window)
    window:create(
        videoconf.mode or jd.VideoMode(800, 600),
        miscconf.title or "Jade Engine",
        videoconf.fullscreen and
            bit32.bor(jd.Window.STYLE_DEFAULT, jd.Window.STYLE_FULLSCREEN) or
            jd.Window.STYLE_DEFAULT)
    window:setVSyncEnabled(videoconf.vsync)
    window:setFramerateLimit(videoconf.framelimit or 0)
    if miscconf.iconFilename then
        window:setIcon(jd.Image.request(miscconf.iconFilename))
    end
    window:setKeyRepeatEnabled(false)
    if jd.drawService then
        jd.drawService:resetLayerViews()
    end
end


local window = jd.RenderWindow()
reinitialize(window)

window.reinitialize = reinitialize
jd.window = window

return window
