# ?? CommitAndPublish.ps1 - Usage Guide

## ? Quick Start

### Simplest Usage (Interactive)
```powershell
.\CommitAndPublish.ps1
```
- Prompts for confirmations
- Asks for API key if not set
- Guides you through each step

### With API Key
```powershell
$env:NUGET_API_KEY = "your-api-key-here"
.\CommitAndPublish.ps1
```

### Non-Interactive (CI/CD)
```powershell
.\CommitAndPublish.ps1 -ApiKey "your-key" -Version "1.1.0"
```

---

## ?? Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-ApiKey` | string | `$env:NUGET_API_KEY` | NuGet API key |
| `-Version` | string | `"1.1.0"` | Version to release |
| `-SkipNuGetPublish` | switch | false | Skip NuGet publish |
| `-SkipGitHubRelease` | switch | false | Skip GitHub release |

---

## ?? Usage Examples

### Example 1: Full Release (Default)
```powershell
# Set API key once
$env:NUGET_API_KEY = "oy2abc..."

# Run full release
.\CommitAndPublish.ps1
```

**Does:**
1. ? Commits all changes
2. ? Pushes to GitHub
3. ? Creates tag v1.1.0
4. ? Creates GitHub release
5. ? Builds NuGet package
6. ? Publishes to NuGet.org

---

### Example 2: Skip NuGet Publish
```powershell
# Build and commit, but don't publish to NuGet
.\CommitAndPublish.ps1 -SkipNuGetPublish
```

**Use when:**
- You want to verify package locally first
- Testing the release process
- Publishing manually later

---

### Example 3: Skip GitHub Release
```powershell
# Commit and publish NuGet, but skip GitHub release
.\CommitAndPublish.ps1 -SkipGitHubRelease
```

**Use when:**
- GitHub CLI not installed
- Creating release manually
- Customizing release notes

---

### Example 4: Specify API Key
```powershell
# Pass API key as parameter
.\CommitAndPublish.ps1 -ApiKey "oy2abc123..."
```

**Use when:**
- API key not in environment variable
- Different key for this release
- CI/CD pipeline

---

### Example 5: Custom Version
```powershell
# Release a different version
.\CommitAndPublish.ps1 -Version "1.2.0"
```

**Note:** Ensure version matches your code!

---

### Example 6: Dry Run (No Publish)
```powershell
# Test everything except NuGet publish
.\CommitAndPublish.ps1 -SkipNuGetPublish
```

**Use for:**
- Testing release process
- Verifying package build
- Checking Git operations

---

### Example 7: CI/CD Pipeline
```powershell
# Fully automated (no prompts)
$ErrorActionPreference = "Stop"

.\CommitAndPublish.ps1 `
    -ApiKey $env:NUGET_API_KEY `
    -Version $env:BUILD_VERSION `
    -SkipGitHubRelease
```

---

## ?? What the Script Does

### Step 1: Verify Git Repository
- Checks if directory is a Git repo
- Verifies Git is available
- Shows current status

### Step 2: Show Changes
- Lists all modified files
- Summarizes v1.1.0 changes
- Prompts for confirmation

### Step 3: Stage and Commit
- Stages all changes (`git add -A`)
- Creates comprehensive commit message
- Commits to local repository

### Step 4: Push to GitHub
- Pushes to origin/main
- Handles push failures gracefully
- Shows success confirmation

### Step 5: Create Tag
- Checks if tag exists
- Offers to recreate if exists
- Pushes tag to GitHub
- Uses detailed tag message

### Step 6: GitHub Release
- Uses GitHub CLI if available
- Reads release notes from file
- Creates release on GitHub
- Or shows manual steps

### Step 7: Build Package
- Finds MSBuild
- Builds in Release mode
- Downloads NuGet.exe if needed
- Creates .nupkg file

### Step 8: Publish to NuGet
- Checks for API key
- Prompts for confirmation
- Publishes to NuGet.org
- Shows success/failure

### Step 9: Summary
- Lists completed steps
- Shows relevant links
- Provides next steps

---

## ? Prerequisites

### Required
- ? PowerShell 5.1+
- ? Git installed and in PATH
- ? Visual Studio or MSBuild

### Optional
- ?? GitHub CLI (`gh`) for automated releases
- ?? NuGet CLI (auto-downloaded if missing)
- ?? NuGet API key (for publishing)

---

## ?? Setting Up NuGet API Key

### Method 1: Environment Variable (Recommended)
```powershell
# Temporary (current session)
$env:NUGET_API_KEY = "oy2abc..."

# Permanent (all sessions)
[System.Environment]::SetEnvironmentVariable("NUGET_API_KEY", "oy2abc...", "User")

# Or using setx
setx NUGET_API_KEY "oy2abc..."
# Restart PowerShell after setx
```

### Method 2: Parameter
```powershell
.\CommitAndPublish.ps1 -ApiKey "oy2abc..."
```

### Method 3: Interactive Entry
```powershell
# Script will prompt if not set
.\CommitAndPublish.ps1
# Enter API key now? (Y/N): Y
```

### Get API Key
1. Go to https://www.nuget.org/
2. Sign in
3. Account ? API Keys
4. Create new key
5. Copy the key (shown only once!)

---

## ?? Common Scenarios

### Scenario 1: First Time Release
```powershell
# Set up API key
$env:NUGET_API_KEY = "your-key"

# Run full release
.\CommitAndPublish.ps1

# Wait 15 minutes
# Verify on NuGet.org
```

### Scenario 2: Hotfix Release
```powershell
# Quick release with existing key
.\CommitAndPublish.ps1 -Version "1.1.1"
```

### Scenario 3: Test Build
```powershell
# Build package without publishing
.\CommitAndPublish.ps1 -SkipNuGetPublish
```

### Scenario 4: Manual GitHub Release
```powershell
# Skip GitHub CLI release
.\CommitAndPublish.ps1 -SkipGitHubRelease

# Create release manually at:
# https://github.com/johanhenningsson4-hash/ValidateJWT/releases/new
```

---

## ?? Troubleshooting

### "Script execution disabled"
```powershell
# Allow script execution (current session)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Then run
.\CommitAndPublish.ps1
```

### "Git push failed"
```powershell
# Pull latest changes first
git pull origin main --rebase

# Then run script again
.\CommitAndPublish.ps1
```

### "Tag already exists"
- Script will prompt to delete/recreate
- Or manually: `git tag -d v1.1.0`

### "MSBuild not found"
```powershell
# Build in Visual Studio first
# Or install Visual Studio Build Tools
# Then run with -SkipBuild
```

### "Package already exists on NuGet"
- Version already published
- Increment version number
- NuGet doesn't allow overwriting

### "GitHub CLI not found"
- Install: `winget install --id GitHub.cli`
- Or use `-SkipGitHubRelease`
- Or create release manually

---

## ?? Output Example

```
============================================================
  ValidateJWT v1.1.0 - Commit and Publish Script
  JWT Signature Verification Feature Release
============================================================

Current Changes:

M  Properties/AssemblyInfo.cs
M  README.md
M  CHANGELOG.md
A  SIGNATURE_VERIFICATION.md
...

Summary of v1.1.0 Changes:
  [NEW] Signature verification (HS256, RS256)
  [UPD] README.md - v1.1.0 features
  ...

Continue with commit and publish? (Y/N): Y

[1/7] Staging all changes...
  ? All changes staged

[2/7] Committing changes...
  ? Changes committed

[3/7] Pushing to GitHub (origin/main)...
  ? Pushed to GitHub

[4/7] Creating Git tag v1.1.0...
  ? Tag v1.1.0 created and pushed

[5/7] Creating GitHub Release...
  ? GitHub release created

[6/7] Building NuGet package...
  ? Build successful
  ? Package created: ValidateJWT.1.1.0.nupkg (48.5 KB)

[7/7] Publishing to NuGet.org...
  Publish to NuGet.org? (Y/N): Y
  Publishing...

============================================================
  ? SUCCESS! Package Published to NuGet.org
============================================================

Package: ValidateJWT v1.1.0
URL: https://www.nuget.org/packages/ValidateJWT/1.1.0

? Indexing: Package will be available in ~15 minutes

============================================================
  Release Summary
============================================================

Version: 1.1.0
Status: Released

Completed:
  ? Code committed to Git
  ? Changes pushed to GitHub
  ? Tag v1.1.0 created and pushed
  ? GitHub release created
  ? NuGet package built
  ? Published to NuGet.org

? Release process complete!
```

---

## ?? Comparison with Batch Script

| Feature | PowerShell | Batch |
|---------|------------|-------|
| **Parameters** | ? Yes | ? Limited |
| **Error Handling** | ? Excellent | ?? Basic |
| **Interactive** | ? Yes | ? Yes |
| **Cross-Platform** | ? Yes (.ps1) | ? Windows only |
| **Colors** | ? Rich | ? Basic |
| **Secure Input** | ? Yes | ? No |
| **CI/CD Friendly** | ? Yes | ?? Limited |

---

## ?? Benefits

### PowerShell Script Advantages:
1. **Parameters** - Flexible command-line options
2. **Error Handling** - Better error detection
3. **Secure Input** - SecureString for API keys
4. **Cross-Platform** - Works on Windows, Mac, Linux
5. **Automation** - Perfect for CI/CD pipelines
6. **Reusable** - Easy to integrate into other scripts

---

## ?? Ready to Release?

**Run this command:**
```powershell
.\CommitAndPublish.ps1
```

**Or with API key:**
```powershell
$env:NUGET_API_KEY = "your-key"
.\CommitAndPublish.ps1
```

---

**Your v1.1.0 release will be live in minutes!** ??

*PowerShell script for ValidateJWT v1.1.0 release*
