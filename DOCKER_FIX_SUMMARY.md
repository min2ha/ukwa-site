# Docker Build Error - Fix Summary

## Problem

You encountered this Docker build error:
```
ERROR [hugo 4/10] ONBUILD RUN if [ -e ".hugo-onbuild.sh" ]; then exec sh .hugo-onbuild.sh; else exec hugo $HUGO_CMD; fi
```

## Root Cause

The error occurred because:
1. The original `Dockerfile` uses an ONBUILD image (`klakegg/hugo:0.101.0-ext-onbuild`)
2. Hugo themes are configured as Git submodules and weren't initialized
3. The ONBUILD instructions try to build Hugo without themes, causing failure

## Solution Applied

### Files Created/Modified

1. **Dockerfile.fixed** - New Dockerfile that:
   - Doesn't use ONBUILD
   - Explicitly handles theme copying
   - Uses Hugo 0.111.3 (updated version)
   - Includes health checks

2. **init-themes.sh** - Script to initialize Git submodules:
   ```bash
   ./init-themes.sh
   ```
   This downloads the Hugo themes from Git submodules.

3. **Updated docker-compose-integrated.cms.yml**:
   - Changed to use `Dockerfile.fixed` instead of `Dockerfile`
   - Added comments about theme requirements

4. **Updated start-cms-local.sh**:
   - Now automatically checks if themes are initialized
   - Runs `init-themes.sh` if needed
   - Better error messages

5. **DOCKER_TROUBLESHOOTING.md** - Complete troubleshooting guide

---

## How to Use

### Quick Start (Automatic)

Just run the startup script - it handles everything:
```bash
./start-cms-local.sh
```

The script will:
1. Check if Docker is running
2. Check if themes are initialized
3. Initialize themes automatically if needed
4. Start all services

### Manual Steps (If Needed)

If automatic doesn't work:

```bash
# 1. Initialize themes
./init-themes.sh

# 2. Verify themes exist
ls themes/hugo-bootstrap/.git
ls themes/hugo-bootstrap-5/.git

# 3. Start services
./start-cms-local.sh
```

---

## Services Status

After fix, you have 4 Docker services:

| Service | Port | Purpose | Build Required |
|---------|------|---------|----------------|
| **hugo-dev** | 1313 | Development server (CMS) | ❌ No |
| site | 1080 | Production build | ✅ Yes (requires themes) |
| git-gateway | 8081 | Decap Server | ❌ No |
| auth-proxy | 8082 | User info API | ❌ No |

**For CMS work, you primarily use hugo-dev (port 1313)** which doesn't require building.

---

## What Got Fixed

### Before (Broken)
```
./start-cms-local.sh
  ↓
Docker tries to build site
  ↓
ONBUILD runs
  ↓
Themes missing
  ↓
❌ BUILD FAILS
```

### After (Fixed)
```
./start-cms-local.sh
  ↓
Script checks for themes
  ↓
If missing: ./init-themes.sh runs automatically
  ↓
Themes downloaded from Git submodules
  ↓
Docker builds with Dockerfile.fixed
  ↓
✅ BUILD SUCCEEDS
```

---

## Verify Fix

Run these commands to verify everything works:

```bash
# 1. Check themes are present
ls -la themes/hugo-bootstrap/
# Should show theme files

# 2. Start services
./start-cms-local.sh
# Should start without errors

# 3. Check containers running
docker ps | grep ukwa-site-original
# Should show 4 containers running

# 4. Test CMS access
curl -I http://localhost:1313/admin/
# Should return: HTTP/1.1 200 OK

# 5. Test Hugo dev server
curl -I http://localhost:1313
# Should return: HTTP/1.1 200 OK
```

---

## Access Points After Fix

Once services are running:

| What | URL | Status |
|------|-----|--------|
| **CMS Admin** | http://localhost:1313/admin/ | ✅ Primary interface |
| Hugo Dev | http://localhost:1313 | ✅ Live preview |
| Production Build | http://localhost:1080 | ✅ Static site |
| Git Gateway | http://localhost:8081 | ✅ Backend API |
| Auth Proxy | http://localhost:8082 | ✅ User info |

---

## Understanding Hugo Themes as Git Submodules

### What are Git Submodules?

Git submodules are external Git repositories linked to your main repository.

**In this project:**
- Main repo: `ukwa/ukwa-site`
- Submodule 1: `themes/hugo-bootstrap` → https://github.com/Xzya/hugo-bootstrap.git
- Submodule 2: `themes/hugo-bootstrap-5` → https://github.com/NotWoods/hugo-bootstrap-5.git

### Why Use Submodules?

✅ Advantages:
- Keeps theme code separate
- Easy to update themes
- Maintains theme version history
- Reduces main repo size

❌ Disadvantages:
- Need to initialize after clone
- Can be confusing for new users
- Adds complexity to builds

### When to Initialize

You need to initialize submodules:
- ✅ After fresh `git clone`
- ✅ After `git pull` that adds new submodules
- ✅ If themes directory is empty
- ✅ Before building Docker images

### Commands

```bash
# Initialize submodules
git submodule init

# Download submodule content
git submodule update --recursive

# Or do both at once
git submodule update --init --recursive

# Our script does this for you
./init-themes.sh
```

---

## Alternative: Clone with Submodules

If you're cloning the repository fresh, you can get everything at once:

```bash
# Clone with submodules automatically initialized
git clone --recursive https://github.com/ukwa/ukwa-site.git

# Or after regular clone
git clone https://github.com/ukwa/ukwa-site.git
cd ukwa-site
git submodule update --init --recursive
```

---

## Why Two Dockerfiles?

### Dockerfile (Original)
- Uses ONBUILD image
- Simpler but requires specific setup
- Fails if themes missing
- **Status:** Kept for compatibility but not used by default

### Dockerfile.fixed (New)
- Explicit build steps
- Better error messages
- Handles themes correctly
- **Status:** Used by docker-compose-integrated.cms.yml

---

## For Production Deployment

### Netlify, Azure, or Other Platforms

When deploying to production:

1. **Set build command:**
   ```bash
   git submodule update --init --recursive && hugo --minify
   ```

2. **Or in Azure Static Web Apps:**
   ```yaml
   # azure-static-web-apps.yml
   steps:
   - name: Checkout with submodules
     uses: actions/checkout@v3
     with:
       submodules: true

   - name: Build
     run: hugo --minify
   ```

3. **Or in Netlify:**
   ```toml
   # netlify.toml
   [build]
     command = "git submodule update --init --recursive && hugo --minify"
     publish = "public"
   ```

---

## Quick Reference

| Task | Command |
|------|---------|
| Fix the error | `./init-themes.sh` |
| Start CMS | `./start-cms-local.sh` |
| Stop CMS | `./stop-cms-local.sh` |
| Check themes | `ls themes/hugo-bootstrap/.git` |
| View logs | `docker compose -f docker-compose-integrated.cms.yml logs -f` |
| Rebuild | `docker compose -f docker-compose-integrated.cms.yml build --no-cache site` |

---

## Troubleshooting

### Still Getting Build Errors?

1. **Clean rebuild:**
   ```bash
   ./stop-cms-local.sh
   docker compose -f docker-compose-integrated.cms.yml down --rmi local
   ./init-themes.sh
   ./start-cms-local.sh
   ```

2. **Use only hugo-dev (skip building site):**
   ```bash
   docker compose -f docker-compose-integrated.cms.yml up -d hugo-dev git-gateway auth-proxy
   ```
   This skips the `site` service that requires themes.

3. **Check complete guide:**
   See [DOCKER_TROUBLESHOOTING.md](DOCKER_TROUBLESHOOTING.md) for comprehensive troubleshooting.

---

## Summary

✅ **Problem:** Docker build failed due to missing Hugo themes (Git submodules)

✅ **Fix Applied:**
- Created `init-themes.sh` to initialize submodules
- Created `Dockerfile.fixed` with explicit build steps
- Updated `start-cms-local.sh` to auto-initialize themes
- Updated `docker-compose-integrated.cms.yml` to use new Dockerfile
- Created comprehensive troubleshooting guide

✅ **Result:** Docker build now works correctly

✅ **Next Steps:**
1. Run `./start-cms-local.sh`
2. Access CMS at http://localhost:1313/admin/
3. Start editing content!

---

**Date:** 2025-01-28
**Status:** ✅ Fixed and Tested

For more details, see:
- [DOCKER_TROUBLESHOOTING.md](DOCKER_TROUBLESHOOTING.md) - Complete troubleshooting guide
- [CMS_INTEGRATION_README.md](CMS_INTEGRATION_README.md) - CMS quick start
- [docs/DEVOPS_GUIDE.md](docs/DEVOPS_GUIDE.md) - Technical details
