# ─────────────────────────────────────────────────────────────────────────────
# setup-hooks.ps1  –  one-time setup for every developer on Windows
#
# Usage (run once after cloning):
#   .\setup-hooks.ps1
# ─────────────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "Setting up Git hooks for Mind Print..." -ForegroundColor Cyan

# Point Git to the tracked hooks/ folder
git config core.hooksPath hooks

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to configure core.hooksPath." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Git hooks are now active:" -ForegroundColor Green
Write-Host "  pre-commit  ->  dart format check  +  flutter analyze" -ForegroundColor Gray
Write-Host "  pre-push    ->  flutter test" -ForegroundColor Gray
Write-Host ""
Write-Host "Done! Hooks will run automatically on each commit / push." -ForegroundColor Green
Write-Host ""
