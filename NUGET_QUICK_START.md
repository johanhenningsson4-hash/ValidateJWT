# ?? Quick NuGet Package Creation

## ?? Create Package (30 seconds)

```powershell
.\CreateNuGetPackage.ps1
```

**This will:**
- ? Build in Release mode
- ? Generate XML documentation
- ? Create `.nupkg` file
- ? Show next steps

---

## ?? Publish to NuGet.org

### Step 1: Get API Key
1. Go to https://www.nuget.org/
2. Sign in
3. Account Settings ? API Keys ? Create

### Step 2: Push Package
```powershell
nuget push ValidateJWT.1.0.0.nupkg -Source https://api.nuget.org/v3/index.json -ApiKey YOUR_API_KEY
```

---

## ?? Test Locally First

```powershell
# Add to local feed
nuget add ValidateJWT.1.0.0.nupkg -source C:\LocalNuGetFeed

# Test install
Install-Package ValidateJWT -Source C:\LocalNuGetFeed
```

---

## ?? Package Info

**Name:** ValidateJWT  
**Version:** 1.0.0  
**Framework:** .NET Framework 4.7.2  
**Dependencies:** None  
**License:** MIT  

**Install Command:**
```powershell
Install-Package ValidateJWT
```

---

## ? Before Publishing

- [x] Build successful
- [x] XML docs generated
- [x] Tests passing (58+)
- [x] README updated
- [x] License included
- [ ] Tested locally
- [ ] Version correct
- [ ] Ready to publish!

---

**Full Guide:** See `NUGET_GUIDE.md`

**Just run:** `.\CreateNuGetPackage.ps1` ??
