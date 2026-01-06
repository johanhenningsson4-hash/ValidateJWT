# Verify NuGet Package Contents
# Checks that README.md and LICENSE.txt are included

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  NuGet Package Content Verification" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$projectDir = "C:\Jobb\ValidateJWT"
Set-Location $projectDir

# Find the package
$nupkgFile = Get-ChildItem -Filter "ValidateJWT.*.nupkg" | Select-Object -First 1

if (-not $nupkgFile) {
    Write-Host "? No .nupkg file found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Build the package first:" -ForegroundColor Yellow
    Write-Host "   .\BuildNuGetPackage.bat" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "?? Package found: $($nupkgFile.Name)" -ForegroundColor Green
Write-Host "   Size: $([math]::Round($nupkgFile.Length / 1KB, 2)) KB" -ForegroundColor Gray
Write-Host ""

# Extract package to temporary directory
$tempDir = "temp_package_check"
if (Test-Path $tempDir) {
    Remove-Item -Recurse -Force $tempDir
}

Write-Host "Extracting package..." -ForegroundColor Cyan
Expand-Archive $nupkgFile.Name -DestinationPath $tempDir

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Package Contents Verification" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Check for required files
$checks = @(
    @{ Name = "README.md"; Path = "$tempDir\README.md"; Required = $true },
    @{ Name = "LICENSE.txt"; Path = "$tempDir\LICENSE.txt"; Required = $true },
    @{ Name = "ValidateJWT.dll"; Path = "$tempDir\lib\net472\ValidateJWT.dll"; Required = $true },
    @{ Name = "ValidateJWT.xml"; Path = "$tempDir\lib\net472\ValidateJWT.xml"; Required = $true },
    @{ Name = "ValidateJWT.pdb"; Path = "$tempDir\lib\net472\ValidateJWT.pdb"; Required = $false },
    @{ Name = "ValidateJWT.cs (source)"; Path = "$tempDir\src\ValidateJWT.cs"; Required = $false }
)

$allPassed = $true
foreach ($check in $checks) {
    $exists = Test-Path $check.Path
    
    if ($exists) {
        $fileInfo = Get-Item $check.Path
        $size = [math]::Round($fileInfo.Length / 1KB, 2)
        Write-Host "  ? $($check.Name)" -ForegroundColor Green -NoNewline
        Write-Host " ($size KB)" -ForegroundColor Gray
    } else {
        if ($check.Required) {
            Write-Host "  ? $($check.Name) - MISSING!" -ForegroundColor Red
            $allPassed = $false
        } else {
            Write-Host "  ??  $($check.Name) - Not found (optional)" -ForegroundColor Yellow
        }
    }
}

Write-Host ""

# Check README content
if (Test-Path "$tempDir\README.md") {
    $readmeContent = Get-Content "$tempDir\README.md" -Raw
    $readmeLines = ($readmeContent -split "`n").Count
    
    Write-Host "README.md Details:" -ForegroundColor Cyan
    Write-Host "  Lines: $readmeLines" -ForegroundColor White
    Write-Host "  Size: $([math]::Round((Get-Item "$tempDir\README.md").Length / 1KB, 2)) KB" -ForegroundColor White
    
    # Check for important sections
    $sections = @("Installation", "Usage", "API", "Features")
    $foundSections = @()
    foreach ($section in $sections) {
        if ($readmeContent -match $section) {
            $foundSections += $section
        }
    }
    
    if ($foundSections.Count -gt 0) {
        Write-Host "  Sections found: $($foundSections -join ', ')" -ForegroundColor Green
    }
    Write-Host ""
}

# Check LICENSE content
if (Test-Path "$tempDir\LICENSE.txt") {
    $licenseContent = Get-Content "$tempDir\LICENSE.txt" -Raw
    
    Write-Host "LICENSE.txt Details:" -ForegroundColor Cyan
    Write-Host "  Size: $([math]::Round((Get-Item "$tempDir\LICENSE.txt").Length / 1KB, 2)) KB" -ForegroundColor White
    
    if ($licenseContent -match "MIT License") {
        Write-Host "  License Type: MIT ?" -ForegroundColor Green
    }
    
    if ($licenseContent -match "2026") {
        Write-Host "  Copyright Year: 2026 ?" -ForegroundColor Green
    }
    
    if ($licenseContent -match "Johan Henningsson") {
        Write-Host "  Copyright Holder: Johan Henningsson ?" -ForegroundColor Green
    }
    Write-Host ""
}

# List all files in package
Write-Host "Complete File Structure:" -ForegroundColor Cyan
Get-ChildItem $tempDir -Recurse -File | ForEach-Object {
    $relativePath = $_.FullName.Replace("$tempDir\", "").Replace("$tempDir", "")
    $size = [math]::Round($_.Length / 1KB, 2)
    Write-Host "  $relativePath" -ForegroundColor Gray -NoNewline
    Write-Host " ($size KB)" -ForegroundColor DarkGray
}

Write-Host ""

# Cleanup
Remove-Item -Recurse -Force $tempDir

# Final result
Write-Host "============================================================" -ForegroundColor Cyan
if ($allPassed) {
    Write-Host "  ? Package Verification: PASSED" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Your package is ready to publish!" -ForegroundColor Green
    Write-Host ""
    Write-Host "README.md and LICENSE.txt are properly included." -ForegroundColor White
    Write-Host "They will be displayed on NuGet.org after publishing." -ForegroundColor White
    Write-Host ""
    Write-Host "To publish:" -ForegroundColor Yellow
    Write-Host "   nuget push $($nupkgFile.Name) -Source https://api.nuget.org/v3/index.json -ApiKey YOUR_KEY" -ForegroundColor White
    Write-Host ""
    Write-Host "Or use:" -ForegroundColor Yellow
    Write-Host "   .\BuildAndPublish-NuGet.ps1" -ForegroundColor White
} else {
    Write-Host "  ? Package Verification: FAILED" -ForegroundColor Red
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Some required files are missing!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Rebuild the package:" -ForegroundColor Yellow
    Write-Host "   .\BuildNuGetPackage.bat" -ForegroundColor White
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
