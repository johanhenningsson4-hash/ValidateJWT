using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Johan.Common;
using static Johan.Common.ValidateJWT;

namespace ValidateJWT.Tests
{
    [TestClass]
    public class ClaimValidationTests
    {
        [TestMethod]
        public void IsAudienceValid_ValidSingleAudience_ReturnsTrue()
        {
            string payload = "{\"aud\":\"my-api\",\"exp\":9999999999}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            bool result = IsAudienceValid(jwt, "my-api");
            
            Assert.IsTrue(result);
        }

        [TestMethod]
        public void IsAudienceValid_ValidAudienceArray_ReturnsTrue()
        {
            string payload = "{\"aud\":[\"my-api\",\"other-api\"],\"exp\":9999999999}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            bool result = IsAudienceValid(jwt, "my-api");
            
            Assert.IsTrue(result);
        }

        [TestMethod]
        public void IsAudienceValid_InvalidAudience_ReturnsFalse()
        {
            string payload = "{\"aud\":\"wrong-api\",\"exp\":9999999999}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            bool result = IsAudienceValid(jwt, "my-api");
            
            Assert.IsFalse(result);
        }

        [TestMethod]
        public void IsNotBeforeValid_ValidNotBefore_ReturnsTrue()
        {
            var pastTime = DateTimeOffset.UtcNow.AddMinutes(-10).ToUnixTimeSeconds();
            string payload = $"{{\"nbf\":{pastTime},\"exp\":9999999999}}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            bool result = IsNotBeforeValid(jwt);
            
            Assert.IsTrue(result);
        }

        [TestMethod]
        public void IsNotBeforeValid_FutureNotBefore_ReturnsFalse()
        {
            var futureTime = DateTimeOffset.UtcNow.AddMinutes(10).ToUnixTimeSeconds();
            string payload = $"{{\"nbf\":{futureTime},\"exp\":9999999999}}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            bool result = IsNotBeforeValid(jwt, TimeSpan.FromMinutes(2));
            
            Assert.IsFalse(result);
        }

        [TestMethod]
        public void IsNotBeforeValid_NoNotBeforeClaim_ReturnsTrue()
        {
            string payload = "{\"exp\":9999999999}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            bool result = IsNotBeforeValid(jwt);
            
            Assert.IsTrue(result);
        }

        [TestMethod]
        public void GetNotBeforeUtc_ValidClaim_ReturnsCorrectTime()
        {
            var testTime = new DateTime(2025, 1, 1, 12, 0, 0, DateTimeKind.Utc);
            var unixTime = ((DateTimeOffset)testTime).ToUnixTimeSeconds();
            string payload = $"{{\"nbf\":{unixTime},\"exp\":9999999999}}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            DateTime? result = GetNotBeforeUtc(jwt);
            
            Assert.IsNotNull(result);
            Assert.AreEqual(testTime, result.Value);
        }

        [TestMethod]
        public void GetIssuedAtUtc_ValidClaim_ReturnsCorrectTime()
        {
            var testTime = new DateTime(2025, 1, 1, 12, 0, 0, DateTimeKind.Utc);
            var unixTime = ((DateTimeOffset)testTime).ToUnixTimeSeconds();
            string payload = $"{{\"iat\":{unixTime},\"exp\":9999999999}}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            DateTime? result = GetIssuedAtUtc(jwt);
            
            Assert.IsNotNull(result);
            Assert.AreEqual(testTime, result.Value);
        }

        [TestMethod]
        public void GetAudience_SingleAudience_ReturnsCorrectValue()
        {
            string payload = "{\"aud\":\"my-api\",\"exp\":9999999999}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            string result = GetAudience(jwt);
            
            Assert.AreEqual("my-api", result);
        }

        [TestMethod]
        public void GetAudience_AudienceArray_ReturnsFirstValue()
        {
            string payload = "{\"aud\":[\"first-api\",\"second-api\"],\"exp\":9999999999}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            string result = GetAudience(jwt);
            
            Assert.AreEqual("first-api", result);
        }

        [TestMethod]
        public void GetAudience_NoAudience_ReturnsNull()
        {
            string payload = "{\"exp\":9999999999}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            string result = GetAudience(jwt);
            
            Assert.IsNull(result);
        }

        [TestMethod]
        public void IsAudienceValid_NullInput_ReturnsFalse()
        {
            bool result = IsAudienceValid(null, "my-api");
            Assert.IsFalse(result);
        }

        [TestMethod]
        public void IsAudienceValid_EmptyExpectedAudience_ReturnsFalse()
        {
            string payload = "{\"aud\":\"my-api\",\"exp\":9999999999}";
            string jwt = JwtTestHelper.CreateTestJwt(payload);
            
            bool result = IsAudienceValid(jwt, "");
            
            Assert.IsFalse(result);
        }
    }
}