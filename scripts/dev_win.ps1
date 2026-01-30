# Raleigh - Windows Development Script
# Quick setup and run for local development
# Usage: .\scripts\dev_win.ps1

Write-Host "Raleigh - Windows Development Setup" -ForegroundColor Yellow

try {
    Write-Host "`n=== Installing dependencies ===" -ForegroundColor Cyan
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw "Flutter pub get failed" }

    Write-Host "`n=== Generating code ===" -ForegroundColor Cyan
    dart run build_runner build
    if ($LASTEXITCODE -ne 0) { throw "Build runner failed" }

    Write-Host "`n=== Starting development server ===" -ForegroundColor Cyan
    flutter run -d windows

} catch {
    Write-Host "✗ Error: $_" -ForegroundColor Red
    exit 1
}
