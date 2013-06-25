@echo off
REM FloodFill -- Copyright (c) Christian Neumüller 2012--2013
REM This file is subject to the terms of the BSD 2-Clause License.
REM See LICENSE.txt or http://opensource.org/licenses/BSD-2-Clause

REM Requires InnoSetup 5 and 7-Zip installed in standard locations,
REM MikTeX in PATH and Visual Studio 11 installed.
REM JD_ROOT must be set to jd's install root (where the share and bin
REM directories are located).
REM SFML_ROOT must be set to SFML 2's install root (where the include, bin, ...
REM directories are located).
setlocal
set ffdata=%TMP%\floodfill.jd
set basedata=%JD_ROOT%\share\base.jd
set zipdist=%cd%\FloodFill.zip
set setupdir=%cd%
cd %~dp0

if not defined ProgramFiles(x86) set ProgramFiles(x86)=%ProgramFiles%
set PATH=%ProgramFiles(x86)%\Inno Setup 5\;%ProgramFiles%\7-Zip\;%PATH%

echo Creating Installer...
pushd ..\doc || goto :E
texify --pdf -b -q --engine=xetex usermanual.tex || goto :E
popd

if exist "%ffdata%" del "%ffdata%" || goto :E
7z a -tzip "%ffdata%" ..\game\* -x@..\.gitignore -x!.git\ -x!.gitignore -x!*.bat || goto :E

ISCC /q installer.iss /o%setupdir% /fFloodFill_Setup || goto :E
echo Done.

echo Creating ZIP...
set zipsrc=%TMP%\FloodFill
if exist "%zipsrc%" rmdir /Q /S "%zipsrc%" || goto :E
mkdir %TMP%\FloodFill || goto :E
copy /b %JD_ROOT%\bin\jd.exe+%ffdata% "%zipsrc%\FloodFill.exe" || goto :E
copy /Y %basedata% "%zipsrc%" || goto :E
copy /Y %SFML_ROOT%\bin\openal32.dll "%zipsrc%" || goto :E
copy /Y %SFML_ROOT%\bin\libsndfile-1.dll "%zipsrc%" || goto :E
xcopy /Y "%VS110COMNTOOLS%\..\..\VC\redist\x86\Microsoft.VC110.CRT\msvc*.dll" "%zipsrc%" || goto :E
copy /Y ..\doc\usermanual.pdf "%zipsrc%" || goto :E
copy /Y FloodFill.ico "%zipsrc%" || goto :E
copy /Y zipdesktop.ini "%zipsrc%\desktop.ini" || goto :E
xcopy /Y ..\licenses\* "%zipsrc%\lincenses\"
copy /Y License.rtf "%zipsrc%"
attrib "%zipsrc%\desktop.ini" +S +H -I
attrib "%zipsrc%" +R -I

if exist "%zipdist%" del "%zipdist%" || goto :E
7z a -tzip "%zipdist%" "%zipsrc%" || goto :E
echo Done.

goto :eof

:E
    echo An error occured. Code: %ERRORLEVEL%
    pause
goto :eof
