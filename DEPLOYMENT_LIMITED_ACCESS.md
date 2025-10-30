# Limited Access Deployment Guide
## UKWA Static Website - dev_limited_access Branch

**Branch:** `dev_limited_access`
**Target URL:** https://static-ukwa-site.netlify.app
**Purpose:** Restricted access deployment with limited editing capabilities
**Date:** 2025-10-30

---

## Overview

This deployment guide is specifically for the **dev_limited_access** branch, which provides a separate Netlify deployment with restricted content management capabilities.

### Key Differences from Main Deployment

| Feature | Main (development) | Limited Access (dev_limited_access) |
|---------|-------------------|-------------------------------------|
| **URL** | https://ukwa-static.netlify.app | https://static-ukwa-site.netlify.app |
| **Branch** | `development` | `dev_limited_access` |
| **Create Content** | ✅ Yes | ❌ No |
| **Delete Content** | ✅ Yes (with approval) | ❌ No |
| **Edit Content** | ✅ Yes | ✅ Yes (only) |
| **Publish Workflow** | ✅ Editorial workflow | ✅ Editorial workflow |
| **User Roles** | Admin + Editor | Editor only (restricted) |

---

## Architecture

```
GitHub Repository: min2ha/ukwa-site
│
├── Branch: development
│   └── Deploys to: https://ukwa-static.netlify.app
│       (Full access - create, edit, delete)
│
└── Branch: dev_limited_access
    └── Deploys to: https://static-ukwa-site.netlify.app
        (Limited access - edit only)
```

---

## Configuration Details

### 1. Decap CMS Configuration

**File:** `static/admin/config.yml`

```yaml
backend:
  name: github
  repo: min2ha/ukwa-site
  branch: dev_limited_access  # ← Points to limited access branch

publish_mode: editorial_workflow

# Collections are restricted:
collections:
  - name: "homepage"
    label: "Homepage (Edit Only)"
    create: false  # ← Cannot create new pages
    delete: false  # ← Cannot delete pages

  - name: "info"
    label: "Information Pages (Edit Only)"
    create: false  # ← Cannot create new pages
    delete: false  # ← Cannot delete pages
```

### 2. Netlify Configuration

**File:** `netlify.toml`

```toml
# Context for dev_limited_access branch
# Deploy to: https://static-ukwa-site.netlify.app
[context.dev_limited_access]
  command = "hugo --minify"

[context.dev_limited_access.environment]
  HUGO_ENV = "production"
  HUGO_VERSION = "0.111.3"
  HUGO_ENABLEGITINFO = "true"
```

---

## Deployment Steps

### Prerequisites

- ✅ GitHub account with access to `min2ha/ukwa-site`
- ✅ Netlify account
- ✅ `dev_limited_access` branch exists and is up to date

### Step 1: Create New Netlify Site (15 minutes)

1. **Go to Netlify Dashboard**
   - URL: https://app.netlify.com
   - Log in with your GitHub account

2. **Add New Site**
   - Click "Add new site" → "Import an existing project"
   - Choose "Deploy with GitHub"
   - Authorize Netlify to access your GitHub repositories

3. **Select Repository**
   - Choose: `min2ha/ukwa-site`
   - Click "Configure Netlify on GitHub" if repository not visible

4. **Configure Build Settings**
   ```
   Branch to deploy:     dev_limited_access
   Build command:        hugo --minify
   Publish directory:    public
   ```

5. **Advanced Build Settings** (click "Show advanced")
   - Add environment variables:
     ```
     HUGO_VERSION = 0.111.3
     HUGO_ENV = production
     HUGO_ENABLEGITINFO = true
     ```

6. **Deploy Site**
   - Click "Deploy site"
   - Initial build will start (~2 minutes)
   - Wait for "Site is live" message

7. **Change Site Name**
   - Go to "Site settings" → "General" → "Site details"
   - Click "Change site name"
   - New name: `static-ukwa-site`
   - Click "Save"
   - New URL: https://static-ukwa-site.netlify.app

### Step 2: Configure Branch Protection (5 minutes)

1. **Go to GitHub Repository Settings**
   - URL: https://github.com/min2ha/ukwa-site/settings/branches
   - Click "Add branch protection rule"

2. **Configure Protection for dev_limited_access**
   ```
   Branch name pattern: dev_limited_access

   ☑ Require a pull request before merging
     ☑ Require approvals: 1
     ☑ Dismiss stale pull request approvals when new commits are pushed

   ☐ Require status checks to pass before merging
   ☐ Require conversation resolution before merging
   ☐ Require signed commits
   ☐ Require linear history
   ☐ Include administrators (optional)
   ☐ Restrict who can push to matching branches
   ☑ Do not allow bypassing the above settings
   ☐ Allow force pushes
   ☐ Allow deletions
   ```

3. **Save Changes**
   - Click "Create" or "Save changes"

### Step 3: Invite GitHub Collaborators (5 minutes)

**Note:** For limited access, invite users with **Write** role only (not Maintain).

1. **Go to Repository Access Settings**
   - URL: https://github.com/min2ha/ukwa-site/settings/access
   - Click "Add people"

2. **Invite Limited Access User**
   - Enter email: `mindaugas.vidmantas@bl.uk`
   - Role: **Write** (can create PRs, cannot merge)
   - Click "Add to repository"

3. **User Accepts Invitation**
   - User receives email invitation
   - Clicks "Accept invitation"
   - Now has Write access to repository

### Step 4: Test CMS Access (5 minutes)

1. **Admin Tests First**
   - Go to: https://static-ukwa-site.netlify.app/admin/
   - Click "Login with GitHub"
   - Authorize application
   - Verify CMS loads correctly

2. **Check Collection Access**
   - Open "Homepage (Edit Only)"
   - Verify: Can edit existing pages ✅
   - Verify: Cannot see "New Homepage" button ✅
   - Open "Information Pages (Edit Only)"
   - Verify: Can edit existing pages ✅
   - Verify: Cannot see "New Information Pages" button ✅

3. **Test Editorial Workflow**
   - Edit a page (e.g., "About")
   - Click "Save" → Creates draft
   - Change status to "In Review" → Creates PR
   - Check GitHub: PR #XX created on `dev_limited_access` branch ✅

4. **Limited Access User Tests**
   - User goes to: https://static-ukwa-site.netlify.app/admin/
   - Logs in with GitHub
   - Verifies same restrictions apply
   - Can edit but cannot create/delete ✅

---

## User Workflow (Limited Access)

### What Users CAN Do

✅ **Edit Existing Content**
- Open existing pages
- Modify text, titles, body content
- Update translations (EN, CY, GD)
- Change highlights on homepage
- Save changes as drafts

✅ **Submit for Review**
- Save draft changes
- Submit for review (creates Pull Request)
- View workflow board
- See status of submissions

✅ **Upload Media**
- Upload images to media library
- Use uploaded images in content
- Organize media files

### What Users CANNOT Do

❌ **Create New Pages**
- No "New Homepage" button
- No "New Information Pages" button
- Cannot add new content types

❌ **Delete Pages**
- No delete option in editor
- Cannot remove existing content

❌ **Publish Directly**
- Cannot merge Pull Requests
- Cannot approve content
- Must wait for admin approval

❌ **Modify Site Configuration**
- Cannot edit config.toml
- Cannot change themes
- Cannot modify deployment settings

---

## Editorial Workflow (Limited Access)

```
Editor (Limited Access User)
    │
    ├─ 1. Opens existing page
    │     https://static-ukwa-site.netlify.app/admin/
    │
    ├─ 2. Makes edits
    │     Modifies content, translations
    │
    ├─ 3. Saves as draft
    │     Creates branch: cms/info/page-name
    │
    ├─ 4. Submits for review
    │     Creates PR to dev_limited_access
    │
    ▼
GitHub Pull Request Created
    │
    ├─ Status: Awaiting review
    ├─ Required approvals: 1
    │
    ▼
Admin Reviews PR
    │
    ├─ Option A: Approve
    │     ├─ Admin clicks "Approve" in GitHub or CMS
    │     ├─ Admin publishes (merges PR)
    │     └─> Netlify auto-deploys (~2 min)
    │         └─> Live on https://static-ukwa-site.netlify.app ✅
    │
    └─ Option B: Request Changes
          ├─ Admin adds review comments
          ├─ Editor receives notification
          ├─ Editor makes requested changes
          └─> Review cycle repeats
```

---

## Access URLs

| Resource | URL |
|----------|-----|
| **Live Site (Limited Access)** | https://static-ukwa-site.netlify.app |
| **CMS Admin (Limited Access)** | https://static-ukwa-site.netlify.app/admin/ |
| **Workflow Board** | https://static-ukwa-site.netlify.app/admin/#/workflow |
| **GitHub Repository** | https://github.com/min2ha/ukwa-site |
| **Branch on GitHub** | https://github.com/min2ha/ukwa-site/tree/dev_limited_access |
| **Netlify Dashboard** | https://app.netlify.com/sites/static-ukwa-site |
| **Main Site (Full Access)** | https://ukwa-static.netlify.app |

---

## User Permissions

### Limited Access Editor

**GitHub Role:** Write
**Email:** mindaugas.vidmantas@bl.uk

**CMS Permissions:**
- ✅ View all content
- ✅ Edit existing pages
- ✅ Create drafts
- ✅ Submit for review
- ✅ Upload media
- ❌ Create new pages
- ❌ Delete pages
- ❌ Publish content
- ❌ Approve PRs

**GitHub Permissions:**
```
Repository: min2ha/ukwa-site
Role: Write
Permissions:
  admin: false
  maintain: false
  push: true      ← Can create branches
  triage: true
  pull: true

Branch: dev_limited_access
  Can create feature branches: Yes
  Can create PRs: Yes
  Can merge PRs: No (requires approval)
  Can push directly: No (branch protected)
```

### Admin (for approval)

**GitHub Role:** Maintain or Admin
**Email:** minvidm@gmail.com

**Permissions:**
- ✅ All editor permissions
- ✅ Approve PRs
- ✅ Merge PRs
- ✅ Publish content
- ✅ Manage users

---

## Branch Synchronization

### Keeping dev_limited_access Updated

The `dev_limited_access` branch should be periodically synchronized with `development` to get latest content updates.

#### Option 1: Via GitHub Web Interface

1. Go to: https://github.com/min2ha/ukwa-site
2. Switch to `dev_limited_access` branch
3. Click "Sync fork" or "Update branch"
4. Click "Update with merge"

#### Option 2: Via Git Command Line

```bash
# Fetch latest changes
git fetch origin

# Switch to dev_limited_access
git checkout dev_limited_access

# Merge changes from development
git merge origin/development

# Resolve any conflicts if needed

# Push updated branch
git push origin dev_limited_access
```

#### Option 3: Via Pull Request

1. Create PR from `development` → `dev_limited_access`
2. Review changes
3. Merge PR
4. Auto-deploys to https://static-ukwa-site.netlify.app

**Recommendation:** Sync weekly or after major content updates on main site.

---

## Deployment Timeline

| Phase | Time | Task |
|-------|------|------|
| Create Netlify site | 10 min | Configure and initial deploy |
| Change site name | 2 min | Set to static-ukwa-site |
| Branch protection | 5 min | Configure GitHub rules |
| Invite collaborators | 3 min | Add limited access users |
| Test CMS access | 5 min | Verify restrictions work |
| **Total** | **25 min** | Complete setup |

---

## Comparison: Main vs Limited Access

### Main Deployment (development branch)

```
URL: https://ukwa-static.netlify.app
Branch: development
Users:
  - minvidm@gmail.com (Admin - Maintain role)
  - mindaugas.vidmantas@bl.uk (Editor - Write role)

Capabilities:
  ✅ Create new content
  ✅ Edit existing content
  ✅ Delete content (with approval)
  ✅ Full editorial workflow
  ✅ Media management

Use Case: Full content management
```

### Limited Access Deployment (dev_limited_access branch)

```
URL: https://static-ukwa-site.netlify.app
Branch: dev_limited_access
Users:
  - mindaugas.vidmantas@bl.uk (Editor - Write role, restricted)

Capabilities:
  ❌ Create new content (disabled)
  ✅ Edit existing content
  ❌ Delete content (disabled)
  ✅ Editorial workflow (submit for review)
  ✅ Media management

Use Case: Restricted editing for specific users
```

---

## Troubleshooting

### Issue: User Cannot See CMS Content

**Symptoms:**
- CMS loads but shows empty collections
- "No entries found" message

**Solution:**
```bash
# Verify branch configuration
Check static/admin/config.yml:
  backend:
    branch: dev_limited_access  # Must match

# Verify user has repository access
Go to: https://github.com/min2ha/ukwa-site/settings/access
Confirm user is listed with Write role
```

### Issue: User Can See Create/Delete Buttons

**Symptoms:**
- "New Homepage" button visible
- Delete option available

**Solution:**
```yaml
# Verify collection configuration in static/admin/config.yml
collections:
  - name: "info"
    create: false  # Must be false
    delete: false  # Must be false
```

### Issue: User Can Merge PRs

**Symptoms:**
- User can publish without approval
- "Publish" button works directly

**Solution:**
```bash
# Verify GitHub repository role
Go to: https://github.com/min2ha/ukwa-site/settings/access
Check user role: Should be "Write" (not "Maintain")

# Verify branch protection
Go to: https://github.com/min2ha/ukwa-site/settings/branches
Verify dev_limited_access has protection rules enabled
```

### Issue: Build Fails After Deployment

**Symptoms:**
- Netlify build fails
- Hugo errors in logs

**Solution:**
```bash
# Check Hugo version in netlify.toml
[context.dev_limited_access.environment]
  HUGO_VERSION = "0.111.3"  # Must match

# Check build command
[context.dev_limited_access]
  command = "hugo --minify"

# View build logs
https://app.netlify.com/sites/static-ukwa-site/deploys
```

### Issue: Changes Not Appearing on Live Site

**Symptoms:**
- PR merged but site unchanged
- Content outdated

**Solution:**
```bash
# Check deployment status
Go to: https://app.netlify.com/sites/static-ukwa-site/deploys
Verify latest deploy is "Published"

# Check if webhook is working
Verify GitHub webhook at:
https://github.com/min2ha/ukwa-site/settings/hooks

# Manual re-deploy
Netlify dashboard → "Trigger deploy" → "Deploy site"
```

---

## Security Considerations

### Authentication

✅ **GitHub OAuth 2.0**
- Industry-standard authentication
- No password storage
- Token-based access

### Authorization

✅ **Repository Permissions**
- Enforced by GitHub
- Write role = limited access
- Cannot bypass branch protection

### Content Review

✅ **Mandatory PR Review**
- All changes require approval
- 1 approval minimum
- Admin reviews before publish

### Audit Trail

✅ **Full Git History**
- Every change tracked
- Who made changes
- When changes were made
- What was changed

### Branch Protection

✅ **Protected Branch**
- No direct pushes
- PR required
- No force pushes
- No deletions

---

## Monitoring & Maintenance

### Weekly Tasks

- [ ] Check for pending PRs requiring review
- [ ] Review deployed content for accuracy
- [ ] Sync `dev_limited_access` with `development` if needed
- [ ] Check Netlify build logs for errors

### Monthly Tasks

- [ ] Review user access permissions
- [ ] Check SSL certificate status (auto-renewed)
- [ ] Review GitHub webhook status
- [ ] Update Hugo version if new release available

### Quarterly Tasks

- [ ] Review and update documentation
- [ ] Audit user access logs
- [ ] Test disaster recovery procedures
- [ ] Review and optimize build times

---

## Support & Resources

### For Limited Access Users

**Getting Started:**
1. Accept GitHub repository invitation
2. Go to: https://static-ukwa-site.netlify.app/admin/
3. Login with GitHub
4. Read: [User Guide](docs/USER_GUIDE.md)

**Need Help?**
- Contact admin: minvidm@gmail.com
- View workflow guide: [Editorial Workflow](EDITORIAL_WORKFLOW_GUIDE.md)

### For Administrators

**Documentation:**
- [DevOps Guide](docs/DEVOPS_GUIDE.md)
- [Architecture Diagrams](DEVOPS_ARCHITECTURE_DIAGRAMS.md)
- [GitHub Backend Deployment](GITHUB_BACKEND_DEPLOYMENT.md)
- [Deployment Checklist](DEPLOYMENT_CHECKLIST.md)

**Technical Support:**
- Netlify: https://www.netlify.com/support/
- Decap CMS: https://github.com/decaporg/decap-cms/discussions
- Hugo: https://discourse.gohugo.io/

---

## Summary

✅ **Deployment Configuration Complete**
- Branch: `dev_limited_access`
- URL: https://static-ukwa-site.netlify.app
- Build: Hugo 0.111.3 with minification
- Context: Separate Netlify deployment

✅ **Access Restrictions Enforced**
- Edit only (no create/delete)
- Mandatory PR review workflow
- GitHub Write role (limited)
- Branch protection enabled

✅ **Ready for Production**
- Follow deployment steps above
- Invite limited access users
- Test CMS functionality
- Monitor and maintain

---

**Prepared:** 2025-10-30
**Branch:** `dev_limited_access`
**Target URL:** https://static-ukwa-site.netlify.app
**Status:** ✅ Configuration Complete - Ready to Deploy
