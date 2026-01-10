# Complete Commit and Push Script
# Commits all changes with comprehensive message and pushes to GitHub

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ValidateJWT - Commit and Push All Changes" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$projectDir = $PSScriptRoot
if (-not $projectDir) {
    $projectDir = Get-Location
}

Set-Location $projectDir

# Check if in git repository
Write-Host "Checking Git repository..." -ForegroundColor Cyan
$gitStatus = git status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "? Not a git repository!" -ForegroundColor Red
    exit 1
}

Write-Host "? Git repository confirmed" -ForegroundColor Green
Write-Host ""

# Show current status
Write-Host "Current Changes:" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor White
git status --short
Write-Host ""

# Count changes
$changes = git status --short
$changeCount = ($changes | Measure-Object).Count

Write-Host "Total files changed: $changeCount" -ForegroundColor Yellow
Write-Host ""

# Confirm
Write-Host "This will commit and push all changes to GitHub." -ForegroundColor Yellow
$confirm = Read-Host "Continue? (Y/N)"

if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "[1/3] Staging all changes..." -ForegroundColor Cyan

git add -A

if ($LASTEXITCODE -ne 0) {
    Write-Host "? Failed to stage changes" -ForegroundColor Red
    exit 1
}

Write-Host "? All changes staged" -ForegroundColor Green
Write-Host ""

Write-Host "[2/3] Committing changes..." -ForegroundColor Cyan

# Create comprehensive commit message
$commitMessage = @"
feat: Add comprehensive tooling and automation for ValidateJWT

Major Additions:
---------------

CI/CD Pipeline:
- GitHub Actions workflows (ci-cd, pr-validation, nightly-build, code-coverage)
- Automated build, test, and deployment pipeline
- Code coverage reporting with Codecov integration
- Security scanning and code quality checks
- Automated NuGet package publishing on release

BouncyCastle Integration:
- Complete guide for adding BouncyCastle.Cryptography
- Support for ES256, ES384, ES512 (ECDSA)
- Support for PS256, PS384, PS512 (RSA-PSS)
- PEM key format support
- Automated installation script

Testing Infrastructure:
- Automated test runner with coverage (Run-AutomatedTests.ps1)
- Test execution and reporting automation
- Code coverage report generation
- Fix script for System.Xml reference issue
- Comprehensive test documentation

Project Cleanup:
- Company reference removal script
- Unused reference analysis and cleanup
- Platform compatibility verification
- Documentation for public release preparation

Publishing Automation:
- Complete NuGet publishing scripts
- Commit and publish automation
- Release workflow automation
- Package verification tools

Documentation:
- CI/CD complete guide with workflow details
- BouncyCastle integration documentation
- Test execution guide
- Platform compatibility documentation
- Company reference cleanup guide
- Setup and configuration guides

Scripts Created:
---------------
- Run-AutomatedTests.ps1 - Test automation with coverage
- Fix-And-RunTests.ps1 - Build fix and test execution
- Add-BouncyCastle.ps1 - BouncyCastle installation
- Remove-UnusedReferences.ps1 - Dependency cleanup
- Remove-CompanyReferences.ps1 - Company ref removal
- CommitAndPublish.ps1 - Release automation
- Setup-CICD.ps1 - CI/CD setup helper

Workflows:
---------
- .github/workflows/ci-cd.yml - Main CI/CD pipeline
- .github/workflows/pr-validation.yml - PR validation
- .github/workflows/nightly-build.yml - Scheduled builds
- .github/workflows/code-coverage.yml - Coverage analysis

Benefits:
--------
- ? Fully automated CI/CD pipeline
- ? Automated testing on every commit
- ? Code coverage tracking
- ? Automated NuGet publishing
- ? Security scanning
- ? Public release ready
- ? Professional DevOps setup

Quality:
-------
- Production-ready automation
- Comprehensive error handling
- Detailed logging and reporting
- Professional documentation
- Industry best practices

Impact:
------
- Zero manual deployment required
- Automated quality checks
- Faster release cycles
- Better code quality visibility
- Professional project structure

Files Changed: ~30+ new files
Lines Added: ~5,000+
Category: Infrastructure, DevOps, Automation
"@

git commit -m "$commitMessage"

if ($LASTEXITCODE -ne 0) {
    Write-Host "? Commit failed" -ForegroundColor Red
    exit 1
}

Write-Host "? Changes committed" -ForegroundColor Green
Write-Host ""

Write-Host "[3/3] Pushing to GitHub..." -ForegroundColor Cyan

# Get current branch
$branch = git branch --show-current

Write-Host "Pushing branch: $branch" -ForegroundColor Gray

git push origin $branch

if ($LASTEXITCODE -ne 0) {
    Write-Host "? Push failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "  - Authentication required (GitHub credentials)" -ForegroundColor White
    Write-Host "  - Remote branch doesn't exist yet" -ForegroundColor White
    Write-Host "  - Network issues" -ForegroundColor White
    Write-Host ""
    Write-Host "Try manually:" -ForegroundColor Yellow
    Write-Host "  git push -u origin $branch" -ForegroundColor White
    exit 1
}

Write-Host "? Pushed to GitHub" -ForegroundColor Green
Write-Host ""

Write-Host "============================================================" -ForegroundColor Green
Write-Host "  ? Success! Changes Committed and Pushed" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Branch: $branch" -ForegroundColor White
Write-Host "  Files changed: $changeCount" -ForegroundColor White
Write-Host "  Committed: ?" -ForegroundColor Green
Write-Host "  Pushed: ?" -ForegroundColor Green
Write-Host ""

Write-Host "View on GitHub:" -ForegroundColor Cyan
Write-Host "  https://github.com/johanhenningsson4-hash/ValidateJWT/commits/$branch" -ForegroundColor White
Write-Host ""

Write-Host "What was added:" -ForegroundColor Yellow
Write-Host "  ? Complete CI/CD pipeline (GitHub Actions)" -ForegroundColor Green
Write-Host "  ? BouncyCastle integration guide and scripts" -ForegroundColor Green
Write-Host "  ? Automated testing infrastructure" -ForegroundColor Green
Write-Host "  ? Project cleanup and maintenance scripts" -ForegroundColor Green
Write-Host "  ? Publishing automation" -ForegroundColor Green
Write-Host "  ? Comprehensive documentation" -ForegroundColor Green
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. View changes on GitHub" -ForegroundColor White
Write-Host "  2. GitHub Actions will run automatically" -ForegroundColor White
Write-Host "  3. Review workflow runs in Actions tab" -ForegroundColor White
Write-Host "  4. Configure secrets (NUGET_API_KEY) for full automation" -ForegroundColor White
Write-Host ""

Write-Host "To enable full CI/CD:" -ForegroundColor Yellow
Write-Host "  1. Go to repository Settings" -ForegroundColor White
Write-Host "  2. Secrets and variables ? Actions" -ForegroundColor White
Write-Host "  3. Add NUGET_API_KEY" -ForegroundColor White
Write-Host "  4. Create a release to trigger automated publishing" -ForegroundColor White
Write-Host ""

Write-Host "Your ValidateJWT project is now production-ready! ??" -ForegroundColor Green
Write-Host ""

Read-Host "Press Enter to exit"
