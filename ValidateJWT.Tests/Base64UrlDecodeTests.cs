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
            string input = "SGVsbG8gV29ybGQ";
            string expected = "Hello World";
            string decoded = Encoding.UTF8.GetString(Base64UrlDecode(input));
            Assert.AreEqual(expected, decoded);
        }

        [TestMethod]
        public void Base64UrlDecode_WithDashes_ReplacesWithPlus()
        {
            string base64Url = "SGVsbG8tV29ybGQ";
            var result = Base64UrlDecode(base64Url);
            Assert.IsNotNull(result);
            Assert.IsNotEmpty(result);
        }

        [TestMethod]
        public void Base64UrlDecode_WithUnderscores_ReplacesWithSlash()
        {
            string base64Url = "SGVsbG9fV29ybGQ";
            var result = Base64UrlDecode(base64Url);
            Assert.IsNotNull(result);
            Assert.IsNotEmpty(result);
        }

        [TestMethod]
        public void Base64UrlDecode_NoPadding_AddsPaddingCorrectly()
        {
            string withoutPadding = "SGVsbG8";
            string expected = "Hello";
            string decoded = Encoding.UTF8.GetString(Base64UrlDecode(withoutPadding));
            Assert.AreEqual(expected, decoded);
        }

        [TestMethod]
        public void Base64UrlDecode_RequiresTwoPaddingChars_AddsCorrectly()
        {
            string input = "YQ";
            string expected = "a";
            string decoded = Encoding.UTF8.GetString(Base64UrlDecode(input));
            Assert.AreEqual(expected, decoded);
        }

        [TestMethod]
        public void Base64UrlDecode_RequiresOnePaddingChar_AddsCorrectly()
        {
            string input = "YWI";
            string expected = "ab";
            string decoded = Encoding.UTF8.GetString(Base64UrlDecode(input));
            Assert.AreEqual(expected, decoded);
        }

        [TestMethod]
        public void Base64UrlDecode_AlreadyCorrectLength_NoExtraPadding()
        {
            string input = "QUJD";
            string expected = "ABC";
            string decoded = Encoding.UTF8.GetString(Base64UrlDecode(input));
            Assert.AreEqual(expected, decoded);
        }

        [TestMethod]
        public void Base64UrlDecode_EmptyString_ReturnsEmptyArray()
        {
            var result = Base64UrlDecode(string.Empty);
            Assert.IsNotNull(result);
            Assert.IsEmpty(result);
        }

        [TestMethod]
        public void Base64UrlDecode_NullInput_ReturnsEmptyArray()
        {
            var result = Base64UrlDecode(null);
            Assert.IsNotNull(result);
            Assert.IsEmpty(result);
        }

        [TestMethod]
        public void Base64UrlDecode_LongString_DecodesCorrectly()
        {
            string longText = "This is a longer string to test Base64Url encoding and decoding with multiple characters.";
            string base64Url = Base64UrlEncode(longText);
            string decoded = Encoding.UTF8.GetString(Base64UrlDecode(base64Url));
            Assert.AreEqual(longText, decoded);
        }

        [TestMethod]
        public void Base64UrlDecode_SpecialCharacters_DecodesCorrectly()
        {
            string textWithSpecial = "Test with special chars: !@#$%^&*()";
            string base64Url = Base64UrlEncode(textWithSpecial);
            string decoded = Encoding.UTF8.GetString(Base64UrlDecode(base64Url));
            Assert.AreEqual(textWithSpecial, decoded);
        }

        [TestMethod]
        public void Base64UrlDecode_UnicodeCharacters_DecodesCorrectly()
        {
            string unicodeText = "Hello??";
            string base64Url = Base64UrlEncode(unicodeText);
            string decoded = Encoding.UTF8.GetString(Base64UrlDecode(base64Url));
            Assert.AreEqual(unicodeText, decoded);
        }

        [TestMethod]
        public void Base64UrlDecode_JsonPayload_DecodesCorrectly()
        {
            string json = "{\"sub\":\"1234567890\",\"name\":\"John Doe\",\"iat\":1516239022}";
            string base64Url = Base64UrlEncode(json);
            string decoded = Encoding.UTF8.GetString(Base64UrlDecode(base64Url));
            Assert.AreEqual(json, decoded);
        }

        [TestMethod]
        public void Base64UrlDecode_InvalidLength_ThrowsFormatException()
        {
            string invalid = "A";
            bool exceptionThrown = false;
            try
            {
                Base64UrlDecode(invalid);
            }
            catch (FormatException)
            {
                exceptionThrown = true;
            }
            Assert.IsTrue(exceptionThrown, "Should throw FormatException for invalid Base64 length");
        }

        [TestMethod]
        public void Base64UrlDecode_RealJwtPayload_DecodesCorrectly()
        {
            string jwtPayload = "eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ";
            string decoded = Encoding.UTF8.GetString(Base64UrlDecode(jwtPayload));
            StringAssert.Contains(decoded, "\"sub\":\"1234567890\"");
            StringAssert.Contains(decoded, "\"name\":\"John Doe\"");
            StringAssert.Contains(decoded, "\"iat\":1516239022");
        }

        [TestMethod]
        public void Base64UrlDecode_BinaryData_PreservesBytes()
        {
            byte[] originalBytes = new byte[] { 0x00, 0x01, 0x02, 0xFE, 0xFF };
            string base64Url = Convert.ToBase64String(originalBytes)
                .Replace('+', '-')
                .Replace('/', '_')
                .TrimEnd('=');
            var result = Base64UrlDecode(base64Url);
            CollectionAssert.AreEqual(originalBytes, result);
        }

        [TestMethod]
        public void Base64UrlDecode_AllPaddingScenarios_WorkCorrectly()
        {
            string[] testInputs = { "QUJD", "QUI", "QQ" };
            foreach (var input in testInputs)
            {
                var result = Base64UrlDecode(input);
                Assert.IsNotNull(result);
                Assert.IsNotEmpty(result);
            }
        }

        private static string Base64UrlEncode(string input)
        {
            byte[] bytes = Encoding.UTF8.GetBytes(input);
            string base64 = Convert.ToBase64String(bytes);
            return base64.Replace('+', '-').Replace('/', '_').TrimEnd('=');
        }
    }
}
