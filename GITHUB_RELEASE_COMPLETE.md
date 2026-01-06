# ?? GitHub Release System - Complete!

## ? Files Created

| File | Purpose |
|------|---------|
| **CreateGitHubRelease.ps1** | Automated release creation script |
| **GITHUB_RELEASE_GUIDE.md** | Complete guide with all methods |
| **CREATE_GITHUB_RELEASE.md** | Quick start guide |

---

## ?? How to Create Release

### **Fastest Way (30 seconds):**

```powershell
.\CreateGitHubRelease.ps1
```

**Done!** Release created at:
```
https://github.com/johanhenningsson4-hash/ValidateJWT/releases/tag/v1.0.0
```

---

## ?? What the Script Does

### Automatic Process:

1. **Checks Git Status**
   - Verifies working directory is clean
   - Offers to commit uncommitted changes

2. **Builds Release Binaries**
   - Finds MSBuild automatically
   - Builds in Release mode
   - Generates XML documentation

3. **Creates Release Package**
   - Creates `Release-v1.0.0` folder
   - Copies all release files
   - Creates `ValidateJWT-v1.0.0.zip` (complete package)

4. **Creates Git Tag**
   - Creates annotated tag `v1.0.0`
   - Includes detailed tag message

5. **Pushes to GitHub**
   - Pushes tag to remote

6. **Creates GitHub Release**
   - Uses GitHub CLI if available
   - Otherwise shows manual instructions
   - Uploads release assets:
     - ValidateJWT-v1.0.0.zip
     - ValidateJWT.dll
     - ValidateJWT.xml

---

## ?? Three Methods Available

### Method 1: Automated Script ? **Recommended**

```powershell
.\CreateGitHubRelease.ps1
```

**Advantages:**
- ? Fully automated
- ? Builds, tags, and releases
- ? Uploads all assets
- ? No manual steps

**Requirements:**
- Visual Studio or MSBuild
- Optional: GitHub CLI (`gh`)

---

### Method 2: GitHub CLI

```powershell
# Prerequisites
winget install --id GitHub.cli
gh auth login

# Create release
git tag -a v1.0.0 -m "ValidateJWT v1.0.0 - Initial Release"
git push origin v1.0.0

gh release create v1.0.0 `
    --title "ValidateJWT v1.0.0 - Initial Release" `
    --notes-file RELEASE_NOTES_v1.0.0.md `
    ValidateJWT-v1.0.0.zip `
    bin\Release\ValidateJWT.dll `
    bin\Release\ValidateJWT.xml
```

**Advantages:**
- ? Command-line automation
- ? CI/CD friendly
- ? Scriptable

---

### Method 3: Manual (GitHub Web UI)

**Steps:**

1. **Build**
   - Visual Studio ? Release ? Build Solution

2. **Create Package**
   - Zip: `bin\Release\ValidateJWT.dll`, `.xml`, `.pdb` + docs

3. **Tag**
   ```powershell
   git tag -a v1.0.0 -m "Release message"
   git push origin v1.0.0
   ```

4. **Release**
   - Go to: https://github.com/johanhenningsson4-hash/ValidateJWT/releases/new
   - Select tag: v1.0.0
   - Title: ValidateJWT v1.0.0 - Initial Release
   - Description: Copy from RELEASE_NOTES_v1.0.0.md
   - Upload files
   - Publish

**Advantages:**
- ? No CLI tools needed
- ? Visual interface
- ? Easy to review before publishing

---

## ?? Release Checklist

### Before Running Script

- [x] ? All code committed and pushed
- [x] ? Version 1.0.0 in `ValidateJWT.nuspec`
- [x] ? Version 1.0.0.0 in `AssemblyInfo.cs`
- [x] ? CHANGELOG.md updated
- [x] ? RELEASE_NOTES_v1.0.0.md ready
- [x] ? Tests passing (58+ tests)
- [x] ? Build succeeds in Release mode

### Run Script

```powershell
.\CreateGitHubRelease.ps1
```

### After Release

- [ ] Verify release page loads
- [ ] Test downloading assets
- [ ] Add release badge to README
- [ ] Announce release

---

## ?? Release Assets

Your release includes:

| Asset | Type | Description |
|-------|------|-------------|
| **ValidateJWT-v1.0.0.zip** | Package | Complete release (DLL + docs) |
| **ValidateJWT.dll** | Binary | Main library (~15 KB) |
| **ValidateJWT.xml** | Docs | IntelliSense documentation (~10 KB) |
| **Source code (zip)** | Auto | GitHub auto-generated |
| **Source code (tar.gz)** | Auto | GitHub auto-generated |

---

## ??? Version Tagging

Use semantic versioning:

```
v1.0.0    ? Initial release (you are here!)
v1.0.1    ? Patch (bug fixes)
v1.1.0    ? Minor (new features)
v2.0.0    ? Major (breaking changes)
```

**Tag format:**
- Prefix with `v`
- Three numbers: MAJOR.MINOR.PATCH
- Annotated tags (with `-a` flag)
- Descriptive messages

---

## ?? Future Releases (v1.0.1, etc.)

### To Create v1.0.1:

1. **Update version:**
   - ValidateJWT.nuspec: `<version>1.0.1</version>`
   - AssemblyInfo.cs: `AssemblyVersion("1.0.1.0")`

2. **Update docs:**
   - CHANGELOG.md: Add v1.0.1 section
   - Create RELEASE_NOTES_v1.0.1.md

3. **Update script:**
   - Edit CreateGitHubRelease.ps1
   - Change `$version = "1.0.1"`

4. **Run:**
   ```powershell
   .\CreateGitHubRelease.ps1
   ```

---

## ?? Release Page Customization

### Add Badges to README

```markdown
[![Latest Release](https://img.shields.io/github/v/release/johanhenningsson4-hash/ValidateJWT)](https://github.com/johanhenningsson4-hash/ValidateJWT/releases/latest)

[![Downloads](https://img.shields.io/github/downloads/johanhenningsson4-hash/ValidateJWT/total)](https://github.com/johanhenningsson4-hash/ValidateJWT/releases)
```

### Release Categories

Mark releases as:
- ? **Latest release** (default)
- ?? **Pre-release** (beta, alpha)
- ?? **Draft** (not published yet)

---

## ??? GitHub CLI Cheat Sheet

```powershell
# Install
winget install --id GitHub.cli

# Login
gh auth login

# Create release
gh release create v1.0.0 --notes "Release notes" file1.zip file2.dll

# List releases
gh release list

# View release
gh release view v1.0.0

# Delete release
gh release delete v1.0.0

# Download release assets
gh release download v1.0.0
```

---

## ?? Integration with Other Tools

### CI/CD (GitHub Actions)

```yaml
name: Create Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup MSBuild
        uses: microsoft/setup-msbuild@v1
      
      - name: Build
        run: msbuild /p:Configuration=Release
      
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            bin/Release/ValidateJWT.dll
            bin/Release/ValidateJWT.xml
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### NuGet Integration

After creating GitHub release:
```powershell
.\BuildAndPublish-NuGet.ps1
```

This creates both GitHub release AND NuGet package!

---

## ?? Troubleshooting

### Script fails at MSBuild
**Solution:** Build manually in Visual Studio first, then run script

### Tag already exists
```powershell
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0
.\CreateGitHubRelease.ps1
```

### GitHub CLI auth issues
```powershell
gh auth status
gh auth login
```

### Release creation fails
- Check internet connection
- Verify GitHub permissions
- Try manual method

---

## ?? Release Statistics

After release, you can track:

- **Downloads:** GitHub Insights ? Traffic
- **Stars:** Repository stars
- **Forks:** Repository forks
- **Used by:** Dependency graph

---

## ?? Best Practices

? **DO:**
- Test release assets before publishing
- Write clear release notes
- Use semantic versioning
- Tag every release
- Include binaries and docs

? **DON'T:**
- Delete releases (breaks links)
- Reuse version numbers
- Skip release notes
- Forget to test downloads

---

## ?? Resources

- **GitHub Releases Docs:** https://docs.github.com/en/repositories/releasing-projects-on-github
- **GitHub CLI:** https://cli.github.com/
- **Semantic Versioning:** https://semver.org/

---

## ?? Summary

You now have a **complete GitHub release system**:

1. ? **Automated script** (`CreateGitHubRelease.ps1`)
2. ? **Complete guide** (`GITHUB_RELEASE_GUIDE.md`)
3. ? **Quick start** (`CREATE_GITHUB_RELEASE.md`)
4. ? **Multiple methods** (script, CLI, manual)
5. ? **Professional assets** (zip, binaries, docs)

---

## ?? Create Your Release Now!

```powershell
.\CreateGitHubRelease.ps1
```

**In 30 seconds, your release will be live at:**
```
https://github.com/johanhenningsson4-hash/ValidateJWT/releases/tag/v1.0.0
```

**Users can:**
- ?? Download binaries
- ? Star the repository
- ?? Install via NuGet
- ?? Clone specific version

---

**Ready to release? Run the script!** ??

*ValidateJWT v1.0.0 - January 2026*
