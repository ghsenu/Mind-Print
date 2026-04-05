#!/bin/sh
# ─────────────────────────────────────────────────────────────────────────────
# setup-hooks.sh  –  one-time setup for every developer on macOS / Linux
#
# Usage (run once after cloning):
#   sh setup-hooks.sh
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo "Setting up Git hooks for Mind Print..."

# Make hook scripts executable
chmod +x hooks/pre-commit
chmod +x hooks/pre-push

# Point Git to the tracked hooks/ folder
git config core.hooksPath hooks

echo ""
echo "Git hooks are now active:"
echo "  pre-commit  ->  dart format check  +  flutter analyze"
echo "  pre-push    ->  flutter test"
echo ""
echo "Done! Hooks will run automatically on each commit / push."
echo ""
