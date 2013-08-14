# FloodFill -- Copyright (c) Christian Neumüller 2012--2013
# This file is subject to the terms of the BSD 2-Clause License.
# See LICENSE.txt or http://opensource.org/licenses/BSD-2-Clause

import re
import os.path

MAP_NAME, MAP_X, MAP_Y, MAP_W, MAP_H = range(5)
TSX_HEAD = \
'''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE tileset SYSTEM "http://mapeditor.org/dtd/1.0/map.dtd">
<tileset name="{name}" tilewidth="{tw}" tileheight="{th}">
 <image source="{imgn}"/>"
'''
TSX_END = "</tileset>"
TSX_TILE = ''' <tile id="{tid}">
  <properties>
   <property name="name" value="{tname}"/> {tanim}
  </properties>
 </tile>
'''

TSX_TILE_ANIMATION = '''
   <property name="animationLength" value="{alen}"/>
   <property name="animationSpeed"  value="{aspeed}"/>'''

def import_map(mfn):
    exp = re.compile("^([A-Za-z_][A-Za-z_0-9]*) = (\d+) (\d+) (\d+) (\d+)$")
    tiles = []
    with open(mfn) as f:
        for line in f:
            tiles.append(exp.match(line).group(1, 2, 3, 4, 5))
            t = tiles[-1]
            tiles[-1] = (t[0],
                         int(t[1]), int(t[2]),
                         int(t[3]), int(t[4]))
    return tiles

def import_animations(afn):
    animations = {}
    with open(afn) as f:
        for line in f:
            tokens = line.split()
            assert len(tokens) == 3
            animations[tokens[0]] = map(int, tokens[1:])
    return animations

def map_to_tsx(tmap, anims, tw, th, imgn, tilesPerRow, ofn):
    def doformattile(tid, tname):
        if tname in anims:
            tanim = TSX_TILE_ANIMATION.format(
                alen=anims[tname][0], aspeed=anims[tname][1])
        else:
            tanim = ""
        return TSX_TILE.format(tid=tid, tname=tname, tanim=tanim)

    def formattile(tile):
        tname, x, y, w, h = tile
        if h != th:
            raise RuntimeError("tile '" + tname + "' of invalid height")
        assert(w % tw == 0)
        colspan = w / tw
        assert(colspan >= 1)
        tid = x / tw + y / th * tilesPerRow
        if colspan > 1:
            return "".join((doformattile(tid + i, "{}#{}".format(tname, i + 1))
                    for i in xrange(colspan)))
        return doformattile(tid, tname)

    name = os.path.splitext(os.path.basename(ofn))[0]

    with open(ofn, "w") as f:
        f.write(TSX_HEAD.format(name=name, tw=tw, th=th, imgn=imgn))
        f.writelines((formattile(tile) for tile in tmap))
        f.write(TSX_END)



if __name__ == "__main__":
    map_to_tsx(
        import_map("map.txt"),
        import_animations("animations.txt"),
        32, 32,
        "../res/img/tileset.png",        # Relative to output-file
        8,                               # Tiles per row: please adjust
        "../dbg/maps/set.tsx")
