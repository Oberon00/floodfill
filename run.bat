@echo off
REM FloodFill -- Copyright (c) Christian Neumüller 2012--2013
REM This file is subject to the terms of the BSD 2-Clause License.
REM See LICENSE.txt or http://opensource.org/licenses/BSD-2-Clause

echo jd is starting...
pushd %~dp0\game
%JD_ROOT%\bin\jd.exe || goto :err

goto :EOF

:err
echo Exitcode: %ERRORLEVEL%

popd
