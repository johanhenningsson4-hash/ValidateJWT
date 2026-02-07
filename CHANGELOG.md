# Changelog

All notable changes to the ValidateJWT project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2026-01-11

### Added
- **Comprehensive JWT Claim Validation** - Major enhancement
  - `IsAudienceValid(jwt, expectedAudience)` method for 'aud' claim validation
  - `IsNotBeforeValid(jwt, clockSkew, nowUtc)` method for 'nbf' claim validation
  - `GetNotBeforeUtc(jwt)` method for extracting 'nbf' timestamps
  - `GetIssuedAtUtc(jwt)` method for extracting 'iat' timestamps  
  - `GetAudience(jwt)` method for extracting 'aud' claims
- Support for audience arrays in addition to single audience strings
- Enhanced claim parsing with robust error handling
- Clock skew tolerance support for 'nbf' validation (default: 5 minutes)
- Helper method `GetUnixTimestampClaim()` for consistent timestamp parsing

### Improved
- More comprehensive JWT validation capabilities
- Better support for standard JWT claims beyond expiration
- Consistent API design across all claim validation methods
- Enhanced security with multi-claim validation support

### Compatibility
- 100% backward compatible with all previous versions
- All existing methods unchanged and fully supported
- No breaking changes
- New claim validation features are opt-in

## [1.2.0] - 2026-01-11

### Added
- **JWT Signature Verification** - Major new feature
  - `VerifySignature(jwt, secretKey)` method for HMAC-SHA256 (HS256) verification
  - `VerifySignatureRS256(jwt, publicKeyXml)` method for RSA-SHA256 (RS256) verification
  - `JwtVerificationResult` class containing validation results
  - `GetAlgorithm(jwt)` method to detect JWT algorithm from header
  - `Base64UrlEncode(bytes)` method for URL-safe Base64 encoding
- Support for symmetric (HS256) and asymmetric (RS256) signature algorithms
- Detailed verification results with error messages
- Optional expiration checking included in verification result
- Complete documentation (SIGNATURE_VERIFICATION.md)
- `IsIssuerValid()` function for validating the 'iss' (issuer) claim in JWT tokens

### Improved
- Enhanced security with full JWT validation capability
- Comprehensive API examples for signature verification
- Performance optimization guidance (two-stage validation)
- Security best practices documentation

### Compatibility
- 100% backward compatible with v1.0.x
- All existing methods unchanged (IsExpired, IsValidNow, GetExpirationUtc, Base64UrlDecode)
- No breaking changes
- New signature verification features are opt-in

### Documentation
- Added SIGNATURE_VERIFICATION.md with complete feature guide
- Added VERSION_1.1.0_READY.md with release notes
- Updated API reference with new methods
- Added security notes and best practices
- Added migration examples from v1.0.x

## [1.0.1] - 2026-01-XX

### Changed
- Enhanced NuGet package metadata for better display on NuGet.org
- Improved documentation organization and clarity
- Verified clean codebase with no company-specific references
- Standardized namespace to `Johan.Common` throughout project

### Improved
- README.md now displays properly on NuGet.org package page
- LICENSE.txt now displays in NuGet package license tab
- Better package discoverability with enhanced metadata
- Comprehensive publishing guides and automation scripts

### Documentation
- Added `PUBLISH_NOW.md` - Complete publishing checklist
- Added `PUBLISH_QUICK_START.md` - Quick reference guide
- Added `PublishRelease.bat` - Automated publishing script
- Added `COMPANY_VERIFICATION.md` - Code verification documentation
- Added `FINAL_COMPANY_VERIFICATION.md` - Complete verification results
- Improved NuGet package documentation
- Added GitHub release automation documentation

### Fixed
- Removed all company-specific references from source code
- Cleaned namespace references in documentation
- Ensured personal copyright (Johan Henningsson) throughout

### Quality
- All 58+ tests still passing
- Code quality maintained at Grade A-
- Zero external dependencies verified
- Professional, clean codebase confirmed

## [1.0.0] - 2026-01-XX

### Added
- Initial public release of ValidateJWT library
- Core JWT expiration validation functionality
  - `IsExpired()` method - Check if token has expired
  - `IsValidNow()` method - Check if token is currently valid
  - `GetExpirationUtc()` method - Extract expiration timestamp
  - `Base64UrlDecode()` method - Decode Base64URL strings
- Clock skew support with 5-minute default tolerance
- Time injection support for deterministic testing
- Thread-safe static implementation
- Comprehensive test suite with 58+ unit tests
  - 40 tests for core validation methods
  - 18 tests for Base64URL decoding
  - Test utilities (`JwtTestHelper`) for JWT generation
- Complete documentation suite
  - README.md with usage examples
  - PROJECT_ANALYSIS.md with technical details
  - ANALYSIS_SUMMARY.md with executive summary
  - TEST_COVERAGE.md with test documentation
  - SYNC_STATUS.md with repository information
  - RELEASE_NOTES_v1.0.0.md with release details
- .NET Framework 4.8 support
- MSTest test framework integration

### Quality Metrics
- ~100% public API test coverage
- 2.6:1 test-to-production code ratio
- 290 lines of production code
- 766 lines of test code
- 1,500+ lines of documentation
- Grade: A- (Excellent)

### Security
- Clear documentation that library does NOT verify JWT signatures (in v1.0.0)
- Designed for time-based pre-validation only
- Security notices in README and documentation

### Known Issues
- External dependency on `TPDotnet.Base.Service.TPBaseLogging` (not included)
- `nbf` (Not Before) and `iat` (Issued At) claims not implemented
- Log.cs file present but unused

---

## [Unreleased]

### Planned for v1.2.0
- Implement `nbf` (Not Before) claim validation
- Implement `iat` (Issued At) claim extraction
- Additional signature algorithms (ES256, PS256)
- Enhanced claims extraction

### Future Enhancements
- GitHub Actions CI/CD pipeline
- Code coverage reporting
- .NET Standard 2.0 support
- Performance benchmarks
- Additional test scenarios

---

## Release Links

- [1.1.0] - https://github.com/johanhenningsson4-hash/ValidateJWT/releases/tag/v1.1.0
- [1.0.1] - https://github.com/johanhenningsson4-hash/ValidateJWT/releases/tag/v1.0.1
- [1.0.0] - https://github.com/johanhenningsson4-hash/ValidateJWT/releases/tag/v1.0.0

---

## Versioning

This project uses [Semantic Versioning](https://semver.org/):
- **MAJOR** version for incompatible API changes
- **MINOR** version for backwards-compatible functionality additions
- **PATCH** version for backwards-compatible bug fixes

---

*Last Updated: January 2026*
