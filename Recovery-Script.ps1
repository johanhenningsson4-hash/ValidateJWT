# Recovery Script - Fix Manual Edit Mistakes

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " ValidateJWT Recovery Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$solutionDir = "C:\Jobb\ValidateJWT"

Write-Host "What happened:" -ForegroundColor Yellow
Write-Host "  • Test files had wrong namespace (ValidateJWT.Common)" -ForegroundColor White
Write-Host "  • MSTest packages need to be restored" -ForegroundColor White
Write-Host ""

Write-Host "? GOOD NEWS:" -ForegroundColor Green
Write-Host "  • I've fixed the namespace issues in test files" -ForegroundColor White
Write-Host "  • Test project file looks correct" -ForegroundColor White
Write-Host "  • Main project builds successfully" -ForegroundColor White
Write-Host ""

Write-Host "?? Next Steps:" -ForegroundColor Cyan
Write-Host ""

Write-Host "[Step 1] Restore NuGet Packages" -ForegroundColor Yellow
Write-Host "This will download the MSTest framework" -ForegroundColor White
Write-Host ""
Write-Host "Run this command:" -ForegroundColor Cyan
Write-Host "  nuget restore ValidateJWT.sln" -ForegroundColor White
Write-Host ""
Write-Host "OR in Visual Studio:" -ForegroundColor Cyan
Write-Host "  Right-click Solution ? Restore NuGet Packages" -ForegroundColor White
Write-Host ""

$response = Read-Host "Do you want me to try restoring NuGet packages now? (Y/N)"
if ($response -eq 'Y' -or $response -eq 'y') {
    Write-Host ""
    Write-Host "Attempting NuGet restore..." -ForegroundColor Cyan
    
    # Try different NuGet restore methods
    Push-Location $solutionDir
    
    # Method 1: nuget.exe
    if (Get-Command nuget -ErrorAction SilentlyContinue) {
        Write-Host "Using nuget.exe..." -ForegroundColor Yellow
        nuget restore ValidateJWT.sln
    }
    # Method 2: dotnet restore
    elseif (Get-Command dotnet -ErrorAction SilentlyContinue) {
        Write-Host "Using dotnet restore..." -ForegroundColor Yellow
        dotnet restore ValidateJWT.sln
    }
    # Method 3: msbuild /t:restore
    else {
        Write-Host "Using msbuild /t:restore..." -ForegroundColor Yellow
        msbuild ValidateJWT.sln /t:restore
    }
    
    Pop-Location
    Write-Host ""
    Write-Host "? NuGet restore attempted" -ForegroundColor Green
}

Write-Host ""
Write-Host "[Step 2] Clean and Rebuild" -ForegroundColor Yellow
Write-Host ""
Write-Host "After restoring packages:" -ForegroundColor White
Write-Host "  1. Open ValidateJWT.sln in Visual Studio" -ForegroundColor White
Write-Host "  2. Build ? Clean Solution" -ForegroundColor White
Write-Host "  3. Build ? Rebuild Solution (Ctrl+Shift+B)" -ForegroundColor White
Write-Host ""

Write-Host "[Step 3] Verify Success" -ForegroundColor Yellow
Write-Host ""
Write-Host "Expected output:" -ForegroundColor White
Write-Host "  ? Build succeeded" -ForegroundColor Green
Write-Host "  ? 0 errors, 0 warnings" -ForegroundColor Green
Write-Host "  ? ValidateJWT.dll in bin\Debug\" -ForegroundColor Green
Write-Host "  ? ValidateJWT.Tests.dll in ValidateJWT.Tests\bin\Debug\" -ForegroundColor Green
Write-Host ""

Write-Host "[Step 4] Run Tests" -ForegroundColor Yellow
Write-Host "  Test ? Run All Tests (Ctrl+R, A)" -ForegroundColor White
Write-Host ""
Write-Host "Expected:" -ForegroundColor White
Write-Host "  ? 58 tests passed" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Summary of Fixes Applied" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "? Fixed ValidateJWTTests.cs namespace" -ForegroundColor Green
Write-Host "   Changed: using ValidateJWT.Common;" -ForegroundColor Yellow
Write-Host "   To:      using TPDotNet.MTR.Common;" -ForegroundColor Green
Write-Host ""
Write-Host "? Fixed Base64UrlDecodeTests.cs namespace" -ForegroundColor Green
Write-Host "   Changed: using ValidateJWT.Common;" -ForegroundColor Yellow
Write-Host "   To:      using TPDotNet.MTR.Common;" -ForegroundColor Green
Write-Host ""
Write-Host "? Test project file verified correct" -ForegroundColor Green
Write-Host "   • MSTest references present" -ForegroundColor White
Write-Host "   • Project reference to main project correct" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " What You Need to Do Now" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1??  Open Visual Studio" -ForegroundColor Yellow
Write-Host "2??  Right-click Solution ? Restore NuGet Packages" -ForegroundColor Yellow
Write-Host "3??  Build ? Rebuild Solution" -ForegroundColor Yellow
Write-Host "4??  Test ? Run All Tests" -ForegroundColor Yellow
Write-Host "5??  Success! ??" -ForegroundColor Green
Write-Host ""

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
