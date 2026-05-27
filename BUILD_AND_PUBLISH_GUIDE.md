# Building and Publishing ValidateJWT v1.6.0

## Quick Build & Package

```powershell
# 1. Clean previous builds
msbuild ValidateJWT.sln /t:Clean /p:Configuration=Release /p:Platform=AnyCPU

# 2. Build in Release mode
msbuild ValidateJWT.sln /p:Configuration=Release /p:Platform=AnyCPU

# 3. Create NuGet package
nuget pack ValidateJWT.nuspec

# 4. Verify package contents
nuget list -Source . ValidateJWT
```

## Detailed Steps

### Step 1: Clean Build

```powershell
msbuild ValidateJWT.sln /t:Clean /p:Configuration=Release /p:Platform=AnyCPU
```

This removes all previous build artifacts.

### Step 2: Build Release

```powershell
msbuild ValidateJWT.sln /p:Configuration=Release /p:Platform=AnyCPU
```

Expected output:
- `bin\Release\Johan.Common.ValidateJWT.dll`
- `bin\Release\Johan.Common.ValidateJWT.xml`

### Step 3: Verify Assembly Version

```powershell
# PowerShell command to check DLL version
[System.Reflection.Assembly]::LoadFile("$PWD\bin\Release\Johan.Common.ValidateJWT.dll").GetName().Version
```

Expected output: `1.6.0.0`

### Step 4: Create NuGet Package

```powershell
nuget pack ValidateJWT.nuspec
```

This creates: `ValidateJWT.1.6.0.nupkg`

### Step 5: Inspect Package (Optional)

```powershell
# List package contents
nuget list -Source . ValidateJWT

# Extract and inspect (optional)
Expand-Archive ValidateJWT.1.6.0.nupkg -DestinationPath temp_package
dir temp_package -Recurse
```

### Step 6: Test Package Locally (Optional)

```powershell
# Add local package source
nuget sources add -Name "LocalTest" -Source "$PWD"

# Install in test project
cd ..\TestConsoleApp
dotnet add package ValidateJWT --version 1.6.0 --source ..\ValidateJWT\
```

### Step 7: Publish to NuGet.org

```powershell
# Set API key (one time)
nuget setApiKey YOUR_API_KEY_HERE

# Push to NuGet.org
nuget push ValidateJWT.1.6.0.nupkg -Source https://api.nuget.org/v3/index.json

# Or use specific API key
nuget push ValidateJWT.1.6.0.nupkg -ApiKey YOUR_API_KEY -Source https://api.nuget.org/v3/index.json
```

## Automated Publishing (If PublishRelease.bat exists)

```powershell
.\PublishRelease.bat -Version "1.6.0"
```

## Post-Publishing Steps

### 1. Create GitHub Release

```powershell
# Tag the release
git tag -a v1.6.0 -m "Release v1.6.0 - Proactive Token Renewal"
git push origin v1.6.0

# Create release on GitHub
# - Go to https://github.com/johanhenningsson4-hash/ValidateJWT/releases/new
# - Tag: v1.6.0
# - Title: ValidateJWT v1.6.0 - Proactive Token Renewal
# - Description: Copy from RELEASE_NOTES_v1.6.0.md
# - Attach: ValidateJWT.1.6.0.nupkg
```

### 2. Update GitHub Repository

```powershell
git add .
git commit -m "Release v1.6.0 - Add proactive token renewal functionality"
git push origin main
```

### 3. Verify NuGet Package

- Visit https://www.nuget.org/packages/ValidateJWT/1.6.0
- Verify metadata, description, tags
- Check that documentation displays correctly

## Package Contents Verification

The `.nupkg` file should contain:

```
ValidateJWT.1.6.0.nupkg
├── lib/
│   └── net472/
│       ├── Johan.Common.ValidateJWT.dll  (v1.6.0.0)
│       └── Johan.Common.ValidateJWT.xml
├── LICENSE.txt
├── README.md
├── icon.png
└── ValidateJWT.nuspec (metadata)
```

## Troubleshooting

### Issue: "Build failed"
```powershell
# Check for compilation errors
msbuild ValidateJWT.sln /p:Configuration=Release /p:Platform=AnyCPU /v:detailed
```

### Issue: "Package already exists"
```powershell
# NuGet.org doesn't allow re-uploading same version
# Bump version to 1.6.1 and rebuild
```

### Issue: "Missing files in package"
```powershell
# Verify files exist
Test-Path "bin\Release\Johan.Common.ValidateJWT.dll"
Test-Path "LICENSE.txt"
Test-Path "README.md"
Test-Path "icon.png"
```

### Issue: "Wrong assembly version"
```powershell
# Rebuild with correct version
msbuild ValidateJWT.sln /t:Rebuild /p:Configuration=Release /p:Platform=AnyCPU
```

## Pre-Flight Checklist

Before publishing:

- [ ] Build successful
- [ ] All 138 tests passing
- [ ] Assembly version is 1.6.0.0
- [ ] NuSpec version is 1.6.0
- [ ] CHANGELOG.md updated
- [ ] README.md updated
- [ ] Release notes created
- [ ] No compilation warnings
- [ ] Documentation XML generated
- [ ] Package contents verified

## Success Indicators

✅ Package builds without errors  
✅ Package size is reasonable (~50-100 KB)  
✅ Assembly version matches NuSpec version  
✅ README displays correctly on NuGet.org  
✅ All dependencies listed correctly (none)  
✅ Tags are appropriate and searchable  

## Package Information

```
Package ID:        ValidateJWT
Version:           1.6.0
Size:              ~XX KB
Downloads:         Check NuGet.org after publish
Framework:         .NET Framework 4.7.2
Dependencies:      None
License:           MIT (or as specified in LICENSE.txt)
Authors:           Johan Henningsson
Repository:        https://github.com/johanhenningsson4-hash/ValidateJWT
```

## Command Reference

```powershell
# Clean
msbuild /t:Clean /p:Configuration=Release /p:Platform=AnyCPU

# Build
msbuild /p:Configuration=Release /p:Platform=AnyCPU

# Pack
nuget pack ValidateJWT.nuspec

# Push
nuget push ValidateJWT.1.6.0.nupkg -Source https://api.nuget.org/v3/index.json
```

---

**Ready to publish ValidateJWT v1.6.0!** 🚀
