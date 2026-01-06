# ValidateJWT

[![NuGet](https://img.shields.io/nuget/v/ValidateJWT.svg)](https://www.nuget.org/packages/ValidateJWT/)
[![License](https://img.shields.io/github/license/johanhenningsson4-hash/ValidateJWT)](LICENSE.txt)

A lightweight .NET Framework 4.7.2 library for validating JWT (JSON Web Token) expiration times with optional signature verification support.

## ? Features

- ? **Time-Based Validation** - Check JWT expiration with configurable clock skew
- ? **Signature Verification** - HMAC-SHA256 (HS256) and RSA-SHA256 (RS256) support
- ? **Zero Dependencies** - Uses only built-in .NET Framework libraries
- ? **Thread-Safe** - No shared mutable state
- ? **Well-Tested** - 58+ unit tests with ~100% API coverage
- ? **Fast & Lightweight** - Minimal overhead
- ? **Production-Ready** - Comprehensive error handling

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

var token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...";

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

- [README.md](README.md) - This file
- [CHANGELOG.md](CHANGELOG.md) - Version history
- [SIGNATURE_VERIFICATION.md](SIGNATURE_VERIFICATION.md) - Complete signature verification guide
- [LICENSE.txt](LICENSE.txt) - MIT License

## ?? Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## ?? License

This project is licensed under the MIT License - see [LICENSE.txt](LICENSE.txt) for details.

## ?? Links

- **NuGet Package:** https://www.nuget.org/packages/ValidateJWT
- **GitHub Repository:** https://github.com/johanhenningsson4-hash/ValidateJWT
- **Issues:** https://github.com/johanhenningsson4-hash/ValidateJWT/issues

## ?? Support

For questions, issues, or feature requests:
- Open an issue on [GitHub](https://github.com/johanhenningsson4-hash/ValidateJWT/issues)
- Check existing documentation
- Review test examples

---

**Made with ?? for the .NET community**

**Author:** Johan Henningsson  
**Version:** 1.1.0  
**Last Updated:** January 2026  
**Status:** ? Production-Ready
