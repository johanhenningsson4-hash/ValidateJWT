# ?? Company References Cleanup - ValidateJWT

## ?? Overview

This document provides a complete guide to removing all references to Diebold Nixdorf, MTR, and TPDotnet from the ValidateJWT project to make it suitable for public release.

---

## ?? What Was Found

### Company Terms to Remove:
- **Diebold / Diebold Nixdorf** - Hardware manufacturer
- **MTR** - Internal project/division name
- **TPDotnet / TPDotNet** - Internal library/framework
- **TechServices** - Internal service name
- **Payment Terminal** - Industry-specific references
- **POIID / TerminalIP** - Terminal-specific configuration

---

## ?? Where References Exist

### 1. **Archive Folder** (Historical Documentation)

**Location:** `Archive/Development/` and `Archive/Releases/`

**Files:**
- `ANALYSIS_SUMMARY.md`
- `PROJECT_ANALYSIS.md`
- `OUTPUT_PATH_FIX.md`
- `MANUAL_FIX_GUIDE.md`
- `FINAL_SUCCESS.md`
- `COMPLETE_FIX_INSTRUCTIONS.md`
- `BUILD_ISSUES_FIXED.md`
- `RELEASE_GUIDE.md`
- `RELEASE_NOTES_v1.0.0.md`
- `COMMIT_AND_PUBLISH_GUIDE.md`
- `VerifyNuGetPackage.ps1`
- `CLEANUP_PLAN.md`
- `CommitAndPublish.bat`

**Status:** ?? Contains historical company references

**Recommendation:** **Delete the entire Archive folder** OR keep for history but note it's not part of active code

---

### 2. **Active Code** (Current Solution)

? **Good News:** No company references found in:
- `ValidateJWT.cs`
- `Properties/AssemblyInfo.cs`
- `README.md`
- `CHANGELOG.md`
- `SIGNATURE_VERIFICATION.md`
- Test files
- Project files (`.csproj`)
- Solution file (`.sln`)

---

### 3. **Configuration Files**

**App.config** - Check for:
- Payment terminal settings
- Company-specific connection strings
- Internal service URLs

---

## ?? Cleanup Options

### Option 1: Quick Clean (Recommended)

**Delete Archive folder completely:**

```powershell
# Run the cleanup script
.\Remove-CompanyReferences.ps1 -ArchiveOnly
```

**What this does:**
- ? Removes all historical documentation
- ? Keeps all active code
- ? Preserves working solution
- ? Makes project public-ready

**Time:** 1 minute

---

### Option 2: Keep Archive (Historical)

**Keep Archive for reference, clean active code only:**

```powershell
# Preview what would be changed
.\Remove-CompanyReferences.ps1 -Preview
```

**Then manually:**
1. Add note to Archive/README.md explaining it's historical
2. Ensure no active code references company terms
3. Verify namespaces are generic

**Time:** 5 minutes

---

### Option 3: Manual Review

**Review each file individually:**

```powershell
# Run interactive cleanup
.\Remove-CompanyReferences.ps1
```

Follow prompts to selectively clean files.

**Time:** 15-30 minutes

---

## ? Checklist for Public Release

### Code Files
- [ ] **ValidateJWT.cs** - Check namespace (currently `Johan.Common` ?)
- [ ] **AssemblyInfo.cs** - Verify company name and copyright
- [ ] **Test files** - Ensure no company references
- [ ] **Project files** - Clean of external company dependencies

### Documentation
- [ ] **README.md** - Generic, no company mentions ?
- [ ] **CHANGELOG.md** - Clean ?
- [ ] **SIGNATURE_VERIFICATION.md** - Clean ?
- [ ] **LICENSE.txt** - Check copyright holder
- [ ] **Remove or clean Archive/** - Historical docs

### Configuration
- [ ] **App.config** - Remove company-specific settings
- [ ] **packages.config** - No internal package sources
- [ ] **.gitignore** - Standard .NET ignore rules

### Namespace
- [ ] Current: `Johan.Common` ? (Generic, good!)
- [ ] **Do NOT use:** `TPDotNet.MTR.Common` ? (Company-specific)

---

## ?? Quick Fix Commands

### Remove Archive Folder:
```powershell
Remove-Item -Path Archive -Recurse -Force
```

### Check for Company Terms:
```powershell
# Search all files
Get-ChildItem -Recurse -Include *.cs,*.md,*.config | Select-String -Pattern "Diebold|Nixdorf|MTR|TPDotnet"
```

### Clean App.config:
```powershell
# Open App.config and remove sections:
# - Payment terminal settings
# - Company-specific configurations
```

---

## ?? Recommended Namespace

### Current Namespace: ? **CORRECT**

```csharp
namespace Johan.Common
{
    public static class ValidateJWT
    {
        // ...
    }
}
```

**This is good!** It's:
- ? Generic
- ? Personal (Johan)
- ? Not company-specific
- ? Ready for public release

### **DO NOT Change To:**

? `TPDotNet.MTR.Common` - Company specific  
? `Diebold.Nixdorf.XXX` - Company specific  
? `TechServices.XXX` - Company specific

---

## ?? Action Plan

### Immediate Actions:

1. **Run Cleanup Script:**
```powershell
.\Remove-CompanyReferences.ps1
```

2. **Choose Option:**
   - Option 1: Delete Archive (**Recommended for public release**)
   - Option 2: Keep Archive (mark as historical)

3. **Verify Clean:**
```powershell
# Should find no results
Get-ChildItem -Recurse -Include *.cs,*.md,*.txt -Exclude *Archive* | 
  Select-String -Pattern "Diebold|Nixdorf|MTR|TPDotnet|TechServices"
```

4. **Check AssemblyInfo.cs:**
```csharp
// Verify these are appropriate
[assembly: AssemblyCompany("Johan Henningsson")]
[assembly: AssemblyCopyright("Copyright © 2026")]
[assembly: AssemblyTrademark("")]
```

5. **Review App.config:**
- Remove payment terminal settings
- Remove company-specific connection strings
- Keep only .NET Framework settings

---

## ?? Cleanup Summary

### Files to Clean/Remove:

| Category | Count | Action |
|----------|-------|--------|
| **Archive Folder** | ~15 files | Delete OR mark as historical |
| **Active Code** | 0 files | ? Clean |
| **Documentation** | 0 files | ? Clean |
| **Config Files** | Check | Review App.config |

---

## ? Result After Cleanup

### What You'll Have:

? **Clean Solution**
- No company references in active code
- Generic namespaces (`Johan.Common`)
- Public-ready documentation
- No internal dependencies

? **Professional Package**
- Suitable for GitHub public repo
- Ready for NuGet.org
- Open source friendly
- No proprietary mentions

? **Maintained History** (Optional)
- Archive folder preserved (if kept)
- Git history intact
- Development journey documented

---

## ?? Critical Points

### ?? Before Public Release:

1. **Verify Namespace:** `Johan.Common` ? (Good)
2. **Check AssemblyInfo:** Company name appropriate
3. **Review LICENSE:** Correct copyright holder
4. **Clean Archive:** Delete or mark as historical
5. **Test Build:** Ensure no external dependencies
6. **Review README:** No company mentions

### ? Currently Clean:

- Source code (ValidateJWT.cs)
- Main documentation
- Project files
- Test files
- README.md
- CHANGELOG.md

### ?? Need Attention:

- Archive folder (historical docs)
- App.config (check for company settings)
- AssemblyInfo.cs (verify company name)

---

## ?? Final Verification Script

```powershell
# Complete verification
$terms = @("Diebold", "Nixdorf", "MTR", "TPDotnet", "TPDotNet", "TechServices")
$files = Get-ChildItem -Recurse -Include *.cs,*.md,*.txt,*.config,*.csproj -Exclude *bin*,*obj*,*packages*,*Archive*

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    foreach ($term in $terms) {
        if ($content -match $term) {
            Write-Host "Found '$term' in: $($file.FullName)" -ForegroundColor Yellow
        }
    }
}

Write-Host "Verification complete!" -ForegroundColor Green
```

---

## ?? Success Criteria

Your solution is clean when:

- [ ] ? No company terms in active code
- [ ] ? Namespace is generic (`Johan.Common`)
- [ ] ? Documentation is public-ready
- [ ] ? No external company dependencies
- [ ] ? AssemblyInfo has correct company
- [ ] ? App.config is clean
- [ ] ? README is generic
- [ ] ? Can build without company infrastructure

---

## ?? Ready for Release

Once cleanup is complete:

1. **Commit Changes:**
```bash
git add .
git commit -m "chore: Remove company-specific references for public release"
```

2. **Verify Clean:**
```bash
git diff HEAD~1
```

3. **Push to GitHub:**
```bash
git push origin main
```

4. **Create Release:**
- Tag version
- Create GitHub release
- Publish to NuGet.org

---

## ?? Related Scripts

- `Remove-CompanyReferences.ps1` - Automated cleanup
- `Remove-UnusedReferences.ps1` - Clean project references
- `Cleanup-Code.ps1` - General code cleanup

---

## ?? Tips

### Namespace Best Practices:

? **Good Namespace Choices:**
- `ValidateJWT`
- `Johan.Utilities`
- `Johan.Common`
- `JWT.Validation`

? **Avoid:**
- Company names
- Internal project codes
- Proprietary terms
- Division names

### Documentation:

- Keep technical content
- Remove company context
- Use generic examples
- Avoid internal terminology

---

**Status:** ?? Cleanup Required  
**Risk:** Low (all references in Archive folder)  
**Time:** 1-5 minutes  
**Impact:** High (enables public release)

---

*Run `.\Remove-CompanyReferences.ps1` to get started!*

