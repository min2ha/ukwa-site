# Production Deployment Guide - Auth0 (Updated)
## Site URL: https://ukwa-static.netlify.app

---

## ⚠️ Important Update: Netlify Identity Deprecated

**Netlify Identity is deprecated** as of 2024. We'll use one of these alternatives:

### Recommended Options:

1. **Auth0** (via Netlify Auth0 Extension) ⭐ Recommended
2. **GitHub Backend** (Direct OAuth - Simplest)
3. **Self-hosted Git Gateway** (Most control)

---

## Option 1: GitHub Backend (Recommended for Quick Setup)

This is the **simplest and fastest** option - no external auth service needed!

### How It Works

- Users authenticate via GitHub OAuth
- No separate auth service required
- Netlify provides the OAuth proxy
- Works with your existing GitHub repository

### Pros & Cons

**Pros:**
- ✅ Fastest setup (~15 minutes)
- ✅ No deprecated services
- ✅ Free forever
- ✅ Users already have GitHub accounts
- ✅ No additional service to maintain

**Cons:**
- ⚠️ Users must have GitHub accounts
- ⚠️ Permissions tied to GitHub repo access

---

## Quick Deployment with GitHub Backend

### Step 1: Update CMS Config

Edit `static/admin/config.yml`:

```yaml
backend:
  name: github              # Changed from git-gateway
  repo: min2ha/ukwa-site
  branch: development

publish_mode: editorial_workflow

# Remove local_backend line entirely
# local_backend: true

media_folder: static/assets/images/uploads
public_folder: /assets/images/uploads

i18n:
  structure: multiple_files
  locales: ["en", "cy", "gd"]
  default_locale: en

# Rest of config stays the same...
```

### Step 2: Set Up GitHub Repository Access

**For Admin User (minvidm@gmail.com):**
1. Invite to repository with **Write** access
2. Can merge pull requests

**For Editor User (mindaugas.vidmantas@bl.uk):**
1. Invite to repository with **Write** access
2. Can create branches and PRs
3. Cannot merge (enforced by branch protection)

**Steps:**
```
GitHub → min2ha/ukwa-site → Settings → Collaborators
→ Add people:
  - minvidm@gmail.com (Write access)
  - mindaugas.vidmantas@bl.uk (Write access)
```

### Step 3: Enable Branch Protection

```
GitHub → Settings → Branches → Add rule for "development"

☑ Require pull request reviews before merging
☑ Require review from Code Owners (optional)
☑ Number of required approvals: 1
```

This ensures editor cannot merge their own PRs - admin must approve!

### Step 4: Commit and Deploy

```bash
# Update config
# Edit static/admin/config.yml as shown above

# Commit
git add static/admin/config.yml
git commit -m "feat: use GitHub backend for authentication"
git push origin development

# Deploy to Netlify (standard Hugo deployment)
# No Identity or Git Gateway needed!
```

### Step 5: Deploy to Netlify

1. Go to https://app.netlify.com
2. Add new site → Import from GitHub
3. Select `min2ha/ukwa-site`
4. Branch: `development`
5. Build command: `hugo --minify`
6. Publish directory: `public`
7. Deploy!

**That's it!** No Auth0, no Identity setup needed.

### Step 6: Users Access CMS

**First time:**
1. Go to: https://ukwa-static.netlify.app/admin/
2. Click "Login with GitHub"
3. Authorize the app
4. Start editing!

**Authentication:** Via GitHub OAuth (automatic)

---

## Option 2: Auth0 Integration (More Features)

If you want email/password login instead of GitHub:

### Step 1: Create Auth0 Account

1. Go to https://auth0.com
2. Sign up for free account
3. Create new tenant: `ukwa-cms`

### Step 2: Create Auth0 Application

1. Applications → Create Application
2. Name: "UKWA CMS"
3. Type: "Single Page Application"
4. Create

### Step 3: Configure Application

**Settings:**
```
Allowed Callback URLs:
https://ukwa-static.netlify.app/admin/

Allowed Logout URLs:
https://ukwa-static.netlify.app/admin/

Allowed Web Origins:
https://ukwa-static.netlify.app
```

Save changes.

### Step 4: Create Auth0 Users

1. User Management → Users → Create User
2. Add users:
   - minvidm@gmail.com (admin)
   - mindaugas.vidmantas@bl.uk (editor)
3. Users will receive password setup emails

### Step 5: Install Netlify Auth0 Extension

```bash
# In your repository
netlify init  # If not already initialized

# Install Auth0 extension
netlify addons:create auth0
```

Follow prompts to connect Auth0 account.

### Step 6: Update CMS Config

```yaml
backend:
  name: git-gateway
  repo: min2ha/ukwa-site
  branch: development

publish_mode: editorial_workflow

media_folder: static/assets/images/uploads
public_folder: /assets/images/uploads

# Rest stays the same
```

### Step 7: Deploy

Deploy to Netlify as usual.

**Note:** This option is more complex but gives you email/password login.

---

## Comparison of Options

| Feature | GitHub Backend | Auth0 | Self-hosted Gateway |
|---------|----------------|-------|---------------------|
| **Setup Time** | 15 min ⚡ | 45 min | 2 hours |
| **Complexity** | Low | Medium | High |
| **Cost** | Free | Free tier | Hosting cost |
| **User Management** | Via GitHub | Via Auth0 | Custom |
| **Login Method** | GitHub OAuth | Email/Password | Custom |
| **Best For** | Tech-savvy users | Non-GitHub users | Full control |

---

## Recommended: GitHub Backend

For your use case (2 users, both tech-savvy), **GitHub Backend is recommended**:

**Why:**
- ✅ Simplest setup
- ✅ No deprecated services
- ✅ Both users likely have GitHub accounts
- ✅ Free forever
- ✅ One less service to maintain
- ✅ Direct integration with repository

---

## Updated Deployment Steps (GitHub Backend)

### Pre-Deployment (5 min)

```bash
# 1. Update config to use GitHub backend
cat > static/admin/config.yml << 'EOF'
backend:
  name: github
  repo: min2ha/ukwa-site
  branch: development

publish_mode: editorial_workflow

media_folder: static/assets/images/uploads
public_folder: /assets/images/uploads

i18n:
  structure: multiple_files
  locales: ["en", "cy", "gd"]
  default_locale: en

collections:
  - name: "homepage"
    label: "Homepage"
    folder: content/ukwa
    create: false
    delete: false
    i18n: true
    preview_path: "en/ukwa/{{dirname}}"
    fields:
      - {label: 'Title', name: 'title', widget: 'string', i18n: true}
      - {label: 'Body', name: 'body', widget: 'markdown', i18n: true}
      - {label: 'Layout', name: 'layout', widget: 'hidden'}
      - {label: 'Aliases', name: 'aliases', widget: 'hidden'}
      - label: "Highlights"
        name: "highlights"
        collapsed: true
        widget: "list"
        min: 3
        max: 3
        i18n: true
        summary: '{{fields.title}}'
        fields:
         - {label: "Collection ID Number", name: collectionId, widget: number, value_type: int }
         - {label: "Title", name: title, widget: string, i18n: true }
         - {label: "Description", name: description, widget: string, i18n: true }

  - name: "info"
    label: "Information Pages"
    folder: content/info
    create: false
    delete: false
    path: "{{slug}}/index"
    i18n: true
    preview_path: "en/ukwa/info/{{dirname}}"
    fields:
      - {label: 'Title', name: 'title', widget: 'string', i18n: true}
      - {label: 'Body', name: 'body', widget: 'markdown', i18n: true}
      - {label: 'Aliases', name: 'aliases', widget: 'hidden'}
EOF

# 2. Commit
git add static/admin/config.yml
git commit -m "feat: use GitHub backend instead of deprecated Netlify Identity"
git push origin development
```

### GitHub Setup (10 min)

1. **Add Collaborators:**
   - Go to: https://github.com/min2ha/ukwa-site/settings/access
   - Invite users:
     - minvidm@gmail.com → **Maintain** role (can merge PRs)
     - mindaugas.vidmantas@bl.uk → **Write** role (can create PRs)

2. **Enable Branch Protection:**
   - Settings → Branches → Add rule for `development`
   - ☑ Require pull request reviews before merging
   - ☑ Required approvals: 1
   - Save

### Netlify Deployment (10 min)

1. Go to https://app.netlify.com
2. Add new site → Import from GitHub
3. Authorize Netlify to access repository
4. Configure:
   - Repository: `min2ha/ukwa-site`
   - Branch: `development`
   - Build: `hugo --minify`
   - Publish: `public`
5. Click "Deploy site"
6. Once deployed:
   - Site settings → Domain management
   - Change site name to: `ukwa-static`

**Site will be live at:** https://ukwa-static.netlify.app

### User Access (5 min)

**For Both Users:**
1. Go to: https://ukwa-static.netlify.app/admin/
2. Click "Login with GitHub"
3. Authorize the application
4. Start editing!

**No email invitations needed** - users authenticate with GitHub immediately.

---

## User Instructions

### Admin (minvidm@gmail.com)

**Requirements:**
- GitHub account with access to min2ha/ukwa-site
- Repository role: **Maintain** or **Admin**

**Login:**
1. Navigate to: https://ukwa-static.netlify.app/admin/
2. Click "Login with GitHub"
3. Authorize (first time only)
4. You're in!

**Permissions:**
- ✅ Create/edit content
- ✅ Approve pull requests
- ✅ Publish to live site
- ✅ Delete content
- ✅ Access workflow board

---

### Editor (mindaugas.vidmantas@bl.uk)

**Requirements:**
- GitHub account with access to min2ha/ukwa-site
- Repository role: **Write**

**Login:**
1. Navigate to: https://ukwa-static.netlify.app/admin/
2. Click "Login with GitHub"
3. Authorize (first time only)
4. You're in!

**Permissions:**
- ✅ Create/edit content
- ✅ Submit for review (creates PR)
- ✅ Upload media
- ⚠️ Cannot merge PRs (needs admin approval)
- ⚠️ Cannot delete content

---

## Workflow Process

### Content Creation

**Editor:**
1. Login to CMS via GitHub
2. Create/edit content
3. Save draft
4. Change status to "In Review"
5. **Result:** GitHub PR created automatically

**Admin:**
1. Receives GitHub notification (PR created)
2. Reviews PR in GitHub or CMS
3. Approves PR
4. Clicks "Publish" in CMS
5. **Result:** PR merged, site auto-deploys

**Time:** 2-3 minutes from publish to live

---

## Advantages of GitHub Backend

### For This Project

✅ **Perfect fit:**
- Both users likely have GitHub accounts
- Direct repository integration
- No deprecated services
- Free forever
- Simple setup

✅ **Built-in features:**
- OAuth authentication (secure)
- Role-based via repository permissions
- Audit trail via Git history
- No additional services to maintain

✅ **Future-proof:**
- Not deprecated
- Active development
- Large community support

---

## Testing Checklist

After deployment:

- [ ] Site loads: https://ukwa-static.netlify.app
- [ ] CMS loads: https://ukwa-static.netlify.app/admin/
- [ ] "Login with GitHub" button appears
- [ ] Admin can log in (minvidm@gmail.com)
- [ ] Editor can log in (mindaugas.vidmantas@bl.uk)
- [ ] Admin can access workflow board
- [ ] Editor can create draft
- [ ] Editor can submit for review (creates PR)
- [ ] Admin receives PR notification
- [ ] Admin can approve and publish
- [ ] Changes appear on live site

---

## Troubleshooting

### "Login with GitHub not appearing"

**Check:**
- Config has `name: github` (not `git-gateway`)
- Pushed to deployment branch
- Netlify site rebuilt with new config

**Fix:**
```bash
# Verify config
grep "name: github" static/admin/config.yml

# Trigger rebuild
git commit --allow-empty -m "trigger rebuild"
git push origin development
```

### "User can't access CMS"

**Check:**
- User has GitHub account
- User invited to repository
- User accepted invitation
- User has Write or Maintain role

**Fix:**
- Resend GitHub repository invitation
- Verify user's repository access

### "Editor can merge their own PRs"

**Check:**
- Branch protection enabled for `development`
- "Require pull request reviews" is checked
- User doesn't have Admin role

**Fix:**
- Enable branch protection rules
- Downgrade user to Write role if needed

---

## Migration from Local Backend

Your current `local_backend: true` setup needs only config change:

```bash
# Before (local development)
backend:
  name: git-gateway
  repo: min2ha/ukwa-site
  branch: development
local_backend: true

# After (production with GitHub)
backend:
  name: github              # Changed!
  repo: min2ha/ukwa-site
  branch: development
# local_backend removed!
```

**All content stays the same!** Just authentication method changes.

---

## Summary

### What Changed

❌ **Old Plan:** Netlify Identity + Git Gateway (deprecated)
✅ **New Plan:** GitHub Backend (direct OAuth)

### Benefits

- ✅ No deprecated services
- ✅ Simpler setup (15 min vs 45 min)
- ✅ No separate auth service
- ✅ Direct GitHub integration
- ✅ Future-proof solution
- ✅ Free forever

### Users

- **Admin:** minvidm@gmail.com (GitHub account required)
- **Editor:** mindaugas.vidmantas@bl.uk (GitHub account required)

### Access

- **CMS:** https://ukwa-static.netlify.app/admin/
- **Login:** Via GitHub OAuth
- **Workflow:** Full editorial workflow via PRs

---

## Quick Commands

```bash
# Update config for GitHub backend
cat > static/admin/config.yml << 'EOF'
backend:
  name: github
  repo: min2ha/ukwa-site
  branch: development
publish_mode: editorial_workflow
# ... rest of config
EOF

# Commit and deploy
git add static/admin/config.yml
git commit -m "feat: switch to GitHub backend authentication"
git push origin development

# Then deploy via Netlify web UI
```

---

**Deployment Time:** ~25 minutes (vs 45 with deprecated Identity)
**Status:** ✅ Ready to deploy with GitHub backend
**Date:** 2025-10-28

---

**This is the recommended path forward!** 🚀
