
using System;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Text;

namespace TPDotNet.MTR.Common
{
    [DataContract]
    internal class JwtTimeClaims
    {
        // Claims can be numbers or strings; store as string and parse.
        [DataMember(Name = "exp")]
        public string Exp { get; set; }

        //[DataMember(Name = "nbf")]
        //public string Nbf { get; set; }

        //[DataMember(Name = "iat")]
        //public string Iat { get; set; }
    }

    
    

    public static class ValidateJWT
    {
        private static TPDotnet.Base.Service.TPBaseLogging objLog;
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
                if (objLog == null)
                {
                    objLog = new TPDotnet.Base.Service.TPBaseLogging("ValidateJWT");
                }
                objLog.WriteLogError("ValidateJWT", "checkJWTExpired", ex);
                return true;
            }
        }

        public static bool IsValidNow(string jwt, TimeSpan? clockSkew = null, DateTime? nowUtc = null)
        {
            var now = nowUtc ?? DateTime.UtcNow;
            var skew = clockSkew ?? TimeSpan.FromMinutes(5);

            var claims = ParseClaims(jwt);
            if (claims == null) return false;

            //var nbf = ParseUnix(claims.Nbf);
            var exp = ParseUnix(claims.Exp);

            //if (nbf != null && now < nbf.Value.Subtract(skew)) return false;
            if (exp != null && now > exp.Value.Add(skew)) return false;

            return true;
        }

        public static DateTime? GetExpirationUtc(string jwt)
        {
            var claims = ParseClaims(jwt);
            if (claims == null) return null;
            return ParseUnix(claims.Exp);
        }

        //public static DateTime? GetIssuedAtUtc(string jwt)
        //{
        //    var claims = ParseClaims(jwt);
        //    if (claims == null) return null;
        //    return ParseUnix(claims.Iat);
        //}

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

        public static byte[] Base64UrlDecode(string input)
        {
            if (input == null) input = string.Empty;
            string s = input.Replace('-', '+').Replace('_', '/');

            switch (s.Length % 4)
            {
                case 2: s += "=="; break;
                case 3: s += "="; break;
                case 0: break;
                default: throw new FormatException("Invalid Base64Url length.");
            }

            return Convert.FromBase64String(s);
        }
    }
}
