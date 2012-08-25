@echo off
echo Start.
..\build\src\Debug\jd.exe || goto :err

goto :EOF

:err
echo Exitcode: %ERRORLEVEL% && pause