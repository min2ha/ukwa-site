#!/bin/bash

# Stop UKWA Decap CMS Local Development Environment

set -e

echo "Stopping UKWA Decap CMS services..."

docker compose -f docker-compose-integrated.cms.yml down

echo ""
echo "All services stopped successfully!"
echo ""
