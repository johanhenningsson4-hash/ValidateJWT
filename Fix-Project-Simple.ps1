# Simple Text-Based Project File Fixer
# This uses text replacement instead of XML manipulation

Write-Host "======================================" -ForegroundColor Cyan
Write-Host " ValidateJWT Project File Fixer v2" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$projectFile = "C:\Jobb\ValidateJWT\ValidateJWT.csproj"

# Check if VS is running
$vsProcesses = Get-Process -Name "devenv" -ErrorAction SilentlyContinue
if ($vsProcesses) {
    Write-Host "? ERROR: Visual Studio is running!" -ForegroundColor Red
    Write-Host "Please close Visual Studio completely and run this script again." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host "? Visual Studio is not running" -ForegroundColor Green
Write-Host ""

# Backup
Write-Host "[1/3] Creating backup..." -ForegroundColor Cyan
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "$projectFile.backup_$timestamp"
Copy-Item $projectFile $backupFile
Write-Host "? Backup: $backupFile" -ForegroundColor Green
Write-Host ""

# Read entire file as text
Write-Host "[2/3] Reading and fixing project file..." -ForegroundColor Cyan
$content = Get-Content $projectFile -Raw

# Track changes
$changesMade = @()

# Fix RootNamespace
if ($content -match '<RootNamespace>ValidateJWT</RootNamespace>') {
    $content = $content -replace '<RootNamespace>ValidateJWT</RootNamespace>', '<RootNamespace>TPDotNet.MTR.Common</RootNamespace>'
    $changesMade += "Fixed RootNamespace"
    Write-Host "  ? Fixed RootNamespace to TPDotNet.MTR.Common" -ForegroundColor Green
}

# Remove test file compile items (one by one)
$testFiles = @(
    'ValidateJWT.Tests\Base64UrlDecodeTests.cs',
    'ValidateJWT.Tests\JwtTestHelper.cs',
    'ValidateJWT.Tests\Properties\AssemblyInfo.cs',
    'ValidateJWT.Tests\ValidateJWTTests.cs'
)

foreach ($file in $testFiles) {
    $pattern = '\s*<Compile Include="' + [regex]::Escape($file) + '" />\r?\n'
    if ($content -match $pattern) {
        $content = $content -replace $pattern, ''
        Write-Host "  ? Removed $file from compile items" -ForegroundColor Green
        $changesMade += "Removed test file: $file"
    }
}

# Remove bad System.Runtime.CompilerServices.Unsafe reference
$pattern = '(?s)<Reference Include="System\.Runtime\.CompilerServices\.Unsafe[^>]*>.*?</Reference>\r?\n'
if ($content -match $pattern) {
    $content = $content -replace $pattern, ''
    Write-Host "  ? Removed bad System.Runtime.CompilerServices.Unsafe reference" -ForegroundColor Green
    $changesMade += "Removed bad Unsafe reference"
}

# Remove unnecessary references
$unnecessaryRefs = @(
    'System.Configuration', 'System.Numerics', 'System.ServiceModel',
    'System.Transactions', 'System.Web', 'System.Web.Extensions',
    'System.Xml.Linq', 'System.Data.DataSetExtensions', 'System.Data',
    'System.Deployment', 'System.Drawing', 'System.Windows.Forms'
)

foreach ($ref in $unnecessaryRefs) {
    $pattern = '\s*<Reference Include="' + [regex]::Escape($ref) + '" />\r?\n'
    if ($content -match $pattern) {
        $content = $content -replace $pattern, ''
        $changesMade += "Removed reference: $ref"
    }
}
if ($changesMade.Count -gt 5) {
    Write-Host "  ? Removed unnecessary references" -ForegroundColor Green
}

# Remove x86 configurations
$pattern = '(?s)<PropertyGroup Condition="[^"]*\|x86[^"]*">.*?</PropertyGroup>\r?\n'
while ($content -match $pattern) {
    $content = $content -replace $pattern, '', 1
}
Write-Host "  ? Removed x86 configurations" -ForegroundColor Green
$changesMade += "Removed x86 configs"

# Remove bad Import for System.ValueTuple
$pattern = '\s*<Import Project="[^"]*TechServices[^"]*System\.ValueTuple[^"]+" [^/]+/>\r?\n'
if ($content -match $pattern) {
    $content = $content -replace $pattern, ''
    Write-Host "  ? Removed bad System.ValueTuple import" -ForegroundColor Green
    $changesMade += "Removed bad ValueTuple import"
}

# Remove problematic NuGet target
$pattern = '(?s)<Target Name="EnsureNuGetPackageBuildImports"[^>]*>.*?</Target>'
if ($content -match $pattern) {
    $content = $content -replace $pattern, ''
    Write-Host "  ? Removed problematic NuGet build target" -ForegroundColor Green
    $changesMade += "Removed NuGet target"
}

# Remove bootstrapper packages
$pattern = '(?s)<ItemGroup>\s*<BootstrapperPackage[^>]*>.*?</ItemGroup>\r?\n'
if ($content -match $pattern) {
    $content = $content -replace $pattern, ''
    Write-Host "  ? Removed bootstrapper packages" -ForegroundColor Green
    $changesMade += "Removed bootstrapper"
}

# Save fixed file
Write-Host ""
Write-Host "[3/3] Saving fixed project file..." -ForegroundColor Cyan
$content | Set-Content $projectFile -NoNewline
Write-Host "? Project file saved" -ForegroundColor Green

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host " ? Fix Complete!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Changes made:" -ForegroundColor Yellow
foreach ($change in $changesMade | Select-Object -Unique) {
    Write-Host "  • $change" -ForegroundColor White
}
Write-Host ""

Write-Host "Backup saved to:" -ForegroundColor Yellow
Write-Host "  $backupFile" -ForegroundColor White
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Delete bin and obj folders:" -ForegroundColor White
Write-Host "     Remove-Item -Recurse -Force bin, obj, ValidateJWT.Tests\bin, ValidateJWT.Tests\obj -ErrorAction SilentlyContinue" -ForegroundColor Cyan
Write-Host ""
Write-Host "  2. Open ValidateJWT.sln in Visual Studio" -ForegroundColor White
Write-Host ""
Write-Host "  3. Build Solution (Ctrl+Shift+B)" -ForegroundColor White
Write-Host ""
Write-Host "  4. Run Tests (Ctrl+R, A)" -ForegroundColor White
Write-Host ""

Write-Host "Expected DLL location:" -ForegroundColor Cyan
Write-Host "  C:\Jobb\ValidateJWT\bin\Debug\ValidateJWT.dll" -ForegroundColor White
Write-Host ""

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
