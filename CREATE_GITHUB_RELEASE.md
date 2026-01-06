# ?? Create GitHub Release - Quick Start

## ? Super Fast (30 seconds)

**Just run:**
```powershell
.\CreateGitHubRelease.ps1
```

**That's it!** Release will be created automatically! ??

---

## ?? What It Does

1. ? Checks Git status
2. ? Builds in Release mode
3. ? Creates `ValidateJWT-v1.0.0.zip`
4. ? Creates Git tag `v1.0.0`
5. ? Pushes tag to GitHub
6. ? Creates GitHub Release
7. ? Uploads binaries

**Time:** ~30 seconds  
**Result:** Live release at https://github.com/johanhenningsson4-hash/ValidateJWT/releases

---

## ?? Prerequisites

### Optional: GitHub CLI (for automation)
```powershell
winget install --id GitHub.cli
gh auth login
```

**Without GitHub CLI:** Script will show manual steps

---

## ?? What Gets Released

| File | Size | Purpose |
|------|------|---------|
| ValidateJWT-v1.0.0.zip | ~50 KB | Complete package |
| ValidateJWT.dll | ~15 KB | Library binary |
| ValidateJWT.xml | ~10 KB | IntelliSense docs |

Plus auto-generated source code (zip/tar.gz)

---

## ?? Three Methods

### Method 1: Automated ? **Easiest**
```powershell
.\CreateGitHubRelease.ps1
```

### Method 2: GitHub CLI
```powershell
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
gh release create v1.0.0 --notes-file RELEASE_NOTES_v1.0.0.md ValidateJWT-v1.0.0.zip
```

### Method 3: Manual
1. Build in Visual Studio (Release)
2. Create zip of binaries
3. Push tag: `git tag v1.0.0 && git push origin v1.0.0`
4. Go to GitHub ? Releases ? Draft new release
5. Upload files

---

## ? Before Release Checklist

- [x] ? Code committed to main
- [x] ? Version in nuspec: 1.0.0
- [x] ? Version in AssemblyInfo: 1.0.0.0
- [x] ? CHANGELOG.md updated
- [x] ? Tests passing (58+)
- [x] ? Build succeeds
- [ ] ? Run `.\CreateGitHubRelease.ps1`

---

## ?? After Release

**View at:**
```
https://github.com/johanhenningsson4-hash/ValidateJWT/releases/tag/v1.0.0
```

**Users can:**
- Download binaries
- Install from NuGet: `Install-Package ValidateJWT`
- Clone version: `git clone --branch v1.0.0 ...`

---

## ?? If Something Fails

### Build fails
```powershell
# Build manually in Visual Studio first
# Then run script again
```

### Tag exists
```powershell
# Delete and recreate
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0
.\CreateGitHubRelease.ps1
```

### GitHub CLI not found
Script will show manual steps. Or install:
```powershell
winget install --id GitHub.cli
```

---

## ?? Full Guide

See `GITHUB_RELEASE_GUIDE.md` for complete documentation.

---

**Ready?** Run this now:
```powershell
.\CreateGitHubRelease.ps1
```

?? **Your release will be live in 30 seconds!** ??

---

*ValidateJWT v1.0.0 - January 2026*
