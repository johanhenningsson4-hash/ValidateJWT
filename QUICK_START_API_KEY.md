# ?? Quick Start - Build & Publish with API Key

## ? Super Fast Setup (2 minutes)

### Step 1: Get API Key (1 minute)
```
https://www.nuget.org/ ? Sign In ? API Keys ? Create
```
Copy the key!

### Step 2: Run Setup Script (30 seconds)
```powershell
.\SetupNuGetApiKey.ps1
```
Paste your key when prompted ? Choose option 3 (both)

### Step 3: Build & Publish (30 seconds)
```powershell
.\BuildAndPublish-NuGet.ps1
```
Press Y when asked to publish

**Done!** Package will be on NuGet.org in ~15 minutes! ??

---

## ?? Three Scripts Available

| Script | Purpose | When to Use |
|--------|---------|-------------|
| **SetupNuGetApiKey.ps1** | Set API key | First time or key update |
| **BuildAndPublish-NuGet.ps1** | Build + Publish | Publish new version |
| **BuildNuGetPackage.bat** | Build only | Local testing |

---

## ?? Workflows

### First Time Publishing
```powershell
# 1. Setup API key
.\SetupNuGetApiKey.ps1

# 2. Build and publish
.\BuildAndPublish-NuGet.ps1
```

### Update Package (New Version)
```powershell
# 1. Update version in ValidateJWT.nuspec
# 2. Update version in AssemblyInfo.cs
# 3. Build and publish
.\BuildAndPublish-NuGet.ps1
```

### Test Locally First
```powershell
# 1. Build without API key
$env:NUGET_API_KEY = $null
.\BuildAndPublish-NuGet.ps1

# 2. Test locally
mkdir C:\LocalNuGetFeed
nuget add ValidateJWT.1.0.0.nupkg -source C:\LocalNuGetFeed

# 3. If OK, set key and publish
.\SetupNuGetApiKey.ps1
.\BuildAndPublish-NuGet.ps1
```

---

## ?? API Key Commands

### Set (Session)
```powershell
$env:NUGET_API_KEY = "your-key-here"
```

### Set (Permanent)
```powershell
setx NUGET_API_KEY "your-key-here"
# Then restart PowerShell
```

### Check Status
```powershell
echo $env:NUGET_API_KEY
```

### Remove
```powershell
$env:NUGET_API_KEY = $null
```

---

## ? File Summary

### Created for API Key Workflow:
- ? `BuildAndPublish-NuGet.ps1` - Main build & publish script
- ? `SetupNuGetApiKey.ps1` - Helper to set API key
- ? `NUGET_API_KEY_GUIDE.md` - Complete documentation
- ? `QUICK_START_API_KEY.md` - This file

### Already Have:
- ? `ValidateJWT.nuspec` - Package specification
- ? `LICENSE.txt` - MIT license
- ? `BuildNuGetPackage.bat` - Build-only script
- ? All documentation files

---

## ?? Advantages of This Approach

| Feature | Benefit |
|---------|---------|
| **Secure** | API key not in code |
| **Automated** | One script does everything |
| **Interactive** | Confirms before publishing |
| **Flexible** | Can build without publishing |
| **CI/CD Ready** | Works with GitHub Actions |

---

## ?? Complete Example

```powershell
# First time setup
PS C:\Jobb\ValidateJWT> .\SetupNuGetApiKey.ps1
Enter your NuGet API Key: ****
Choose how to save: 3
? Setup Complete!

# Build and publish
PS C:\Jobb\ValidateJWT> .\BuildAndPublish-NuGet.ps1
? NUGET_API_KEY found
[Building...]
? Package created: ValidateJWT.1.0.0.nupkg
Publish now? (Y/N): Y
[Publishing...]
? SUCCESS! Package Published to NuGet.org
?? URL: https://www.nuget.org/packages/ValidateJWT
```

**That's it!** Package is live! ??

---

## ?? Need Help?

**Full Guide:** `NUGET_API_KEY_GUIDE.md`  
**General NuGet Guide:** `NUGET_PACKAGE_CREATION.md`

---

**Start now:** Run `.\SetupNuGetApiKey.ps1` ??
