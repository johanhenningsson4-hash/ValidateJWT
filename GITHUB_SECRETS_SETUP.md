# ?? GitHub Secrets Configuration Guide - ValidateJWT

## ?? Overview

This guide will help you configure GitHub secrets to enable full CI/CD automation, including automated NuGet package publishing.

---

## ?? Required Secrets

### 1. **NUGET_API_KEY** (Required)

**Purpose:** Enables automated publishing to NuGet.org

**Used By:**
- `.github/workflows/ci-cd.yml` - Main CI/CD pipeline
- Automatic NuGet package publishing on release

**Without This:** 
- ? Cannot automatically publish to NuGet.org
- ?? Manual publishing required

---

### 2. **CODECOV_TOKEN** (Optional)

**Purpose:** Uploads code coverage reports to Codecov.io

**Used By:**
- `.github/workflows/code-coverage.yml` - Coverage analysis

**Without This:**
- ?? Coverage reports not uploaded to Codecov
- ?? Local coverage reports still work

---

## ?? Step-by-Step Setup

### Step 1: Get Your NuGet API Key

**1.1 Log into NuGet.org:**
```
https://www.nuget.org/
```

**1.2 Navigate to API Keys:**
1. Click your username (top right)
2. Select **"API Keys"**
3. Or go directly to: https://www.nuget.org/account/apikeys

**1.3 Create New API Key:**

Click **"Create"** and fill in:

| Field | Value | Notes |
|-------|-------|-------|
| **Key Name** | `ValidateJWT-GitHub-Actions` | Descriptive name |
| **Package Owner** | Your username | Auto-filled |
| **Glob Pattern** | `ValidateJWT` | Limits to this package |
| **Scopes** | ? Push, ? Push new packages and package versions | Required permissions |
| **Expiration** | 365 days | Or custom |

**1.4 Copy the API Key:**

?? **IMPORTANT:** Copy the key immediately - you won't see it again!

```
Example format: oy2a....(long string)....xyz
```

---

### Step 2: Add Secret to GitHub

**2.1 Open Your Repository:**
```
https://github.com/johanhenningsson4-hash/ValidateJWT
```

**2.2 Navigate to Settings:**
1. Click **"Settings"** tab (top menu)
2. Click **"Secrets and variables"** (left sidebar)
3. Click **"Actions"**

**2.3 Add New Secret:**

Click **"New repository secret"**

Fill in:
- **Name:** `NUGET_API_KEY` (EXACT - case sensitive!)
- **Secret:** Paste your NuGet API key
- Click **"Add secret"**

? **Done!** The secret is now configured.

---

### Step 3: Verify Configuration

**3.1 Check Secret Exists:**

Go to:
```
Settings ? Secrets and variables ? Actions
```

You should see:
- ? `NUGET_API_KEY` - Updated X seconds/minutes ago

**3.2 Test with a Push:**

```powershell
# Make a small change
echo "# Test" >> README.md

# Commit and push
git add README.md
git commit -m "test: Verify CI/CD pipeline"
git push origin main
```

**3.3 Check Actions Tab:**
```
https://github.com/johanhenningsson4-hash/ValidateJWT/actions
```

You should see:
- ? Workflow running
- ? Build and test job succeeds
- ?? NuGet publish skipped (only runs on release)

---

## ?? Complete CI/CD Workflow

### When You Push to `main`:

```
Push to main
    ?
GitHub Actions Triggered
    ?
???????????????????????????????????
?  Build and Test                 ?
?  • Restore packages             ?
?  • Build Debug & Release        ?
?  • Run all 58+ tests           ?
?  • Upload test results          ?
???????????????????????????????????
    ?
???????????????????????????????????
?  Code Quality                   ?
?  • Run code analysis            ?
?  • Check for warnings           ?
???????????????????????????????????
    ?
???????????????????????????????????
?  Security Scan                  ?
?  • Scan for vulnerabilities     ?
?  • Upload SARIF results         ?
???????????????????????????????????
    ?
? Pipeline Complete
```

### When You Create a Release:

```
Create GitHub Release (v1.x.x)
    ?
GitHub Actions Triggered
    ?
... (same as above) ...
    ?
???????????????????????????????????
?  Build NuGet Package            ?
?  • Pack ValidateJWT.nuspec      ?
?  • Include README & LICENSE     ?
?  • Upload as artifact           ?
???????????????????????????????????
    ?
???????????????????????????????????
?  Publish to NuGet.org          ?
?  • Uses NUGET_API_KEY ??       ?
?  • Push package                 ?
?  • Skip if already exists       ?
???????????????????????????????????
    ?
???????????????????????????????????
?  Upload Release Assets          ?
?  • Attach .nupkg file          ?
?  • Create ZIP archive           ?
???????????????????????????????????
    ?
???????????????????????????????????
?  Update Documentation           ?
?  • Update version badges        ?
?  • Commit changes               ?
???????????????????????????????????
    ?
? Package Published to NuGet! ??
```

---

## ?? Quick Reference Commands

### Check Configured Secrets (via GitHub CLI)

```powershell
# Install GitHub CLI (if needed)
winget install --id GitHub.cli

# Login
gh auth login

# List secrets
gh secret list
```

**Expected Output:**
```
NUGET_API_KEY  Updated 2024-01-XX
```

### Update Secret (via GitHub CLI)

```powershell
# Update NUGET_API_KEY
gh secret set NUGET_API_KEY

# Enter the new key when prompted
```

### Remove Secret (via GitHub CLI)

```powershell
gh secret remove NUGET_API_KEY
```

---

## ?? Testing the Full Pipeline

### Test 1: Regular Push (No Release)

```powershell
# Make a change
echo "# Test CI/CD" >> CI_CD_GUIDE.md

# Commit and push
git add .
git commit -m "test: CI/CD pipeline"
git push origin main
```

**Expected:**
- ? Build succeeds
- ? Tests pass
- ? Code quality checks pass
- ?? NuGet publish skipped (not a release)

---

### Test 2: Create Release (Full Pipeline)

**2.1 Create Tag:**
```powershell
git tag -a v1.1.1 -m "Test release"
git push origin v1.1.1
```

**2.2 Create GitHub Release:**

1. Go to: https://github.com/johanhenningsson4-hash/ValidateJWT/releases/new
2. Select tag: `v1.1.1`
3. Title: `ValidateJWT v1.1.1 - Test Release`
4. Description: `Testing automated publishing`
5. Click **"Publish release"**

**2.3 Watch Actions:**
```
https://github.com/johanhenningsson4-hash/ValidateJWT/actions
```

**Expected:**
- ? Build succeeds
- ? Tests pass
- ? Package built
- ? **Published to NuGet.org** ??
- ? Assets uploaded

**2.4 Verify on NuGet (wait ~15 minutes):**
```
https://www.nuget.org/packages/ValidateJWT/1.1.1
```

---

## ?? Security Best Practices

### ? Do:

- ? Use scoped API keys (limit to specific package)
- ? Set expiration dates (review annually)
- ? Use repository secrets (not organization secrets)
- ? Rotate keys periodically
- ? Delete keys when no longer needed

### ? Don't:

- ? Share API keys in chat/email
- ? Commit keys to repository
- ? Use keys with excessive permissions
- ? Reuse keys across projects
- ? Leave keys active indefinitely

---

## ?? Troubleshooting

### Issue: "Secret not found" Error

**Symptoms:**
```
Error: Secret NUGET_API_KEY not found
```

**Solution:**
1. Verify secret name is EXACT: `NUGET_API_KEY` (case-sensitive)
2. Check it's in **Actions** secrets (not Dependabot or Codespaces)
3. Recreate the secret if needed

---

### Issue: "Authentication failed" When Publishing

**Symptoms:**
```
error: Response status code does not indicate success: 401 (Unauthorized)
```

**Solutions:**

**A. API Key Expired:**
1. Go to https://www.nuget.org/account/apikeys
2. Check expiration date
3. Create new key if expired
4. Update GitHub secret

**B. Insufficient Permissions:**
1. Verify key has **"Push"** scope
2. Verify package glob pattern includes `ValidateJWT`
3. Recreate key with correct permissions

**C. Rate Limiting:**
- Wait a few minutes
- Try again

---

### Issue: "Package Already Exists"

**Symptoms:**
```
error: Response status code does not indicate success: 409 (Conflict)
Package version 1.1.0 already exists
```

**This is normal!** The workflow uses `-SkipDuplicate` flag.

**Solution:**
- Increment version number
- Create new release with new version

---

### Issue: Workflow Not Triggering

**Check:**

1. **Workflow files exist:**
```powershell
dir .github\workflows\*.yml
```

2. **Workflows enabled:**
   - Go to Actions tab
   - Check if workflows are disabled

3. **Branch protection:**
   - Ensure no rules blocking Actions

---

## ?? Monitoring

### View Workflow Runs

**Main Dashboard:**
```
https://github.com/johanhenningsson4-hash/ValidateJWT/actions
```

**Specific Workflow:**
- Click on workflow name (e.g., "CI/CD Pipeline")
- View all runs
- Click on run to see details

### Check Secret Usage

**In Workflow Logs:**
```
Run nuget push
```

You'll see:
```
Using API key: ***
```

Secrets are automatically masked in logs! ?

---

## ?? Success Indicators

### After Setup, You Should See:

**In GitHub:**
- ? Secret `NUGET_API_KEY` listed in Settings
- ? Green checkmarks on commits in Actions
- ? Workflow runs completing successfully

**On Release:**
- ? Package built automatically
- ? Published to NuGet.org
- ? Release assets attached
- ? No manual intervention needed

**On NuGet.org (~15 min after release):**
- ? New version appears
- ? Package searchable
- ? README displays
- ? Can install: `Install-Package ValidateJWT -Version x.x.x`

---

## ?? Optional: Codecov Setup

### Step 1: Sign Up for Codecov

1. Go to: https://codecov.io/
2. Sign in with GitHub
3. Add ValidateJWT repository

### Step 2: Get Token

1. Go to repository settings on Codecov
2. Copy the upload token

### Step 3: Add to GitHub

1. Go to GitHub repository Settings
2. Secrets and variables ? Actions
3. New repository secret
   - Name: `CODECOV_TOKEN`
   - Value: Your Codecov token

### Step 4: Add Badge to README

```markdown
[![codecov](https://codecov.io/gh/johanhenningsson4-hash/ValidateJWT/branch/main/graph/badge.svg)](https://codecov.io/gh/johanhenningsson4-hash/ValidateJWT)
```

---

## ?? Checklist

### Initial Setup:
- [ ] NuGet API key created
- [ ] `NUGET_API_KEY` secret added to GitHub
- [ ] Secret name verified (exact case)
- [ ] Test push to verify CI works

### Release Setup:
- [ ] Test release created
- [ ] Package published successfully
- [ ] Package appears on NuGet.org
- [ ] Release assets attached

### Optional:
- [ ] Codecov account created
- [ ] `CODECOV_TOKEN` secret added
- [ ] Coverage badge added to README

---

## ?? You're All Set!

Once configured, your workflow is:

1. **Develop** ? Code and test locally
2. **Commit** ? Push to GitHub
3. **Wait** ? CI runs automatically (2-3 minutes)
4. **Release** ? Create GitHub release
5. **Automated** ? Package published to NuGet automatically
6. **Done!** ? Users can install your package

**Zero manual deployment required!** ??

---

## ?? Related Documentation

- [CI_CD_GUIDE.md](CI_CD_GUIDE.md) - Complete CI/CD documentation
- [GitHub Actions Workflows](.github/workflows/) - Workflow definitions
- [GitHub Docs - Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [NuGet API Keys](https://docs.microsoft.com/en-us/nuget/nuget-org/scoped-api-keys)

---

## ?? Pro Tips

1. **Descriptive Key Names:**
   ```
   ? ValidateJWT-GitHub-Actions-2024
   ? key1
   ```

2. **Set Expiration Reminders:**
   - Add calendar reminder for 1 month before expiration
   - Rotate keys proactively

3. **Test Before Real Release:**
   - Use test version (e.g., `v1.1.1-test`)
   - Verify entire pipeline
   - Delete test version after

4. **Monitor Actions:**
   - Enable email notifications for failed workflows
   - Check Actions tab weekly

5. **Keep Secrets Minimal:**
   - Only add secrets that are actually needed
   - Remove unused secrets

---

**Status:** ?? Ready to Configure  
**Time Required:** 5-10 minutes  
**Difficulty:** Easy  
**Impact:** High (enables full automation)

---

*Last Updated: January 2026*  
*For ValidateJWT v1.1.0+*

