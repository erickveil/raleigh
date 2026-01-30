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

    # Run if requested
    if ($Run) {
        Write-Header "Launching application"
        flutter run -d windows
    }

    Write-Host "`n✓ Build successful!" -ForegroundColor Green
} catch {
    Write-Error $_
    exit 1
}
