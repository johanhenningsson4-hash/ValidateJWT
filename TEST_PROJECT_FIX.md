# Test Project Reference Fix - Step by Step

**Date:** January 2025  
**Issue:** CS0006 - Metadata file 'ValidateJWT.ValidateJWT.dll' could not be found  
**Status:** ? Solution identified, ready to apply

---

## ?? Root Cause

The main project file (`ValidateJWT.csproj`) has several issues:

1. **Wrong AssemblyName:** `ValidateJWT.ValidateJWT` (should be `ValidateJWT`)
2. **External dependency still referenced:** `TPDotnet.Base.Service.dll`
3. **Test files incorrectly included** in main project as compile items
4. **Bloated references** from old project structure

---

## ? The Fix

### Step 1: Close Visual Studio

**Why:** The project file cannot be edited while the solution is open.

```powershell
# Close Visual Studio completely
```

---

### Step 2: Backup Current Project File

```powershell
cd C:\Jobb\ValidateJWT
copy ValidateJWT.csproj ValidateJWT.csproj.backup
```

---

### Step 3: Edit ValidateJWT.csproj

Open `ValidateJWT.csproj` in a text editor (Notepad, VS Code, etc.) and make these changes:

#### Change 1: Fix AssemblyName (Line ~9)

**Find:**
```xml
<AssemblyName>ValidateJWT.ValidateJWT</AssemblyName>
```

**Replace with:**
```xml
<AssemblyName>ValidateJWT</AssemblyName>
```

#### Change 2: Fix RootNamespace (Line ~8)

**Find:**
```xml
<RootNamespace>ValidateJWT.ValidateJWT</RootNamespace>
```

**Replace with:**
```xml
<RootNamespace>ValidateJWT.Common</RootNamespace>
```

#### Change 3: Remove External TPDotnet.Base.Service Reference

**Find and DELETE this entire block:**
```xml
<Reference Include="TPDotnet.Base.Service">
  <HintPath>..\..\..\..\..\..\..\..\..\rsw.tpactdev\dev.net\Pos\bin\TPDotnet.Base.Service.dll</HintPath>
</Reference>
```

#### Change 4: Remove Test Files from Main Project

**Find and DELETE these lines:**
```xml
<Compile Include="ValidateJWT.Tests\Base64UrlDecodeTests.cs" />
<Compile Include="ValidateJWT.Tests\JwtTestHelper.cs" />
<Compile Include="ValidateJWT.Tests\Properties\AssemblyInfo.cs" />
<Compile Include="ValidateJWT.Tests\ValidateJWTTests.cs" />
```

**Also DELETE:**
```xml
<None Include="ValidateJWT.Tests\packages.config" />
<None Include="ValidateJWT.Tests\TEST_COVERAGE.md" />
<None Include="ValidateJWT.Tests\ValidateJWT.Tests.csproj" />
```

#### Change 5: Clean Up References Section

**Replace the entire `<ItemGroup>` with References with:**
```xml
<ItemGroup>
  <Reference Include="System" />
  <Reference Include="System.Core" />
  <Reference Include="System.Runtime.Serialization" />
  <Reference Include="System.Xml" />
</ItemGroup>
```

#### Change 6: Add XML Documentation Generation

**In the Release PropertyGroup, add:**
```xml
<PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|AnyCPU' ">
  <PlatformTarget>AnyCPU</PlatformTarget>
  <DebugType>pdbonly</DebugType>
  <Optimize>true</Optimize>
  <OutputPath>bin\Release\</OutputPath>
  <DefineConstants>TRACE</DefineConstants>
  <ErrorReport>prompt</ErrorReport>
  <WarningLevel>4</WarningLevel>
  <Prefer32Bit>false</Prefer32Bit>
  <DocumentationFile>bin\Release\ValidateJWT.xml</DocumentationFile>
</PropertyGroup>
```

#### Change 7: Remove x86 Platform Configurations

**DELETE these entire PropertyGroup sections:**
```xml
<PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug|x86'">
  ...
</PropertyGroup>

<PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Release|x86'">
  ...
</PropertyGroup>
```

#### Change 8: Clean Up Bootst rapper and ValueTuple References

**DELETE:**
```xml
<ItemGroup>
  <BootstrapperPackage Include=".NETFramework,Version=v4.6">
    ...
  </BootstrapperPackage>
  ...
</ItemGroup>
```

**DELETE:**
```xml
<Import Project="..\..\..\..\TechServices\packages\System.ValueTuple.4.6.1\build\net471\System.ValueTuple.targets" Condition="..." />
<Target Name="EnsureNuGetPackageBuildImports" BeforeTargets="PrepareForBuild">
  ...
</Target>
```

---

### Step 4: Save the Fixed Project File

Save `ValidateJWT.csproj` with all the above changes.

---

### Step 5: Clean Solution

```powershell
cd C:\Jobb\ValidateJWT
rmdir /s /q bin
rmdir /s /q obj
rmdir /s /q ValidateJWT.Tests\bin
rmdir /s /q ValidateJWT.Tests\obj
```

---

### Step 6: Reopen Solution in Visual Studio

1. Open Visual Studio
2. Open `ValidateJWT.sln`
3. If prompted to reload projects, click "Reload"

---

### Step 7: Rebuild Solution

```
Build ? Rebuild Solution
```

**Expected Result:**
```
Build succeeded.
    0 Warning(s)
    0 Error(s)
```

---

### Step 8: Run Tests

```
Test ? Run All Tests
```

**Expected Result:**
```
Total tests: 58
Passed: 58 ?
Failed: 0
Skipped: 0
Time: < 2 seconds
```

---

## ?? Complete Fixed ValidateJWT.csproj

Here's the complete, cleaned-up project file:

```xml
<Project ToolsVersion="15.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Import Project="$(MSBuildExtensionsPath)\$(MSBuildToolsVersion)\Microsoft.Common.props" Condition="Exists('$(MSBuildExtensionsPath)\$(MSBuildToolsVersion)\Microsoft.Common.props')" />
  <PropertyGroup>
    <Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
    <Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
    <ProjectGuid>{46918B27-6B53-4899-BC1C-FC7EAEF71871}</ProjectGuid>
    <OutputType>Library</OutputType>
    <RootNamespace>ValidateJWT.Common</RootNamespace>
    <AssemblyName>ValidateJWT</AssemblyName>
    <TargetFrameworkVersion>v4.8</TargetFrameworkVersion>
    <FileAlignment>512</FileAlignment>
    <Deterministic>true</Deterministic>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' ">
    <PlatformTarget>AnyCPU</PlatformTarget>
    <DebugSymbols>true</DebugSymbols>
    <DebugType>full</DebugType>
    <Optimize>false</Optimize>
    <OutputPath>bin\Debug\</OutputPath>
    <DefineConstants>DEBUG;TRACE</DefineConstants>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
    <Prefer32Bit>false</Prefer32Bit>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|AnyCPU' ">
    <PlatformTarget>AnyCPU</PlatformTarget>
    <DebugType>pdbonly</DebugType>
    <Optimize>true</Optimize>
    <OutputPath>bin\Release\</OutputPath>
    <DefineConstants>TRACE</DefineConstants>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
    <Prefer32Bit>false</Prefer32Bit>
    <DocumentationFile>bin\Release\ValidateJWT.xml</DocumentationFile>
  </PropertyGroup>
  <ItemGroup>
    <Reference Include="System" />
    <Reference Include="System.Core" />
    <Reference Include="System.Runtime.Serialization" />
    <Reference Include="System.Xml" />
  </ItemGroup>
  <ItemGroup>
    <Compile Include="Properties\AssemblyInfo.cs" />
    <Compile Include="ValidateJWT.cs" />
    <Compile Include="Properties\Resources.Designer.cs">
      <AutoGen>True</AutoGen>
      <DependentUpon>Resources.resx</DependentUpon>
      <DesignTime>True</DesignTime>
    </Compile>
    <Compile Include="Properties\Settings.Designer.cs">
      <AutoGen>True</AutoGen>
      <DependentUpon>Settings.settings</DependentUpon>
      <DesignTimeSharedInput>True</DesignTimeSharedInput>
    </Compile>
  </ItemGroup>
  <ItemGroup>
    <EmbeddedResource Include="Properties\Resources.resx">
      <Generator>ResXFileCodeGenerator</Generator>
      <LastGenOutput>Resources.Designer.cs</LastGenOutput>
      <SubType>Designer</SubType>
    </EmbeddedResource>
  </ItemGroup>
  <ItemGroup>
    <None Include="App.config" />
    <None Include="packages.config" />
    <None Include="Properties\Settings.settings">
      <Generator>SettingsSingleFileGenerator</Generator>
      <LastGenOutput>Settings.Designer.cs</LastGenOutput>
    </None>
    <None Include="README.md" />
    <None Include="PROJECT_ANALYSIS.md" />
    <None Include="ANALYSIS_SUMMARY.md" />
    <None Include="CHANGELOG.md" />
    <None Include="RELEASE_NOTES_v1.0.0.md" />
    <None Include="RELEASE_GUIDE.md" />
    <None Include="RELEASE_READY.md" />
    <None Include="SYNC_STATUS.md" />
    <None Include="WARNINGS_FIXED.md" />
    <None Include="BUILD_ISSUES_FIXED.md" />
    <None Include="Create-Release.ps1" />
  </ItemGroup>
  <ItemGroup>
    <Content Include=".gitignore" />
  </ItemGroup>
  <Import Project="$(MSBuildToolsPath)\Microsoft.CSharp.targets" />
</Project>
```

---

## ? Verification Checklist

After applying the fix:

- [ ] Visual Studio closed
- [ ] Project file backed up
- [ ] All changes applied to ValidateJWT.csproj
- [ ] File saved
- [ ] bin/obj folders cleaned
- [ ] Solution reopened in Visual Studio
- [ ] Solution rebuilds without errors
- [ ] All 58 tests run successfully

---

## ?? Expected Results

### Build Output
```
1>------ Rebuild All started: Project: ValidateJWT, Configuration: Debug Any CPU ------
1>  ValidateJWT -> C:\Jobb\ValidateJWT\bin\Debug\ValidateJWT.dll
2>------ Rebuild All started: Project: ValidateJWT.Tests, Configuration: Debug Any CPU ------
2>  ValidateJWT.Tests -> C:\Jobb\ValidateJWT\ValidateJWT.Tests\bin\Debug\ValidateJWT.Tests.dll
========== Rebuild All: 2 succeeded, 0 failed, 0 skipped ==========
```

### Test Results
```
Test Explorer
??? ValidateJWTTests (40 tests) ?
?   ??? IsExpired Tests (13) ?
?   ??? IsValidNow Tests (12) ?
?   ??? GetExpirationUtc Tests (10) ?
?   ??? Edge Cases (5) ?
??? Base64UrlDecodeTests (18 tests) ?

Total: 58 tests
Passed: 58 ?
Failed: 0
Duration: < 2s
```

---

## ?? What This Fixes

1. ? **Assembly Name** - Now generates `ValidateJWT.dll`
2. ? **Test Project Reference** - Can now find the DLL
3. ? **External Dependency** - TPDotnet.Base.Service removed
4. ? **Project Structure** - Test files only in test project
5. ? **Clean Build** - Only necessary references
6. ? **XML Documentation** - Generated for Release builds

---

## ?? Benefits

### Before Fix
- ? Build fails with CS0006 error
- ? Tests cannot run
- ? External dependency referenced
- ? Mixed project structure
- ? Bloated with unnecessary config

### After Fix
- ? Clean build
- ? All 58 tests run
- ? Zero external dependencies
- ? Proper project separation
- ? Professional structure

---

## ?? Alternative: Quick PowerShell Script

If you want to automate the fix, here's a PowerShell script:

```powershell
# Save as Fix-ProjectFile.ps1
$projectFile = "C:\Jobb\ValidateJWT\ValidateJWT.csproj"

# Backup
Copy-Item $projectFile "$projectFile.backup"

# Read content
$content = Get-Content $projectFile -Raw

# Apply fixes
$content = $content -replace '<AssemblyName>TPDotnet\.MTR\.ValidateJWT</AssemblyName>', '<AssemblyName>ValidateJWT</AssemblyName>'
$content = $content -replace '<RootNamespace>TPDotnet\.MTR\.ValidateJWT</RootNamespace>', '<RootNamespace>ValidateJWT.Common</RootNamespace>'

# Remove external reference (simplified - you may need to adjust the regex)
$content = $content -replace '(?s)<Reference Include="TPDotnet\.Base\.Service">.*?</Reference>', ''

# Save
Set-Content $projectFile $content -NoNewline

Write-Host "Project file fixed!" -ForegroundColor Green
Write-Host "Backup saved to: $projectFile.backup" -ForegroundColor Yellow
```

---

## ?? Related Documents

- [BUILD_ISSUES_FIXED.md](BUILD_ISSUES_FIXED.md) - Overall build status
- [WARNINGS_FIXED.md](WARNINGS_FIXED.md) - Code-level fixes
- [README.md](README.md) - Usage guide

---

**Status:** ? Fix ready to apply  
**Estimated Time:** 10 minutes  
**Difficulty:** Easy  
**Risk:** Low (backup created)

---

*Last Updated: January 2025*
