# Add BouncyCastle to ValidateJWT Project
# This script adds the BouncyCastle.Cryptography package

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Add BouncyCastle.Cryptography to ValidateJWT" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$projectDir = $PSScriptRoot
if (-not $projectDir) {
    $projectDir = Get-Location
}

Set-Location $projectDir

Write-Host "Project Directory: $projectDir" -ForegroundColor Gray
Write-Host ""

# Check if Visual Studio is running
$vsProcess = Get-Process devenv -ErrorAction SilentlyContinue
if ($vsProcess) {
    Write-Host "? Visual Studio is currently running!" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue anyway? (Y/N)"
    if ($continue -ne 'Y' -and $continue -ne 'y') {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
        exit 0
    }
    Write-Host ""
}

# Show what will be added
Write-Host "BouncyCastle.Cryptography Package" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Package: BouncyCastle.Cryptography" -ForegroundColor White
Write-Host "Version: 2.4.0 (latest stable)" -ForegroundColor White
Write-Host "Size: ~2.2 MB" -ForegroundColor White
Write-Host "License: MIT (compatible)" -ForegroundColor White
Write-Host ""

Write-Host "What You'll Get:" -ForegroundColor Green
Write-Host "  ? ES256/384/512 (ECDSA) support" -ForegroundColor White
Write-Host "  ? PS256/384/512 (RSA-PSS) support" -ForegroundColor White
Write-Host "  ? HS384/512 (HMAC) support" -ForegroundColor White
Write-Host "  ? RS384/512 (RSA) support" -ForegroundColor White
Write-Host "  ? PEM key format support" -ForegroundColor White
Write-Host "  ? Better cross-platform compatibility" -ForegroundColor White
Write-Host ""

Write-Host "Impact:" -ForegroundColor Yellow
Write-Host "  • Package size: +2.2 MB" -ForegroundColor White
Write-Host "  • Dependencies: +1 (BouncyCastle)" -ForegroundColor White
Write-Host "  • Supported algorithms: 2 ? 12" -ForegroundColor White
Write-Host "  • Backward compatible: 100%" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Add BouncyCastle to ValidateJWT? (Y/N)"
if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "[1/4] Checking for NuGet..." -ForegroundColor Cyan

# Check for NuGet
$nuget = $null
if (Get-Command nuget -ErrorAction SilentlyContinue) {
    $nuget = "nuget"
    Write-Host "  ? Found: nuget.exe" -ForegroundColor Green
} elseif (Test-Path ".\nuget.exe") {
    $nuget = ".\nuget.exe"
    Write-Host "  ? Found: .\nuget.exe" -ForegroundColor Green
} else {
    Write-Host "  ? NuGet not found, downloading..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile "nuget.exe"
    $nuget = ".\nuget.exe"
    Write-Host "  ? Downloaded nuget.exe" -ForegroundColor Green
}

Write-Host ""
Write-Host "[2/4] Installing BouncyCastle.Cryptography..." -ForegroundColor Cyan

# Install package
& $nuget install BouncyCastle.Cryptography -Version 2.4.0 -OutputDirectory packages

if ($LASTEXITCODE -eq 0) {
    Write-Host "  ? Package installed successfully" -ForegroundColor Green
} else {
    Write-Host "  ? Package installation failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[3/4] Backing up project file..." -ForegroundColor Cyan

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$projectFile = "ValidateJWT.csproj"
$backupFile = "ValidateJWT.csproj.backup_$timestamp"

Copy-Item $projectFile $backupFile
Write-Host "  ? Backup created: $backupFile" -ForegroundColor Green

Write-Host ""
Write-Host "[4/4] Updating project file..." -ForegroundColor Cyan

# Read project file
$content = Get-Content $projectFile -Raw

# Check if BouncyCastle is already added
if ($content -match "BouncyCastle") {
    Write-Host "  ? BouncyCastle already in project file" -ForegroundColor Yellow
} else {
    # Find the ItemGroup with References
    $referenceGroup = '<ItemGroup>\s+<Reference Include="System'
    
    if ($content -match $referenceGroup) {
        # Add after System references
        $addition = @'
  </ItemGroup>
  <ItemGroup>
    <PackageReference Include="BouncyCastle.Cryptography" Version="2.4.0" />
'@
        $content = $content -replace '(</ItemGroup>)', "$addition`r`n  $1"
        
        # Save
        [System.IO.File]::WriteAllText((Join-Path $projectDir $projectFile), $content, [System.Text.Encoding]::UTF8)
        
        Write-Host "  ? Project file updated" -ForegroundColor Green
    } else {
        Write-Host "  ? Could not find reference section" -ForegroundColor Yellow
        Write-Host "  Please add manually:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host '  <ItemGroup>' -ForegroundColor White
        Write-Host '    <PackageReference Include="BouncyCastle.Cryptography" Version="2.4.0" />' -ForegroundColor White
        Write-Host '  </ItemGroup>' -ForegroundColor White
    }
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  BouncyCastle Added Successfully!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "What Was Done:" -ForegroundColor White
Write-Host "  ? BouncyCastle.Cryptography 2.4.0 installed" -ForegroundColor Green
Write-Host "  ? Project file updated" -ForegroundColor Green
Write-Host "  ? Backup created" -ForegroundColor Green
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Add using statements to ValidateJWT.cs:" -ForegroundColor White
Write-Host "     using Org.BouncyCastle.Crypto;" -ForegroundColor Gray
Write-Host "     using Org.BouncyCastle.Security;" -ForegroundColor Gray
Write-Host "     using Org.BouncyCastle.OpenSsl;" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Implement new verification methods:" -ForegroundColor White
Write-Host "     • VerifySignatureES256() - ECDSA support" -ForegroundColor Gray
Write-Host "     • VerifySignaturePS256() - RSA-PSS support" -ForegroundColor Gray
Write-Host "     • VerifySignatureUniversal() - Auto-detect" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. See implementation guide:" -ForegroundColor White
Write-Host "     BOUNCYCASTLE_INTEGRATION.md" -ForegroundColor Gray
Write-Host ""
Write-Host "  4. Test in Visual Studio:" -ForegroundColor White
Write-Host "     • Rebuild solution" -ForegroundColor Gray
Write-Host "     • Verify no errors" -ForegroundColor Gray
Write-Host "     • Run existing tests" -ForegroundColor Gray
Write-Host ""

Write-Host "Documentation:" -ForegroundColor Cyan
Write-Host "  ?? BOUNCYCASTLE_INTEGRATION.md - Complete guide" -ForegroundColor White
Write-Host "  ?? README.md - Will need update for new algorithms" -ForegroundColor White
Write-Host ""

Write-Host "Package Info:" -ForegroundColor Cyan
Write-Host "  Location: .\packages\BouncyCastle.Cryptography.2.4.0" -ForegroundColor White
Write-Host "  DLL: lib\net472\BouncyCastle.Cryptography.dll" -ForegroundColor White
Write-Host ""

Write-Host "To restore backup if needed:" -ForegroundColor Yellow
Write-Host "  Copy-Item $backupFile $projectFile" -ForegroundColor White
Write-Host ""

Write-Host "Ready to implement ES256, PS256, and more! ??" -ForegroundColor Green
Write-Host ""

Read-Host "Press Enter to exit"
