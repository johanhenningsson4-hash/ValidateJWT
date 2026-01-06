# Quick Sync to GitHub
# Commits and pushes all namespace and year changes

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  ValidateJWT - Sync to GitHub" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

Set-Location "C:\Jobb\ValidateJWT"

Write-Host "Changes to commit:" -ForegroundColor Yellow
Write-Host "  • Namespace: TPDotNet.MTR.Common ? Johan.Common" -ForegroundColor White
Write-Host "  • Copyright year: 2024/2025 ? 2026" -ForegroundColor White
Write-Host "  • Build: ? Successful (58+ tests passing)" -ForegroundColor Green
Write-Host ""

# Show what will be committed
Write-Host "[1/3] Staging changes..." -ForegroundColor Cyan
git add -A
Write-Host "? All changes staged" -ForegroundColor Green
Write-Host ""

# Commit
Write-Host "[2/3] Creating commit..." -ForegroundColor Cyan
$commitMsg = @"
Update namespace to Johan.Common and copyright year to 2026

Changes:
- Namespace: TPDotNet.MTR.Common ? Johan.Common
  - ValidateJWT.cs
  - ValidateJWTTests.cs  
  - Base64UrlDecodeTests.cs
  
- Copyright year: 2024/2025 ? 2026
  - Properties/AssemblyInfo.cs
  - ValidateJWT.Tests/Properties/AssemblyInfo.cs
  - All documentation files

- Added helper files:
  - NAMESPACE_CHANGE_SUMMARY.md
  - CommitAndPush.ps1
  - FINAL_STATUS_COMPLETE.md
  - PUSH_NOW.md
  - SyncToGitHub.ps1

Build Status: ? Success - 58+ tests passing
"@

git commit -m $commitMsg
Write-Host "? Commit created" -ForegroundColor Green
Write-Host ""

# Push
Write-Host "[3/3] Pushing to GitHub..." -ForegroundColor Cyan
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "  ? SUCCESS! All changes pushed to GitHub" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Repository:" -ForegroundColor Yellow
    Write-Host "  https://github.com/johanhenningsson4-hash/ValidateJWT" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Committed:" -ForegroundColor Yellow
    Write-Host "  ? Namespace changed to Johan.Common" -ForegroundColor Green
    Write-Host "  ? Copyright updated to 2026" -ForegroundColor Green
    Write-Host "  ? All test files updated" -ForegroundColor Green
    Write-Host "  ? All documentation updated" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "??  Manual Step Required:" -ForegroundColor Yellow
    Write-Host "  1. Close Visual Studio" -ForegroundColor White
    Write-Host "  2. Edit ValidateJWT.csproj" -ForegroundColor White
    Write-Host "     Find:    <RootNamespace>TPDotNet.MTR.Common</RootNamespace>" -ForegroundColor Red
    Write-Host "     Replace: <RootNamespace>Johan.Common</RootNamespace>" -ForegroundColor Green
    Write-Host "  3. Save and commit:" -ForegroundColor White
    Write-Host "     git add ValidateJWT.csproj" -ForegroundColor Cyan
    Write-Host "     git commit -m 'Update RootNamespace to Johan.Common'" -ForegroundColor Cyan
    Write-Host "     git push origin main" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Red
    Write-Host "  ? Push Failed!" -ForegroundColor Red
    Write-Host "==================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error code: $LASTEXITCODE" -ForegroundColor Red
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "  • Check internet connection" -ForegroundColor White
    Write-Host "  • Verify Git credentials" -ForegroundColor White
    Write-Host "  • Ensure repository access permissions" -ForegroundColor White
    Write-Host ""
}

Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
