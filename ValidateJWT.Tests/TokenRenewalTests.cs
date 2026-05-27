using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Johan.Common;
using static Johan.Common.ValidateJWT;

namespace ValidateJWT.Tests
{
    [TestClass]
    public class TokenRenewalTests
    {
        #region ShouldRenewToken Tests

        [TestMethod]
        public void ShouldRenewToken_TokenExpiresIn3Minutes_RenewBefore5Minutes_ReturnsTrue()
        {
            // Arrange
            var expiresAt = DateTime.UtcNow.AddMinutes(3);
            var jwt = JwtTestHelper.CreateJwtWithExpiration(expiresAt);

            // Act
            var result = ShouldRenewToken(jwt, 5);

            // Assert
            Assert.IsTrue(result, "Token expiring in 3 minutes should be renewed when threshold is 5 minutes");
        }

        [TestMethod]
        public void ShouldRenewToken_TokenExpiresIn10Minutes_RenewBefore5Minutes_ReturnsFalse()
        {
            // Arrange
            var expiresAt = DateTime.UtcNow.AddMinutes(10);
            var jwt = JwtTestHelper.CreateJwtWithExpiration(expiresAt);

            // Act
            var result = ShouldRenewToken(jwt, 5);

            // Assert
            Assert.IsFalse(result, "Token expiring in 10 minutes should not be renewed when threshold is 5 minutes");
        }

        [TestMethod]
        public void ShouldRenewToken_TokenExpiresExactlyAt5Minutes_RenewBefore5Minutes_ReturnsTrue()
        {
            // Arrange
            var expiresAt = DateTime.UtcNow.AddMinutes(5);
            var jwt = JwtTestHelper.CreateJwtWithExpiration(expiresAt);

            // Act
            var result = ShouldRenewToken(jwt, 5);

            // Assert
            Assert.IsTrue(result, "Token expiring in exactly 5 minutes should be renewed when threshold is 5 minutes");
        }

        [TestMethod]
        public void ShouldRenewToken_ExpiredToken_ReturnsFalse()
        {
            // Arrange
            var expiresAt = DateTime.UtcNow.AddMinutes(-10);
            var jwt = JwtTestHelper.CreateJwtWithExpiration(expiresAt);

            // Act
            var result = ShouldRenewToken(jwt, 5);

            // Assert
            Assert.IsFalse(result, "Already expired token should return false");
        }

        [TestMethod]
        public void ShouldRenewToken_TokenExpiresIn30Seconds_RenewBefore1Minute_ReturnsTrue()
        {
            // Arrange
            var expiresAt = DateTime.UtcNow.AddSeconds(30);
            var jwt = JwtTestHelper.CreateJwtWithExpiration(expiresAt);

            // Act
            var result = ShouldRenewToken(jwt, 1);

            // Assert
            Assert.IsTrue(result, "Token expiring in 30 seconds should be renewed when threshold is 1 minute");
        }

        [TestMethod]
        public void ShouldRenewToken_WithCustomNowUtc_UsesCustomTime()
        {
            // Arrange
            var expiresAt = new DateTime(2024, 1, 1, 12, 0, 0, DateTimeKind.Utc);
            var jwt = JwtTestHelper.CreateJwtWithExpiration(expiresAt);
            var customNow = new DateTime(2024, 1, 1, 11, 57, 0, DateTimeKind.Utc); // 3 minutes before expiration

            // Act
            var result = ShouldRenewToken(jwt, 5, customNow);

            // Assert
            Assert.IsTrue(result, "Token should be renewed when custom time is 3 minutes before expiration with 5-minute threshold");
        }

        [TestMethod]
        public void ShouldRenewToken_InvalidToken_ReturnsFalse()
        {
            // Arrange
            var jwt = "invalid.jwt.token";

            // Act
            var result = ShouldRenewToken(jwt, 5);

            // Assert
            Assert.IsFalse(result, "Invalid token should return false");
        }

        [TestMethod]
        public void ShouldRenewToken_NullToken_ReturnsFalse()
        {
            // Arrange
            string jwt = null;

            // Act
            var result = ShouldRenewToken(jwt, 5);

            // Assert
            Assert.IsFalse(result, "Null token should return false");
        }

        [TestMethod]
        public void ShouldRenewToken_TokenWithoutExpiration_ReturnsFalse()
        {
            // Arrange - Create a token without expiration claim
            var jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIn0.Gfx6VO9tcxwk6xqx9yYzSfebfeakZp5JYIgP_edcw_A";

            // Act
            var result = ShouldRenewToken(jwt, 5);

            // Assert
            Assert.IsFalse(result, "Token without expiration should return false");
        }

        #endregion

        #region GetTimeUntilRenewal Tests

        [TestMethod]
        public void GetTimeUntilRenewal_TokenExpiresIn10Minutes_RenewBefore5Minutes_Returns5Minutes()
        {
            // Arrange
            var expiresAt = DateTime.UtcNow.AddMinutes(10);
            var jwt = JwtTestHelper.CreateJwtWithExpiration(expiresAt);

            // Act
            var result = GetTimeUntilRenewal(jwt, 5);

            // Assert
            Assert.IsNotNull(result, "Should return a TimeSpan for valid token");
            Assert.IsTrue(result.Value.TotalMinutes >= 4.9 && result.Value.TotalMinutes <= 5.1, 
                $"Time until renewal should be approximately 5 minutes, but was {result.Value.TotalMinutes}");
        }

        [TestMethod]
        public void GetTimeUntilRenewal_TokenExpiresIn3Minutes_RenewBefore5Minutes_ReturnsNull()
        {
            // Arrange
            var expiresAt = DateTime.UtcNow.AddMinutes(3);
            var jwt = JwtTestHelper.CreateJwtWithExpiration(expiresAt);

            // Act
            var result = GetTimeUntilRenewal(jwt, 5);

            // Assert
            Assert.IsNull(result, "Should return null when renewal is needed now (within renewal window)");
        }

        [TestMethod]
        public void GetTimeUntilRenewal_ExpiredToken_ReturnsNull()
        {
            // Arrange
            var expiresAt = DateTime.UtcNow.AddMinutes(-10);
            var jwt = JwtTestHelper.CreateJwtWithExpiration(expiresAt);

            // Act
            var result = GetTimeUntilRenewal(jwt, 5);

            // Assert
            Assert.IsNull(result, "Should return null for expired token");
        }

        [TestMethod]
        public void GetTimeUntilRenewal_TokenExpiresIn30Minutes_RenewBefore10Minutes_Returns20Minutes()
        {
            // Arrange
            var expiresAt = DateTime.UtcNow.AddMinutes(30);
            var jwt = JwtTestHelper.CreateJwtWithExpiration(expiresAt);

            // Act
            var result = GetTimeUntilRenewal(jwt, 10);

            // Assert
            Assert.IsNotNull(result, "Should return a TimeSpan for valid token");
            Assert.IsTrue(result.Value.TotalMinutes >= 19.9 && result.Value.TotalMinutes <= 20.1, 
                $"Time until renewal should be approximately 20 minutes, but was {result.Value.TotalMinutes}");
        }

        [TestMethod]
        public void GetTimeUntilRenewal_WithCustomNowUtc_UsesCustomTime()
        {
            // Arrange
            var expiresAt = new DateTime(2024, 1, 1, 12, 0, 0, DateTimeKind.Utc);
            var jwt = JwtTestHelper.CreateJwtWithExpiration(expiresAt);
            var customNow = new DateTime(2024, 1, 1, 11, 50, 0, DateTimeKind.Utc); // 10 minutes before expiration

            // Act
            var result = GetTimeUntilRenewal(jwt, 5, customNow);

            // Assert
            Assert.IsNotNull(result, "Should return a TimeSpan for valid token");
            Assert.IsTrue(result.Value.TotalMinutes >= 4.9 && result.Value.TotalMinutes <= 5.1, 
                $"Time until renewal should be approximately 5 minutes, but was {result.Value.TotalMinutes}");
        }

        [TestMethod]
        public void GetTimeUntilRenewal_InvalidToken_ReturnsNull()
        {
            // Arrange
            var jwt = "invalid.jwt.token";

            // Act
            var result = GetTimeUntilRenewal(jwt, 5);

            // Assert
            Assert.IsNull(result, "Should return null for invalid token");
        }

        [TestMethod]
        public void GetTimeUntilRenewal_NullToken_ReturnsNull()
        {
            // Arrange
            string jwt = null;

            // Act
            var result = GetTimeUntilRenewal(jwt, 5);

            // Assert
            Assert.IsNull(result, "Should return null for null token");
        }

        [TestMethod]
        public void GetTimeUntilRenewal_TokenWithoutExpiration_ReturnsNull()
        {
            // Arrange - Create a token without expiration claim
            var jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIn0.Gfx6VO9tcxwk6xqx9yYzSfebfeakZp5JYIgP_edcw_A";

            // Act
            var result = GetTimeUntilRenewal(jwt, 5);

            // Assert
            Assert.IsNull(result, "Should return null for token without expiration");
        }

        [TestMethod]
        public void GetTimeUntilRenewal_TokenExpiresIn1Hour_RenewBefore15Minutes_Returns45Minutes()
        {
            // Arrange
            var expiresAt = DateTime.UtcNow.AddHours(1);
            var jwt = JwtTestHelper.CreateJwtWithExpiration(expiresAt);

            // Act
            var result = GetTimeUntilRenewal(jwt, 15);

            // Assert
            Assert.IsNotNull(result, "Should return a TimeSpan for valid token");
            Assert.IsTrue(result.Value.TotalMinutes >= 44.9 && result.Value.TotalMinutes <= 45.1, 
                $"Time until renewal should be approximately 45 minutes, but was {result.Value.TotalMinutes}");
        }

        #endregion

        #region Integration Tests

        [TestMethod]
        public void TokenRenewal_RealWorldScenario_WorksCorrectly()
        {
            // Arrange - Create a token that expires in 4 minutes
            var expiresAt = DateTime.UtcNow.AddMinutes(4);
            var jwt = JwtTestHelper.CreateJwtWithExpiration(expiresAt);
            var renewThreshold = 5;

            // Act
            var shouldRenew = ShouldRenewToken(jwt, renewThreshold);
            var timeUntilRenewal = GetTimeUntilRenewal(jwt, renewThreshold);

            // Assert
            Assert.IsTrue(shouldRenew, "Token expiring in 4 minutes should be renewed with 5-minute threshold");
            Assert.IsNull(timeUntilRenewal, "Time until renewal should be null when renewal is needed");
        }

        [TestMethod]
        public void TokenRenewal_TokenStillValid_DoesNotNeedRenewal()
        {
            // Arrange - Create a token that expires in 20 minutes
            var expiresAt = DateTime.UtcNow.AddMinutes(20);
            var jwt = JwtTestHelper.CreateJwtWithExpiration(expiresAt);
            var renewThreshold = 5;

            // Act
            var shouldRenew = ShouldRenewToken(jwt, renewThreshold);
            var timeUntilRenewal = GetTimeUntilRenewal(jwt, renewThreshold);

            // Assert
            Assert.IsFalse(shouldRenew, "Token expiring in 20 minutes should not be renewed with 5-minute threshold");
            Assert.IsNotNull(timeUntilRenewal, "Time until renewal should be available");
            Assert.IsTrue(timeUntilRenewal.Value.TotalMinutes >= 14.9 && timeUntilRenewal.Value.TotalMinutes <= 15.1,
                $"Time until renewal should be approximately 15 minutes, but was {timeUntilRenewal.Value.TotalMinutes}");
        }

        #endregion
    }
}
