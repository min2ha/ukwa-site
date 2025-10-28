# Branch Configuration - Decap CMS

## Current Configuration

### CMS Configuration (static/admin/config.yml)

The Decap CMS is configured to work with:

```yaml
backend:
  name: git-gateway
  repo: min2ha/ukwa-site      # Your fork
  branch: development          # Target branch ✅
```

**This means:**
- CMS will create/merge content to the `development` branch
- Pull requests will target `development` (not `master`)
- Editorial workflow: Draft → Review → Merge to `development`

---

## Local Repository Status

**Current local branch:** `master`
**Remote repository:** `ukwa/ukwa-site` (original repo)

To align with the CMS configuration, you may want to:

### Option 1: Switch to development branch locally

```bash
# Create and switch to development branch
git checkout -b development

# Push to your fork
git push -u origin development
```

### Option 2: Update your remote to point to your fork

```bash
# Add your fork as remote
git remote add fork https://github.com/min2ha/ukwa-site.git

# Or update origin to your fork
git remote set-url origin https://github.com/min2ha/ukwa-site.git

# Verify
git remote -v
```

---

## How This Works

### Local Development (Current Setup)

With `local_backend: true` in config.yml:
- ✅ CMS works directly with local files
- ✅ No branch restrictions
- ✅ Changes saved to whichever branch you're on
- ✅ You control when to commit and push

**Current status:** This works fine! The branch setting only matters for production.

### Production Deployment

When you deploy to production and disable `local_backend`:
- CMS will use Git Gateway
- Changes will be committed to `development` branch
- Pull requests will target `development`
- You'll merge `development` → `master` for deployment

---

## Workflow Mapping

### With Editorial Workflow Enabled

```
Editor creates content
    ↓
CMS creates branch: cms/draft/info/page-name
    ↓
Editor requests review: Status → "In Review"
    ↓
CMS creates PR: cms/draft/... → development
    ↓
Supervisor approves
    ↓
PR merged to: development branch
    ↓
Production deployment: development → master
```

### Branch Strategy

```
master (production)
  ↑
  └── development (CMS target)
        ↑
        ├── cms/draft/info/about
        ├── cms/draft/homepage/update
        └── cms/review/info/faq
```

---

## Configuration Differences

### For Local Development (Current)

```yaml
# static/admin/config.yml
backend:
  name: git-gateway
  repo: min2ha/ukwa-site
  branch: development

local_backend: true  # Works with local files
```

**Branch setting:** Ignored in local mode
**Actual branch used:** Whatever you're on (`master` currently)

### For Production

```yaml
# static/admin/config.yml
backend:
  name: git-gateway
  repo: min2ha/ukwa-site
  branch: development

# Remove or set to false:
# local_backend: false
```

**Branch setting:** Used! All changes go to `development`
**Production workflow:** `development` → `master` via manual merge

---

## Recommendations

### For Local CMS Development (Current)
**✅ No changes needed!**
- `local_backend: true` means branch setting doesn't matter
- You can stay on `master` branch
- CMS works with local files directly

### For Production Setup (Future)

**Option A: Use development branch**
```bash
# 1. Create development branch
git checkout -b development
git push -u origin development

# 2. Set up branch protection on GitHub
# Settings → Branches → Add rule for "development"
# ✓ Require pull request reviews
# ✓ Require status checks to pass

# 3. Deploy from development branch
```

**Option B: Use master branch**
```yaml
# Update static/admin/config.yml
backend:
  name: git-gateway
  repo: min2ha/ukwa-site
  branch: master  # Change to master
```

---

## Repository Configuration

### Current Setup
- **Local:** Points to `ukwa/ukwa-site` (original repo)
- **CMS Config:** Points to `min2ha/ukwa-site` (your fork)

### Recommended: Align Repositories

```bash
# Update local to use your fork
git remote set-url origin https://github.com/min2ha/ukwa-site.git

# Keep original as upstream
git remote add upstream https://github.com/ukwa/ukwa-site.git

# Verify
git remote -v
# Should show:
# origin    https://github.com/min2ha/ukwa-site.git
# upstream  https://github.com/ukwa/ukwa-site.git
```

**Benefits:**
- Local repo matches CMS config
- Can still pull updates from upstream
- Push directly to your fork

---

## Testing Branch Configuration

### Test Locally (Works Now)
```bash
# CMS is already accessible
open http://localhost:1313/admin/

# Make changes in CMS
# Check git status
git status
# Will show changes on current branch (master)
```

### Test with Development Branch
```bash
# Switch to development
git checkout -b development

# Start CMS
./start-cms-local.sh
open http://localhost:1313/admin/

# Make changes
# Check status
git status
# Will show changes on development branch
```

---

## Summary

### Current Status
✅ **CMS Configuration:** Set to `development` branch
✅ **Local Branch:** On `master` branch
✅ **CMS Mode:** `local_backend: true` (works with any branch)
✅ **Working:** Yes! Branch setting doesn't matter in local mode

### Action Items

**For Continued Local Development:**
- [ ] No action needed! Keep using CMS as-is

**For Production Deployment:**
- [ ] Decide: Use `development` or `master` branch?
- [ ] If `development`: Create the branch locally
- [ ] Update git remote to point to your fork
- [ ] Set up branch protection rules on GitHub
- [ ] Disable `local_backend` in config.yml
- [ ] Configure Git Gateway (Netlify/GitHub OAuth)

### Quick Reference

| Environment | Branch Used | Config Setting Matters? |
|-------------|-------------|-------------------------|
| **Local (current)** | `master` | ❌ No (local_backend: true) |
| **Production** | `development` | ✅ Yes (local_backend: false) |

---

## Files to Review

- **[static/admin/config.yml](static/admin/config.yml)** - CMS configuration
- **[docs/DEVOPS_GUIDE.md](docs/DEVOPS_GUIDE.md)** - Production setup guide
- **[README_CMS.md](README_CMS.md)** - CMS overview

---

**Date:** 2025-10-28
**Status:** ✅ Configuration verified
**Branch:** `development` (configured in CMS)
**Mode:** Local development (branch setting not active)

---

## Need to Change Branch Back to Master?

If you want to use `master` branch instead:

```bash
# Edit static/admin/config.yml
# Change line 4:
branch: master  # instead of development
```

Or keep `development` for production and create the branch when ready:

```bash
git checkout -b development
git push -u origin development
```

**Current setup is fine for local development!** The branch configuration only matters when you deploy to production with Git Gateway.
