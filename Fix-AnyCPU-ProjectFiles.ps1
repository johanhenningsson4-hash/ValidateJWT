# Fix-AnyCPU-ProjectFiles.ps1
# This script removes all 'Any CPU' (with space) PropertyGroups from .csproj files and keeps only 'AnyCPU' (no space).

$projectFiles = Get-ChildItem -Path . -Recurse -Filter *.csproj

foreach ($file in $projectFiles) {
    Write-Host "Processing $($file.FullName)..."
    $content = Get-Content $file.FullName

    # Remove PropertyGroups for 'Any CPU' (with space)
    $content = $content -replace '<PropertyGroup Condition="[^"]*Any CPU[^"]*">(.|\n)*?</PropertyGroup>', ''

    # Save the cleaned file
    Set-Content $file.FullName $content
}

Write-Host "All .csproj files have been updated to use only 'AnyCPU' platform."