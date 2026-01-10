# Automated Test Runner Script
# Runs all tests and generates reports

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Debug",
    
    [Parameter(Mandatory=$false)]
    [switch]$GenerateCoverage,
    
    [Parameter(Mandatory=$false)]
    [switch]$OpenReport
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ValidateJWT - Automated Test Runner" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = $PSScriptRoot
if (-not $projectRoot) {
    $projectRoot = Get-Location
}

Set-Location $projectRoot

# Configuration
$testDll = "ValidateJWT.Tests\bin\$Configuration\ValidateJWT.Tests.dll"
$resultsDir = "TestResults"
$coverageFile = "coverage.cobertura.xml"

Write-Host "[1/6] Checking Prerequisites..." -ForegroundColor Cyan

# Check for MSBuild
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
    } else {
        Write-Host "  ? MSBuild not found!" -ForegroundColor Red
        exit 1
    }
}

Write-Host "  ? MSBuild found: $msbuild" -ForegroundColor Green

# Check for VSTest
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
    Write-Host "  ? VSTest not found, will try alternative methods" -ForegroundColor Yellow
} else {
    Write-Host "  ? VSTest found" -ForegroundColor Green
}

Write-Host ""
Write-Host "[2/6] Cleaning Previous Results..." -ForegroundColor Cyan

Remove-Item -Path $resultsDir -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path $coverageFile -Force -ErrorAction SilentlyContinue
Remove-Item -Path "bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "obj" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "ValidateJWT.Tests\bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "ValidateJWT.Tests\obj" -Recurse -Force -ErrorAction SilentlyContinue

New-Item -ItemType Directory -Force -Path $resultsDir | Out-Null

Write-Host "  ? Cleaned" -ForegroundColor Green

Write-Host ""
Write-Host "[3/6] Restoring NuGet Packages..." -ForegroundColor Cyan

# Find or download nuget.exe
$nuget = $null
if (Get-Command nuget -ErrorAction SilentlyContinue) {
    $nuget = "nuget"
} elseif (Test-Path ".\nuget.exe") {
    $nuget = ".\nuget.exe"
} else {
    Write-Host "  Downloading NuGet.exe..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile "nuget.exe"
    $nuget = ".\nuget.exe"
}

& $nuget restore ValidateJWT.sln -NonInteractive

Write-Host "  ? Packages restored" -ForegroundColor Green

Write-Host ""
Write-Host "[4/6] Building Solution ($Configuration)..." -ForegroundColor Cyan

& $msbuild ValidateJWT.sln /t:Rebuild /p:Configuration=$Configuration /p:Platform="Any CPU" /v:minimal /nologo

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ? Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "  ? Build successful" -ForegroundColor Green

Write-Host ""
Write-Host "[5/6] Running Tests..." -ForegroundColor Cyan

if (-not (Test-Path $testDll)) {
    Write-Host "  ? Test assembly not found: $testDll" -ForegroundColor Red
    exit 1
}

$testStartTime = Get-Date

if ($GenerateCoverage) {
    Write-Host "  Running with code coverage..." -ForegroundColor Yellow
    
    # Check for dotnet-coverage
    $dotnetCoverage = Get-Command dotnet-coverage -ErrorAction SilentlyContinue
    if (-not $dotnetCoverage) {
        Write-Host "  Installing dotnet-coverage..." -ForegroundColor Yellow
        dotnet tool install -g dotnet-coverage
    }
    
    if ($vstest) {
        dotnet-coverage collect -f cobertura -o $coverageFile $vstest $testDll /logger:trx /ResultsDirectory:$resultsDir
    } else {
        Write-Host "  ? Cannot collect coverage without VSTest" -ForegroundColor Yellow
        $GenerateCoverage = $false
    }
} else {
    if ($vstest) {
        & $vstest $testDll /logger:trx /ResultsDirectory:$resultsDir
    } else {
        Write-Host "  ? VSTest not available, run tests in Visual Studio" -ForegroundColor Yellow
    }
}

$testEndTime = Get-Date
$testDuration = ($testEndTime - $testStartTime).TotalSeconds

Write-Host ""
Write-Host "[6/6] Generating Reports..." -ForegroundColor Cyan

# Parse test results
$trxFiles = Get-ChildItem -Path $resultsDir -Filter "*.trx" -ErrorAction SilentlyContinue

if ($trxFiles) {
    $trxFile = $trxFiles[0]
    [xml]$testResults = Get-Content $trxFile.FullName
    
    $counters = $testResults.TestRun.ResultSummary.Counters
    $total = [int]$counters.total
    $passed = [int]$counters.passed
    $failed = [int]$counters.failed
    $skipped = [int]$counters.notExecuted
    
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  Test Results Summary" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Total Tests:    $total" -ForegroundColor White
    Write-Host "Passed:         $passed" -ForegroundColor Green
    Write-Host "Failed:         $failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
    Write-Host "Skipped:        $skipped" -ForegroundColor Yellow
    Write-Host "Duration:       $([math]::Round($testDuration, 2))s" -ForegroundColor White
    Write-Host ""
    
    if ($failed -eq 0) {
        Write-Host "Result:         ? SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "Result:         ? FAILURE" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Test Results:   $($trxFile.FullName)" -ForegroundColor Gray
} else {
    Write-Host "  ? No test results file found" -ForegroundColor Yellow
}

# Generate coverage report
if ($GenerateCoverage -and (Test-Path $coverageFile)) {
    Write-Host ""
    Write-Host "Generating Coverage Report..." -ForegroundColor Cyan
    
    $reportGen = Get-Command reportgenerator -ErrorAction SilentlyContinue
    if (-not $reportGen) {
        Write-Host "  Installing ReportGenerator..." -ForegroundColor Yellow
        dotnet tool install -g dotnet-reportgenerator-globaltool
    }
    
    $coverageReportDir = "CoverageReport"
    Remove-Item -Path $coverageReportDir -Recurse -Force -ErrorAction SilentlyContinue
    
    reportgenerator -reports:$coverageFile -targetdir:$coverageReportDir -reporttypes:Html
    
    Write-Host "  ? Coverage report generated: $coverageReportDir\index.html" -ForegroundColor Green
    
    if ($OpenReport) {
        Start-Process "$coverageReportDir\index.html"
    }
}

Write-Host ""
Write-Host "Files Generated:" -ForegroundColor Cyan
Write-Host "  Test Results: $resultsDir\" -ForegroundColor White
if ($GenerateCoverage) {
    Write-Host "  Coverage:     $coverageFile" -ForegroundColor White
    Write-Host "  Report:       CoverageReport\index.html" -ForegroundColor White
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan

if ($trxFiles -and $failed -eq 0) {
    Write-Host "  All Tests Passed! ?" -ForegroundColor Green
    exit 0
} elseif ($trxFiles -and $failed -gt 0) {
    Write-Host "  Some Tests Failed! ?" -ForegroundColor Red
    exit 1
} else {
    Write-Host "  Test Execution Completed" -ForegroundColor Yellow
    exit 0
}
