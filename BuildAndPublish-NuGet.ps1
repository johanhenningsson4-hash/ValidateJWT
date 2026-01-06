# Complete NuGet Package Builder and Publisher
# Uses NUGET_API_KEY environment variable for automatic publishing

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ValidateJWT - Build & Publish NuGet Package" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$projectDir = "C:\Jobb\ValidateJWT"
Set-Location $projectDir

# Check for API key
$apiKey = $env:NUGET_API_KEY
$hasApiKey = -not [string]::IsNullOrWhiteSpace($apiKey)

if ($hasApiKey) {
    Write-Host "? NUGET_API_KEY found in environment" -ForegroundColor Green
    Write-Host "   Package will be published automatically after build" -ForegroundColor Gray
} else {
    Write-Host "??  NUGET_API_KEY not found in environment" -ForegroundColor Yellow
    Write-Host "   Package will be created but not published" -ForegroundColor Gray
    Write-Host ""
    Write-Host "To set API key for this session:" -ForegroundColor Cyan
    Write-Host '   $env:NUGET_API_KEY = "your-api-key-here"' -ForegroundColor White
    Write-Host ""
    Write-Host "To set permanently (Windows):" -ForegroundColor Cyan
    Write-Host '   setx NUGET_API_KEY "your-api-key-here"' -ForegroundColor White
    Write-Host ""
}

# Step 1: Clean
Write-Host "[Step 1/5] Cleaning previous builds..." -ForegroundColor Cyan
if (Test-Path "bin\Release") { Remove-Item -Recurse -Force "bin\Release" }
if (Test-Path "obj") { Remove-Item -Recurse -Force "obj" }
if (Test-Path "*.nupkg") { Remove-Item -Force "*.nupkg" }
Write-Host "   ? Cleaned" -ForegroundColor Green
Write-Host ""

# Step 2: Find MSBuild
Write-Host "[Step 2/5] Locating MSBuild..." -ForegroundColor Cyan

function Find-MSBuild {
    # Check if in Developer Command Prompt
    if ($env:VSINSTALLDIR) {
        $devCmdMSBuild = Join-Path $env:VSINSTALLDIR "MSBuild\Current\Bin\MSBuild.exe"
        if (Test-Path $devCmdMSBuild) {
            return $devCmdMSBuild
        }
        return "msbuild"  # Should be in PATH when in Dev Cmd
    }
    
    # Search common VS locations
    $paths = @(
        "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe",
        "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe",
        "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe"
    )
    
    foreach ($path in $paths) {
        if (Test-Path $path) { return $path }
    }
    
    # Try vswhere
    $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (Test-Path $vswhere) {
        $vsPath = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild -property installationPath
        if ($vsPath) {
            $msbuildPath = Join-Path $vsPath "MSBuild\Current\Bin\MSBuild.exe"
            if (Test-Path $msbuildPath) { return $msbuildPath }
        }
    }
    
    # Check PATH
    if (Get-Command msbuild -ErrorAction SilentlyContinue) { return "msbuild" }
    
    return $null
}

$msbuild = Find-MSBuild
if (-not $msbuild) {
    Write-Host "   ? MSBuild not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Run from Developer Command Prompt or double-click BuildNuGetPackage.bat" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
Write-Host "   ? Found: $msbuild" -ForegroundColor Green
Write-Host ""

# Step 3: Build
Write-Host "[Step 3/5] Building in Release mode..." -ForegroundColor Cyan
& $msbuild ValidateJWT.csproj /p:Configuration=Release /p:DocumentationFile=bin\Release\ValidateJWT.xml /v:minimal /nologo

if ($LASTEXITCODE -ne 0) {
    Write-Host "   ? Build failed!" -ForegroundColor Red
    exit 1
}

# Verify output
if (-not (Test-Path "bin\Release\ValidateJWT.dll")) {
    Write-Host "   ? ValidateJWT.dll not found!" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path "bin\Release\ValidateJWT.xml")) {
    Write-Host "   ? ValidateJWT.xml not found!" -ForegroundColor Red
    exit 1
}

$dllSize = [math]::Round((Get-Item "bin\Release\ValidateJWT.dll").Length / 1KB, 2)
Write-Host "   ? Build successful" -ForegroundColor Green
Write-Host "      ValidateJWT.dll: $dllSize KB" -ForegroundColor Gray
Write-Host ""

# Step 4: Get NuGet
Write-Host "[Step 4/5] Preparing NuGet..." -ForegroundColor Cyan
$nuget = $null
if (Get-Command nuget -ErrorAction SilentlyContinue) {
    $nuget = "nuget"
} elseif (Test-Path ".\nuget.exe") {
    $nuget = ".\nuget.exe"
} else {
    Write-Host "   Downloading nuget.exe..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile "nuget.exe"
    $nuget = ".\nuget.exe"
}
Write-Host "   ? NuGet ready" -ForegroundColor Green
Write-Host ""

# Step 5: Create Package
Write-Host "[Step 5/5] Creating NuGet package..." -ForegroundColor Cyan
& $nuget pack ValidateJWT.nuspec -OutputDirectory .

if ($LASTEXITCODE -ne 0) {
    Write-Host "   ? Pack failed!" -ForegroundColor Red
    exit 1
}

$nupkgFile = Get-ChildItem -Filter "ValidateJWT.*.nupkg" | Select-Object -First 1
if (-not $nupkgFile) {
    Write-Host "   ? .nupkg file not found!" -ForegroundColor Red
    exit 1
}

$pkgSize = [math]::Round($nupkgFile.Length / 1KB, 2)
Write-Host "   ? Package created: $($nupkgFile.Name) ($pkgSize KB)" -ForegroundColor Green
Write-Host ""

# Step 6: Publish (if API key available)
if ($hasApiKey) {
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  Publishing to NuGet.org..." -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Package: $($nupkgFile.Name)" -ForegroundColor White
    Write-Host "Target: https://api.nuget.org/v3/index.json" -ForegroundColor White
    Write-Host ""
    
    $publishConfirm = Read-Host "Publish now? (Y/N)"
    
    if ($publishConfirm -eq 'Y' -or $publishConfirm -eq 'y') {
        Write-Host ""
        Write-Host "Publishing..." -ForegroundColor Cyan
        
        & $nuget push $nupkgFile.Name -Source https://api.nuget.org/v3/index.json -ApiKey $env:NUGET_API_KEY
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "============================================================" -ForegroundColor Cyan
            Write-Host "  ? SUCCESS! Package Published to NuGet.org" -ForegroundColor Green
            Write-Host "============================================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "?? Package: $($nupkgFile.Name)" -ForegroundColor White
            Write-Host "?? URL: https://www.nuget.org/packages/ValidateJWT" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "? Indexing: Package will be available in ~15 minutes" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "?? You will receive an email confirmation" -ForegroundColor Gray
            Write-Host ""
            Write-Host "Install Command:" -ForegroundColor Yellow
            Write-Host "   Install-Package ValidateJWT" -ForegroundColor White
            Write-Host ""
        } else {
            Write-Host ""
            Write-Host "============================================================" -ForegroundColor Red
            Write-Host "  ? Publish Failed!" -ForegroundColor Red
            Write-Host "============================================================" -ForegroundColor Red
            Write-Host ""
            Write-Host "Common issues:" -ForegroundColor Yellow
            Write-Host "  • Invalid API key" -ForegroundColor White
            Write-Host "  • Package version already exists" -ForegroundColor White
            Write-Host "  • Network/connection issues" -ForegroundColor White
            Write-Host ""
            Write-Host "To retry manually:" -ForegroundColor Cyan
            Write-Host "   nuget push $($nupkgFile.Name) -Source https://api.nuget.org/v3/index.json -ApiKey YOUR_KEY" -ForegroundColor White
            Write-Host ""
        }
    } else {
        Write-Host ""
        Write-Host "Publishing skipped." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "To publish manually:" -ForegroundColor Cyan
        Write-Host "   nuget push $($nupkgFile.Name) -Source https://api.nuget.org/v3/index.json -ApiKey YOUR_KEY" -ForegroundColor White
        Write-Host ""
    }
} else {
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  ? Package Created Successfully" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "?? Package: $($nupkgFile.Name) ($pkgSize KB)" -ForegroundColor White
    Write-Host "?? Location: $($nupkgFile.FullName)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1??  Set NUGET_API_KEY environment variable:" -ForegroundColor Cyan
    Write-Host "   PowerShell session:" -ForegroundColor Gray
    Write-Host '      $env:NUGET_API_KEY = "your-api-key"' -ForegroundColor White
    Write-Host "   Permanent (Command Prompt):" -ForegroundColor Gray
    Write-Host '      setx NUGET_API_KEY "your-api-key"' -ForegroundColor White
    Write-Host ""
    Write-Host "2??  Get API key from:" -ForegroundColor Cyan
    Write-Host "   https://www.nuget.org/ > Account Settings > API Keys" -ForegroundColor White
    Write-Host ""
    Write-Host "3??  Run this script again to publish" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Or publish manually:" -ForegroundColor Yellow
    Write-Host "   nuget push $($nupkgFile.Name) -Source https://api.nuget.org/v3/index.json -ApiKey YOUR_KEY" -ForegroundColor White
    Write-Host ""
    Write-Host "Test locally first:" -ForegroundColor Yellow
    Write-Host "   mkdir C:\LocalNuGetFeed" -ForegroundColor White
    Write-Host "   nuget add $($nupkgFile.Name) -source C:\LocalNuGetFeed" -ForegroundColor White
    Write-Host ""
}

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
