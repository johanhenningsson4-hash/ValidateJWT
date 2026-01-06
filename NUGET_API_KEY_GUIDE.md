# ?? Using NUGET_API_KEY Environment Variable

## ?? Complete Build & Publish Workflow

### **New Script: `BuildAndPublish-NuGet.ps1`**

This script automatically:
1. ? Builds the project in Release mode
2. ? Generates XML documentation
3. ? Creates the NuGet package
4. ? **Publishes to NuGet.org (if NUGET_API_KEY is set)**

---

## ?? Setup Instructions

### Step 1: Get Your NuGet API Key

1. Go to https://www.nuget.org/
2. Sign in (or create account)
3. Click your username ? **API Keys**
4. Click **Create**
5. Settings:
   - **Key Name:** ValidateJWT
   - **Select Scopes:** Push
   - **Select Packages:** All packages (*)
   - **Expiration:** Your choice (365 days recommended)
6. Click **Create**
7. **Copy the API key** (shown only once!)

---

### Step 2: Set Environment Variable

Choose one method:

#### **Method A: PowerShell Session (Temporary)**
```powershell
$env:NUGET_API_KEY = "your-api-key-here"
```
? Works immediately  
? Lost when PowerShell closes

#### **Method B: Windows System (Permanent)** ? **Recommended**
```cmd
setx NUGET_API_KEY "your-api-key-here"
```
? Permanent (survives reboots)  
?? Restart PowerShell to take effect

#### **Method C: User Environment Variables (GUI)**
1. Windows Key ? "Environment Variables"
2. Click "Environment Variables"
3. Under "User variables" click "New"
4. Variable name: `NUGET_API_KEY`
5. Variable value: Your API key
6. Click OK
7. Restart PowerShell

---

### Step 3: Run the Script

```powershell
.\BuildAndPublish-NuGet.ps1
```

**What happens:**
1. Cleans previous builds
2. Finds MSBuild automatically
3. Builds in Release mode
4. Creates `ValidateJWT.1.0.0.nupkg`
5. **Asks if you want to publish** (if NUGET_API_KEY is set)
6. Publishes to NuGet.org
7. Shows package URL

---

## ?? Usage Scenarios

### Scenario 1: First Time (No API Key Set)

```powershell
PS C:\Jobb\ValidateJWT> .\BuildAndPublish-NuGet.ps1

??  NUGET_API_KEY not found in environment
   Package will be created but not published

[Build happens...]

? Package Created Successfully
?? Package: ValidateJWT.1.0.0.nupkg

Next Steps:
1??  Set NUGET_API_KEY environment variable
2??  Get API key from: https://www.nuget.org/
3??  Run this script again to publish
```

### Scenario 2: With API Key (Automatic Publish)

```powershell
PS C:\Jobb\ValidateJWT> $env:NUGET_API_KEY = "oy2abc..."
PS C:\Jobb\ValidateJWT> .\BuildAndPublish-NuGet.ps1

? NUGET_API_KEY found in environment
   Package will be published automatically after build

[Build happens...]

? Package created: ValidateJWT.1.0.0.nupkg

============================================================
  Publishing to NuGet.org...
============================================================

Package: ValidateJWT.1.0.0.nupkg
Target: https://api.nuget.org/v3/index.json

Publish now? (Y/N): Y

Publishing...

? SUCCESS! Package Published to NuGet.org

?? Package: ValidateJWT.1.0.0.nupkg
?? URL: https://www.nuget.org/packages/ValidateJWT

? Indexing: Package will be available in ~15 minutes
```

---

## ?? Security Best Practices

### ? DO:
- Store API key in environment variable (not in code)
- Use key expiration (e.g., 365 days)
- Regenerate keys periodically
- Keep keys private (don't commit to Git)

### ? DON'T:
- Hardcode API keys in scripts
- Share API keys in chat/email
- Commit API keys to version control
- Use same key for multiple purposes

---

## ?? Test Before Publishing

### Test Locally First

1. **Create package without publishing:**
   ```powershell
   # Clear API key temporarily
   $env:NUGET_API_KEY = $null
   .\BuildAndPublish-NuGet.ps1
   ```

2. **Add to local feed:**
   ```powershell
   mkdir C:\LocalNuGetFeed
   nuget add ValidateJWT.1.0.0.nupkg -source C:\LocalNuGetFeed
   ```

3. **Test installation:**
   ```powershell
   dotnet new console -n TestApp -f net472
   cd TestApp
   nuget install ValidateJWT -Source C:\LocalNuGetFeed
   ```

4. **If all works, publish:**
   ```powershell
   # Set API key
   $env:NUGET_API_KEY = "your-key"
   cd ..
   .\BuildAndPublish-NuGet.ps1
   ```

---

## ?? Environment Variable Check

### Verify API Key is Set

```powershell
# Check if set
if ($env:NUGET_API_KEY) {
    Write-Host "? NUGET_API_KEY is set" -ForegroundColor Green
    Write-Host "   Value: $($env:NUGET_API_KEY.Substring(0, 8))..." -ForegroundColor Gray
} else {
    Write-Host "? NUGET_API_KEY is NOT set" -ForegroundColor Red
}
```

### View All Environment Variables
```powershell
Get-ChildItem Env: | Where-Object { $_.Name -like "*NUGET*" }
```

### Remove API Key
```powershell
# From current session
$env:NUGET_API_KEY = $null

# Permanently
[System.Environment]::SetEnvironmentVariable("NUGET_API_KEY", $null, "User")
```

---

## ?? Update Package Workflow

### For Version Updates (e.g., 1.0.0 ? 1.0.1)

1. **Update version in `ValidateJWT.nuspec`:**
   ```xml
   <version>1.0.1</version>
   ```

2. **Update `Properties\AssemblyInfo.cs`:**
   ```csharp
   [assembly: AssemblyVersion("1.0.1.0")]
   [assembly: AssemblyFileVersion("1.0.1.0")]
   ```

3. **Add release notes in nuspec:**
   ```xml
   <releaseNotes>
   v1.0.1 (2026-XX-XX)
   - Fixed: Issue with...
   - Added: New feature...
   </releaseNotes>
   ```

4. **Build and publish:**
   ```powershell
   .\BuildAndPublish-NuGet.ps1
   ```

---

## ?? CI/CD Integration

### GitHub Actions Example

```yaml
name: Publish NuGet Package

on:
  push:
    tags:
      - 'v*'

jobs:
  publish:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup MSBuild
        uses: microsoft/setup-msbuild@v1
      
      - name: Build and Publish
        env:
          NUGET_API_KEY: ${{ secrets.NUGET_API_KEY }}
        run: .\BuildAndPublish-NuGet.ps1
```

**Setup:**
1. GitHub ? Repository ? Settings ? Secrets
2. Add secret: `NUGET_API_KEY` = your key
3. Push tag: `git tag v1.0.0 && git push --tags`

---

## ?? Troubleshooting

### Issue: "NUGET_API_KEY not found"

**Check if set:**
```powershell
echo $env:NUGET_API_KEY
```

**If empty:**
```powershell
$env:NUGET_API_KEY = "your-key-here"
```

### Issue: "Invalid API key"

**Solutions:**
- Key might be expired - create new one
- Check you copied the entire key
- Verify key has "Push" permission
- Try regenerating the key on NuGet.org

### Issue: "Package version already exists"

**Solution:**
Increment version in:
1. `ValidateJWT.nuspec` ? `<version>`
2. `Properties\AssemblyInfo.cs` ? `AssemblyVersion`

NuGet.org doesn't allow overwriting existing versions.

---

## ?? Quick Reference

| Task | Command |
|------|---------|
| **Set API key (session)** | `$env:NUGET_API_KEY = "key"` |
| **Set API key (permanent)** | `setx NUGET_API_KEY "key"` |
| **Check if set** | `echo $env:NUGET_API_KEY` |
| **Build & publish** | `.\BuildAndPublish-NuGet.ps1` |
| **Build only (no publish)** | Clear `NUGET_API_KEY`, run script |
| **Manual publish** | `nuget push *.nupkg -Source nuget.org -ApiKey $env:NUGET_API_KEY` |

---

## ?? Complete Example

```powershell
# 1. Get API key from nuget.org
# 2. Set it permanently
setx NUGET_API_KEY "oy2abcdefghijklmnopqrstuvwxyz1234567890"

# 3. Restart PowerShell (for setx to take effect)
# 4. Navigate to project
cd C:\Jobb\ValidateJWT

# 5. Build and publish
.\BuildAndPublish-NuGet.ps1

# 6. Confirm when prompted
# Publish now? (Y/N): Y

# 7. Wait ~15 minutes

# 8. Check package is live
# https://www.nuget.org/packages/ValidateJWT
```

---

## ? Advantages of Using Environment Variable

| Benefit | Description |
|---------|-------------|
| **Security** | Key not stored in code |
| **Automation** | Script can auto-publish |
| **CI/CD Ready** | Easy to integrate |
| **Multi-Project** | Same key for all projects |
| **Revocable** | Change key without updating scripts |

---

**All set! Just run `.\BuildAndPublish-NuGet.ps1` to build and publish!** ??

*Last Updated: January 2026*
