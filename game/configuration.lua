-- FloodFill -- Copyright (c) Christian Neumüller 2012--2013
-- This file is subject to the terms of the BSD 2-Clause License.
-- See LICENSE.txt or http://opensource.org/licenses/BSD-2-Clause

return {
    misc = {
        title        = "FloodFill",
        iconFilename = "icon",
        debugKey     = jd.kb.LSHIFT,
        layerCount   = 3, -- background, tilemap, ui
        backgroundColor = jd.Color(255, 0, 255),
        initialState = 'Splash',
        defaultFont  = "Ubuntu-R",
        splashLevel  = "FloodFillFlow",

        keepSplash = true
    }
}
