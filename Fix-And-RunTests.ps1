# Fix Build and Run Tests Script for ValidateJWT
# This script adds System.Xml reference and runs all tests

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ValidateJWT - Fix Build and Run Tests" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$projectDir = $PSScriptRoot
if (-not $projectDir) {
    $projectDir = Get-Location
}

Set-Location $projectDir

# Check if Visual Studio is running
Write-Host "Checking Visual Studio status..." -ForegroundColor Cyan
$vsProcess = Get-Process devenv -ErrorAction SilentlyContinue
if ($vsProcess) {
    Write-Host "? Visual Studio is currently running!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please close Visual Studio and press Enter to continue..." -ForegroundColor Yellow
    Read-Host
    Write-Host ""
}

Write-Host "[1/5] Adding System.Xml reference..." -ForegroundColor Cyan

$projectFile = "ValidateJWT.csproj"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "ValidateJWT.csproj.backup_$timestamp"

# Backup
Copy-Item $projectFile $backupFile
Write-Host "  ? Backup created: $backupFile" -ForegroundColor Green

# Read and update
$content = Get-Content $projectFile -Raw

if ($content -match "System\.Xml") {
    Write-Host "  ? System.Xml already present" -ForegroundColor Yellow
} else {
    # Add System.Xml after System.Runtime.Serialization
    $content = $content -replace '(<Reference Include="System\.Runtime\.Serialization" />)', "`$1`r`n    <Reference Include=`"System.Xml`" />"
    
    [System.IO.File]::WriteAllText((Join-Path $projectDir $projectFile), $content, [System.Text.Encoding]::UTF8)
    
    Write-Host "  ? System.Xml reference added" -ForegroundColor Green
}

Write-Host ""
Write-Host "[2/5] Cleaning build artifacts..." -ForegroundColor Cyan

Remove-Item -Path "bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "obj" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "ValidateJWT.Tests\bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "ValidateJWT.Tests\obj" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "  ? Build artifacts cleaned" -ForegroundColor Green

Write-Host ""
Write-Host "[3/5] Building ValidateJWT..." -ForegroundColor Cyan

# Find MSBuild
$msbuild = $null
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

if (Test-Path $vswhere) {
    $vsPath = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild -property installationPath
    if ($vsPath) {
        $msbuild = Join-Path $vsPath "MSBuild\Current\Bin\MSBuild.exe"
        if (-not (Test-Path $msbuild)) {
            $msbuild = Join-Path $vsPath "MSBuild\15.0\Bin\MSBuild.exe"
        }
    }
}

if (-not $msbuild -or -not (Test-Path $msbuild)) {
    if (Get-Command msbuild -ErrorAction SilentlyContinue) {
        $msbuild = "msbuild"
    }
}

if (-not $msbuild) {
    Write-Host "  ? MSBuild not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please build the solution in Visual Studio:" -ForegroundColor Yellow
    Write-Host "  1. Open ValidateJWT.sln" -ForegroundColor White
    Write-Host "  2. Build -> Rebuild Solution" -ForegroundColor White
    Write-Host "  3. Test -> Run All Tests" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "  Using MSBuild: $msbuild" -ForegroundColor Gray

# Build solution
& $msbuild "ValidateJWT.sln" /t:Rebuild /p:Configuration=Debug /v:minimal /nologo

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "  ? Build failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check build errors above." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "  ? Build successful!" -ForegroundColor Green

Write-Host ""
Write-Host "[4/5] Verifying test assembly..." -ForegroundColor Cyan

$testDll = "ValidateJWT.Tests\bin\Debug\ValidateJWT.Tests.dll"
if (Test-Path $testDll) {
    Write-Host "  ? Test assembly found: $testDll" -ForegroundColor Green
} else {
    Write-Host "  ? Test assembly not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Expected location: $testDll" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "[5/5] Running tests..." -ForegroundColor Cyan
Write-Host ""

# Try VSTest first
$vstest = $null
if (Test-Path $vswhere) {
    $vsPath = & $vswhere -latest -products * -property installationPath
    if ($vsPath) {
        $vstestPath = Join-Path $vsPath "Common7\IDE\Extensions\TestPlatform\vstest.console.exe"
        if (Test-Path $vstestPath) {
            $vstest = $vstestPath
        }
    }
}

if (-not $vstest) {
    # Try common locations
    $commonPaths = @(
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\Extensions\TestPlatform\vstest.console.exe",
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Professional\Common7\IDE\Extensions\TestPlatform\vstest.console.exe",
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community\Common7\IDE\Extensions\TestPlatform\vstest.console.exe",
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\Extensions\TestPlatform\vstest.console.exe",
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Professional\Common7\IDE\Extensions\TestPlatform\vstest.console.exe",
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\Common7\IDE\Extensions\TestPlatform\vstest.console.exe"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            $vstest = $path
            break
        }
    }
}

if ($vstest) {
    Write-Host "Using VSTest: $vstest" -ForegroundColor Gray
    Write-Host ""
    
    & $vstest $testDll /logger:console
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "============================================================" -ForegroundColor Green
        Write-Host "  ? All Tests Passed!" -ForegroundColor Green
        Write-Host "============================================================" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "============================================================" -ForegroundColor Yellow
        Write-Host "  ? Some Tests Failed" -ForegroundColor Yellow
        Write-Host "============================================================" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "See test results above for details." -ForegroundColor White
    }
} else {
    Write-Host "VSTest not found. Using MSTest instead..." -ForegroundColor Yellow
    Write-Host ""
    
    # Try MSTest
    $mstest = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\TestAgent\Common7\IDE\MSTest.exe"
    if (-not (Test-Path $mstest)) {
        $mstest = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Professional\Common7\IDE\MSTest.exe"
    }
    if (-not (Test-Path $mstest)) {
        $mstest = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\Common7\IDE\MSTest.exe"
    }
    
    if (Test-Path $mstest) {
        & $mstest /testcontainer:$testDll
    } else {
        Write-Host "============================================================" -ForegroundColor Yellow
        Write-Host "  Test runner not found automatically" -ForegroundColor Yellow
        Write-Host "============================================================" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Build succeeded! Test assembly is ready." -ForegroundColor Green
        Write-Host ""
        Write-Host "To run tests manually:" -ForegroundColor Cyan
        Write-Host "  1. Open ValidateJWT.sln in Visual Studio" -ForegroundColor White
        Write-Host "  2. Test -> Test Explorer" -ForegroundColor White
        Write-Host "  3. Click 'Run All'" -ForegroundColor White
        Write-Host ""
        Write-Host "Test assembly location:" -ForegroundColor Cyan
        Write-Host "  $testDll" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  ? System.Xml reference added" -ForegroundColor Green
Write-Host "  ? Solution built successfully" -ForegroundColor Green
Write-Host "  ? Test assembly generated" -ForegroundColor Green
Write-Host ""

if ($vstest -or (Test-Path $mstest)) {
    Write-Host "Test files:" -ForegroundColor Cyan
    Write-Host "  - ValidateJWTTests.cs (40 tests)" -ForegroundColor White
    Write-Host "  - Base64UrlDecodeTests.cs (18 tests)" -ForegroundColor White
    Write-Host "  Total: 58+ tests" -ForegroundColor White
}

Write-Host ""
Read-Host "Press Enter to exit"
