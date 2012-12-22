return {

    video = {
        mode       = jd.VideoMode(800, 600),
        vsync      = false,
        fullscreen = false,
        framelimit = 240
    },
    
    misc = {
        title        = "FloodFill",
        iconFilename = "icon",
        debugKey     = jd.kb.LSHIFT,
		layerCount   = 3, -- background, tilemap, ui
		backgroundColor = jd.Color(255, 0, 255),
		initialState = 'Splash',
		defaultFont  = "Ubuntu-R",
		splashLevel  = "FloodFillFlow"
    }
}
