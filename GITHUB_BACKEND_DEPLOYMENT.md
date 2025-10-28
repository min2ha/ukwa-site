# ✅ Recommended: GitHub Backend Deployment
## Avoiding Deprecated Netlify Identity

---

## 🎯 Quick Summary

**Problem:** Netlify Identity is deprecated
**Solution:** Use GitHub Backend (direct OAuth)
**Time:** ~25 minutes
**Users:** minvidm@gmail.com (admin), mindaugas.vidmantas@bl.uk (editor)

---

## Why GitHub Backend?

✅ **No Deprecated Services**
- Netlify Identity is deprecated
- GitHub Backend is actively maintained
- Future-proof solution

✅ **Simpler Setup**
- No separate auth service
- No Identity configuration
- No Git Gateway setup needed
- Just GitHub repository permissions

✅ **Better for Your Use Case**
- Both users likely have GitHub accounts
- Direct repository integration
- Natural workflow for developers

✅ **Free Forever**
- No additional costs
- No user limits
- No feature restrictions

---

## Configuration Change

### From (Local Development):
```yaml
backend:
  name: git-gateway
  repo: min2ha/ukwa-site
  branch: development

local_backend: true
```

### To (Production with GitHub):
```yaml
backend:
  name: github              # Changed from git-gateway
  repo: min2ha/ukwa-site
  branch: development

# local_backend removed
```

**That's it!** Just change backend name and remove local_backend.

---

## Step-by-Step Deployment

### Step 1: Update Config (2 min)

```bash
# Edit static/admin/config.yml
# Change:
#   name: git-gateway → name: github
# Remove:
#   local_backend: true

# Quick command:
sed -i.bak -e 's/name: git-gateway/name: github/' -e '/local_backend: true/d' static/admin/config.yml
```

### Step 2: Commit and Push (1 min)

```bash
git add static/admin/config.yml
git commit -m "feat: use GitHub backend for authentication"
git push origin development
```

### Step 3: Deploy to Netlify (10 min)

1. Go to https://app.netlify.com
2. "Add new site" → "Import from Git"
3. Authorize Netlify → Select `min2ha/ukwa-site`
4. Settings:
   - Branch: `development`
   - Build: `hugo --minify`
   - Publish: `public`
5. Deploy!
6. Change site name to `ukwa-static`

### Step 4: Invite GitHub Collaborators (5 min)

**Go to:** https://github.com/min2ha/ukwa-site/settings/access

**Invite Admin:**
- Email: minvidm@gmail.com
- Role: **Maintain** (can merge PRs)

**Invite Editor:**
- Email: mindaugas.vidmantas@bl.uk
- Role: **Write** (can create PRs)

Users will receive GitHub invitation emails.

### Step 5: Enable Branch Protection (3 min)

**Go to:** https://github.com/min2ha/ukwa-site/settings/branches

1. Add rule for `development` branch
2. Enable:
   - ☑ Require pull request reviews before merging
   - ☑ Required approvals: 1
3. Save

**This ensures editor cannot merge without admin approval!**

### Step 6: Users Access CMS (2 min each)

**Both users:**
1. Accept GitHub repository invitation
2. Go to: https://ukwa-static.netlify.app/admin/
3. Click "Login with GitHub"
4. Authorize app (first time only)
5. Start editing!

---

## User Instructions

### Admin: minvidm@gmail.com

**Requirements:**
- GitHub account
- Repository access (Maintain role)

**First Login:**
1. Check email for GitHub repository invitation
2. Accept invitation
3. Navigate to: https://ukwa-static.netlify.app/admin/
4. Click "Login with GitHub"
5. Click "Authorize" when prompted
6. ✅ You're in!

**Permissions:**
- ✅ Create/edit all content
- ✅ Review pull requests
- ✅ Approve and publish content
- ✅ Access full workflow board

---

### Editor: mindaugas.vidmantas@bl.uk

**Requirements:**
- GitHub account
- Repository access (Write role)

**First Login:**
1. Check email for GitHub repository invitation
2. Accept invitation
3. Navigate to: https://ukwa-static.netlify.app/admin/
4. Click "Login with GitHub"
5. Click "Authorize" when prompted
6. ✅ You're in!

**Permissions:**
- ✅ Create/edit content
- ✅ Submit for review (creates GitHub PR)
- ⚠️ Cannot merge PRs (needs admin approval)

---

## How It Works

### Authentication Flow

```
User visits /admin/
    ↓
Clicks "Login with GitHub"
    ↓
Redirected to GitHub OAuth
    ↓
Authorizes application
    ↓
Redirected back to CMS
    ↓
Authenticated via GitHub account
    ↓
Permissions based on repository role
```

### Editorial Workflow

```
Editor creates content
    ↓
Saves draft (Git branch: cms/draft/...)
    ↓
Submits for review
    ↓
GitHub PR created automatically
    ↓
Admin receives GitHub notification
    ↓
Admin reviews in CMS or GitHub
    ↓
Admin approves and publishes
    ↓
PR merged to development
    ↓
Netlify auto-deploys (~2 min)
    ↓
Content live on site!
```

---

## Comparison

| Feature | Netlify Identity | GitHub Backend |
|---------|------------------|----------------|
| **Status** | ⚠️ Deprecated | ✅ Active |
| **Setup Time** | 45 min | 25 min |
| **Auth Service** | Separate | Built-in |
| **User Management** | Netlify dashboard | GitHub repo |
| **Login Method** | Email/password | GitHub OAuth |
| **Cost** | Free tier | Free |
| **Future Support** | ❌ No | ✅ Yes |

---

## Advantages

### No Separate Auth Service
- No Netlify Identity setup
- No Auth0 configuration
- No user database to maintain
- One less service to manage

### Natural Integration
- Users already on GitHub
- Repository permissions = CMS permissions
- Git-based workflow throughout
- Audit trail via Git history

### Simpler Architecture

**With Netlify Identity (deprecated):**
```
CMS → Netlify Identity → Git Gateway → GitHub
```

**With GitHub Backend:**
```
CMS → GitHub (direct)
```

### Future-Proof
- Not deprecated
- Active development
- Large community
- Will continue working

---

## FAQ

### "Do users need GitHub accounts?"

**Yes.** Both users must have GitHub accounts.

**Why this is good:**
- Professional development tool
- Both users likely already have accounts
- Free to create if needed
- Better audit trail

### "Can we use email/password instead?"

**Yes, but not recommended** due to Netlify Identity deprecation.

**Alternative:** Auth0 integration (see PRODUCTION_DEPLOYMENT_AUTH0.md)

**Recommendation:** Stick with GitHub backend - simpler and future-proof.

### "How do we control permissions?"

**Via GitHub repository roles:**
- **Maintain/Admin** = Full CMS access (can publish)
- **Write** = Content creation (cannot publish)
- **Read** = View only (no CMS access)

**Plus branch protection:**
- Requires PR reviews
- Editor cannot merge own PRs
- Admin must approve

### "What if user doesn't have GitHub account?"

**Two options:**
1. **Recommended:** User creates free GitHub account
2. **Alternative:** Use Auth0 (more complex, see other guide)

### "Is this secure?"

**Yes!**
- ✅ OAuth 2.0 authentication
- ✅ HTTPS only
- ✅ Repository permissions enforced
- ✅ Branch protection rules
- ✅ Full audit trail via Git

---

## Testing

After deployment, verify:

- [ ] https://ukwa-static.netlify.app loads
- [ ] https://ukwa-static.netlify.app/admin/ shows "Login with GitHub"
- [ ] Admin can log in with GitHub
- [ ] Editor can log in with GitHub
- [ ] Admin can access workflow board
- [ ] Editor can create draft
- [ ] Editor can submit for review (creates PR)
- [ ] Admin sees PR in GitHub
- [ ] Admin can approve and publish
- [ ] Changes appear on live site

---

## Troubleshooting

### "Login with GitHub button not appearing"

**Check:**
1. Config has `name: github` (not `git-gateway`)
2. Pushed changes to GitHub
3. Netlify rebuilt site with new config

**Fix:**
```bash
# Verify config
grep "name: github" static/admin/config.yml

# Force rebuild
git commit --allow-empty -m "trigger rebuild"
git push
```

### "User can't access CMS"

**Check:**
1. User has GitHub account
2. User invited to repository
3. User accepted invitation

**Fix:**
- Resend repository invitation
- Verify user's email on GitHub matches invitation

### "Editor can merge their own PRs"

**Problem:** Branch protection not enabled

**Fix:**
1. GitHub → Settings → Branches
2. Add rule for `development`
3. Enable "Require pull request reviews"

---

## Files to Update

### Required Change:
- `static/admin/config.yml` - Change `name: github`, remove `local_backend`

### Already Prepared:
- `netlify.toml` - Hugo 0.111.3 configured
- Themes - Git submodules initialized
- Docker - Build tested and working

---

## Timeline

| Phase | Time | Task |
|-------|------|------|
| Config update | 2 min | Edit config.yml |
| Commit/push | 1 min | Git operations |
| Netlify deploy | 10 min | Create site, first build |
| GitHub access | 5 min | Invite collaborators |
| Branch protection | 3 min | Enable PR reviews |
| User testing | 4 min | Both users log in |
| **Total** | **25 min** | Complete deployment |

---

## Summary

✅ **Simplest Solution**
- No deprecated services
- Direct GitHub OAuth
- 25 minute setup

✅ **Perfect for Your Project**
- 2 users with GitHub accounts
- Developer-friendly workflow
- Free forever

✅ **Fully Functional**
- Complete editorial workflow
- Role-based permissions
- All CMS features working

---

## Next Steps

1. **Update config** - Change to GitHub backend
2. **Commit and push** - Deploy changes
3. **Deploy to Netlify** - Create site
4. **Invite users** - Add GitHub collaborators
5. **Test** - Verify everything works

**Detailed steps:** [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)

---

**Status:** ✅ Recommended approach
**Time:** ~25 minutes
**Cost:** $0/month
**Support:** Active and ongoing

This is the best path forward! 🚀
