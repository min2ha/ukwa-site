#!/bin/bash

# UKWA Decap CMS Local Development Startup Script
# This script starts all services needed for local CMS development

set -e

echo "================================"
echo "UKWA Decap CMS Local Environment"
echo "================================"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if docker compose is available
if ! command -v docker compose &> /dev/null; then
    echo "Error: docker compose is not installed. Please install it and try again."
    exit 1
fi

# Check if themes are initialized (Git submodules)
if [ ! -f "themes/hugo-bootstrap/.git" ] && [ ! -d "themes/hugo-bootstrap/.git" ]; then
    echo "⚠️  Warning: Hugo themes (Git submodules) are not initialized."
    echo ""
    echo "Initializing themes now..."
    ./init-themes.sh
    echo ""
fi

echo "Starting services..."
echo ""

# Start all services
docker compose -f docker-compose-integrated.cms.yml up -d

echo ""
echo "Services started successfully!"
echo ""
echo "================================"
echo "Access Points:"
echo "================================"
echo ""
echo "1. Hugo Site (Production build): http://localhost:1080"
echo "2. Hugo Dev Server (Live reload): http://localhost:1313"
echo "3. Decap CMS Admin Interface: http://localhost:1313/admin/"
echo "4. Git Gateway Proxy: http://localhost:8081"
echo "5. Auth Proxy (User Info): http://localhost:8082"
echo ""
echo "================================"
echo "Test Users:"
echo "================================"
echo ""
echo "Supervisor (Full Access):"
echo "  - Email: supervisor@ukwa-local.test"
echo "  - Role: Admin - Can publish, approve, manage users"
echo ""
echo "Editor (Content Creator):"
echo "  - Email: editor@ukwa-local.test"
echo "  - Role: Editor - Can create/edit, cannot publish"
echo ""
echo "Viewer (Read-Only):"
echo "  - Email: viewer@ukwa-local.test"
echo "  - Role: Viewer - Can only view content"
echo ""
echo "================================"
echo "Next Steps:"
echo "================================"
echo ""
echo "1. Open http://localhost:1313/admin/ in your browser"
echo "2. When using local_backend, you'll work directly with local files"
echo "3. Changes are saved to your local repository"
echo "4. Use 'docker-compose -f docker-compose-integrated.cms.yml logs -f' to view logs"
echo "5. Use './stop-cms-local.sh' to stop all services"
echo ""
echo "For production Git Gateway setup, see docs/DEVOPS_GUIDE.md"
echo ""
