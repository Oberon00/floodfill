#!/usr/bin/env python
# -*- coding: utf-8 -*-

# FloodFill -- Copyright (c) Christian Neumüller 2012--2013
# This file is subject to the terms of the BSD 2-Clause License.
# See LICENSE.txt or http://opensource.org/licenses/BSD-2-Clause

import array
import xml.etree.ElementTree as etree
import sys
import base64
import zlib
import array


def dictfromtset(setroot):
    result = {}
    for tile in setroot.findall("tile"):
        tid = int(tile.get('id'))
        tname = tile.find("./properties/property[@name='name']").get('value')
        result[tname] = tid
    return result


def arrayfromlayer(layer):
    return array.array('I', zlib.decompress(base64.b64decode(layer)))


def arraytolayer(layerarray):
    return base64.b64encode(zlib.compress(layerarray.tostring()))


def update_map(mapfilename, originalsetfilename):
    originalset = dictfromtset(etree.parse(originalsetfilename).getroot())
    maptree = etree.parse(mapfilename)
    maproot = maptree.getroot()
    newsetfilename = maproot.find('tileset').get('source')
    newset = dictfromtset(etree.parse(newsetfilename).getroot())
    translation = dict(
        (v, newset.get(k, newset.get(k + "#1"))) for
            k, v in originalset.iteritems())
    def translate(id):
        return 0 if id == 0 else translation[id - 1] + 1
    for layer in maproot.findall('layer/data'):
        a = arrayfromlayer(layer.text)
        a = array.array('I', map(translate , a))
        layer.text = arraytolayer(a)
    for group in maproot.findall('objectgroup'):
        for obj in group.findall('object'):
            gid = obj.get('gid')
            if gid is not None:
                obj.set('gid', str(translate(int(gid))))
    maptree.write(mapfilename, "utf-8", xml_declaration=True)

if __name__ == '__main__':
    update_map(sys.argv[1], sys.argv[2])
