using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Security.Cryptography;
using System.Text;

namespace Johan.Common
{
    [DataContract]
    internal class JwtTimeClaims
    {
        [DataMember(Name = "exp")]
        public string Exp { get; set; }
    }

    [DataContract]
    internal class JwtHeader
    {
        [DataMember(Name = "alg")]
        public string Alg { get; set; }
        
        [DataMember(Name = "typ")]
        public string Typ { get; set; }
    }

    /// <summary>
    /// Result of JWT signature verification
    /// </summary>
    public class JwtVerificationResult
    {
        /// <summary>
        /// Gets whether the signature is valid
        /// </summary>
        public bool IsValid { get; internal set; }

        /// <summary>
        /// Gets the algorithm used (e.g., "HS256", "RS256")
        /// </summary>
        public string Algorithm { get; internal set; }

        /// <summary>
        /// Gets any error message if verification failed
        /// </summary>
        public string ErrorMessage { get; internal set; }

        /// <summary>
        /// Gets whether the token is expired (time-based check)
        /// </summary>
        public bool IsExpired { get; internal set; }
    }

    /// <summary>
    /// Represents a JWT payload with standard and custom claims
    /// </summary>
    public class JwtPayload
    {
        /// <summary>
        /// Gets or sets the issuer (iss) claim
        /// </summary>
        public string Issuer { get; set; }

        /// <summary>
        /// Gets or sets the subject (sub) claim
        /// </summary>
        public string Subject { get; set; }

        /// <summary>
        /// Gets or sets the audience (aud) claim. Can be a single audience or array.
        /// </summary>
        public string[] Audiences { get; set; }

        /// <summary>
        /// Gets or sets the expiration time (exp) claim
        /// </summary>
        public DateTime? ExpiresAt { get; set; }

        /// <summary>
        /// Gets or sets the not before (nbf) claim
        /// </summary>
        public DateTime? NotBefore { get; set; }

        /// <summary>
        /// Gets or sets the issued at (iat) claim
        /// </summary>
        public DateTime? IssuedAt { get; set; }

        /// <summary>
        /// Gets or sets the JWT ID (jti) claim
        /// </summary>
        public string JwtId { get; set; }

        /// <summary>
        /// Gets or sets custom claims
        /// </summary>
        public Dictionary<string, object> CustomClaims { get; set; }

        /// <summary>
        /// Initializes a new instance of JwtPayload
        /// </summary>
        public JwtPayload()
        {
            CustomClaims = new Dictionary<string, object>();
        }
    }

    /// <summary>
    /// Provides lightweight validation of JWT token expiration times.
    /// Also includes optional signature verification functionality.
    /// </summary>
    public static class ValidateJWT
    {
        /// <summary>
        /// Checks if a JWT token has expired based on its expiration claim.
        /// </summary>
        /// <param name="jwt">The JWT token string to validate</param>
        /// <param name="clockSkew">Optional clock skew tolerance to account for time synchronization issues (default: 5 minutes)</param>
        /// <param name="nowUtc">Optional current UTC time for testing purposes (default: DateTime.UtcNow)</param>
        /// <returns>True if the token has expired; false if the token is still valid or if no expiration claim is found</returns>
        /// <remarks>
        /// Returns true on errors as a fail-safe approach. Does NOT verify JWT signatures.
        /// </remarks>
        public static bool IsExpired(string jwt, TimeSpan? clockSkew = null, DateTime? nowUtc = null)
        {
            try
            {
                var now = nowUtc ?? DateTime.UtcNow;
                var skew = clockSkew ?? TimeSpan.FromMinutes(5);

                var exp = GetExpirationUtc(jwt);
                if (exp == null) return false;
                return now > exp.Value.Add(skew);
            }
            catch (Exception ex)
            {
                Trace.WriteLine($"ValidateJWT.IsExpired error: {ex.Message}");
                return true;
            }
        }

        /// <summary>
        /// Checks if a JWT token is currently valid based on its expiration claim.
        /// </summary>
        /// <param name="jwt">The JWT token string to validate</param>
        /// <param name="clockSkew">Optional clock skew tolerance to account for time synchronization issues (default: 5 minutes)</param>
        /// <param name="nowUtc">Optional current UTC time for testing purposes (default: DateTime.UtcNow)</param>
        /// <returns>True if the token is currently valid; false if expired or invalid</returns>
        /// <remarks>
        /// Does NOT verify JWT signatures. Use only for time-based pre-validation.
        /// </remarks>
        public static bool IsValidNow(string jwt, TimeSpan? clockSkew = null, DateTime? nowUtc = null)
        {
            var now = nowUtc ?? DateTime.UtcNow;
            var skew = clockSkew ?? TimeSpan.FromMinutes(5);

            var claims = ParseClaims(jwt);
            if (claims == null) return false;

            var exp = ParseUnix(claims.Exp);
            if (exp == null) return false; // Fix: No expiration claim means not valid
            if (now > exp.Value.Add(skew)) return false;

            return true;
        }

        /// <summary>
        /// Extracts the expiration time from a JWT token.
        /// </summary>
        /// <param name="jwt">The JWT token string to parse</param>
        /// <returns>The expiration time in UTC, or null if the token is invalid or has no expiration claim</returns>
        public static DateTime? GetExpirationUtc(string jwt)
        {
            var claims = ParseClaims(jwt);
            if (claims == null) return null;
            return ParseUnix(claims.Exp);
        }

        /// <summary>
        /// Checks if a JWT token should be renewed based on the time remaining until expiration.
        /// </summary>
        /// <param name="jwt">The JWT token string to check</param>
        /// <param name="renewBeforeMinutes">Number of minutes before expiration when renewal should occur</param>
        /// <param name="nowUtc">Optional current UTC time for testing purposes (default: DateTime.UtcNow)</param>
        /// <returns>True if the token should be renewed (expires within the specified minutes); false otherwise</returns>
        /// <remarks>
        /// This method is useful for proactive token renewal before expiration.
        /// For example, if renewBeforeMinutes is 5, the method returns true when the token has 5 or fewer minutes remaining.
        /// Returns false if the token is already expired or if no expiration claim is found.
        /// </remarks>
        /// <example>
        /// <code>
        /// if (ValidateJWT.ShouldRenewToken(token, 5))
        /// {
        ///     // Token expires in 5 minutes or less, get a new one
        ///     token = await GetNewTokenAsync();
        /// }
        /// </code>
        /// </example>
        public static bool ShouldRenewToken(string jwt, int renewBeforeMinutes, DateTime? nowUtc = null)
        {
            try
            {
                var now = nowUtc ?? DateTime.UtcNow;
                var exp = GetExpirationUtc(jwt);

                if (exp == null) return false;
                if (exp.Value <= now) return false; // Already expired

                var timeRemaining = exp.Value - now;
                return timeRemaining.TotalMinutes <= renewBeforeMinutes;
            }
            catch (Exception ex)
            {
                Trace.WriteLine($"ValidateJWT.ShouldRenewToken error: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Gets the time remaining until a JWT token should be renewed.
        /// </summary>
        /// <param name="jwt">The JWT token string to check</param>
        /// <param name="renewBeforeMinutes">Number of minutes before expiration when renewal should occur</param>
        /// <param name="nowUtc">Optional current UTC time for testing purposes (default: DateTime.UtcNow)</param>
        /// <returns>TimeSpan until renewal is needed, or null if the token is invalid or should be renewed now</returns>
        /// <remarks>
        /// Returns null if:
        /// - The token has no expiration claim
        /// - The token is already expired
        /// - The token should be renewed now (within renewBeforeMinutes window)
        /// Use this method to schedule token renewal or display time until renewal.
        /// </remarks>
        /// <example>
        /// <code>
        /// var timeUntilRenewal = ValidateJWT.GetTimeUntilRenewal(token, 5);
        /// if (timeUntilRenewal.HasValue)
        /// {
        ///     Console.WriteLine($"Token renewal needed in {timeUntilRenewal.Value.TotalMinutes:F1} minutes");
        /// }
        /// else
        /// {
        ///     Console.WriteLine("Token should be renewed now");
        /// }
        /// </code>
        /// </example>
        public static TimeSpan? GetTimeUntilRenewal(string jwt, int renewBeforeMinutes, DateTime? nowUtc = null)
        {
            try
            {
                var now = nowUtc ?? DateTime.UtcNow;
                var exp = GetExpirationUtc(jwt);

                if (exp == null) return null;
                if (exp.Value <= now) return null; // Already expired

                var renewalTime = exp.Value.AddMinutes(-renewBeforeMinutes);

                if (now >= renewalTime) return null; // Should renew now

                return renewalTime - now;
            }
            catch (Exception ex)
            {
                Trace.WriteLine($"ValidateJWT.GetTimeUntilRenewal error: {ex.Message}");
                return null;
            }
        }

        /// <summary>
        /// Verifies the signature of a JWT token using HMAC-SHA256 (HS256) algorithm.
        /// </summary>
        /// <param name="jwt">The JWT token string to verify</param>
        /// <param name="secretKey">The secret key used to sign the token</param>
        /// <returns>A JwtVerificationResult containing validation status and details</returns>
        /// <remarks>
        /// This method verifies the signature using HMAC-SHA256. For other algorithms (RS256, ES256, etc.),
        /// use VerifySignatureRS256() or implement custom verification.
        /// </remarks>
        /// <example>
        /// <code>
        /// var result = ValidateJWT.VerifySignature(token, "your-secret-key");
        /// if (result.IsValid &amp;&amp; !result.IsExpired)
        /// {
        ///     // Token is valid and not expired
        /// }
        /// </code>
        /// </example>
        public static JwtVerificationResult VerifySignature(string jwt, string secretKey)
        {
            var result = new JwtVerificationResult();

            try
            {
                if (string.IsNullOrWhiteSpace(jwt))
                {
                    result.ErrorMessage = "JWT token is null or empty";
                    return result;
                }

                if (string.IsNullOrWhiteSpace(secretKey))
                {
                    result.ErrorMessage = "Secret key is null or empty";
                    return result;
                }

                var parts = jwt.Split('.');
                if (parts.Length != 3)
                {
                    result.ErrorMessage = "Invalid JWT format (expected 3 parts)";
                    return result;
                }

                // Parse header to get algorithm
                var header = ParseHeader(jwt);
                if (header == null)
                {
                    result.ErrorMessage = "Failed to parse JWT header";
                    return result;
                }

                result.Algorithm = header.Alg;

                // Verify algorithm is supported
                if (header.Alg != "HS256")
                {
                    result.ErrorMessage = $"Unsupported algorithm: {header.Alg}. Use VerifySignature for HS256 only.";
                    return result;
                }

                // Verify signature
                var headerPayload = parts[0] + "." + parts[1];
                var signature = parts[2];

                var keyBytes = Encoding.UTF8.GetBytes(secretKey);
                using (var hmac = new HMACSHA256(keyBytes))
                {
                    var signatureBytes = hmac.ComputeHash(Encoding.UTF8.GetBytes(headerPayload));
                    var expectedSignature = Base64UrlEncode(signatureBytes);

                    result.IsValid = (signature == expectedSignature);
                    
                    if (!result.IsValid)
                    {
                        result.ErrorMessage = "Signature verification failed";
                    }
                }

                // Also check expiration
                result.IsExpired = IsExpired(jwt);
            }
            catch (Exception ex)
            {
                result.ErrorMessage = $"Verification error: {ex.Message}";
                Trace.WriteLine($"ValidateJWT.VerifySignature error: {ex.Message}");
            }

            return result;
        }

        /// <summary>
        /// Verifies the signature of a JWT token using RSA-SHA256 (RS256) algorithm.
        /// </summary>
        /// <param name="jwt">The JWT token string to verify</param>
        /// <param name="publicKeyXml">The RSA public key in XML format</param>
        /// <returns>A JwtVerificationResult containing validation status and details</returns>
        /// <remarks>
        /// This method verifies the signature using RSA-SHA256 with a public key.
        /// The public key must be in XML format (RSAParameters).
        /// </remarks>
        /// <example>
        /// <code>
        /// var result = ValidateJWT.VerifySignatureRS256(token, publicKeyXml);
        /// if (result.IsValid)
        /// {
        ///     // Signature is valid
        /// }
        /// </code>
        /// </example>
        public static JwtVerificationResult VerifySignatureRS256(string jwt, string publicKeyXml)
        {
            var result = new JwtVerificationResult();

            try
            {
                if (string.IsNullOrWhiteSpace(jwt))
                {
                    result.ErrorMessage = "JWT token is null or empty";
                    return result;
                }

                if (string.IsNullOrWhiteSpace(publicKeyXml))
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

                if (header.Alg != "RS256")
                {
                    result.ErrorMessage = $"Unsupported algorithm: {header.Alg}. Use VerifySignatureRS256 for RS256 only.";
                    return result;
                }

                // Verify signature
                var headerPayload = parts[0] + "." + parts[1];
                var signatureBytes = Base64UrlDecode(parts[2]);

                using (var rsa = new RSACryptoServiceProvider())
                {
                    rsa.FromXmlString(publicKeyXml);
                    
                    var dataBytes = Encoding.UTF8.GetBytes(headerPayload);
                    result.IsValid = rsa.VerifyData(dataBytes, signatureBytes, HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);
                    
                    if (!result.IsValid)
                    {
                        result.ErrorMessage = "Signature verification failed";
                    }
                }

                // Check expiration
                result.IsExpired = IsExpired(jwt);
            }
            catch (Exception ex)
            {
                result.ErrorMessage = $"Verification error: {ex.Message}";
                Trace.WriteLine($"ValidateJWT.VerifySignatureRS256 error: {ex.Message}");
            }

            return result;
        }

        /// <summary>
        /// Gets the algorithm used in the JWT header.
        /// </summary>
        /// <param name="jwt">The JWT token string</param>
        /// <returns>The algorithm name (e.g., "HS256", "RS256") or null if parsing fails</returns>
        public static string GetAlgorithm(string jwt)
        {
            var header = ParseHeader(jwt);
            return header?.Alg;
        }

        /// <summary>
        /// Validates the 'iss' (issuer) claim in a JWT token.
        /// </summary>
        /// <param name="jwt">The JWT token string to validate</param>
        /// <param name="expectedIssuer">The expected issuer value</param>
        /// <returns>True if the issuer matches; false otherwise or if the claim is missing/invalid</returns>
        public static bool IsIssuerValid(string jwt, string expectedIssuer)
        {
            if (string.IsNullOrWhiteSpace(jwt) || string.IsNullOrWhiteSpace(expectedIssuer))
                return false;

            var parts = jwt.Split('.');
            if (parts.Length < 2) return false;

            try
            {
                var payloadBytes = Base64UrlDecode(parts[1]);
                var payloadJson = Encoding.UTF8.GetString(payloadBytes);
                // Simple string search for 'iss' claim (works for flat JWTs)
                var issKey = "\"iss\":";
                var idx = payloadJson.IndexOf(issKey, StringComparison.OrdinalIgnoreCase);
                if (idx == -1) return false;
                var afterKey = payloadJson.Substring(idx + issKey.Length).TrimStart();
                // Support both quoted and unquoted values
                if (afterKey.StartsWith("\""))
                {
                    var endIdx = afterKey.IndexOf('"', 1);
                    if (endIdx == -1) return false;
                    var value = afterKey.Substring(1, endIdx - 1);
                    return string.Equals(value, expectedIssuer, StringComparison.Ordinal);
                }
                else
                {
                    // Unquoted value (rare)
                    var endIdx = afterKey.IndexOfAny(new[] { ',', '}', ' ' });
                    var value = endIdx == -1 ? afterKey : afterKey.Substring(0, endIdx);
                    return string.Equals(value, expectedIssuer, StringComparison.Ordinal);
                }
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Validates the 'aud' (audience) claim in a JWT token.
        /// </summary>
        /// <param name="jwt">The JWT token string to validate</param>
        /// <param name="expectedAudience">The expected audience value</param>
        /// <returns>True if the audience matches; false otherwise or if the claim is missing/invalid</returns>
        public static bool IsAudienceValid(string jwt, string expectedAudience)
        {
            if (string.IsNullOrWhiteSpace(jwt) || string.IsNullOrWhiteSpace(expectedAudience))
                return false;

            var parts = jwt.Split('.');
            if (parts.Length < 2) return false;

            try
            {
                var payloadBytes = Base64UrlDecode(parts[1]);
                var payloadJson = Encoding.UTF8.GetString(payloadBytes);
                
                // Handle both single audience and array of audiences
                var audKey = "\"aud\":";
                var idx = payloadJson.IndexOf(audKey, StringComparison.OrdinalIgnoreCase);
                if (idx == -1) return false;
                
                var afterKey = payloadJson.Substring(idx + audKey.Length).TrimStart();
                
                // Check if it's an array
                if (afterKey.StartsWith("["))
                {
                    // Array format: "aud":["audience1","audience2"]
                    var endIdx = afterKey.IndexOf(']');
                    if (endIdx == -1) return false;
                    var arrayContent = afterKey.Substring(1, endIdx - 1);
                    return arrayContent.Contains("\"" + expectedAudience + "\"");
                }
                else if (afterKey.StartsWith("\""))
                {
                    // Single string format: "aud":"audience"
                    var endIdx = afterKey.IndexOf('"', 1);
                    if (endIdx == -1) return false;
                    var value = afterKey.Substring(1, endIdx - 1);
                    return string.Equals(value, expectedAudience, StringComparison.Ordinal);
                }
                
                return false;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Validates the 'nbf' (not before) claim in a JWT token.
        /// </summary>
        /// <param name="jwt">The JWT token string to validate</param>
        /// <param name="clockSkew">Clock skew tolerance (default: 5 minutes)</param>
        /// <param name="nowUtc">Current UTC time (default: DateTime.UtcNow)</param>
        /// <returns>True if the token is not being used before its 'nbf' time; false otherwise</returns>
        public static bool IsNotBeforeValid(string jwt, TimeSpan? clockSkew = null, DateTime? nowUtc = null)
        {
            var nbf = GetNotBeforeUtc(jwt);
            if (!nbf.HasValue) return true; // No nbf claim means always valid

            var currentTime = nowUtc ?? DateTime.UtcNow;
            var tolerance = clockSkew ?? TimeSpan.FromMinutes(5);
            
            // Token is valid if current time + tolerance >= nbf
            return currentTime.Add(tolerance) >= nbf.Value;
        }

        /// <summary>
        /// Extracts the 'nbf' (not before) claim from a JWT token.
        /// </summary>
        /// <param name="jwt">The JWT token string</param>
        /// <returns>The not before time in UTC, or null if not present or invalid</returns>
        public static DateTime? GetNotBeforeUtc(string jwt)
        {
            return GetUnixTimestampClaim(jwt, "nbf");
        }

        /// <summary>
        /// Extracts the 'iat' (issued at) claim from a JWT token.
        /// </summary>
        /// <param name="jwt">The JWT token string</param>
        /// <returns>The issued at time in UTC, or null if not present or invalid</returns>
        public static DateTime? GetIssuedAtUtc(string jwt)
        {
            return GetUnixTimestampClaim(jwt, "iat");
        }

        /// <summary>
        /// Extracts the 'aud' (audience) claim from a JWT token.
        /// </summary>
        /// <param name="jwt">The JWT token string</param>
        /// <returns>The audience value, or null if not present or invalid</returns>
        public static string GetAudience(string jwt)
        {
            if (string.IsNullOrWhiteSpace(jwt))
                return null;

            var parts = jwt.Split('.');
            if (parts.Length < 2) return null;

            try
            {
                var payloadBytes = Base64UrlDecode(parts[1]);
                var payloadJson = Encoding.UTF8.GetString(payloadBytes);
                
                var audKey = "\"aud\":";
                var idx = payloadJson.IndexOf(audKey, StringComparison.OrdinalIgnoreCase);
                if (idx == -1) return null;
                
                var afterKey = payloadJson.Substring(idx + audKey.Length).TrimStart();
                
                if (afterKey.StartsWith("\""))
                {
                    // Single string format
                    var endIdx = afterKey.IndexOf('"', 1);
                    if (endIdx == -1) return null;
                    return afterKey.Substring(1, endIdx - 1);
                }
                else if (afterKey.StartsWith("["))
                {
                    // Array format - return first audience
                    var arrayStart = afterKey.IndexOf("\"");
                    if (arrayStart == -1) return null;
                    var arrayEnd = afterKey.IndexOf("\"", arrayStart + 1);
                    if (arrayEnd == -1) return null;
                    return afterKey.Substring(arrayStart + 1, arrayEnd - arrayStart - 1);
                }
                
                return null;
            }
            catch
            {
                return null;
            }
        }

        /// <summary>
        /// Extracts a claim from a JWT token with strong typing.
        /// </summary>
        /// <typeparam name="T">The type to convert the claim value to</typeparam>
        /// <param name="jwt">The JWT token string</param>
        /// <param name="claimName">The name of the claim to extract</param>
        /// <returns>The claim value converted to type T, or default(T) if not found or conversion fails</returns>
        public static T GetClaim<T>(string jwt, string claimName)
        {
            if (string.IsNullOrWhiteSpace(jwt) || string.IsNullOrWhiteSpace(claimName))
                return default(T);

            var parts = jwt.Split('.');
            if (parts.Length < 2) return default(T);

            try
            {
                var payloadBytes = Base64UrlDecode(parts[1]);
                var payloadJson = Encoding.UTF8.GetString(payloadBytes);

                var claimKey = "\"" + claimName + "\":";
                var idx = payloadJson.IndexOf(claimKey, StringComparison.OrdinalIgnoreCase);
                if (idx == -1) return default(T);

                var afterKey = payloadJson.Substring(idx + claimKey.Length).TrimStart();

                // Handle different value types
                if (afterKey.StartsWith("\""))
                {
                    // String value - need to properly handle escaped quotes
                    var endIdx = FindStringEndIndex(afterKey);
                    if (endIdx == -1) return default(T);
                    var stringValue = afterKey.Substring(1, endIdx - 1);
                    return ConvertClaimValue<T>(stringValue, true);
                }
                else if (afterKey.StartsWith("["))
                {
                    // Array value
                    var endIdx = afterKey.IndexOf(']');
                    if (endIdx == -1) return default(T);
                    var arrayValue = afterKey.Substring(0, endIdx + 1);
                    return ConvertClaimValue<T>(arrayValue, false);
                }
                else
                {
                    // Numeric, boolean, or null value
                    var endIdx = afterKey.IndexOfAny(new[] { ',', '}', '\r', '\n' });
                    var rawValue = endIdx == -1 ? afterKey.Trim() : afterKey.Substring(0, endIdx).Trim();
                    return ConvertClaimValue<T>(rawValue, false);
                }
            }
            catch
            {
                return default(T);
            }
        }

        /// <summary>
        /// Checks if a JWT token contains a specific claim.
        /// </summary>
        /// <param name="jwt">The JWT token string</param>
        /// <param name="claimName">The name of the claim to check</param>
        /// <returns>True if the claim exists, false otherwise</returns>
        public static bool HasClaim(string jwt, string claimName)
        {
            if (string.IsNullOrWhiteSpace(jwt) || string.IsNullOrWhiteSpace(claimName))
                return false;

            var parts = jwt.Split('.');
            if (parts.Length < 2) return false;

            try
            {
                var payloadBytes = Base64UrlDecode(parts[1]);
                var payloadJson = Encoding.UTF8.GetString(payloadBytes);

                var claimKey = "\"" + claimName + "\":";
                return payloadJson.IndexOf(claimKey, StringComparison.OrdinalIgnoreCase) != -1;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Converts a claim value to the specified type.
        /// </summary>
        private static T ConvertClaimValue<T>(string value, bool isStringValue)
        {
            if (string.IsNullOrEmpty(value) || value == "null")
                return default(T);

            var targetType = typeof(T);
            var nullableType = Nullable.GetUnderlyingType(targetType);
            var actualType = nullableType ?? targetType;

            try
            {
                // Handle string types
                if (actualType == typeof(string))
                {
                    // If it's a string value from JSON, we need to unescape it
                    if (isStringValue)
                    {
                        return (T)(object)UnescapeJsonString(value);
                    }
                    return (T)(object)value;
                }

                // Handle DateTime (Unix timestamps)
                if (actualType == typeof(DateTime))
                {
                    if (isStringValue)
                    {
                        // Try parsing as ISO 8601 string first
                        if (DateTime.TryParse(value, out var dateTime))
                        {
                            return (T)(object)dateTime.ToUniversalTime();
                        }
                    }
                    else
                    {
                        // Try parsing as Unix timestamp
                        if (long.TryParse(value, out var unixTime))
                        {
                            var epoch = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
                            return (T)(object)epoch.AddSeconds(unixTime);
                        }
                    }
                    return default(T);
                }

                // For non-string values, remove quotes if present
                if (isStringValue && !actualType.Equals(typeof(string)))
                {
                    // The value is quoted but we need a non-string type
                    // This might be a number or boolean stored as a string
                }

                // Handle numeric types
                if (actualType == typeof(int))
                {
                    return int.TryParse(value, out var intValue) ? (T)(object)intValue : default(T);
                }
                if (actualType == typeof(long))
                {
                    return long.TryParse(value, out var longValue) ? (T)(object)longValue : default(T);
                }
                if (actualType == typeof(double))
                {
                    return double.TryParse(value, out var doubleValue) ? (T)(object)doubleValue : default(T);
                }
                if (actualType == typeof(decimal))
                {
                    return decimal.TryParse(value, out var decimalValue) ? (T)(object)decimalValue : default(T);
                }

                // Handle boolean
                if (actualType == typeof(bool))
                {
                    if (value.Equals("true", StringComparison.OrdinalIgnoreCase))
                        return (T)(object)true;
                    if (value.Equals("false", StringComparison.OrdinalIgnoreCase))
                        return (T)(object)false;
                    return default(T);
                }

                // Handle arrays (simple string array support)
                if (actualType == typeof(string[]) && !isStringValue)
                {
                    if (value.StartsWith("[") && value.EndsWith("]"))
                    {
                        var arrayContent = value.Substring(1, value.Length - 2).Trim();
                        if (string.IsNullOrEmpty(arrayContent))
                            return (T)(object)new string[0];

                        // Simple array parsing (assumes string elements)
                        var elements = new List<string>();
                        var inQuotes = false;
                        var current = new StringBuilder();

                        for (int i = 0; i < arrayContent.Length; i++)
                        {
                            var c = arrayContent[i];
                            if (c == '"' && (i == 0 || arrayContent[i - 1] != '\\'))
                            {
                                inQuotes = !inQuotes;
                            }
                            else if (c == ',' && !inQuotes)
                            {
                                var element = current.ToString().Trim().Trim('"');
                                elements.Add(UnescapeJsonString(element));
                                current.Clear();
                            }
                            else if (!char.IsWhiteSpace(c) || inQuotes)
                            {
                                current.Append(c);
                            }
                        }

                        if (current.Length > 0)
                        {
                            var element = current.ToString().Trim().Trim('"');
                            elements.Add(UnescapeJsonString(element));
                        }

                        return (T)(object)elements.ToArray();
                    }
                }

                // Fallback: try direct conversion
                return (T)Convert.ChangeType(value, actualType);
            }
            catch
            {
                return default(T);
            }
        }

        /// <summary>
        /// Helper method to extract Unix timestamp claims from JWT payload.
        /// </summary>
        /// <param name="jwt">The JWT token string</param>
        /// <param name="claimName">The claim name (e.g., "exp", "nbf", "iat")</param>
        /// <returns>The timestamp as DateTime in UTC, or null if not present or invalid</returns>
        private static DateTime? GetUnixTimestampClaim(string jwt, string claimName)
        {
            if (string.IsNullOrWhiteSpace(jwt) || string.IsNullOrWhiteSpace(claimName))
                return null;

            var parts = jwt.Split('.');
            if (parts.Length < 2) return null;

            try
            {
                var payloadBytes = Base64UrlDecode(parts[1]);
                var payloadJson = Encoding.UTF8.GetString(payloadBytes);
                
                var claimKey = "\"" + claimName + "\":";
                var idx = payloadJson.IndexOf(claimKey, StringComparison.OrdinalIgnoreCase);
                if (idx == -1) return null;

                var afterKey = payloadJson.Substring(idx + claimKey.Length).TrimStart();
                var endIdx = afterKey.IndexOfAny(new[] { ',', '}', ' ', '\r', '\n' });
                var timestampStr = endIdx == -1 ? afterKey : afterKey.Substring(0, endIdx);

                if (long.TryParse(timestampStr, out var timestamp))
                {
                    var epoch = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
                    return epoch.AddSeconds(timestamp);
                }

                return null;
            }
            catch
            {
                return null;
            }
        }

        private static JwtHeader ParseHeader(string jwt)
        {
            if (string.IsNullOrWhiteSpace(jwt)) return null;

            var parts = jwt.Split('.');
            if (parts.Length < 1) return null;

            try
            {
                var headerBytes = Base64UrlDecode(parts[0]);
                using (var ms = new MemoryStream(headerBytes))
                {
                    var ser = new DataContractJsonSerializer(typeof(JwtHeader));
                    return ser.ReadObject(ms) as JwtHeader;
                }
            }
            catch
            {
                return null;
            }
        }

        private static JwtTimeClaims ParseClaims(string jwt)
        {
            if (string.IsNullOrWhiteSpace(jwt)) return null;

            var parts = jwt.Split('.');
            if (parts.Length < 2) return null;

            try
            {
                var payloadBytes = Base64UrlDecode(parts[1]);
                using (var ms = new MemoryStream(payloadBytes))
                {
                    var ser = new DataContractJsonSerializer(typeof(JwtTimeClaims));
                    var obj = ser.ReadObject(ms) as JwtTimeClaims;
                    return obj;
                }
            }
            catch
            {
                return null;
            }
        }

        private static DateTime? ParseUnix(string value)
        {
            if (string.IsNullOrEmpty(value)) return null;

            long seconds;
            if (!long.TryParse(value, out seconds)) return null;

            try
            {
                var epoch = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
                return epoch.AddSeconds(seconds);
            }
            catch
            {
                return null;
            }
        }

        /// <summary>
        /// Decodes a Base64Url encoded string to a byte array.
        /// </summary>
        /// <param name="input">Base64Url encoded string</param>
        /// <returns>Decoded byte array</returns>
        public static byte[] Base64UrlDecode(string input)
        {
            if (string.IsNullOrEmpty(input))
            {
                return Array.Empty<byte>();
            }

            string base64 = input.Replace('-', '+').Replace('_', '/');
            int padding = base64.Length % 4;
            if (padding == 2)
            {
                base64 += "==";
            }
            else if (padding == 3)
            {
                base64 += "=";
            }
            else if (padding == 1)
            {
                throw new FormatException("Invalid Base64Url string length.");
            }

            return Convert.FromBase64String(base64);
        }

        /// <summary>
        /// Encodes a byte array to a Base64Url encoded string.
        /// </summary>
        /// <param name="input">Byte array to encode</param>
        /// <returns>Base64Url encoded string</returns>
        public static string Base64UrlEncode(byte[] input)
        {
            if (input == null || input.Length == 0)
            {
                return string.Empty;
            }

            var base64 = Convert.ToBase64String(input);
            return base64.Replace('+', '-').Replace('/', '_').TrimEnd('=');
        }

        /// <summary>
        /// Creates a JWT token with the specified payload and signs it using HMAC-SHA256.
        /// </summary>
        /// <param name="payload">The JWT payload containing claims</param>
        /// <param name="secretKey">The secret key for HMAC signing</param>
        /// <returns>A signed JWT token string</returns>
        public static string CreateJwt(JwtPayload payload, string secretKey)
        {
            return CreateJwt(payload, secretKey, "HS256");
        }

        /// <summary>
        /// Creates a JWT token with the specified payload and signs it using the specified algorithm.
        /// </summary>
        /// <param name="payload">The JWT payload containing claims</param>
        /// <param name="secretKey">The secret key for HMAC signing (HS256 only)</param>
        /// <param name="algorithm">The signing algorithm ("HS256" only for this overload)</param>
        /// <returns>A signed JWT token string</returns>
        public static string CreateJwt(JwtPayload payload, string secretKey, string algorithm)
        {
            if (payload == null)
                throw new ArgumentNullException(nameof(payload));
            if (string.IsNullOrWhiteSpace(secretKey))
                throw new ArgumentNullException(nameof(secretKey));
            if (algorithm != "HS256")
                throw new ArgumentException("This overload only supports HS256. Use CreateJwtRS256 for RS256.", nameof(algorithm));

            // Create header
            var header = new { alg = algorithm, typ = "JWT" };
            var headerJson = SerializeToJson(header);
            var headerEncoded = Base64UrlEncode(Encoding.UTF8.GetBytes(headerJson));

            // Create payload JSON
            var payloadJson = SerializePayloadToJson(payload);
            var payloadEncoded = Base64UrlEncode(Encoding.UTF8.GetBytes(payloadJson));

            // Create signature
            var headerPayload = headerEncoded + "." + payloadEncoded;
            var signature = CreateHmacSignature(headerPayload, secretKey);

            return headerEncoded + "." + payloadEncoded + "." + signature;
        }

        /// <summary>
        /// Creates a JWT token with the specified payload and signs it using RSA-SHA256.
        /// </summary>
        /// <param name="payload">The JWT payload containing claims</param>
        /// <param name="privateKeyXml">The RSA private key in XML format</param>
        /// <returns>A signed JWT token string</returns>
        public static string CreateJwtRS256(JwtPayload payload, string privateKeyXml)
        {
            if (payload == null)
                throw new ArgumentNullException(nameof(payload));
            if (string.IsNullOrWhiteSpace(privateKeyXml))
                throw new ArgumentNullException(nameof(privateKeyXml));

            // Create header
            var header = new { alg = "RS256", typ = "JWT" };
            var headerJson = SerializeToJson(header);
            var headerEncoded = Base64UrlEncode(Encoding.UTF8.GetBytes(headerJson));

            // Create payload JSON
            var payloadJson = SerializePayloadToJson(payload);
            var payloadEncoded = Base64UrlEncode(Encoding.UTF8.GetBytes(payloadJson));

            // Create signature
            var headerPayload = headerEncoded + "." + payloadEncoded;
            var signature = CreateRsaSignature(headerPayload, privateKeyXml);

            return headerEncoded + "." + payloadEncoded + "." + signature;
        }

        /// <summary>
        /// Creates a simple JWT with basic claims.
        /// </summary>
        /// <param name="subject">The subject (sub) claim</param>
        /// <param name="issuer">The issuer (iss) claim</param>
        /// <param name="audience">The audience (aud) claim</param>
        /// <param name="expiresInMinutes">Token expiration in minutes from now</param>
        /// <param name="secretKey">The secret key for HMAC signing</param>
        /// <returns>A signed JWT token string</returns>
        public static string CreateSimpleJwt(string subject, string issuer, string audience, int expiresInMinutes, string secretKey)
        {
            var payload = new JwtPayload
            {
                Subject = subject,
                Issuer = issuer,
                Audiences = new[] { audience },
                IssuedAt = DateTime.UtcNow,
                ExpiresAt = DateTime.UtcNow.AddMinutes(expiresInMinutes)
            };

            return CreateJwt(payload, secretKey);
        }

        /// <summary>
        /// Serializes a payload object to JSON.
        /// </summary>
        private static string SerializePayloadToJson(JwtPayload payload)
        {
            var claims = new Dictionary<string, object>();

            // Add standard claims
            if (!string.IsNullOrEmpty(payload.Issuer))
                claims["iss"] = payload.Issuer;

            if (!string.IsNullOrEmpty(payload.Subject))
                claims["sub"] = payload.Subject;

            if (payload.Audiences != null && payload.Audiences.Length > 0)
            {
                if (payload.Audiences.Length == 1)
                    claims["aud"] = payload.Audiences[0];
                else
                    claims["aud"] = payload.Audiences;
            }

            if (payload.ExpiresAt.HasValue)
                claims["exp"] = DateTimeToUnixTimestamp(payload.ExpiresAt.Value);

            if (payload.NotBefore.HasValue)
                claims["nbf"] = DateTimeToUnixTimestamp(payload.NotBefore.Value);

            if (payload.IssuedAt.HasValue)
                claims["iat"] = DateTimeToUnixTimestamp(payload.IssuedAt.Value);

            if (!string.IsNullOrEmpty(payload.JwtId))
                claims["jti"] = payload.JwtId;

            // Add custom claims
            if (payload.CustomClaims != null)
            {
                foreach (var claim in payload.CustomClaims)
                {
                    claims[claim.Key] = claim.Value;
                }
            }

            return SerializeToJson(claims);
        }

        /// <summary>
        /// Serializes an object to JSON (simple implementation).
        /// </summary>
        private static string SerializeToJson(object obj)
        {
            if (obj == null)
                return "{}";

            var dict = obj as Dictionary<string, object>;
            if (dict != null)
            {
                var parts = new List<string>();
                foreach (var kvp in dict)
                {
                    var value = SerializeJsonValue(kvp.Value);
                    parts.Add($"\"{kvp.Key}\":{value}");
                }
                return "{" + string.Join(",", parts) + "}";
            }

            // Handle anonymous objects using reflection
            var type = obj.GetType();
            var properties = type.GetProperties();
            var jsonParts = new List<string>();

            foreach (var prop in properties)
            {
                var value = prop.GetValue(obj);
                var jsonValue = SerializeJsonValue(value);
                jsonParts.Add($"\"{prop.Name}\":{jsonValue}");
            }

            return "{" + string.Join(",", jsonParts) + "}";
        }

        /// <summary>
        /// Serializes a value to JSON format.
        /// </summary>
        private static string SerializeJsonValue(object value)
        {
            if (value == null)
                return "null";

            if (value is string str)
                return $"\"{EscapeJsonString(str)}\"";

            if (value is bool b)
                return b ? "true" : "false";

            if (value is int || value is long || value is double || value is decimal)
                return value.ToString();

            if (value is string[] strArray)
            {
                var arrayItems = strArray.Select(s => $"\"{EscapeJsonString(s)}\"");
                return "[" + string.Join(",", arrayItems) + "]";
            }

            if (value is Array array)
            {
                var arrayItems = new List<string>();
                foreach (var item in array)
                {
                    arrayItems.Add(SerializeJsonValue(item));
                }
                return "[" + string.Join(",", arrayItems) + "]";
            }

            // Fallback to ToString
            return $"\"{EscapeJsonString(value.ToString())}\"";
        }

        /// <summary>
        /// Escapes a string for JSON.
        /// </summary>
        private static string EscapeJsonString(string input)
        {
            if (string.IsNullOrEmpty(input))
                return string.Empty;

            return input
                .Replace("\\", "\\\\")
                .Replace("\"", "\\\"")
                .Replace("\r", "\\r")
                .Replace("\n", "\\n")
                .Replace("\t", "\\t");
        }

        /// <summary>
        /// Finds the end index of a JSON string, properly handling escaped quotes.
        /// </summary>
        /// <param name="jsonString">JSON string starting with a quote</param>
        /// <returns>Index of the closing quote, or -1 if not found</returns>
        private static int FindStringEndIndex(string jsonString)
        {
            if (string.IsNullOrEmpty(jsonString) || !jsonString.StartsWith("\""))
                return -1;

            for (int i = 1; i < jsonString.Length; i++)
            {
                var c = jsonString[i];
                if (c == '"')
                {
                    // Check if this quote is escaped
                    int backslashCount = 0;
                    for (int j = i - 1; j >= 0 && jsonString[j] == '\\'; j--)
                    {
                        backslashCount++;
                    }

                    // If even number of backslashes (including 0), the quote is not escaped
                    if (backslashCount % 2 == 0)
                    {
                        return i;
                    }
                }
            }

            return -1; // Closing quote not found
        }

        /// <summary>
        /// Unescapes a JSON string.
        /// </summary>
        private static string UnescapeJsonString(string input)
        {
            if (string.IsNullOrEmpty(input))
                return string.Empty;

            // Order matters: unescape specific sequences first, then backslashes
            return input
                .Replace("\\\"", "\"")
                .Replace("\\r", "\r")
                .Replace("\\n", "\n")
                .Replace("\\t", "\t")
                .Replace("\\\\", "\\");
        }

        /// <summary>
        /// Converts DateTime to Unix timestamp.
        /// </summary>
        private static long DateTimeToUnixTimestamp(DateTime dateTime)
        {
            var epoch = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
            var utcDateTime = dateTime.Kind == DateTimeKind.Utc ? dateTime : dateTime.ToUniversalTime();
            return (long)(utcDateTime - epoch).TotalSeconds;
        }

        /// <summary>
        /// Creates an HMAC-SHA256 signature.
        /// </summary>
        private static string CreateHmacSignature(string input, string secretKey)
        {
            var keyBytes = Encoding.UTF8.GetBytes(secretKey);
            using (var hmac = new HMACSHA256(keyBytes))
            {
                var signatureBytes = hmac.ComputeHash(Encoding.UTF8.GetBytes(input));
                return Base64UrlEncode(signatureBytes);
            }
        }

        /// <summary>
        /// Creates an RSA-SHA256 signature.
        /// </summary>
        private static string CreateRsaSignature(string input, string privateKeyXml)
        {
            using (var rsa = new RSACryptoServiceProvider())
            {
                rsa.FromXmlString(privateKeyXml);
                var inputBytes = Encoding.UTF8.GetBytes(input);
                var signatureBytes = rsa.SignData(inputBytes, HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);
                return Base64UrlEncode(signatureBytes);
            }
        }
    }
}
