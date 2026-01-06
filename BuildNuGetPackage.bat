@echo off
REM NuGet Package Builder - Launches Developer Command Prompt
REM This batch file will open Developer Command Prompt and build the package

echo ============================================================
echo   ValidateJWT - NuGet Package Builder
echo ============================================================
echo.

REM Try to find VS 2022 Developer Command Prompt
set "VSCMD_2022=C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat"
if exist "%VSCMD_2022%" (
    echo Found Visual Studio 2022 Developer Command Prompt
    call "%VSCMD_2022%"
    goto :build
)

REM Try VS 2022 Professional
set "VSCMD_2022_PRO=C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\VsDevCmd.bat"
if exist "%VSCMD_2022_PRO%" (
    echo Found Visual Studio 2022 Professional Developer Command Prompt
    call "%VSCMD_2022_PRO%"
    goto :build
)

REM Try VS 2019
set "VSCMD_2019=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\VsDevCmd.bat"
if exist "%VSCMD_2019%" (
    echo Found Visual Studio 2019 Developer Command Prompt
    call "%VSCMD_2019%"
    goto :build
)

REM If not found, show instructions
echo.
echo Visual Studio Developer Command Prompt not found!
echo.
echo Please install Visual Studio or use one of these methods:
echo.
echo 1. Open "Developer Command Prompt for VS" from Start Menu
echo 2. Navigate to: cd C:\Jobb\ValidateJWT
echo 3. Run: BuildNuGetPackage.bat
echo.
echo Or build manually in Visual Studio:
echo    - Open ValidateJWT.sln
echo    - Configuration ^> Release
echo    - Build ^> Build Solution
echo    - Run: nuget pack ValidateJWT.nuspec
echo.
pause
exit /b 1

:build
echo.
echo ============================================================
echo   Building ValidateJWT in Release mode...
echo ============================================================
echo.

cd /d "%~dp0"

REM Clean previous builds
if exist "bin\Release\" rmdir /s /q "bin\Release"
if exist "obj\" rmdir /s /q "obj"
if exist "*.nupkg" del /q "*.nupkg"

REM Build the project
msbuild ValidateJWT.csproj /p:Configuration=Release /p:DocumentationFile=bin\Release\ValidateJWT.xml /v:minimal /nologo

if errorlevel 1 (
    echo.
    echo ============================================================
    echo   Build FAILED!
    echo ============================================================
    echo.
    pause
    exit /b 1
)

echo.
echo Build successful!
echo.

REM Check if output files exist
if not exist "bin\Release\ValidateJWT.dll" (
    echo ERROR: ValidateJWT.dll not found!
    pause
    exit /b 1
)

if not exist "bin\Release\ValidateJWT.xml" (
    echo ERROR: ValidateJWT.xml not found!
    pause
    exit /b 1
)

echo ============================================================
echo   Creating NuGet Package...
echo ============================================================
echo.

REM Check for nuget
where nuget >nul 2>&1
if errorlevel 1 (
    if not exist "nuget.exe" (
        echo Downloading nuget.exe...
        powershell -Command "Invoke-WebRequest -Uri 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe' -OutFile 'nuget.exe'"
    )
    set NUGET_CMD=nuget.exe
) else (
    set NUGET_CMD=nuget
)

REM Create the package
%NUGET_CMD% pack ValidateJWT.nuspec -OutputDirectory .

if errorlevel 1 (
    echo.
    echo ============================================================
    echo   NuGet Pack FAILED!
    echo ============================================================
    echo.
    pause
    exit /b 1
)

echo.
echo ============================================================
echo   SUCCESS! NuGet Package Created
echo ============================================================
echo.

REM Find and display the package
for %%f in (ValidateJWT.*.nupkg) do (
    echo Package: %%f
    echo Size: %%~zf bytes
    echo.
)

echo Next Steps:
echo.
echo Test locally:
echo   nuget add ValidateJWT.1.0.0.nupkg -source C:\LocalNuGetFeed
echo.
echo Publish to NuGet.org:
echo   nuget push ValidateJWT.1.0.0.nupkg -Source https://api.nuget.org/v3/index.json -ApiKey YOUR_KEY
echo.
echo Get API Key: https://www.nuget.org/ ^> Account Settings ^> API Keys
echo.

pause
