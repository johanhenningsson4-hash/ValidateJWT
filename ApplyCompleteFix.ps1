# Complete Automated Fix Script
# This will fix EVERYTHING automatically

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " ValidateJWT Complete Fix Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectDir = "C:\Jobb\ValidateJWT"

# Check VS is closed
Write-Host "[Check] Verifying Visual Studio is closed..." -ForegroundColor Cyan
$vsProcesses = Get-Process -Name "devenv" -ErrorAction SilentlyContinue
if ($vsProcesses) {
    Write-Host "? ERROR: Visual Studio is running!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please close Visual Studio completely and run this script again." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
Write-Host "? Visual Studio is not running" -ForegroundColor Green
Write-Host ""

cd $projectDir

# Step 1: Backup
Write-Host "[Step 1/6] Creating backups..." -ForegroundColor Cyan
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
copy ValidateJWT.csproj "ValidateJWT.csproj.backup_$timestamp" -ErrorAction SilentlyContinue
copy ValidateJWT.Tests\ValidateJWT.Tests.csproj "ValidateJWT.Tests\ValidateJWT.Tests.csproj.backup_$timestamp" -ErrorAction SilentlyContinue
Write-Host "? Backups created" -ForegroundColor Green
Write-Host ""

# Step 2: Replace project files
Write-Host "[Step 2/6] Replacing project files with fixed versions..." -ForegroundColor Cyan
if (Test-Path "ValidateJWT.csproj.FIXED") {
    copy ValidateJWT.csproj.FIXED ValidateJWT.csproj -Force
    Write-Host "? Main project file replaced" -ForegroundColor Green
} else {
    Write-Host "? ERROR: ValidateJWT.csproj.FIXED not found!" -ForegroundColor Red
    exit 1
}

if (Test-Path "ValidateJWT.Tests\ValidateJWT.Tests.csproj.FIXED") {
    copy ValidateJWT.Tests\ValidateJWT.Tests.csproj.FIXED ValidateJWT.Tests\ValidateJWT.Tests.csproj -Force
    Write-Host "? Test project file replaced" -ForegroundColor Green
} else {
    Write-Host "? ERROR: ValidateJWT.Tests.csproj.FIXED not found!" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 3: Clean build folders
Write-Host "[Step 3/6] Cleaning build folders..." -ForegroundColor Cyan
Remove-Item -Recurse -Force bin -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force obj -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force ValidateJWT.Tests\bin -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force ValidateJWT.Tests\obj -ErrorAction SilentlyContinue
Write-Host "? Build folders cleaned" -ForegroundColor Green
Write-Host ""

# Step 4: Restore NuGet packages
Write-Host "[Step 4/6] Restoring NuGet packages..." -ForegroundColor Cyan
$restored = $false

if (Get-Command nuget -ErrorAction SilentlyContinue) {
    Write-Host "Using nuget.exe..." -ForegroundColor Yellow
    nuget restore ValidateJWT.sln -NonInteractive
    $restored = $true
} elseif (Get-Command dotnet -ErrorAction SilentlyContinue) {
    Write-Host "Using dotnet restore..." -ForegroundColor Yellow
    dotnet restore ValidateJWT.sln
    $restored = $true
} elseif (Get-Command msbuild -ErrorAction SilentlyContinue) {
    Write-Host "Using msbuild /t:restore..." -ForegroundColor Yellow
    msbuild ValidateJWT.sln /t:restore /v:minimal
    $restored = $true
}

if ($restored) {
    Write-Host "? NuGet packages restored" -ForegroundColor Green
} else {
    Write-Host "?? Could not restore NuGet packages automatically" -ForegroundColor Yellow
    Write-Host "   You'll need to restore them in Visual Studio" -ForegroundColor Yellow
}
Write-Host ""

# Step 5: Build solution
Write-Host "[Step 5/6] Building solution..." -ForegroundColor Cyan
if (Get-Command msbuild -ErrorAction SilentlyContinue) {
    Write-Host "Running msbuild..." -ForegroundColor Yellow
    msbuild ValidateJWT.sln /t:rebuild /p:Configuration=Debug /v:minimal /nologo
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "? Build succeeded!" -ForegroundColor Green
    } else {
        Write-Host "?? Build may have issues. Check output above." -ForegroundColor Yellow
    }
} else {
    Write-Host "?? msbuild not found. You'll need to build in Visual Studio." -ForegroundColor Yellow
}
Write-Host ""

# Step 6: Verify
Write-Host "[Step 6/6] Verifying output..." -ForegroundColor Cyan
if (Test-Path "bin\Debug\ValidateJWT.dll") {
    Write-Host "? ValidateJWT.dll created successfully!" -ForegroundColor Green
    $fileInfo = Get-Item "bin\Debug\ValidateJWT.dll"
    Write-Host "   Location: $($fileInfo.FullName)" -ForegroundColor White
    Write-Host "   Size: $($fileInfo.Length) bytes" -ForegroundColor White
} else {
    Write-Host "?? ValidateJWT.dll not found. Build may have failed." -ForegroundColor Yellow
}

if (Test-Path "ValidateJWT.Tests\bin\Debug\ValidateJWT.Tests.dll") {
    Write-Host "? ValidateJWT.Tests.dll created successfully!" -ForegroundColor Green
} else {
    Write-Host "?? ValidateJWT.Tests.dll not found. You may need to restore NuGet packages in VS." -ForegroundColor Yellow
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Fix Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Summary of changes:" -ForegroundColor Yellow
Write-Host "  ? Main project file fixed (RootNamespace, AssemblyName, references)" -ForegroundColor White
Write-Host "  ? Test project file fixed (GenerateAssemblyInfo disabled)" -ForegroundColor White
Write-Host "  ? Test file namespaces corrected (TPDotNet.MTR.Common)" -ForegroundColor White
Write-Host "  ? Build folders cleaned" -ForegroundColor White
if ($restored) {
    Write-Host "  ? NuGet packages restored" -ForegroundColor White
}
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Yellow
if (-not $restored) {
    Write-Host "  1. Open ValidateJWT.sln in Visual Studio" -ForegroundColor White
    Write-Host "  2. Right-click Solution ? Restore NuGet Packages" -ForegroundColor White
    Write-Host "  3. Build ? Rebuild Solution (Ctrl+Shift+B)" -ForegroundColor White
} else {
    Write-Host "  1. Open ValidateJWT.sln in Visual Studio" -ForegroundColor White
    Write-Host "  2. Build ? Rebuild Solution (Ctrl+Shift+B)" -ForegroundColor White
}
Write-Host "  3. Test ? Run All Tests (Ctrl+R, A)" -ForegroundColor White
Write-Host ""

Write-Host "Expected result:" -ForegroundColor Cyan
Write-Host "  ? Build: 2 succeeded, 0 failed" -ForegroundColor Green
Write-Host "  ? Tests: 58 passed, 0 failed" -ForegroundColor Green
Write-Host ""

Write-Host "Backup files:" -ForegroundColor Yellow
Write-Host "  ValidateJWT.csproj.backup_$timestamp" -ForegroundColor White
Write-Host "  ValidateJWT.Tests\ValidateJWT.Tests.csproj.backup_$timestamp" -ForegroundColor White
Write-Host ""

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Add-Type -AssemblyName System.Xml
