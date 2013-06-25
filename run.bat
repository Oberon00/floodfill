@echo off
echo jd is starting...
pushd %~dp0\game
%JD_ROOT%\bin\jd.exe || goto :err

goto :EOF

:err
echo Exitcode: %ERRORLEVEL%

popd
