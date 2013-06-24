setlocal
set out=..\dbg\res\img\tileset.png
dir /B  /TC /OD *.png >~listing.txt
set postfix=%DATE%-%RANDOM%
copy %out% tileset%postfix%.png.bak || (pause & goto :EOF)
copy ..\dbg\maps\set.tsx set%postfix%.tsx.bak || (pause & goto :EOF)
.\sspack /image:%out% /il:~listing.txt /map:map.txt /pad:0 /mw:256 /pow2 || (pause & goto :EOF)
.\makeTsx.py || pause