# ValidateJWT v1.6.0 Release Notes

**Release Date:** May 27, 2026  
**Type:** Minor Release (Feature Addition)  
**Compatibility:** 100% Backward Compatible

## ? What's New

### Proactive Token Renewal

Version 1.6.0 introduces **proactive token renewal** capabilities, allowing applications to automatically detect and renew JWT tokens before they expire. This prevents authentication failures and improves user experience in long-running applications.

## ✨ New Features

### 1. `ShouldRenewToken()` Method

Check if a token should be renewed based on time remaining until expiration:

```csharp
// Renew token if it expires within 5 minutes
if (ValidateJWT.ShouldRenewToken(token, 5))
{
	token = await GetNewTokenAsync();
}
```

**Key Benefits:**
- Prevents token expiration issues before they happen
- Configurable renewal window (1-30 minutes typical)
- Returns `false` for expired or invalid tokens
- Supports custom time injection for testing

### 2. `GetTimeUntilRenewal()` Method

Calculate the exact time remaining until token renewal is needed:

```csharp
var timeUntilRenewal = ValidateJWT.GetTimeUntilRenewal(token, 5);
if (timeUntilRenewal.HasValue)
{
	Console.WriteLine($"Renew in {timeUntilRenewal.Value.TotalMinutes:F1} minutes");
	ScheduleRenewal(timeUntilRenewal.Value);
}
else
{
	// Token should be renewed now
	await RenewTokenAsync();
}
```

**Key Benefits:**
- Schedule automatic token renewal
- Display countdown to users
- Implement background renewal services
- Optimize renewal timing

## ? Use Cases

### 1. Long-Running Applications

```csharp
public class ApiService
{
	private string _token;

	public async Task<string> CallApiAsync(string endpoint)
	{
		// Ensure token is valid before API call
		if (ValidateJWT.ShouldRenewToken(_token, 5))
		{
			_token = await RenewTokenAsync();
		}

		return await HttpClient.GetAsync(endpoint, _token);
	}
}
```

### 2. Background Services with Timer

```csharp
public class TokenRenewalService
{
	private Timer _renewalTimer;

	private void ScheduleNextRenewal()
	{
		var timeUntilRenewal = ValidateJWT.GetTimeUntilRenewal(_token, 5);
		if (timeUntilRenewal.HasValue)
		{
			_renewalTimer = new Timer(
				async _ => await RenewTokenAsync(),
				null,
				timeUntilRenewal.Value,
				Timeout.InfiniteTimeSpan);
		}
	}
}
```

### 3. User-Facing Applications

```csharp
// Show renewal countdown to users
var timeUntilRenewal = ValidateJWT.GetTimeUntilRenewal(token, 5);
if (timeUntilRenewal.HasValue)
{
	lblStatus.Text = $"Session expires in {timeUntilRenewal.Value.TotalMinutes:F0} minutes";
}
```

## ? Comprehensive Documentation

This release includes:
- **TokenRenewalExamples.md** - 20+ code examples and best practices
- **20 new unit tests** - Full test coverage for renewal scenarios
- **Updated API documentation** - Complete method signatures and parameters
- **Real-world integration examples** - HTTP clients, background services, timers

## ? Testing

### New Test Coverage
- 20 new unit tests specifically for token renewal
- Edge cases: expired tokens, invalid tokens, null tokens
- Various renewal windows: 1, 5, 10, 15, 30 minutes
- Custom time injection for deterministic testing
- Integration scenarios with existing methods

### Total Test Suite
- **138 total unit tests** (up from 118)
- All tests passing ✓
- ~100% API coverage maintained

## ? What Hasn't Changed

### Backward Compatibility
- ✅ All existing methods unchanged
- ✅ No breaking changes
- ✅ Existing code continues to work without modification
- ✅ New methods are purely additive

### Existing Features Still Available
- Time-based validation (`IsExpired`, `IsValidNow`, `GetExpirationUtc`)
- Signature verification (HS256, RS256)
- Claim extraction (`GetClaim<T>`, `HasClaim`)
- JWT generation (`CreateJwt`, `CreateJwtRS256`, `CreateSimpleJwt`)
- Claim validation (`IsIssuerValid`, `IsAudienceValid`, `IsNotBeforeValid`)

## ? Configuration Examples

### Aggressive Renewal (1 minute)
```csharp
if (ValidateJWT.ShouldRenewToken(token, 1))
{
	// Renew very close to expiration
}
```

### Conservative Renewal (15 minutes)
```csharp
if (ValidateJWT.ShouldRenewToken(token, 15))
{
	// Renew well before expiration
}
```

### Very Conservative (30 minutes)
```csharp
// Good for long-running operations
if (ValidateJWT.ShouldRenewToken(token, 30))
{
	// Ensure token valid for next 30 minutes
}
```

## ? Best Practices

1. **Choose Appropriate Window**: 5-15 minutes is typical for most applications
2. **Handle Renewal Failures**: Always have fallback logic if renewal fails
3. **Avoid Excessive Renewals**: Don't renew more frequently than necessary
4. **Use Proactive Renewal**: Don't wait until token is expired
5. **Log Renewal Events**: Track renewals for debugging and monitoring
6. **Test Edge Cases**: Test with expired, invalid, and missing tokens

## ? Migration Guide

### For Existing Users

No changes required! All existing code continues to work. To add token renewal:

**Before (v1.5.0 and earlier):**
```csharp
if (ValidateJWT.IsExpired(token))
{
	// Token already expired - might fail
	token = await GetNewTokenAsync();
}
```

**After (v1.6.0):**
```csharp
// Proactive approach - renew before expiration
if (ValidateJWT.ShouldRenewToken(token, 5))
{
	token = await GetNewTokenAsync();
}
```

## ? Package Updates

### NuGet Package
```xml
<PackageReference Include="ValidateJWT" Version="1.6.0" />
```

### Installation
```powershell
dotnet add package ValidateJWT --version 1.6.0
# or
Install-Package ValidateJWT -Version 1.6.0
```

## ? Files Changed

- `ValidateJWT.cs` - Added 2 new public methods with full documentation
- `Properties/AssemblyInfo.cs` - Version bumped to 1.6.0.0
- `ValidateJWT.nuspec` - Updated version, description, and release notes
- `CHANGELOG.md` - Added v1.6.0 entry with detailed changes
- `README.md` - Updated features, quick start, and API reference
- `TokenRenewalExamples.md` - NEW comprehensive examples document
- `ValidateJWT.Tests/TokenRenewalTests.cs` - NEW 20 unit tests

## ? Links

- **NuGet Package:** https://www.nuget.org/packages/ValidateJWT/1.6.0
- **GitHub Release:** https://github.com/johanhenningsson4-hash/ValidateJWT/releases/tag/v1.6.0
- **Documentation:** [TokenRenewalExamples.md](TokenRenewalExamples.md)
- **Changelog:** [CHANGELOG.md](CHANGELOG.md)
- **GitHub Repo:** https://github.com/johanhenningsson4-hash/ValidateJWT

## ? Technical Details

### API Signatures

```csharp
public static bool ShouldRenewToken(
	string jwt, 
	int renewBeforeMinutes, 
	DateTime? nowUtc = null)

public static TimeSpan? GetTimeUntilRenewal(
	string jwt, 
	int renewBeforeMinutes, 
	DateTime? nowUtc = null)
```

### Return Values

**`ShouldRenewToken`:**
- Returns `true` if token expires within `renewBeforeMinutes`
- Returns `false` if token is already expired
- Returns `false` if token is invalid or has no expiration

**`GetTimeUntilRenewal`:**
- Returns `TimeSpan` until renewal is needed
- Returns `null` if renewal should happen now
- Returns `null` if token is invalid or expired

## ? Support

- **Issues:** https://github.com/johanhenningsson4-hash/ValidateJWT/issues
- **Discussions:** https://github.com/johanhenningsson4-hash/ValidateJWT/discussions
- **Email:** support@example.com

## ? Contributors

- Johan Henningsson (@johanhenningsson4-hash)

---

**Thank you for using ValidateJWT!** ?

This release represents a significant enhancement to token lifecycle management, making it easier to build reliable, long-running applications with JWT authentication.
