using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Johan.Common;
using static Johan.Common.ValidateJWT;

namespace ValidateJWT.Tests
{
    [TestClass]
    public class GetClaimTests
    {
        [TestMethod]
        public void GetClaim_StringClaim_ReturnsCorrectValue()
        {
            string payload = "{\"sub\":\"user123\",\"name\":\"John Doe\",\"exp\":9999999999}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            string subject = GetClaim<string>(jwt, "sub");
            string name = GetClaim<string>(jwt, "name");
            
            Assert.AreEqual("user123", subject);
            Assert.AreEqual("John Doe", name);
        }

        [TestMethod]
        public void GetClaim_NumericClaim_ReturnsCorrectValue()
        {
            var testTime = DateTimeOffset.UtcNow.AddHours(1).ToUnixTimeSeconds();
            string payload = $"{{\"exp\":{testTime},\"age\":25,\"score\":95.5,\"active\":true}}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            long exp = GetClaim<long>(jwt, "exp");
            int age = GetClaim<int>(jwt, "age");
            double score = GetClaim<double>(jwt, "score");
            bool active = GetClaim<bool>(jwt, "active");
            
            Assert.AreEqual(testTime, exp);
            Assert.AreEqual(25, age);
            Assert.AreEqual(95.5, score);
            Assert.IsTrue(active);
        }

        [TestMethod]
        public void GetClaim_DateTimeClaim_ReturnsCorrectValue()
        {
            var testTime = DateTimeOffset.UtcNow.AddHours(1).ToUnixTimeSeconds();
            string payload = $"{{\"exp\":{testTime},\"iat\":{testTime - 3600}}}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            DateTime? expTime = GetClaim<DateTime?>(jwt, "exp");
            DateTime? iatTime = GetClaim<DateTime?>(jwt, "iat");
            
            Assert.IsNotNull(expTime);
            Assert.IsNotNull(iatTime);
            Assert.IsTrue(expTime > iatTime);
        }

        [TestMethod]
        public void GetClaim_ArrayClaim_ReturnsCorrectValue()
        {
            string payload = "{\"roles\":[\"admin\",\"user\"],\"exp\":9999999999}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            string[] roles = GetClaim<string[]>(jwt, "roles");
            
            Assert.IsNotNull(roles);
            Assert.AreEqual(2, roles.Length);
            Assert.AreEqual("admin", roles[0]);
            Assert.AreEqual("user", roles[1]);
        }

        [TestMethod]
        public void GetClaim_NonExistentClaim_ReturnsDefault()
        {
            string payload = "{\"sub\":\"user123\",\"exp\":9999999999}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            string missing = GetClaim<string>(jwt, "missing");
            int missingInt = GetClaim<int>(jwt, "missing");
            DateTime? missingDate = GetClaim<DateTime?>(jwt, "missing");
            
            Assert.IsNull(missing);
            Assert.AreEqual(0, missingInt);
            Assert.IsNull(missingDate);
        }

        [TestMethod]
        public void GetClaim_NullableTypes_WorkCorrectly()
        {
            string payload = "{\"age\":30,\"score\":null,\"exp\":9999999999}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            int? age = GetClaim<int?>(jwt, "age");
            int? score = GetClaim<int?>(jwt, "score");
            int? missing = GetClaim<int?>(jwt, "missing");
            
            Assert.IsNotNull(age);
            Assert.AreEqual(30, age.Value);
            Assert.IsNull(score);
            Assert.IsNull(missing);
        }

        [TestMethod]
        public void GetClaim_BooleanClaims_WorkCorrectly()
        {
            string payload = "{\"active\":true,\"premium\":false,\"exp\":9999999999}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            bool active = GetClaim<bool>(jwt, "active");
            bool premium = GetClaim<bool>(jwt, "premium");
            bool? nullable = GetClaim<bool?>(jwt, "missing");
            
            Assert.IsTrue(active);
            Assert.IsFalse(premium);
            Assert.IsNull(nullable);
        }

        [TestMethod]
        public void GetClaim_EmptyArray_ReturnsEmptyArray()
        {
            string payload = "{\"roles\":[],\"exp\":9999999999}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            string[] roles = GetClaim<string[]>(jwt, "roles");
            
            Assert.IsNotNull(roles);
            Assert.AreEqual(0, roles.Length);
        }

        [TestMethod]
        public void GetClaim_InvalidJwt_ReturnsDefault()
        {
            string invalidJwt = "invalid.jwt.token";
            
            string claim = GetClaim<string>(invalidJwt, "sub");
            int intClaim = GetClaim<int>(invalidJwt, "age");
            
            Assert.IsNull(claim);
            Assert.AreEqual(0, intClaim);
        }

        [TestMethod]
        public void GetClaim_NullInputs_ReturnsDefault()
        {
            string result1 = GetClaim<string>(null, "sub");
            string result2 = GetClaim<string>("valid.jwt.token", null);
            string result3 = GetClaim<string>("", "sub");
            string result4 = GetClaim<string>("valid.jwt.token", "");
            
            Assert.IsNull(result1);
            Assert.IsNull(result2);
            Assert.IsNull(result3);
            Assert.IsNull(result4);
        }

        [TestMethod]
        public void HasClaim_ExistingClaim_ReturnsTrue()
        {
            string payload = "{\"sub\":\"user123\",\"name\":\"John Doe\",\"exp\":9999999999}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            bool hasSub = HasClaim(jwt, "sub");
            bool hasName = HasClaim(jwt, "name");
            bool hasExp = HasClaim(jwt, "exp");
            
            Assert.IsTrue(hasSub);
            Assert.IsTrue(hasName);
            Assert.IsTrue(hasExp);
        }

        [TestMethod]
        public void HasClaim_NonExistentClaim_ReturnsFalse()
        {
            string payload = "{\"sub\":\"user123\",\"exp\":9999999999}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            bool hasMissing = HasClaim(jwt, "missing");
            bool hasAud = HasClaim(jwt, "aud");
            
            Assert.IsFalse(hasMissing);
            Assert.IsFalse(hasAud);
        }

        [TestMethod]
        public void HasClaim_InvalidInputs_ReturnsFalse()
        {
            bool result1 = HasClaim(null, "sub");
            bool result2 = HasClaim("invalid.jwt", "sub");
            bool result3 = HasClaim("valid.jwt.token", null);
            bool result4 = HasClaim("valid.jwt.token", "");
            
            Assert.IsFalse(result1);
            Assert.IsFalse(result2);
            Assert.IsFalse(result3);
            Assert.IsFalse(result4);
        }

        [TestMethod]
        public void GetClaim_ComplexScenario_WorksCorrectly()
        {
            // Test a more complex JWT payload
            var unixTime = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
            string payload = $"{{" +
                $"\"iss\":\"https://example.com\"," +
                $"\"sub\":\"user123\"," +
                $"\"aud\":[\"api1\",\"api2\"]," +
                $"\"exp\":{unixTime + 3600}," +
                $"\"iat\":{unixTime}," +
                $"\"nbf\":{unixTime - 60}," +
                $"\"jti\":\"token-id-456\"," +
                $"\"roles\":[\"admin\",\"editor\"]," +
                $"\"age\":30," +
                $"\"premium\":true," +
                $"\"score\":95.7" +
                $"}}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            // Extract various claim types
            string issuer = GetClaim<string>(jwt, "iss");
            string subject = GetClaim<string>(jwt, "sub");
            string[] audience = GetClaim<string[]>(jwt, "aud");
            DateTime? expiration = GetClaim<DateTime?>(jwt, "exp");
            string jti = GetClaim<string>(jwt, "jti");
            string[] roles = GetClaim<string[]>(jwt, "roles");
            int age = GetClaim<int>(jwt, "age");
            bool premium = GetClaim<bool>(jwt, "premium");
            double score = GetClaim<double>(jwt, "score");
            
            // Verify all claims
            Assert.AreEqual("https://example.com", issuer);
            Assert.AreEqual("user123", subject);
            Assert.IsNotNull(audience);
            Assert.AreEqual(2, audience.Length);
            Assert.AreEqual("api1", audience[0]);
            Assert.AreEqual("api2", audience[1]);
            Assert.IsNotNull(expiration);
            Assert.AreEqual("token-id-456", jti);
            Assert.IsNotNull(roles);
            Assert.AreEqual(2, roles.Length);
            Assert.AreEqual("admin", roles[0]);
            Assert.AreEqual("editor", roles[1]);
            Assert.AreEqual(30, age);
            Assert.IsTrue(premium);
            Assert.AreEqual(95.7, score, 0.001);
        }
    }
}