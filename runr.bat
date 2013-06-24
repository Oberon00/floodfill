@echo off
echo jd is starting...
cd %~dp0\game
..\..\build11\src\RelWithDebInfo\jd.exe || goto :err

goto :EOF

:err
echo Exitcode: %ERRORLEVEL%
