# Production Deployment Guide - Netlify
## Site URL: https://ukwa-static.netlify.app

---

## Quick Overview

**Site Details:**
- **URL:** https://ukwa-static.netlify.app
- **Platform:** Netlify
- **Repository:** min2ha/ukwa-site
- **Branch:** development
- **Hugo Version:** 0.111.3

**CMS Users:**
1. **Admin:** minvidm@gmail.com (Full access)
2. **Editor:** mindaugas.vidmantas@bl.uk (Content creation only)

---

## Pre-Deployment Checklist

### Files Prepared ✅

- [x] `netlify.toml` - Updated with Hugo 0.111.3
- [x] `static/admin/config.production.yml` - Production CMS config
- [x] `static/admin/config.yml` - Updated for production
- [x] Git submodules initialized (themes)
- [x] Docker build tested and working

### Required Changes Before Deploy

- [ ] Update `static/admin/config.yml` - Remove `local_backend: true`
- [ ] Commit all changes
- [ ] Push to GitHub

---

## Step-by-Step Deployment

### Phase 1: Prepare Repository (5 minutes)

#### Step 1.1: Update CMS Config for Production

```bash
# Backup current config
cp static/admin/config.yml static/admin/config.local.yml

# Remove local_backend line
sed -i.bak '/local_backend: true/d' static/admin/config.yml

# Verify change
grep "local_backend" static/admin/config.yml
# Should return nothing
```

**Or manually edit:**
```yaml
# static/admin/config.yml
# DELETE OR COMMENT THIS LINE:
# local_backend: true
```

#### Step 1.2: Commit Changes

```bash
# Check what's changed
git status

# Add files
git add static/admin/config.yml
git add netlify.toml
git add static/admin/config.production.yml

# Commit
git commit -m "chore: prepare for Netlify production deployment

- Remove local_backend from CMS config
- Update netlify.toml with Hugo 0.111.3
- Add production CMS configuration
- Configure for ukwa-static.netlify.app"

# Push to GitHub
git push origin development
```

---

### Phase 2: Deploy to Netlify (10 minutes)

#### Step 2.1: Create Netlify Site

1. **Go to Netlify Dashboard**
   - URL: https://app.netlify.com
   - Log in with your account

2. **Add New Site**
   - Click "Add new site" → "Import an existing project"
   - Choose "Deploy with GitHub"

3. **Authorize GitHub**
   - Grant Netlify access to your repositories
   - Select `min2ha/ukwa-site`

4. **Configure Build Settings**
   ```
   Branch to deploy: development
   Build command: hugo --minify
   Publish directory: public
   ```
   *(These are auto-detected from netlify.toml)*

5. **Deploy Site**
   - Click "Deploy site"
   - Wait for build to complete (~2-3 minutes)

#### Step 2.2: Set Custom Domain

1. **Go to Site Settings** → **Domain management**
2. **Options** → **Edit site name**
3. **Change to:** `ukwa-static`
4. **Save**

**Result:** Site accessible at https://ukwa-static.netlify.app

---

### Phase 3: Enable Netlify Identity (5 minutes)

#### Step 3.1: Enable Identity Service

1. Go to **Site settings** → **Identity**
2. Click **"Enable Identity"**
3. Wait for service to activate

#### Step 3.2: Configure Registration

1. **Registration** section
2. **Registration preferences** → **Invite only**
3. **Save**

This ensures only invited users can access CMS.

#### Step 3.3: External Providers (Optional)

If you want GitHub/Google login:

1. **External providers** section
2. Enable: GitHub, Google, etc.
3. Configure OAuth apps
4. Save

**Recommendation:** Start with Email/Password only for simplicity.

---

### Phase 4: Enable Git Gateway (2 minutes)

#### Step 4.1: Connect Git Gateway

1. Go to **Identity** → **Services**
2. Find **Git Gateway**
3. Click **"Enable Git Gateway"**
4. Confirm

**What this does:**
- Connects Netlify Identity to your GitHub repository
- Allows CMS to create branches and PRs
- Enables editorial workflow

---

### Phase 5: Invite Users (5 minutes)

#### Step 5.1: Invite Admin User

1. Go to **Identity** → **Invite users**
2. Enter email: `minvidm@gmail.com`
3. Click **"Send invite"**

**Email sent to minvidm@gmail.com:**
- Contains invitation link
- User clicks link to set password
- User gains access to CMS

#### Step 5.2: Invite Editor User

1. Still in **Identity** → **Invite users**
2. Enter email: `mindaugas.vidmantas@bl.uk`
3. Click **"Send invite"**

**Email sent to mindaugas.vidmantas@bl.uk:**
- Contains invitation link
- User clicks link to set password
- User gains access to CMS

---

### Phase 6: Configure User Roles (5 minutes)

#### Step 6.1: Set Admin Role

1. Go to **Identity** → Users list
2. Find: `minvidm@gmail.com`
3. Click on user
4. **User metadata** → Edit
5. Add:
   ```json
   {
     "roles": ["admin"]
   }
   ```
6. **Save**

**Admin Permissions:**
- ✅ Create content
- ✅ Edit content
- ✅ Delete content
- ✅ Approve workflow
- ✅ Publish to live site
- ✅ Manage media

#### Step 6.2: Set Editor Role

1. In **Identity** → Users list
2. Find: `mindaugas.vidmantas@bl.uk`
3. Click on user
4. **User metadata** → Edit
5. Add:
   ```json
   {
     "roles": ["editor"]
   }
   ```
6. **Save**

**Editor Permissions:**
- ✅ Create content
- ✅ Edit content
- ✅ Upload media
- ✅ Submit for review
- ❌ Cannot publish
- ❌ Cannot delete
- ❌ Cannot approve

---

### Phase 7: Test CMS Access (10 minutes)

#### Step 7.1: Access CMS

**CMS URL:**
```
https://ukwa-static.netlify.app/admin/
```

#### Step 7.2: Admin User Test

1. **Admin (minvidm@gmail.com) checks email**
2. Clicks invitation link
3. Sets password (min 8 characters)
4. Navigates to: https://ukwa-static.netlify.app/admin/
5. Logs in with email + password

**Expected:**
- ✅ Login successful
- ✅ Dashboard loads
- ✅ Can see Collections
- ✅ Can access Workflow board: https://ukwa-static.netlify.app/admin/#/workflow
- ✅ Sees three columns: Drafts | In Review | Ready

#### Step 7.3: Editor User Test

1. **Editor (mindaugas.vidmantas@bl.uk) checks email**
2. Clicks invitation link
3. Sets password
4. Navigates to: https://ukwa-static.netlify.app/admin/
5. Logs in

**Expected:**
- ✅ Login successful
- ✅ Can see Collections
- ✅ Can access Workflow board
- ✅ Can create/edit content
- ⚠️ Cannot publish (needs admin approval)

---

### Phase 8: Test Editorial Workflow (15 minutes)

#### Step 8.1: Editor Creates Content

**As Editor (mindaugas.vidmantas@bl.uk):**

1. Log in to CMS
2. Go to **Collections** → **Information Pages**
3. Click on "About Us"
4. Make a test edit (add "TEST" to title)
5. **Save**
6. Change status to **"In Review"**

**Result:**
- Creates Git branch: `cms/draft/info/about`
- Opens Pull Request on GitHub
- Content appears in "In Review" column

#### Step 8.2: Admin Reviews Content

**As Admin (minvidm@gmail.com):**

1. Log in to CMS
2. Go to **Workflow** board
3. Check **"In Review"** column
4. Click on the pending item
5. Review changes
6. Two options:
   - **Approve:** Move to "Ready"
   - **Request changes:** Send back to "Drafts" with comments

7. If approved, click **"Publish"**

**Result:**
- PR merged to `development` branch
- Content live on site
- GitHub PR closed

---

## User Management

### Admin User: minvidm@gmail.com

**Role:** Administrator / Supervisor

**Permissions:**
- ✅ Full content management
- ✅ Approve submissions
- ✅ Publish content
- ✅ Delete content
- ✅ Manage media
- ✅ Access all workflow stages

**Workflow Actions:**
- Create drafts
- Edit any content
- Move content to "In Review"
- Approve content (move to "Ready")
- Publish content (merge to main branch)
- Reject content (send back to drafts)

**GitHub Access Needed:**
- Write access to min2ha/ukwa-site
- Can merge pull requests

---

### Editor User: mindaugas.vidmantas@bl.uk

**Role:** Content Editor

**Permissions:**
- ✅ Create content
- ✅ Edit content
- ✅ Upload media
- ✅ Submit for review
- ❌ Cannot publish
- ❌ Cannot delete
- ❌ Cannot approve

**Workflow Actions:**
- Create drafts
- Edit own content
- Save drafts
- Submit for review (move to "In Review")
- Wait for admin approval

**GitHub Access Needed:**
- Write access to min2ha/ukwa-site (to create branches)
- GitHub will auto-create branches for drafts

---

## Post-Deployment Configuration

### Enable Branch Protection (Recommended)

1. Go to GitHub → min2ha/ukwa-site → Settings → Branches
2. Add rule for `development` branch:
   - ☑ Require pull request reviews before merging
   - ☑ Require status checks to pass
   - ☑ Require branches to be up to date
   - Number of required approvals: **1**

**Benefit:** Ensures all content goes through review process

### Configure Netlify Deploy Notifications

1. Netlify Dashboard → Site settings → Build & deploy
2. Deploy notifications
3. Add notifications:
   - Email on deploy started
   - Email on deploy succeeded
   - Email on deploy failed
4. Recipients: minvidm@gmail.com

### Set Up Preview Deployments

**Already enabled by default!**

When editor creates PR:
- Netlify creates preview URL
- Admin can review live preview
- URL format: `https://deploy-preview-XX--ukwa-static.netlify.app`

---

## Access URLs

| Resource | URL |
|----------|-----|
| **Live Site** | https://ukwa-static.netlify.app |
| **CMS Admin** | https://ukwa-static.netlify.app/admin/ |
| **Workflow Board** | https://ukwa-static.netlify.app/admin/#/workflow |
| **GitHub Repo** | https://github.com/min2ha/ukwa-site |
| **Netlify Dashboard** | https://app.netlify.com/sites/ukwa-static |

---

## User Login Instructions

### For Admin (minvidm@gmail.com)

**First Time:**
1. Check email for invitation from Netlify
2. Click "Accept invitation" link
3. Set a secure password (min 8 characters)
4. Navigate to: https://ukwa-static.netlify.app/admin/
5. Log in with email + password

**Subsequent Logins:**
1. Go to: https://ukwa-static.netlify.app/admin/
2. Enter email: minvidm@gmail.com
3. Enter password
4. Click "Login"

**Forgot Password:**
1. Click "Forgot password?" on login page
2. Enter email
3. Check email for reset link

---

### For Editor (mindaugas.vidmantas@bl.uk)

**First Time:**
1. Check email for invitation from Netlify
2. Click "Accept invitation" link
3. Set a secure password
4. Navigate to: https://ukwa-static.netlify.app/admin/
5. Log in with email + password

**Subsequent Logins:**
1. Go to: https://ukwa-static.netlify.app/admin/
2. Enter email: mindaugas.vidmantas@bl.uk
3. Enter password
4. Click "Login"

---

## Workflow Process

### Content Creation Flow

```
Editor creates content
    ↓
Saves as draft (Git branch created: cms/draft/...)
    ↓
Editor submits for review
    ↓
Pull Request created automatically
    ↓
Admin receives notification
    ↓
Admin reviews in CMS or GitHub
    ↓
Admin approves → Content moves to "Ready"
    ↓
Admin clicks "Publish"
    ↓
PR merged to development branch
    ↓
Netlify auto-deploys
    ↓
Content live on https://ukwa-static.netlify.app
```

**Time from submission to publish:** 2-5 minutes (after admin approval)

---

## Troubleshooting

### Issue: User didn't receive invitation email

**Solution:**
1. Check spam folder
2. In Netlify → Identity → Resend invitation
3. Or manually create user and send password reset

### Issue: Can't log in to CMS

**Check:**
- Email address is correct
- Password was set (clicked invitation link)
- Trying correct URL: https://ukwa-static.netlify.app/admin/
- Identity is enabled in Netlify

**Solution:**
- Use "Forgot password" to reset
- Or in Netlify → Identity → Resend invitation

### Issue: Editor can publish content

**Problem:** Role not set correctly

**Solution:**
1. Netlify → Identity → Find user
2. Edit metadata
3. Ensure: `{"roles": ["editor"]}`
4. Save

### Issue: Workflow board shows "Not Found"

**Problem:** Git Gateway not enabled

**Solution:**
1. Netlify → Identity → Services
2. Enable Git Gateway

### Issue: Changes not appearing on live site

**Check:**
1. Was content published (not just saved as draft)?
2. Check Netlify deploys (should auto-trigger)
3. Check build logs for errors
4. Hard refresh: Cmd+Shift+R (Mac) or Ctrl+F5 (Windows)

**Solution:**
- Trigger manual deploy in Netlify if needed

---

## Security Checklist

- [ ] Netlify Identity enabled
- [ ] Registration set to "Invite only"
- [ ] Git Gateway enabled
- [ ] Branch protection rules active
- [ ] Users invited via email only
- [ ] Passwords minimum 8 characters
- [ ] HTTPS enforced (automatic on Netlify)
- [ ] Security headers configured in netlify.toml

---

## Backup and Recovery

### Content Backup

**Automatic via Git:**
- Every change is committed to GitHub
- Full version history available
- Can revert to any previous version

**Manual Backup:**
```bash
git clone https://github.com/min2ha/ukwa-site.git ukwa-backup
cd ukwa-backup
git checkout development
```

### Restore Previous Version

**Via GitHub:**
1. Find commit with desired content
2. Revert commit or cherry-pick

**Via CMS:**
- Editorial workflow keeps PRs
- Can re-open closed PRs if needed

---

## Monitoring

### Check Site Health

**Site Status:**
```
https://ukwa-static.netlify.app
```
Should load without errors.

**CMS Status:**
```
https://ukwa-static.netlify.app/admin/
```
Should show login or CMS interface.

### Monitor Builds

1. Netlify Dashboard → Deploys
2. Check recent deployments
3. Review build logs for errors

### Monitor Usage

1. Netlify Dashboard → Analytics
2. Check:
   - Page views
   - Build minutes used
   - Bandwidth used

---

## Costs

**Netlify Free Tier Includes:**
- ✅ 100 GB bandwidth/month
- ✅ 300 build minutes/month
- ✅ 1,000 Identity active users
- ✅ Unlimited sites
- ✅ HTTPS
- ✅ Continuous deployment

**Current Project Usage:**
- Build time: ~2 minutes per deploy
- Expected deploys: ~50/month (with editorial workflow)
- Bandwidth: Depends on traffic

**Recommendation:** Free tier sufficient for UKWA project

---

## Next Steps After Deployment

### Immediate (Day 1)
- [ ] Verify deployment successful
- [ ] Both users received and accepted invitations
- [ ] Test login for both users
- [ ] Test creating draft content
- [ ] Test workflow (draft → review → publish)

### Week 1
- [ ] Train users on CMS interface
- [ ] Share USER_GUIDE.md with users
- [ ] Monitor first few content updates
- [ ] Adjust workflow if needed

### Month 1
- [ ] Review analytics
- [ ] Gather user feedback
- [ ] Optimize workflow
- [ ] Consider adding more users if needed

---

## Support Contacts

**Admin User:**
- Email: minvidm@gmail.com
- Role: Full administrator access
- Contact for: Approvals, publishing, user management

**Editor User:**
- Email: mindaugas.vidmantas@bl.uk
- Role: Content creation
- Contact for: Content questions

**Technical Support:**
- Netlify: https://www.netlify.com/support/
- Decap CMS: https://github.com/decaporg/decap-cms/discussions
- This repository: https://github.com/min2ha/ukwa-site/issues

---

## Documentation References

- [CMS_INTEGRATION_README.md](CMS_INTEGRATION_README.md) - CMS overview
- [docs/USER_GUIDE.md](docs/USER_GUIDE.md) - For content editors
- [docs/DEVOPS_GUIDE.md](docs/DEVOPS_GUIDE.md) - Technical details
- [AUTHENTICATION_GUIDE.md](AUTHENTICATION_GUIDE.md) - Auth setup
- [EDITORIAL_WORKFLOW_GUIDE.md](EDITORIAL_WORKFLOW_GUIDE.md) - Workflow details

---

**Deployment Date:** 2025-10-28
**Prepared by:** DevOps Team
**Site URL:** https://ukwa-static.netlify.app
**Status:** Ready for deployment

---

## Quick Deployment Summary

**Time Required:** ~45 minutes total

1. ✅ Update config (5 min)
2. ✅ Deploy to Netlify (10 min)
3. ✅ Enable Identity (5 min)
4. ✅ Enable Git Gateway (2 min)
5. ✅ Invite users (5 min)
6. ✅ Set roles (5 min)
7. ✅ Test access (10 min)
8. ✅ Test workflow (15 min)

**Users Created:**
1. **minvidm@gmail.com** - Admin role
2. **mindaugas.vidmantas@bl.uk** - Editor role

**Site will be live at:** https://ukwa-static.netlify.app 🚀
