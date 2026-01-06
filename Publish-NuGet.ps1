# PowerShell Script for Publishing ValidateJWT to NuGet
# Version: 1.0.1
# Requires: NuGet CLI, MSBuild, Git

param(
    [Parameter(Mandatory=$false)]
    [string]$ApiKey = $env:NUGET_API_KEY,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipBuild,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipTests,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipGit,
    
    [Parameter(Mandatory=$false)]
    [switch]$LocalOnly,
    
    [Parameter(Mandatory=$false)]
    [string]$Version = "1.0.1"
)

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Info($message) { Write-Host $message -ForegroundColor Cyan }
function Write-Success($message) { Write-Host $message -ForegroundColor Green }
function Write-Warning($message) { Write-Host $message -ForegroundColor Yellow }
function Write-Error($message) { Write-Host $message -ForegroundColor Red }

# Banner
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ValidateJWT v$Version - NuGet Publishing Script" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Set working directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

# Configuration
$projectFile = "ValidateJWT.csproj"
$nuspecFile = "ValidateJWT.nuspec"
$packageName = "ValidateJWT"
$configuration = "Release"
$nugetSource = "https://api.nuget.org/v3/index.json"

# Step 1: Verify Prerequisites
Write-Info "[Step 1/8] Verifying prerequisites..."

# Check if project file exists
if (-not (Test-Path $projectFile)) {
    Write-Error "ERROR: Project file '$projectFile' not found!"
    exit 1
}

# Check if nuspec exists
if (-not (Test-Path $nuspecFile)) {
    Write-Error "ERROR: NuGet spec file '$nuspecFile' not found!"
    exit 1
}

# Check for NuGet
$nugetExe = $null
if (Get-Command nuget -ErrorAction SilentlyContinue) {
    $nugetExe = "nuget"
    Write-Success "  ? NuGet CLI found in PATH"
} elseif (Test-Path ".\nuget.exe") {
    $nugetExe = ".\nuget.exe"
    Write-Success "  ? NuGet.exe found in current directory"
} else {
    Write-Warning "  ! NuGet CLI not found. Downloading..."
    Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile "nuget.exe"
    $nugetExe = ".\nuget.exe"
    Write-Success "  ? NuGet.exe downloaded"
}

# Check for MSBuild
function Find-MSBuild {
    # Try vswhere first
    $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (Test-Path $vswhere) {
        $vsPath = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild -property installationPath
        if ($vsPath) {
            $msbuildPath = Join-Path $vsPath "MSBuild\Current\Bin\MSBuild.exe"
            if (Test-Path $msbuildPath) { return $msbuildPath }
        }
    }
    
    # Try common paths
    $paths = @(
        "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe",
        "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe",
        "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"
    )
    
    foreach ($path in $paths) {
        if (Test-Path $path) { return $path }
    }
    
    # Check if in PATH
    if (Get-Command msbuild -ErrorAction SilentlyContinue) {
        return "msbuild"
    }
    
    return $null
}

if (-not $SkipBuild) {
    $msbuild = Find-MSBuild
    if (-not $msbuild) {
        Write-Error "ERROR: MSBuild not found! Please install Visual Studio or use -SkipBuild"
        exit 1
    }
    Write-Success "  ? MSBuild found: $msbuild"
}

Write-Host ""

# Step 2: Clean Previous Builds
Write-Info "[Step 2/8] Cleaning previous builds..."

if (Test-Path "bin\$configuration") {
    Remove-Item -Recurse -Force "bin\$configuration"
    Write-Success "  ? Cleaned bin\$configuration"
}

if (Test-Path "obj") {
    Remove-Item -Recurse -Force "obj"
    Write-Success "  ? Cleaned obj"
}

# Remove old packages
Get-ChildItem -Filter "$packageName.*.nupkg" | ForEach-Object {
    Remove-Item $_.FullName -Force
    Write-Success "  ? Removed old package: $($_.Name)"
}

Write-Host ""

# Step 3: Restore NuGet Packages
Write-Info "[Step 3/8] Restoring NuGet packages..."

& $nugetExe restore $projectFile
if ($LASTEXITCODE -ne 0) {
    Write-Error "ERROR: NuGet restore failed!"
    exit 1
}
Write-Success "  ? NuGet packages restored"
Write-Host ""

# Step 4: Build Project
if (-not $SkipBuild) {
    Write-Info "[Step 4/8] Building project in $configuration mode..."
    
    & $msbuild $projectFile /p:Configuration=$configuration /p:DocumentationFile=bin\$configuration\ValidateJWT.xml /v:minimal /nologo
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "ERROR: Build failed!"
        exit 1
    }
    
    # Verify output files
    $dllPath = "bin\$configuration\ValidateJWT.dll"
    $xmlPath = "bin\$configuration\ValidateJWT.xml"
    
    if (-not (Test-Path $dllPath)) {
        Write-Error "ERROR: DLL not found at $dllPath"
        exit 1
    }
    
    if (-not (Test-Path $xmlPath)) {
        Write-Warning "  ! XML documentation not found at $xmlPath"
    }
    
    $dllSize = [math]::Round((Get-Item $dllPath).Length / 1KB, 2)
    Write-Success "  ? Build successful"
    Write-Host "    ValidateJWT.dll: $dllSize KB" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Warning "[Step 4/8] Skipping build (as requested)"
    Write-Host ""
}

# Step 5: Run Tests
if (-not $SkipTests) {
    Write-Info "[Step 5/8] Running tests..."
    
    $testProject = "ValidateJWT.Tests\ValidateJWT.Tests.csproj"
    if (Test-Path $testProject) {
        $dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
        if ($dotnet) {
            dotnet test $testProject --configuration $configuration --no-build --verbosity quiet
            if ($LASTEXITCODE -eq 0) {
                Write-Success "  ? All tests passed"
            } else {
                Write-Warning "  ! Some tests failed, but continuing..."
            }
        } else {
            Write-Warning "  ! dotnet CLI not found, skipping tests"
        }
    } else {
        Write-Warning "  ! Test project not found, skipping tests"
    }
    Write-Host ""
} else {
    Write-Warning "[Step 5/8] Skipping tests (as requested)"
    Write-Host ""
}

# Step 6: Create NuGet Package
Write-Info "[Step 6/8] Creating NuGet package..."

& $nugetExe pack $nuspecFile -OutputDirectory . -Properties Configuration=$configuration

if ($LASTEXITCODE -ne 0) {
    Write-Error "ERROR: Package creation failed!"
    exit 1
}

$packageFile = Get-ChildItem -Filter "$packageName.$Version.nupkg" | Select-Object -First 1

if (-not $packageFile) {
    Write-Error "ERROR: Package file not found!"
    exit 1
}

$packageSize = [math]::Round($packageFile.Length / 1KB, 2)
Write-Success "  ? Package created: $($packageFile.Name) ($packageSize KB)"
Write-Host ""

# Step 7: Verify Package Contents
Write-Info "[Step 7/8] Verifying package contents..."

$tempDir = "temp_package_verify"
if (Test-Path $tempDir) {
    Remove-Item -Recurse -Force $tempDir
}

Expand-Archive $packageFile.Name -DestinationPath $tempDir

$requiredFiles = @(
    "$tempDir\lib\net472\ValidateJWT.dll",
    "$tempDir\lib\net472\ValidateJWT.xml",
    "$tempDir\README.md",
    "$tempDir\LICENSE.txt"
)

$allFound = $true
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        $fileName = Split-Path $file -Leaf
        Write-Success "  ? $fileName"
    } else {
        $fileName = Split-Path $file -Leaf
        Write-Warning "  ! Missing: $fileName"
        $allFound = $false
    }
}

Remove-Item -Recurse -Force $tempDir

if (-not $allFound) {
    Write-Warning "  Some files are missing from package, but continuing..."
}
Write-Host ""

# Step 8: Git Operations
if (-not $SkipGit) {
    Write-Info "[Step 8/8] Git operations..."
    
    # Check if git is available
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        # Check for uncommitted changes
        $status = git status --porcelain
        if ($status) {
            Write-Host "  Uncommitted changes detected:" -ForegroundColor Yellow
            git status --short
            Write-Host ""
            
            $commit = Read-Host "  Commit changes before publishing? (Y/N)"
            if ($commit -eq 'Y' -or $commit -eq 'y') {
                git add -A
                git commit -m "Release v$Version - NuGet package publication"
                git push origin main
                Write-Success "  ? Changes committed and pushed"
            }
        } else {
            Write-Success "  ? Working directory clean"
        }
        
        # Check if tag exists
        $tagExists = git tag -l "v$Version"
        if (-not $tagExists) {
            $createTag = Read-Host "  Create and push tag v$Version? (Y/N)"
            if ($createTag -eq 'Y' -or $createTag -eq 'y') {
                git tag -a "v$Version" -m "ValidateJWT v$Version"
                git push origin "v$Version"
                Write-Success "  ? Tag v$Version created and pushed"
            }
        } else {
            Write-Success "  ? Tag v$Version already exists"
        }
    } else {
        Write-Warning "  ! Git not found, skipping Git operations"
    }
    Write-Host ""
} else {
    Write-Warning "[Step 8/8] Skipping Git operations (as requested)"
    Write-Host ""
}

# Step 9: Publish to NuGet
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Publishing to NuGet.org" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

if ($LocalOnly) {
    Write-Warning "Local-only mode: Skipping NuGet.org publication"
    Write-Host ""
    Write-Info "Package created successfully: $($packageFile.Name)"
    Write-Host ""
    Write-Host "To publish manually:" -ForegroundColor Yellow
    Write-Host "  nuget push $($packageFile.Name) -Source $nugetSource -ApiKey YOUR_API_KEY" -ForegroundColor White
    Write-Host ""
} else {
    if ([string]::IsNullOrWhiteSpace($ApiKey)) {
        Write-Warning "No API key provided!"
        Write-Host ""
        Write-Host "Options:" -ForegroundColor Yellow
        Write-Host "  1. Set environment variable: `$env:NUGET_API_KEY = 'your-key'" -ForegroundColor White
        Write-Host "  2. Run script with parameter: -ApiKey 'your-key'" -ForegroundColor White
        Write-Host "  3. Enter API key now" -ForegroundColor White
        Write-Host ""
        
        $enterNow = Read-Host "Enter API key now? (Y/N)"
        if ($enterNow -eq 'Y' -or $enterNow -eq 'y') {
            $ApiKey = Read-Host "Enter your NuGet API key" -AsSecureString
            $ApiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ApiKey))
        }
    }
    
    if (-not [string]::IsNullOrWhiteSpace($ApiKey)) {
        Write-Info "API key found"
        Write-Host "Package: $($packageFile.Name)" -ForegroundColor White
        Write-Host "Target: $nugetSource" -ForegroundColor White
        Write-Host ""
        
        $confirm = Read-Host "Publish to NuGet.org? (Y/N)"
        if ($confirm -eq 'Y' -or $confirm -eq 'y') {
            Write-Host ""
            Write-Info "Publishing..."
            
            & $nugetExe push $packageFile.Name -Source $nugetSource -ApiKey $ApiKey
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host ""
                Write-Host "============================================================" -ForegroundColor Green
                Write-Host "  ? SUCCESS! Package Published to NuGet.org" -ForegroundColor Green
                Write-Host "============================================================" -ForegroundColor Green
                Write-Host ""
                Write-Host "Package: $packageName v$Version" -ForegroundColor White
                Write-Host "URL: https://www.nuget.org/packages/$packageName/$Version" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "? Indexing: Package will be available in ~15 minutes" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "Install command:" -ForegroundColor Yellow
                Write-Host "  Install-Package $packageName -Version $Version" -ForegroundColor White
                Write-Host ""
            } else {
                Write-Host ""
                Write-Host "============================================================" -ForegroundColor Red
                Write-Host "  ? Publication Failed!" -ForegroundColor Red
                Write-Host "============================================================" -ForegroundColor Red
                Write-Host ""
                Write-Host "Common issues:" -ForegroundColor Yellow
                Write-Host "  • Invalid or expired API key" -ForegroundColor White
                Write-Host "  • Package version already exists" -ForegroundColor White
                Write-Host "  • Network connection issues" -ForegroundColor White
                Write-Host ""
                Write-Host "To retry:" -ForegroundColor Yellow
                Write-Host "  .\Publish-NuGet.ps1 -ApiKey YOUR_KEY -Version $Version" -ForegroundColor White
                Write-Host ""
                exit 1
            }
        } else {
            Write-Warning "Publication cancelled"
            Write-Host ""
            Write-Host "Package ready at: $($packageFile.FullName)" -ForegroundColor Gray
            Write-Host ""
        }
    } else {
        Write-Warning "No API key provided - skipping publication"
        Write-Host ""
        Write-Host "Package created: $($packageFile.Name)" -ForegroundColor White
        Write-Host ""
        Write-Host "To publish later:" -ForegroundColor Yellow
        Write-Host "  .\Publish-NuGet.ps1 -ApiKey YOUR_KEY -Version $Version" -ForegroundColor White
        Write-Host ""
    }
}

# Summary
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Summary" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Version: $Version" -ForegroundColor White
Write-Host "Package: $($packageFile.Name)" -ForegroundColor White
Write-Host "Size: $packageSize KB" -ForegroundColor White
Write-Host "Location: $($packageFile.FullName)" -ForegroundColor Gray
Write-Host ""

if (-not $LocalOnly -and -not [string]::IsNullOrWhiteSpace($ApiKey)) {
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Wait ~15 minutes for NuGet indexing" -ForegroundColor White
    Write-Host "  2. Verify: https://www.nuget.org/packages/$packageName/$Version" -ForegroundColor White
    Write-Host "  3. Test install: Install-Package $packageName -Version $Version" -ForegroundColor White
    Write-Host ""
}

Write-Success "Script completed successfully!"
Write-Host ""
