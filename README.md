# ValidateJWT

A lightweight .NET Framework 4.8 library for validating JWT (JSON Web Token) expiration times and time-based claims.

## Overview

ValidateJWT is a utility library that provides simple methods to check JWT token validity based on time claims (`exp`, `nbf`, `iat`) without requiring full JWT verification. This is useful when you need to quickly check if a token has expired before making API calls or other operations.

## Features

- ? Check if a JWT token is expired
- ? Validate JWT token based on current time
- ? Extract expiration time from JWT tokens
- ? Configurable clock skew to account for time synchronization issues
- ? Base64URL decoding support
- ? Lightweight - no heavy dependencies
- ? Built for .NET Framework 4.8
- ? **Comprehensive test suite with 58+ unit tests**
- ? **~100% test coverage of public API**

## Installation

1. Clone this repository
2. Build the project in Visual Studio
3. Reference the compiled DLL in your project

```bash
git clone https://github.com/johanhenningsson4-hash/ValidateJWT.git
```

## Usage

### Check if a JWT is Expired

```csharp
using ValidateJWT.Common;

string jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...";

// Check if token is expired with default 5-minute clock skew
bool isExpired = ValidateJWT.IsExpired(jwt);

// Check with custom clock skew
bool isExpired = ValidateJWT.IsExpired(jwt, TimeSpan.FromMinutes(10));

// Check with custom clock skew and specific time
bool isExpired = ValidateJWT.IsExpired(jwt, TimeSpan.FromMinutes(5), DateTime.UtcNow);
```

### Validate JWT Token is Currently Valid

```csharp
// Check if token is valid now (not expired)
bool isValid = ValidateJWT.IsValidNow(jwt);

// With custom parameters
bool isValid = ValidateJWT.IsValidNow(jwt, TimeSpan.FromMinutes(10), DateTime.UtcNow);
```

### Get Token Expiration Time

```csharp
// Extract the expiration time from the token
DateTime? expirationTime = ValidateJWT.GetExpirationUtc(jwt);

if (expirationTime.HasValue)
{
    Console.WriteLine($"Token expires at: {expirationTime.Value}");
}
```

### Base64URL Decoding

```csharp
// Decode Base64URL encoded strings
byte[] decoded = ValidateJWT.Base64UrlDecode("SGVsbG8gV29ybGQ");
```

## API Reference

### Methods

#### `IsExpired(string jwt, TimeSpan? clockSkew = null, DateTime? nowUtc = null)`
Checks if the JWT token has expired.

**Parameters:**
- `jwt` - The JWT token string
- `clockSkew` - Optional clock skew tolerance (default: 5 minutes)
- `nowUtc` - Optional current UTC time (default: `DateTime.UtcNow`)

**Returns:** `bool` - `true` if expired, `false` otherwise

**Test Coverage:** ? 13 comprehensive tests

---

#### `IsValidNow(string jwt, TimeSpan? clockSkew = null, DateTime? nowUtc = null)`
Checks if the JWT token is valid at the current time.

**Parameters:**
- `jwt` - The JWT token string
- `clockSkew` - Optional clock skew tolerance (default: 5 minutes)
- `nowUtc` - Optional current UTC time (default: `DateTime.UtcNow`)

**Returns:** `bool` - `true` if valid, `false` otherwise

**Test Coverage:** ? 12 comprehensive tests

---

#### `GetExpirationUtc(string jwt)`
Extracts the expiration time from the JWT token.

**Parameters:**
- `jwt` - The JWT token string

**Returns:** `DateTime?` - The expiration time in UTC, or `null` if not found

**Test Coverage:** ? 10 comprehensive tests

---

#### `Base64UrlDecode(string input)`
Decodes a Base64URL encoded string.

**Parameters:**
- `input` - The Base64URL encoded string

**Returns:** `byte[]` - The decoded bytes

**Throws:** `FormatException` - If the input has invalid Base64URL length

**Test Coverage:** ? 18 comprehensive tests

## Clock Skew

The library includes a default clock skew of 5 minutes to account for time synchronization issues between different servers. You can customize this value:

```csharp
// 10-minute clock skew tolerance
bool isExpired = ValidateJWT.IsExpired(jwt, TimeSpan.FromMinutes(10));
```

## Error Handling

The library includes built-in error handling and logging:
- Invalid JWT formats return `false` or `null` values
- Exceptions are logged using `TPBaseLogging`
- `IsExpired` returns `true` on errors (fail-safe approach)

All error handling scenarios are validated by comprehensive unit tests.

## Testing

This project includes a comprehensive test suite:

### Test Statistics
- **Total Tests:** 58+
- **Test Coverage:** ~100% of public API
- **Test Framework:** MSTest 3.1.1
- **Target Framework:** .NET Framework 4.8

### Test Files
- `ValidateJWT.Tests/ValidateJWTTests.cs` - Core functionality tests (40 tests)
- `ValidateJWT.Tests/Base64UrlDecodeTests.cs` - Base64URL decoding tests (18 tests)
- `ValidateJWT.Tests/JwtTestHelper.cs` - Test utilities for generating test JWTs

### Running Tests

**Visual Studio:**
1. Open Test Explorer (Test ? Test Explorer)
2. Click "Run All" to execute all tests

**Command Line:**
```powershell
# Run all tests
dotnet test ValidateJWT.sln

# Run with detailed output
dotnet test ValidateJWT.sln --logger "console;verbosity=detailed"
```

For more information, see [TEST_COVERAGE.md](ValidateJWT.Tests/TEST_COVERAGE.md).

## Requirements

- .NET Framework 4.8
- Dependencies:
  - System.Runtime.Serialization
  - TPDotnet.Base.Service (for logging)

### Development Requirements
- Visual Studio 2019 or later
- MSTest.TestFramework 3.1.1 (for tests)
- MSTest.TestAdapter 3.1.1 (for tests)

## Project Structure

```
ValidateJWT/
??? ValidateJWT.cs              # Main validation logic
??? Log.cs                      # Logging utilities
??? App.config                  # Application configuration
??? ValidateJWT.csproj          # Project file
??? ValidateJWT.sln             # Solution file
??? packages.config             # NuGet packages
??? README.md                   # This file
??? PROJECT_ANALYSIS.md         # Detailed project analysis
??? Properties/                 # Assembly info and resources
??? ValidateJWT.Tests/          # Test project (NEW)
    ??? ValidateJWTTests.cs         # Main test suite (40 tests)
    ??? Base64UrlDecodeTests.cs     # Base64 tests (18 tests)
    ??? JwtTestHelper.cs            # Test utilities
    ??? TEST_COVERAGE.md            # Test documentation
    ??? ValidateJWT.Tests.csproj    # Test project file
```

## Code Quality

| Metric | Value |
|--------|-------|
| Production Code | ~290 lines |
| Test Code | ~766 lines |
| Test-to-Production Ratio | 2.6:1 |
| Test Coverage | ~100% |
| Total Tests | 58+ |

## Contributing

Contributions are welcome! Please follow these guidelines:

1. ? Ensure all existing tests pass
2. ? Add tests for new functionality
3. ? Follow existing naming conventions
4. ? Update documentation as needed
5. ? Submit a Pull Request

## License

This project is private and proprietary.

## Security Notice

?? **IMPORTANT:** This library validates JWT time claims only - it does **NOT** verify signatures!

### What This Library Does
? Checks if a JWT token has expired  
? Validates token based on current time  
? Extracts expiration timestamps  

### What This Library Does NOT Do
? Verify JWT signatures  
? Validate token issuer  
? Check token audience  
? Provide authentication/authorization  

**For production security:** Always use this library in conjunction with full JWT validation that includes signature verification. This library is best used for quick expiration pre-checks before making expensive API calls.

For full JWT validation including signature verification, consider using:
- **System.IdentityModel.Tokens.Jwt** (Microsoft)
- **jose-jwt** (dvsekhvalnov)
- **JWT.Net** (jwt-dotnet)

## Notes

- This library validates JWT time claims only - it does not verify signatures
- For full JWT validation including signature verification, consider using a comprehensive JWT library
- The library assumes UTC times for all operations
- All functionality is validated by comprehensive unit tests
- The library is thread-safe (no shared mutable state)

## Documentation

- [README.md](README.md) - This file (user guide)
- [PROJECT_ANALYSIS.md](PROJECT_ANALYSIS.md) - Detailed technical analysis
- [TEST_COVERAGE.md](ValidateJWT.Tests/TEST_COVERAGE.md) - Test suite documentation

## Support

For issues or questions, please open an issue in the GitHub repository.

---

**Version:** 1.0  
**Last Updated:** January 2025  
**Status:** ? Production-ready with comprehensive test coverage
