# JWT Token Renewal Example

This document shows how to use the new token renewal functionality to get a new JWT before it expires.

## Quick Start

The ValidateJWT library now includes two new methods to help with proactive token renewal:

1. **`ShouldRenewToken`** - Check if a token should be renewed
2. **`GetTimeUntilRenewal`** - Get the time remaining until renewal is needed

## Basic Usage

### Check if Token Needs Renewal

```csharp
using Johan.Common;

// Check if token should be renewed 5 minutes before expiration
string token = GetCurrentToken();
bool needsRenewal = ValidateJWT.ShouldRenewToken(token, renewBeforeMinutes: 5);

if (needsRenewal)
{
	// Get a new token from your authentication service
	token = await GetNewTokenAsync();
	SaveToken(token);
}
```

### Get Time Until Renewal

```csharp
using Johan.Common;

string token = GetCurrentToken();
TimeSpan? timeUntilRenewal = ValidateJWT.GetTimeUntilRenewal(token, renewBeforeMinutes: 5);

if (timeUntilRenewal.HasValue)
{
	Console.WriteLine($"Token renewal needed in {timeUntilRenewal.Value.TotalMinutes:F1} minutes");
}
else
{
	Console.WriteLine("Token should be renewed now");
}
```

## Advanced Example: Proactive Token Renewal Service

```csharp
using System;
using System.Threading;
using System.Threading.Tasks;
using Johan.Common;

public class TokenManager
{
	private string _currentToken;
	private readonly int _renewBeforeMinutes;
	private Timer _renewalTimer;

	public TokenManager(int renewBeforeMinutes = 5)
	{
		_renewBeforeMinutes = renewBeforeMinutes;
	}

	public async Task<string> GetTokenAsync()
	{
		// If no token or needs renewal, get a new one
		if (string.IsNullOrEmpty(_currentToken) || 
			ValidateJWT.ShouldRenewToken(_currentToken, _renewBeforeMinutes))
		{
			await RenewTokenAsync();
		}

		return _currentToken;
	}

	public async Task InitializeAsync(string initialToken)
	{
		_currentToken = initialToken;
		ScheduleNextRenewal();
	}

	private async Task RenewTokenAsync()
	{
		try
		{
			// Call your authentication service to get a new token
			_currentToken = await GetNewTokenFromServiceAsync();

			Console.WriteLine("Token renewed successfully");

			// Schedule the next renewal
			ScheduleNextRenewal();
		}
		catch (Exception ex)
		{
			Console.WriteLine($"Failed to renew token: {ex.Message}");
		}
	}

	private void ScheduleNextRenewal()
	{
		// Dispose existing timer if any
		_renewalTimer?.Dispose();

		var timeUntilRenewal = ValidateJWT.GetTimeUntilRenewal(_currentToken, _renewBeforeMinutes);

		if (timeUntilRenewal.HasValue)
		{
			// Schedule renewal
			_renewalTimer = new Timer(
				async _ => await RenewTokenAsync(),
				null,
				timeUntilRenewal.Value,
				Timeout.InfiniteTimeSpan);

			Console.WriteLine($"Next token renewal scheduled in {timeUntilRenewal.Value.TotalMinutes:F1} minutes");
		}
		else
		{
			// Token needs renewal now or is invalid
			Task.Run(() => RenewTokenAsync());
		}
	}

	private async Task<string> GetNewTokenFromServiceAsync()
	{
		// Replace with your actual token acquisition logic
		// For example: call your OAuth2 refresh endpoint
		await Task.Delay(100); // Simulate API call
		return "new.jwt.token";
	}

	public void Dispose()
	{
		_renewalTimer?.Dispose();
	}
}
```

## Usage with HTTP Clients

```csharp
using System;
using System.Net.Http;
using System.Threading.Tasks;
using Johan.Common;

public class ApiClient
{
	private readonly HttpClient _httpClient;
	private string _token;

	public ApiClient()
	{
		_httpClient = new HttpClient();
	}

	public async Task<string> CallApiAsync(string endpoint)
	{
		// Ensure token is valid before making API call
		await EnsureValidTokenAsync();

		_httpClient.DefaultRequestHeaders.Authorization = 
			new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", _token);

		var response = await _httpClient.GetAsync(endpoint);
		return await response.Content.ReadAsStringAsync();
	}

	private async Task EnsureValidTokenAsync()
	{
		// Renew token if it expires within 5 minutes
		if (string.IsNullOrEmpty(_token) || 
			ValidateJWT.ShouldRenewToken(_token, 5))
		{
			_token = await AcquireNewTokenAsync();
		}
	}

	private async Task<string> AcquireNewTokenAsync()
	{
		// Your token acquisition logic here
		await Task.Delay(100);
		return "new.jwt.token";
	}
}
```

## Configuration Examples

### Different Renewal Windows

```csharp
// Renew 1 minute before expiration (aggressive)
bool needsRenewal = ValidateJWT.ShouldRenewToken(token, renewBeforeMinutes: 1);

// Renew 15 minutes before expiration (conservative)
bool needsRenewal = ValidateJWT.ShouldRenewToken(token, renewBeforeMinutes: 15);

// Renew 30 minutes before expiration (very conservative, good for long-running operations)
bool needsRenewal = ValidateJWT.ShouldRenewToken(token, renewBeforeMinutes: 30);
```

### Testing with Custom Time

```csharp
// For testing purposes, you can provide a custom "now" time
var customNow = new DateTime(2024, 1, 1, 12, 0, 0, DateTimeKind.Utc);

bool needsRenewal = ValidateJWT.ShouldRenewToken(
	token, 
	renewBeforeMinutes: 5, 
	nowUtc: customNow);
```

## Best Practices

1. **Choose an appropriate renewal window**: 5-15 minutes is typical
2. **Handle renewal failures**: Always have a fallback plan if renewal fails
3. **Don't renew too frequently**: Unnecessary renewals waste resources
4. **Use proactive renewal**: Don't wait until the token is expired
5. **Log renewal events**: Track when tokens are renewed for debugging

## Error Handling

```csharp
public async Task<string> GetValidTokenAsync(string currentToken)
{
	try
	{
		// Check if renewal is needed
		if (ValidateJWT.ShouldRenewToken(currentToken, 5))
		{
			// Try to get a new token
			var newToken = await RenewTokenAsync();
			return newToken;
		}

		return currentToken;
	}
	catch (Exception ex)
	{
		Console.WriteLine($"Token renewal failed: {ex.Message}");

		// If current token is still valid (not expired), use it
		if (!ValidateJWT.IsExpired(currentToken))
		{
			return currentToken;
		}

		// Token is expired and renewal failed - re-authenticate
		throw new InvalidOperationException("Token expired and renewal failed", ex);
	}
}
```

## See Also

- `ValidateJWT.IsExpired()` - Check if a token is expired
- `ValidateJWT.GetExpirationUtc()` - Get token expiration time
- `ValidateJWT.IsValidNow()` - Check if token is currently valid
