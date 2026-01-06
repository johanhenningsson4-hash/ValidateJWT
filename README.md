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

## Installation

1. Clone this repository
2. Build the project in Visual Studio
3. Reference the compiled DLL in your project

```bash
git clone https://github.com/YOUR_USERNAME/ValidateJWT.git
```

## Usage

### Check if a JWT is Expired

```csharp
using TPDotNet.MTR.Common;

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

---

#### `IsValidNow(string jwt, TimeSpan? clockSkew = null, DateTime? nowUtc = null)`
Checks if the JWT token is valid at the current time.

**Parameters:**
- `jwt` - The JWT token string
- `clockSkew` - Optional clock skew tolerance (default: 5 minutes)
- `nowUtc` - Optional current UTC time (default: `DateTime.UtcNow`)

**Returns:** `bool` - `true` if valid, `false` otherwise

---

#### `GetExpirationUtc(string jwt)`
Extracts the expiration time from the JWT token.

**Parameters:**
- `jwt` - The JWT token string

**Returns:** `DateTime?` - The expiration time in UTC, or `null` if not found

---

#### `Base64UrlDecode(string input)`
Decodes a Base64URL encoded string.

**Parameters:**
- `input` - The Base64URL encoded string

**Returns:** `byte[]` - The decoded bytes

**Throws:** `FormatException` - If the input has invalid Base64URL length

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

## Requirements

- .NET Framework 4.8
- Dependencies:
  - System.Runtime.Serialization
  - TPDotnet.Base.Service (for logging)

## Project Structure

```
ValidateJWT/
??? ValidateJWT.cs          # Main validation logic
??? Log.cs                  # Logging utilities
??? App.config              # Application configuration
??? ValidateJWT.csproj      # Project file
??? ValidateJWT.sln         # Solution file
??? packages.config         # NuGet packages
??? Properties/             # Assembly info and resources
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is private and proprietary.

## Notes

- This library validates JWT time claims only - it does not verify signatures
- For full JWT validation including signature verification, consider using a comprehensive JWT library
- The library assumes UTC times for all operations

## Support

For issues or questions, please open an issue in the GitHub repository.
