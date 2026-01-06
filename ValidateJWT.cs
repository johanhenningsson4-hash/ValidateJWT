using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Text;

namespace Johan.Common
{
    [DataContract]
    internal class JwtTimeClaims
    {
        [DataMember(Name = "exp")]
        public string Exp { get; set; }
    }

    /// <summary>
    /// Provides lightweight validation of JWT token expiration times.
    /// This class does NOT verify JWT signatures - use only for time-based pre-validation.
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
            if (exp != null && now > exp.Value.Add(skew)) return false;

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
    }
}
