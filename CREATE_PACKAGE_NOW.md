# ?? Create NuGet Package - Quick Start

## ? Fastest Way (10 seconds)

**Just double-click this file:**
```
BuildNuGetPackage.bat
```

**That's it!** Package created: `ValidateJWT.1.0.0.nupkg`

---

## ?? What It Does

? Finds Visual Studio automatically  
? Sets up build environment  
? Builds in Release mode  
? Generates XML docs  
? Downloads NuGet.exe if needed  
? Creates package  

---

## ?? Next: Publish

```cmd
nuget push ValidateJWT.1.0.0.nupkg -Source https://api.nuget.org/v3/index.json -ApiKey YOUR_KEY
```

**Get API Key:** https://www.nuget.org/ ? Account Settings ? API Keys

---

## ?? Or Test Locally First

```cmd
mkdir C:\LocalNuGetFeed
nuget add ValidateJWT.1.0.0.nupkg -source C:\LocalNuGetFeed
```

Then install in any project:
```cmd
Install-Package ValidateJWT -Source C:\LocalNuGetFeed
```

---

## ?? Alternative Methods

**Method 2: Developer Command Prompt**
```cmd
cd C:\Jobb\ValidateJWT
.\BuildNuGetPackage.bat
```

**Method 3: Visual Studio**
1. Build ? Configuration ? Release
2. Build ? Build Solution
3. Run: `nuget pack ValidateJWT.nuspec`

---

## ? Files Created

- `BuildNuGetPackage.bat` - Auto build & package (double-click this!)
- `CreateNuGetPackage-DevCmd.ps1` - PowerShell version
- `ValidateJWT.nuspec` - Package specification
- `LICENSE.txt` - MIT License

---

## ?? Full Guide

See `NUGET_PACKAGE_CREATION.md` for complete documentation.

---

**Just double-click `BuildNuGetPackage.bat` to start!** ??
