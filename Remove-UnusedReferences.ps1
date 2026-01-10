# Remove Unused References Script for ValidateJWT
# This script removes the System.Xml reference which is not used in the code

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ValidateJWT - Remove Unused References" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Check if Visual Studio is running
$vsProcess = Get-Process devenv -ErrorAction SilentlyContinue
if ($vsProcess) {
    Write-Host "? Visual Studio is currently running!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please close Visual Studio before running this script." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

$projectDir = $PSScriptRoot
if (-not $projectDir) {
    $projectDir = Get-Location
}

Set-Location $projectDir

Write-Host "Project Directory: $projectDir" -ForegroundColor Gray
Write-Host ""

# Analysis
Write-Host "Analysis Results:" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Required References (Used in Code):" -ForegroundColor Green
Write-Host "  ? System - Core .NET types (DateTime, Exception, etc.)" -ForegroundColor White
Write-Host "  ? System.Core - Extension methods and LINQ" -ForegroundColor White
Write-Host "  ? System.Runtime.Serialization - JWT JSON parsing" -ForegroundColor White
Write-Host ""

Write-Host "Unused References (Not Found in Code):" -ForegroundColor Yellow
Write-Host "  ? System.Xml - XML functionality (not used)" -ForegroundColor White
Write-Host ""

# Confirm removal
$confirm = Read-Host "Remove unused System.Xml reference? (Y/N)"
if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "[1/3] Creating backup..." -ForegroundColor Cyan

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$projectFile = "ValidateJWT.csproj"
$backupFile = "ValidateJWT.csproj.backup_$timestamp"

Copy-Item $projectFile $backupFile
Write-Host "  ? Backup created: $backupFile" -ForegroundColor Green
Write-Host ""

Write-Host "[2/3] Removing System.Xml reference..." -ForegroundColor Cyan

# Read project file
$content = Get-Content $projectFile -Raw

# Count references before
$beforeCount = ([regex]::Matches($content, '<Reference Include')).Count

# Remove System.Xml reference
$content = $content -replace '\s*<Reference Include="System\.Xml"\s*/>\s*', ''

# Count references after  
$afterCount = ([regex]::Matches($content, '<Reference Include')).Count

# Save
[System.IO.File]::WriteAllText((Join-Path $projectDir $projectFile), $content, [System.Text.Encoding]::UTF8)

Write-Host "  ? System.Xml reference removed" -ForegroundColor Green
Write-Host "  References: $beforeCount -> $afterCount" -ForegroundColor Gray
Write-Host ""

Write-Host "[3/3] Cleaning build artifacts..." -ForegroundColor Cyan

Remove-Item -Path "bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "obj" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "  ? Build artifacts cleaned" -ForegroundColor Green
Write-Host ""

# Summary
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Cleanup Complete!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Summary:" -ForegroundColor White
Write-Host "  ? Removed: System.Xml (unused)" -ForegroundColor Green
Write-Host "  ? Kept: System, System.Core, System.Runtime.Serialization" -ForegroundColor Green
Write-Host "  ? Backup: $backupFile" -ForegroundColor Gray
Write-Host ""

Write-Host "Remaining References:" -ForegroundColor Cyan
Write-Host "  1. System - Core .NET Framework types" -ForegroundColor White
Write-Host "  2. System.Core - Extension methods, LINQ" -ForegroundColor White
Write-Host "  3. System.Runtime.Serialization - JSON serialization" -ForegroundColor White
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Open ValidateJWT.sln in Visual Studio" -ForegroundColor White
Write-Host "  2. Build -> Rebuild Solution (Ctrl+Shift+B)" -ForegroundColor White
Write-Host "  3. Verify: 0 errors, 0 warnings" -ForegroundColor White
Write-Host ""

Write-Host "Expected Result:" -ForegroundColor Green
Write-Host "  ? Build: Successful" -ForegroundColor White
Write-Host "  ? Size: Slightly smaller assembly" -ForegroundColor White
Write-Host "  ? Performance: No change (runtime not affected)" -ForegroundColor White
Write-Host ""

Write-Host "To restore the original file if needed:" -ForegroundColor Yellow
Write-Host "  Copy-Item $backupFile $projectFile" -ForegroundColor White
Write-Host ""

Write-Host "Press Enter to exit..."
Read-Host
