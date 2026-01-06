using System;
using System.Diagnostics;
using System.IO;
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
    }
}
