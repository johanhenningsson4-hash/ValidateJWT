# Automated Cleanup Script for ValidateJWT
# Organizes documentation and archives historical files

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ValidateJWT Code Cleanup & Organization" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

Write-Host "Current directory: $scriptDir" -ForegroundColor Gray
Write-Host ""

# Confirm action
Write-Host "This script will:" -ForegroundColor Yellow
Write-Host "  1. Create Archive/ directory structure" -ForegroundColor White
Write-Host "  2. Move historical documentation to Archive/" -ForegroundColor White
Write-Host "  3. Organize release-specific files" -ForegroundColor White
Write-Host "  4. Keep essential files in root" -ForegroundColor White
Write-Host ""
$confirm = Read-Host "Continue with cleanup? (Y/N)"

if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "Cleanup cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Starting cleanup..." -ForegroundColor Cyan
Write-Host ""

# Step 1: Create archive directories
Write-Host "[1/5] Creating archive directory structure..." -ForegroundColor Cyan

$archiveDirs = @(
    "Archive",
    "Archive/Releases",
    "Archive/Development",
    "Archive/Verification",
    "Archive/NuGet"
)

foreach ($dir in $archiveDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  ? Created: $dir" -ForegroundColor Green
    } else {
        Write-Host "  ? Exists: $dir" -ForegroundColor Gray
    }
}

Write-Host ""

# Step 2: Archive old release files
Write-Host "[2/5] Archiving old release files..." -ForegroundColor Cyan

$releaseFiles = @(
    "VERSION_1.0.1_READY.md",
    "PublishRelease_v1.0.1.bat",
    "RELEASE_NOTES_v1.0.1.md",
    "NUGET_PACKAGE_READY.md",
    "RELEASE_READY.md"
)

foreach ($file in $releaseFiles) {
    if (Test-Path $file) {
        Move-Item $file "Archive/Releases/" -Force
        Write-Host "  ? Archived: $file" -ForegroundColor Green
    } else {
        Write-Host "  ? Not found: $file" -ForegroundColor Gray
    }
}

Write-Host ""

# Step 3: Archive development/troubleshooting docs
Write-Host "[3/5] Archiving development documentation..." -ForegroundColor Cyan

$devFiles = @(
    "PROJECT_ANALYSIS.md",
    "ANALYSIS_SUMMARY.md",
    "BUILD_ISSUES_FIXED.md",
    "WARNINGS_FIXED.md",
    "OUTPUT_PATH_FIX.md",
    "FINAL_SUCCESS.md",
    "COMPLETE_FIX_INSTRUCTIONS.md",
    "FIX_COMPILER_ERRORS_NOW.md",
    "MANUAL_FIX_GUIDE.md",
    "TEST_PROJECT_FIX.md",
    "SYNC_STATUS.md"
)

foreach ($file in $devFiles) {
    if (Test-Path $file) {
        Move-Item $file "Archive/Development/" -Force
        Write-Host "  ? Archived: $file" -ForegroundColor Green
    } else {
        Write-Host "  ? Not found: $file" -ForegroundColor Gray
    }
}

Write-Host ""

# Step 4: Archive verification docs
Write-Host "[4/5] Archiving verification documentation..." -ForegroundColor Cyan

$verificationFiles = @(
    "COMPANY_VERIFICATION.md",
    "FINAL_COMPANY_VERIFICATION.md"
)

foreach ($file in $verificationFiles) {
    if (Test-Path $file) {
        Move-Item $file "Archive/Verification/" -Force
        Write-Host "  ? Archived: $file" -ForegroundColor Green
    } else {
        Write-Host "  ? Not found: $file" -ForegroundColor Gray
    }
}

Write-Host ""

# Step 5: Archive redundant NuGet docs
Write-Host "[5/5] Archiving redundant NuGet documentation..." -ForegroundColor Cyan

$nugetFiles = @(
    "NUGET_API_KEY_GUIDE.md",
    "NUGET_GUIDE.md",
    "NUGET_QUICK_START.md",
    "NUGET_README_LICENSE.md",
    "PUBLISH_NOW.md",
    "PUBLISH_QUICK_START.md",
    "PUBLISH_NUGET_QUICK_REF.md"
)

foreach ($file in $nugetFiles) {
    if (Test-Path $file) {
        Move-Item $file "Archive/NuGet/" -Force
        Write-Host "  ? Archived: $file" -ForegroundColor Green
    } else {
        Write-Host "  ? Not found: $file" -ForegroundColor Gray
    }
}

Write-Host ""

# Create Archive README
Write-Host "Creating Archive/README.md..." -ForegroundColor Cyan

$archiveReadme = @"
# Archived Documentation

This directory contains historical documentation and old release files.

## Directory Structure

### /Releases
Old release notes and version-specific files:
- VERSION_1.0.1_READY.md
- PublishRelease_v1.0.1.bat
- RELEASE_NOTES_v1.0.1.md
- etc.

### /Development
Development process documentation and troubleshooting guides:
- PROJECT_ANALYSIS.md
- BUILD_ISSUES_FIXED.md
- Various troubleshooting guides

### /Verification
One-time verification documents:
- COMPANY_VERIFICATION.md
- Code cleanup verification

### /NuGet
Redundant or superseded NuGet documentation:
- Multiple publishing guides consolidated into main guide

## Current Documentation

For current documentation, see the root directory:
- README.md - Main documentation
- CHANGELOG.md - Version history
- SIGNATURE_VERIFICATION.md - Feature guide
- PUBLISH_NUGET_GUIDE.md - Publishing guide

---

*These files are preserved for historical reference but are no longer actively maintained.*
"@

Set-Content -Path "Archive/README.md" -Value $archiveReadme
Write-Host "  ? Created: Archive/README.md" -ForegroundColor Green

Write-Host ""

# Optional: Rename current release script to generic
if (Test-Path "PublishRelease_v1.1.0.bat") {
    $rename = Read-Host "Rename PublishRelease_v1.1.0.bat to PublishRelease.bat? (Y/N)"
    if ($rename -eq 'Y' -or $rename -eq 'y') {
        if (Test-Path "PublishRelease.bat") {
            Remove-Item "PublishRelease.bat" -Force
        }
        Rename-Item "PublishRelease_v1.1.0.bat" "PublishRelease.bat"
        Write-Host "  ? Renamed to PublishRelease.bat" -ForegroundColor Green
    }
    Write-Host ""
}

# Summary
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Cleanup Summary" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Files organized into Archive/:" -ForegroundColor White
Write-Host "  /Releases      - Old release files" -ForegroundColor Gray
Write-Host "  /Development   - Development docs" -ForegroundColor Gray
Write-Host "  /Verification  - Verification docs" -ForegroundColor Gray
Write-Host "  /NuGet         - Redundant NuGet docs" -ForegroundColor Gray
Write-Host ""

Write-Host "Current root directory contains:" -ForegroundColor White
Write-Host "  ? Essential documentation (README, CHANGELOG, LICENSE)" -ForegroundColor Green
Write-Host "  ? Current release info (VERSION_1.1.0_READY.md)" -ForegroundColor Green
Write-Host "  ? Publishing scripts (Publish-NuGet.ps1, etc.)" -ForegroundColor Green
Write-Host "  ? Feature guides (SIGNATURE_VERIFICATION.md)" -ForegroundColor Green
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Review archived files" -ForegroundColor White
Write-Host "  2. Commit changes: git add -A && git commit -m 'Cleanup: Archive historical docs'" -ForegroundColor White
Write-Host "  3. Update README.md if needed" -ForegroundColor White
Write-Host ""

Write-Host "? Cleanup complete!" -ForegroundColor Green
Write-Host ""

# Show remaining files in root
Write-Host "Files remaining in root directory:" -ForegroundColor Cyan
Get-ChildItem -File | Where-Object { $_.Name -notlike ".*" -and $_.Extension -in @('.md', '.bat', '.ps1', '.txt') } | ForEach-Object {
    Write-Host "  • $($_.Name)" -ForegroundColor Gray
}
Write-Host ""
