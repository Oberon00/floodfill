return {

    video = {
        mode       = jd.VideoMode(800, 600),
        vsync      = false,
        fullscreen = false,
        framelimit = 240
    },
    
    misc = {
        title        = "Jade",
        debugKey     = jd.kb.LSHIFT,
		layerCount   = 2, -- background, tilemap
		backgroundColor = jd.Color(255, 0, 255),
		initialState = 'Game'
    }
}
