# Complete CI/CD Setup Verification and Configuration Script
# Ensures all CI/CD components are properly configured

param(
    [Parameter(Mandatory=$false)]
    [switch]$Fix,
    
    [Parameter(Mandatory=$false)]
    [switch]$Detailed
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ValidateJWT - CI/CD Setup Verification" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = $PSScriptRoot
if (-not $projectRoot) {
    $projectRoot = Get-Location
}

Set-Location $projectRoot

$allGood = $true
$issues = @()
$fixed = @()

# Check 1: GitHub Workflows Directory
Write-Host "[1/10] Checking GitHub workflows directory..." -ForegroundColor Cyan

$workflowsDir = ".github\workflows"
if (Test-Path $workflowsDir) {
    Write-Host "  ? Workflows directory exists" -ForegroundColor Green
} else {
    Write-Host "  ? Workflows directory missing" -ForegroundColor Red
    $allGood = $false
    $issues += "Workflows directory missing"
    
    if ($Fix) {
        New-Item -ItemType Directory -Path $workflowsDir -Force | Out-Null
        Write-Host "  ? Created workflows directory" -ForegroundColor Green
        $fixed += "Created .github/workflows directory"
    }
}

# Check 2: Required Workflow Files
Write-Host ""
Write-Host "[2/10] Checking workflow files..." -ForegroundColor Cyan

$requiredWorkflows = @{
    "ci-cd.yml" = "Main CI/CD pipeline"
    "pr-validation.yml" = "Pull request validation"
    "nightly-build.yml" = "Nightly builds"
    "code-coverage.yml" = "Code coverage"
}

foreach ($workflow in $requiredWorkflows.GetEnumerator()) {
    $filePath = Join-Path $workflowsDir $workflow.Key
    if (Test-Path $filePath) {
        $size = (Get-Item $filePath).Length
        Write-Host "  ? $($workflow.Key) - $($workflow.Value) ($size bytes)" -ForegroundColor Green
    } else {
        Write-Host "  ? $($workflow.Key) - MISSING" -ForegroundColor Red
        $allGood = $false
        $issues += "$($workflow.Key) missing"
    }
}

# Check 3: Automation Scripts
Write-Host ""
Write-Host "[3/10] Checking automation scripts..." -ForegroundColor Cyan

$requiredScripts = @{
    "Run-AutomatedTests.ps1" = "Test automation"
    "Fix-And-RunTests.ps1" = "Build and test"
    "Setup-CICD.ps1" = "CI/CD setup"
    "Check-GitHubSecrets.ps1" = "Secrets verification"
    "Commit-And-Push.ps1" = "Git automation"
    "CommitAndPublish.ps1" = "Release automation"
}

foreach ($script in $requiredScripts.GetEnumerator()) {
    if (Test-Path $script.Key) {
        Write-Host "  ? $($script.Key) - $($script.Value)" -ForegroundColor Green
    } else {
        Write-Host "  ? $($script.Key) - MISSING" -ForegroundColor Yellow
        $issues += "$($script.Key) missing (optional)"
    }
}

# Check 4: Documentation Files
Write-Host ""
Write-Host "[4/10] Checking CI/CD documentation..." -ForegroundColor Cyan

$requiredDocs = @{
    "CI_CD_GUIDE.md" = "CI/CD documentation"
    "GITHUB_SECRETS_SETUP.md" = "Secrets setup guide"
    "RUN_TESTS_GUIDE.md" = "Test execution guide"
}

foreach ($doc in $requiredDocs.GetEnumerator()) {
    if (Test-Path $doc.Key) {
        Write-Host "  ? $($doc.Key) - $($doc.Value)" -ForegroundColor Green
    } else {
        Write-Host "  ? $($doc.Key) - MISSING" -ForegroundColor Yellow
        $issues += "$($doc.Key) missing"
    }
}

# Check 5: Git Repository
Write-Host ""
Write-Host "[5/10] Checking Git repository..." -ForegroundColor Cyan

$gitStatus = git status 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ? Git repository initialized" -ForegroundColor Green
    
    # Check remote
    $remote = git remote get-url origin 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ? Remote configured: $remote" -ForegroundColor Green
    } else {
        Write-Host "  ? No remote configured" -ForegroundColor Yellow
        $issues += "No Git remote"
    }
} else {
    Write-Host "  ? Not a Git repository" -ForegroundColor Red
    $allGood = $false
    $issues += "Not a Git repository"
}

# Check 6: GitHub CLI
Write-Host ""
Write-Host "[6/10] Checking GitHub CLI..." -ForegroundColor Cyan

$ghCli = Get-Command gh -ErrorAction SilentlyContinue
if ($ghCli) {
    Write-Host "  ? GitHub CLI installed" -ForegroundColor Green
    
    # Check authentication
    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ? GitHub CLI authenticated" -ForegroundColor Green
    } else {
        Write-Host "  ? GitHub CLI not authenticated" -ForegroundColor Yellow
        $issues += "GitHub CLI not authenticated"
    }
} else {
    Write-Host "  ? GitHub CLI not installed (optional)" -ForegroundColor Yellow
    Write-Host "    Install: winget install --id GitHub.cli" -ForegroundColor Gray
}

# Check 7: GitHub Secrets
Write-Host ""
Write-Host "[7/10] Checking GitHub secrets..." -ForegroundColor Cyan

if ($ghCli -and $LASTEXITCODE -eq 0) {
    $secrets = gh secret list 2>&1
    if ($LASTEXITCODE -eq 0) {
        if ($secrets -match "NUGET_API_KEY") {
            Write-Host "  ? NUGET_API_KEY configured" -ForegroundColor Green
        } else {
            Write-Host "  ? NUGET_API_KEY not configured" -ForegroundColor Yellow
            $issues += "NUGET_API_KEY not set"
        }
        
        if ($secrets -match "CODECOV_TOKEN") {
            Write-Host "  ? CODECOV_TOKEN configured (optional)" -ForegroundColor Green
        } else {
            Write-Host "  ? CODECOV_TOKEN not configured (optional)" -ForegroundColor Gray
        }
    } else {
        Write-Host "  ? Cannot check secrets (authentication required)" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ? Cannot check secrets (GitHub CLI not available)" -ForegroundColor Yellow
    Write-Host "    Manual check: https://github.com/johanhenningsson4-hash/ValidateJWT/settings/secrets/actions" -ForegroundColor Gray
}

# Check 8: Project Files
Write-Host ""
Write-Host "[8/10] Checking project configuration..." -ForegroundColor Cyan

if (Test-Path "ValidateJWT.csproj") {
    Write-Host "  ? ValidateJWT.csproj exists" -ForegroundColor Green
    
    $csproj = Get-Content "ValidateJWT.csproj" -Raw
    
    # Check platform target
    if ($csproj -match "<PlatformTarget>AnyCPU</PlatformTarget>") {
        Write-Host "  ? Platform target: AnyCPU" -ForegroundColor Green
    } else {
        Write-Host "  ? Platform target not set to AnyCPU" -ForegroundColor Yellow
    }
    
    # Check target framework
    if ($csproj -match "<TargetFrameworkVersion>v4\.7\.2</TargetFrameworkVersion>") {
        Write-Host "  ? Target framework: .NET Framework 4.7.2" -ForegroundColor Green
    } else {
        Write-Host "  ? Target framework not 4.7.2" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ? ValidateJWT.csproj missing" -ForegroundColor Red
    $allGood = $false
    $issues += "Project file missing"
}

if (Test-Path "ValidateJWT.Tests\ValidateJWT.Tests.csproj") {
    Write-Host "  ? Test project exists" -ForegroundColor Green
} else {
    Write-Host "  ? Test project missing" -ForegroundColor Yellow
}

# Check 9: NuGet Package Configuration
Write-Host ""
Write-Host "[9/10] Checking NuGet configuration..." -ForegroundColor Cyan

if (Test-Path "ValidateJWT.nuspec") {
    Write-Host "  ? NuGet spec file exists" -ForegroundColor Green
    
    $nuspec = Get-Content "ValidateJWT.nuspec" -Raw
    if ($nuspec -match "<version>") {
        Write-Host "  ? Version configured in nuspec" -ForegroundColor Green
    }
} else {
    Write-Host "  ? ValidateJWT.nuspec missing" -ForegroundColor Yellow
    $issues += "NuGet spec missing"
}

if (Test-Path "README.md") {
    Write-Host "  ? README.md exists" -ForegroundColor Green
} else {
    Write-Host "  ? README.md missing" -ForegroundColor Yellow
}

if (Test-Path "LICENSE.txt") {
    Write-Host "  ? LICENSE.txt exists" -ForegroundColor Green
} else {
    Write-Host "  ? LICENSE.txt missing" -ForegroundColor Yellow
}

# Check 10: Build Status
Write-Host ""
Write-Host "[10/10] Checking build status..." -ForegroundColor Cyan

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

if ($msbuild -and (Test-Path $msbuild)) {
    Write-Host "  ? MSBuild found" -ForegroundColor Green
    
    if (Test-Path "ValidateJWT.sln") {
        Write-Host "  ? Solution file exists" -ForegroundColor Green
    } else {
        Write-Host "  ? Solution file missing" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ? MSBuild not found (requires Visual Studio)" -ForegroundColor Yellow
}

# Summary
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  CI/CD Setup Summary" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

if ($allGood -and $issues.Count -eq 0) {
    Write-Host "? CI/CD Setup: COMPLETE" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your ValidateJWT project has full CI/CD automation!" -ForegroundColor White
    Write-Host ""
    Write-Host "Enabled Features:" -ForegroundColor Cyan
    Write-Host "  ? Automated builds on push" -ForegroundColor Green
    Write-Host "  ? Automated testing" -ForegroundColor Green
    Write-Host "  ? Pull request validation" -ForegroundColor Green
    Write-Host "  ? Nightly builds" -ForegroundColor Green
    Write-Host "  ? Code coverage tracking" -ForegroundColor Green
    Write-Host "  ? Automation scripts" -ForegroundColor Green
    Write-Host "  ? Complete documentation" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "  1. Configure GitHub secrets (if not done)" -ForegroundColor White
    Write-Host "     - NUGET_API_KEY for automated publishing" -ForegroundColor Gray
    Write-Host "  2. Push changes to trigger first CI build" -ForegroundColor White
    Write-Host "  3. Monitor in Actions tab:" -ForegroundColor White
    Write-Host "     https://github.com/johanhenningsson4-hash/ValidateJWT/actions" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "??  CI/CD Setup: NEEDS ATTENTION" -ForegroundColor Yellow
    Write-Host ""
    
    if ($issues.Count -gt 0) {
        Write-Host "Issues Found:" -ForegroundColor Yellow
        foreach ($issue in $issues) {
            Write-Host "  • $issue" -ForegroundColor White
        }
        Write-Host ""
    }
    
    if ($fixed.Count -gt 0) {
        Write-Host "Fixed (with -Fix flag):" -ForegroundColor Green
        foreach ($fix in $fixed) {
            Write-Host "  • $fix" -ForegroundColor White
        }
        Write-Host ""
    }
}

# Detailed Report
if ($Detailed) {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  Detailed Configuration Report" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Workflow Files:" -ForegroundColor Cyan
    Get-ChildItem -Path $workflowsDir -Filter "*.yml" -ErrorAction SilentlyContinue | ForEach-Object {
        $size = [math]::Round($_.Length / 1KB, 2)
        Write-Host "  $($_.Name) - $size KB" -ForegroundColor Gray
    }
    Write-Host ""
    
    Write-Host "Automation Scripts:" -ForegroundColor Cyan
    Get-ChildItem -Path . -Filter "*.ps1" | ForEach-Object {
        Write-Host "  $($_.Name)" -ForegroundColor Gray
    }
    Write-Host ""
    
    Write-Host "Documentation:" -ForegroundColor Cyan
    Get-ChildItem -Path . -Filter "*_GUIDE.md" | ForEach-Object {
        Write-Host "  $($_.Name)" -ForegroundColor Gray
    }
}

# Action Items
Write-Host "Quick Actions:" -ForegroundColor Cyan
Write-Host ""

if ($issues -match "NUGET_API_KEY") {
    Write-Host "?? Configure NuGet API Key:" -ForegroundColor Yellow
    Write-Host "   1. Get key: https://www.nuget.org/account/apikeys" -ForegroundColor White
    Write-Host "   2. Add to GitHub: Settings ? Secrets ? Actions" -ForegroundColor White
    Write-Host "   3. Run: .\Check-GitHubSecrets.ps1" -ForegroundColor White
    Write-Host ""
}

if (-not $ghCli) {
    Write-Host "?? Install GitHub CLI (optional but recommended):" -ForegroundColor Yellow
    Write-Host "   winget install --id GitHub.cli" -ForegroundColor White
    Write-Host ""
}

if ($issues -match "Not a Git repository") {
    Write-Host "?? Initialize Git Repository:" -ForegroundColor Yellow
    Write-Host "   git init" -ForegroundColor White
    Write-Host "   git remote add origin https://github.com/johanhenningsson4-hash/ValidateJWT.git" -ForegroundColor White
    Write-Host ""
}

Write-Host "?? Documentation:" -ForegroundColor Cyan
Write-Host "   Setup Guide: .\Setup-CICD.ps1" -ForegroundColor White
Write-Host "   Full Guide:  CI_CD_GUIDE.md" -ForegroundColor White
Write-Host "   Secrets:     GITHUB_SECRETS_SETUP.md" -ForegroundColor White
Write-Host ""

Write-Host "?? Test CI/CD:" -ForegroundColor Cyan
Write-Host "   git add -A" -ForegroundColor White
Write-Host "   git commit -m 'test: Verify CI/CD setup'" -ForegroundColor White
Write-Host "   git push origin main" -ForegroundColor White
Write-Host ""

Write-Host "View Status:" -ForegroundColor Cyan
Write-Host "   https://github.com/johanhenningsson4-hash/ValidateJWT/actions" -ForegroundColor White
Write-Host ""

# Exit code
if ($allGood) {
    exit 0
} else {
    exit 1
}
