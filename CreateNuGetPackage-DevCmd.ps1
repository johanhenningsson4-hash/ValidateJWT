# NuGet Package Creation Script - Uses Developer Command Prompt Environment
# Run this from Developer Command Prompt for Visual Studio

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  ValidateJWT - NuGet Package Builder (DevCmd)" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

$projectDir = "C:\Jobb\ValidateJWT"
Set-Location $projectDir

# Step 1: Clean previous builds
Write-Host "[Step 1/4] Cleaning previous builds..." -ForegroundColor Cyan
if (Test-Path "bin\Release") {
    Remove-Item -Recurse -Force "bin\Release"
}
if (Test-Path "obj") {
    Remove-Item -Recurse -Force "obj"
}
if (Test-Path "*.nupkg") {
    Remove-Item -Force "*.nupkg"
}
Write-Host "? Cleaned" -ForegroundColor Green
Write-Host ""

# Step 2: Check for MSBuild via environment
Write-Host "[Step 2/4] Checking build environment..." -ForegroundColor Cyan

# Check if we're in Developer Command Prompt
if ($env:VSINSTALLDIR) {
    Write-Host "  ? Running in Developer Command Prompt" -ForegroundColor Green
    Write-Host "  ?? VS Install Dir: $env:VSINSTALLDIR" -ForegroundColor Gray
    $msbuild = "msbuild"
} else {
    Write-Host "  ??  Not running in Developer Command Prompt" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Opening Developer Command Prompt automatically..." -ForegroundColor Cyan
    Write-Host ""
    
    # Create a batch file to run from Developer Command Prompt
    $batchScript = @"
@echo off
cd /d "$projectDir"
msbuild ValidateJWT.csproj /p:Configuration=Release /p:DocumentationFile=bin\Release\ValidateJWT.xml /v:minimal /nologo
if errorlevel 1 (
    echo Build failed!
    pause
    exit /b 1
)
echo Build successful!
"@
    
    Set-Content -Path "build-release.bat" -Value $batchScript
    
    Write-Host "Instructions:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1??  Open 'Developer Command Prompt for VS' from Start Menu" -ForegroundColor White
    Write-Host ""
    Write-Host "2??  Run these commands:" -ForegroundColor White
    Write-Host "   cd $projectDir" -ForegroundColor Cyan
    Write-Host "   .\build-release.bat" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "3??  After successful build, run:" -ForegroundColor White
    Write-Host "   nuget pack ValidateJWT.nuspec" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "OR use Visual Studio:" -ForegroundColor Yellow
    Write-Host "   • Open ValidateJWT.sln" -ForegroundColor White
    Write-Host "   • Set Configuration to Release" -ForegroundColor White
    Write-Host "   • Build > Build Solution" -ForegroundColor White
    Write-Host "   • Then run: nuget pack ValidateJWT.nuspec" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
Write-Host ""

# Step 3: Build in Release mode
Write-Host "[Step 3/4] Building project in Release mode..." -ForegroundColor Cyan
Write-Host "  Using: msbuild (from Developer Command Prompt)" -ForegroundColor Gray

msbuild ValidateJWT.csproj /p:Configuration=Release /p:DocumentationFile=bin\Release\ValidateJWT.xml /v:minimal /nologo

if ($LASTEXITCODE -ne 0) {
    Write-Host "? Build failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
Write-Host "? Build successful" -ForegroundColor Green
Write-Host ""

# Verify output files
Write-Host "Verifying output files..." -ForegroundColor Cyan
$requiredFiles = @(
    "bin\Release\ValidateJWT.dll",
    "bin\Release\ValidateJWT.xml"
)

$allExist = $true
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        $fileInfo = Get-Item $file
        Write-Host "  ? $file ($([math]::Round($fileInfo.Length / 1KB, 2)) KB)" -ForegroundColor Green
    } else {
        Write-Host "  ? Missing: $file" -ForegroundColor Red
        $allExist = $false
    }
}

if (-not $allExist) {
    Write-Host "? Some required files are missing!" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 4: Create NuGet package
Write-Host "[Step 4/4] Creating NuGet package..." -ForegroundColor Cyan

# Check for nuget
$nuget = $null
if (Get-Command nuget -ErrorAction SilentlyContinue) {
    $nuget = "nuget"
} elseif (Test-Path ".\nuget.exe") {
    $nuget = ".\nuget.exe"
} else {
    Write-Host "  ??  Downloading nuget.exe..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile "nuget.exe"
    $nuget = ".\nuget.exe"
}

Write-Host "  Creating package..." -ForegroundColor Gray
& $nuget pack ValidateJWT.nuspec -OutputDirectory .

if ($LASTEXITCODE -ne 0) {
    Write-Host "? NuGet pack failed!" -ForegroundColor Red
    exit 1
}

$nupkgFile = Get-ChildItem -Filter "ValidateJWT.*.nupkg" | Select-Object -First 1

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  ? NuGet Package Created Successfully!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

if ($nupkgFile) {
    Write-Host "?? Package Details:" -ForegroundColor Yellow
    Write-Host "  Name: $($nupkgFile.Name)" -ForegroundColor White
    Write-Host "  Size: $([math]::Round($nupkgFile.Length / 1KB, 2)) KB" -ForegroundColor White
    Write-Host "  Path: $($nupkgFile.FullName)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "?? Next Steps:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Test locally:" -ForegroundColor Cyan
    Write-Host "  nuget add $($nupkgFile.Name) -source C:\LocalNuGetFeed" -ForegroundColor White
    Write-Host ""
    Write-Host "Publish to NuGet.org:" -ForegroundColor Cyan
    Write-Host "  nuget push $($nupkgFile.Name) -Source https://api.nuget.org/v3/index.json -ApiKey YOUR_KEY" -ForegroundColor White
    Write-Host ""
}

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
