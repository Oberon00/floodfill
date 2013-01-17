local window = jd.RenderWindow(
    jd.conf.video.mode or jd.VideoMode(800, 600),
    jd.conf.misc.title or "Jade Engine",
    jd.conf.video.fullscreen and
        bit32.bor(jd.Window.STYLE_DEFAULT, jd.Window.STYLE_FULLSCREEN) or
        jd.Window.STYLE_DEFAULT)
window:setVSyncEnabled(jd.conf.video.vsync)
if jd.conf.misc.iconFilename then
    window:setIcon(jd.Image.request(jd.conf.misc.iconFilename))
end
window:setFramerateLimit(jd.conf.video.framelimit or 0)

jd.window = window

return window
