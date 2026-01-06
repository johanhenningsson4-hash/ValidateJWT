# ValidateJWT v1.0.0 Release Script
# This script automates the release process

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " ValidateJWT v1.0.0 Release Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Set location
$projectPath = "C:\Jobb\ValidateJWT"
Set-Location $projectPath

Write-Host "Current directory: $projectPath" -ForegroundColor Yellow
Write-Host ""

# Step 1: Check Git status
Write-Host "[Step 1/5] Checking Git status..." -ForegroundColor Green
git status --short

Write-Host ""
$continue = Read-Host "Do you want to continue with the release? (Y/N)"
if ($continue -ne 'Y' -and $continue -ne 'y') {
    Write-Host "Release cancelled." -ForegroundColor Red
    exit
}

# Step 2: Add all changes
Write-Host ""
Write-Host "[Step 2/5] Adding all changes to Git..." -ForegroundColor Green
git add .
Write-Host "Files staged for commit." -ForegroundColor Yellow

# Step 3: Commit changes
Write-Host ""
Write-Host "[Step 3/5] Committing changes..." -ForegroundColor Green
$commitMessage = @"
Release v1.0.0 - Initial public release

- Update version to 1.0.0 in AssemblyInfo.cs
- Add comprehensive release notes (RELEASE_NOTES_v1.0.0.md)
- Add changelog (CHANGELOG.md)
- Add release guide (RELEASE_GUIDE.md)
- Update assembly title and description
- Ready for production use with 58+ tests and full documentation
"@

git commit -m $commitMessage
Write-Host "Changes committed." -ForegroundColor Yellow

# Step 4: Create Git tag
Write-Host ""
Write-Host "[Step 4/5] Creating Git tag v1.0.0..." -ForegroundColor Green
$tagMessage = @"
ValidateJWT v1.0.0 - Initial Release

First official release of ValidateJWT - lightweight JWT expiration validation library.

Features:
- JWT expiration validation
- Clock skew support
- Base64URL decoding
- 58+ comprehensive tests
- ~100% API coverage
- Complete documentation

See RELEASE_NOTES_v1.0.0.md for full details.
"@

git tag -a v1.0.0 -m $tagMessage
Write-Host "Tag v1.0.0 created." -ForegroundColor Yellow

# Step 5: Push to GitHub
Write-Host ""
Write-Host "[Step 5/5] Pushing to GitHub..." -ForegroundColor Green
Write-Host "Pushing commits..." -ForegroundColor Yellow
git push origin main

Write-Host "Pushing tags..." -ForegroundColor Yellow
git push origin v1.0.0

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Release Preparation Complete! ?" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Go to: https://github.com/johanhenningsson4-hash/ValidateJWT/releases/new" -ForegroundColor White
Write-Host "2. Select tag: v1.0.0" -ForegroundColor White
Write-Host "3. Title: ValidateJWT v1.0.0 - Initial Release" -ForegroundColor White
Write-Host "4. Copy content from: RELEASE_NOTES_v1.0.0.md" -ForegroundColor White
Write-Host "5. Click 'Publish release'" -ForegroundColor White
Write-Host ""

Write-Host "Or use GitHub CLI:" -ForegroundColor Yellow
Write-Host "gh release create v1.0.0 --title 'ValidateJWT v1.0.0 - Initial Release' --notes-file RELEASE_NOTES_v1.0.0.md --latest" -ForegroundColor Cyan
Write-Host ""

Write-Host "Repository URL: https://github.com/johanhenningsson4-hash/ValidateJWT" -ForegroundColor Green
Write-Host ""

# Open browser to releases page
$openBrowser = Read-Host "Open GitHub releases page in browser? (Y/N)"
if ($openBrowser -eq 'Y' -or $openBrowser -eq 'y') {
    Start-Process "https://github.com/johanhenningsson4-hash/ValidateJWT/releases/new?tag=v1.0.0"
}

Write-Host ""
Write-Host "Release script completed successfully!" -ForegroundColor Green
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
