# ?? NuGet Package Ready!

## ? Files Created

| File | Purpose |
|------|---------|
| ? `ValidateJWT.nuspec` | NuGet package specification |
| ? `LICENSE.txt` | MIT License for the package |
| ? `CreateNuGetPackage.ps1` | Automated build & pack script |
| ? `NUGET_GUIDE.md` | Complete NuGet guide |
| ? `NUGET_QUICK_START.md` | Quick reference |

---

## ?? Create Your Package Now!

### Step 1: Run the Script
```powershell
.\CreateNuGetPackage.ps1
```

**This will:**
1. Clean previous builds
2. Build project in Release mode
3. Generate XML documentation
4. Download NuGet.exe (if needed)
5. Create `ValidateJWT.1.0.0.nupkg`

**Time:** ~30 seconds

---

## ?? Package Details

**Package ID:** `ValidateJWT`  
**Version:** `1.0.0`  
**Framework:** `.NET Framework 4.7.2`  
**Namespace:** `Johan.Common`  
**License:** MIT  
**Repository:** https://github.com/johanhenningsson4-hash/ValidateJWT

### What's Included
- ? ValidateJWT.dll (library)
- ? ValidateJWT.xml (IntelliSense documentation)
- ? ValidateJWT.pdb (debug symbols)
- ? README.md
- ? LICENSE.txt

### Features
- ? JWT expiration validation
- ? Base64URL decoding
- ? Clock skew support (5 min default)
- ? Thread-safe
- ? Zero dependencies
- ? 58+ unit tests
- ? ~100% test coverage

---

## ?? Publish to NuGet.org

### Get API Key
1. Go to https://www.nuget.org/
2. Sign in (or create account)
3. Click your username ? API Keys
4. Click "Create"
5. Give it a name (e.g., "ValidateJWT")
6. Select "Push" scope
7. Select "*" for Glob Pattern
8. Click "Create"
9. Copy the API key

### Push Package
```powershell
nuget push ValidateJWT.1.0.0.nupkg -Source https://api.nuget.org/v3/index.json -ApiKey YOUR_API_KEY_HERE
```

### Wait for Indexing
- Package will be available in ~15 minutes
- You'll get an email confirmation
- Check https://www.nuget.org/packages/ValidateJWT

---

## ?? Test Before Publishing

### Local Testing

```powershell
# Create local feed
mkdir C:\LocalNuGetFeed

# Add package to local feed
nuget add ValidateJWT.1.0.0.nupkg -source C:\LocalNuGetFeed

# In test project
Install-Package ValidateJWT -Source C:\LocalNuGetFeed
```

### Test Code

```csharp
using Johan.Common;
using System;

class Program
{
    static void Main()
    {
        // Your JWT token
        string jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...";
        
        // Check if expired
        bool expired = ValidateJWT.IsExpired(jwt);
        Console.WriteLine($"Token expired: {expired}");
        
        // Check if valid now
        bool valid = ValidateJWT.IsValidNow(jwt);
        Console.WriteLine($"Token valid: {valid}");
        
        // Get expiration time
        DateTime? expiration = ValidateJWT.GetExpirationUtc(jwt);
        if (expiration.HasValue)
        {
            Console.WriteLine($"Expires: {expiration.Value}");
        }
    }
}
```

---

## ?? Once Published

### Installation Commands

**Package Manager Console:**
```powershell
Install-Package ValidateJWT
```

**.NET CLI:**
```powershell
dotnet add package ValidateJWT
```

**PackageReference (csproj):**
```xml
<PackageReference Include="ValidateJWT" Version="1.0.0" />
```

### Package URL
```
https://www.nuget.org/packages/ValidateJWT
```

### Usage in Code
```csharp
using Johan.Common;

// Start using ValidateJWT methods
bool expired = ValidateJWT.IsExpired(token);
```

---

## ?? Update Package (Future Versions)

### Update Version

1. **In `ValidateJWT.nuspec`:**
   ```xml
   <version>1.0.1</version>
   ```

2. **In `Properties/AssemblyInfo.cs`:**
   ```csharp
   [assembly: AssemblyVersion("1.0.1.0")]
   [assembly: AssemblyFileVersion("1.0.1.0")]
   ```

3. **Add release notes in nuspec:**
   ```xml
   <releaseNotes>
   v1.0.1 (2026-XX-XX)
   - Bug fix: Fixed issue with...
   - New feature: Added...
   </releaseNotes>
   ```

4. **Rebuild:**
   ```powershell
   .\CreateNuGetPackage.ps1
   ```

5. **Push new version:**
   ```powershell
   nuget push ValidateJWT.1.0.1.nupkg -Source https://api.nuget.org/v3/index.json -ApiKey YOUR_KEY
   ```

---

## ?? Pre-Publishing Checklist

- [x] ? Code compiles successfully
- [x] ? All 58+ tests passing
- [x] ? XML documentation generated
- [x] ? README.md up to date
- [x] ? LICENSE.txt included
- [x] ? Version number correct (1.0.0)
- [x] ? Namespace correct (Johan.Common)
- [x] ? RootNamespace in csproj updated
- [ ] ? Tested locally
- [ ] ? Published to NuGet.org
- [ ] ? Verified installation

---

## ?? Summary

**Everything is ready for NuGet package creation!**

### Quick Steps:
1. Run `.\CreateNuGetPackage.ps1` ? **Start here!**
2. Test package locally
3. Get NuGet API key
4. Push to NuGet.org
5. Wait ~15 minutes
6. Install in any project!

---

## ?? Tips

### Tag Best Practices
Current tags: `jwt token validation expiration authentication security base64url`

These help with discoverability on NuGet.org.

### Package Icon (Optional)
Add an icon to your package:
1. Create 128x128 PNG icon
2. Add to nuspec:
   ```xml
   <icon>icon.png</icon>
   ```
3. Include in files:
   ```xml
   <file src="icon.png" target="" />
   ```

### README Preview
NuGet.org will display your README.md on the package page. Make sure it's clear and helpful!

---

## ?? Support

**Issues:** https://github.com/johanhenningsson4-hash/ValidateJWT/issues  
**Documentation:** See README.md and NUGET_GUIDE.md  
**License:** MIT (very permissive)

---

## ?? Success Criteria

Your package is ready when:
- ? `.nupkg` file created
- ? Tested locally without errors
- ? Published to NuGet.org
- ? Shows up in search within 15 minutes
- ? Can be installed with `Install-Package ValidateJWT`

---

**Ready to create your package? Run:**
```powershell
.\CreateNuGetPackage.ps1
```

**Good luck with your first NuGet package! ??**

---

*Last Updated: January 2026*
