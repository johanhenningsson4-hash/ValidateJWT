using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using TPDotNet.MTR.Common;

namespace ValidateJWT.Tests
{
    [TestClass]
    public class ValidateJWTTests
    {
        #region IsExpired Tests

        [TestMethod]
        public void IsExpired_ExpiredToken_ReturnsTrue()
        {
            // Arrange
            var jwt = JwtTestHelper.CreateJwtWithExpiration(DateTime.UtcNow.AddHours(-1));

            // Act
            var result = ValidateJWT.IsExpired(jwt);

            // Assert
            Assert.IsTrue(result, "Token expired 1 hour ago should be marked as expired");
        }

        [TestMethod]
        public void IsExpired_ValidToken_ReturnsFalse()
        {
            // Arrange
            var jwt = JwtTestHelper.CreateJwtWithExpiration(DateTime.UtcNow.AddHours(1));

            // Act
            var result = ValidateJWT.IsExpired(jwt);

            // Assert
            Assert.IsFalse(result, "Token expiring in 1 hour should not be marked as expired");
        }

        [TestMethod]
        public void IsExpired_TokenExpiringNow_WithClockSkew_ReturnsFalse()
        {
            // Arrange
            var jwt = JwtTestHelper.CreateJwtWithExpiration(DateTime.UtcNow);
            var clockSkew = TimeSpan.FromMinutes(5);

            // Act
            var result = ValidateJWT.IsExpired(jwt, clockSkew);

            // Assert
            Assert.IsFalse(result, "Token expiring now should not be expired with 5-minute clock skew");
        }

        [TestMethod]
        public void IsExpired_TokenExpiredBeyondClockSkew_ReturnsTrue()
        {
            // Arrange
            var jwt = JwtTestHelper.CreateJwtWithExpiration(DateTime.UtcNow.AddMinutes(-10));
            var clockSkew = TimeSpan.FromMinutes(5);

            // Act
            var result = ValidateJWT.IsExpired(jwt, clockSkew);

            // Assert
            Assert.IsTrue(result, "Token expired 10 minutes ago should be expired even with 5-minute clock skew");
        }

        [TestMethod]
        public void IsExpired_WithCustomClockSkew_RespectsSkew()
        {
            // Arrange
            var jwt = JwtTestHelper.CreateJwtWithExpiration(DateTime.UtcNow.AddMinutes(-8));
            var clockSkew = TimeSpan.FromMinutes(10);

            // Act
            var result = ValidateJWT.IsExpired(jwt, clockSkew);

            // Assert
            Assert.IsFalse(result, "Token expired 8 minutes ago should not be expired with 10-minute clock skew");
        }

        [TestMethod]
        public void IsExpired_WithCustomTime_UsesProvidedTime()
        {
            // Arrange
            var expirationTime = new DateTime(2024, 1, 15, 12, 0, 0, DateTimeKind.Utc);
            var jwt = JwtTestHelper.CreateJwtWithExpiration(expirationTime);
            var testTime = new DateTime(2024, 1, 15, 11, 0, 0, DateTimeKind.Utc);

            // Act
            var result = ValidateJWT.IsExpired(jwt, TimeSpan.FromMinutes(5), testTime);

            // Assert
            Assert.IsFalse(result, "Token should not be expired when testing at a time before expiration");
        }

        [TestMethod]
        public void IsExpired_NullToken_ReturnsFalse()
        {
            // Act
            var result = ValidateJWT.IsExpired(null);

            // Assert
            Assert.IsFalse(result, "Null token should return false (no expiration claim found)");
        }

        [TestMethod]
        public void IsExpired_EmptyToken_ReturnsFalse()
        {
            // Act
            var result = ValidateJWT.IsExpired(string.Empty);

            // Assert
            Assert.IsFalse(result, "Empty token should return false (no expiration claim found)");
        }

        [TestMethod]
        public void IsExpired_MalformedToken_ReturnsFalse()
        {
            // Arrange
            var jwt = JwtTestHelper.CreateMalformedJwt(1);

            // Act
            var result = ValidateJWT.IsExpired(jwt);

            // Assert
            Assert.IsFalse(result, "Malformed token should return false (no expiration claim found)");
        }

        [TestMethod]
        public void IsExpired_TokenWithoutExpiration_ReturnsFalse()
        {
            // Arrange
            var jwt = JwtTestHelper.CreateJwtWithoutExpiration();

            // Act
            var result = ValidateJWT.IsExpired(jwt);

            // Assert
            Assert.IsFalse(result, "Token without expiration claim should return false");
        }

        [TestMethod]
        public void IsExpired_InvalidBase64_ReturnsFalse()
        {
            // Arrange
            var jwt = JwtTestHelper.CreateJwtWithInvalidBase64();

            // Act
            var result = ValidateJWT.IsExpired(jwt);

            // Assert
            Assert.IsFalse(result, "Token with invalid Base64 should return false");
        }

        #endregion

        #region IsValidNow Tests

        [TestMethod]
        public void IsValidNow_ValidToken_ReturnsTrue()
        {
            // Arrange
            var jwt = JwtTestHelper.CreateJwtWithExpiration(DateTime.UtcNow.AddHours(1));

            // Act
            var result = ValidateJWT.IsValidNow(jwt);

            // Assert
            Assert.IsTrue(result, "Token expiring in 1 hour should be valid now");
        }

        [TestMethod]
        public void IsValidNow_ExpiredToken_ReturnsFalse()
        {
            // Arrange
            var jwt = JwtTestHelper.CreateJwtWithExpiration(DateTime.UtcNow.AddHours(-1));

            // Act
            var result = ValidateJWT.IsValidNow(jwt);

            // Assert
            Assert.IsFalse(result, "Token expired 1 hour ago should not be valid now");
        }

        [TestMethod]
        public void IsValidNow_TokenExpiringNow_WithClockSkew_ReturnsTrue()
        {
            // Arrange
            var jwt = JwtTestHelper.CreateJwtWithExpiration(DateTime.UtcNow);

            // Act
            var result = ValidateJWT.IsValidNow(jwt);

            // Assert
            Assert.IsTrue(result, "Token expiring now should be valid with default clock skew");
        }

        [TestMethod]
        public void IsValidNow_TokenExpiredBeyondClockSkew_ReturnsFalse()
        {
            // Arrange
            var jwt = JwtTestHelper.CreateJwtWithExpiration(DateTime.UtcNow.AddMinutes(-10));
            var clockSkew = TimeSpan.FromMinutes(5);

            // Act
            var result = ValidateJWT.IsValidNow(jwt, clockSkew);

            // Assert
            Assert.IsFalse(result, "Token expired beyond clock skew should not be valid");
        }

        [TestMethod]
        public void IsValidNow_WithCustomTime_UsesProvidedTime()
        {
            // Arrange
            var expirationTime = new DateTime(2024, 1, 15, 12, 0, 0, DateTimeKind.Utc);
            var jwt = JwtTestHelper.CreateJwtWithExpiration(expirationTime);
            var testTime = new DateTime(2024, 1, 15, 11, 0, 0, DateTimeKind.Utc);

            // Act
            var result = ValidateJWT.IsValidNow(jwt, TimeSpan.FromMinutes(5), testTime);

            // Assert
            Assert.IsTrue(result, "Token should be valid when testing at a time before expiration");
        }

        [TestMethod]
        public void IsValidNow_NullToken_ReturnsFalse()
        {
            // Act
            var result = ValidateJWT.IsValidNow(null);

            // Assert
            Assert.IsFalse(result, "Null token should return false");
        }

        [TestMethod]
        public void IsValidNow_EmptyToken_ReturnsFalse()
        {
            // Act
            var result = ValidateJWT.IsValidNow(string.Empty);

            // Assert
            Assert.IsFalse(result, "Empty token should return false");
        }

        [TestMethod]
        public void IsValidNow_MalformedToken_ReturnsFalse()
        {
            // Arrange
            var jwt = JwtTestHelper.CreateMalformedJwt(1);

            // Act
            var result = ValidateJWT.IsValidNow(jwt);

            // Assert
            Assert.IsFalse(result, "Malformed token should return false");
        }

        [TestMethod]
        public void IsValidNow_TokenWithoutExpiration_ReturnsFalse()
        {
            // Arrange
            var jwt = JwtTestHelper.CreateJwtWithoutExpiration();

            // Act
            var result = ValidateJWT.IsValidNow(jwt);

            // Assert
            Assert.IsFalse(result, "Token without expiration should return false");
        }

        #endregion

        #region GetExpirationUtc Tests

        [TestMethod]
        public void GetExpirationUtc_ValidToken_ReturnsCorrectTime()
        {
            // Arrange
            var expectedExpiration = new DateTime(2024, 6, 15, 12, 30, 0, DateTimeKind.Utc);
            var jwt = JwtTestHelper.CreateJwtWithExpiration(expectedExpiration);

            // Act
            var result = ValidateJWT.GetExpirationUtc(jwt);

            // Assert
            Assert.IsNotNull(result, "Expiration should not be null for valid token");
            Assert.AreEqual(expectedExpiration, result.Value, "Expiration time should match");
        }

        [TestMethod]
        public void GetExpirationUtc_TokenWithExpInPast_ReturnsCorrectTime()
        {
            // Arrange
            var expectedExpiration = new DateTime(2020, 1, 1, 0, 0, 0, DateTimeKind.Utc);
            var jwt = JwtTestHelper.CreateJwtWithExpiration(expectedExpiration);

            // Act
            var result = ValidateJWT.GetExpirationUtc(jwt);

            // Assert
            Assert.IsNotNull(result, "Expiration should not be null even for expired token");
            Assert.AreEqual(expectedExpiration, result.Value, "Expiration time should match");
        }

        [TestMethod]
        public void GetExpirationUtc_TokenWithExpInFuture_ReturnsCorrectTime()
        {
            // Arrange
            var expectedExpiration = new DateTime(2030, 12, 31, 23, 59, 59, DateTimeKind.Utc);
            var jwt = JwtTestHelper.CreateJwtWithExpiration(expectedExpiration);

            // Act
            var result = ValidateJWT.GetExpirationUtc(jwt);

            // Assert
            Assert.IsNotNull(result, "Expiration should not be null for future token");
            Assert.AreEqual(expectedExpiration, result.Value, "Expiration time should match");
        }

        [TestMethod]
        public void GetExpirationUtc_NullToken_ReturnsNull()
        {
            // Act
            var result = ValidateJWT.GetExpirationUtc(null);

            // Assert
            Assert.IsNull(result, "Null token should return null expiration");
        }

        [TestMethod]
        public void GetExpirationUtc_EmptyToken_ReturnsNull()
        {
            // Act
            var result = ValidateJWT.GetExpirationUtc(string.Empty);

            // Assert
            Assert.IsNull(result, "Empty token should return null expiration");
        }

        [TestMethod]
        public void GetExpirationUtc_MalformedToken_ReturnsNull()
        {
            // Arrange
            var jwt = JwtTestHelper.CreateMalformedJwt(1);

            // Act
            var result = ValidateJWT.GetExpirationUtc(jwt);

            // Assert
            Assert.IsNull(result, "Malformed token should return null expiration");
        }

        [TestMethod]
        public void GetExpirationUtc_TokenWithoutExpiration_ReturnsNull()
        {
            // Arrange
            var jwt = JwtTestHelper.CreateJwtWithoutExpiration();

            // Act
            var result = ValidateJWT.GetExpirationUtc(jwt);

            // Assert
            Assert.IsNull(result, "Token without expiration claim should return null");
        }

        [TestMethod]
        public void GetExpirationUtc_InvalidBase64_ReturnsNull()
        {
            // Arrange
            var jwt = JwtTestHelper.CreateJwtWithInvalidBase64();

            // Act
            var result = ValidateJWT.GetExpirationUtc(jwt);

            // Assert
            Assert.IsNull(result, "Token with invalid Base64 should return null");
        }

        [TestMethod]
        public void GetExpirationUtc_InvalidJson_ReturnsNull()
        {
            // Arrange
            var jwt = JwtTestHelper.CreateJwtWithInvalidJson();

            // Act
            var result = ValidateJWT.GetExpirationUtc(jwt);

            // Assert
            Assert.IsNull(result, "Token with invalid JSON should return null");
        }

        #endregion

        #region Edge Cases and Integration Tests

        [TestMethod]
        public void IsExpired_VeryOldToken_ReturnsTrue()
        {
            // Arrange - Token from year 2000
            var jwt = JwtTestHelper.CreateJwtWithExpiration(new DateTime(2000, 1, 1, 0, 0, 0, DateTimeKind.Utc));

            // Act
            var result = ValidateJWT.IsExpired(jwt);

            // Assert
            Assert.IsTrue(result, "Very old token should be expired");
        }

        [TestMethod]
        public void IsValidNow_VeryFutureToken_ReturnsTrue()
        {
            // Arrange - Token expiring in year 2050
            var jwt = JwtTestHelper.CreateJwtWithExpiration(new DateTime(2050, 12, 31, 23, 59, 59, DateTimeKind.Utc));

            // Act
            var result = ValidateJWT.IsValidNow(jwt);

            // Assert
            Assert.IsTrue(result, "Token expiring far in future should be valid");
        }

        [TestMethod]
        public void IsExpired_WithZeroClockSkew_IsStrictAboutExpiration()
        {
            // Arrange
            var jwt = JwtTestHelper.CreateJwtWithExpiration(DateTime.UtcNow.AddSeconds(-1));

            // Act
            var result = ValidateJWT.IsExpired(jwt, TimeSpan.Zero);

            // Assert
            Assert.IsTrue(result, "Token expired 1 second ago should be expired with zero clock skew");
        }

        [TestMethod]
        public void IsValidNow_WithLargeClockSkew_IsLenient()
        {
            // Arrange
            var jwt = JwtTestHelper.CreateJwtWithExpiration(DateTime.UtcNow.AddMinutes(-20));
            var clockSkew = TimeSpan.FromMinutes(30);

            // Act
            var result = ValidateJWT.IsValidNow(jwt, clockSkew);

            // Assert
            Assert.IsTrue(result, "Token should be valid with large clock skew");
        }

        [TestMethod]
        public void GetExpirationUtc_MultipleCallsSameToken_ReturnsSameValue()
        {
            // Arrange
            var expectedExpiration = new DateTime(2024, 6, 15, 12, 30, 0, DateTimeKind.Utc);
            var jwt = JwtTestHelper.CreateJwtWithExpiration(expectedExpiration);

            // Act
            var result1 = ValidateJWT.GetExpirationUtc(jwt);
            var result2 = ValidateJWT.GetExpirationUtc(jwt);

            // Assert
            Assert.IsNotNull(result1);
            Assert.IsNotNull(result2);
            Assert.AreEqual(result1.Value, result2.Value, "Multiple calls should return same expiration");
        }

        [TestMethod]
        public void IsExpired_WhitespaceToken_ReturnsFalse()
        {
            // Act
            var result = ValidateJWT.IsExpired("   ");

            // Assert
            Assert.IsFalse(result, "Whitespace token should return false");
        }

        [TestMethod]
        public void IsValidNow_WhitespaceToken_ReturnsFalse()
        {
            // Act
            var result = ValidateJWT.IsValidNow("   ");

            // Assert
            Assert.IsFalse(result, "Whitespace token should return false");
        }

        #endregion
    }
}
