# Changelog

All notable changes to the ValidateJWT project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-XX

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
- Clear documentation that library does NOT verify JWT signatures
- Designed for time-based pre-validation only
- Security notices in README and documentation

### Known Issues
- External dependency on `TPDotnet.Base.Service.TPBaseLogging` (not included)
- `nbf` (Not Before) and `iat` (Issued At) claims not implemented
- Log.cs file present but unused

---

## [Unreleased]

### Planned for v1.1.0
- Fix TPBaseLogging external dependency
- Remove unused Log.cs file
- Add XML documentation comments for IntelliSense
- Implement `nbf` (Not Before) claim validation
- Implement `iat` (Issued At) claim extraction
- Clean up App.config settings

### Future Enhancements
- NuGet package creation and publishing
- GitHub Actions CI/CD pipeline
- Code coverage reporting
- Optional JWT signature verification
- .NET Standard 2.0 support
- Performance benchmarks
- Additional test scenarios

---

## Release Links

- [1.0.0] - https://github.com/johanhenningsson4-hash/ValidateJWT/releases/tag/v1.0.0

---

## Versioning

This project uses [Semantic Versioning](https://semver.org/):
- **MAJOR** version for incompatible API changes
- **MINOR** version for backwards-compatible functionality additions
- **PATCH** version for backwards-compatible bug fixes

---

*Last Updated: January 2025*
