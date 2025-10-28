# Decap CMS Authentication Guide

## Local Backend: No Authentication Required

### Current Setup (`local_backend: true`)

**Important:** With `local_backend: true`, there is **NO authentication or password system**.

```yaml
# static/admin/config.yml
local_backend: true  # Authentication DISABLED
```

**How it works:**
- ✅ Open http://localhost:1313/admin/ directly
- ✅ No login required
- ✅ No username or password needed
- ✅ Works with local filesystem
- ⚠️ Anyone with access to localhost can edit content
- ⚠️ No user roles enforced
- ⚠️ No workflow board (`/admin/#/workflow` not available)

**User files are for reference only:**
- `cms-config/users/supervisor.json` - Documentation only
- `cms-config/users/editor.json` - Documentation only
- `cms-config/users/viewer.json` - Documentation only

These files define what roles **will be** used in production, but have no effect in local mode.

---

## Why No Authentication in Local Mode?

**By design:**
- Local backend is for solo development
- You're already "authenticated" by having filesystem access
- Faster development workflow
- No external services needed

**Security:**
- Only accessible on localhost
- Not exposed to internet
- Your OS user permissions protect the files

---

## To Enable Authentication & User Roles

You need to switch from local backend to a production backend. Here are your options:

---

## Option 1: Test Backend (Simplest - No Real Auth)

For testing the CMS interface without real authentication:

### Update config.yml:

```yaml
backend:
  name: test-repo
  # Remove or comment out:
  # local_backend: true

publish_mode: editorial_workflow
```

**How it works:**
- Fake backend in memory
- No real Git operations
- Can test UI including workflow board
- No passwords still (test mode)

**Access:**
```
http://localhost:1313/admin/
```

**Limitations:**
- Changes not saved to real files
- No actual Git commits
- Just for UI testing

---

## Option 2: GitHub Backend (Local Development with Real Auth)

This gives you real authentication while still running locally.

### Step 1: Create GitHub OAuth App

1. Go to: https://github.com/settings/developers
2. Click "OAuth Apps" → "New OAuth App"
3. Fill in:
   ```
   Application name: UKWA CMS Local Dev
   Homepage URL: http://localhost:1313
   Authorization callback URL: https://api.netlify.com/auth/done
   ```
4. Click "Register application"
5. Copy the **Client ID** and **Client Secret**

### Step 2: Set up Netlify OAuth Gateway (Free)

```bash
# Install netlify-cms-proxy-server (for local OAuth)
npm install -g netlify-cms-proxy-server

# Or use npx (no install needed)
npx netlify-cms-proxy-server
```

### Step 3: Update config.yml

```yaml
backend:
  name: github
  repo: min2ha/ukwa-site
  branch: development

publish_mode: editorial_workflow

# For local development with GitHub auth:
local_backend:
  url: http://localhost:8081/api/v1
```

### Step 4: Start proxy server

```bash
# Terminal 1: Start proxy
npx netlify-cms-proxy-server

# Terminal 2: Start Hugo
./start-cms-local.sh

# Access CMS
open http://localhost:1313/admin/
```

**Authentication:**
- You'll be redirected to GitHub to authorize
- Your GitHub account is used for authentication
- Real Git commits are made with your GitHub identity

---

## Option 3: Netlify Identity (Production - Full Auth)

This is the complete solution with real user accounts and passwords.

### Step 1: Deploy to Netlify

```bash
# Push your code
git add .
git commit -m "Prepare for Netlify deployment"
git push origin development
```

### Step 2: Create Netlify Site

1. Go to https://netlify.com
2. Click "Add new site" → "Import an existing project"
3. Connect to GitHub
4. Select `min2ha/ukwa-site`
5. Build settings:
   - Branch: `development`
   - Build command: `hugo --minify`
   - Publish directory: `public`
6. Click "Deploy site"

### Step 3: Enable Netlify Identity

1. In Netlify dashboard → Site settings → Identity
2. Click "Enable Identity"
3. Registration → Set to "Invite only"
4. External providers (optional):
   - Enable GitHub, Google, etc.

### Step 4: Enable Git Gateway

1. Identity → Services → Git Gateway
2. Click "Enable Git Gateway"
3. This connects Identity to your GitHub repo

### Step 5: Update config.yml

```yaml
backend:
  name: git-gateway
  repo: min2ha/ukwa-site
  branch: development

publish_mode: editorial_workflow

# Remove this line:
# local_backend: true
```

### Step 6: Invite Users

1. Netlify dashboard → Identity → Invite users
2. Enter email addresses:
   - supervisor@ukwa.org
   - editor@ukwa.org
   - viewer@ukwa.org
3. Users receive email invitations
4. They set their own passwords

### Step 7: Set User Roles

**In Netlify Identity:**

1. Go to Identity → User list
2. Click on a user
3. Edit metadata:

**For Supervisor:**
```json
{
  "roles": ["admin"]
}
```

**For Editor:**
```json
{
  "roles": ["editor"]
}
```

**For Viewer:**
```json
{
  "roles": ["viewer"]
}
```

### Step 8: Configure Role-Based Access (Optional)

Update `config.yml` to enforce roles:

```yaml
backend:
  name: git-gateway
  repo: min2ha/ukwa-site
  branch: development

publish_mode: editorial_workflow

# Role-based collections (optional)
collections:
  - name: "info"
    label: "Information Pages"
    folder: content/info
    create: true
    delete: true
    # Only admins can delete
    fields:
      - {label: 'Title', name: 'title', widget: 'string'}
```

**Access CMS:**
```
https://your-site.netlify.app/admin/
```

**Login:**
- Users enter their email and password
- Set during invitation process
- Can be reset via "Forgot password"

---

## Authentication Comparison

| Feature | Local Backend | GitHub Backend | Netlify Identity |
|---------|---------------|----------------|------------------|
| **Passwords** | ❌ None | 🔐 GitHub account | 🔐 User passwords |
| **User Roles** | ❌ No | ⚠️ Via GitHub perms | ✅ Full role system |
| **Workflow Board** | ❌ Not available | ✅ Available | ✅ Available |
| **Multi-user** | ❌ No | ✅ Yes | ✅ Yes |
| **Setup Time** | ⚡ 0 min | 🕐 30 min | 🕐 45 min |
| **Cost** | 💰 Free | 💰 Free | 💰 Free (limits apply) |
| **Internet Required** | ❌ No | ✅ Yes | ✅ Yes |
| **Best For** | Solo dev | Team dev (local) | Production |

---

## Quick Setup: Enable Basic Auth (Netlify)

If you want passwords ASAP:

### Fastest Path (~15 minutes)

```bash
# 1. Update config - remove local_backend
sed -i.bak '/local_backend/d' static/admin/config.yml

# 2. Commit and push
git add static/admin/config.yml
git commit -m "Enable Netlify Identity"
git push origin development

# 3. Deploy to Netlify (via web UI)
# 4. Enable Identity in Netlify dashboard
# 5. Enable Git Gateway
# 6. Invite users via Identity tab
```

**Users will receive emails to set passwords.**

---

## Setting Passwords for Different Setups

### Local Backend (Current)
```
No passwords available - authentication disabled
```

### Test Backend
```
No passwords - UI testing only
```

### GitHub Backend
```
Password = Your GitHub password
Users authenticate via GitHub OAuth
```

### Netlify Identity
```
1. Netlify sends invitation email
2. User clicks link in email
3. User sets their own password
4. Password stored securely by Netlify
5. Can be reset via "Forgot password" link
```

---

## Security Considerations

### Local Backend Security

**Current setup is secure because:**
- ✅ Only accessible on localhost
- ✅ Not exposed to internet
- ✅ OS-level file permissions apply
- ✅ Perfect for solo development

**Not secure if:**
- ❌ You expose localhost to internet (don't do this)
- ❌ Multiple untrusted users on same machine

### Production Security

**Netlify Identity provides:**
- ✅ Password hashing (bcrypt)
- ✅ Rate limiting
- ✅ Email verification
- ✅ Password reset flow
- ✅ 2FA support (optional)
- ✅ JWT-based sessions

---

## User Management Examples

### Example 1: Solo Developer (Current Setup)

**Use:** Local backend
**Auth:** None needed
**Access:** http://localhost:1313/admin/

```yaml
local_backend: true
```

### Example 2: Small Team (3-5 people)

**Use:** GitHub backend
**Auth:** GitHub accounts
**Setup:**

```yaml
backend:
  name: github
  repo: min2ha/ukwa-site
  branch: development
```

**User management:**
- Add collaborators on GitHub
- Admin = Write access
- Editor = Write access
- Viewer = Read access

### Example 3: Organization (10+ people)

**Use:** Netlify Identity
**Auth:** Email/password
**Setup:**

```yaml
backend:
  name: git-gateway
  repo: min2ha/ukwa-site
```

**User management:**
- Invite via Netlify dashboard
- Assign roles in Identity metadata
- Control access per collection

---

## Troubleshooting

### "I want passwords but keep local_backend"

**Not possible.** Local backend specifically disables authentication.

**Solution:** Use GitHub or Netlify backend.

### "Can I use test-repo with passwords?"

**No.** Test backend is for UI testing only, no real auth.

**Solution:** Use GitHub or Netlify backend.

### "How do I test workflow with authentication?"

**Option A: Deploy to Netlify**
- Fastest way to test with real users
- 15 minutes setup

**Option B: Use GitHub backend locally**
- Test with GitHub authentication
- 30 minutes setup

---

## Summary: How to Enable Passwords

### For Local Development
**You can't set passwords with `local_backend: true`**

**To get passwords:**
1. Choose a backend (GitHub or Netlify)
2. Remove `local_backend: true` from config
3. Set up authentication provider
4. Users get passwords through OAuth (GitHub) or invitations (Netlify)

### Quick Answer

**Current setup:** No passwords (local_backend mode)

**To add passwords (fastest):**
1. Deploy to Netlify
2. Enable Identity
3. Invite users via email
4. Users set own passwords

**Time:** ~15 minutes

---

## Next Steps

### Stay with Local Backend (No Auth)
- ✅ Continue as-is
- ✅ Perfect for solo development
- ❌ No passwords needed or available

### Enable Authentication
1. [ ] Choose backend (Netlify recommended)
2. [ ] Update config.yml
3. [ ] Deploy (if using Netlify)
4. [ ] Enable Identity/Git Gateway
5. [ ] Invite users
6. [ ] Users set passwords

---

## Documentation

- **[docs/DEVOPS_GUIDE.md](docs/DEVOPS_GUIDE.md)** - Detailed authentication setup
- **[EDITORIAL_WORKFLOW_GUIDE.md](EDITORIAL_WORKFLOW_GUIDE.md)** - Workflow configuration
- **[Netlify Identity Docs](https://docs.netlify.com/visitor-access/identity/)** - Official documentation
- **[Decap CMS Auth](https://decapcms.org/docs/authentication-backends/)** - Authentication backends

---

**Date:** 2025-10-28
**Current Mode:** Local backend (no authentication)
**To Enable Passwords:** Deploy to Netlify with Identity enabled

---

## Quick Commands

### Check Current Mode
```bash
grep "local_backend" static/admin/config.yml
# If shows "local_backend: true" → No authentication
```

### Enable Production Auth (Netlify)
```bash
# Remove local_backend
sed -i.bak '/local_backend/d' static/admin/config.yml

# Deploy to Netlify (manual via web UI)
# Then enable Identity + Git Gateway
```

### Test with GitHub Auth (Local)
```bash
# Install proxy server
npm install -g netlify-cms-proxy-server

# Update config to use GitHub backend
# Start proxy: npx netlify-cms-proxy-server
# Access: http://localhost:1313/admin/
```

---

**Bottom Line:** With `local_backend: true`, there are no passwords and no authentication. To enable user accounts with passwords, you need to switch to Netlify Identity or GitHub authentication.
