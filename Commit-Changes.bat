@echo off
REM Simple Git Commit and Push Script

echo.
echo ============================================================
echo   ValidateJWT - Commit and Push
echo ============================================================
echo.

cd /d "%~dp0"

REM Stage all changes
echo [1/3] Staging changes...
git add -A
if errorlevel 1 (
    echo ERROR: Failed to stage changes
    pause
    exit /b 1
)
echo   Done.
echo.

REM Commit
echo [2/3] Committing...
git commit -m "docs: Update README and add GitHub secrets setup"
if errorlevel 1 (
    echo ERROR: Commit failed
    pause
    exit /b 1
)
echo   Done.
echo.

REM Push
echo [3/3] Pushing to GitHub...
git push origin main
if errorlevel 1 (
    echo ERROR: Push failed
    pause
    exit /b 1
)
echo   Done.
echo.

echo ============================================================
echo   SUCCESS! Changes pushed to GitHub
echo ============================================================
echo.
echo View at: https://github.com/johanhenningsson4-hash/ValidateJWT
echo.
pause
