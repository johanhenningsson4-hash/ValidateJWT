# MANUAL FIX - Step by Step (Foolproof Method)

## ?? The Automated Script Had Issues

The PowerShell script didn't remove all problematic elements. Here's the **manual fix** that will work 100%.

---

## ?? Manual Fix Steps (10 minutes)

### Step 1: Close Visual Studio
- File ? Exit (or Alt+F4)
- **IMPORTANT:** Make sure it's completely closed!

### Step 2: Backup Your Project File
```powershell
cd C:\Jobb\ValidateJWT
Copy-Item ValidateJWT.csproj ValidateJWT.csproj.manual_backup
```

### Step 3: Open Project File in Notepad
Right-click `ValidateJWT.csproj` ? Open With ? Notepad

### Step 4: Make These Changes

#### Change #1: Fix RootNamespace (Line ~9)
**FIND:**
```xml
<RootNamespace>ValidateJWT</RootNamespace>
```

**REPLACE WITH:**
```xml
<RootNamespace>TPDotNet.MTR.Common</RootNamespace>
```

---

#### Change #2: Remove x86 Configurations (Lines ~60-80)
**DELETE THESE ENTIRE SECTIONS:**
```xml
<PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug|x86'">
  <DebugSymbols>true</DebugSymbols>
  <OutputPath>..\..\..\bin\</OutputPath>
  <DefineConstants>DEBUG;TRACE</DefineConstants>
  <DebugType>full</DebugType>
  <PlatformTarget>x86</PlatformTarget>
  <LangVersion>7.3</LangVersion>
  <ErrorReport>prompt</ErrorReport>
  <Prefer32Bit>false</Prefer32Bit>
</PropertyGroup>
```

AND:

```xml
<PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Release|x86'">
  <OutputPath>bin\x86\Release\</OutputPath>
  <DefineConstants>TRACE</DefineConstants>
  <Optimize>true</Optimize>
  <DebugType>pdbonly</DebugType>
  <PlatformTarget>x86</PlatformTarget>
  <LangVersion>7.3</LangVersion>
  <ErrorReport>prompt</ErrorReport>
  <Prefer32Bit>false</Prefer32Bit>
</PropertyGroup>
```

---

#### Change #3: Remove Bad System.Runtime.CompilerServices.Unsafe
**DELETE THIS ENTIRE BLOCK:**
```xml
<Reference Include="System.Runtime.CompilerServices.Unsafe, Version=6.0.3.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a, processorArchitecture=MSIL">
  <HintPath>..\..\..\..\TechServices\packages\System.Runtime.CompilerServices.Unsafe.6.1.2\lib\net462\System.Runtime.CompilerServices.Unsafe.dll</HintPath>
</Reference>
```

---

#### Change #4: Remove Unnecessary References
**DELETE THESE LINES:**
```xml
<Reference Include="System.Configuration" />
<Reference Include="System.Numerics" />
<Reference Include="System.ServiceModel" />
<Reference Include="System.Transactions" />
<Reference Include="System.Web" />
<Reference Include="System.Web.Extensions" />
<Reference Include="System.Xml.Linq" />
<Reference Include="System.Data.DataSetExtensions" />
<Reference Include="System.Data" />
<Reference Include="System.Deployment" />
<Reference Include="System.Drawing" />
<Reference Include="System.Windows.Forms" />
```

---

#### Change #5: Remove Test Files from Compile Items
**DELETE THESE 4 LINES:**
```xml
<Compile Include="ValidateJWT.Tests\Base64UrlDecodeTests.cs" />
<Compile Include="ValidateJWT.Tests\JwtTestHelper.cs" />
<Compile Include="ValidateJWT.Tests\Properties\AssemblyInfo.cs" />
<Compile Include="ValidateJWT.Tests\ValidateJWTTests.cs" />
```

---

#### Change #6: Remove Bootstrapper Section
**DELETE THIS ENTIRE ITEMGROUP:**
```xml
<ItemGroup>
  <BootstrapperPackage Include=".NETFramework,Version=v4.6">
    <Visible>False</Visible>
    <ProductName>Microsoft .NET Framework 4.6 %28x86 and x64%29</ProductName>
    <Install>true</Install>
  </BootstrapperPackage>
  <BootstrapperPackage Include="Microsoft.Net.Framework.3.5.SP1">
    <Visible>False</Visible>
    <ProductName>.NET Framework 3.5 SP1</ProductName>
    <Install>false</Install>
  </BootstrapperPackage>
</ItemGroup>
```

---

#### Change #7: Remove Bad Import and Target (At the very bottom)
**DELETE THESE LINES:**
```xml
<Import Project="..\..\..\..\TechServices\packages\System.ValueTuple.4.6.1\build\net471\System.ValueTuple.targets" Condition="Exists('..\..\..\..\TechServices\packages\System.ValueTuple.4.6.1\build\net471\System.ValueTuple.targets')" />
<Target Name="EnsureNuGetPackageBuildImports" BeforeTargets="PrepareForBuild">
  <PropertyGroup>
    <ErrorText>This project references NuGet package(s) that are missing on this computer. Use NuGet Package Restore to download them.  For more information, see http://go.microsoft.com/fwlink/?LinkID=322105. The missing file is {0}.</ErrorText>
  </PropertyGroup>
  <Error Condition="!Exists('..\..\..\..\TechServices\packages\System.ValueTuple.4.6.1\build\net471\System.ValueTuple.targets')" Text="$([System.String]::Format('$(ErrorText)', '..\..\..\..\TechServices\packages\System.ValueTuple.4.6.1\build\net471\System.ValueTuple.targets'))" />
</Target>
```

---

### Step 5: Save and Close Notepad
- File ? Save (Ctrl+S)
- File ? Exit

---

### Step 6: Clean Build Directories
Open PowerShell:
```powershell
cd C:\Jobb\ValidateJWT
Remove-Item -Recurse -Force bin, obj -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force ValidateJWT.Tests\bin, ValidateJWT.Tests\obj -ErrorAction SilentlyContinue
```

---

### Step 7: Reopen Visual Studio
1. Open Visual Studio
2. Open `ValidateJWT.sln`
3. If prompted to reload, click "Reload All"

---

### Step 8: Rebuild Solution
```
Build ? Rebuild Solution
```
Or press: **Ctrl+Shift+B**

---

### Step 9: Verify Success
Check Output window for:
```
Build succeeded.
    0 Warning(s)
    0 Error(s)

1> ValidateJWT -> C:\Jobb\ValidateJWT\bin\Debug\ValidateJWT.dll
2> ValidateJWT.Tests -> ...
```

---

### Step 10: Run Tests
```
Test ? Run All Tests
```
Or press: **Ctrl+R, A**

Expected:
```
Total: 58 tests
Passed: 58 ?
Failed: 0
```

---

## ? Verification Checklist

After manual fix:
- [ ] RootNamespace is `TPDotNet.MTR.Common`
- [ ] No x86 configurations
- [ ] No test files in main project Compile items
- [ ] No TechServices references
- [ ] No bootstrapper packages
- [ ] Build succeeds
- [ ] ValidateJWT.dll exists in bin\Debug\
- [ ] All 58 tests pass

---

## ?? If You Need Help Finding Text

Use Notepad's Find feature:
1. Open ValidateJWT.csproj in Notepad
2. Press Ctrl+F
3. Search for text from each "Change #" above
4. Delete as instructed
5. Repeat for all changes

---

## ?? Alternative: Use the New Script

I've created a simpler script that uses text replacement:

```powershell
cd C:\Jobb\ValidateJWT
.\Fix-Project-Simple.ps1
```

This new script is more reliable than the first one.

---

## ?? Why Manual Fix Might Be Better

- **More reliable:** You can see exactly what you're changing
- **Educational:** You understand the project structure
- **Verifiable:** You can double-check each change
- **Safe:** You have full control

---

**Take your time with the manual fix. It's straightforward but requires attention to detail.**
