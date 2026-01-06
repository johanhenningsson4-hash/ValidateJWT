# ?? Create NuGet Package - Complete Guide

## ?? Three Easy Methods

---

## **Method 1: Double-Click Batch File (EASIEST)** ?

Just double-click this file:
```
BuildNuGetPackage.bat
```

**What it does:**
- ? Automatically finds Visual Studio Developer Command Prompt
- ? Sets up build environment (MSBuild, etc.)
- ? Builds project in Release mode
- ? Generates XML documentation
- ? Downloads NuGet.exe if needed
- ? Creates `ValidateJWT.1.0.0.nupkg`

**Time:** ~30 seconds  
**No configuration needed!**

---

## **Method 2: Developer Command Prompt (RECOMMENDED)**

### Step 1: Open Developer Command Prompt
**From Start Menu:**
- Windows 11: Start ? "Developer Command Prompt for VS"
- Windows 10: Start ? Visual Studio 2022 ? Developer Command Prompt

### Step 2: Navigate and Build
```cmd
cd C:\Jobb\ValidateJWT
.\BuildNuGetPackage.bat
```

**Or manually:**
```cmd
cd C:\Jobb\ValidateJWT
msbuild ValidateJWT.csproj /p:Configuration=Release /p:DocumentationFile=bin\Release\ValidateJWT.xml
nuget pack ValidateJWT.nuspec
```

---

## **Method 3: Visual Studio (MANUAL)**

### Step 1: Build in Release Mode
1. Open `ValidateJWT.sln` in Visual Studio
2. Change configuration to **Release** (top toolbar dropdown)
3. **Build** ? **Build Solution** (or press `Ctrl+Shift+B`)

### Step 2: Create Package
Open Package Manager Console (Tools ? NuGet Package Manager ? Package Manager Console):
```powershell
nuget pack ValidateJWT.nuspec
```

Or in regular PowerShell:
```powershell
cd C:\Jobb\ValidateJWT
.\nuget.exe pack ValidateJWT.nuspec
```

---

## ?? Environment Variables Used

The build process uses these Visual Studio environment variables (automatically set by Developer Command Prompt):

| Variable | Purpose |
|----------|---------|
| `%VSINSTALLDIR%` | Visual Studio installation directory |
| `%VCToolsInstallDir%` | Visual C++ tools location |
| `%WindowsSdkDir%` | Windows SDK location |
| `PATH` | Includes MSBuild, NuGet, etc. |

---

## ?? What Gets Created

After running any method:

```
ValidateJWT.1.0.0.nupkg  (Your NuGet package!)
```

**Package contains:**
- `lib\net472\ValidateJWT.dll` - The library
- `lib\net472\ValidateJWT.xml` - IntelliSense docs
- `lib\net472\ValidateJWT.pdb` - Debug symbols
- `README.md` - Documentation
- `LICENSE.txt` - MIT License

---

## ? Verify Package Contents

```powershell
# Extract and inspect (optional)
nuget.exe install ValidateJWT -Source . -OutputDirectory test
dir test\ValidateJWT.1.0.0\lib\net472\
```

Should show:
- ValidateJWT.dll
- ValidateJWT.xml
- ValidateJWT.pdb

---

## ?? Publish Package

### To NuGet.org (Public)

1. **Get API Key:**
   - Go to https://www.nuget.org/
   - Sign in ? Account Settings ? API Keys
   - Create new key with "Push" permission

2. **Push Package:**
```cmd
nuget push ValidateJWT.1.0.0.nupkg -Source https://api.nuget.org/v3/index.json -ApiKey YOUR_API_KEY
```

### To Local Feed (Testing)

```cmd
mkdir C:\LocalNuGetFeed
nuget add ValidateJWT.1.0.0.nupkg -source C:\LocalNuGetFeed
```

Then in Visual Studio:
- Tools ? Options ? NuGet Package Manager ? Package Sources
- Add source: Name: "Local", Source: `C:\LocalNuGetFeed`

---

## ?? Test Package Locally

Create test project:
```cmd
dotnet new console -n TestValidateJWT -f net472
cd TestValidateJWT
nuget install ValidateJWT -Source C:\LocalNuGetFeed
```

Test code:
```csharp
using Johan.Common;

var token = "eyJhbGci...";
bool expired = ValidateJWT.IsExpired(token);
Console.WriteLine($"Expired: {expired}");
```

---

## ?? Troubleshooting

### Issue: "MSBuild not found"
**Solution:** Use `BuildNuGetPackage.bat` - it finds MSBuild automatically

### Issue: "Developer Command Prompt not found"
**Solution:** Install Visual Studio or Build Tools:
- https://visualstudio.microsoft.com/downloads/

### Issue: "nuget is not recognized"
**Solution:** The batch file downloads it automatically, or download from:
- https://dist.nuget.org/win-x86-commandline/latest/nuget.exe

### Issue: "ValidateJWT.xml not generated"
**Solution:** Make sure you build with Release configuration and the project has:
```xml
<DocumentationFile>bin\Release\ValidateJWT.xml</DocumentationFile>
```

---

## ?? Quick Reference

| Task | Command |
|------|---------|
| **Create package (easy)** | Double-click `BuildNuGetPackage.bat` |
| **Create package (manual)** | `msbuild /p:Configuration=Release` then `nuget pack` |
| **Test locally** | `nuget add *.nupkg -source C:\LocalNuGetFeed` |
| **Publish** | `nuget push *.nupkg -Source nuget.org -ApiKey KEY` |
| **Install** | `Install-Package ValidateJWT` |

---

## ?? Recommended Workflow

1. **Build & Package:**
   ```
   Double-click BuildNuGetPackage.bat
   ```

2. **Test Locally:**
   ```cmd
   mkdir C:\LocalNuGetFeed
   nuget add ValidateJWT.1.0.0.nupkg -source C:\LocalNuGetFeed
   ```

3. **Create Test Project:**
   ```cmd
   dotnet new console -n Test -f net472
   Install-Package ValidateJWT -Source C:\LocalNuGetFeed
   ```

4. **If All Works, Publish:**
   ```cmd
   nuget push ValidateJWT.1.0.0.nupkg -Source https://api.nuget.org/v3/index.json -ApiKey YOUR_KEY
   ```

5. **Wait ~15 minutes** for NuGet.org indexing

6. **Done!** Package available at:
   ```
   https://www.nuget.org/packages/ValidateJWT
   ```

---

## ?? Summary

**Easiest way:** Just double-click `BuildNuGetPackage.bat`

**Most control:** Use Developer Command Prompt

**No surprises:** Build in Visual Studio first, then run `nuget pack`

---

**All methods work! Choose what's most comfortable for you.** ??

*Last Updated: January 2026*
