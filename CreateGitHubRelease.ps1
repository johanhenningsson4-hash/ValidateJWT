# GitHub Release Creation Script for ValidateJWT v1.0.0

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ValidateJWT - GitHub Release Creator v1.0.0" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$projectDir = "C:\Jobb\ValidateJWT"
Set-Location $projectDir

# Release configuration
$version = "1.0.0"
$tagName = "v$version"
$releaseName = "ValidateJWT v$version - Initial Release"
$releaseDate = Get-Date -Format "yyyy-MM-dd"

Write-Host "Release Configuration:" -ForegroundColor Yellow
Write-Host "  Version: $version" -ForegroundColor White
Write-Host "  Tag: $tagName" -ForegroundColor White
Write-Host "  Date: $releaseDate" -ForegroundColor White
Write-Host ""

# Step 1: Check Git status
Write-Host "[Step 1/6] Checking Git status..." -ForegroundColor Cyan
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "  ??  You have uncommitted changes:" -ForegroundColor Yellow
    git status --short
    Write-Host ""
    $continue = Read-Host "Commit these changes first? (Y/N)"
    if ($continue -eq 'Y' -or $continue -eq 'y') {
        git add -A
        git commit -m "Prepare for v$version release"
        git push origin main
        Write-Host "  ? Changes committed and pushed" -ForegroundColor Green
    } else {
        Write-Host "  ??  Proceeding with uncommitted changes..." -ForegroundColor Yellow
    }
} else {
    Write-Host "  ? Working directory clean" -ForegroundColor Green
}
Write-Host ""

# Step 2: Build Release binaries
Write-Host "[Step 2/6] Building Release binaries..." -ForegroundColor Cyan

# Find MSBuild
function Find-MSBuild {
    if ($env:VSINSTALLDIR) {
        $devCmdMSBuild = Join-Path $env:VSINSTALLDIR "MSBuild\Current\Bin\MSBuild.exe"
        if (Test-Path $devCmdMSBuild) { return $devCmdMSBuild }
        return "msbuild"
    }
    
    $paths = @(
        "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe",
        "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"
    )
    
    foreach ($path in $paths) {
        if (Test-Path $path) { return $path }
    }
    
    if (Get-Command msbuild -ErrorAction SilentlyContinue) { return "msbuild" }
    return $null
}

$msbuild = Find-MSBuild
if (-not $msbuild) {
    Write-Host "  ? MSBuild not found. Build manually in Visual Studio." -ForegroundColor Red
    Write-Host ""
    exit 1
}

# Clean and build
if (Test-Path "bin\Release") { Remove-Item -Recurse -Force "bin\Release" }
& $msbuild ValidateJWT.csproj /p:Configuration=Release /p:DocumentationFile=bin\Release\ValidateJWT.xml /v:minimal /nologo

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ? Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "  ? Build successful" -ForegroundColor Green
Write-Host ""

# Step 3: Create release package
Write-Host "[Step 3/6] Creating release package..." -ForegroundColor Cyan

$releaseDir = "Release-v$version"
if (Test-Path $releaseDir) { Remove-Item -Recurse -Force $releaseDir }
New-Item -ItemType Directory -Path $releaseDir | Out-Null

# Copy release files
Copy-Item "bin\Release\ValidateJWT.dll" "$releaseDir\"
Copy-Item "bin\Release\ValidateJWT.xml" "$releaseDir\"
Copy-Item "bin\Release\ValidateJWT.pdb" "$releaseDir\"
Copy-Item "README.md" "$releaseDir\"
Copy-Item "LICENSE.txt" "$releaseDir\"
Copy-Item "CHANGELOG.md" "$releaseDir\"

# Create zip file
$zipFile = "ValidateJWT-v$version.zip"
if (Test-Path $zipFile) { Remove-Item $zipFile }

Add-Type -Assembly System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($releaseDir, $zipFile)

$zipSize = [math]::Round((Get-Item $zipFile).Length / 1KB, 2)
Write-Host "  ? Release package created: $zipFile ($zipSize KB)" -ForegroundColor Green
Write-Host ""

# Step 4: Create or check Git tag
Write-Host "[Step 4/6] Creating Git tag..." -ForegroundColor Cyan

$existingTag = git tag -l $tagName
if ($existingTag) {
    Write-Host "  ??  Tag $tagName already exists" -ForegroundColor Yellow
    $recreate = Read-Host "Delete and recreate tag? (Y/N)"
    if ($recreate -eq 'Y' -or $recreate -eq 'y') {
        git tag -d $tagName
        git push origin :refs/tags/$tagName
        Write-Host "  ? Existing tag deleted" -ForegroundColor Green
    } else {
        Write-Host "  ??  Using existing tag" -ForegroundColor Cyan
    }
}

if (-not $existingTag -or ($recreate -eq 'Y' -or $recreate -eq 'y')) {
    $tagMessage = @"
ValidateJWT v$version - Initial Release

First official release of ValidateJWT - lightweight JWT expiration validation library.

Features:
- JWT expiration validation with clock skew support
- Base64URL decoding
- Thread-safe implementation
- Zero external dependencies
- 58+ comprehensive unit tests
- ~100% API coverage

See RELEASE_NOTES_v1.0.0.md for details.
"@
    
    git tag -a $tagName -m $tagMessage
    Write-Host "  ? Tag $tagName created" -ForegroundColor Green
}
Write-Host ""

# Step 5: Push tag
Write-Host "[Step 5/6] Pushing tag to GitHub..." -ForegroundColor Cyan
git push origin $tagName

if ($LASTEXITCODE -eq 0) {
    Write-Host "  ? Tag pushed to GitHub" -ForegroundColor Green
} else {
    Write-Host "  ? Failed to push tag" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 6: Create GitHub Release
Write-Host "[Step 6/6] Creating GitHub Release..." -ForegroundColor Cyan
Write-Host ""

# Check for GitHub CLI
$hasGH = Get-Command gh -ErrorAction SilentlyContinue

if ($hasGH) {
    Write-Host "  ? GitHub CLI (gh) found" -ForegroundColor Green
    Write-Host "  Creating release with gh CLI..." -ForegroundColor Cyan
    Write-Host ""
    
    # Read release notes
    $releaseNotes = Get-Content "RELEASE_NOTES_v1.0.0.md" -Raw
    
    # Create release with gh CLI
    gh release create $tagName `
        --title $releaseName `
        --notes $releaseNotes `
        $zipFile `
        "bin\Release\ValidateJWT.dll" `
        "bin\Release\ValidateJWT.xml"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "============================================================" -ForegroundColor Cyan
        Write-Host "  ? GitHub Release Created Successfully!" -ForegroundColor Green
        Write-Host "============================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "?? Release: $releaseName" -ForegroundColor Yellow
        Write-Host "?? Tag: $tagName" -ForegroundColor White
        Write-Host "?? Assets: $zipFile, ValidateJWT.dll, ValidateJWT.xml" -ForegroundColor White
        Write-Host ""
        Write-Host "?? View release at:" -ForegroundColor Yellow
        Write-Host "   https://github.com/johanhenningsson4-hash/ValidateJWT/releases/tag/$tagName" -ForegroundColor Cyan
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "  ? Failed to create release with gh CLI" -ForegroundColor Red
    }
} else {
    Write-Host "  ??  GitHub CLI (gh) not found" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Manual Steps to Create Release:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Go to:" -ForegroundColor Cyan
    Write-Host "   https://github.com/johanhenningsson4-hash/ValidateJWT/releases/new" -ForegroundColor White
    Write-Host ""
    Write-Host "2. Fill in:" -ForegroundColor Cyan
    Write-Host "   • Tag: $tagName (should be pre-selected)" -ForegroundColor White
    Write-Host "   • Title: $releaseName" -ForegroundColor White
    Write-Host "   • Description: Copy from RELEASE_NOTES_v1.0.0.md" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Upload these files:" -ForegroundColor Cyan
    Write-Host "   • $zipFile" -ForegroundColor White
    Write-Host "   • bin\Release\ValidateJWT.dll" -ForegroundColor White
    Write-Host "   • bin\Release\ValidateJWT.xml" -ForegroundColor White
    Write-Host ""
    Write-Host "4. Check 'Set as the latest release'" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "5. Click 'Publish release'" -ForegroundColor Cyan
    Write-Host ""
    
    $openBrowser = Read-Host "Open GitHub releases page in browser? (Y/N)"
    if ($openBrowser -eq 'Y' -or $openBrowser -eq 'y') {
        Start-Process "https://github.com/johanhenningsson4-hash/ValidateJWT/releases/new?tag=$tagName"
    }
    Write-Host ""
    Write-Host "To install GitHub CLI for next time:" -ForegroundColor Yellow
    Write-Host "   winget install --id GitHub.cli" -ForegroundColor White
    Write-Host "   Or download from: https://cli.github.com/" -ForegroundColor White
    Write-Host ""
}

Write-Host "Release files created in: $releaseDir" -ForegroundColor Gray
Write-Host "Release package: $zipFile" -ForegroundColor Gray
Write-Host ""

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
