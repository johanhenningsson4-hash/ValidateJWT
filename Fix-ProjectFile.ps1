# Automatic Project Fix Script for ValidateJWT
# This script will clean up the project file to enable building

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " ValidateJWT Project File Auto-Fixer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectPath = "C:\Jobb\ValidateJWT"
$projectFile = "$projectPath\ValidateJWT.csproj"
$backupFile = "$projectPath\ValidateJWT.csproj.backup"

# Check if Visual Studio is running
$vsProcesses = Get-Process -Name "devenv" -ErrorAction SilentlyContinue
if ($vsProcesses) {
    Write-Host "??  WARNING: Visual Studio is currently running!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please close Visual Studio before running this script." -ForegroundColor Yellow
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

Write-Host "? Visual Studio is not running - safe to proceed" -ForegroundColor Green
Write-Host ""

# Backup original file
Write-Host "[1/6] Creating backup..." -ForegroundColor Cyan
if (Test-Path $backupFile) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFile = "$projectPath\ValidateJWT.csproj.backup_$timestamp"
}
Copy-Item $projectFile $backupFile
Write-Host "? Backup created: $backupFile" -ForegroundColor Green
Write-Host ""

# Read project file
Write-Host "[2/6] Reading project file..." -ForegroundColor Cyan
$xml = [xml](Get-Content $projectFile)
$ns = @{msbuild = 'http://schemas.microsoft.com/developer/msbuild/2003'}

# Fix AssemblyName and RootNamespace
Write-Host "[3/6] Fixing project properties..." -ForegroundColor Cyan
$assemblyNameNode = $xml.SelectSingleNode("//msbuild:AssemblyName", $ns)
if ($assemblyNameNode.InnerText -ne "ValidateJWT") {
    $assemblyNameNode.InnerText = "ValidateJWT"
    Write-Host "  ? Fixed AssemblyName to 'ValidateJWT'" -ForegroundColor Green
}

$rootNamespaceNode = $xml.SelectSingleNode("//msbuild:RootNamespace", $ns)
if ($rootNamespaceNode.InnerText -ne "TPDotNet.MTR.Common") {
    $rootNamespaceNode.InnerText = "TPDotNet.MTR.Common"
    Write-Host "  ? Fixed RootNamespace to 'TPDotNet.MTR.Common'" -ForegroundColor Green
}

# Fix output paths to standard defaults
$debugConfig = $xml.SelectSingleNode("//msbuild:PropertyGroup[contains(@Condition, 'Debug|AnyCPU')]/msbuild:OutputPath", $ns)
if ($debugConfig -and $debugConfig.InnerText -ne "bin\Debug\") {
    $debugConfig.InnerText = "bin\Debug\"
    Write-Host "  ? Fixed Debug output path to 'bin\Debug\'" -ForegroundColor Green
}

$releaseConfig = $xml.SelectSingleNode("//msbuild:PropertyGroup[contains(@Condition, 'Release|AnyCPU')]/msbuild:OutputPath", $ns)
if ($releaseConfig -and $releaseConfig.InnerText -ne "bin\Release\") {
    $releaseConfig.InnerText = "bin\Release\"
    Write-Host "  ? Fixed Release output path to 'bin\Release\'" -ForegroundColor Green
}

# Remove external references
Write-Host "[4/6] Removing problematic references..." -ForegroundColor Cyan
$removed = 0

# Remove TPDotnet.Base.Service
$badRefs = $xml.SelectNodes("//msbuild:Reference[@Include='TPDotnet.Base.Service']", $ns)
foreach ($ref in $badRefs) {
    $ref.ParentNode.RemoveChild($ref) | Out-Null
    Write-Host "  ? Removed TPDotnet.Base.Service reference" -ForegroundColor Green
    $removed++
}

# Remove System.Runtime.CompilerServices.Unsafe (bad path)
$badRefs = $xml.SelectNodes("//msbuild:Reference[@Include='System.Runtime.CompilerServices.Unsafe']", $ns)
foreach ($ref in $badRefs) {
    $hintPath = $ref.SelectSingleNode("msbuild:HintPath", $ns)
    if ($hintPath -and $hintPath.InnerText.Contains("TechServices")) {
        $ref.ParentNode.RemoveChild($ref) | Out-Null
        Write-Host "  ? Removed bad System.Runtime.CompilerServices.Unsafe reference" -ForegroundColor Green
        $removed++
    }
}

# Remove unnecessary references
$unnecessaryRefs = @(
    'System.Configuration', 'System.Numerics', 'System.ServiceModel',
    'System.Transactions', 'System.Web', 'System.Web.Extensions',
    'System.Xml.Linq', 'System.Data.DataSetExtensions', 'System.Data',
    'System.Deployment', 'System.Drawing', 'System.Windows.Forms'
)

foreach ($refName in $unnecessaryRefs) {
    $refs = $xml.SelectNodes("//msbuild:Reference[@Include='$refName']", $ns)
    foreach ($ref in $refs) {
        $ref.ParentNode.RemoveChild($ref) | Out-Null
        $removed++
    }
}
Write-Host "  ? Removed $removed unnecessary references" -ForegroundColor Green

# Remove test files from compile items
Write-Host "[5/6] Cleaning up project structure..." -ForegroundColor Cyan
$testFiles = @(
    'ValidateJWT.Tests\Base64UrlDecodeTests.cs',
    'ValidateJWT.Tests\JwtTestHelper.cs',
    'ValidateJWT.Tests\Properties\AssemblyInfo.cs',
    'ValidateJWT.Tests\ValidateJWTTests.cs'
)

$testFilesRemoved = 0
foreach ($testFile in $testFiles) {
    $compileItems = $xml.SelectNodes("//msbuild:Compile[@Include='$testFile']", $ns)
    foreach ($item in $compileItems) {
        $item.ParentNode.RemoveChild($item) | Out-Null
        $testFilesRemoved++
    }
}
if ($testFilesRemoved -gt 0) {
    Write-Host "  ? Removed $testFilesRemoved test files from main project" -ForegroundColor Green
}

# Remove x86 configurations
$x86Configs = $xml.SelectNodes("//msbuild:PropertyGroup[contains(@Condition, 'x86')]", $ns)
if ($x86Configs.Count -gt 0) {
    foreach ($config in $x86Configs) {
        $config.ParentNode.RemoveChild($config) | Out-Null
    }
    Write-Host "  ? Removed x86 platform configurations" -ForegroundColor Green
}

# Remove bootstrapper packages
$bootstrappers = $xml.SelectNodes("//msbuild:BootstrapperPackage", $ns)
if ($bootstrappers.Count -gt 0) {
    $bootstrappers[0].ParentNode.ParentNode.RemoveChild($bootstrappers[0].ParentNode) | Out-Null
    Write-Host "  ? Removed bootstrapper packages" -ForegroundColor Green
}

# Remove bad Import statements
Write-Host "[6/6] Cleaning up import statements..." -ForegroundColor Cyan
$imports = $xml.SelectNodes("//msbuild:Import[contains(@Project, 'TechServices')]", $ns)
foreach ($import in $imports) {
    $import.ParentNode.RemoveChild($import) | Out-Null
    Write-Host "  ? Removed bad import statement" -ForegroundColor Green
}

# Remove EnsureNuGetPackageBuildImports target with bad paths
$targets = $xml.SelectNodes("//msbuild:Target[@Name='EnsureNuGetPackageBuildImports']", $ns)
foreach ($target in $targets) {
    $errors = $target.SelectNodes("msbuild:Error[contains(@Condition, 'TechServices')]", $ns)
    if ($errors.Count -gt 0) {
        $target.ParentNode.RemoveChild($target) | Out-Null
        Write-Host "  ? Removed problematic NuGet import target" -ForegroundColor Green
    }
}

# Save fixed project file
$xml.Save($projectFile)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " ? Project File Fixed Successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Summary of changes:" -ForegroundColor Yellow
Write-Host "  • Fixed AssemblyName to 'ValidateJWT'" -ForegroundColor White
Write-Host "  • Fixed RootNamespace to 'TPDotNet.MTR.Common'" -ForegroundColor White
Write-Host "  • Fixed output paths to standard defaults (bin\Debug\, bin\Release\)" -ForegroundColor White
Write-Host "  • Removed external TPDotnet.Base.Service reference" -ForegroundColor White
Write-Host "  • Removed $removed problematic references" -ForegroundColor White
Write-Host "  • Removed test files from main project" -ForegroundColor White
Write-Host "  • Cleaned up unnecessary configurations" -ForegroundColor White
Write-Host ""

Write-Host "Backup saved to:" -ForegroundColor Yellow
Write-Host "  $backupFile" -ForegroundColor White
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Open ValidateJWT.sln in Visual Studio" -ForegroundColor White
Write-Host "  2. Build Solution (Ctrl+Shift+B)" -ForegroundColor White
Write-Host "  3. Run All Tests (Ctrl+R, A)" -ForegroundColor White
Write-Host ""

Write-Host "Expected output DLL location:" -ForegroundColor Cyan
Write-Host "  C:\Jobb\ValidateJWT\bin\Debug\ValidateJWT.dll" -ForegroundColor White
Write-Host "  C:\Jobb\ValidateJWT\bin\Release\ValidateJWT.dll" -ForegroundColor White
Write-Host ""

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
