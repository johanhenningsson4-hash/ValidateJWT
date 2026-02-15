using System;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Johan.Common;
using static Johan.Common.ValidateJWT;

namespace ValidateJWT.Tests
{
    [TestClass]
    public class JwtGenerationTests
    {
        private const string TestSecretKey = "your-256-bit-secret";
        private const string TestRsaPrivateKey = @"<RSAKeyValue><Modulus>test-modulus</Modulus><Exponent>AQAB</Exponent><P>test-p</P><Q>test-q</Q><DP>test-dp</DP><DQ>test-dq</DQ><InverseQ>test-inverseq</InverseQ><D>test-d</D></RSAKeyValue>";

        [TestMethod]
        public void CreateJwt_WithBasicPayload_CreatesValidToken()
        {
            var payload = new JwtPayload
            {
                Subject = "user123",
                Issuer = "https://example.com",
                Audiences = new[] { "my-api" },
                ExpiresAt = DateTime.UtcNow.AddHours(1),
                IssuedAt = DateTime.UtcNow
            };

            string jwt = CreateJwt(payload, TestSecretKey);

            Assert.IsNotNull(jwt);
            Assert.AreEqual(3, jwt.Split('.').Length);
            
            // Verify the token can be parsed
            Assert.AreEqual("user123", GetClaim<string>(jwt, "sub"));
            Assert.AreEqual("https://example.com", GetClaim<string>(jwt, "iss"));
            Assert.AreEqual("my-api", GetClaim<string>(jwt, "aud"));
        }

        [TestMethod]
        public void CreateJwt_WithMultipleAudiences_CreatesValidToken()
        {
            var payload = new JwtPayload
            {
                Subject = "user123",
                Audiences = new[] { "api1", "api2", "api3" },
                ExpiresAt = DateTime.UtcNow.AddHours(1)
            };

            string jwt = CreateJwt(payload, TestSecretKey);

            var audiences = GetClaim<string[]>(jwt, "aud");
            Assert.IsNotNull(audiences);
            Assert.AreEqual(3, audiences.Length);
            Assert.IsTrue(audiences.Contains("api1"));
            Assert.IsTrue(audiences.Contains("api2"));
            Assert.IsTrue(audiences.Contains("api3"));
        }

        [TestMethod]
        public void CreateJwt_WithCustomClaims_IncludesCustomClaims()
        {
            var payload = new JwtPayload
            {
                Subject = "user123",
                ExpiresAt = DateTime.UtcNow.AddHours(1)
            };
            payload.CustomClaims["role"] = "admin";
            payload.CustomClaims["department"] = "IT";
            payload.CustomClaims["age"] = 30;
            payload.CustomClaims["active"] = true;

            string jwt = CreateJwt(payload, TestSecretKey);

            Assert.AreEqual("admin", GetClaim<string>(jwt, "role"));
            Assert.AreEqual("IT", GetClaim<string>(jwt, "department"));
            Assert.AreEqual(30, GetClaim<int>(jwt, "age"));
            Assert.IsTrue(GetClaim<bool>(jwt, "active"));
        }

        [TestMethod]
        public void CreateJwt_WithJwtId_IncludesJtiClaim()
        {
            var payload = new JwtPayload
            {
                Subject = "user123",
                JwtId = "unique-token-id-123",
                ExpiresAt = DateTime.UtcNow.AddHours(1)
            };

            string jwt = CreateJwt(payload, TestSecretKey);

            Assert.AreEqual("unique-token-id-123", GetClaim<string>(jwt, "jti"));
        }

        [TestMethod]
        public void CreateJwt_WithNotBeforeClaim_IncludesNbf()
        {
            var notBefore = DateTime.UtcNow.AddMinutes(-5);
            var payload = new JwtPayload
            {
                Subject = "user123",
                NotBefore = notBefore,
                ExpiresAt = DateTime.UtcNow.AddHours(1)
            };

            string jwt = CreateJwt(payload, TestSecretKey);

            var nbf = GetNotBeforeUtc(jwt);
            Assert.IsNotNull(nbf);
            Assert.IsTrue(Math.Abs((nbf.Value - notBefore).TotalSeconds) < 1);
        }

        [TestMethod]
        public void CreateJwt_CreatedTokenPassesValidation()
        {
            var payload = new JwtPayload
            {
                Subject = "user123",
                Issuer = "https://example.com",
                Audiences = new[] { "my-api" },
                ExpiresAt = DateTime.UtcNow.AddHours(1),
                IssuedAt = DateTime.UtcNow
            };

            string jwt = CreateJwt(payload, TestSecretKey);

            // Test expiration validation
            Assert.IsFalse(IsExpired(jwt));
            Assert.IsTrue(IsValidNow(jwt));

            // Test signature validation
            var verificationResult = VerifySignature(jwt, TestSecretKey);
            Assert.IsTrue(verificationResult.IsValid);
            Assert.AreEqual("HS256", verificationResult.Algorithm);

            // Test claim validation
            Assert.IsTrue(IsIssuerValid(jwt, "https://example.com"));
            Assert.IsTrue(IsAudienceValid(jwt, "my-api"));
        }

        [TestMethod]
        public void CreateSimpleJwt_CreatesValidToken()
        {
            string jwt = CreateSimpleJwt("user123", "https://example.com", "my-api", 60, TestSecretKey);

            Assert.IsNotNull(jwt);
            Assert.AreEqual("user123", GetClaim<string>(jwt, "sub"));
            Assert.AreEqual("https://example.com", GetClaim<string>(jwt, "iss"));
            Assert.AreEqual("my-api", GetClaim<string>(jwt, "aud"));
            
            // Should expire in about 60 minutes
            var exp = GetExpirationUtc(jwt);
            Assert.IsNotNull(exp);
            Assert.IsTrue(exp > DateTime.UtcNow.AddMinutes(55));
            Assert.IsTrue(exp < DateTime.UtcNow.AddMinutes(65));
        }

        [TestMethod]
        public void CreateJwt_WithExpiredTime_CreatesExpiredToken()
        {
            var payload = new JwtPayload
            {
                Subject = "user123",
                ExpiresAt = DateTime.UtcNow.AddMinutes(-10) // 10 minutes ago
            };

            string jwt = CreateJwt(payload, TestSecretKey);

            Assert.IsTrue(IsExpired(jwt));
            Assert.IsFalse(IsValidNow(jwt));
        }

        [TestMethod]
        public void CreateJwt_WithNullPayload_ThrowsException()
        {
            try
            {
                CreateJwt(null, TestSecretKey);
                Assert.Fail("Expected ArgumentNullException");
            }
            catch (ArgumentNullException)
            {
                // Expected
            }
        }

        [TestMethod]
        public void CreateJwt_WithNullSecretKey_ThrowsException()
        {
            var payload = new JwtPayload { Subject = "test" };

            try
            {
                CreateJwt(payload, null);
                Assert.Fail("Expected ArgumentNullException");
            }
            catch (ArgumentNullException)
            {
                // Expected
            }

            try
            {
                CreateJwt(payload, "");
                Assert.Fail("Expected ArgumentNullException");
            }
            catch (ArgumentNullException)
            {
                // Expected
            }

            try
            {
                CreateJwt(payload, "   ");
                Assert.Fail("Expected ArgumentNullException");
            }
            catch (ArgumentNullException)
            {
                // Expected
            }
        }

        [TestMethod]
        public void CreateJwt_WithUnsupportedAlgorithm_ThrowsException()
        {
            var payload = new JwtPayload { Subject = "test" };

            try
            {
                CreateJwt(payload, TestSecretKey, "RS256");
                Assert.Fail("Expected ArgumentException");
            }
            catch (ArgumentException)
            {
                // Expected
            }

            try
            {
                CreateJwt(payload, TestSecretKey, "ES256");
                Assert.Fail("Expected ArgumentException");
            }
            catch (ArgumentException)
            {
                // Expected
            }
        }

        [TestMethod]
        public void CreateJwt_WithHS256Algorithm_CreatesValidToken()
        {
            var payload = new JwtPayload
            {
                Subject = "user123",
                ExpiresAt = DateTime.UtcNow.AddHours(1)
            };

            string jwt = CreateJwt(payload, TestSecretKey, "HS256");

            Assert.IsNotNull(jwt);
            Assert.AreEqual("HS256", GetAlgorithm(jwt));
            
            var verificationResult = VerifySignature(jwt, TestSecretKey);
            Assert.IsTrue(verificationResult.IsValid);
        }

        [TestMethod]
        public void CreateJwtRS256_WithNullInputs_ThrowsException()
        {
            var payload = new JwtPayload { Subject = "test" };

            try
            {
                CreateJwtRS256(null, TestRsaPrivateKey);
                Assert.Fail("Expected ArgumentNullException");
            }
            catch (ArgumentNullException)
            {
                // Expected
            }

            try
            {
                CreateJwtRS256(payload, null);
                Assert.Fail("Expected ArgumentNullException");
            }
            catch (ArgumentNullException)
            {
                // Expected
            }

            try
            {
                CreateJwtRS256(payload, "");
                Assert.Fail("Expected ArgumentNullException");
            }
            catch (ArgumentNullException)
            {
                // Expected
            }
        }

        [TestMethod]
        public void JwtPayload_DefaultConstructor_InitializesCustomClaims()
        {
            var payload = new JwtPayload();
            
            Assert.IsNotNull(payload.CustomClaims);
            Assert.AreEqual(0, payload.CustomClaims.Count);
        }

        [TestMethod]
        public void CreateJwt_WithEmptyPayload_CreatesMinimalToken()
        {
            var payload = new JwtPayload();

            string jwt = CreateJwt(payload, TestSecretKey);

            Assert.IsNotNull(jwt);
            Assert.AreEqual(3, jwt.Split('.').Length);
            
            // Should only contain the algorithm in header
            Assert.AreEqual("HS256", GetAlgorithm(jwt));
        }

        [TestMethod]
        public void CreateJwt_WithSpecialCharactersInClaims_HandlesCorrectly()
        {
            var payload = new JwtPayload
            {
                Subject = "user with spaces",
                Issuer = "https://example.com/path?param=value"
            };
            payload.CustomClaims["message"] = "Hello \"World\" with\nnewlines\tand\ttabs";

            string jwt = CreateJwt(payload, TestSecretKey);

            Assert.AreEqual("user with spaces", GetClaim<string>(jwt, "sub"));
            Assert.AreEqual("https://example.com/path?param=value", GetClaim<string>(jwt, "iss"));
            Assert.AreEqual("Hello \"World\" with\nnewlines\tand\ttabs", GetClaim<string>(jwt, "message"));
        }

        [TestMethod]
        public void CreateJwt_WithArrayCustomClaim_HandlesCorrectly()
        {
            var payload = new JwtPayload
            {
                Subject = "user123"
            };
            payload.CustomClaims["roles"] = new[] { "admin", "user", "moderator" };
            payload.CustomClaims["permissions"] = new[] { "read", "write" };

            string jwt = CreateJwt(payload, TestSecretKey);

            var roles = GetClaim<string[]>(jwt, "roles");
            Assert.IsNotNull(roles);
            Assert.AreEqual(3, roles.Length);
            Assert.IsTrue(roles.Contains("admin"));
            Assert.IsTrue(roles.Contains("user"));
            Assert.IsTrue(roles.Contains("moderator"));

            var permissions = GetClaim<string[]>(jwt, "permissions");
            Assert.IsNotNull(permissions);
            Assert.AreEqual(2, permissions.Length);
            Assert.IsTrue(permissions.Contains("read"));
            Assert.IsTrue(permissions.Contains("write"));
        }

        [TestMethod]
        public void CreateJwt_RoundTripTest_MaintainsAllData()
        {
            var originalPayload = new JwtPayload
            {
                Issuer = "https://issuer.example.com",
                Subject = "user123",
                Audiences = new[] { "api1", "api2" },
                ExpiresAt = DateTime.UtcNow.AddHours(1),
                NotBefore = DateTime.UtcNow.AddMinutes(-5),
                IssuedAt = DateTime.UtcNow,
                JwtId = "unique-id-456"
            };
            originalPayload.CustomClaims["role"] = "admin";
            originalPayload.CustomClaims["age"] = 30;
            originalPayload.CustomClaims["active"] = true;

            string jwt = CreateJwt(originalPayload, TestSecretKey);

            // Verify all claims are preserved
            Assert.AreEqual(originalPayload.Issuer, GetClaim<string>(jwt, "iss"));
            Assert.AreEqual(originalPayload.Subject, GetClaim<string>(jwt, "sub"));
            Assert.AreEqual(originalPayload.JwtId, GetClaim<string>(jwt, "jti"));
            Assert.AreEqual("admin", GetClaim<string>(jwt, "role"));
            Assert.AreEqual(30, GetClaim<int>(jwt, "age"));
            Assert.IsTrue(GetClaim<bool>(jwt, "active"));

            var audiences = GetClaim<string[]>(jwt, "aud");
            Assert.AreEqual(2, audiences.Length);
            Assert.IsTrue(audiences.Contains("api1"));
            Assert.IsTrue(audiences.Contains("api2"));

            // Verify timestamps (allow 1 second tolerance)
            var exp = GetExpirationUtc(jwt);
            var nbf = GetNotBeforeUtc(jwt);
            var iat = GetIssuedAtUtc(jwt);
            
            Assert.IsNotNull(exp);
            Assert.IsNotNull(nbf);
            Assert.IsNotNull(iat);
            
            Assert.IsTrue(Math.Abs((exp.Value - originalPayload.ExpiresAt.Value).TotalSeconds) < 1);
            Assert.IsTrue(Math.Abs((nbf.Value - originalPayload.NotBefore.Value).TotalSeconds) < 1);
            Assert.IsTrue(Math.Abs((iat.Value - originalPayload.IssuedAt.Value).TotalSeconds) < 1);
        }
    }
}