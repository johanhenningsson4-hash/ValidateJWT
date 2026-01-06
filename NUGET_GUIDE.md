# NuGet Package Creation Guide - ValidateJWT

## ?? Create NuGet Package

### Quick Start (Automated)

**Run this script to create the package:**
```powershell
.\CreateNuGetPackage.ps1
```

This will:
1. Clean previous builds
2. Build the project in Release mode with XML documentation
3. Download NuGet.exe if needed
4. Create the `.nupkg` file
5. Show you next steps for publishing

---

## ?? Manual Process

If you prefer to create the package manually:

### Step 1: Build in Release Mode

```powershell
# Using MSBuild
msbuild ValidateJWT.csproj /p:Configuration=Release /p:DocumentationFile=bin\Release\ValidateJWT.xml

# Or in Visual Studio
# Build > Configuration Manager > Release > Build Solution
```

### Step 2: Create NuGet Package

```powershell
# Download NuGet.exe if you don't have it
Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile "nuget.exe"

# Create the package
.\nuget.exe pack ValidateJWT.nuspec
```

---

## ?? Publishing the Package

### Option 1: Publish to NuGet.org (Public)

1. **Get API Key:**
   - Go to https://www.nuget.org/
   - Sign in or create account
   - Navigate to Account Settings > API Keys
   - Create new key with "Push" permission

2. **Push Package:**
   ```powershell
   nuget push ValidateJWT.1.0.0.nupkg -Source https://api.nuget.org/v3/index.json -ApiKey YOUR_API_KEY
   ```

### Option 2: Local NuGet Feed (Testing)

```powershell
# Create local feed directory
mkdir C:\LocalNuGetFeed

# Add package to local feed
nuget add ValidateJWT.1.0.0.nupkg -source C:\LocalNuGetFeed

# In Visual Studio, add the local feed:
# Tools > NuGet Package Manager > Package Manager Settings > Package Sources
# Click + to add: Name: "Local", Source: C:\LocalNuGetFeed
```

### Option 3: Azure DevOps / GitHub Packages (Private)

**Azure DevOps:**
```powershell
nuget push ValidateJWT.1.0.0.nupkg -Source "https://pkgs.dev.azure.com/YOUR_ORG/_packaging/YOUR_FEED/nuget/v3/index.json" -ApiKey az
```

**GitHub Packages:**
```powershell
dotnet nuget push ValidateJWT.1.0.0.nupkg --source "github" --api-key YOUR_GITHUB_TOKEN
```

---

## ?? Package Metadata (ValidateJWT.nuspec)

The package includes:

```xml
<package>
  <metadata>
    <id>ValidateJWT</id>
    <version>1.0.0</version>
    <title>ValidateJWT - Lightweight JWT Expiration Validator</title>
    <authors>Johan Henningsson</authors>
    <description>
      Lightweight JWT expiration validation library for .NET Framework 4.7.2.
      Perfect for quick pre-validation checks before making expensive API calls.
    </description>
    <tags>jwt token validation expiration authentication security base64url</tags>
  </metadata>
</package>
```

---

## ?? Package Contents

The NuGet package includes:

| File | Location | Purpose |
|------|----------|---------|
| `ValidateJWT.dll` | `lib\net472\` | Main library |
| `ValidateJWT.xml` | `lib\net472\` | XML documentation (IntelliSense) |
| `ValidateJWT.pdb` | `lib\net472\` | Debug symbols |
| `README.md` | Root | Documentation |
| `LICENSE.txt` | Root | MIT License |

---

## ?? Testing the Package

### Test Locally Before Publishing

1. **Create test project:**
   ```powershell
   dotnet new console -n TestValidateJWT -f net472
   cd TestValidateJWT
   ```

2. **Add local package source:**
   ```powershell
   nuget sources add -Name "Local" -Source "C:\Jobb\ValidateJWT"
   ```

3. **Install package:**
   ```powershell
   nuget install ValidateJWT -Version 1.0.0 -Source Local
   ```

4. **Test the library:**
   ```csharp
   using Johan.Common;
   
   var token = "eyJhbGci...";
   bool expired = ValidateJWT.IsExpired(token);
   Console.WriteLine($"Token expired: {expired}");
   ```

---

## ?? Updating the Package

To release a new version:

1. **Update version in `ValidateJWT.nuspec`:**
   ```xml
   <version>1.0.1</version>
   ```

2. **Update version in `AssemblyInfo.cs`:**
   ```csharp
   [assembly: AssemblyVersion("1.0.1.0")]
   [assembly: AssemblyFileVersion("1.0.1.0")]
   ```

3. **Add release notes:**
   ```xml
   <releaseNotes>
   v1.0.1 (2026-XX-XX)
   - Bug fixes
   - Performance improvements
   </releaseNotes>
   ```

4. **Rebuild and repack:**
   ```powershell
   .\CreateNuGetPackage.ps1
   ```

---

## ?? Package Information

### Package Details

- **ID:** ValidateJWT
- **Version:** 1.0.0
- **Target Framework:** .NET Framework 4.7.2
- **Dependencies:** None (uses only built-in .NET Framework libraries)
- **License:** MIT
- **Repository:** https://github.com/johanhenningsson4-hash/ValidateJWT

### Installation Command

Once published to NuGet.org:
```powershell
Install-Package ValidateJWT
```

Or with .NET CLI:
```powershell
dotnet add package ValidateJWT
```

---

## ? Pre-Publishing Checklist

Before publishing to NuGet.org:

- [ ] Build succeeds in Release mode
- [ ] XML documentation generated
- [ ] All tests passing (58+ tests)
- [ ] README.md is up to date
- [ ] LICENSE.txt included
- [ ] Version number is correct
- [ ] Release notes are complete
- [ ] Package tested locally
- [ ] Project URL is correct
- [ ] Tags are relevant

---

## ??? Troubleshooting

### Issue: "nuget is not recognized"

**Solution:** Download nuget.exe:
```powershell
Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile "nuget.exe"
```

### Issue: "XML documentation file not found"

**Solution:** Ensure project builds with XML documentation:
```powershell
msbuild ValidateJWT.csproj /p:Configuration=Release /p:DocumentationFile=bin\Release\ValidateJWT.xml
```

### Issue: "Package already exists on NuGet.org"

**Solution:** Increment version number in `ValidateJWT.nuspec` and `AssemblyInfo.cs`

---

## ?? Additional Resources

- **NuGet.org:** https://www.nuget.org/
- **NuGet Documentation:** https://docs.microsoft.com/en-us/nuget/
- **Creating Packages:** https://docs.microsoft.com/en-us/nuget/create-packages/
- **Package Versioning:** https://semver.org/

---

## ?? Summary

**To create and publish your NuGet package:**

1. Run `.\CreateNuGetPackage.ps1`
2. Test the package locally
3. Get NuGet API key from nuget.org
4. Push package: `nuget push ValidateJWT.1.0.0.nupkg -Source https://api.nuget.org/v3/index.json -ApiKey YOUR_KEY`
5. Wait for package to be indexed (~15 minutes)
6. Install in any project: `Install-Package ValidateJWT`

**Done!** Your library is now publicly available on NuGet.org! ??

---

*Last Updated: January 2026*
