using System;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Text;

namespace ValidateJWT.Tests
{
    /// <summary>
    /// Helper class for generating test JWT tokens
    /// </summary>
    public static class JwtTestHelper
    {
        /// <summary>
        /// Creates a JWT token with the specified expiration time
        /// </summary>
        public static string CreateJwtWithExpiration(DateTime expirationUtc)
        {
            long exp = DateTimeToUnixTimestamp(expirationUtc);
            return CreateJwtWithClaims(exp);
        }

        /// <summary>
        /// Creates a JWT token that expires in the specified time span from now
        /// </summary>
        public static string CreateJwtExpiringIn(TimeSpan timeSpan)
        {
            return CreateJwtWithExpiration(DateTime.UtcNow.Add(timeSpan));
        }

        /// <summary>
        /// Creates a JWT token with custom claims
        /// </summary>
        public static string CreateJwtWithClaims(long? exp = null, long? nbf = null, long? iat = null)
        {
            var claims = new TestJwtClaims
            {
                exp = exp?.ToString(),
                nbf = nbf?.ToString(),
                iat = iat?.ToString()
            };

            string header = CreateBase64UrlEncodedHeader();
            string payload = CreateBase64UrlEncodedPayload(claims);
            string signature = "fake-signature";

            return $"{header}.{payload}.{signature}";
        }

        /// <summary>
        /// Creates a JWT token with custom JSON payload
        /// </summary>
        public static string CreateTestJwt(string jsonPayload)
        {
            string header = CreateBase64UrlEncodedHeader();
            string payload = Base64UrlEncode(jsonPayload);
            string signature = "fake-signature";

            return $"{header}.{payload}.{signature}";
        }

        /// <summary>
        /// Creates a JWT token without expiration claim
        /// </summary>
        public static string CreateJwtWithoutExpiration()
        {
            var claims = new { sub = "test", name = "Test User" };
            string header = CreateBase64UrlEncodedHeader();
            string payload = SerializeAndEncode(claims);
            string signature = "fake-signature";

            return $"{header}.{payload}.{signature}";
        }

        /// <summary>
        /// Creates a malformed JWT (missing parts)
        /// </summary>
        public static string CreateMalformedJwt(int parts)
        {
            switch (parts)
            {
                case 0:
                    return "";
                case 1:
                    return "onlyheader";
                case 2:
                    return "header.payload";
                default:
                    return "header.payload.signature";
            }
        }

        /// <summary>
        /// Creates a JWT with invalid Base64 encoding
        /// </summary>
        public static string CreateJwtWithInvalidBase64()
        {
            return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.InvalidBase64!@#$.signature";
        }

        /// <summary>
        /// Creates a JWT with invalid JSON in payload
        /// </summary>
        public static string CreateJwtWithInvalidJson()
        {
            string header = CreateBase64UrlEncodedHeader();
            string invalidJson = Base64UrlEncode("{not valid json");
            return $"{header}.{invalidJson}.signature";
        }

        private static string CreateBase64UrlEncodedHeader()
        {
            var header = new { alg = "HS256", typ = "JWT" };
            return SerializeAndEncode(header);
        }

        private static string CreateBase64UrlEncodedPayload(TestJwtClaims claims)
        {
            using (var ms = new MemoryStream())
            {
                var serializer = new DataContractJsonSerializer(typeof(TestJwtClaims));
                serializer.WriteObject(ms, claims);
                byte[] bytes = ms.ToArray();
                return Base64UrlEncode(bytes);
            }
        }

        private static string SerializeAndEncode(object obj)
        {
            string json = SimpleJsonSerialize(obj);
            return Base64UrlEncode(json);
        }

        private static string SimpleJsonSerialize(object obj)
        {
            var props = obj.GetType().GetProperties();
            var parts = new System.Collections.Generic.List<string>();
            
            foreach (var prop in props)
            {
                var value = prop.GetValue(obj);
                if (value != null)
                {
                    string valueStr = value is string ? $"\"{value}\"" : value.ToString();
                    parts.Add($"\"{prop.Name}\":{valueStr}");
                }
            }
            
            return "{" + string.Join(",", parts) + "}";
        }

        private static string Base64UrlEncode(string input)
        {
            byte[] bytes = Encoding.UTF8.GetBytes(input);
            return Base64UrlEncode(bytes);
        }

        private static string Base64UrlEncode(byte[] input)
        {
            string base64 = Convert.ToBase64String(input);
            return base64.Replace('+', '-').Replace('/', '_').TrimEnd('=');
        }

        private static long DateTimeToUnixTimestamp(DateTime dateTime)
        {
            var epoch = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
            return (long)(dateTime - epoch).TotalSeconds;
        }

        [DataContract]
        private class TestJwtClaims
        {
            [DataMember(Name = "exp")]
            public string exp { get; set; }

            [DataMember(Name = "nbf")]
            public string nbf { get; set; }

            [DataMember(Name = "iat")]
            public string iat { get; set; }
        }
    }
}
