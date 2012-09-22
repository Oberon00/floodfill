@echo off
echo jd is starting...
cd %~dp0
..\build11\src\Debug\jd.exe || goto :err

goto :EOF

:err
echo Exitcode: %ERRORLEVEL%