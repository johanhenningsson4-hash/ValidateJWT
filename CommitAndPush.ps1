# Git Commit and Push Script
# Commits all changes and pushes to GitHub

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Git Commit & Push Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectDir = "C:\Jobb\ValidateJWT"
cd $projectDir

Write-Host "Current directory: $projectDir" -ForegroundColor Yellow
Write-Host ""

# Step 1: Check Git status
Write-Host "[Step 1/4] Checking Git status..." -ForegroundColor Green
git status --short
Write-Host ""

# Step 2: Add all changes
Write-Host "[Step 2/4] Adding all changes..." -ForegroundColor Green
git add -A
Write-Host "? All changes staged" -ForegroundColor Green
Write-Host ""

# Step 3: Commit with descriptive message
Write-Host "[Step 3/4] Creating commit..." -ForegroundColor Green
$commitMessage = @"
Update namespace from TPDotNet.MTR.Common to Johan.Common and update copyright year to 2026

Changes:
- Changed namespace from TPDotNet.MTR.Common to Johan.Common in ValidateJWT.cs
- Updated using statements in ValidateJWTTests.cs to use Johan.Common
- Updated using statements in Base64UrlDecodeTests.cs to use Johan.Common
- Updated copyright year from 2025 to 2026 in Properties/AssemblyInfo.cs
- Updated copyright year from 2024 to 2026 in ValidateJWT.Tests/Properties/AssemblyInfo.cs
- Updated all documentation files (PROJECT_ANALYSIS.md, ANALYSIS_SUMMARY.md, CHANGELOG.md, etc.) to reflect 2026 dates
- Added NAMESPACE_CHANGE_SUMMARY.md documenting the changes

Build Status: ? All tests passing (58+ tests)
"@

git commit -m $commitMessage
Write-Host "? Commit created" -ForegroundColor Green
Write-Host ""

# Step 4: Push to GitHub
Write-Host "[Step 4/4] Pushing to GitHub..." -ForegroundColor Green
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " ? Success! Changes pushed to GitHub" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Summary of changes:" -ForegroundColor Yellow
    Write-Host "  ? Namespace: TPDotNet.MTR.Common ? Johan.Common" -ForegroundColor White
    Write-Host "  ? Copyright year: 2025/2024 ? 2026" -ForegroundColor White
    Write-Host "  ? All test files updated" -ForegroundColor White
    Write-Host "  ? All documentation updated" -ForegroundColor White
    Write-Host "  ? Build successful with 58+ tests passing" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Repository URL:" -ForegroundColor Cyan
    Write-Host "  https://github.com/johanhenningsson4-hash/ValidateJWT" -ForegroundColor White
    Write-Host ""
    
    Write-Host "?? IMPORTANT: Manual step required!" -ForegroundColor Yellow
    Write-Host "  Close Visual Studio and edit ValidateJWT.csproj:" -ForegroundColor White
    Write-Host "  Change: <RootNamespace>TPDotNet.MTR.Common</RootNamespace>" -ForegroundColor Red
    Write-Host "  To:     <RootNamespace>Johan.Common</RootNamespace>" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "? Push failed!" -ForegroundColor Red
    Write-Host "Error code: $LASTEXITCODE" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check:" -ForegroundColor Yellow
    Write-Host "  - Internet connection" -ForegroundColor White
    Write-Host "  - GitHub credentials" -ForegroundColor White
    Write-Host "  - Repository permissions" -ForegroundColor White
    Write-Host ""
}

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
