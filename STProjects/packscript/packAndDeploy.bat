REM @ECHO off
SETLOCAL
cd %~dp0
SET StartDir=%~dp0..

call :RUNCOPY AIHelperD.dll

nuget pack package\SprutTechnology.AIHelperD.nuspec

SET source=https://nexus.office.sprut.ru/repository/dev-feed/index.json
SET api=<enter api key here>
REM nuget push SprutTechnology.AIHelperD.1.0.0.nupkg -Source %source% -apiKey %api%

pause

EXIT /B 

:RUNCOPY
    xcopy /Y "%StartDir%\Win64\%~1" "%StartDir%\packscript\package\build\bin\%~1"*
EXIT /B
