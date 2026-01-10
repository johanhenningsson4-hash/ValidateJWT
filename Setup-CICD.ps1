# Setup CI/CD Pipeline for ValidateJWT
# This script helps set up GitHub Actions workflows and configure secrets

param(
    [Parameter(Mandatory=$false)]
    [switch]$SkipSecretGuide,
    
    [Parameter(Mandatory=$false)]
    [switch]$TestLocally
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ValidateJWT - CI/CD Pipeline Setup" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = $PSScriptRoot
if (-not $projectRoot) {
    $projectRoot = Get-Location
}

Set-Location $projectRoot

Write-Host "Project Root: $projectRoot" -ForegroundColor Gray
Write-Host ""

# Check if .github/workflows exists
$workflowsDir = ".github\workflows"
if (Test-Path $workflowsDir) {
    Write-Host "? Workflows directory exists" -ForegroundColor Green
    
    $workflows = Get-ChildItem -Path $workflowsDir -Filter "*.yml"
    Write-Host "Found $($workflows.Count) workflow files:" -ForegroundColor White
    foreach ($workflow in $workflows) {
        Write-Host "  • $($workflow.Name)" -ForegroundColor Gray
    }
} else {
    Write-Host "? Workflows directory not found!" -ForegroundColor Red
    Write-Host "Please ensure .github/workflows/ directory exists with workflow files." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Workflow Summary" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Main CI/CD Pipeline (ci-cd.yml)" -ForegroundColor Yellow
Write-Host "   Triggers: Push to main/develop, PR, Release" -ForegroundColor White
Write-Host "   Jobs: Build, Test, Quality, Security, NuGet" -ForegroundColor White
Write-Host ""

Write-Host "2. PR Validation (pr-validation.yml)" -ForegroundColor Yellow
Write-Host "   Triggers: Pull request opened/updated" -ForegroundColor White
Write-Host "   Jobs: Build, Test, Comment on PR" -ForegroundColor White
Write-Host ""

Write-Host "3. Nightly Build (nightly-build.yml)" -ForegroundColor Yellow
Write-Host "   Triggers: Schedule (2 AM UTC), Manual" -ForegroundColor White
Write-Host "   Jobs: Build, Test, Create issue on failure" -ForegroundColor White
Write-Host ""

Write-Host "4. Code Coverage (code-coverage.yml)" -ForegroundColor Yellow
Write-Host "   Triggers: Push to main, PR to main" -ForegroundColor White
Write-Host "   Jobs: Coverage analysis, Codecov upload" -ForegroundColor White
Write-Host ""

if (-not $SkipSecretGuide) {
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  Required GitHub Secrets" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "To enable full CI/CD functionality, add these secrets:" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "1. NUGET_API_KEY" -ForegroundColor White
    Write-Host "   Purpose: Publish packages to NuGet.org" -ForegroundColor Gray
    Write-Host "   Get from: https://www.nuget.org/account/apikeys" -ForegroundColor Gray
    Write-Host "   Required: Yes (for releases)" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "2. CODECOV_TOKEN (Optional)" -ForegroundColor White
    Write-Host "   Purpose: Upload coverage to Codecov.io" -ForegroundColor Gray
    Write-Host "   Get from: https://codecov.io/gh/your-org/ValidateJWT" -ForegroundColor Gray
    Write-Host "   Required: No (nice to have)" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "How to add secrets:" -ForegroundColor Cyan
    Write-Host "  1. Go to repository Settings" -ForegroundColor White
    Write-Host "  2. Navigate to Secrets and variables ? Actions" -ForegroundColor White
    Write-Host "  3. Click 'New repository secret'" -ForegroundColor White
    Write-Host "  4. Add name and value" -ForegroundColor White
    Write-Host "  5. Click 'Add secret'" -ForegroundColor White
    Write-Host ""
}

if ($TestLocally) {
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  Testing Locally" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Running automated tests..." -ForegroundColor Yellow
    Write-Host ""
    
    if (Test-Path "Run-AutomatedTests.ps1") {
        & .\Run-AutomatedTests.ps1
    } else {
        Write-Host "Run-AutomatedTests.ps1 not found!" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Next Steps" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Add GitHub Secrets (if not done):" -ForegroundColor Yellow
Write-Host "   • NUGET_API_KEY (required for publishing)" -ForegroundColor White
Write-Host ""

Write-Host "2. Commit and Push Workflows:" -ForegroundColor Yellow
Write-Host "   git add .github/" -ForegroundColor Gray
Write-Host "   git commit -m `"ci: Add CI/CD pipeline workflows`"" -ForegroundColor Gray
Write-Host "   git push origin main" -ForegroundColor Gray
Write-Host ""

Write-Host "3. Verify Workflows:" -ForegroundColor Yellow
Write-Host "   • Go to GitHub ? Actions tab" -ForegroundColor White
Write-Host "   • Check workflow runs" -ForegroundColor White
Write-Host "   • View logs and results" -ForegroundColor White
Write-Host ""

Write-Host "4. Test Locally (optional):" -ForegroundColor Yellow
Write-Host "   .\Run-AutomatedTests.ps1" -ForegroundColor Gray
Write-Host "   .\Run-AutomatedTests.ps1 -GenerateCoverage" -ForegroundColor Gray
Write-Host ""

Write-Host "5. Create First Release:" -ForegroundColor Yellow
Write-Host "   • Create tag: git tag -a v1.1.0 -m `"Release v1.1.0`"" -ForegroundColor White
Write-Host "   • Push tag: git push origin v1.1.0" -ForegroundColor White
Write-Host "   • Create release on GitHub" -ForegroundColor White
Write-Host "   • CI/CD will automatically publish to NuGet!" -ForegroundColor White
Write-Host ""

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Documentation" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Read CI_CD_GUIDE.md for:" -ForegroundColor White
Write-Host "  • Complete workflow documentation" -ForegroundColor Gray
Write-Host "  • Troubleshooting guide" -ForegroundColor Gray
Write-Host "  • Best practices" -ForegroundColor Gray
Write-Host "  • Badge integration" -ForegroundColor Gray
Write-Host ""

Write-Host "Quick Commands:" -ForegroundColor Cyan
Write-Host "  Test locally:       .\Run-AutomatedTests.ps1" -ForegroundColor White
Write-Host "  With coverage:      .\Run-AutomatedTests.ps1 -GenerateCoverage" -ForegroundColor White
Write-Host "  View guide:         code CI_CD_GUIDE.md" -ForegroundColor White
Write-Host ""

Write-Host "============================================================" -ForegroundColor Green
Write-Host "  CI/CD Pipeline Ready! ??" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Your ValidateJWT project now has:" -ForegroundColor White
Write-Host "  ? Automated builds on every push" -ForegroundColor Green
Write-Host "  ? Comprehensive test execution" -ForegroundColor Green
Write-Host "  ? Code coverage reporting" -ForegroundColor Green
Write-Host "  ? PR validation" -ForegroundColor Green
Write-Host "  ? Automated NuGet publishing" -ForegroundColor Green
Write-Host "  ? Nightly builds" -ForegroundColor Green
Write-Host "  ? Security scanning" -ForegroundColor Green
Write-Host ""

Write-Host "Commit the workflows and start building! ??" -ForegroundColor Cyan
Write-Host ""
