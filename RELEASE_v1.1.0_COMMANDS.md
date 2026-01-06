# ?? Release v1.1.0 - Quick Command Guide

## ? Fastest Way (Automated)

```cmd
.\PublishRelease_v1.1.0.bat
```

This single command will:
1. ? Build NuGet package v1.1.0
2. ? Verify package contents
3. ? Run tests
4. ? Commit all changes
5. ? Create and push tag v1.1.0
6. ? Create GitHub release
7. ? Publish to NuGet.org (if API key set)

**Time:** ~5-10 minutes

---

## ?? Manual Steps (Alternative)

### Step 1: Build Package
```cmd
msbuild ValidateJWT.csproj /p:Configuration=Release
nuget pack ValidateJWT.nuspec
```

### Step 2: Verify Package
```powershell
.\VerifyNuGetPackage.ps1
```

### Step 3: Commit Changes
```cmd
git add ValidateJWT.cs Properties\AssemblyInfo.cs ValidateJWT.nuspec
git add SIGNATURE_VERIFICATION.md VERSION_1.1.0_READY.md CHANGELOG.md
git commit -m "Release v1.1.0 - JWT Signature Verification"
git push origin main
```

### Step 4: Create Tag
```cmd
git tag -a v1.1.0 -m "v1.1.0 - JWT Signature Verification"
git push origin v1.1.0
```

### Step 5: Create GitHub Release
```
https://github.com/johanhenningsson4-hash/ValidateJWT/releases/new?tag=v1.1.0
```

Or with GitHub CLI:
```cmd
gh release create v1.1.0 --title "ValidateJWT v1.1.0 - JWT Signature Verification" --notes-file VERSION_1.1.0_READY.md
```

### Step 6: Publish to NuGet
```cmd
nuget push ValidateJWT.1.1.0.nupkg -Source https://api.nuget.org/v3/index.json -ApiKey YOUR_KEY
```

---

## ?? API Key Setup

```powershell
# Set API key
$env:NUGET_API_KEY = "your-api-key"

# Or permanent
setx NUGET_API_KEY "your-api-key"
# (Restart terminal after setx)
```

---

## ? Pre-Release Checklist

- [x] ? Version updated to 1.1.0.0
- [x] ? Signature verification code added
- [x] ? Documentation created (SIGNATURE_VERIFICATION.md)
- [x] ? CHANGELOG.md updated
- [x] ? Release script created
- [ ] ? Build successful
- [ ] ? Tests passing
- [ ] ? Package verified
- [ ] ? Changes committed
- [ ] ? Tag created
- [ ] ? GitHub release created
- [ ] ? Published to NuGet

---

## ?? What's Being Released

### Version: 1.1.0 (Minor Feature Release)

**Major New Features:**
- JWT signature verification (HS256, RS256)
- `VerifySignature()` method
- `VerifySignatureRS256()` method
- `JwtVerificationResult` class
- `GetAlgorithm()` helper
- `Base64UrlEncode()` helper

**Compatibility:**
- ? 100% backward compatible
- ? No breaking changes
- ? All v1.0.x code works unchanged

---

## ?? After Release

### Verify on NuGet.org (~15 min)
```
https://www.nuget.org/packages/ValidateJWT/1.1.0
```

### Verify on GitHub
```
https://github.com/johanhenningsson4-hash/ValidateJWT/releases/tag/v1.1.0
```

### Test Installation
```powershell
Install-Package ValidateJWT -Version 1.1.0
```

### Test New Features
```csharp
using Johan.Common;

var result = ValidateJWT.VerifySignature(token, secret);
Console.WriteLine($"Valid: {result.IsValid}");
```

---

## ?? Release Summary

| Item | Value |
|------|-------|
| **Version** | 1.1.0 |
| **Type** | Minor (New Features) |
| **Breaking Changes** | None |
| **New Methods** | 4 |
| **New Classes** | 1 |
| **Documentation** | 3 new files |
| **Compatibility** | 100% with v1.0.x |

---

## ?? Troubleshooting

### "Package already exists"
```powershell
# Version 1.1.0 already published
# Check: https://www.nuget.org/packages/ValidateJWT/1.1.0
```

### "API key invalid"
```powershell
# Regenerate key on NuGet.org
# Update: $env:NUGET_API_KEY = "new-key"
```

### "Git tag exists"
```cmd
# Delete and recreate
git tag -d v1.1.0
git push origin :refs/tags/v1.1.0
git tag -a v1.1.0 -m "v1.1.0"
git push origin v1.1.0
```

---

## ?? Files Changed

```
Modified:
  - ValidateJWT.cs (signature verification added)
  - Properties/AssemblyInfo.cs (v1.1.0.0)
  - ValidateJWT.nuspec (v1.1.0)
  - CHANGELOG.md (v1.1.0 section)

New:
  - SIGNATURE_VERIFICATION.md
  - VERSION_1.1.0_READY.md
  - PublishRelease_v1.1.0.bat
  - RELEASE_v1.1.0_COMMANDS.md (this file)
```

---

## ?? Success Indicators

After successful release:
- ? Tag v1.1.0 visible on GitHub
- ? Release page created with notes
- ? Package shows on NuGet.org search
- ? Can install with Install-Package
- ? README displays on NuGet.org
- ? New methods work as expected

---

**Start Release:** `.\PublishRelease_v1.1.0.bat` ??

*Quick reference for ValidateJWT v1.1.0 release - January 2026*
