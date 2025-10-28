# Production Deployment Checklist
## Site: ukwa-static.netlify.app

## ⚠️ IMPORTANT: Using GitHub Backend (Not Netlify Identity)

**Netlify Identity is deprecated.** This deployment uses **GitHub Backend** instead.

**What this means:**
- ✅ Users login with GitHub accounts
- ✅ Simpler setup (~25 min vs 45 min)
- ✅ No deprecated services
- ✅ No Identity/Auth0 setup needed

**See:** [PRODUCTION_DEPLOYMENT_AUTH0.md](PRODUCTION_DEPLOYMENT_AUTH0.md) for details.

---

## Pre-Deployment

### Repository Preparation
- [ ] Update `static/admin/config.yml` - Change to GitHub backend
- [ ] Remove `local_backend: true` line
- [ ] Verify `netlify.toml` is configured (Hugo 0.111.3)
- [ ] Commit all changes
- [ ] Push to GitHub `development` branch

### Quick Command
```bash
# Update config to use GitHub backend
# Edit static/admin/config.yml:
# Change line: backend:
#              name: github  (instead of git-gateway)
# Remove line: local_backend: true

# Or use this one-liner:
sed -i.bak -e 's/name: git-gateway/name: github/' -e '/local_backend: true/d' static/admin/config.yml

# Commit
git add static/admin/config.yml netlify.toml
git commit -m "feat: use GitHub backend for authentication"
git push origin development
```

---

## Netlify Deployment

### Site Creation
- [ ] Log in to https://app.netlify.com
- [ ] Click "Add new site" → "Import from Git"
- [ ] Connect GitHub → Select `min2ha/ukwa-site`
- [ ] Configure:
  - Branch: `development`
  - Build command: `hugo --minify`
  - Publish directory: `public`
- [ ] Click "Deploy site"
- [ ] Wait for first build (~2-3 minutes)

### Custom Domain
- [ ] Go to Site settings → Domain management
- [ ] Edit site name → Change to: `ukwa-static`
- [ ] Verify URL: https://ukwa-static.netlify.app

---

## GitHub Repository Access

### Add Admin User
- [ ] Go to: https://github.com/min2ha/ukwa-site/settings/access
- [ ] Click "Invite a collaborator"
- [ ] Email/username: `minvidm@gmail.com`
- [ ] Role: **Maintain** (or Admin)
- [ ] Send invitation
- [ ] ✉️ User receives GitHub invitation email

### Add Editor User
- [ ] Click "Invite a collaborator"
- [ ] Email/username: `mindaugas.vidmantas@bl.uk`
- [ ] Role: **Write**
- [ ] Send invitation
- [ ] ✉️ User receives GitHub invitation email

### Enable Branch Protection
- [ ] Go to: https://github.com/min2ha/ukwa-site/settings/branches
- [ ] Click "Add rule"
- [ ] Branch name pattern: `development`
- [ ] Settings to enable:
  - [x] Require pull request reviews before merging
  - [x] Required number of approvals: 1
  - [x] Dismiss stale pull request approvals when new commits are pushed
  - [x] Require review from Code Owners (optional)
- [ ] Save changes

**This ensures editor cannot merge their own PRs!**

---

## Testing

### Verify Deployment
- [ ] Visit: https://ukwa-static.netlify.app
- [ ] Site loads without errors
- [ ] Check multiple pages work
- [ ] Verify images load

### CMS Access - Admin
- [ ] Admin accepts GitHub repository invitation
- [ ] Navigate to: https://ukwa-static.netlify.app/admin/
- [ ] Click "Login with GitHub"
- [ ] Authorize application (first time only)
- [ ] Dashboard loads successfully
- [ ] Can access Workflow board: `/admin/#/workflow`
- [ ] Sees three columns: Drafts | In Review | Ready

### CMS Access - Editor
- [ ] Editor accepts GitHub repository invitation
- [ ] Navigate to: https://ukwa-static.netlify.app/admin/
- [ ] Click "Login with GitHub"
- [ ] Authorize application (first time only)
- [ ] Dashboard loads successfully
- [ ] Can access Collections

### Workflow Test
- [ ] Editor creates test edit
- [ ] Editor saves draft
- [ ] Editor submits for review
- [ ] Admin sees in "In Review" column
- [ ] Admin approves
- [ ] Admin publishes
- [ ] Changes appear on live site
- [ ] GitHub PR created and merged

---

## Post-Deployment

### GitHub Configuration
- [ ] Enable branch protection for `development`
- [ ] Require PR reviews before merging
- [ ] Require status checks to pass

### Notifications
- [ ] Configure deploy notifications (optional)
- [ ] Add email: minvidm@gmail.com

### Documentation
- [ ] Share with users:
  - [ ] `docs/USER_GUIDE.md` (for both users)
  - [ ] `PRODUCTION_DEPLOYMENT.md` (for admin)
  - [ ] Access URLs

### Training
- [ ] Schedule CMS training session
- [ ] Walk through editorial workflow
- [ ] Answer questions

---

## Verification Checklist

### URLs Working
- [ ] https://ukwa-static.netlify.app
- [ ] https://ukwa-static.netlify.app/admin/
- [ ] https://ukwa-static.netlify.app/admin/#/workflow
- [ ] https://ukwa-static.netlify.app/en/ukwa/
- [ ] https://ukwa-static.netlify.app/cy/ukwa/
- [ ] https://ukwa-static.netlify.app/gd/ukwa/

### Users Created
- [ ] minvidm@gmail.com (Admin role)
- [ ] mindaugas.vidmantas@bl.uk (Editor role)

### Features Working
- [ ] Content editing
- [ ] Media upload
- [ ] Editorial workflow
- [ ] Multi-language support
- [ ] Preview deployments
- [ ] Auto-deploy on merge

---

## Rollback Plan

If something goes wrong:

### Option 1: Revert Config
```bash
# Restore local_backend
git checkout static/admin/config.yml
git commit -m "rollback: restore local backend"
git push origin development
```

### Option 2: Pause Deploys
- [ ] Netlify → Site settings → Build & deploy
- [ ] Stop builds
- [ ] Fix issues
- [ ] Resume builds

### Option 3: Revert to Previous Deploy
- [ ] Netlify → Deploys
- [ ] Find last working deploy
- [ ] Click "Publish deploy"

---

## Success Criteria

✅ **Deployment Successful When:**
- Site accessible at https://ukwa-static.netlify.app
- CMS accessible at /admin/
- Both users can log in
- Editorial workflow functional
- Content can be published
- No build errors

---

## Timeline

| Phase | Duration | Status |
|-------|----------|--------|
| Pre-deployment | 5 min | ⏳ |
| Netlify setup | 10 min | ⏳ |
| Identity & Gateway | 7 min | ⏳ |
| User setup | 10 min | ⏳ |
| Testing | 15 min | ⏳ |
| **Total** | **~45 min** | ⏳ |

---

## Contacts

**Admin:** minvidm@gmail.com
**Editor:** mindaugas.vidmantas@bl.uk
**Site URL:** https://ukwa-static.netlify.app
**Repository:** https://github.com/min2ha/ukwa-site

---

## Notes

- Netlify free tier sufficient for this project
- First deployment may take longer (~5 min)
- Subsequent deploys: ~2 min
- Users must accept email invitations within 7 days

---

**Status:** Ready for deployment ✅
**Date:** 2025-10-28
