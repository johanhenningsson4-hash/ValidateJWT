# NuGet Package Creation Script for ValidateJWT
# Builds the project in Release mode and creates a NuGet package

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  ValidateJWT - NuGet Package Builder" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

$projectDir = "C:\Jobb\ValidateJWT"
Set-Location $projectDir

# Step 1: Clean previous builds
Write-Host "[Step 1/5] Cleaning previous builds..." -ForegroundColor Cyan
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

# Step 2: Find MSBuild
Write-Host "[Step 2/5] Locating MSBuild..." -ForegroundColor Cyan

function Find-MSBuild {
    # Try common Visual Studio 2022 locations
    $vs2022Paths = @(
        "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe",
        "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe",
        "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
    )
    
    foreach ($path in $vs2022Paths) {
        if (Test-Path $path) {
            Write-Host "  ? Found MSBuild (VS 2022): $path" -ForegroundColor Green
            return $path
        }
    }
    
    # Try Visual Studio 2019 locations
    $vs2019Paths = @(
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
    )
    
    foreach ($path in $vs2019Paths) {
        if (Test-Path $path) {
            Write-Host "  ? Found MSBuild (VS 2019): $path" -ForegroundColor Green
            return $path
        }
    }
    
    # Try Build Tools locations
    $buildToolsPaths = @(
        "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
    )
    
    foreach ($path in $buildToolsPaths) {
        if (Test-Path $path) {
            Write-Host "  ? Found MSBuild (Build Tools): $path" -ForegroundColor Green
            return $path
        }
    }
    
    # Try using vswhere (installed with VS 2017+)
    $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (Test-Path $vswhere) {
        $vsPath = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild -property installationPath
        if ($vsPath) {
            $msbuildPath = Join-Path $vsPath "MSBuild\Current\Bin\MSBuild.exe"
            if (Test-Path $msbuildPath) {
                Write-Host "  ? Found MSBuild via vswhere: $msbuildPath" -ForegroundColor Green
                return $msbuildPath
            }
        }
    }
    
    # Check if msbuild is in PATH
    try {
        $msbuildInPath = Get-Command msbuild -ErrorAction SilentlyContinue
        if ($msbuildInPath) {
            Write-Host "  ? Found MSBuild in PATH: $($msbuildInPath.Source)" -ForegroundColor Green
            return "msbuild"
        }
    } catch {}
    
    return $null
}

$msbuild = Find-MSBuild

if (-not $msbuild) {
    Write-Host "  ? MSBuild not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Solutions:" -ForegroundColor Yellow
    Write-Host "  1. Install Visual Studio 2019 or 2022" -ForegroundColor White
    Write-Host "     Download: https://visualstudio.microsoft.com/downloads/" -ForegroundColor White
    Write-Host ""
    Write-Host "  2. Or install Build Tools for Visual Studio" -ForegroundColor White
    Write-Host "     Download: https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022" -ForegroundColor White
    Write-Host ""
    Write-Host "  3. Or build manually in Visual Studio:" -ForegroundColor White
    Write-Host "     - Open ValidateJWT.sln" -ForegroundColor White
    Write-Host "     - Set Configuration to Release" -ForegroundColor White
    Write-Host "     - Build > Build Solution" -ForegroundColor White
    Write-Host "     - Then run this part of the script:" -ForegroundColor White
    Write-Host "       nuget pack ValidateJWT.nuspec" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
Write-Host ""

# Step 3: Build in Release mode
Write-Host "[Step 3/5] Building project in Release mode..." -ForegroundColor Cyan
Write-Host "  Using: $msbuild" -ForegroundColor Gray

& $msbuild ValidateJWT.csproj /p:Configuration=Release /p:DocumentationFile=bin\Release\ValidateJWT.xml /v:minimal /nologo

if ($LASTEXITCODE -ne 0) {
    Write-Host "? Build failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Try building in Visual Studio first:" -ForegroundColor Yellow
    Write-Host "  1. Open ValidateJWT.sln" -ForegroundColor White
    Write-Host "  2. Configuration Manager > Release" -ForegroundColor White
    Write-Host "  3. Build > Build Solution" -ForegroundColor White
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
Write-Host "? Build successful" -ForegroundColor Green
Write-Host ""

# Step 4: Verify output files
Write-Host "[Step 4/5] Verifying output files..." -ForegroundColor Cyan
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
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
Write-Host ""

# Step 5: Check for NuGet and create package
Write-Host "[Step 5/5] Creating NuGet package..." -ForegroundColor Cyan
$nuget = $null
if (Get-Command nuget -ErrorAction SilentlyContinue) {
    $nuget = "nuget"
    Write-Host "  ? Found nuget in PATH" -ForegroundColor Green
} elseif (Test-Path ".\nuget.exe") {
    $nuget = ".\nuget.exe"
    Write-Host "  ? Found nuget.exe in current directory" -ForegroundColor Green
} else {
    Write-Host "  ??  NuGet not found. Downloading..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile "nuget.exe"
        $nuget = ".\nuget.exe"
        Write-Host "  ? Downloaded nuget.exe" -ForegroundColor Green
    } catch {
        Write-Host "  ? Failed to download nuget.exe" -ForegroundColor Red
        Write-Host "  Download manually from: https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
}
Write-Host ""

Write-Host "  Creating package..." -ForegroundColor Gray
& $nuget pack ValidateJWT.nuspec -OutputDirectory .

if ($LASTEXITCODE -ne 0) {
    Write-Host "? NuGet pack failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

$nupkgFile = Get-ChildItem -Filter "ValidateJWT.*.nupkg" | Select-Object -First 1

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  ? NuGet Package Created Successfully!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

if ($nupkgFile) {
    Write-Host "Package Details:" -ForegroundColor Yellow
    Write-Host "  ?? Name: $($nupkgFile.Name)" -ForegroundColor White
    Write-Host "  ?? Location: $($nupkgFile.FullName)" -ForegroundColor White
    Write-Host "  ?? Size: $([math]::Round($nupkgFile.Length / 1KB, 2)) KB" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1??  Test the package locally:" -ForegroundColor Cyan
    Write-Host "   nuget add $($nupkgFile.Name) -source C:\LocalNuGetFeed" -ForegroundColor White
    Write-Host ""
    Write-Host "2??  Publish to NuGet.org:" -ForegroundColor Cyan
    Write-Host "   nuget push $($nupkgFile.Name) -Source https://api.nuget.org/v3/index.json -ApiKey YOUR_API_KEY" -ForegroundColor White
    Write-Host ""
    Write-Host "3??  Or publish to a private feed:" -ForegroundColor Cyan
    Write-Host "   nuget push $($nupkgFile.Name) -Source YOUR_FEED_URL -ApiKey YOUR_API_KEY" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Package Contents:" -ForegroundColor Yellow
    Write-Host "  • ValidateJWT.dll (lib\net472)" -ForegroundColor White
    Write-Host "  • ValidateJWT.xml (XML documentation)" -ForegroundColor White
    Write-Host "  • ValidateJWT.pdb (debug symbols)" -ForegroundColor White
    Write-Host "  • README.md" -ForegroundColor White
    Write-Host "  • LICENSE.txt" -ForegroundColor White
    Write-Host ""
}

Write-Host "To get a NuGet API key:" -ForegroundColor Yellow
Write-Host "  1. Go to https://www.nuget.org/" -ForegroundColor White
Write-Host "  2. Sign in or create an account" -ForegroundColor White
Write-Host "  3. Go to Account Settings > API Keys" -ForegroundColor White
Write-Host "  4. Create new API key with 'Push' permission" -ForegroundColor White
Write-Host ""

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
