# Quick Fix for Test Project
# The main project is building! Just need to fix the test project

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " ValidateJWT Test Project Quick Fix" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Good News:" -ForegroundColor Green
Write-Host "  ? Main project built successfully!" -ForegroundColor White
Write-Host "  ? ValidateJWT.dll created at bin\Debug\" -ForegroundColor White
Write-Host ""

Write-Host "Issue:" -ForegroundColor Yellow
Write-Host "  ? Test project missing System.Xml reference" -ForegroundColor White
Write-Host ""

$projectDir = "C:\Jobb\ValidateJWT"
cd $projectDir

# Check VS is closed
$vsProcesses = Get-Process -Name "devenv" -ErrorAction SilentlyContinue
if ($vsProcesses) {
    Write-Host "? Close Visual Studio and press any key to continue..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

Write-Host "[1/3] Backing up test project file..." -ForegroundColor Cyan
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
copy ValidateJWT.Tests\ValidateJWT.Tests.csproj "ValidateJWT.Tests\ValidateJWT.Tests.csproj.backup_$timestamp"
Write-Host "? Backup created" -ForegroundColor Green
Write-Host ""

Write-Host "[2/3] Applying fix (adding System.Xml reference)..." -ForegroundColor Cyan
copy ValidateJWT.Tests\ValidateJWT.Tests.csproj.FIXED ValidateJWT.Tests\ValidateJWT.Tests.csproj -Force
Write-Host "? Test project file updated" -ForegroundColor Green
Write-Host ""

Write-Host "[3/3] Cleaning test build folder..." -ForegroundColor Cyan
Remove-Item -Recurse -Force ValidateJWT.Tests\bin -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force ValidateJWT.Tests\obj -ErrorAction SilentlyContinue
Write-Host "? Test build folders cleaned" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Fix Applied!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "What was fixed:" -ForegroundColor Yellow
Write-Host "  ? Added System.Xml reference to test project" -ForegroundColor White
Write-Host "  ? This fixes the CS0012 error about XmlWriter type" -ForegroundColor White
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Open ValidateJWT.sln in Visual Studio" -ForegroundColor White
Write-Host "  2. Build ? Rebuild Solution (Ctrl+Shift+B)" -ForegroundColor White
Write-Host "  3. Test ? Run All Tests (Ctrl+R, A)" -ForegroundColor White
Write-Host ""

Write-Host "Expected result:" -ForegroundColor Green
Write-Host "  ? Build: 2 succeeded, 0 failed" -ForegroundColor White
Write-Host "  ? Tests: 58 passed, 0 failed" -ForegroundColor White
Write-Host ""

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
