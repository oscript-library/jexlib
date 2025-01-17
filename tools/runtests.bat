@ECHO OFF

echo %~dp0
@chcp 65001

FOR /f "usebackq tokens=*" %%a in ("%~dp0openssh\.env") DO (
  FOR /F "tokens=1,2 delims==" %%b IN ("%%a") DO (
    set "%%b=%%c"
  )
)

IF NOT EXIST "%~dp0nuget.exe" (
  @"C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe" curl -o "%~dp0nuget.exe" https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
)
@%~dp0nuget.exe restore %~dp0../src
@%~dp0nuget.exe install NUnit.ConsoleRunner -Version 3.6.1 -OutputDirectory %~dp0../test
@dotnet tool install --global dotnet-coverage
@dotnet restore %~dp0../src
@dotnet build %~dp0../src --configuration Debug
@mkdir "%~dp0../test"
@dotnet-coverage collect -o %~dp0../test/coverage.xml -f xml "%~dp0../test/NUnit.ConsoleRunner.3.6.1/tools/nunit3-console.exe %~dp0../src/NUnitTests/bin/Debug/net452/NUnitTests.dll --result=%~dp0../test/nunit-result.xml"
@rd /S /Q "%~dp0../test/NUnit.ConsoleRunner.3.6.1"
@exit /b %ERRORLEVEL%