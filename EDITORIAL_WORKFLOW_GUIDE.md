# Editorial Workflow Setup and Testing Guide

## Current Configuration

### Config Status: ✅ Editorial Workflow Enabled

```yaml
# static/admin/config.yml
publish_mode: editorial_workflow  ✅
local_backend: true              ⚠️ Limits workflow functionality
```

---

## Important: Local Backend Limitations

### What Works in Local Mode (`local_backend: true`)

✅ **Drafts**
- Save content as drafts
- Edit drafts
- Content saved to local files immediately

❌ **Limited Workflow Features**
- No Pull Requests created
- No "In Review" status (works differently)
- No approval process
- No Git branches created automatically

**Why?** Local backend works directly with files, bypassing Git operations that power the full workflow.

---

## Accessing the Workflow

### CMS Routes Available

1. **Main Dashboard**
   ```
   http://localhost:1313/admin/
   ```

2. **Workflow Board** (Editorial Workflow)
   ```
   http://localhost:1313/admin/#/workflow
   ```
   ⚠️ **NOT AVAILABLE with `local_backend: true`**
   **Shows "Not Found"** - This is expected behavior

3. **Collections**
   ```
   http://localhost:1313/admin/#/collections
   ```

4. **Media Library**
   ```
   http://localhost:1313/admin/#/media
   ```

---

## Testing Editorial Workflow

### In Local Mode (Current Setup)

**Step 1: Create Draft Content**

1. Open CMS: http://localhost:1313/admin/
2. Navigate to Collections → Information Pages
3. Click on a page (e.g., "About Us")
4. Make an edit
5. Click **"Save"**

**Result:** ✅ Saved to local file immediately

**Step 2: Try Workflow Status**

1. In the editor, look for status dropdown
2. Try changing status to "In Review" or "Ready"

**Result:** ⚠️ Limited - local backend doesn't create PRs

**Step 3: Check Workflow Board**

1. Navigate to: http://localhost:1313/admin/#/workflow
2. Look for columns: Drafts | In Review | Ready

**Result:** May show entries but won't behave like production workflow

---

## Full Editorial Workflow (Production Setup)

### Requirements for Full Workflow

To get the complete editorial workflow with PRs and approvals:

1. ✅ `publish_mode: editorial_workflow` (already set)
2. ❌ `local_backend: false` or removed (currently true)
3. ❌ Git Gateway configured (not yet set up)
4. ❌ GitHub/GitLab OAuth (not yet set up)
5. ❌ Repository permissions configured

---

## Enabling Full Workflow

### Option 1: Test with GitHub Backend (Recommended)

Update `static/admin/config.yml`:

```yaml
backend:
  name: github                    # Change from git-gateway
  repo: min2ha/ukwa-site          # Your repo
  branch: development

publish_mode: editorial_workflow
# Remove or comment out:
# local_backend: true
```

**Setup GitHub OAuth App:**

1. Go to GitHub → Settings → Developer settings → OAuth Apps
2. Click "New OAuth App"
3. Fill in:
   - **Application name:** UKWA CMS Local
   - **Homepage URL:** `http://localhost:1313`
   - **Authorization callback URL:** `https://api.netlify.com/auth/done`
4. Save Client ID and Secret

**Update config:**

```yaml
backend:
  name: github
  repo: min2ha/ukwa-site
  branch: development
  # Optional: for local testing
  base_url: https://api.netlify.com
  auth_endpoint: auth
```

### Option 2: Deploy to Netlify (Easiest for Full Workflow)

1. **Push to GitHub:**
   ```bash
   git add .
   git commit -m "Add Decap CMS with editorial workflow"
   git push origin development
   ```

2. **Deploy to Netlify:**
   - Go to https://netlify.com
   - Click "Add new site" → "Import from Git"
   - Connect to your repo
   - Build settings:
     - Build command: `hugo --minify`
     - Publish directory: `public`

3. **Enable Identity & Git Gateway:**
   - Netlify dashboard → Site settings → Identity
   - Click "Enable Identity"
   - Services → Git Gateway → Enable

4. **Update config.yml:**
   ```yaml
   # Remove local_backend line
   # local_backend: true  # DELETE THIS
   ```

5. **Access CMS:**
   ```
   https://your-site.netlify.app/admin/
   ```

---

## How Editorial Workflow Works (Production)

### Full Workflow Process

```
┌─────────────────────────────────────────────────────────────┐
│                    DRAFT COLUMN                             │
│  Editor creates content → Saved to draft branch             │
│  cms/draft/info/page-name                                   │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  │ Editor clicks "Set status: In Review"
                  ↓
┌─────────────────────────────────────────────────────────────┐
│                   IN REVIEW COLUMN                          │
│  Pull Request created: cms/draft/... → development          │
│  Reviewers can see the PR on GitHub                         │
│  Comments can be added                                      │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  │ Supervisor approves
                  ↓
┌─────────────────────────────────────────────────────────────┐
│                    READY COLUMN                             │
│  PR approved, ready to publish                              │
│  Supervisor clicks "Publish"                                │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  │ Publish action
                  ↓
┌─────────────────────────────────────────────────────────────┐
│                    PUBLISHED                                │
│  PR merged to development branch                            │
│  Content appears on live site                               │
│  GitHub PR closed                                           │
└─────────────────────────────────────────────────────────────┘
```

---

## User Roles in Editorial Workflow

### Supervisor Role
**What they see:**
- All three workflow columns
- Draft | In Review | Ready

**What they can do:**
- ✅ Create content
- ✅ Move content to "In Review"
- ✅ Approve content (move to "Ready")
- ✅ Publish content (merge to main branch)
- ✅ Reject content (send back to Draft)

**GitHub Permissions Needed:**
- Write access to repository
- Can merge pull requests

---

### Editor Role
**What they see:**
- Draft column
- In Review column (limited)

**What they can do:**
- ✅ Create content
- ✅ Save drafts
- ✅ Submit for review (move to "In Review")
- ❌ Cannot publish
- ❌ Cannot approve others' content

**GitHub Permissions Needed:**
- Write access to repository (to create branches/PRs)

---

### Viewer Role
**What they see:**
- All workflow columns (read-only)

**What they can do:**
- ✅ View content in all states
- ✅ See workflow status
- ❌ Cannot create content
- ❌ Cannot edit
- ❌ Cannot change status

**GitHub Permissions Needed:**
- Read access to repository

---

## Testing the Workflow Interface

### Current Setup (Local Backend)

**Test 1: Access Workflow Board**
```bash
open http://localhost:1313/admin/#/workflow
```

**Expected:**
- ✅ Page loads
- ✅ Shows three columns: Drafts | In Review | Ready
- ⚠️ May be empty or show limited functionality

**Test 2: Create Draft**
```bash
open http://localhost:1313/admin/#/collections
```
1. Click "Information Pages"
2. Click a page
3. Edit and save
4. Go to Workflow board

**Expected:**
- ⚠️ Content saved but may not appear in workflow board
- ⚠️ Local backend doesn't track workflow states the same way

---

## Workflow in Local Mode vs Production

| Feature | Local Backend | Production (Git Gateway) |
|---------|---------------|--------------------------|
| **Save drafts** | ✅ Yes | ✅ Yes |
| **Edit content** | ✅ Yes | ✅ Yes |
| **View workflow board** | ⚠️ Partial | ✅ Full |
| **Create PRs** | ❌ No | ✅ Yes |
| **In Review status** | ⚠️ Limited | ✅ Full |
| **Approval process** | ❌ No | ✅ Yes |
| **Git branches** | ❌ Manual | ✅ Automatic |
| **Multi-user** | ❌ No | ✅ Yes |
| **Access control** | ❌ No | ✅ Yes |

---

## Making Workflow Work Locally

### Workaround: Manual Git Workflow

Even with `local_backend: true`, you can simulate workflow:

**Step 1: Editor Creates Content**
```bash
# Create feature branch
git checkout -b feature/update-about-page

# Make changes in CMS
open http://localhost:1313/admin/

# Commit changes
git add content/info/about/
git commit -m "Draft: Update About page"
git push origin feature/update-about-page
```

**Step 2: Create Pull Request**
```bash
# On GitHub, create PR: feature/... → development
# Or use gh CLI:
gh pr create --base development --title "Update About page"
```

**Step 3: Review and Approve**
- Reviewer checks PR on GitHub
- Adds comments
- Approves PR

**Step 4: Merge**
```bash
# Merge PR via GitHub interface
# Or:
gh pr merge --merge
```

---

## Enabling Full Workflow (Quick Setup)

### Fastest Way: Netlify

1. **Update config (remove local_backend):**
   ```bash
   # Edit static/admin/config.yml
   # Comment out or delete:
   # local_backend: true
   ```

2. **Push to GitHub:**
   ```bash
   git add static/admin/config.yml
   git commit -m "Enable production workflow"
   git push origin development
   ```

3. **Deploy to Netlify:**
   - Import from GitHub
   - Enable Identity
   - Enable Git Gateway
   - Invite users via Identity tab

4. **Test:**
   ```
   https://your-site.netlify.app/admin/#/workflow
   ```

**Time:** ~15 minutes

---

## Verifying Workflow Setup

### Checklist

- [x] `publish_mode: editorial_workflow` in config.yml
- [x] CMS loads at /admin/
- [x] Can access /admin/#/workflow
- [ ] `local_backend: false` or removed (needed for full workflow)
- [ ] Git Gateway or GitHub backend configured
- [ ] OAuth authentication set up
- [ ] Multiple users with different roles
- [ ] Can create PRs from CMS
- [ ] Can approve and merge from CMS

**Current Status: 3/9** (Local development mode)

---

## Routes Reference

| Route | Purpose | Status |
|-------|---------|--------|
| `/admin/` | CMS dashboard | ✅ Working |
| `/admin/#/workflow` | Editorial workflow board | ✅ Accessible (limited) |
| `/admin/#/collections` | Content collections | ✅ Working |
| `/admin/#/collections/info` | Info pages | ✅ Working |
| `/admin/#/media` | Media library | ✅ Working |

---

## Next Steps

### To Enable Full Editorial Workflow

**Option A: Keep Local (Limited)**
- ✅ Continue with current setup
- ✅ Use manual Git workflow
- ⚠️ No automatic PRs
- ⚠️ No built-in approval process

**Option B: Deploy to Production (Full Features)**
1. [ ] Choose platform (Netlify recommended)
2. [ ] Deploy site
3. [ ] Enable Git Gateway
4. [ ] Configure OAuth
5. [ ] Invite users with roles
6. [ ] Test full workflow

**Option C: Hybrid (Local + GitHub Backend)**
1. [ ] Set up GitHub OAuth App
2. [ ] Update config to use `github` backend
3. [ ] Keep running locally
4. [ ] Get some workflow features without full deployment

---

## Troubleshooting

### "Workflow board is empty"
**Cause:** Local backend doesn't track workflow state
**Solution:**
- Switch to Git Gateway or GitHub backend
- Or use manual Git workflow

### "Can't change status to In Review"
**Cause:** Local backend limitations
**Solution:**
- Deploy to production with Git Gateway
- Status changes will create PRs

### "Changes appear immediately, no approval needed"
**Cause:** Local backend bypasses workflow
**Solution:**
- This is expected with `local_backend: true`
- Deploy to production for approval workflow

---

## Documentation References

- **[docs/DEVOPS_GUIDE.md](docs/DEVOPS_GUIDE.md)** - Production setup details
- **[docs/USER_GUIDE.md](docs/USER_GUIDE.md)** - Workflow for content editors
- **[README_CMS.md](README_CMS.md)** - CMS overview
- **[Decap CMS Workflow Docs](https://decapcms.org/docs/configuration-options/#publish-mode)** - Official documentation

---

## Summary

✅ **Editorial workflow is configured** (`publish_mode: editorial_workflow`)
✅ **Workflow route is available** (http://localhost:1313/admin/#/workflow)
⚠️ **Limited functionality in local mode** (`local_backend: true`)
📝 **Full workflow requires production deployment** (Netlify, GitHub, or custom Git Gateway)

**Current Status:**
- Can access workflow interface
- Can save drafts
- Limited workflow features (no PRs, no approval process)

**For Full Workflow:**
- Deploy to Netlify or similar platform
- Remove `local_backend: true`
- Configure Git Gateway
- Set up OAuth authentication
- Invite users with different roles

---

**Date:** 2025-10-28
**Status:** ✅ Editorial workflow configured, accessible but limited in local mode
**To Test Full Workflow:** Deploy to production (see [docs/DEVOPS_GUIDE.md](docs/DEVOPS_GUIDE.md))
