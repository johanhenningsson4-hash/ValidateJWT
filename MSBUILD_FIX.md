# MSBuild Not Found - Quick Fix

## ?? Solution

The updated `CreateNuGetPackage.ps1` now automatically searches for MSBuild in:
- ? Visual Studio 2022 (Community, Professional, Enterprise)
- ? Visual Studio 2019 (Community, Professional, Enterprise)
- ? Build Tools installations
- ? Uses vswhere to locate any VS installation
- ? Checks PATH

## ?? Try Again

Just run the script again:
```powershell
.\CreateNuGetPackage.ps1
```

It should now find MSBuild automatically!

---

## ?? If Still Not Found

### Option 1: Use Visual Studio (Easiest)

1. **Open Visual Studio**
2. **Open** `ValidateJWT.sln`
3. **Change Configuration** to `Release` (top toolbar)
4. **Build** ? **Build Solution** (or press `Ctrl+Shift+B`)
5. **Verify** `bin\Release\ValidateJWT.dll` and `bin\Release\ValidateJWT.xml` exist
6. **Then create package:**
   ```powershell
   nuget pack ValidateJWT.nuspec
   ```

### Option 2: Install Build Tools

Download and install:
https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022

Select **".NET desktop build tools"** workload.

### Option 3: Manual MSBuild Path

If you know where MSBuild is installed, edit the script:

1. Open `CreateNuGetPackage.ps1`
2. Find this section (around line 35):
   ```powershell
   $msbuild = Find-MSBuild
   ```
3. Replace with your actual path:
   ```powershell
   $msbuild = "C:\Your\Path\To\MSBuild.exe"
   ```

---

## ?? Find MSBuild Manually

Run this in PowerShell to search for MSBuild:
```powershell
Get-ChildItem "C:\Program Files*" -Recurse -Filter "MSBuild.exe" -ErrorAction SilentlyContinue | Select-Object FullName
```

Common locations:
- `C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe`
- `C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe`

---

## ? After Fix

Once MSBuild is found, the script will:
1. ? Build in Release mode
2. ? Generate XML documentation
3. ? Create `ValidateJWT.1.0.0.nupkg`
4. ? Show next steps!

---

**The updated script should work now! Try running it again.** ??
