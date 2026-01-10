# Verify GitHub Secrets Configuration
# Checks if required secrets are configured for CI/CD automation

param(
    [Parameter(Mandatory=$false)]
    [switch]$SetupGuide
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  GitHub Secrets Configuration Checker" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Check for GitHub CLI
$ghCli = Get-Command gh -ErrorAction SilentlyContinue

if (-not $ghCli) {
    Write-Host "? GitHub CLI not found" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "GitHub CLI is required to check secrets from command line." -ForegroundColor White
    Write-Host ""
    Write-Host "Install GitHub CLI:" -ForegroundColor Cyan
    Write-Host "  winget install --id GitHub.cli" -ForegroundColor White
    Write-Host ""
    Write-Host "Or check manually:" -ForegroundColor Cyan
    Write-Host "  1. Go to: https://github.com/johanhenningsson4-hash/ValidateJWT" -ForegroundColor White
    Write-Host "  2. Settings ? Secrets and variables ? Actions" -ForegroundColor White
    Write-Host ""
    
    if ($SetupGuide) {
        Write-Host "Opening setup guide..." -ForegroundColor Cyan
        Start-Process "GITHUB_SECRETS_SETUP.md"
    }
    
    exit 0
}

Write-Host "? GitHub CLI found" -ForegroundColor Green
Write-Host ""

# Check if authenticated
Write-Host "Checking GitHub authentication..." -ForegroundColor Cyan

$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "? Not authenticated with GitHub CLI" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please authenticate:" -ForegroundColor White
    Write-Host "  gh auth login" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "? Authenticated" -ForegroundColor Green
Write-Host ""

# List secrets
Write-Host "Checking configured secrets..." -ForegroundColor Cyan
Write-Host ""

$secrets = gh secret list --repo johanhenningsson4-hash/ValidateJWT 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "? Failed to list secrets" -ForegroundColor Red
    Write-Host $secrets
    exit 1
}

Write-Host "Configured Secrets:" -ForegroundColor White
Write-Host "============================================================" -ForegroundColor Gray
Write-Host $secrets
Write-Host ""

# Check for required secrets
$requiredSecrets = @("NUGET_API_KEY")
$optionalSecrets = @("CODECOV_TOKEN")

Write-Host "Verification:" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Gray
Write-Host ""

$allGood = $true

foreach ($secret in $requiredSecrets) {
    if ($secrets -match $secret) {
        Write-Host "  ? $secret - Configured" -ForegroundColor Green
    } else {
        Write-Host "  ? $secret - MISSING (Required)" -ForegroundColor Red
        $allGood = $false
    }
}

Write-Host ""

foreach ($secret in $optionalSecrets) {
    if ($secrets -match $secret) {
        Write-Host "  ? $secret - Configured (Optional)" -ForegroundColor Green
    } else {
        Write-Host "  ? $secret - Not configured (Optional)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan

if ($allGood) {
    Write-Host "  ? All Required Secrets Configured!" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Your CI/CD pipeline is fully configured!" -ForegroundColor White
    Write-Host ""
    Write-Host "What this enables:" -ForegroundColor Cyan
    Write-Host "  ? Automated building on every push" -ForegroundColor Green
    Write-Host "  ? Automated testing" -ForegroundColor Green
    Write-Host "  ? Automated NuGet publishing on release" -ForegroundColor Green
    Write-Host "  ? Automated asset uploads" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Make a commit and push to test CI" -ForegroundColor White
    Write-Host "  2. Create a release to test full pipeline" -ForegroundColor White
    Write-Host "  3. Monitor in Actions tab" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "  ? Missing Required Secrets" -ForegroundColor Yellow
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To enable full automation, add the missing secrets:" -ForegroundColor White
    Write-Host ""
    Write-Host "Quick Setup:" -ForegroundColor Cyan
    Write-Host "  1. Get NuGet API key: https://www.nuget.org/account/apikeys" -ForegroundColor White
    Write-Host "  2. Go to: https://github.com/johanhenningsson4-hash/ValidateJWT/settings/secrets/actions" -ForegroundColor White
    Write-Host "  3. Click 'New repository secret'" -ForegroundColor White
    Write-Host "  4. Name: NUGET_API_KEY" -ForegroundColor White
    Write-Host "  5. Value: Paste your API key" -ForegroundColor White
    Write-Host ""
    Write-Host "Detailed guide:" -ForegroundColor Cyan
    Write-Host "  See: GITHUB_SECRETS_SETUP.md" -ForegroundColor White
    Write-Host ""
    
    if ($SetupGuide) {
        Write-Host "Opening setup guide..." -ForegroundColor Cyan
        Start-Process "GITHUB_SECRETS_SETUP.md"
    }
}

Write-Host ""

# Check workflows
Write-Host "Checking GitHub Actions workflows..." -ForegroundColor Cyan
Write-Host ""

$workflows = @(
    ".github\workflows\ci-cd.yml",
    ".github\workflows\pr-validation.yml",
    ".github\workflows\nightly-build.yml",
    ".github\workflows\code-coverage.yml"
)

$workflowsExist = $true

foreach ($workflow in $workflows) {
    if (Test-Path $workflow) {
        $name = Split-Path $workflow -Leaf
        Write-Host "  ? $name" -ForegroundColor Green
    } else {
        Write-Host "  ? $workflow - Missing" -ForegroundColor Red
        $workflowsExist = $false
    }
}

Write-Host ""

if ($workflowsExist) {
    Write-Host "All workflow files present! ?" -ForegroundColor Green
    Write-Host ""
    Write-Host "View workflows:" -ForegroundColor Cyan
    Write-Host "  https://github.com/johanhenningsson4-hash/ValidateJWT/actions" -ForegroundColor White
} else {
    Write-Host "Some workflow files are missing!" -ForegroundColor Yellow
    Write-Host "Run Setup-CICD.ps1 to create them." -ForegroundColor White
}

Write-Host ""

# Summary
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Configuration Summary" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$status = if ($allGood -and $workflowsExist) { 
    "?? READY" 
} elseif ($allGood -or $workflowsExist) { 
    "?? PARTIAL" 
} else { 
    "?? SETUP REQUIRED" 
}

Write-Host "Status: $status" -ForegroundColor White
Write-Host ""

if ($allGood -and $workflowsExist) {
    Write-Host "Your ValidateJWT project has full CI/CD automation! ??" -ForegroundColor Green
    Write-Host ""
    Write-Host "Test it:" -ForegroundColor Cyan
    Write-Host "  git commit -m 'test: CI/CD' --allow-empty" -ForegroundColor White
    Write-Host "  git push origin main" -ForegroundColor White
} else {
    Write-Host "Complete setup to enable full automation." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "See: GITHUB_SECRETS_SETUP.md for detailed instructions" -ForegroundColor Cyan
}

Write-Host ""
Read-Host "Press Enter to exit"
