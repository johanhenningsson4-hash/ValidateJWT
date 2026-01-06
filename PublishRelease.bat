@echo off
REM Complete Release Script for ValidateJWT v1.1.0
REM Major Feature Release: JWT Signature Verification

echo.
echo ============================================================
echo   ValidateJWT v1.1.0 - New Feature Release
echo   JWT Signature Verification Added
echo ============================================================
echo.

cd /d "%~dp0"

REM Check git repository
git status >nul 2>&1
if errorlevel 1 (
    echo ERROR: Not a git repository!
    pause
    exit /b 1
)

echo Step 1/9: Verifying files changed...
echo ============================================================
git status --short
echo.
echo Changed files for v1.1.0:
echo   - ValidateJWT.cs (signature verification added)
echo   - Properties/AssemblyInfo.cs (version 1.1.0.0)
echo   - ValidateJWT.nuspec (version 1.1.0)
echo   - SIGNATURE_VERIFICATION.md (new)
echo   - VERSION_1.1.0_READY.md (new)
echo.
pause

echo.
echo Step 2/9: Building NuGet Package v1.1.0...
echo ============================================================
call BuildNuGetPackage.bat
if errorlevel 1 (
    echo ERROR: Package build failed!
    pause
    exit /b 1
)

echo.
echo Step 3/9: Verifying Package Contents...
echo ============================================================
powershell -ExecutionPolicy Bypass -File VerifyNuGetPackage.ps1
if errorlevel 1 (
    echo WARNING: Package verification had warnings
    echo Continue anyway? Press any key...
    pause >nul
)

echo.
echo Step 4/9: Running Tests...
echo ============================================================
echo Checking if tests exist...
if exist "ValidateJWT.Tests\ValidateJWT.Tests.csproj" (
    echo Running tests...
    dotnet test ValidateJWT.Tests\ValidateJWT.Tests.csproj --configuration Release --verbosity quiet
    if errorlevel 1 (
        echo WARNING: Some tests failed
        set /p CONTINUE="Continue with release? (Y/N): "
        if /i not "%CONTINUE%"=="Y" (
            echo Release cancelled
            exit /b 1
        )
    ) else (
        echo   All tests passed!
    )
) else (
    echo   No test project found, skipping tests
)
echo.

echo Step 5/9: Committing Changes...
echo ============================================================
echo.
echo Changes to commit:
echo   - ValidateJWT.cs (signature verification feature)
echo   - Properties/AssemblyInfo.cs (v1.1.0.0)
echo   - ValidateJWT.nuspec (v1.1.0)
echo   - SIGNATURE_VERIFICATION.md (new documentation)
echo   - VERSION_1.1.0_READY.md (release notes)
echo   - CHANGELOG.md (updated)
echo.
set /p COMMIT="Commit these changes? (Y/N): "
if /i "%COMMIT%"=="Y" (
    git add ValidateJWT.cs
    git add Properties\AssemblyInfo.cs
    git add ValidateJWT.nuspec
    git add SIGNATURE_VERIFICATION.md
    git add VERSION_1.1.0_READY.md
    git add CHANGELOG.md
    git add Publish-NuGet.ps1
    git add PublishRelease_v1.1.0.bat
    
    git commit -m "Release v1.1.0 - JWT Signature Verification

Major New Features:
- JWT signature verification support (HS256 and RS256)
- VerifySignature() method for HMAC-SHA256 verification
- VerifySignatureRS256() method for RSA-SHA256 verification
- GetAlgorithm() method to detect JWT algorithm
- Base64UrlEncode() helper method
- JwtVerificationResult class for detailed validation results

Improvements:
- Comprehensive signature verification documentation
- Complete API examples and usage scenarios
- Security best practices guide
- Performance optimization guidance

Compatibility:
- 100%% backward compatible with v1.0.x
- All existing methods unchanged
- New features are opt-in
- No breaking changes

Documentation:
- SIGNATURE_VERIFICATION.md (complete feature guide)
- Updated API reference
- Security notes
- Migration examples"
    
    git push origin main
    echo   Changes committed and pushed!
) else (
    echo   Skipping commit...
)
echo.

echo Step 6/9: Creating Git Tag v1.1.0...
echo ============================================================
git tag -l v1.1.0 >nul 2>&1
if not errorlevel 1 (
    echo   Tag v1.1.0 already exists!
    set /p RECREATE="Delete and recreate? (Y/N): "
    if /i "%RECREATE%"=="Y" (
        git tag -d v1.1.0
        git push origin :refs/tags/v1.1.0
        echo   Existing tag deleted
    ) else (
        echo   Using existing tag
        goto skip_tag
    )
)

git tag -a v1.1.0 -m "ValidateJWT v1.1.0 - JWT Signature Verification

Major Feature Release

What's New:
============

Signature Verification (NEW!)
- VerifySignature(jwt, secretKey) - HMAC-SHA256 (HS256) verification
- VerifySignatureRS256(jwt, publicKeyXml) - RSA-SHA256 (RS256) verification
- JwtVerificationResult class with detailed validation info
- GetAlgorithm(jwt) - Detect algorithm from JWT header
- Base64UrlEncode(bytes) - URL-safe encoding helper

Key Features:
=============
- Full JWT validation with signature verification
- Support for HS256 (symmetric) and RS256 (asymmetric)
- Detailed verification results with error messages
- Optional expiration checking included in result
- 100%% backward compatible with v1.0.x

Compatibility:
==============
- All existing methods unchanged (IsExpired, IsValidNow, etc.)
- No breaking changes
- Opt-in signature verification
- Seamless upgrade from v1.0.x

Documentation:
==============
- SIGNATURE_VERIFICATION.md - Complete feature guide
- Examples for all algorithms
- Security best practices
- Performance optimization tips

See SIGNATURE_VERIFICATION.md and VERSION_1.1.0_READY.md for details."

git push origin v1.1.0
echo   Tag v1.1.0 created and pushed!

:skip_tag
echo.

echo Step 7/9: Creating GitHub Release...
echo ============================================================
where gh >nul 2>&1
if errorlevel 1 (
    echo   GitHub CLI not found. Manual steps required:
    echo.
    echo   1. Go to: https://github.com/johanhenningsson4-hash/ValidateJWT/releases/new
    echo   2. Tag: v1.1.0
    echo   3. Title: ValidateJWT v1.1.0 - JWT Signature Verification
    echo   4. Description: Copy from VERSION_1.1.0_READY.md
    echo   5. Highlights:
    echo      - New signature verification (HS256, RS256)
    echo      - VerifySignature() and VerifySignatureRS256() methods
    echo      - JwtVerificationResult class
    echo      - 100%% backward compatible
    echo   6. Click: Publish release
    echo.
    set /p OPEN="Open GitHub releases page? (Y/N): "
    if /i "%OPEN%"=="Y" (
        start https://github.com/johanhenningsson4-hash/ValidateJWT/releases/new?tag=v1.1.0
    )
) else (
    echo   Creating release with GitHub CLI...
    
    REM Create release notes file
    echo # ValidateJWT v1.1.0 - JWT Signature Verification > release_notes_temp.md
    echo. >> release_notes_temp.md
    echo Major feature release adding JWT signature verification support. >> release_notes_temp.md
    echo. >> release_notes_temp.md
    echo ## What's New >> release_notes_temp.md
    echo. >> release_notes_temp.md
    echo ### Signature Verification >> release_notes_temp.md
    echo - `VerifySignature(jwt, secretKey)` - HMAC-SHA256 (HS256) verification >> release_notes_temp.md
    echo - `VerifySignatureRS256(jwt, publicKeyXml)` - RSA-SHA256 (RS256) verification >> release_notes_temp.md
    echo - `JwtVerificationResult` class with detailed validation results >> release_notes_temp.md
    echo - `GetAlgorithm(jwt)` - Detect algorithm from JWT header >> release_notes_temp.md
    echo - `Base64UrlEncode(bytes)` - URL-safe Base64 encoding >> release_notes_temp.md
    echo. >> release_notes_temp.md
    echo ## Key Features >> release_notes_temp.md
    echo - Full JWT validation with signature verification >> release_notes_temp.md
    echo - Support for HS256 (symmetric) and RS256 (asymmetric) algorithms >> release_notes_temp.md
    echo - Detailed verification results with error messages >> release_notes_temp.md
    echo - 100%% backward compatible with v1.0.x >> release_notes_temp.md
    echo. >> release_notes_temp.md
    echo ## Documentation >> release_notes_temp.md
    echo See [SIGNATURE_VERIFICATION.md](SIGNATURE_VERIFICATION.md) for complete guide. >> release_notes_temp.md
    
    gh release create v1.1.0 --title "ValidateJWT v1.1.0 - JWT Signature Verification" --notes-file release_notes_temp.md
    
    del release_notes_temp.md
    echo   GitHub release created!
)
echo.

echo Step 8/9: Publishing to NuGet.org...
echo ============================================================
if defined NUGET_API_KEY (
    echo   NUGET_API_KEY found!
    echo.
    echo   This will publish ValidateJWT v1.1.0 to NuGet.org
    echo   Package: ValidateJWT.1.1.0.nupkg
    echo   New Features: Signature verification (HS256, RS256)
    echo.
    set /p PUBLISH="Publish to NuGet.org? (Y/N): "
    if /i "%PUBLISH%"=="Y" (
        for %%f in (ValidateJWT.1.1.0.nupkg) do (
            echo   Publishing %%f...
            nuget push %%f -Source https://api.nuget.org/v3/index.json -ApiKey %NUGET_API_KEY%
            if errorlevel 1 (
                echo   ERROR: Publication failed!
                echo   Check API key and package version
            ) else (
                echo   Package published successfully!
            )
        )
    ) else (
        echo   Skipping NuGet publish...
    )
) else (
    echo   NUGET_API_KEY not set!
    echo.
    echo   To publish manually:
    echo     nuget push ValidateJWT.1.1.0.nupkg -Source https://api.nuget.org/v3/index.json -ApiKey YOUR_KEY
    echo.
    echo   Or set environment variable:
    echo     setx NUGET_API_KEY "your-key-here"
    echo.
)
echo.

echo Step 9/9: Release Summary
echo ============================================================
echo.
echo Release v1.1.0 Status:
echo   Version: 1.1.0.0
echo   Type: Major Feature Release
echo   Package: ValidateJWT.1.1.0.nupkg
echo   Git: Committed and tagged
echo   GitHub: Release created or manual steps shown
if defined NUGET_API_KEY (
    echo   NuGet: Published or skipped
) else (
    echo   NuGet: Manual publish required
)
echo.
echo What's New in v1.1.0:
echo   - JWT signature verification (HS256, RS256)
echo   - VerifySignature() method for HMAC-SHA256
echo   - VerifySignatureRS256() method for RSA-SHA256
echo   - JwtVerificationResult class
echo   - GetAlgorithm() helper method
echo   - Base64UrlEncode() helper method
echo   - Complete documentation (SIGNATURE_VERIFICATION.md)
echo   - 100%% backward compatible
echo.
echo Compatibility:
echo   - No breaking changes
echo   - All v1.0.x code works unchanged
echo   - New features are opt-in
echo.
echo Next Steps:
echo   1. Wait ~15 minutes for NuGet indexing
echo   2. Verify: https://www.nuget.org/packages/ValidateJWT/1.1.0
echo   3. Verify: https://github.com/johanhenningsson4-hash/ValidateJWT/releases/tag/v1.1.0
echo   4. Test install: Install-Package ValidateJWT -Version 1.1.0
echo   5. Test signature verification features
echo.
echo Documentation:
echo   - SIGNATURE_VERIFICATION.md (feature guide)
echo   - VERSION_1.1.0_READY.md (release notes)
echo   - CHANGELOG.md (version history)
echo.
echo ============================================================
echo   v1.1.0 Feature Release Complete!
echo ============================================================
echo.
echo Thank you for using ValidateJWT!
echo.
pause
