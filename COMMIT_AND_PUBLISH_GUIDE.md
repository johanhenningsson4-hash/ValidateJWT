# ?? Commit and Publish - Quick Guide

## ? Fastest Way (One Command)

```cmd
.\CommitAndPublish.bat
```

This will:
1. ? Stage all changes
2. ? Commit with comprehensive message
3. ? Push to GitHub
4. ? Create tag v1.1.0
5. ? Create GitHub release
6. ? Build NuGet package
7. ? Optionally publish to NuGet.org

**Time:** ~5 minutes

---

## ?? What Gets Committed

### Code Changes
- ? ValidateJWT.cs (signature verification)
- ? Properties/AssemblyInfo.cs (v1.1.0.0)
- ? ValidateJWT.nuspec (v1.1.0)

### Documentation
- ? README.md (updated for v1.1.0)
- ? CHANGELOG.md (v1.1.0 section)
- ? SIGNATURE_VERIFICATION.md (new feature guide)
- ? VERSION_1.1.0_READY.md (release notes)
- ? RELEASE_v1.1.0_COMMANDS.md (quick ref)
- ? README_UPDATE_SUMMARY.md (update summary)

### Scripts & Tools
- ? Publish-NuGet.ps1 (publishing script)
- ? PublishRelease_v1.1.0.bat (release script)
- ? Cleanup-Code.ps1 (cleanup script)
- ? CLEANUP_PLAN.md (cleanup documentation)
- ? CLEANUP_SUMMARY.md (cleanup summary)
- ? CommitAndPublish.bat (this process)

---

## ?? Manual Steps (Alternative)

### Step 1: Commit Changes
```cmd
git add -A
git commit -m "Release v1.1.0 - JWT Signature Verification"
git push origin main
```

### Step 2: Create Tag
```cmd
git tag -a v1.1.0 -m "v1.1.0 - Signature Verification"
git push origin v1.1.0
```

### Step 3: Create GitHub Release
```
https://github.com/johanhenningsson4-hash/ValidateJWT/releases/new?tag=v1.1.0
```

Or with GitHub CLI:
```cmd
gh release create v1.1.0 --title "ValidateJWT v1.1.0 - JWT Signature Verification" --notes-file VERSION_1.1.0_READY.md
```

### Step 4: Build Package
```cmd
.\BuildNuGetPackage.bat
```

### Step 5: Publish to NuGet
```cmd
nuget push ValidateJWT.1.1.0.nupkg -Source https://api.nuget.org/v3/index.json -ApiKey YOUR_KEY
```

Or:
```powershell
.\Publish-NuGet.ps1 -Version "1.1.0"
```

---

## ?? NuGet API Key

If not set:
```powershell
# Temporary (session only)
$env:NUGET_API_KEY = "your-api-key"

# Permanent
setx NUGET_API_KEY "your-api-key"
# (Restart terminal after setx)
```

Get your key from:
```
https://www.nuget.org/ ? Account ? API Keys ? Create
```

---

## ? Verification Checklist

### After Commit
- [ ] Check GitHub commits: https://github.com/johanhenningsson4-hash/ValidateJWT/commits/main
- [ ] Verify tag exists: https://github.com/johanhenningsson4-hash/ValidateJWT/tags
- [ ] Confirm all files committed

### After GitHub Release
- [ ] Release visible: https://github.com/johanhenningsson4-hash/ValidateJWT/releases/tag/v1.1.0
- [ ] Release notes display correctly
- [ ] Assets attached (if any)

### After NuGet Publish (~15 min)
- [ ] Package searchable: https://www.nuget.org/packages/ValidateJWT/1.1.0
- [ ] README displays on package page
- [ ] LICENSE displays in license tab
- [ ] Can install: `Install-Package ValidateJWT -Version 1.1.0`

### Test Installation
```powershell
# Create test project
dotnet new console -n TestValidateJWT -f net472
cd TestValidateJWT

# Install package
Install-Package ValidateJWT -Version 1.1.0

# Test code
```

```csharp
using Johan.Common;

var token = "eyJhbGci...";
var secret = "test-secret";

// Test time validation
var expired = ValidateJWT.IsExpired(token);
Console.WriteLine($"Expired: {expired}");

// Test signature verification (NEW in v1.1.0)
var result = ValidateJWT.VerifySignature(token, secret);
Console.WriteLine($"Valid: {result.IsValid}");
Console.WriteLine($"Algorithm: {result.Algorithm}");
```

---

## ?? Commit Summary

**Version:** 1.1.0  
**Type:** Minor (New Features)  
**Breaking Changes:** None  
**Backward Compatible:** 100%

**Major Changes:**
- JWT signature verification (HS256, RS256)
- 4 new public methods
- 1 new public class (JwtVerificationResult)
- Comprehensive documentation
- Updated README for NuGet.org

**Files Changed:** ~20 files  
**Lines Added:** ~1,000+  
**Lines Removed:** ~50 (refactoring)

---

## ?? Success Indicators

After completing all steps:

? **GitHub**
- Commits on main branch
- Tag v1.1.0 created
- Release published
- README displays correctly

? **NuGet.org** (~15 min delay)
- Package appears in search
- v1.1.0 is latest version
- README tab shows updated content
- LICENSE tab shows MIT license

? **Installation**
- Package installs successfully
- No dependency errors
- Code samples work
- IntelliSense shows new methods

---

## ?? Troubleshooting

### "Nothing to commit"
```cmd
git status
# Check if files are staged
git add -A
```

### "Tag already exists"
```cmd
git tag -d v1.1.0
git push origin :refs/tags/v1.1.0
# Then recreate
```

### "Push rejected"
```cmd
git pull origin main --rebase
git push origin main
```

### "NuGet push failed"
- Check API key is correct
- Verify key has "Push" permission
- Ensure version doesn't already exist
- Check internet connection

### "GitHub CLI not found"
- Install: `winget install --id GitHub.cli`
- Or use manual GitHub web interface
- Or skip and create release later

---

## ?? Quick Reference

| Task | Command |
|------|---------|
| **Full process** | `.\CommitAndPublish.bat` |
| **Commit only** | `git add -A && git commit -m "Release v1.1.0"` |
| **Tag only** | `git tag -a v1.1.0 -m "v1.1.0"` |
| **Build only** | `.\BuildNuGetPackage.bat` |
| **Publish only** | `.\Publish-NuGet.ps1 -Version "1.1.0"` |
| **Check status** | `git status` |
| **View commits** | `git log --oneline` |

---

## ?? After Release

1. **Announce** (optional)
   - Social media
   - Blog post
   - Developer communities

2. **Monitor**
   - NuGet download stats
   - GitHub stars/forks
   - Issues and feedback

3. **Next Steps**
   - Plan v1.2.0 features
   - Address issues
   - Improve documentation

---

**Ready to release?** Run `.\CommitAndPublish.bat` now! ??

*Quick guide for ValidateJWT v1.1.0 release*
