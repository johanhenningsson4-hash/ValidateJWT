# Setup NuGet API Key Helper Script

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  NuGet API Key Setup Helper" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Check current status
if ($env:NUGET_API_KEY) {
    Write-Host "? NUGET_API_KEY is already set" -ForegroundColor Green
    Write-Host "   Current value: $($env:NUGET_API_KEY.Substring(0, [Math]::Min(8, $env:NUGET_API_KEY.Length)))..." -ForegroundColor Gray
    Write-Host ""
    
    $update = Read-Host "Do you want to update it? (Y/N)"
    if ($update -ne 'Y' -and $update -ne 'y') {
        Write-Host ""
        Write-Host "No changes made. Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 0
    }
    Write-Host ""
} else {
    Write-Host "??  NUGET_API_KEY is not set" -ForegroundColor Yellow
    Write-Host ""
}

# Instructions to get API key
Write-Host "?? How to get your NuGet API Key:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Go to: https://www.nuget.org/" -ForegroundColor White
Write-Host "2. Sign in (or create account)" -ForegroundColor White
Write-Host "3. Click your username > API Keys" -ForegroundColor White
Write-Host "4. Click 'Create' button" -ForegroundColor White
Write-Host "5. Settings:" -ForegroundColor White
Write-Host "   - Name: ValidateJWT" -ForegroundColor Gray
Write-Host "   - Select Scopes: Push" -ForegroundColor Gray
Write-Host "   - Select Packages: * (all)" -ForegroundColor Gray
Write-Host "   - Expiration: 365 days" -ForegroundColor Gray
Write-Host "6. Click 'Create' and copy the key" -ForegroundColor White
Write-Host ""

# Ask for API key
Write-Host "Enter your NuGet API Key (or press Enter to cancel):" -ForegroundColor Cyan
$apiKey = Read-Host -AsSecureString
$apiKeyPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiKey))

if ([string]::IsNullOrWhiteSpace($apiKeyPlainText)) {
    Write-Host ""
    Write-Host "Cancelled. No changes made." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}

Write-Host ""
Write-Host "Choose how to save the API key:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Current PowerShell session only (temporary)" -ForegroundColor White
Write-Host "   ? Works immediately" -ForegroundColor Green
Write-Host "   ? Lost when PowerShell closes" -ForegroundColor Red
Write-Host ""
Write-Host "2. User environment variable (permanent)" -ForegroundColor White
Write-Host "   ? Survives reboots" -ForegroundColor Green
Write-Host "   ??  Need to restart PowerShell" -ForegroundColor Yellow
Write-Host ""
Write-Host "3. Both (recommended)" -ForegroundColor White
Write-Host "   ? Works immediately AND permanent" -ForegroundColor Green
Write-Host ""

$choice = Read-Host "Enter choice (1/2/3)"

switch ($choice) {
    "1" {
        # Session only
        $env:NUGET_API_KEY = $apiKeyPlainText
        Write-Host ""
        Write-Host "? NUGET_API_KEY set for current session" -ForegroundColor Green
        Write-Host "   Valid until you close PowerShell" -ForegroundColor Gray
        Write-Host ""
    }
    "2" {
        # Permanent only
        [System.Environment]::SetEnvironmentVariable("NUGET_API_KEY", $apiKeyPlainText, "User")
        Write-Host ""
        Write-Host "? NUGET_API_KEY saved permanently" -ForegroundColor Green
        Write-Host "   ??  Restart PowerShell for it to take effect" -ForegroundColor Yellow
        Write-Host ""
    }
    "3" {
        # Both
        $env:NUGET_API_KEY = $apiKeyPlainText
        [System.Environment]::SetEnvironmentVariable("NUGET_API_KEY", $apiKeyPlainText, "User")
        Write-Host ""
        Write-Host "? NUGET_API_KEY set for current session" -ForegroundColor Green
        Write-Host "? NUGET_API_KEY saved permanently" -ForegroundColor Green
        Write-Host "   Works immediately AND survives restarts!" -ForegroundColor Gray
        Write-Host ""
    }
    default {
        Write-Host ""
        Write-Host "Invalid choice. No changes made." -ForegroundColor Red
        Write-Host ""
        Write-Host "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
}

# Verify
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "?? API Key Status:" -ForegroundColor Yellow
if ($env:NUGET_API_KEY) {
    Write-Host "   Current Session: ? Set ($($env:NUGET_API_KEY.Substring(0, [Math]::Min(8, $env:NUGET_API_KEY.Length)))...)" -ForegroundColor Green
} else {
    Write-Host "   Current Session: ? Not set (restart PowerShell)" -ForegroundColor Red
}

$permanentKey = [System.Environment]::GetEnvironmentVariable("NUGET_API_KEY", "User")
if ($permanentKey) {
    Write-Host "   Permanent: ? Saved ($($permanentKey.Substring(0, [Math]::Min(8, $permanentKey.Length)))...)" -ForegroundColor Green
} else {
    Write-Host "   Permanent: ? Not saved" -ForegroundColor Red
}
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1??  Run the build script:" -ForegroundColor Cyan
Write-Host "   .\BuildAndPublish-NuGet.ps1" -ForegroundColor White
Write-Host ""
Write-Host "2??  Or test that API key works:" -ForegroundColor Cyan
Write-Host '   nuget list -Source https://api.nuget.org/v3/index.json -ApiKey $env:NUGET_API_KEY' -ForegroundColor White
Write-Host ""

Write-Host "?? Security Notes:" -ForegroundColor Yellow
Write-Host "   • Never share your API key" -ForegroundColor White
Write-Host "   • Don't commit it to Git" -ForegroundColor White
Write-Host "   • Set expiration (e.g., 365 days)" -ForegroundColor White
Write-Host "   • Regenerate periodically" -ForegroundColor White
Write-Host ""

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
