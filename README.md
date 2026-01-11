# ValidateJWT

[![NuGet](https://img.shields.io/nuget/v/ValidateJWT.svg)](https://www.nuget.org/packages/ValidateJWT/)
[![Build Status](https://github.com/johanhenningsson4-hash/ValidateJWT/workflows/CI%2FCD%20Pipeline/badge.svg)](https://github.com/johanhenningsson4-hash/ValidateJWT/actions)
[![License](https://img.shields.io/github/license/johanhenningsson4-hash/ValidateJWT)](LICENSE.txt)
[![.NET Framework](https://img.shields.io/badge/.NET%20Framework-4.7.2-blue)](https://dotnet.microsoft.com/)

A lightweight .NET Framework 4.7.2 library for validating JWT (JSON Web Token) expiration times with optional signature verification support.

## ? Features

- ? **Time-Based Validation** - Check JWT expiration with configurable clock skew
- ? **Signature Verification** - HMAC-SHA256 (HS256) and RSA-SHA256 (RS256) support
- ? **Zero Dependencies** - Uses only built-in .NET Framework libraries
- ? **Thread-Safe** - No shared mutable state
- ? **Well-Tested** - 58+ unit tests with ~100% API coverage
- ? **Cross-Platform** - Works on x86, x64, and AnyCPU
- ? **Fast & Lightweight** - Minimal overhead
- ? **CI/CD Ready** - Automated testing and deployment
- ? **Production-Ready** - Comprehensive error handling

## ?? Platform Compatibility

ValidateJWT is built as **AnyCPU** and works on both x86 and x64 platforms:

- ? Windows x86 (32-bit)
- ? Windows x64 (64-bit)
- ? .NET Framework 4.7.2 or higher
- ? No native dependencies
- ? Pure managed code

### System Requirements
- **OS:** Windows 7 SP1 or higher
- **.NET:** Framework 4.7.2 or higher
- **Architecture:** Any (x86, x64, AnyCPU)

## ?? Installation

### NuGet Package Manager
```powershell
Install-Package ValidateJWT
```

### .NET CLI
```powershell
dotnet add package ValidateJWT
```

### PackageReference
```xml
<PackageReference Include="ValidateJWT" Version="1.1.0" />
```

## ?? Quick Start

### Time-Based Validation (Fast Pre-Check)

```csharp
using Johan.Common;

var token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."";

// Check if token is expired
if (ValidateJWT.IsExpired(token))
{
    Console.WriteLine("Token has expired");
}

// Check if token is currently valid
if (ValidateJWT.IsValidNow(token))
{
    Console.WriteLine("Token is valid");
}

// Get expiration time
DateTime? expiration = ValidateJWT.GetExpirationUtc(token);
Console.WriteLine($"Expires: {expiration}");
```

### Signature Verification (Complete Validation) ??

```csharp
using Johan.Common;

var token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...";
var secret = "your-secret-key";

// Verify signature with HS256
var result = ValidateJWT.VerifySignature(token, secret);

if (result.IsValid && !result.IsExpired)
{
    Console.WriteLine("? Token is valid and not expired");
}
else if (!result.IsValid)
{
    Console.WriteLine($"? Invalid signature: {result.ErrorMessage}");
}
else if (result.IsExpired)
{
    Console.WriteLine("? Token has expired");
}
```

## ?? API Reference

### Time-Based Validation Methods

#### `IsExpired(jwt, clockSkew, nowUtc)`
Checks if a JWT token has expired.

```csharp
bool isExpired = ValidateJWT.IsExpired(token);
bool isExpired = ValidateJWT.IsExpired(token, TimeSpan.FromMinutes(10));
```

**Parameters:**
- `jwt` (string) - JWT token
- `clockSkew` (TimeSpan?) - Clock skew tolerance (default: 5 minutes)
- `nowUtc` (DateTime?) - Current UTC time (default: DateTime.UtcNow)

**Returns:** `bool` - True if expired, false otherwise

---

#### `IsValidNow(jwt, clockSkew, nowUtc)`
Checks if a JWT token is currently valid.

```csharp
bool isValid = ValidateJWT.IsValidNow(token);
```

**Returns:** `bool` - True if valid, false if expired or invalid

---

#### `GetExpirationUtc(jwt)`
Extracts the expiration time from a JWT token.

```csharp
DateTime? expiration = ValidateJWT.GetExpirationUtc(token);
```

**Returns:** `DateTime?` - Expiration time in UTC, or null if not found

---

### Signature Verification Methods ??

#### `VerifySignature(jwt, secretKey)`
Verifies JWT signature using HMAC-SHA256 (HS256).

```csharp
var result = ValidateJWT.VerifySignature(token, "your-secret-key");

if (result.IsValid && !result.IsExpired)
{
    // Token is fully validated
}
```

**Parameters:**
- `jwt` (string) - JWT token
- `secretKey` (string) - Secret key used to sign the token

**Returns:** `JwtVerificationResult`
- `IsValid` (bool) - Whether signature is valid
- `Algorithm` (string) - Algorithm used (e.g., "HS256")
- `ErrorMessage` (string) - Error details if failed
- `IsExpired` (bool) - Whether token is expired

---

#### `VerifySignatureRS256(jwt, publicKeyXml)`
Verifies JWT signature using RSA-SHA256 (RS256).

```csharp
var publicKey = "<RSAKeyValue>...</RSAKeyValue>";
var result = ValidateJWT.VerifySignatureRS256(token, publicKey);
```

**Parameters:**
- `jwt` (string) - JWT token
- `publicKeyXml` (string) - RSA public key in XML format

**Returns:** `JwtVerificationResult`

---

#### `GetAlgorithm(jwt)` ??
Gets the algorithm from the JWT header.

```csharp
string algorithm = ValidateJWT.GetAlgorithm(token);
// Returns: "HS256", "RS256", etc.
```

---

### Helper Methods

#### `Base64UrlDecode(input)`
Decodes Base64URL encoded strings.

```csharp
byte[] decoded = ValidateJWT.Base64UrlDecode("SGVsbG8gV29ybGQ");
```

#### `Base64UrlEncode(input)` ??
Encodes byte arrays to Base64URL format.

```csharp
byte[] data = Encoding.UTF8.GetBytes("Hello");
string encoded = ValidateJWT.Base64UrlEncode(data);
```

## ?? Usage Scenarios

### Scenario 1: Quick Expiration Check (Fastest)

```csharp
// Fast pre-check before expensive operations
if (ValidateJWT.IsExpired(token))
{
    return Unauthorized("Token expired");
}

// Proceed with API call
```

### Scenario 2: Complete Validation (Recommended for Security)

```csharp
// Full signature and expiration validation
var result = ValidateJWT.VerifySignature(token, secretKey);

if (!result.IsValid)
{
    return Unauthorized($"Invalid token: {result.ErrorMessage}");
}

if (result.IsExpired)
{
    return Unauthorized("Token expired");
}

// Token is fully validated
```

### Scenario 3: Two-Stage Validation (Optimized)

```csharp
// Stage 1: Quick time check (0.1ms)
if (ValidateJWT.IsExpired(token))
{
    return Unauthorized("Token expired");
}

// Stage 2: Signature verification (0.5-5ms)
var result = ValidateJWT.VerifySignature(token, secretKey);

if (!result.IsValid)
{
    return Unauthorized("Invalid signature");
}

// Token is valid
```

### Scenario 4: Multi-Algorithm Support

```csharp
var algorithm = ValidateJWT.GetAlgorithm(token);

JwtVerificationResult result;
switch (algorithm)
{
    case "HS256":
        result = ValidateJWT.VerifySignature(token, secretKey);
        break;
    case "RS256":
        result = ValidateJWT.VerifySignatureRS256(token, publicKey);
        break;
    default:
        return Unauthorized($"Unsupported algorithm: {algorithm}");
}

if (result.IsValid && !result.IsExpired)
{
    // Token is valid
}
```

## ?? Configuration

### Clock Skew Tolerance

Account for time synchronization issues between servers:

```csharp
// Default: 5 minutes
bool isExpired = ValidateJWT.IsExpired(token);

// Custom: 10 minutes
bool isExpired = ValidateJWT.IsExpired(token, TimeSpan.FromMinutes(10));

// No clock skew
bool isExpired = ValidateJWT.IsExpired(token, TimeSpan.Zero);
```

### Time Injection (Testing)

Inject custom time for deterministic testing:

```csharp
var testTime = new DateTime(2025, 1, 15, 12, 0, 0, DateTimeKind.Utc);
bool isExpired = ValidateJWT.IsExpired(token, null, testTime);
```

## ?? Security Considerations

### ? What This Library Provides

- ? JWT expiration validation
- ? Signature verification (HS256, RS256)
- ? Algorithm detection
- ? Clock skew handling
- ? Comprehensive error handling

### ?? What This Library Does NOT Provide

- ? Issuer (`iss`) claim validation
- ? Audience (`aud`) claim validation
- ? Not-before (`nbf`) claim validation (planned for v1.2)
- ? Token generation/signing

### ?? Best Practices

1. **Always verify signatures in production:**
   ```csharp
   var result = ValidateJWT.VerifySignature(token, secret);
   if (!result.IsValid) return Unauthorized();
   ```

2. **Store secrets securely:**
   ```csharp
   // ? Good - from configuration
   var secret = _configuration["JWT:Secret"];
   
   // ? Bad - hardcoded
   var secret = "my-secret-123";
   ```

3. **Use appropriate algorithm:**
   - **HS256** - Shared secret, both parties trust each other
   - **RS256** - Public/private key, issuer signs, anyone verifies

4. **Combine with full JWT validation:**
   ```csharp
   // Step 1: Quick expiration check
   if (ValidateJWT.IsExpired(token)) return Unauthorized();
   
   // Step 2: Signature verification
   var result = ValidateJWT.VerifySignature(token, secret);
   if (!result.IsValid) return Unauthorized();
   
   // Step 3: Validate claims (issuer, audience, etc.)
   // ... your claim validation logic
   ```

## ?? Testing

Comprehensive test suite with 58+ unit tests:

```csharp
// Test expiration
[TestMethod]
public void IsExpired_ExpiredToken_ReturnsTrue()
{
    var token = CreateExpiredToken();
    Assert.IsTrue(ValidateJWT.IsExpired(token));
}

// Test signature verification
[TestMethod]
public void VerifySignature_ValidToken_ReturnsTrue()
{
    var result = ValidateJWT.VerifySignature(validToken, secret);
    Assert.IsTrue(result.IsValid);
}
```

**Test Coverage:**
- 13 tests for `IsExpired()`
- 12 tests for `IsValidNow()`
- 10 tests for `GetExpirationUtc()`
- 18 tests for `Base64UrlDecode()`
- Plus additional tests for signature verification

## ?? Performance

| Operation | Time | Notes |
|-----------|------|-------|
| Time Check | ~0.1ms | Very fast |
| HS256 Verify | ~0.5-1ms | HMAC verification |
| RS256 Verify | ~2-5ms | RSA verification (slower) |

**Optimization tip:** Check expiration first, then verify signature.

## ?? Version History

### v1.1.0 (Latest) ??
- Added JWT signature verification (HS256, RS256)
- New `VerifySignature()` and `VerifySignatureRS256()` methods
- New `JwtVerificationResult` class
- New `GetAlgorithm()` helper
- New `Base64UrlEncode()` helper
- 100% backward compatible with v1.0.x

### v1.0.1
- Documentation improvements
- Enhanced NuGet package metadata
- Clean namespace (Johan.Common)

### v1.0.0
- Initial release
- Time-based JWT validation
- Base64URL encoding/decoding
- 58+ comprehensive tests

See [CHANGELOG.md](CHANGELOG.md) for complete history.

## ?? Documentation

### User Documentation
- [README.md](README.md) - This file (getting started)
- [CHANGELOG.md](CHANGELOG.md) - Version history
- [SIGNATURE_VERIFICATION.md](SIGNATURE_VERIFICATION.md) - Signature verification guide
- [LICENSE.txt](LICENSE.txt) - MIT License

### Developer Documentation
- [CI_CD_GUIDE.md](CI_CD_GUIDE.md) - CI/CD pipeline and automation
- [BOUNCYCASTLE_INTEGRATION.md](BOUNCYCASTLE_INTEGRATION.md) - BouncyCastle integration
- [RUN_TESTS_GUIDE.md](RUN_TESTS_GUIDE.md) - Test execution guide
- [PLATFORM_COMPATIBILITY.md](PLATFORM_COMPATIBILITY.md) - Platform compatibility details
- [GITHUB_SECRETS_SETUP.md](GITHUB_SECRETS_SETUP.md) - GitHub secrets configuration

### Maintenance Documentation
- [COMPANY_REFERENCES_CLEANUP.md](COMPANY_REFERENCES_CLEANUP.md) - Cleanup guide
- [UNUSED_REFERENCES_ANALYSIS.md](UNUSED_REFERENCES_ANALYSIS.md) - Dependency analysis

## ?? CI/CD & Automation

### GitHub Actions Workflows

ValidateJWT includes a complete CI/CD pipeline:

- **?? Continuous Integration** - Automated build and test on every push
- **? Pull Request Validation** - Automatic testing on PRs
- **? Nightly Builds** - Scheduled regression testing
- **? Code Coverage** - Automated coverage reporting
- **? Security Scanning** - Vulnerability detection
- **? Automated Publishing** - Zero-touch NuGet deployment

### Automation Scripts

**Testing:**
```powershell
# Run all tests with coverage
.\Run-AutomatedTests.ps1 -GenerateCoverage

# Fix and run tests
.\Fix-And-RunTests.ps1
```

**Publishing:**
```powershell
# Build NuGet package
.\BuildNuGetPackage.bat

# Publish to NuGet.org
.\Publish-NuGet.ps1 -Version "1.1.0"
```

**Maintenance:**
```powershell
# Remove unused references
.\Remove-UnusedReferences.ps1

# Clean company references
.\Remove-CompanyReferences.ps1

# Setup CI/CD
.\Setup-CICD.ps1
```

**See [CI_CD_GUIDE.md](CI_CD_GUIDE.md) for complete automation documentation.**

## ?? Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Add tests for new functionality
4. Ensure all tests pass (`.\Run-AutomatedTests.ps1`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Development Setup

```powershell
# Clone repository
git clone https://github.com/johanhenningsson4-hash/ValidateJWT.git
cd ValidateJWT

# Restore packages
nuget restore ValidateJWT.sln

# Build
msbuild ValidateJWT.sln /p:Configuration=Release

# Run tests
.\Run-AutomatedTests.ps1
```

### Code Quality Standards

- ? Maintain ~100% test coverage
- ? Follow existing code style
- ? Add XML documentation for public APIs
- ? Include usage examples in tests
- ? Update CHANGELOG.md for changes

## ?? Links

- **NuGet Package:** https://www.nuget.org/packages/ValidateJWT
- **GitHub Repository:** https://github.com/johanhenningsson4-hash/ValidateJWT
- **Issues:** https://github.com/johanhenningsson4-hash/ValidateJWT/issues
- **GitHub Actions:** https://github.com/johanhenningsson4-hash/ValidateJWT/actions
- **Releases:** https://github.com/johanhenningsson4-hash/ValidateJWT/releases

## ?? Support

For questions, issues, or feature requests:
- Open an issue on [GitHub](https://github.com/johanhenningsson4-hash/ValidateJWT/issues)
- Check [CI_CD_GUIDE.md](CI_CD_GUIDE.md) for automation help
- Review test examples in ValidateJWT.Tests
- See documentation files for specific topics

---

**Made with ?? for the .NET community**

**Author:** Johan Henningsson  
**Version:** 1.1.0  
**Framework:** .NET Framework 4.7.2  
**Last Updated:** January 2026  
**Status:** ? Production-Ready | ? CI/CD Enabled | ? Fully Automated

## ?? Build Instructions

To build the library and run tests, always use the platform string `AnyCPU` (no space):

```powershell
msbuild ValidateJWT.sln /p:Configuration=Release /p:Platform=AnyCPU
```

If you use `AnyCPU` (with a space), you may get an error about `BaseOutputPath/OutputPath property is not set`.

**Troubleshooting:**
- If you see an error about `BaseOutputPath/OutputPath property is not set`, check that you are using `AnyCPU` (no space) for the platform.
- Both Debug and Release configurations are supported for `AnyCPU`, `x64`, and `x86` (if defined in the project file).

---
