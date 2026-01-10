# Remove Company References - ValidateJWT Cleanup Script
# Removes all references to Diebold Nixdorf, MTR, and TPDotnet from the solution

param(
    [Parameter(Mandatory=$false)]
    [switch]$Preview,
    
    [Parameter(Mandatory=$false)]
    [switch]$ArchiveOnly
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ValidateJWT - Remove Company References" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = $PSScriptRoot
if (-not $projectRoot) {
    $projectRoot = Get-Location
}

Set-Location $projectRoot

# Terms to search for
$companyTerms = @(
    "Diebold",
    "Nixdorf",
    "Diebold Nixdorf",
    "MTR",
    "TPDotnet",
    "TPDotNet",
    "TechServices",
    "payment terminal",
    "POIID",
    "TerminalIP"
)

Write-Host "Searching for company-specific references..." -ForegroundColor Cyan
Write-Host ""

# Function to search files
function Search-CompanyReferences {
    param([string]$path)
    
    $results = @()
    $files = Get-ChildItem -Path $path -Recurse -File -Include "*.cs","*.md","*.txt","*.config","*.csproj","*.sln","*.ps1","*.bat" -ErrorAction SilentlyContinue
    
    foreach ($file in $files) {
        # Skip certain directories
        if ($file.FullName -match "\\(bin|obj|packages|\.git|\.vs)\\") {
            continue
        }
        
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if (-not $content) { continue }
        
        foreach ($term in $companyTerms) {
            if ($content -match $term) {
                $results += @{
                    File = $file.FullName.Replace($projectRoot, ".")
                    Term = $term
                    Type = $file.Extension
                }
            }
        }
    }
    
    return $results
}

$references = Search-CompanyReferences -path $projectRoot

if ($references.Count -eq 0) {
    Write-Host "? No company references found!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your solution is clean and ready for public release." -ForegroundColor White
    exit 0
}

Write-Host "Found $($references.Count) files with company references:" -ForegroundColor Yellow
Write-Host ""

# Group by file
$groupedRefs = $references | Group-Object -Property File

foreach ($group in $groupedRefs) {
    $fileName = $group.Name
    $terms = ($group.Group | ForEach-Object { $_.Term }) | Select-Object -Unique
    
    Write-Host "  $fileName" -ForegroundColor White
    Write-Host "    Terms: $($terms -join ', ')" -ForegroundColor Gray
}

Write-Host ""

if ($Preview) {
    Write-Host "Preview mode - no changes made." -ForegroundColor Yellow
    exit 0
}

# Ask for confirmation
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Recommended Actions" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Most references are in Archive folder (historical documentation)." -ForegroundColor White
Write-Host ""
Write-Host "Options:" -ForegroundColor Cyan
Write-Host "  1. Keep Archive folder (history preserved, not in active code)" -ForegroundColor White
Write-Host "  2. Delete Archive folder completely" -ForegroundColor White
Write-Host "  3. Clean specific files only" -ForegroundColor White
Write-Host ""

if ($ArchiveOnly) {
    Write-Host "Archive-only mode: Will only remove Archive folder." -ForegroundColor Yellow
    $choice = "2"
} else {
    $choice = Read-Host "Enter choice (1/2/3)"
}

Write-Host ""

switch ($choice) {
    "1" {
        Write-Host "Keeping Archive folder..." -ForegroundColor Green
        Write-Host ""
        Write-Host "Checking active files only..." -ForegroundColor Cyan
        
        # Check non-archived files
        $activeRefs = $references | Where-Object { $_.File -notmatch "\\Archive\\" }
        
        if ($activeRefs.Count -eq 0) {
            Write-Host "? No company references in active code!" -ForegroundColor Green
            Write-Host ""
            Write-Host "All references are in archived documentation." -ForegroundColor White
            Write-Host "Your active solution is clean." -ForegroundColor White
        } else {
            Write-Host "? Found $($activeRefs.Count) references in active files:" -ForegroundColor Yellow
            $activeRefs | ForEach-Object { Write-Host "  $($_.File)" -ForegroundColor White }
            Write-Host ""
            Write-Host "Review these files manually and remove company references." -ForegroundColor Yellow
        }
    }
    
    "2" {
        Write-Host "Removing Archive folder..." -ForegroundColor Yellow
        
        if (Test-Path "Archive") {
            $archiveSize = (Get-ChildItem -Path Archive -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1KB
            Write-Host "  Archive folder size: $([math]::Round($archiveSize, 2)) KB" -ForegroundColor Gray
            
            $confirm = Read-Host "Confirm deletion of Archive folder? (Y/N)"
            if ($confirm -eq 'Y' -or $confirm -eq 'y') {
                Remove-Item -Path Archive -Recurse -Force
                Write-Host "  ? Archive folder deleted" -ForegroundColor Green
                
                # Check remaining references
                $remaining = Search-CompanyReferences -path $projectRoot
                
                if ($remaining.Count -eq 0) {
                    Write-Host ""
                    Write-Host "? All company references removed!" -ForegroundColor Green
                } else {
                    Write-Host ""
                    Write-Host "? Found $($remaining.Count) remaining references:" -ForegroundColor Yellow
                    $remaining | ForEach-Object { Write-Host "  $($_.File)" -ForegroundColor White }
                }
            } else {
                Write-Host "  Deletion cancelled." -ForegroundColor Yellow
            }
        } else {
            Write-Host "  Archive folder not found." -ForegroundColor Yellow
        }
    }
    
    "3" {
        Write-Host "Manual cleanup mode..." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Files requiring cleanup:" -ForegroundColor Cyan
        
        foreach ($group in $groupedRefs) {
            Write-Host ""
            Write-Host "  $($group.Name)" -ForegroundColor White
            Write-Host "  Terms found: $($($group.Group | ForEach-Object { $_.Term }) | Select-Object -Unique -join ', ')" -ForegroundColor Gray
            Write-Host ""
        }
        
        Write-Host "Please review and clean these files manually." -ForegroundColor Yellow
        Write-Host "Search for terms: $($companyTerms -join ', ')" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Cleanup Summary" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Final check
$finalCheck = Search-CompanyReferences -path $projectRoot

if ($finalCheck.Count -eq 0) {
    Write-Host "? Solution is clean!" -ForegroundColor Green
    Write-Host ""
    Write-Host "No company references found in:" -ForegroundColor White
    Write-Host "  - Source code" -ForegroundColor Gray
    Write-Host "  - Project files" -ForegroundColor Gray
    Write-Host "  - Documentation" -ForegroundColor Gray
    Write-Host "  - Scripts" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Your project is ready for public release." -ForegroundColor Green
} else {
    Write-Host "Files with company references:" -ForegroundColor Yellow
    $finalCheck | Group-Object -Property File | ForEach-Object {
        Write-Host "  $($_.Name)" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "Total: $($finalCheck.Count) references in $(($finalCheck | Group-Object -Property File).Count) files" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Review README.md - ensure it's generic" -ForegroundColor White
Write-Host "  2. Check AssemblyInfo.cs - verify company name" -ForegroundColor White
Write-Host "  3. Review namespaces - ensure they're appropriate" -ForegroundColor White
Write-Host "  4. Check App.config - remove company-specific settings" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to exit"
