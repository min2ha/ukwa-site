# DevOps Guide: Git-based CMS with Decap CMS
## UKWA Website - Technical Implementation Guide

---

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Local Development Setup](#local-development-setup)
3. [Production Deployment](#production-deployment)
4. [Git Gateway Configuration](#git-gateway-configuration)
5. [User Management](#user-management)
6. [Workflow and Branch Strategy](#workflow-and-branch-strategy)
7. [CI/CD Integration](#cicd-integration)
8. [Security Considerations](#security-considerations)
9. [Troubleshooting](#troubleshooting)
10. [Caveats and Limitations](#caveats-and-limitations)
11. [Monitoring and Maintenance](#monitoring-and-maintenance)

---

## Architecture Overview

### System Components

```
┌─────────────────────────────────────────────────────────────┐
│                       Users (Browser)                        │
└────────────┬────────────────────────────────────┬───────────┘
             │                                     │
             ├─ Content Editors                   │
             ├─ Supervisors                       │
             └─ Viewers                           │
                          │                        │
                          ↓                        ↓
┌─────────────────────────────────┐  ┌──────────────────────────┐
│      Decap CMS Interface        │  │    Hugo Static Site      │
│  (Static JS App in /admin/)     │  │  (Public Website)        │
└────────────┬────────────────────┘  └──────────────────────────┘
             │
             ↓
┌─────────────────────────────────┐
│       Git Gateway / OAuth        │
│  (Netlify, GitHub, or custom)   │
└────────────┬────────────────────┘
             │
             ↓
┌─────────────────────────────────┐
│      Git Repository             │
│   (GitHub: ukwa/ukwa-site)      │
│                                 │
│  ├─ content/ (Markdown files)  │
│  ├─ static/admin/ (CMS)        │
│  └─ config.toml                │
└────────────┬────────────────────┘
             │
             ↓
┌─────────────────────────────────┐
│     CI/CD Pipeline              │
│  (GitHub Actions, Azure, etc.)  │
└────────────┬────────────────────┘
             │
             ↓
┌─────────────────────────────────┐
│     Static Hosting              │
│  (Azure Static Web Apps,        │
│   Netlify, or custom CDN)       │
└─────────────────────────────────┘
```

### Data Flow

**Content Creation Flow:**
```
Editor creates content
    ↓
Decap CMS saves to Git (branch)
    ↓
Supervisor reviews (PR workflow)
    ↓
Merge to master
    ↓
CI/CD builds Hugo site
    ↓
Deploy to production
    ↓
Content live on website
```

---

## Local Development Setup

### Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- Git 2.30+
- Node.js 18+ (for npx decap-server)
- Hugo 0.111+ (optional, for local builds)

### Quick Start

1. **Clone the repository:**
```bash
git clone https://github.com/ukwa/ukwa-site.git
cd ukwa-site
```

2. **Start the development environment:**
```bash
./start-cms-local.sh
```

This starts:
- Hugo development server on `http://localhost:1313`
- Decap CMS admin on `http://localhost:1313/admin/`
- Git Gateway proxy on `http://localhost:8081`

3. **Access the CMS:**
- Navigate to `http://localhost:1313/admin/`
- With `local_backend: true`, Decap CMS works directly with local files
- No authentication needed in local mode

### Manual Setup (Alternative)

If you prefer not to use Docker:

1. **Install Decap Server:**
```bash
npm install -g decap-server
```

2. **Start Decap Server:**
```bash
npx decap-server
```

3. **Start Hugo:**
```bash
hugo server -D
```

4. **Access CMS:**
```bash
open http://localhost:1313/admin/
```

### Local Backend Configuration

In `static/admin/config.yml`:
```yaml
local_backend: true  # Enable for local development
```

**How it works:**
- Decap Server runs a proxy on port 8081
- Changes are written directly to local Git repository
- No commits are created automatically
- You control when to commit and push

**Benefits:**
- Fast development cycle
- Offline capable
- No external dependencies
- Full Git control

---

## Production Deployment

### Option 1: Netlify (Recommended for Easy Setup)

Netlify provides built-in Git Gateway and Identity management.

#### Setup Steps:

1. **Deploy to Netlify:**
```bash
# Connect your GitHub repo to Netlify via web UI
# Or use Netlify CLI:
netlify init
```

2. **Enable Netlify Identity:**
- Go to Netlify dashboard → Site settings → Identity
- Click "Enable Identity"

3. **Enable Git Gateway:**
- Identity settings → Services → Git Gateway
- Click "Enable Git Gateway"

4. **Configure External Providers (optional):**
- Identity → Settings → External providers
- Enable GitHub, GitLab, or other OAuth providers

5. **Update config.yml:**
```yaml
backend:
  name: git-gateway
  repo: ukwa/ukwa-site
  branch: master

publish_mode: editorial_workflow

# Remove or comment out local_backend for production
# local_backend: true
```

6. **Invite Users:**
- Identity → Invite users
- Send invitation emails
- Users will receive setup links

#### User Roles in Netlify:

Netlify doesn't have built-in role-based permissions. Control is via:
- Repository permissions (GitHub collaborators)
- Branch protection rules
- Custom authentication rules

---

### Option 2: GitHub with Custom Git Gateway

For more control, set up your own Git Gateway.

#### Prerequisites:

- GitHub OAuth App
- Server to run Git Gateway
- SSL certificate

#### Step 1: Create GitHub OAuth App

1. Go to GitHub → Settings → Developer settings → OAuth Apps
2. Click "New OAuth App"
3. Fill in:
   - **Application name:** UKWA CMS
   - **Homepage URL:** `https://www.webarchive.org.uk`
   - **Authorization callback URL:** `https://your-gateway.com/callback`
4. Save Client ID and Client Secret

#### Step 2: Deploy Git Gateway

Using Docker:

```yaml
# docker-compose.prod.yml
version: '3.7'

services:
  git-gateway:
    image: netlify/git-gateway:latest
    ports:
      - "9999:9999"
    environment:
      - GITHUB_CLIENT_ID=${GITHUB_CLIENT_ID}
      - GITHUB_CLIENT_SECRET=${GITHUB_CLIENT_SECRET}
      - GITHUB_REPO=ukwa/ukwa-site
      - JWT_SECRET=${JWT_SECRET}
      - DATABASE_URL=${DATABASE_URL}
    restart: always
```

**Environment variables:**
```bash
# .env.production
GITHUB_CLIENT_ID=your_client_id
GITHUB_CLIENT_SECRET=your_client_secret
JWT_SECRET=generate_random_string_min_32_chars
DATABASE_URL=postgres://user:pass@localhost:5432/git_gateway
```

#### Step 3: Update CMS Config

```yaml
# static/admin/config.yml
backend:
  name: git-gateway
  repo: ukwa/ukwa-site
  branch: master
  api_root: https://your-gateway.com/api/v1
  base_url: https://your-gateway.com
  auth_endpoint: auth

publish_mode: editorial_workflow
```

---

### Option 3: GitLab Backend

Use GitLab directly without Git Gateway:

```yaml
backend:
  name: gitlab
  repo: your-group/ukwa-site
  branch: master
  auth_type: pkce # Recommended for security
  app_id: your_gitlab_app_id

publish_mode: editorial_workflow
```

**Setup GitLab OAuth:**
1. GitLab → User Settings → Applications
2. Create new application
3. Redirect URI: `https://www.webarchive.org.uk/admin/`
4. Scopes: `api`, `read_user`, `write_repository`

---

### Option 4: Azure Static Web Apps

Azure has native support for static sites with CI/CD.

#### Setup:

1. **Create Azure Static Web App:**
```bash
az staticwebapp create \
  --name ukwa-site \
  --resource-group ukwa-rg \
  --source https://github.com/ukwa/ukwa-site \
  --branch master \
  --app-location "/" \
  --output-location "public" \
  --build-command "hugo"
```

2. **Configure Authentication:**
```json
// staticwebapp.config.json
{
  "routes": [
    {
      "route": "/admin/*",
      "allowedRoles": ["authenticated"]
    }
  ],
  "responseOverrides": {
    "401": {
      "redirect": "/.auth/login/github"
    }
  }
}
```

3. **Set up Git Gateway separately** (Azure doesn't provide built-in)

---

## Git Gateway Configuration

### Understanding Git Gateway

**What is Git Gateway?**
- Proxy service between Decap CMS and Git
- Handles authentication and authorization
- Creates commits on behalf of users
- Manages editorial workflow branches

**Why use it?**
- Users don't need direct Git repository access
- Centralizes permissions management
- Enables granular access control
- Separates content editing from code changes

### Custom Git Gateway Setup

For production without Netlify:

1. **Install Git Gateway:**
```bash
git clone https://github.com/netlify/git-gateway
cd git-gateway
go build
```

2. **Configure:**
```yaml
# config.yml
jwt_secret: "your-secret-key"
github:
  client_id: "your-github-client-id"
  client_secret: "your-github-client-secret"
  repo: "ukwa/ukwa-site"
  branch: "master"
database:
  driver: "postgres"
  url: "postgres://localhost/git_gateway"
```

3. **Run:**
```bash
./git-gateway serve
```

4. **Secure with HTTPS:**
```nginx
# nginx configuration
server {
    listen 443 ssl;
    server_name gateway.webarchive.org.uk;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:9999;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## User Management

### GitHub-based Permissions

When using GitHub as backend (via Git Gateway):

**Repository Roles:**
- **Admin** = Supervisor (can merge PRs, publish)
- **Write** = Editor (can create branches, open PRs)
- **Read** = Viewer (can view but not create PRs)

**Set up users:**
1. Go to GitHub repo → Settings → Collaborators
2. Add user email
3. Select permission level
4. User accepts invitation

### Branch Protection Rules

Essential for production:

1. **Protect master branch:**
```
GitHub repo → Settings → Branches → Add rule
```

2. **Configure:**
   - ☑️ Require pull request reviews before merging
   - ☑️ Require status checks to pass
   - ☑️ Require branches to be up to date
   - ☑️ Include administrators (optional)
   - Number of required approvals: **1** (for supervisor approval)

3. **Status checks:**
   - Hugo build
   - Markdown linting
   - Link checking
   - Image optimization

### Custom User Database

For fine-grained control, maintain user database:

```sql
-- PostgreSQL schema
CREATE TABLE cms_users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL,
    github_username VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP
);

CREATE TABLE cms_permissions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES cms_users(id),
    collection VARCHAR(100),
    can_create BOOLEAN DEFAULT FALSE,
    can_edit BOOLEAN DEFAULT FALSE,
    can_delete BOOLEAN DEFAULT FALSE,
    can_publish BOOLEAN DEFAULT FALSE
);
```

---

## Workflow and Branch Strategy

### Editorial Workflow with Git

Decap CMS editorial workflow maps to Git branches:

**Status → Git Representation:**
- **Draft** → `cms/draft-{slug}` branch
- **In Review** → Pull Request opened
- **Ready** → PR approved, awaiting merge
- **Published** → Merged to `master`

### Branch Naming Convention

```
cms/[status]/[collection]/[slug]
```

Examples:
- `cms/draft/info/accessibility-statement`
- `cms/review/homepage/updates`

### Workflow Process

**Editor creates content:**
```bash
# Decap CMS creates:
git checkout -b cms/draft/info/new-page
git add content/info/new-page/index.en.md
git commit -m "Draft: Create new info page"
git push origin cms/draft/info/new-page
```

**Editor requests review:**
```bash
# Decap CMS:
# 1. Creates PR from cms/draft/... to master
# 2. Adds label: "status: review"
# 3. Requests review from supervisors
```

**Supervisor approves:**
```bash
# Supervisor (via GitHub or CMS):
# 1. Reviews changes
# 2. Approves PR
# 3. Merges to master
```

**Auto-deployment:**
```bash
# CI/CD (GitHub Actions):
# 1. Detects merge to master
# 2. Runs Hugo build
# 3. Deploys to production
```

### Handling Conflicts

If two users edit the same content:

1. **Prevention:**
   - Lock files in CMS (not supported natively, but can be added)
   - Communicate about who's editing what

2. **Resolution:**
   - Git merge conflicts appear in CMS
   - Supervisor resolves manually
   - Or: latest change wins (configurable)

---

## CI/CD Integration

### GitHub Actions Example

```yaml
# .github/workflows/deploy.yml
name: Deploy UKWA Site

on:
  push:
    branches: [master]
  pull_request:
    branches: [master]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v3
      with:
        submodules: true
        fetch-depth: 0

    - name: Setup Hugo
      uses: peaceiris/actions-hugo@v2
      with:
        hugo-version: '0.111.3'
        extended: true

    - name: Build site
      run: hugo --minify

    - name: Run tests
      run: |
        # Validate HTML
        npm install -g html-validate
        html-validate public/**/*.html

        # Check links
        npm install -g broken-link-checker
        blc http://localhost:1313 -ro

    - name: Deploy to Azure
      if: github.ref == 'refs/heads/master'
      uses: Azure/static-web-apps-deploy@v1
      with:
        azure_static_web_apps_api_token: ${{ secrets.AZURE_TOKEN }}
        repo_token: ${{ secrets.GITHUB_TOKEN }}
        action: "upload"
        app_location: "public"
```

### Azure Pipelines Example

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
    - master

pool:
  vmImage: 'ubuntu-latest'

steps:
- task: GoTool@0
  inputs:
    version: '1.21'

- script: |
    wget https://github.com/gohugoio/hugo/releases/download/v0.111.3/hugo_extended_0.111.3_Linux-64bit.tar.gz
    tar -xzf hugo_extended_0.111.3_Linux-64bit.tar.gz
    sudo mv hugo /usr/local/bin/
  displayName: 'Install Hugo'

- script: hugo --minify
  displayName: 'Build Hugo site'

- task: AzureStaticWebApp@0
  inputs:
    app_location: 'public'
    azure_static_web_apps_api_token: $(AZURE_TOKEN)
```

### Netlify Configuration

```toml
# netlify.toml
[build]
  command = "hugo --minify"
  publish = "public"

[build.environment]
  HUGO_VERSION = "0.111.3"
  HUGO_ENABLEGITINFO = "true"

[[redirects]]
  from = "/en/ukwa/*"
  to = "/ukwa/:splat"
  status = 301

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-XSS-Protection = "1; mode=block"
    Content-Security-Policy = "default-src 'self'"
```

---

## Security Considerations

### Authentication Security

**OAuth Configuration:**
- ✅ Use HTTPS for all OAuth callbacks
- ✅ Set restrictive redirect URIs
- ✅ Rotate client secrets regularly (every 90 days)
- ✅ Use PKCE flow when available
- ❌ Never commit secrets to Git
- ❌ Don't use the same OAuth app for dev and production

**JWT Tokens:**
```bash
# Generate secure JWT secret (min 32 chars)
openssl rand -base64 32
```

Store in:
- Environment variables (production)
- Secret manager (AWS Secrets Manager, Azure Key Vault)
- Never in code or config files

### Repository Security

**GitHub Security:**
1. **Enable 2FA** for all users
2. **Signed commits:**
```bash
git config --global commit.gpgsign true
```

3. **Dependabot alerts:**
   - Enable in repo settings
   - Review and update dependencies regularly

4. **Secret scanning:**
   - Enable GitHub secret scanning
   - Use `.gitignore` to prevent credential commits

**Branch Protection:**
- Require signed commits
- Require status checks
- Dismiss stale reviews
- Restrict who can push to master

### Content Security

**Prevent XSS:**
```yaml
# config.toml
[markup.goldmark.renderer]
  unsafe = false  # Disable raw HTML in markdown
```

**Sanitize user input:**
- All markdown is sanitized by Hugo
- Images are served from controlled CDN
- No user-uploaded scripts

**Content Security Policy:**
```html
<!-- Add to layouts/partials/head.html -->
<meta http-equiv="Content-Security-Policy"
      content="default-src 'self';
               script-src 'self' https://unpkg.com;
               style-src 'self' 'unsafe-inline';">
```

### HTTPS and Certificates

**Production requirements:**
- ✅ TLS 1.3 only
- ✅ Valid SSL certificate (Let's Encrypt or commercial)
- ✅ HSTS header
- ✅ Secure cookies

```nginx
# Nginx HTTPS configuration
server {
    listen 443 ssl http2;
    server_name www.webarchive.org.uk;

    ssl_certificate /etc/letsencrypt/live/webarchive.org.uk/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/webarchive.org.uk/privkey.pem;
    ssl_protocols TLSv1.3;
    ssl_prefer_server_ciphers on;

    add_header Strict-Transport-Security "max-age=31536000" always;
}
```

---

## Troubleshooting

### Common Issues

#### Issue 1: "Error loading config.yml"

**Symptoms:**
- CMS shows error on load
- Can't access admin interface

**Causes:**
- YAML syntax error
- Invalid configuration
- CORS issue

**Solutions:**
```bash
# Validate YAML syntax
npx js-yaml static/admin/config.yml

# Check browser console for CORS errors
# If present, configure server to allow:
Access-Control-Allow-Origin: *
```

---

#### Issue 2: "Failed to persist entry"

**Symptoms:**
- Cannot save content
- Changes not committed to Git

**Causes:**
- Git Gateway not accessible
- Authentication token expired
- Repository permissions

**Solutions:**
```bash
# Check Git Gateway status
curl https://your-gateway.com/health

# Verify OAuth token
# Have user log out and log back in

# Check GitHub API rate limits
curl -H "Authorization: token YOUR_TOKEN" \
     https://api.github.com/rate_limit
```

---

#### Issue 3: Editorial workflow not working

**Symptoms:**
- Status changes don't create PRs
- Can't move content between stages

**Causes:**
- `publish_mode` not set
- Git Gateway configuration
- Branch protection interfering

**Solutions:**
```yaml
# Ensure in config.yml:
publish_mode: editorial_workflow

# Check Git Gateway has permission to create branches
# Verify PR creation in GitHub repo settings
```

---

#### Issue 4: "Unable to authenticate"

**Symptoms:**
- Login fails
- OAuth redirect errors

**Causes:**
- Incorrect OAuth configuration
- Callback URL mismatch
- Expired credentials

**Solutions:**
1. Verify OAuth app settings match CMS config
2. Check redirect URI exactly matches
3. Test OAuth flow separately:
```bash
curl https://github.com/login/oauth/authorize\?client_id=YOUR_CLIENT_ID
```

---

### Debug Mode

Enable debug logging:

```yaml
# config.yml
backend:
  name: git-gateway
  repo: ukwa/ukwa-site

# Add debug flag (temporary)
local_backend:
  url: http://localhost:8081/api/v1
  debug: true
```

Check browser console for detailed logs.

---

## Caveats and Limitations

### Git-based CMS Limitations

❌ **Not Real-time Collaborative:**
- Multiple users editing same file = conflicts
- No Google Docs-style live editing
- Lock mechanism not built-in

**Mitigation:**
- Coordinate editing via Slack/Teams
- Use draft branches per editor
- Implement custom locking (advanced)

---

❌ **No Built-in Media Management:**
- Large files bloat repository
- No image optimization in CMS
- No CDN integration by default

**Mitigation:**
- Pre-optimize images before upload
- Use Git LFS for large files:
```bash
git lfs install
git lfs track "*.png" "*.jpg"
```
- Integrate Cloudinary or similar:
```yaml
# config.yml
media_library:
  name: cloudinary
  config:
    cloud_name: your_cloud_name
    api_key: your_api_key
```

---

❌ **Build Time Increases:**
- Every change triggers full site rebuild
- Hugo is fast, but CI/CD overhead adds time
- Users wait 2-5 minutes to see changes

**Mitigation:**
- Incremental builds (Hugo 0.90+)
- Optimize build pipeline
- Use build cache
- Preview deployments (Netlify/Vercel)

---

❌ **No Fine-grained Permissions:**
- Decap CMS doesn't have role system
- Control is via Git repository permissions
- All-or-nothing per collection

**Mitigation:**
- Use multiple repositories for different content areas
- Custom backend with permission checks
- Workflow approval as permission gate

---

❌ **Mobile Experience:**
- CMS is desktop-first
- Mobile editing is functional but not optimal
- Touch interface improvements needed

**Mitigation:**
- Use desktop for complex edits
- Simple text changes work on mobile
- Consider native mobile CMS app (future)

---

### Decap CMS Specific Issues

**Internationalization:**
- Multi-language support is good but complex
- Must configure carefully for each collection
- Switching between languages in UI can be confusing

**Rich Text Editor:**
- Limited compared to WordPress/Contentful
- No drag-and-drop by default
- Markdown knowledge helpful

**Preview:**
- Preview pane uses React components
- Must configure preview templates
- May not match production exactly

---

## Monitoring and Maintenance

### Health Checks

**Daily checks:**
```bash
#!/bin/bash
# check-cms-health.sh

# Check Git Gateway
curl -f https://gateway.webarchive.org.uk/health || echo "Gateway DOWN"

# Check CMS admin page loads
curl -f https://www.webarchive.org.uk/admin/ || echo "CMS admin DOWN"

# Check recent commits
COMMITS=$(git log --since="24 hours ago" --oneline | wc -l)
echo "Commits in last 24h: $COMMITS"

# Check open PRs
gh pr list --state open --json number,title
```

**Run via cron:**
```bash
0 9 * * * /path/to/check-cms-health.sh | mail -s "CMS Health Report" admin@example.com
```

---

### Performance Monitoring

**Metrics to track:**
- Build time (Hugo)
- Deploy time (CI/CD)
- API response time (Git Gateway)
- Authentication latency
- User adoption (active users per week)

**Tools:**
- GitHub Insights (commit frequency, PR velocity)
- CI/CD platform metrics
- Google Analytics on CMS admin (if permitted)
- Custom logging:

```javascript
// In static/admin/index.html
<script>
CMS.registerEventListener({
  name: 'preSave',
  handler: ({ entry }) => {
    console.log('Saving:', entry.get('slug'));
    // Send to analytics
    fetch('/api/metrics', {
      method: 'POST',
      body: JSON.stringify({
        event: 'cms_save',
        collection: entry.get('collection'),
        timestamp: Date.now()
      })
    });
  }
});
</script>
```

---

### Backup Strategy

**What to backup:**
1. ✅ Git repository (primary backup)
2. ✅ CMS configuration
3. ✅ User database (if using custom auth)
4. ✅ OAuth credentials (in secure vault)
5. ✅ Build artifacts (optional)

**Git is your backup:**
- Every change is versioned
- No data loss possible
- Can restore any previous version

**Additional backups:**
```bash
# Daily Git mirror
git clone --mirror https://github.com/ukwa/ukwa-site.git
tar -czf ukwa-site-backup-$(date +%Y%m%d).tar.gz ukwa-site.git

# Upload to S3
aws s3 cp ukwa-site-backup-*.tar.gz s3://backups/ukwa-site/
```

---

### Updates and Upgrades

**Decap CMS updates:**

Current version: 3.3.3 (as of implementation)

Check for updates:
```bash
npm info decap-cms version
```

Update in `static/admin/index.html`:
```html
<script src="https://unpkg.com/decap-cms@^3.3.3/dist/decap-cms.js"></script>
```

**Hugo updates:**

Monitor Hugo releases: https://github.com/gohugoio/hugo/releases

Test before upgrading:
```bash
# Create test branch
git checkout -b test-hugo-upgrade

# Update Hugo version in CI/CD
# Build and test locally
hugo --minify

# If successful, merge to master
```

**Dependencies:**
```bash
# Check for outdated dependencies
npm outdated

# Update package.json
npm update

# Or use Dependabot (GitHub)
```

---

### User Training and Onboarding

**Onboarding checklist:**
- [ ] Send user guide (docs/USER_GUIDE.md)
- [ ] Create user account (GitHub invite)
- [ ] Assign role (collaborator permission)
- [ ] Send welcome email with login link
- [ ] Schedule 30-min training session
- [ ] Provide test environment access
- [ ] Assign mentor (buddy system)

**Training materials:**
- Video walkthrough (record screen while using CMS)
- Quick reference card (print-friendly)
- FAQ document
- Office hours (weekly Q&A session)

---

## Advanced Configuration

### Custom Widgets

Add custom field types:

```javascript
// static/admin/config.js
CMS.registerWidget(
  'ukwa-collection-id',
  UKWACollectionIdControl,
  UKWACollectionIdPreview
);
```

### Preview Templates

Customize content preview:

```javascript
// static/admin/preview.js
const InfoPagePreview = ({ entry, widgetFor }) => {
  return (
    <div className="ukwa-preview">
      <h1>{entry.getIn(['data', 'title'])}</h1>
      <div>{widgetFor('body')}</div>
    </div>
  );
};

CMS.registerPreviewTemplate('info', InfoPagePreview);
```

### Custom Backends

For specialized workflows, implement custom backend:

```javascript
// static/admin/custom-backend.js
class CustomBackend {
  constructor(config) {
    this.config = config;
  }

  async getEntry(collection, slug) {
    // Fetch from custom API
    const response = await fetch(`/api/content/${collection}/${slug}`);
    return response.json();
  }

  async persistEntry(entry) {
    // Save to custom backend
    await fetch('/api/content', {
      method: 'POST',
      body: JSON.stringify(entry)
    });
  }
}

CMS.registerBackend('custom', CustomBackend);
```

---

## Migration from Other CMS

### From WordPress:

1. **Export content:**
```bash
wp export --dir=./export
```

2. **Convert to Markdown:**
```bash
npm install -g wordpress-export-to-markdown
wordpress-export-to-markdown export.xml content/
```

3. **Update front matter:**
```bash
# Add Hugo-compatible YAML front matter
for file in content/**/*.md; do
  # Parse and reformat
  python scripts/convert-frontmatter.py "$file"
done
```

### From Contentful:

1. **Export via API:**
```bash
contentful space export --space-id YOUR_SPACE_ID
```

2. **Transform data:**
```javascript
// scripts/contentful-to-hugo.js
const entries = require('./contentful-export.json');
entries.forEach(entry => {
  const markdown = convertToMarkdown(entry);
  fs.writeFileSync(`content/${entry.sys.id}.md`, markdown);
});
```

---

## Conclusion

This guide provides comprehensive coverage of Decap CMS integration with Hugo for the UKWA website. Key takeaways:

✅ **Use local backend for development** - Fast, no auth needed
✅ **Leverage editorial workflow** - Quality control through Git PRs
✅ **Secure with OAuth** - GitHub/GitLab integration
✅ **Automate with CI/CD** - Fast deployment pipeline
✅ **Monitor actively** - Health checks and metrics
✅ **Backup via Git** - Version control is your safety net

For questions or issues:
- **Documentation:** This guide + USER_GUIDE.md
- **Community:** Decap CMS Forum (https://github.com/decaporg/decap-cms/discussions)
- **Support:** Create issue in ukwa/ukwa-site repository

---

**Document Version:** 1.0
**Last Updated:** 2025-01-28
**Maintained by:** UKWA DevOps Team

---
