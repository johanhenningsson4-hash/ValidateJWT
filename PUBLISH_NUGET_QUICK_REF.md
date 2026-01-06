# ?? Quick Reference - Publish-NuGet.ps1

## ? Quick Start

```powershell
# Simple publish (interactive)
.\Publish-NuGet.ps1

# With API key
.\Publish-NuGet.ps1 -ApiKey "your-key"

# Specific version
.\Publish-NuGet.ps1 -Version "1.0.1"
```

---

## ?? All Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-ApiKey` | string | `$env:NUGET_API_KEY` | NuGet API key |
| `-Version` | string | `"1.0.1"` | Package version |
| `-SkipBuild` | switch | false | Skip building project |
| `-SkipTests` | switch | false | Skip running tests |
| `-SkipGit` | switch | false | Skip Git operations |
| `-LocalOnly` | switch | false | Create package only, don't publish |

---

## ?? Common Commands

```powershell
# Standard workflow
.\Publish-NuGet.ps1

# Quick update (already built)
.\Publish-NuGet.ps1 -SkipBuild -SkipTests

# Local testing
.\Publish-NuGet.ps1 -LocalOnly

# CI/CD (automated)
.\Publish-NuGet.ps1 -SkipGit -Version $BUILD_VERSION

# Full control
.\Publish-NuGet.ps1 `
    -ApiKey "key" `
    -Version "1.0.1" `
    -SkipTests
```

---

## ?? API Key Setup

```powershell
# Session (temporary)
$env:NUGET_API_KEY = "your-key"

# Permanent
setx NUGET_API_KEY "your-key"
# Restart PowerShell after setx
```

---

## ? What It Does

1. ? Verifies prerequisites (NuGet, MSBuild)
2. ? Cleans previous builds
3. ? Restores NuGet packages
4. ? Builds in Release mode
5. ? Runs tests (optional)
6. ? Creates NuGet package
7. ? Verifies package contents
8. ? Handles Git commit/tag
9. ? Publishes to NuGet.org

---

## ?? Quick Fixes

```powershell
# MSBuild not found?
.\Publish-NuGet.ps1 -SkipBuild

# Tests failing?
.\Publish-NuGet.ps1 -SkipTests

# Git issues?
.\Publish-NuGet.ps1 -SkipGit

# Execution policy error?
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

---

## ?? Expected Output

```
[Step 1/8] Verifying prerequisites...
  ? NuGet CLI found
  ? MSBuild found

[Step 2/8] Cleaning previous builds...
  ? Cleaned

[Step 3/8] Restoring packages...
  ? Restored

[Step 4/8] Building...
  ? Build successful

[Step 5/8] Running tests...
  ? Tests passed

[Step 6/8] Creating package...
  ? Package created

[Step 7/8] Verifying...
  ? Verified

[Step 8/8] Git operations...
  ? Tagged

Publishing to NuGet.org...
  ? SUCCESS!
```

---

## ?? Scenarios

| Scenario | Command |
|----------|---------|
| **First publish** | `.\Publish-NuGet.ps1 -Version "1.0.0"` |
| **Update release** | `.\Publish-NuGet.ps1 -Version "1.0.1"` |
| **Local test** | `.\Publish-NuGet.ps1 -LocalOnly` |
| **Quick patch** | `.\Publish-NuGet.ps1 -SkipTests` |
| **CI/CD** | `.\Publish-NuGet.ps1 -SkipGit` |

---

## ?? Package Verification

After publish (wait 15 min):
```
https://www.nuget.org/packages/ValidateJWT/1.0.1
```

Test install:
```powershell
Install-Package ValidateJWT -Version 1.0.1
```

---

**Full guide:** See `PUBLISH_NUGET_GUIDE.md`

*Quick reference for Publish-NuGet.ps1 - January 2026*
