# PowerShell NuGet Publishing Guide

## ?? Quick Start

### Simple Usage (Recommended)
```powershell
.\Publish-NuGet.ps1
```

The script will:
1. ? Verify all prerequisites
2. ? Clean previous builds
3. ? Restore NuGet packages
4. ? Build project in Release mode
5. ? Run tests (if available)
6. ? Create NuGet package
7. ? Verify package contents
8. ? Handle Git operations
9. ? Publish to NuGet.org (with confirmation)

---

## ?? Parameters

### Basic Usage

```powershell
# Default behavior (interactive)
.\Publish-NuGet.ps1

# With API key
.\Publish-NuGet.ps1 -ApiKey "your-api-key"

# Specify version
.\Publish-NuGet.ps1 -Version "1.0.1"

# Build locally only (don't publish)
.\Publish-NuGet.ps1 -LocalOnly
```

### Advanced Usage

```powershell
# Skip build (use existing binaries)
.\Publish-NuGet.ps1 -SkipBuild

# Skip tests
.\Publish-NuGet.ps1 -SkipTests

# Skip Git operations
.\Publish-NuGet.ps1 -SkipGit

# Combine options
.\Publish-NuGet.ps1 -SkipTests -SkipGit -ApiKey "key"

# Local package creation only
.\Publish-NuGet.ps1 -LocalOnly -SkipTests
```

---

## ?? API Key Setup

### Method 1: Environment Variable (Recommended)

**PowerShell Session (Temporary):**
```powershell
$env:NUGET_API_KEY = "your-api-key-here"
.\Publish-NuGet.ps1
```

**Permanent (Windows):**
```cmd
setx NUGET_API_KEY "your-api-key-here"
```
Then restart PowerShell and run:
```powershell
.\Publish-NuGet.ps1
```

### Method 2: Script Parameter

```powershell
.\Publish-NuGet.ps1 -ApiKey "your-api-key-here"
```

### Method 3: Interactive Entry

If no API key is provided, the script will prompt you to enter it.

---

## ?? Complete Workflow Examples

### Example 1: First Time Publishing

```powershell
# 1. Set API key (one time)
$env:NUGET_API_KEY = "oy2abc..."

# 2. Run script
.\Publish-NuGet.ps1 -Version "1.0.0"

# Script will:
# - Build the project
# - Run tests
# - Create package
# - Ask to commit/tag in Git
# - Ask to publish to NuGet.org
```

### Example 2: Quick Update Release

```powershell
# Already built and tested, just package and publish
.\Publish-NuGet.ps1 -SkipBuild -SkipTests -Version "1.0.1"
```

### Example 3: Local Package Creation

```powershell
# Create package for testing, don't publish
.\Publish-NuGet.ps1 -LocalOnly
```

### Example 4: Fully Automated

```powershell
# Set everything up front, no interactive prompts needed
$env:NUGET_API_KEY = "your-key"

.\Publish-NuGet.ps1 `
    -Version "1.0.1" `
    -SkipTests `
    -SkipGit
    
# Then confirm publish when prompted
```

---

## ? Prerequisites

### Required
- ? PowerShell 5.1 or later
- ? .NET Framework 4.7.2+ SDK
- ? MSBuild (Visual Studio 2019+ or Build Tools)

### Optional
- ?? NuGet CLI (auto-downloaded if missing)
- ?? Git (for version tagging)
- ?? dotnet CLI (for running tests)

---

## ?? What the Script Does

### Step 1: Prerequisites Check
- Verifies project file exists
- Checks for NuGet CLI (downloads if missing)
- Finds MSBuild installation
- Validates nuspec file

### Step 2: Clean
- Removes `bin\Release\`
- Removes `obj\`
- Deletes old `.nupkg` files

### Step 3: Restore
- Restores NuGet packages for project

### Step 4: Build
- Builds in Release configuration
- Generates XML documentation
- Verifies DLL output

### Step 5: Test
- Runs unit tests if project exists
- Shows test results
- Continues even if tests fail (with warning)

### Step 6: Package
- Runs `nuget pack` with nuspec
- Creates `.nupkg` file
- Shows package size

### Step 7: Verify
- Extracts package to temp directory
- Checks for required files:
  - `ValidateJWT.dll`
  - `ValidateJWT.xml`
  - `README.md`
  - `LICENSE.txt`

### Step 8: Git
- Checks for uncommitted changes
- Offers to commit and push
- Creates version tag
- Pushes tag to remote

### Step 9: Publish
- Validates API key
- Shows confirmation prompt
- Publishes to NuGet.org
- Displays success/failure message

---

## ?? Common Scenarios

### Scenario 1: Development Build
```powershell
# Quick build and package for local testing
.\Publish-NuGet.ps1 -LocalOnly -SkipTests
```

### Scenario 2: CI/CD Pipeline
```powershell
# Non-interactive, fully automated
$env:NUGET_API_KEY = $env:BUILD_NUGET_KEY

.\Publish-NuGet.ps1 `
    -Version $env:BUILD_VERSION `
    -SkipGit
```

### Scenario 3: Hotfix Release
```powershell
# Quick patch, skip tests, don't wait for Git
.\Publish-NuGet.ps1 `
    -Version "1.0.2" `
    -SkipTests `
    -SkipGit
```

### Scenario 4: Major Release
```powershell
# Full workflow with all checks
.\Publish-NuGet.ps1 -Version "2.0.0"
# Confirms: build, test, git commit, git tag, publish
```

---

## ?? Troubleshooting

### "MSBuild not found"
**Solution:**
```powershell
# Use -SkipBuild if you already built in Visual Studio
.\Publish-NuGet.ps1 -SkipBuild

# Or install Visual Studio Build Tools
```

### "Package already exists"
**Error:** Version already published on NuGet.org

**Solution:**
```powershell
# Increment version number
.\Publish-NuGet.ps1 -Version "1.0.2"
```

### "Invalid API key"
**Solutions:**
- Regenerate key on NuGet.org
- Check key has "Push" permission
- Verify key hasn't expired

### "Tests failed"
The script continues with a warning. To stop on test failure:
```powershell
# Manual check first
dotnet test ValidateJWT.Tests\ValidateJWT.Tests.csproj

# Then run script
.\Publish-NuGet.ps1 -SkipTests
```

### "Git not found"
**Solution:**
```powershell
.\Publish-NuGet.ps1 -SkipGit
```

---

## ?? Script Output Example

```
============================================================
  ValidateJWT v1.0.1 - NuGet Publishing Script
============================================================

[Step 1/8] Verifying prerequisites...
  ? NuGet CLI found in PATH
  ? MSBuild found: C:\Program Files\Microsoft Visual Studio\2022\...

[Step 2/8] Cleaning previous builds...
  ? Cleaned bin\Release
  ? Cleaned obj

[Step 3/8] Restoring NuGet packages...
  ? NuGet packages restored

[Step 4/8] Building project in Release mode...
  ? Build successful
    ValidateJWT.dll: 15.2 KB

[Step 5/8] Running tests...
  ? All tests passed

[Step 6/8] Creating NuGet package...
  ? Package created: ValidateJWT.1.0.1.nupkg (48.5 KB)

[Step 7/8] Verifying package contents...
  ? ValidateJWT.dll
  ? ValidateJWT.xml
  ? README.md
  ? LICENSE.txt

[Step 8/8] Git operations...
  ? Working directory clean
  Create and push tag v1.0.1? (Y/N): Y
  ? Tag v1.0.1 created and pushed

============================================================
  Publishing to NuGet.org
============================================================

API key found
Package: ValidateJWT.1.0.1.nupkg
Target: https://api.nuget.org/v3/index.json

Publish to NuGet.org? (Y/N): Y

Publishing...

============================================================
  ? SUCCESS! Package Published to NuGet.org
============================================================

Package: ValidateJWT v1.0.1
URL: https://www.nuget.org/packages/ValidateJWT/1.0.1

? Indexing: Package will be available in ~15 minutes

Install command:
  Install-Package ValidateJWT -Version 1.0.1
```

---

## ?? Security Best Practices

### API Key Management
- ? Use environment variables
- ? Never commit API keys to Git
- ? Set key expiration (365 days)
- ? Regenerate keys periodically
- ? Don't hardcode keys in scripts
- ? Don't share keys in chat/email

### Script Execution
```powershell
# If you get execution policy error:
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Then run:
.\Publish-NuGet.ps1
```

---

## ?? Quick Reference

### Most Common Commands

```powershell
# Standard publish
.\Publish-NuGet.ps1

# With specific version
.\Publish-NuGet.ps1 -Version "1.0.1"

# Local build only
.\Publish-NuGet.ps1 -LocalOnly

# Skip tests and Git
.\Publish-NuGet.ps1 -SkipTests -SkipGit

# With API key parameter
.\Publish-NuGet.ps1 -ApiKey "key" -Version "1.0.1"
```

### Get Help
```powershell
Get-Help .\Publish-NuGet.ps1 -Detailed
```

---

## ?? Success!

After running successfully, your package will be:
- ? Built and packaged
- ? Verified for correctness
- ? Tagged in Git
- ? Published to NuGet.org
- ? Available in ~15 minutes

**Verify at:**
```
https://www.nuget.org/packages/ValidateJWT/1.0.1
```

**Install with:**
```powershell
Install-Package ValidateJWT -Version 1.0.1
```

---

*Last Updated: January 2026*
