@echo off
REM Complete Publishing Script for ValidateJWT v1.0.0
REM Automates the entire publishing process

echo.
echo ============================================================
echo   ValidateJWT v1.0.0 - Complete Publishing Script
echo ============================================================
echo.

cd /d "%~dp0"

REM Check if git repository
git status >nul 2>&1
if errorlevel 1 (
    echo ERROR: Not a git repository!
    pause
    exit /b 1
)

echo Step 1/7: Building NuGet Package...
echo ============================================================
call BuildNuGetPackage.bat
if errorlevel 1 (
    echo ERROR: Package build failed!
    pause
    exit /b 1
)

echo.
echo Step 2/7: Verifying Package Contents...
echo ============================================================
powershell -ExecutionPolicy Bypass -File VerifyNuGetPackage.ps1
if errorlevel 1 (
    echo ERROR: Package verification failed!
    pause
    exit /b 1
)

echo.
echo Step 3/7: Checking Git Status...
echo ============================================================
git status --short
echo.
set /p COMMIT="Commit changes? (Y/N): "
if /i "%COMMIT%"=="Y" (
    git add .
    git commit -m "Release v1.0.0 - Production Ready"
    git push origin main
    echo Changes committed and pushed!
) else (
    echo Skipping commit...
)

echo.
echo Step 4/7: Creating Git Tag...
echo ============================================================
git tag -l v1.0.0 >nul 2>&1
if not errorlevel 1 (
    echo Tag v1.0.0 already exists!
    set /p RECREATE="Delete and recreate? (Y/N): "
    if /i "%RECREATE%"=="Y" (
        git tag -d v1.0.0
        git push origin :refs/tags/v1.0.0
    )
)

git tag -a v1.0.0 -m "ValidateJWT v1.0.0 - Initial Public Release"
git push origin v1.0.0
echo Tag created and pushed!

echo.
echo Step 5/7: Creating GitHub Release...
echo ============================================================
where gh >nul 2>&1
if errorlevel 1 (
    echo GitHub CLI not found. Manual steps required:
    echo.
    echo 1. Go to: https://github.com/johanhenningsson4-hash/ValidateJWT/releases/new
    echo 2. Select tag: v1.0.0
    echo 3. Title: ValidateJWT v1.0.0 - Initial Public Release
    echo 4. Description: Copy from RELEASE_NOTES_v1.0.0.md
    echo 5. Upload: ValidateJWT-v1.0.0.zip (if available)
    echo 6. Click: Publish release
    echo.
    set /p OPEN="Open GitHub releases page? (Y/N): "
    if /i "%OPEN%"=="Y" (
        start https://github.com/johanhenningsson4-hash/ValidateJWT/releases/new?tag=v1.0.0
    )
) else (
    echo Creating release with GitHub CLI...
    gh release create v1.0.0 --title "ValidateJWT v1.0.0 - Initial Public Release" --notes-file RELEASE_NOTES_v1.0.0.md
    echo GitHub release created!
)

echo.
echo Step 6/7: Publishing to NuGet.org...
echo ============================================================
if defined NUGET_API_KEY (
    echo NUGET_API_KEY found!
    set /p PUBLISH="Publish to NuGet.org? (Y/N): "
    if /i "%PUBLISH%"=="Y" (
        for %%f in (ValidateJWT.*.nupkg) do (
            nuget push %%f -Source https://api.nuget.org/v3/index.json -ApiKey %NUGET_API_KEY%
            echo Package published!
        )
    ) else (
        echo Skipping NuGet publish...
    )
) else (
    echo NUGET_API_KEY not set!
    echo.
    echo To publish manually:
    echo   1. Get API key from https://www.nuget.org/
    echo   2. Run: nuget push ValidateJWT.1.0.0.nupkg -Source https://api.nuget.org/v3/index.json -ApiKey YOUR_KEY
    echo.
    echo Or set environment variable:
    echo   setx NUGET_API_KEY "your-key-here"
    echo.
)

echo.
echo Step 7/7: Summary
echo ============================================================
echo.
echo Release Status:
echo   Package: Built and verified
echo   GitHub: Tag pushed
echo   Release: Created (or manual steps shown)
if defined NUGET_API_KEY (
    echo   NuGet: Published or skipped
) else (
    echo   NuGet: Manual publish required
)
echo.

echo Next Steps:
echo   1. Wait ~15 minutes for NuGet indexing
echo   2. Verify: https://www.nuget.org/packages/ValidateJWT
echo   3. Verify: https://github.com/johanhenningsson4-hash/ValidateJWT/releases
echo   4. Test installation: Install-Package ValidateJWT
echo.

echo ============================================================
echo   Publishing Complete!
echo ============================================================
echo.
pause
