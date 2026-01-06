using System;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Johan.Common;
using static Johan.Common.ValidateJWT;

namespace ValidateJWT.Tests
{
    [TestClass]
    public class Base64UrlDecodeTests
    {
        [TestMethod]
        public void Base64UrlDecode_ValidInput_DecodesCorrectly()
        {
            // Arrange
            string input = "SGVsbG8gV29ybGQ"; // "Hello World" in Base64Url
            string expected = "Hello World";

            // Act
            byte[] result = Base64UrlDecode(input);
            string decoded = Encoding.UTF8.GetString(result);

            // Assert
            Assert.AreEqual(expected, decoded, "Should decode valid Base64Url string correctly");
        }

        [TestMethod]
        public void Base64UrlDecode_WithDashes_ReplacesWithPlus()
        {
            // Arrange - Base64Url uses '-' instead of '+'
            string base64Url = "SGVsbG8tV29ybGQ"; // Contains dash
            
            // Act
            byte[] result = Base64UrlDecode(base64Url);

            // Assert
            Assert.IsNotNull(result, "Should decode string with dashes");
            Assert.IsTrue(result.Length > 0, "Should return non-empty result");
        }

        [TestMethod]
        public void Base64UrlDecode_WithUnderscores_ReplacesWithSlash()
        {
            // Arrange - Base64Url uses '_' instead of '/'
            string base64Url = "SGVsbG9fV29ybGQ"; // Contains underscore
            
            // Act
            byte[] result = Base64UrlDecode(base64Url);

            // Assert
            Assert.IsNotNull(result, "Should decode string with underscores");
            Assert.IsTrue(result.Length > 0, "Should return non-empty result");
        }

        [TestMethod]
        public void Base64UrlDecode_NoPadding_AddsPaddingCorrectly()
        {
            // Arrange - Base64Url removes padding '='
            string withoutPadding = "SGVsbG8"; // Missing padding
            string expected = "Hello";

            // Act
            byte[] result = Base64UrlDecode(withoutPadding);
            string decoded = Encoding.UTF8.GetString(result);

            // Assert
            Assert.AreEqual(expected, decoded, "Should add correct padding and decode");
        }

        [TestMethod]
        public void Base64UrlDecode_RequiresTwoPaddingChars_AddsCorrectly()
        {
            // Arrange - String length % 4 == 2 requires "=="
            string input = "YQ"; // "a" in Base64Url without padding
            string expected = "a";

            // Act
            byte[] result = Base64UrlDecode(input);
            string decoded = Encoding.UTF8.GetString(result);

            // Assert
            Assert.AreEqual(expected, decoded, "Should add two padding chars correctly");
        }

        [TestMethod]
        public void Base64UrlDecode_RequiresOnePaddingChar_AddsCorrectly()
        {
            // Arrange - String length % 4 == 3 requires "="
            string input = "YWI"; // "ab" in Base64Url without padding
            string expected = "ab";

            // Act
            byte[] result = Base64UrlDecode(input);
            string decoded = Encoding.UTF8.GetString(result);

            // Assert
            Assert.AreEqual(expected, decoded, "Should add one padding char correctly");
        }

        [TestMethod]
        public void Base64UrlDecode_AlreadyCorrectLength_NoExtraPadding()
        {
            // Arrange - String length % 4 == 0, no padding needed
            string input = "QUJD"; // "ABC" in Base64
            string expected = "ABC";

            // Act
            byte[] result = Base64UrlDecode(input);
            string decoded = Encoding.UTF8.GetString(result);

            // Assert
            Assert.AreEqual(expected, decoded, "Should not add padding when length is correct");
        }

        [TestMethod]
        public void Base64UrlDecode_EmptyString_ReturnsEmptyArray()
        {
            // Arrange
            string input = string.Empty;

            // Act
            byte[] result = Base64UrlDecode(input);

            // Assert
            Assert.IsNotNull(result, "Should return non-null array");
            Assert.AreEqual(0, result.Length, "Should return empty array for empty input");
        }

        [TestMethod]
        public void Base64UrlDecode_NullInput_ReturnsEmptyArray()
        {
            // Arrange
            string input = null;

            // Act
            byte[] result = Base64UrlDecode(input);

            // Assert
            Assert.IsNotNull(result, "Should return non-null array");
            Assert.AreEqual(0, result.Length, "Should return empty array for null input");
        }

        [TestMethod]
        public void Base64UrlDecode_LongString_DecodesCorrectly()
        {
            // Arrange
            string longText = "This is a longer string to test Base64Url encoding and decoding with multiple characters.";
            string base64Url = Base64UrlEncode(longText);

            // Act
            byte[] result = Base64UrlDecode(base64Url);
            string decoded = Encoding.UTF8.GetString(result);

            // Assert
            Assert.AreEqual(longText, decoded, "Should decode long strings correctly");
        }

        [TestMethod]
        public void Base64UrlDecode_SpecialCharacters_DecodesCorrectly()
        {
            // Arrange
            string textWithSpecial = "Test with special chars: !@#$%^&*()";
            string base64Url = Base64UrlEncode(textWithSpecial);

            // Act
            byte[] result = Base64UrlDecode(base64Url);
            string decoded = Encoding.UTF8.GetString(result);

            // Assert
            Assert.AreEqual(textWithSpecial, decoded, "Should decode special characters correctly");
        }

        [TestMethod]
        public void Base64UrlDecode_UnicodeCharacters_DecodesCorrectly()
        {
            // Arrange
            string unicodeText = "Hello??";
            string base64Url = Base64UrlEncode(unicodeText);

            // Act
            byte[] result = Base64UrlDecode(base64Url);
            string decoded = Encoding.UTF8.GetString(result);

            // Assert
            Assert.AreEqual(unicodeText, decoded, "Should decode Unicode characters correctly");
        }

        [TestMethod]
        public void Base64UrlDecode_JsonPayload_DecodesCorrectly()
        {
            // Arrange - Typical JWT payload
            string json = "{\"sub\":\"1234567890\",\"name\":\"John Doe\",\"iat\":1516239022}";
            string base64Url = Base64UrlEncode(json);

            // Act
            byte[] result = Base64UrlDecode(base64Url);
            string decoded = Encoding.UTF8.GetString(result);

            // Assert
            Assert.AreEqual(json, decoded, "Should decode JSON payload correctly");
        }

        [TestMethod]
        [ExpectedException(typeof(FormatException))]
        public void Base64UrlDecode_InvalidLength_ThrowsFormatException()
        {
            // Arrange - Length % 4 == 1 is invalid
            string invalid = "A"; // Single character, invalid Base64 length

            // Act
            Base64UrlDecode(invalid);

            // Assert - Exception expected
        }

        [TestMethod]
        public void Base64UrlDecode_RealJwtPayload_DecodesCorrectly()
        {
            // Arrange - Real JWT payload (without padding)
            string jwtPayload = "eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ";
            
            // Act
            byte[] result = Base64UrlDecode(jwtPayload);
            string decoded = Encoding.UTF8.GetString(result);

            // Assert
            Assert.IsTrue(decoded.Contains("\"sub\":\"1234567890\""), "Should contain sub claim");
            Assert.IsTrue(decoded.Contains("\"name\":\"John Doe\""), "Should contain name claim");
            Assert.IsTrue(decoded.Contains("\"iat\":1516239022"), "Should contain iat claim");
        }

        [TestMethod]
        public void Base64UrlDecode_BinaryData_PreservesBytes()
        {
            // Arrange
            byte[] originalBytes = new byte[] { 0x00, 0x01, 0x02, 0xFE, 0xFF };
            string base64Url = Convert.ToBase64String(originalBytes)
                .Replace('+', '-')
                .Replace('/', '_')
                .TrimEnd('=');

            // Act
            byte[] result = Base64UrlDecode(base64Url);

            // Assert
            CollectionAssert.AreEqual(originalBytes, result, "Should preserve binary data exactly");
        }

        [TestMethod]
        public void Base64UrlDecode_AllPaddingScenarios_WorkCorrectly()
        {
            // Test all padding scenarios (length % 4 = 0, 2, 3)
            string[] testInputs = new[]
            {
                "QUJD",      // Length % 4 = 0, no padding needed
                "QUI",       // Length % 4 = 3, needs one '='
                "QQ"         // Length % 4 = 2, needs two '=='
            };

            foreach (var input in testInputs)
            {
                // Act
                byte[] result = Base64UrlDecode(input);
                
                // Assert
                Assert.IsNotNull(result, $"Should decode input: {input}");
                Assert.IsTrue(result.Length > 0, $"Should return non-empty result for: {input}");
            }
        }

        #region Helper Methods

        /// <summary>
        /// Helper method to encode strings to Base64Url format for testing
        /// </summary>
        private static string Base64UrlEncode(string input)
        {
            byte[] bytes = Encoding.UTF8.GetBytes(input);
            string base64 = Convert.ToBase64String(bytes);
            return base64.Replace('+', '-').Replace('/', '_').TrimEnd('=');
        }

        #endregion
    }
}
