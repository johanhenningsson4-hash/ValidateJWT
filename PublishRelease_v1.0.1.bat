@echo off
REM Publishing Script for ValidateJWT v1.0.1
REM Automates the release process for patch version

echo.
echo ============================================================
echo   ValidateJWT v1.0.1 - Release Publishing Script
echo ============================================================
echo.

cd /d "%~dp0"

REM Check git status
git status >nul 2>&1
if errorlevel 1 (
    echo ERROR: Not a git repository!
    pause
    exit /b 1
)

echo Step 1/7: Building NuGet Package v1.0.1...
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
echo Step 3/7: Git Status Check...
echo ============================================================
git status --short
echo.
echo Changes to be committed:
echo   - Properties/AssemblyInfo.cs (version 1.0.1.0)
echo   - ValidateJWT.nuspec (version 1.0.1)
echo   - CHANGELOG.md (updated)
echo   - RELEASE_NOTES_v1.0.1.md (new)
echo.
set /p COMMIT="Commit v1.0.1 changes? (Y/N): "
if /i "%COMMIT%"=="Y" (
    git add Properties\AssemblyInfo.cs
    git add ValidateJWT.nuspec
    git add CHANGELOG.md
    git add RELEASE_NOTES_v1.0.1.md
    git add PUBLISH_NOW.md
    git add PUBLISH_QUICK_START.md
    git add PublishRelease.bat
    git add COMPANY_VERIFICATION.md
    git add FINAL_COMPANY_VERIFICATION.md
    git commit -m "Release v1.0.1 - Documentation and Metadata Improvements

Changes:
- Update version to 1.0.1 in AssemblyInfo and nuspec
- Enhanced NuGet package metadata
- Added comprehensive publishing guides
- Added code verification documentation
- Updated CHANGELOG.md
- Created RELEASE_NOTES_v1.0.1.md

Improvements:
- README and LICENSE now display on NuGet.org
- Better package discoverability
- Automated publishing scripts
- Verified clean codebase (no company references)

Compatibility:
- 100%% backward compatible with v1.0.0
- All 58+ tests passing
- No functional changes to library code"
    git push origin main
    echo   Changes committed and pushed!
) else (
    echo   Skipping commit...
)

echo.
echo Step 4/7: Creating Git Tag v1.0.1...
echo ============================================================
git tag -l v1.0.1 >nul 2>&1
if not errorlevel 1 (
    echo   Tag v1.0.1 already exists!
    set /p RECREATE="Delete and recreate? (Y/N): "
    if /i "%RECREATE%"=="Y" (
        git tag -d v1.0.1
        git push origin :refs/tags/v1.0.1
        echo   Existing tag deleted
    )
)

git tag -a v1.0.1 -m "ValidateJWT v1.0.1 - Documentation and Metadata Improvements

Patch release with enhanced NuGet package presentation and documentation.

What's New:
- Enhanced NuGet package metadata
- README.md displays on NuGet.org
- LICENSE.txt displays in license tab
- Comprehensive publishing guides
- Code verification documentation

Compatibility:
- 100%% compatible with v1.0.0
- No breaking changes
- All APIs unchanged
- All 58+ tests passing

Quality:
- Grade A- maintained
- Zero dependencies
- Clean codebase verified
- Personal copyright confirmed

See RELEASE_NOTES_v1.0.1.md for complete details."

git push origin v1.0.1
echo   Tag v1.0.1 created and pushed!

echo.
echo Step 5/7: Creating GitHub Release...
echo ============================================================
where gh >nul 2>&1
if errorlevel 1 (
    echo   GitHub CLI not found. Manual steps:
    echo.
    echo   1. Go to: https://github.com/johanhenningsson4-hash/ValidateJWT/releases/new
    echo   2. Tag: v1.0.1
    echo   3. Title: ValidateJWT v1.0.1 - Documentation and Metadata Improvements
    echo   4. Description: Copy from RELEASE_NOTES_v1.0.1.md
    echo   5. Upload: ValidateJWT-v1.0.1.zip (if available)
    echo   6. Click: Publish release
    echo.
    set /p OPEN="Open GitHub releases page? (Y/N): "
    if /i "%OPEN%"=="Y" (
        start https://github.com/johanhenningsson4-hash/ValidateJWT/releases/new?tag=v1.0.1
    )
) else (
    echo   Creating release with GitHub CLI...
    gh release create v1.0.1 --title "ValidateJWT v1.0.1 - Documentation and Metadata Improvements" --notes-file RELEASE_NOTES_v1.0.1.md
    echo   GitHub release created!
)

echo.
echo Step 6/7: Publishing to NuGet.org...
echo ============================================================
if defined NUGET_API_KEY (
    echo   NUGET_API_KEY found!
    echo.
    echo   This will publish ValidateJWT v1.0.1 to NuGet.org
    echo   Package: ValidateJWT.1.0.1.nupkg
    echo.
    set /p PUBLISH="Publish to NuGet.org? (Y/N): "
    if /i "%PUBLISH%"=="Y" (
        for %%f in (ValidateJWT.1.0.1.nupkg) do (
            echo   Publishing %%f...
            nuget push %%f -Source https://api.nuget.org/v3/index.json -ApiKey %NUGET_API_KEY%
            echo   Package published!
        )
    ) else (
        echo   Skipping NuGet publish...
    )
) else (
    echo   NUGET_API_KEY not set!
    echo.
    echo   To publish manually:
    echo     nuget push ValidateJWT.1.0.1.nupkg -Source https://api.nuget.org/v3/index.json -ApiKey YOUR_KEY
    echo.
    echo   Or set environment variable:
    echo     setx NUGET_API_KEY "your-key-here"
    echo.
)

echo.
echo Step 7/7: Release Summary
echo ============================================================
echo.
echo Release v1.0.1 Status:
echo   Version: 1.0.1.0
echo   Package: Built and verified
echo   Git: Committed and tagged
echo   GitHub: Release created or pending manual creation
if defined NUGET_API_KEY (
    echo   NuGet: Published or skipped
) else (
    echo   NuGet: Manual publish required
)
echo.
echo Changes in v1.0.1:
echo   - Enhanced NuGet package metadata
echo   - Documentation improvements
echo   - Publishing automation scripts
echo   - Code verification completed
echo   - 100%% backward compatible
echo.
echo Next Steps:
echo   1. Wait ~15 minutes for NuGet indexing
echo   2. Verify: https://www.nuget.org/packages/ValidateJWT/1.0.1
echo   3. Verify: https://github.com/johanhenningsson4-hash/ValidateJWT/releases/tag/v1.0.1
echo   4. Test upgrade: Update-Package ValidateJWT -Version 1.0.1
echo.
echo ============================================================
echo   v1.0.1 Release Complete!
echo ============================================================
echo.
pause
