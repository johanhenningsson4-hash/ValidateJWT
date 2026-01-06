# ?? PUBLISH v1.0.0 - QUICK START

## ? Fastest Way (Automated)

**Just run this:**
```batch
.\PublishRelease.bat
```

This will:
1. ? Build NuGet package
2. ? Verify package contents
3. ? Commit changes to Git
4. ? Create and push tag v1.0.0
5. ? Create GitHub release
6. ? Publish to NuGet.org (if API key set)

**Time:** ~5 minutes

---

## ?? What You Need

### Before Starting:

1. **NuGet API Key** (for NuGet.org)
   - Get from: https://www.nuget.org/ ? API Keys
   - Set: `setx NUGET_API_KEY "your-key"`

2. **GitHub CLI** (optional, for automation)
   - Install: `winget install --id GitHub.cli`
   - Login: `gh auth login`

### Your Current Status:

- ? Code ready (`Johan.Common` namespace)
- ? No company references
- ? Tests passing (58+)
- ? Documentation complete
- ? NuGet package configured
- ? MIT License included

**Everything is ready to publish!**

---

## ?? Three Ways to Publish

### Method 1: Fully Automated ? **Easiest**

```batch
.\PublishRelease.bat
```

### Method 2: Semi-Automated

```powershell
# Build & verify
.\BuildNuGetPackage.bat
.\VerifyNuGetPackage.ps1

# Git
git add .
git commit -m "Release v1.0.0"
git push origin main
git tag -a v1.0.0 -m "v1.0.0"
git push origin v1.0.0

# GitHub release
.\CreateGitHubRelease.ps1

# NuGet
.\BuildAndPublish-NuGet.ps1
```

### Method 3: Manual

See `PUBLISH_NOW.md` for step-by-step instructions

---

## ?? After Publishing

### Verify NuGet (wait ~15 min)
```
https://www.nuget.org/packages/ValidateJWT
```

### Verify GitHub
```
https://github.com/johanhenningsson4-hash/ValidateJWT/releases
```

### Test Installation
```powershell
Install-Package ValidateJWT
```

---

## ? Success Checklist

After publishing:

- [ ] ? NuGet package appears in search
- [ ] ? GitHub release is visible
- [ ] ? README displays on NuGet.org
- [ ] ? License displays correctly
- [ ] ? Can install: `Install-Package ValidateJWT`
- [ ] ? Code samples work

---

## ?? You're Publishing:

**Package:** ValidateJWT v1.0.0  
**Namespace:** Johan.Common  
**License:** MIT  
**Features:**
- JWT expiration validation
- Base64URL decoding
- 58+ tests, ~100% coverage
- Zero dependencies

**Your library will be available to everyone!** ??

---

**Start now:** Run `.\PublishRelease.bat` ??

*Complete guide: See PUBLISH_NOW.md*
