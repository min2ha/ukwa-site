#!/bin/bash

# Initialize Git submodules for Hugo themes
# This must be run before building the Docker images

set -e

echo "================================"
echo "Initializing Hugo Themes"
echo "================================"
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Initialize and update submodules
echo "Initializing Git submodules..."
git submodule init

echo "Updating Git submodules..."
git submodule update --recursive

# Verify themes were downloaded
if [ -d "themes/hugo-bootstrap/.git" ] && [ -d "themes/hugo-bootstrap-5/.git" ]; then
    echo ""
    echo "✓ Themes initialized successfully!"
    echo ""
    echo "Themes available:"
    ls -1 themes/
    echo ""
else
    echo ""
    echo "⚠ Warning: Some themes may not have been initialized properly"
    echo ""
    echo "Themes directory contents:"
    ls -la themes/
    echo ""
fi

echo "================================"
echo "Ready to build!"
echo "================================"
echo ""
echo "You can now run:"
echo "  ./start-cms-local.sh"
echo ""
