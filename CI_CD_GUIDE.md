# ?? CI/CD Pipeline and Automated Testing

## ?? Overview

Complete CI/CD pipeline with automated testing, code coverage, and deployment to NuGet.org.

---

## ?? GitHub Actions Workflows

### 1. **Main CI/CD Pipeline** (`ci-cd.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Release published

**Jobs:**
1. ? **Build and Test** - Builds solution and runs all tests
2. ?? **Code Quality** - Runs code analysis and checks for warnings
3. ?? **Security Scan** - Scans for security vulnerabilities
4. ?? **Build NuGet** - Creates NuGet package
5. ?? **Publish NuGet** - Publishes to NuGet.org (release only)
6. ?? **GitHub Release** - Uploads release assets
7. ?? **Update Docs** - Updates documentation badges

---

### 2. **Pull Request Validation** (`pr-validation.yml`)

**Triggers:**
- Pull request opened, synchronized, or reopened

**Actions:**
- ? Builds solution
- ? Runs all tests
- ? Comments on PR with test results
- ? Blocks merge if tests fail

---

### 3. **Nightly Build** (`nightly-build.yml`)

**Triggers:**
- Scheduled: Every day at 2 AM UTC
- Manual: workflow_dispatch

**Actions:**
- ? Builds Debug and Release configurations
- ? Runs comprehensive test suite
- ? Archives test results (30 days retention)
- ? Creates GitHub issue if build fails

---

### 4. **Code Coverage** (`code-coverage.yml`)

**Triggers:**
- Push to `main`
- Pull requests to `main`

**Actions:**
- ? Collects code coverage metrics
- ? Uploads to Codecov
- ? Generates HTML coverage report
- ? Archives coverage report

---

## ?? Workflow Files

```
.github/
??? workflows/
    ??? ci-cd.yml              # Main CI/CD pipeline
    ??? pr-validation.yml      # PR checks
    ??? nightly-build.yml      # Scheduled builds
    ??? code-coverage.yml      # Coverage analysis
```

---

## ?? Local Automated Testing

### Run All Tests

```powershell
# Basic test run
.\Run-AutomatedTests.ps1

# With code coverage
.\Run-AutomatedTests.ps1 -GenerateCoverage

# Open coverage report
.\Run-AutomatedTests.ps1 -GenerateCoverage -OpenReport

# Release configuration
.\Run-AutomatedTests.ps1 -Configuration Release
```

### What It Does

1. ? Checks prerequisites (MSBuild, VSTest, NuGet)
2. ? Cleans previous results
3. ? Restores NuGet packages
4. ? Builds solution
5. ? Runs all 58+ tests
6. ? Generates test results (TRX format)
7. ? (Optional) Generates code coverage report
8. ? Displays summary with pass/fail counts

---

## ?? Secrets Configuration

### Required GitHub Secrets

| Secret | Purpose | Required For |
|--------|---------|--------------|
| `NUGET_API_KEY` | NuGet.org API key | Publishing packages |
| `CODECOV_TOKEN` | Codecov upload token | Coverage reporting |

### How to Add Secrets

1. Go to repository **Settings** ? **Secrets and variables** ? **Actions**
2. Click **New repository secret**
3. Add:
   - Name: `NUGET_API_KEY`
   - Value: Your NuGet API key from https://www.nuget.org/account/apikeys
4. Repeat for other secrets

---

## ?? Test Results

### Automated Test Execution

**Test Suite:**
- 58+ unit tests
- ~100% API coverage
- All public methods tested

**Test Categories:**
- Time validation (30 tests)
- Signature verification (ready)
- Base64URL encoding (18 tests)
- Error handling (comprehensive)

### Expected Results

```
============================================================
  Test Results Summary
============================================================

Total Tests:    58
Passed:         58
Failed:         0
Skipped:        0
Duration:       1.8s

Result:         ? SUCCESS
```

---

## ?? Code Coverage

### Coverage Metrics

| Component | Target | Status |
|-----------|--------|--------|
| IsExpired() | 100% | ? |
| IsValidNow() | 100% | ? |
| GetExpirationUtc() | 100% | ? |
| Base64UrlDecode() | 100% | ? |
| VerifySignature() | 100% | ? |
| VerifySignatureRS256() | 100% | ? |
| **Overall** | **>95%** | ? |

### Generate Coverage Report

```powershell
# Local coverage
.\Run-AutomatedTests.ps1 -GenerateCoverage

# View report
start CoverageReport\index.html
```

### CI Coverage

Coverage automatically uploaded to:
- Codecov.io (with badge)
- GitHub Actions artifacts
- Stored for 30 days

---

## ?? Deployment Process

### Automatic Deployment (Recommended)

**1. Create a Release on GitHub:**

```bash
# Create tag
git tag -a v1.1.0 -m "Release v1.1.0"
git push origin v1.1.0

# Create release on GitHub
# Go to: https://github.com/your-repo/releases/new
# Select tag: v1.1.0
# Publish release
```

**2. CI/CD Automatically:**
- ? Builds the project
- ? Runs all tests
- ? Creates NuGet package
- ? Publishes to NuGet.org
- ? Uploads release assets
- ? Updates documentation

### Manual Deployment

```powershell
# Build and test
.\Run-AutomatedTests.ps1 -Configuration Release

# Create package
nuget pack ValidateJWT.nuspec

# Publish
nuget push ValidateJWT.1.1.0.nupkg -Source https://api.nuget.org/v3/index.json -ApiKey YOUR_KEY
```

---

## ?? Badge Integration

### Add to README.md

```markdown
![Build Status](https://github.com/johanhenningsson4-hash/ValidateJWT/workflows/CI%2FCD%20Pipeline/badge.svg)
![Tests](https://img.shields.io/github/workflow/status/johanhenningsson4-hash/ValidateJWT/CI%2FCD%20Pipeline)
![Coverage](https://codecov.io/gh/johanhenningsson4-hash/ValidateJWT/branch/main/graph/badge.svg)
![NuGet](https://img.shields.io/nuget/v/ValidateJWT.svg)
![Downloads](https://img.shields.io/nuget/dt/ValidateJWT.svg)
```

---

## ?? Monitoring and Notifications

### Build Status

- ? Green checkmark = All tests passed
- ? Red X = Build or tests failed
- ?? Yellow dot = Build in progress

### Notifications

**Automatic notifications for:**
- Failed builds (GitHub issue created)
- PR test results (comment on PR)
- Release completion
- Coverage changes

### View Status

**GitHub Actions:**
```
https://github.com/johanhenningsson4-hash/ValidateJWT/actions
```

**Test Results:**
- Click on any workflow run
- Navigate to "Build and Test" job
- View test summary and logs

---

## ??? Troubleshooting

### Build Fails in CI

**Check:**
1. View workflow logs in GitHub Actions
2. Look for specific error messages
3. Reproduce locally:
   ```powershell
   .\Run-AutomatedTests.ps1
   ```

### Tests Fail in CI but Pass Locally

**Common causes:**
- Time-zone differences
- Missing dependencies
- Configuration differences

**Solution:**
```yaml
# Add to workflow
env:
  TZ: UTC
```

### NuGet Publish Fails

**Check:**
1. API key is valid and not expired
2. Secret `NUGET_API_KEY` is set correctly
3. Package version doesn't already exist
4. Package passes validation

### Coverage Not Uploading

**Ensure:**
1. `CODECOV_TOKEN` secret is set
2. Coverage file is generated
3. Codecov service is accessible

---

## ?? Documentation Files

| File | Purpose |
|------|---------|
| `.github/workflows/ci-cd.yml` | Main CI/CD pipeline |
| `.github/workflows/pr-validation.yml` | PR validation |
| `.github/workflows/nightly-build.yml` | Scheduled builds |
| `.github/workflows/code-coverage.yml` | Coverage analysis |
| `Run-AutomatedTests.ps1` | Local test automation |
| `CI_CD_GUIDE.md` | This file |

---

## ?? Best Practices

### Commit Messages

Use conventional commits:
```
feat: Add new signature verification method
fix: Resolve token parsing issue
docs: Update README with new features
test: Add tests for ES256 algorithm
ci: Update deployment workflow
```

### Branch Strategy

```
main         - Production releases
develop      - Integration branch
feature/*    - New features
bugfix/*     - Bug fixes
release/*    - Release preparation
```

### Testing Strategy

1. **Unit Tests** - Test individual methods
2. **Integration Tests** - Test component interactions
3. **Coverage** - Maintain >95% coverage
4. **PR Validation** - All tests must pass before merge

---

## ? Checklist for New Features

Before merging:

- [ ] All tests pass locally
- [ ] Code coverage >95%
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] PR validation passes
- [ ] Code reviewed
- [ ] No security vulnerabilities

---

## ?? Workflow Diagram

```
???????????????????
?  Push to main   ?
???????????????????
         ?
         ?
???????????????????
?  Build & Test   ? ??????? Fail ??? Create Issue
???????????????????
         ? Pass
         ?
???????????????????
?  Code Quality   ?
???????????????????
         ?
         ?
???????????????????
? Build NuGet Pkg ?
???????????????????
         ?
         ?
     [Release?]
         ?
    Yes  ?  No
         ?
???????????????????
? Publish NuGet   ?
???????????????????
         ?
         ?
???????????????????
? Upload Assets   ?
???????????????????
```

---

## ?? Support

**Issues:**
- GitHub Issues: https://github.com/johanhenningsson4-hash/ValidateJWT/issues
- Workflow logs: GitHub Actions tab

**Documentation:**
- This guide
- README.md
- Workflow files (inline comments)

---

## ?? Summary

**Your CI/CD pipeline includes:**

? Automated building on every push  
? Comprehensive test execution  
? Code coverage reporting  
? Security scanning  
? Automated NuGet publishing  
? PR validation  
? Nightly builds  
? Release automation  

**All tests run automatically - zero manual intervention required!** ??

---

*CI/CD Pipeline Guide - ValidateJWT v1.1.0*  
*Last Updated: January 2026*
