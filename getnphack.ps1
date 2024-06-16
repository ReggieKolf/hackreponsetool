# Path to your Node.js project
$projectPath = "E:\workspace\backend"

# Get list of all installed packages
$packages = Get-ChildItem -Path "$projectPath\node_modules" -Directory

# Function to check for obfuscated code
function Check-ObfuscatedCode {
    param (
        [string]$filePath
    )
    $content = Get-Content -Path $filePath -Raw
    if ($content -match 'var _[a-zA-Z0-9]+ = function') {
        Write-Output "Possible obfuscated code detected in $filePath"
    }
}

# Function to check for suspicious scripts in package.json
function Check-SuspiciousScripts {
    param (
        [string]$packageJsonPath
    )
    $packageJson = Get-Content -Path $packageJsonPath | ConvertFrom-Json
    if ($packageJson.scripts.install -or $packageJson.scripts.postinstall) {
        Write-Output "Suspicious install scripts found in $packageJsonPath"
    }
}

# Function to check for unexpected network requests
function Check-NetworkRequests {
    param (
        [string]$filePath
    )
    $content = Get-Content -Path $filePath -Raw
    if ($content -match 'http\.get\(' -or $content -match 'http\.request\(') {
        Write-Output "Unexpected network requests detected in $filePath"
    }
}

# Iterate over each package and perform checks
foreach ($package in $packages) {
    $packageJsonPath = "$($package.FullName)\package.json"
    if (Test-Path $packageJsonPath) {
        Check-SuspiciousScripts -packageJsonPath $packageJsonPath
    }

    $jsFiles = Get-ChildItem -Path $package.FullName -Recurse -Include *.js
    foreach ($jsFile in $jsFiles) {
        Check-ObfuscatedCode -filePath $jsFile.FullName
        Check-NetworkRequests -filePath $jsFile.FullName
    }
}

Write-Output "Scan completed."
