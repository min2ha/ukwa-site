# Decap CMS Integration for UKWA Website

This document provides a quick start guide for the newly integrated Decap CMS (formerly Netlify CMS) into the UKWA Hugo static website.

## Quick Start

### For Local Development

1. **Start the CMS environment:**
   ```bash
   ./start-cms-local.sh
   ```

2. **Access the CMS:**
   - Open your browser to `http://localhost:1313/admin/`
   - With local backend enabled, no authentication is required
   - Changes are saved directly to your local Git repository

3. **Stop the environment:**
   ```bash
   ./stop-cms-local.sh
   ```

### Alternative: Quick Local Setup (Without Docker)

```bash
# Install Decap Server
npm install -g decap-server

# Start Decap Server (in one terminal)
npx decap-server

# Start Hugo (in another terminal)
hugo server -D

# Access CMS
open http://localhost:1313/admin/
```

## What's Included

### Files Created/Modified

**CMS Configuration:**
- `static/admin/config.yml` - Updated with editorial workflow enabled
- `static/admin/index.html` - Updated to use latest Decap CMS (v3.3.3)

**Docker Setup:**
- `docker-compose-integrated.cms.yml` - Full development environment
- `start-cms-local.sh` - Easy startup script
- `stop-cms-local.sh` - Shutdown script

**User Management:**
- `cms-config/users/supervisor.json` - Admin role definition
- `cms-config/users/editor.json` - Editor role definition
- `cms-config/users/viewer.json` - Viewer role definition
- `cms-config/users/README.md` - User roles documentation
- `cms-config/nginx.conf` - Auth proxy configuration

**Documentation:**
- `docs/USER_GUIDE.md` - Comprehensive guide for content editors (non-technical)
- `docs/DEVOPS_GUIDE.md` - Technical implementation guide for DevOps
- `CMS_INTEGRATION_README.md` - This file

## User Roles

### Supervisor (Admin)
- **Permissions:** Full access - create, edit, delete, publish, user management
- **Workflow:** Can approve and publish content
- **Use case:** Content managers, site administrators

### Editor (Content Creator)
- **Permissions:** Create and edit content, upload media
- **Workflow:** Submit content for review, cannot publish
- **Use case:** Content writers, translators

### Viewer (Observer)
- **Permissions:** Read-only access
- **Workflow:** View content and workflow status
- **Use case:** Stakeholders, reviewers

## Features

### Editorial Workflow

The CMS is configured with a three-stage editorial workflow:

1. **Draft** - Content being created/edited
2. **In Review** - Submitted for approval
3. **Published** - Live on the website

This maps to Git branches and Pull Requests:
- Drafts create feature branches
- Review requests create PRs
- Publishing merges to master

### Multi-language Support

The CMS supports all three UKWA languages:
- English (en)
- Welsh / Cymraeg (cy)
- Gaelic / Gàidhlig (gd)

### Collections

Currently configured collections:
- **Homepage** - Main homepage content with highlights
- **Information Pages** - About, FAQ, Terms, etc.

## Testing the Integration

### Step 1: Verify Configuration

```bash
# Check YAML syntax
npx js-yaml static/admin/config.yml

# Should output the parsed config without errors
```

### Step 2: Start Local Environment

```bash
# Using the startup script
./start-cms-local.sh

# Or manually with Hugo
hugo server -D
```

### Step 3: Access CMS Interface

1. Open `http://localhost:1313/admin/`
2. You should see the Decap CMS interface
3. With `local_backend: true`, you'll work directly with local files

### Step 4: Test Content Editing

1. Navigate to "Collections" → "Information Pages"
2. Click on "About Us"
3. Make a small edit (e.g., add a sentence)
4. Click "Save"
5. Check that changes are reflected in `content/info/about/index.en.md`

### Step 5: Test Workflow

1. Create new content
2. Save as draft
3. Change status to "In Review"
4. (With full Git Gateway) This would create a PR
5. Approve and publish

## Production Deployment

### Option 1: Netlify (Easiest)

1. Connect your GitHub repo to Netlify
2. Enable Netlify Identity
3. Enable Git Gateway
4. Update `static/admin/config.yml`:
   ```yaml
   local_backend: false  # or remove this line
   ```
5. Deploy

### Option 2: GitHub with Custom Git Gateway

1. Set up GitHub OAuth App
2. Deploy Git Gateway service
3. Configure CMS to point to your gateway
4. See `docs/DEVOPS_GUIDE.md` for detailed steps

### Option 3: Azure Static Web Apps

1. Create Azure Static Web App
2. Connect to GitHub repo
3. Configure authentication
4. Set up separate Git Gateway
5. See `docs/DEVOPS_GUIDE.md` for configuration

## Configuration Files

### static/admin/config.yml

Key settings:
```yaml
backend:
  name: git-gateway          # Use Git Gateway for auth
  repo: ukwa/ukwa-site       # Your GitHub repo
  branch: master             # Target branch

publish_mode: editorial_workflow  # Enable draft/review/publish
local_backend: true               # Enable for local dev, disable for prod

media_folder: assets/images/uploads
public_folder: /assets/images/uploads

i18n:
  structure: multiple_files
  locales: ["en", "cy", "gd"]
```

### docker-compose-integrated.cms.yml

Services:
- **site** - Nginx serving built Hugo site (port 1080)
- **hugo-dev** - Hugo development server with live reload (port 1313)
- **git-gateway** - Decap Server for local backend (port 8081)
- **auth-proxy** - Nginx serving user info (port 8082)

## Troubleshooting

### Issue: CMS won't load

**Check:**
1. Is Hugo server running? `http://localhost:1313` should work
2. Check browser console for errors
3. Verify `static/admin/config.yml` syntax

**Solution:**
```bash
# Restart Hugo server
hugo server -D

# Clear browser cache and reload
```

### Issue: Can't save changes

**Check:**
1. Is decap-server running? (if using local backend)
2. Do you have write permissions to the repo?
3. Check console for error messages

**Solution:**
```bash
# Start decap-server if not running
npx decap-server

# Check Git status
git status
```

### Issue: Images not uploading

**Check:**
1. Does `static/assets/images/uploads/` exist?
2. Do you have write permissions?
3. Is file size reasonable (<5MB)?

**Solution:**
```bash
# Create directory if missing
mkdir -p static/assets/images/uploads
```

### Issue: Docker containers won't start

**Check:**
1. Is Docker running?
2. Are ports already in use?
3. Check logs

**Solution:**
```bash
# Check Docker status
docker ps

# View logs
docker-compose -f docker-compose-integrated.cms.yml logs

# Restart
docker-compose -f docker-compose-integrated.cms.yml restart
```

## Next Steps

1. **Read the documentation:**
   - Non-technical users: [docs/USER_GUIDE.md](docs/USER_GUIDE.md)
   - DevOps/Technical: [docs/DEVOPS_GUIDE.md](docs/DEVOPS_GUIDE.md)

2. **Test locally:**
   - Create test content
   - Upload test images
   - Try the workflow

3. **Set up production:**
   - Choose deployment platform
   - Configure authentication
   - Set up CI/CD
   - Invite users

4. **Train users:**
   - Share USER_GUIDE.md
   - Conduct training session
   - Set up support channels

## Resources

### Documentation
- [Decap CMS Official Docs](https://decapcms.org/docs/)
- [Hugo Documentation](https://gohugo.io/documentation/)
- [Git Workflow Guide](https://www.atlassian.com/git/tutorials/comparing-workflows)

### Community
- [Decap CMS Discussions](https://github.com/decaporg/decap-cms/discussions)
- [Hugo Discourse](https://discourse.gohugo.io/)

### Repository
- **GitHub:** https://github.com/ukwa/ukwa-site
- **Issues:** Report bugs or request features in the repository

## Support

For questions or issues:
1. Check this README and documentation in `docs/`
2. Search [existing issues](https://github.com/ukwa/ukwa-site/issues)
3. Create a new issue with details
4. Contact the DevOps team

---

**Version:** 1.0
**Date:** 2025-01-28
**Integration Status:** ✅ Complete - Ready for testing

---
