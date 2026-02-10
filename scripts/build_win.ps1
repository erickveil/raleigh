# Raleigh - Windows Build Script
# This script handles all build steps needed to prepare the app for Windows
# Usage: .\scripts\build_win.ps1

param(
    [switch]$Run = $false,  # Pass -Run to also launch the app
    [switch]$Clean = $false # Pass -Clean to clean build artifacts first
)

# Color output for better readability
function Write-Header {
    param([string]$Message)
    Write-Host "`n=== $Message ===" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

Write-Host "Raleigh - Windows Build Script" -ForegroundColor Yellow

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Push-Location $repoRoot

try {
    # Clean if requested
    if ($Clean) {
        Write-Header "Cleaning build artifacts"
        flutter clean
        if ($LASTEXITCODE -ne 0) { throw "Flutter clean failed" }
        Write-Success "Cleaned build artifacts"
    }

    # Get dependencies
    Write-Header "Installing dependencies"
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw "Flutter pub get failed" }
    Write-Success "Dependencies installed"

    # Generate code (Hive adapters, etc.)
    Write-Header "Generating code"
    dart run build_runner build
    if ($LASTEXITCODE -ne 0) { throw "Build runner failed" }
    Write-Success "Code generation complete"

    # Build Windows app
    Write-Header "Building Windows application"
    flutter build windows
    if ($LASTEXITCODE -ne 0) { throw "Flutter build failed" }
    Write-Success "Windows build complete"

    # Extract version from pubspec.yaml
    Write-Header "Preparing deployment package"
    $pubspecContent = Get-Content -Path "pubspec.yaml" -Raw
    if ($pubspecContent -match 'version:\s+([^\s+]+)') {
        $version = $matches[1]
        Write-Success "Version extracted: $version"
    } else {
        throw "Could not extract version from pubspec.yaml"
    }

    # Create deploy directory if it doesn't exist
    $deployDir = Join-Path (Split-Path $PSCommandPath -Parent) "deploy"
    if (-not (Test-Path $deployDir)) {
        New-Item -ItemType Directory -Path $deployDir | Out-Null
        Write-Success "Created deploy directory"
    }

    # Prepare zip package
    $buildOutput = "build\windows\x64\runner\Release"
    $tempDir = Join-Path $env:TEMP "raleigh_build_$([System.Guid]::NewGuid())"
    $appDir = Join-Path $tempDir "raleigh"
    
    # Copy built app to temp directory
    Copy-Item -Path $buildOutput -Destination $appDir -Recurse -Force
    Write-Success "Copied application files"

    # Create zip file
    $zipName = "raleigh-$version.zip"
    $zipPath = Join-Path $deployDir $zipName
    
    # Remove existing zip if it exists
    if (Test-Path $zipPath) {
        Remove-Item $zipPath -Force
    }

    # Compress the app directory
    Compress-Archive -Path $appDir -DestinationPath $zipPath -Force
    Write-Success "Created deployment package: $zipName"

    # Cleanup temp directory
    Remove-Item $tempDir -Recurse -Force
    Write-Success "Cleaned up temporary files"

    # Run if requested
    if ($Run) {
        Write-Header "Launching application"
        flutter run -d windows
    }

    Write-Host "`n✓ Build successful!" -ForegroundColor Green
    Write-Host "Deploy package available at: $zipPath" -ForegroundColor Cyan
} catch {
    Write-Error $_
    exit 1
} finally {
    Pop-Location
}
