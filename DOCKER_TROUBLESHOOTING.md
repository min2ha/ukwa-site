# Docker Build Troubleshooting Guide

## Common Docker Errors and Solutions

---

## Error: "ONBUILD RUN if [ -e ".hugo-onbuild.sh" ]..." Build Failure

### Symptoms
```
ERROR [hugo 4/10] ONBUILD RUN if [ -e ".hugo-onbuild.sh" ]; then exec sh .hugo-onbuild.sh; else exec hugo $HUGO_CMD; fi
```

### Root Cause
The original `Dockerfile` uses an ONBUILD image (`klakegg/hugo:0.101.0-ext-onbuild`) which:
1. Expects Hugo themes to be present
2. Themes are Git submodules that weren't initialized
3. Build fails because themes directory is empty or incomplete

### Solution

#### Quick Fix (Recommended)
```bash
# 1. Initialize Git submodules (themes)
./init-themes.sh

# 2. Start the CMS environment
./start-cms-local.sh
```

The `start-cms-local.sh` script now automatically checks for themes and initializes them if needed.

#### Manual Fix
If the automatic fix doesn't work:

```bash
# 1. Initialize submodules manually
git submodule init
git submodule update --recursive

# 2. Verify themes are present
ls -la themes/hugo-bootstrap/
ls -la themes/hugo-bootstrap-5/

# 3. Start services
./start-cms-local.sh
```

---

## Alternative: Use the Fixed Dockerfile

The project now includes `Dockerfile.fixed` which:
- ✅ Doesn't rely on ONBUILD
- ✅ Explicitly copies themes
- ✅ Uses Hugo 0.111.3 (newer version)
- ✅ Includes health checks

The `docker-compose-integrated.cms.yml` has been updated to use this Dockerfile automatically.

---

## Understanding the Setup

### Theme Initialization

The UKWA site uses Hugo themes as Git submodules:
- `themes/hugo-bootstrap` - From https://github.com/Xzya/hugo-bootstrap.git
- `themes/hugo-bootstrap-5` - From https://github.com/NotWoods/hugo-bootstrap-5.git

**Why Git Submodules?**
- Keeps themes separate from main codebase
- Allows easy theme updates
- Maintains theme version control

**When to Initialize:**
- First time cloning the repository
- After `git clone` without `--recursive` flag
- When themes directory is empty

---

## Docker Compose Services

The `docker-compose-integrated.cms.yml` includes 4 services:

### 1. **site** (Port 1080)
- **Purpose:** Production build of Hugo site
- **Build:** Uses `Dockerfile.fixed`
- **Issue:** May fail if themes not initialized
- **Solution:** Run `./init-themes.sh` first

### 2. **hugo-dev** (Port 1313) ⭐ Primary for CMS
- **Purpose:** Hugo development server with live reload
- **Image:** `klakegg/hugo:0.111.3-ext-alpine`
- **Advantage:** Doesn't need building, mounts source directly
- **Use this for:** CMS development work

### 3. **git-gateway** (Port 8081)
- **Purpose:** Decap Server for local Git operations
- **Issue:** May take time to install on first run
- **Solution:** Wait for npm install to complete (~30 seconds)

### 4. **auth-proxy** (Port 8082)
- **Purpose:** Serves user configuration files
- **Issue:** Rarely fails
- **Solution:** Check `cms-config/nginx.conf` exists

---

## Quick Troubleshooting

### Issue: Build fails with theme error
```bash
# Solution
./init-themes.sh
```

### Issue: Can't access CMS at localhost:1313/admin/
```bash
# Check if hugo-dev is running
docker ps | grep hugo-dev

# If not running, check logs
docker compose -f docker-compose-integrated.cms.yml logs hugo-dev

# Restart hugo-dev only
docker compose -f docker-compose-integrated.cms.yml restart hugo-dev
```

### Issue: Port 1313 already in use
```bash
# Find what's using the port
lsof -i :1313

# Kill the process or stop Hugo if running separately
pkill hugo

# Or change port in docker-compose-integrated.cms.yml:
# Change "1313:1313" to "1314:1313"
```

### Issue: Git Gateway not starting
```bash
# Check logs
docker compose -f docker-compose-integrated.cms.yml logs git-gateway

# Common: npm install is still running (wait 30 seconds)
# Or restart the service
docker compose -f docker-compose-integrated.cms.yml restart git-gateway
```

### Issue: Docker says "no such file or directory"
```bash
# Make sure you're in the project root
pwd
# Should end with: ukwa-site-original

# If not, navigate there
cd /path/to/ukwa-site-original
```

---

## Complete Rebuild

If everything is broken, do a clean rebuild:

```bash
# 1. Stop all services
./stop-cms-local.sh

# 2. Remove containers and images
docker compose -f docker-compose-integrated.cms.yml down --rmi local

# 3. Initialize themes
./init-themes.sh

# 4. Start fresh
./start-cms-local.sh
```

---

## For Development: Use hugo-dev Service Only

The **hugo-dev** service (port 1313) is the primary service for CMS work:
- ✅ No building required
- ✅ Live reload
- ✅ Mounts source code directly
- ✅ Works even without themes initialized (Hugo will warn but continue)

**To use hugo-dev without building site:**

```bash
# Start only the services needed for CMS
docker compose -f docker-compose-integrated.cms.yml up -d hugo-dev git-gateway auth-proxy

# Access CMS
open http://localhost:1313/admin/
```

This skips the **site** service which requires themes to be built.

---

## Verify Everything Works

Run this checklist:

```bash
# 1. Themes initialized?
ls themes/hugo-bootstrap/.git
# Should show: .git file or directory

# 2. Docker running?
docker ps
# Should show multiple containers

# 3. Hugo dev accessible?
curl -I http://localhost:1313
# Should return: HTTP/1.1 200 OK

# 4. CMS admin accessible?
curl -I http://localhost:1313/admin/
# Should return: HTTP/1.1 200 OK

# 5. Git Gateway running?
curl http://localhost:8081
# Should return something (not connection refused)
```

---

## Still Having Issues?

### Check Service Logs
```bash
# All services
docker compose -f docker-compose-integrated.cms.yml logs

# Specific service
docker compose -f docker-compose-integrated.cms.yml logs hugo-dev
docker compose -f docker-compose-integrated.cms.yml logs git-gateway
docker compose -f docker-compose-integrated.cms.yml logs site
```

### View Running Containers
```bash
docker ps -a | grep ukwa-site-original
```

### Check Container Resource Usage
```bash
docker stats
```

### Force Restart Everything
```bash
docker compose -f docker-compose-integrated.cms.yml restart
```

---

## Prevention Tips

### ✅ Do's
1. ✅ Always run `./init-themes.sh` after fresh clone
2. ✅ Use `hugo-dev` service (port 1313) for CMS work
3. ✅ Check Docker is running before starting services
4. ✅ Wait for npm install to complete in git-gateway (~30s)
5. ✅ Use `./stop-cms-local.sh` to cleanly stop services

### ❌ Don'ts
1. ❌ Don't delete themes directory manually
2. ❌ Don't run `git submodule deinit` unless intentional
3. ❌ Don't modify Dockerfile without understanding implications
4. ❌ Don't force kill Docker containers (use stop script)
5. ❌ Don't build site service if you only need CMS

---

## Docker Compose Commands Reference

```bash
# Start all services (detached)
docker compose -f docker-compose-integrated.cms.yml up -d

# Start specific service
docker compose -f docker-compose-integrated.cms.yml up -d hugo-dev

# Stop all services
docker compose -f docker-compose-integrated.cms.yml down

# View logs (live)
docker compose -f docker-compose-integrated.cms.yml logs -f

# View logs for specific service
docker compose -f docker-compose-integrated.cms.yml logs -f hugo-dev

# Restart service
docker compose -f docker-compose-integrated.cms.yml restart hugo-dev

# Rebuild service
docker compose -f docker-compose-integrated.cms.yml build --no-cache site

# Remove containers and images
docker compose -f docker-compose-integrated.cms.yml down --rmi local

# Remove everything including volumes
docker compose -f docker-compose-integrated.cms.yml down -v --rmi all
```

---

## Environment-Specific Issues

### macOS
- Docker Desktop must be running
- May need to increase Docker memory (Preferences → Resources)
- M1/M2 Macs: Should work with arm64 images

### Linux
- May need `sudo` for Docker commands
- Check user is in `docker` group: `groups $USER`
- Add to group if needed: `sudo usermod -aG docker $USER`

### Windows (WSL2)
- Use WSL2 backend in Docker Desktop
- Navigate to project in WSL filesystem (not /mnt/c/)
- Line endings: ensure scripts use LF not CRLF

---

## Files Created for Docker Fix

- ✅ **Dockerfile.fixed** - New Dockerfile that doesn't use ONBUILD
- ✅ **init-themes.sh** - Script to initialize Git submodules
- ✅ **Updated start-cms-local.sh** - Auto-checks and initializes themes
- ✅ **Updated docker-compose-integrated.cms.yml** - Uses Dockerfile.fixed
- ✅ **This guide** - Troubleshooting documentation

---

## Success Indicators

When everything is working correctly:

```bash
$ ./start-cms-local.sh

================================
UKWA Decap CMS Local Environment
================================

Starting services...

✓ Container ukwa-site-original-hugo-dev-1 Started
✓ Container ukwa-site-original-git-gateway-1 Started
✓ Container ukwa-site-original-auth-proxy-1 Started
✓ Container ukwa-site-original-site-1 Started

Services started successfully!

================================
Access Points:
================================

1. Hugo Site (Production build): http://localhost:1080
2. Hugo Dev Server (Live reload): http://localhost:1313
3. Decap CMS Admin Interface: http://localhost:1313/admin/
...
```

---

## Quick Reference

| Problem | Command |
|---------|---------|
| Initialize themes | `./init-themes.sh` |
| Start services | `./start-cms-local.sh` |
| Stop services | `./stop-cms-local.sh` |
| View logs | `docker compose -f docker-compose-integrated.cms.yml logs -f` |
| Restart Hugo | `docker compose -f docker-compose-integrated.cms.yml restart hugo-dev` |
| Clean rebuild | `./stop-cms-local.sh && docker compose -f docker-compose-integrated.cms.yml down --rmi local && ./start-cms-local.sh` |

---

**Last Updated:** 2025-01-28
**Status:** Fixed ✅

For more help, see:
- [CMS_INTEGRATION_README.md](CMS_INTEGRATION_README.md)
- [docs/DEVOPS_GUIDE.md](docs/DEVOPS_GUIDE.md)
- [TESTING_CHECKLIST.md](TESTING_CHECKLIST.md)
