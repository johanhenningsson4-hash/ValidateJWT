# JWT Signature Verification - Feature Documentation

## ?? Overview

ValidateJWT now includes **optional signature verification** functionality alongside the existing time-based validation. This provides complete JWT validation while maintaining backward compatibility.

---

## ? New Features in v1.1.0

### Signature Verification Methods

| Method | Algorithm | Use Case |
|--------|-----------|----------|
| `VerifySignature(jwt, secretKey)` | HS256 | HMAC with symmetric secret |
| `VerifySignatureRS256(jwt, publicKeyXml)` | RS256 | RSA with public key |
| `GetAlgorithm(jwt)` | N/A | Get algorithm from header |

### New Classes

| Class | Purpose |
|-------|---------|
| `JwtVerificationResult` | Contains verification results and details |

---

## ?? API Reference

### VerifySignature (HS256)

Verifies JWT signature using HMAC-SHA256 symmetric encryption.

```csharp
public static JwtVerificationResult VerifySignature(string jwt, string secretKey)
```

**Parameters:**
- `jwt` - The JWT token string
- `secretKey` - The secret key used to sign the token

**Returns:** `JwtVerificationResult` with:
- `IsValid` - Whether signature is valid
- `Algorithm` - Algorithm used (e.g., "HS256")
- `ErrorMessage` - Error details if verification failed
- `IsExpired` - Whether token is expired (time check)

**Example:**
```csharp
using Johan.Common;

var token = "eyJhbGci...";
var secret = "your-secret-key";

var result = ValidateJWT.VerifySignature(token, secret);

if (result.IsValid && !result.IsExpired)
{
    // Token is valid and not expired
    Console.WriteLine("? Valid token");
}
else if (!result.IsValid)
{
    Console.WriteLine($"? Invalid signature: {result.ErrorMessage}");
}
else if (result.IsExpired)
{
    Console.WriteLine("? Token expired");
}
```

---

### VerifySignatureRS256 (RS256)

Verifies JWT signature using RSA-SHA256 asymmetric encryption.

```csharp
public static JwtVerificationResult VerifySignatureRS256(string jwt, string publicKeyXml)
```

**Parameters:**
- `jwt` - The JWT token string
- `publicKeyXml` - RSA public key in XML format

**Returns:** `JwtVerificationResult`

**Example:**
```csharp
var token = "eyJhbGci...";
var publicKey = "<RSAKeyValue>...</RSAKeyValue>";

var result = ValidateJWT.VerifySignatureRS256(token, publicKey);

if (result.IsValid)
{
    Console.WriteLine("? Signature verified");
}
```

---

### GetAlgorithm

Gets the algorithm from the JWT header.

```csharp
public static string GetAlgorithm(string jwt)
```

**Returns:** Algorithm name (e.g., "HS256", "RS256") or null

**Example:**
```csharp
var algorithm = ValidateJWT.GetAlgorithm(token);
Console.WriteLine($"Algorithm: {algorithm}");

// Use appropriate verification method
if (algorithm == "HS256")
{
    var result = ValidateJWT.VerifySignature(token, secretKey);
}
else if (algorithm == "RS256")
{
    var result = ValidateJWT.VerifySignatureRS256(token, publicKey);
}
```

---

### Base64UrlEncode (New)

Encodes byte array to Base64URL format.

```csharp
public static string Base64UrlEncode(byte[] input)
```

**Example:**
```csharp
var bytes = Encoding.UTF8.GetBytes("Hello");
var encoded = ValidateJWT.Base64UrlEncode(bytes);
// Result: "SGVsbG8"
```

---

## ?? Usage Scenarios

### Scenario 1: Simple HMAC Verification

```csharp
using Johan.Common;

public bool ValidateToken(string token, string secret)
{
    var result = ValidateJWT.VerifySignature(token, secret);
    return result.IsValid && !result.IsExpired;
}
```

---

### Scenario 2: RSA Public Key Verification

```csharp
public bool ValidateTokenWithPublicKey(string token, string publicKeyXml)
{
    var result = ValidateJWT.VerifySignatureRS256(token, publicKeyXml);
    
    if (!result.IsValid)
    {
        _logger.LogError($"Invalid signature: {result.ErrorMessage}");
        return false;
    }
    
    if (result.IsExpired)
    {
        _logger.LogWarning("Token expired");
        return false;
    }
    
    return true;
}
```

---

### Scenario 3: Multi-Algorithm Support

```csharp
public JwtVerificationResult ValidateTokenAutoDetect(string token, 
    string secretKey, string publicKeyXml)
{
    var algorithm = ValidateJWT.GetAlgorithm(token);
    
    switch (algorithm)
    {
        case "HS256":
            return ValidateJWT.VerifySignature(token, secretKey);
        
        case "RS256":
            return ValidateJWT.VerifySignatureRS256(token, publicKeyXml);
        
        default:
            return new JwtVerificationResult
            {
                IsValid = false,
                ErrorMessage = $"Unsupported algorithm: {algorithm}"
            };
    }
}
```

---

### Scenario 4: Two-Stage Validation

```csharp
public bool ValidateTokenOptimized(string token, string secret)
{
    // Stage 1: Quick expiration check (fast)
    if (ValidateJWT.IsExpired(token))
    {
        Console.WriteLine("Token expired - skipping signature check");
        return false;
    }
    
    // Stage 2: Signature verification (slower, but necessary)
    var result = ValidateJWT.VerifySignature(token, secret);
    return result.IsValid;
}
```

---

### Scenario 5: Complete Validation

```csharp
public class TokenValidationResponse
{
    public bool IsValid { get; set; }
    public string Status { get; set; }
    public DateTime? ExpiresAt { get; set; }
}

public TokenValidationResponse ValidateTokenComplete(string token, string secret)
{
    var response = new TokenValidationResponse();
    
    // Check signature
    var result = ValidateJWT.VerifySignature(token, secret);
    
    if (!result.IsValid)
    {
        response.Status = $"Invalid signature: {result.ErrorMessage}";
        return response;
    }
    
    // Get expiration
    var expiration = ValidateJWT.GetExpirationUtc(token);
    response.ExpiresAt = expiration;
    
    if (result.IsExpired)
    {
        response.Status = "Token expired";
        return response;
    }
    
    response.IsValid = true;
    response.Status = "Valid";
    return response;
}
```

---

## ?? Migration Guide

### From Time-Only Validation

**Before (v1.0.x):**
```csharp
// Only time validation
if (!ValidateJWT.IsExpired(token))
{
    // Use token (but signature not verified!)
    ProcessToken(token);
}
```

**After (v1.1.0):**
```csharp
// Time + signature validation
var result = ValidateJWT.VerifySignature(token, secretKey);

if (result.IsValid && !result.IsExpired)
{
    // Token is fully validated
    ProcessToken(token);
}
```

---

### Backward Compatibility

All existing methods still work exactly the same:

```csharp
// ? Still works - no changes needed
var expired = ValidateJWT.IsExpired(token);
var valid = ValidateJWT.IsValidNow(token);
var exp = ValidateJWT.GetExpirationUtc(token);
var decoded = ValidateJWT.Base64UrlDecode(input);
```

---

## ?? Security Notes

### ? What Signature Verification Provides

- ? Authenticity: Token was created by holder of secret/private key
- ? Integrity: Token content hasn't been tampered with
- ? Non-repudiation: Issuer cannot deny creating token

### ? What It Doesn't Provide (Yet)

- ? Issuer validation (check `iss` claim manually)
- ? Audience validation (check `aud` claim manually)
- ? Not-before validation (check `nbf` claim manually)

### ?? Best Practices

1. **Always verify signatures in production:**
   ```csharp
   var result = ValidateJWT.VerifySignature(token, secret);
   if (!result.IsValid) return Unauthorized();
   ```

2. **Store secrets securely:**
   ```csharp
   // ? Good - from secure storage
   var secret = _configuration.GetValue<string>("JWT:Secret");
   
   // ? Bad - hardcoded
   var secret = "my-secret-123";
   ```

3. **Use appropriate algorithm:**
   - **HS256**: Shared secret, both parties trust each other
   - **RS256**: Public/private key, issuer signs, anyone can verify

4. **Combine with time validation:**
   ```csharp
   var result = ValidateJWT.VerifySignature(token, secret);
   if (result.IsValid && !result.IsExpired)
   {
       // Fully validated
   }
   ```

---

## ?? Supported Algorithms

| Algorithm | Type | Verification Method | Key Type |
|-----------|------|---------------------|----------|
| **HS256** | HMAC | `VerifySignature()` | Symmetric secret |
| **RS256** | RSA | `VerifySignatureRS256()` | Public key (XML) |

### Future Support (Planned)

- ES256 (ECDSA)
- PS256 (RSA-PSS)
- None (unsigned)

---

## ?? Performance Considerations

### Time Validation (Fast)
```csharp
// ~0.1ms - Very fast
var expired = ValidateJWT.IsExpired(token);
```

### Signature Verification (Slower)
```csharp
// HS256: ~0.5-1ms
var result = ValidateJWT.VerifySignature(token, secret);

// RS256: ~2-5ms (RSA is slower)
var result = ValidateJWT.VerifySignatureRS256(token, publicKey);
```

### Optimization Strategy
```csharp
// Check expiration first (fast filter)
if (ValidateJWT.IsExpired(token))
{
    return false; // Skip expensive signature check
}

// Then verify signature
var result = ValidateJWT.VerifySignature(token, secret);
return result.IsValid;
```

---

## ?? Testing

### Unit Test Examples

```csharp
[TestClass]
public class SignatureVerificationTests
{
    [TestMethod]
    public void VerifySignature_ValidHS256_ReturnsTrue()
    {
        // Arrange
        var secret = "test-secret-key";
        var token = CreateHS256Token(secret, DateTime.UtcNow.AddHours(1));
        
        // Act
        var result = ValidateJWT.VerifySignature(token, secret);
        
        // Assert
        Assert.IsTrue(result.IsValid);
        Assert.IsFalse(result.IsExpired);
        Assert.AreEqual("HS256", result.Algorithm);
    }
    
    [TestMethod]
    public void VerifySignature_InvalidSecret_ReturnsFalse()
    {
        // Arrange
        var token = CreateHS256Token("correct-secret", DateTime.UtcNow.AddHours(1));
        
        // Act
        var result = ValidateJWT.VerifySignature(token, "wrong-secret");
        
        // Assert
        Assert.IsFalse(result.IsValid);
        Assert.IsNotNull(result.ErrorMessage);
    }
}
```

---

## ?? Examples by Language/Framework

### ASP.NET Core Middleware

```csharp
public class JwtValidationMiddleware
{
    private readonly RequestDelegate _next;
    private readonly string _secret;
    
    public async Task InvokeAsync(HttpContext context)
    {
        var token = context.Request.Headers["Authorization"]
            .FirstOrDefault()?.Replace("Bearer ", "");
        
        if (!string.IsNullOrEmpty(token))
        {
            var result = ValidateJWT.VerifySignature(token, _secret);
            
            if (!result.IsValid || result.IsExpired)
            {
                context.Response.StatusCode = 401;
                return;
            }
        }
        
        await _next(context);
    }
}
```

### Web API Controller

```csharp
[ApiController]
[Route("api/[controller]")]
public class SecureController : ControllerBase
{
    private readonly IConfiguration _config;
    
    [HttpGet]
    public IActionResult Get()
    {
        var token = Request.Headers["Authorization"]
            .FirstOrDefault()?.Replace("Bearer ", "");
        
        if (string.IsNullOrEmpty(token))
            return Unauthorized("Token required");
        
        var secret = _config["JWT:Secret"];
        var result = ValidateJWT.VerifySignature(token, secret);
        
        if (!result.IsValid)
            return Unauthorized(result.ErrorMessage);
        
        if (result.IsExpired)
            return Unauthorized("Token expired");
        
        return Ok("Access granted");
    }
}
```

---

## ?? Related Documentation

- [README.md](README.md) - Getting started
- [API Reference](README.md#api-reference) - Complete API docs
- [Security Guide](SECURITY.md) - Security best practices
- [Migration Guide](#migration-guide) - Upgrading from v1.0.x

---

## ? FAQ

**Q: Do I have to use signature verification?**  
A: No, it's optional. All existing time-based validation methods still work.

**Q: Which algorithm should I use?**  
A: Use **HS256** for shared secrets, **RS256** for public/private key scenarios.

**Q: Can I verify tokens from third-party issuers?**  
A: Yes, use RS256 with their public key.

**Q: What if the token uses an unsupported algorithm?**  
A: The method returns `IsValid=false` with an error message about the unsupported algorithm.

**Q: Is this slower than time-only validation?**  
A: Yes, signature verification is slower (0.5-5ms vs 0.1ms). Use two-stage validation for optimization.

---

*Last Updated: January 2026*  
*Feature Added: v1.1.0*
