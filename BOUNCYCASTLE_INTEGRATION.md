# ?? BouncyCastle.Cryptography Integration Guide

## ?? Overview

**BouncyCastle** provides superior cryptography support compared to the built-in .NET Framework cryptography:

### Why BouncyCastle?

? **More Algorithms:** ES256, ES384, PS256, PS384, PS512  
? **Better Cross-Platform:** Works consistently across platforms  
? **Modern Standards:** Latest cryptographic standards  
? **PEM Support:** Native PEM key format support  
? **Industry Standard:** Used by JWT libraries worldwide  

---

## ?? Current vs. BouncyCastle Implementation

### Current (System.Security.Cryptography)

**Pros:**
- ? Built-in, no dependencies
- ? Fast for HS256
- ? Works for basic RS256

**Cons:**
- ? Limited algorithms (only HS256, RS256)
- ? No ES256 (ECDSA) support
- ? No PS256 (RSA-PSS) support
- ? XML key format only
- ? Platform-specific behavior

### With BouncyCastle

**Pros:**
- ? Support for ES256, ES384, ES512 (ECDSA)
- ? Support for PS256, PS384, PS512 (RSA-PSS)
- ? PEM key format support
- ? JWK (JSON Web Key) support
- ? Consistent cross-platform
- ? Industry-standard library

**Cons:**
- ?? External dependency (~2.2 MB)
- ?? Slightly larger package size

---

## ?? Installation

### Option 1: NuGet Package Manager
```powershell
Install-Package BouncyCastle.Cryptography -Version 2.4.0
```

### Option 2: .NET CLI
```powershell
dotnet add package BouncyCastle.Cryptography --version 2.4.0
```

### Option 3: PackageReference
```xml
<PackageReference Include="BouncyCastle.Cryptography" Version="2.4.0" />
```

---

## ?? Implementation Plan

### Phase 1: Add BouncyCastle Support (Alongside Current)

**Keep existing methods** and **add new BouncyCastle-powered methods**:

```csharp
// Existing (System.Security.Cryptography)
public static JwtVerificationResult VerifySignature(string jwt, string secretKey)
public static JwtVerificationResult VerifySignatureRS256(string jwt, string publicKeyXml)

// NEW (BouncyCastle)
public static JwtVerificationResult VerifySignatureES256(string jwt, string publicKeyPem)
public static JwtVerificationResult VerifySignaturePS256(string jwt, string publicKeyPem)
public static JwtVerificationResult VerifyWithPem(string jwt, string keyPem, bool isSymmetric = false)
```

### Phase 2: Enhanced Verification (Auto-Detect Algorithm)

```csharp
public static JwtVerificationResult VerifySignatureAuto(string jwt, string key, KeyFormat format = KeyFormat.Auto)
```

Supports:
- HS256, HS384, HS512 (HMAC with symmetric key)
- RS256, RS384, RS512 (RSA with public key)
- ES256, ES384, ES512 (ECDSA with public key) **NEW!**
- PS256, PS384, PS512 (RSA-PSS with public key) **NEW!**

---

## ?? Code Implementation

### Step 1: Add Using Statement

```csharp
using Org.BouncyCastle.Crypto;
using Org.BouncyCastle.Crypto.Parameters;
using Org.BouncyCastle.Security;
using Org.BouncyCastle.OpenSsl;
using System.IO;
```

### Step 2: ES256 (ECDSA) Support

```csharp
/// <summary>
/// Verifies JWT signature using ECDSA-SHA256 (ES256) algorithm.
/// </summary>
/// <param name="jwt">The JWT token string</param>
/// <param name="publicKeyPem">ECDSA public key in PEM format</param>
/// <returns>JwtVerificationResult</returns>
public static JwtVerificationResult VerifySignatureES256(string jwt, string publicKeyPem)
{
    var result = new JwtVerificationResult();

    try
    {
        if (string.IsNullOrWhiteSpace(jwt))
        {
            result.ErrorMessage = "JWT token is null or empty";
            return result;
        }

        if (string.IsNullOrWhiteSpace(publicKeyPem))
        {
            result.ErrorMessage = "Public key is null or empty";
            return result;
        }

        var parts = jwt.Split('.');
        if (parts.Length != 3)
        {
            result.ErrorMessage = "Invalid JWT format (expected 3 parts)";
            return result;
        }

        // Parse header
        var header = ParseHeader(jwt);
        if (header == null)
        {
            result.ErrorMessage = "Failed to parse JWT header";
            return result;
        }

        result.Algorithm = header.Alg;

        if (header.Alg != "ES256")
        {
            result.ErrorMessage = $"Unsupported algorithm: {header.Alg}. Use VerifySignatureES256 for ES256 only.";
            return result;
        }

        // Parse PEM public key
        ECPublicKeyParameters publicKey;
        using (var reader = new StringReader(publicKeyPem))
        {
            var pemReader = new PemReader(reader);
            var keyObject = pemReader.ReadObject();
            
            if (keyObject is ECPublicKeyParameters)
            {
                publicKey = (ECPublicKeyParameters)keyObject;
            }
            else
            {
                result.ErrorMessage = "Invalid EC public key format";
                return result;
            }
        }

        // Verify signature
        var headerPayload = parts[0] + "." + parts[1];
        var signatureBytes = Base64UrlDecode(parts[2]);

        var signer = SignerUtilities.GetSigner("SHA-256withECDSA");
        signer.Init(false, publicKey);
        
        var dataBytes = Encoding.UTF8.GetBytes(headerPayload);
        signer.BlockUpdate(dataBytes, 0, dataBytes.Length);
        
        result.IsValid = signer.VerifySignature(signatureBytes);
        
        if (!result.IsValid)
        {
            result.ErrorMessage = "Signature verification failed";
        }

        // Check expiration
        result.IsExpired = IsExpired(jwt);
    }
    catch (Exception ex)
    {
        result.ErrorMessage = $"Verification error: {ex.Message}";
        Trace.WriteLine($"ValidateJWT.VerifySignatureES256 error: {ex.Message}");
    }

    return result;
}
```

### Step 3: PS256 (RSA-PSS) Support

```csharp
/// <summary>
/// Verifies JWT signature using RSA-PSS-SHA256 (PS256) algorithm.
/// </summary>
/// <param name="jwt">The JWT token string</param>
/// <param name="publicKeyPem">RSA public key in PEM format</param>
/// <returns>JwtVerificationResult</returns>
public static JwtVerificationResult VerifySignaturePS256(string jwt, string publicKeyPem)
{
    var result = new JwtVerificationResult();

    try
    {
        if (string.IsNullOrWhiteSpace(jwt))
        {
            result.ErrorMessage = "JWT token is null or empty";
            return result;
        }

        if (string.IsNullOrWhiteSpace(publicKeyPem))
        {
            result.ErrorMessage = "Public key is null or empty";
            return result;
        }

        var parts = jwt.Split('.');
        if (parts.Length != 3)
        {
            result.ErrorMessage = "Invalid JWT format (expected 3 parts)";
            return result;
        }

        // Parse header
        var header = ParseHeader(jwt);
        if (header == null)
        {
            result.ErrorMessage = "Failed to parse JWT header";
            return result;
        }

        result.Algorithm = header.Alg;

        if (header.Alg != "PS256")
        {
            result.ErrorMessage = $"Unsupported algorithm: {header.Alg}. Use VerifySignaturePS256 for PS256 only.";
            return result;
        }

        // Parse PEM public key
        RsaKeyParameters publicKey;
        using (var reader = new StringReader(publicKeyPem))
        {
            var pemReader = new PemReader(reader);
            var keyObject = pemReader.ReadObject();
            
            if (keyObject is RsaKeyParameters)
            {
                publicKey = (RsaKeyParameters)keyObject;
            }
            else
            {
                result.ErrorMessage = "Invalid RSA public key format";
                return result;
            }
        }

        // Verify signature (RSA-PSS)
        var headerPayload = parts[0] + "." + parts[1];
        var signatureBytes = Base64UrlDecode(parts[2]);

        var signer = SignerUtilities.GetSigner("SHA-256withRSAandMGF1");
        signer.Init(false, publicKey);
        
        var dataBytes = Encoding.UTF8.GetBytes(headerPayload);
        signer.BlockUpdate(dataBytes, 0, dataBytes.Length);
        
        result.IsValid = signer.VerifySignature(signatureBytes);
        
        if (!result.IsValid)
        {
            result.ErrorMessage = "Signature verification failed";
        }

        // Check expiration
        result.IsExpired = IsExpired(jwt);
    }
    catch (Exception ex)
    {
        result.ErrorMessage = $"Verification error: {ex.Message}";
        Trace.WriteLine($"ValidateJWT.VerifySignaturePS256 error: {ex.Message}");
    }

    return result;
}
```

### Step 4: Universal Verification Method

```csharp
/// <summary>
/// Verifies JWT signature using any supported algorithm (auto-detect).
/// </summary>
/// <param name="jwt">The JWT token string</param>
/// <param name="key">Secret key (for HMAC) or public key in PEM format</param>
/// <returns>JwtVerificationResult</returns>
public static JwtVerificationResult VerifySignatureUniversal(string jwt, string key)
{
    var algorithm = GetAlgorithm(jwt);
    
    switch (algorithm)
    {
        case "HS256":
        case "HS384":
        case "HS512":
            return VerifySignature(jwt, key);
        
        case "RS256":
        case "RS384":
        case "RS512":
            // Try PEM first, fallback to XML
            if (key.Contains("BEGIN"))
                return VerifySignatureRSWithPem(jwt, key, algorithm);
            else
                return VerifySignatureRS256(jwt, key); // XML format
        
        case "ES256":
            return VerifySignatureES256(jwt, key);
        
        case "ES384":
            return VerifySignatureES384(jwt, key);
        
        case "ES512":
            return VerifySignatureES512(jwt, key);
        
        case "PS256":
            return VerifySignaturePS256(jwt, key);
        
        case "PS384":
            return VerifySignaturePS384(jwt, key);
        
        case "PS512":
            return VerifySignaturePS512(jwt, key);
        
        default:
            return new JwtVerificationResult
            {
                IsValid = false,
                Algorithm = algorithm,
                ErrorMessage = $"Unsupported algorithm: {algorithm}"
            };
    }
}
```

---

## ?? Supported Algorithms After BouncyCastle

| Algorithm | Type | Current | With BouncyCastle |
|-----------|------|---------|-------------------|
| **HS256** | HMAC | ? Yes | ? Yes |
| **HS384** | HMAC | ? No | ? Yes |
| **HS512** | HMAC | ? No | ? Yes |
| **RS256** | RSA | ? Yes | ? Yes (improved) |
| **RS384** | RSA | ? No | ? Yes |
| **RS512** | RSA | ? No | ? Yes |
| **ES256** | ECDSA | ? No | ? **NEW!** |
| **ES384** | ECDSA | ? No | ? **NEW!** |
| **ES512** | ECDSA | ? No | ? **NEW!** |
| **PS256** | RSA-PSS | ? No | ? **NEW!** |
| **PS384** | RSA-PSS | ? No | ? **NEW!** |
| **PS512** | RSA-PSS | ? No | ? **NEW!** |

**Total:** 2 algorithms ? **12 algorithms!** ??

---

## ?? Usage Examples

### ES256 (ECDSA) Verification

```csharp
var token = "eyJhbGci...";
var publicKeyPem = @"
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE...
-----END PUBLIC KEY-----
";

var result = ValidateJWT.VerifySignatureES256(token, publicKeyPem);

if (result.IsValid)
{
    Console.WriteLine("? ES256 signature verified!");
}
```

### PS256 (RSA-PSS) Verification

```csharp
var publicKeyPem = @"
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...
-----END PUBLIC KEY-----
";

var result = ValidateJWT.VerifySignaturePS256(token, publicKeyPem);
```

### Universal Verification (Auto-Detect)

```csharp
// Works with any algorithm!
var result = ValidateJWT.VerifySignatureUniversal(token, keyPem);

Console.WriteLine($"Algorithm: {result.Algorithm}");
Console.WriteLine($"Valid: {result.IsValid}");
```

---

## ?? Project File Changes

### Update ValidateJWT.csproj

```xml
<ItemGroup>
  <Reference Include="System" />
  <Reference Include="System.Core" />
  <Reference Include="System.Runtime.Serialization" />
  <!-- BouncyCastle added -->
  <PackageReference Include="BouncyCastle.Cryptography" Version="2.4.0" />
</ItemGroup>
```

### Update ValidateJWT.nuspec

```xml
<dependencies>
  <group targetFramework=".NETFramework4.7.2">
    <dependency id="BouncyCastle.Cryptography" version="2.4.0" />
  </group>
</dependencies>
```

---

## ?? Migration Strategy

### Phase 1: Keep Existing (Backward Compatible)

```csharp
// Existing code still works - NO CHANGES NEEDED
var result = ValidateJWT.VerifySignature(token, secret);
var result = ValidateJWT.VerifySignatureRS256(token, xmlKey);
```

### Phase 2: Add New Methods (Opt-In)

```csharp
// NEW - Use when ready
var result = ValidateJWT.VerifySignatureES256(token, pemKey);
var result = ValidateJWT.VerifySignatureUniversal(token, key);
```

### Phase 3: Future - Deprecate Old Methods (Optional)

Mark old methods with `[Obsolete]` in v2.0.0:
```csharp
[Obsolete("Use VerifySignatureUniversal instead")]
public static JwtVerificationResult VerifySignatureRS256(string jwt, string publicKeyXml)
```

---

## ?? NuGet Package Impact

### Before BouncyCastle:
- **Size:** ~48 KB
- **Dependencies:** 0
- **Algorithms:** 2 (HS256, RS256)

### After BouncyCastle:
- **Size:** ~2.2 MB (BouncyCastle) + 48 KB = ~2.25 MB
- **Dependencies:** 1 (BouncyCastle.Cryptography)
- **Algorithms:** 12 (HS256/384/512, RS256/384/512, ES256/384/512, PS256/384/512)

### Size Comparison:
- Still small compared to full JWT libraries (5-10 MB)
- Industry-standard dependency
- Acceptable for the functionality gained

---

## ? Benefits Summary

| Aspect | Before | After |
|--------|--------|-------|
| **Algorithms** | 2 | 12 |
| **ECDSA Support** | ? | ? |
| **RSA-PSS Support** | ? | ? |
| **PEM Keys** | ? | ? |
| **Cross-Platform** | ?? | ? |
| **Industry Standard** | ?? | ? |
| **Package Size** | 48 KB | ~2.25 MB |
| **Dependencies** | 0 | 1 |

---

## ?? Next Steps

1. **Add BouncyCastle package**
   ```powershell
   Install-Package BouncyCastle.Cryptography -Version 2.4.0
   ```

2. **Implement ES256 support**
   - Add method to ValidateJWT.cs
   - Test with real tokens

3. **Implement PS256 support**
   - Add method to ValidateJWT.cs
   - Test with real tokens

4. **Add universal verification**
   - Implement auto-detect
   - Test all algorithms

5. **Update documentation**
   - README.md
   - SIGNATURE_VERIFICATION.md
   - API reference

6. **Write tests**
   - ES256 verification tests
   - PS256 verification tests
   - PEM key parsing tests

7. **Release as v1.2.0**
   - Bump version
   - Update CHANGELOG.md
   - Publish to NuGet

---

## ?? Resources

**BouncyCastle Documentation:**
- https://www.bouncycastle.org/csharp/
- https://github.com/bcgit/bc-csharp

**JWT Algorithm Specs:**
- https://datatracker.ietf.org/doc/html/rfc7518
- https://jwt.io/

**PEM Key Formats:**
- EC Public Key: `-----BEGIN PUBLIC KEY-----`
- RSA Public Key: `-----BEGIN PUBLIC KEY-----`
- RSA Private Key: `-----BEGIN RSA PRIVATE KEY-----`

---

*BouncyCastle Integration Guide - ValidateJWT v1.2.0*  
*Adds ES256, ES384, ES512, PS256, PS384, PS512 support*

