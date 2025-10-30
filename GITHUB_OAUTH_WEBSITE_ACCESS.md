# GitHub OAuth Website Access Solutions
## Protecting Static Website with GitHub Authentication

**Purpose:** Restrict public website access using GitHub OAuth authentication
**Similar to:** Decap CMS admin authentication, but for the entire website
**Target:** https://static-ukwa-site.netlify.app (limited access deployment)

---

## Table of Contents

1. [Overview](#overview)
2. [Solution 1: Netlify Identity + GitHub Provider (Recommended)](#solution-1-netlify-identity--github-provider-recommended)
3. [Solution 2: Netlify Edge Functions with GitHub OAuth](#solution-2-netlify-edge-functions-with-github-oauth)
4. [Solution 3: Cloudflare Access with GitHub](#solution-3-cloudflare-access-with-github)
5. [Solution 4: Custom Middleware Service](#solution-4-custom-middleware-service)
6. [Solution 5: Auth0 with GitHub Social Login](#solution-5-auth0-with-github-social-login)
7. [Solution 6: Simple Password Protection (Basic Auth)](#solution-6-simple-password-protection-basic-auth)
8. [Comparison Matrix](#comparison-matrix)
9. [Implementation Recommendations](#implementation-recommendations)

---

## Overview

### Current Architecture

```
User → https://static-ukwa-site.netlify.app
       ↓
       Public access (no authentication)
       ↓
       Static HTML/CSS/JS served directly
```

### Desired Architecture

```
User → https://static-ukwa-site.netlify.app
       ↓
       Authentication check
       ↓
       ├─ Not authenticated → Redirect to GitHub OAuth login
       │                      ↓
       │                      User logs in with GitHub
       │                      ↓
       │                      Check GitHub organization/team membership
       │                      ↓
       │                      ├─ Authorized → Grant access + cookie/token
       │                      └─ Not authorized → "Access Denied"
       │
       └─ Authenticated → Serve static content
```

---

## Solution 1: Netlify Identity + GitHub Provider (Recommended)

### Overview

Use Netlify's built-in Identity service with GitHub as an external OAuth provider, then protect the site with Netlify's visitor access control.

**Note:** While Netlify Identity is deprecated for CMS usage, it's still available for site access control.

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    User Access Flow                             │
└─────────────────────────────────────────────────────────────────┘

User visits: https://static-ukwa-site.netlify.app
                        ↓
        ┌───────────────────────────────┐
        │   Netlify Edge Protection     │
        │   Checks authentication       │
        └───────────────┬───────────────┘
                        ↓
            Not authenticated?
                        ↓
        ┌───────────────────────────────┐
        │   Redirect to Login Page      │
        │   /login or custom page       │
        └───────────────┬───────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   "Login with GitHub" button  │
        └───────────────┬───────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   GitHub OAuth 2.0 Flow       │
        │   User authorizes app         │
        └───────────────┬───────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   Netlify Identity validates  │
        │   Sets authentication cookie  │
        └───────────────┬───────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   User redirected to site     │
        │   Cookie grants access        │
        └───────────────┬───────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   Static content served       │
        │   All pages protected         │
        └───────────────────────────────┘
```

### Implementation Steps

#### Step 1: Enable Netlify Identity (10 min)

1. **Go to Netlify Dashboard**
   - Site: https://app.netlify.com/sites/static-ukwa-site
   - Navigate to "Site configuration" → "Identity"

2. **Enable Identity**
   - Click "Enable Identity"
   - Identity service is now active

3. **Configure Registration**
   - Registration preferences: **Invite only**
   - Email templates: Default (or customize)
   - External providers: Enable GitHub

#### Step 2: Configure GitHub as OAuth Provider (15 min)

1. **Create GitHub OAuth App**
   - Go to: https://github.com/settings/developers
   - Click "New OAuth App"
   - Fill in details:
     ```
     Application name: UKWA Limited Access Site
     Homepage URL: https://static-ukwa-site.netlify.app
     Authorization callback URL: https://static-ukwa-site.netlify.app/.netlify/identity/callback
     ```
   - Click "Register application"
   - Note down: **Client ID** and **Client Secret**

2. **Add GitHub Provider to Netlify**
   - In Netlify Dashboard → Identity → External providers
   - Click "Add provider" → "GitHub"
   - Enter:
     - Client ID: `{your_github_client_id}`
     - Client Secret: `{your_github_client_secret}`
   - Click "Install provider"

#### Step 3: Protect the Site (5 min)

1. **Enable Visitor Access Control**
   - Netlify Dashboard → Site configuration → Access control
   - Select "Visitor access control"
   - Choose: **Identity (JWT-based authentication)**

2. **Configure Protected Paths**
   ```toml
   # Add to netlify.toml
   [[redirects]]
     from = "/*"
     to = "/.netlify/identity/login"
     status = 200
     force = false
     conditions = {Role = []}  # No role = not logged in
   ```

#### Step 4: Create Login Page (15 min)

Create `static/login.html`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login - UKWA Limited Access</title>
  <script src="https://identity.netlify.com/v1/netlify-identity-widget.js"></script>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      margin: 0;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    }
    .login-container {
      background: white;
      padding: 2rem;
      border-radius: 8px;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      max-width: 400px;
      width: 100%;
      text-align: center;
    }
    h1 {
      margin-top: 0;
      color: #333;
    }
    p {
      color: #666;
      line-height: 1.6;
    }
    .login-button {
      background: #24292e;
      color: white;
      border: none;
      padding: 12px 24px;
      font-size: 16px;
      border-radius: 6px;
      cursor: pointer;
      margin-top: 1rem;
      display: inline-flex;
      align-items: center;
      gap: 8px;
    }
    .login-button:hover {
      background: #1b1f23;
    }
    .github-icon {
      width: 20px;
      height: 20px;
    }
  </style>
</head>
<body>
  <div class="login-container">
    <h1>🔐 UKWA Limited Access</h1>
    <p>This site requires authentication. Please log in with your GitHub account to continue.</p>

    <button class="login-button" onclick="netlifyIdentity.open()">
      <svg class="github-icon" viewBox="0 0 16 16" fill="currentColor">
        <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"/>
      </svg>
      Login with GitHub
    </button>

    <p style="margin-top: 2rem; font-size: 14px; color: #999;">
      Access restricted to authorized users only.
    </p>
  </div>

  <script>
    // Initialize Netlify Identity
    netlifyIdentity.init();

    // Redirect to home page after successful login
    netlifyIdentity.on('login', user => {
      window.location.href = '/';
    });

    // Auto-open login modal if user came here directly
    if (window.location.hash === '#login') {
      netlifyIdentity.open();
    }
  </script>
</body>
</html>
```

#### Step 5: Invite Users (5 min)

1. **Invite via Netlify Dashboard**
   - Identity → Invite users
   - Enter email: `mindaugas.vidmantas@bl.uk`
   - User receives invitation email
   - User clicks link → Chooses "Login with GitHub"

### Pros & Cons

**Pros:**
- ✅ Native Netlify integration
- ✅ Simple setup (no external services)
- ✅ Works with GitHub OAuth
- ✅ Automatic cookie management
- ✅ Free for small teams (<5 users)

**Cons:**
- ⚠️ Netlify Identity is deprecated for new CMS use cases
- ⚠️ Limited to 1,000 active users on free tier
- ⚠️ Cannot restrict by GitHub organization/team membership
- ⚠️ Users must be invited individually

**Cost:** Free (up to 1,000 users)

---

## Solution 2: Netlify Edge Functions with GitHub OAuth

### Overview

Use Netlify Edge Functions (running on Deno) to implement custom GitHub OAuth authentication at the edge.

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│              Edge Function Authentication Flow                  │
└─────────────────────────────────────────────────────────────────┘

User requests: https://static-ukwa-site.netlify.app/
                        ↓
        ┌───────────────────────────────┐
        │   Netlify Edge Function       │
        │   Runs at CDN edge            │
        └───────────────┬───────────────┘
                        ↓
            Check cookie/JWT token
                        ↓
        ┌───────────────┴───────────────┐
        │                               │
        ▼                               ▼
   Authenticated                  Not authenticated
        │                               │
        │                               ▼
        │                   ┌───────────────────────┐
        │                   │ Redirect to GitHub    │
        │                   │ OAuth login           │
        │                   └───────┬───────────────┘
        │                           ↓
        │                   GitHub user authorizes
        │                           ↓
        │                   ┌───────────────────────┐
        │                   │ Callback to           │
        │                   │ /.netlify/functions/  │
        │                   │ oauth-callback        │
        │                   └───────┬───────────────┘
        │                           ↓
        │                   Check GitHub org/team
        │                           ↓
        │                   ┌───────┴───────────────┐
        │                   │                       │
        │                   ▼                       ▼
        │              Authorized            Not authorized
        │                   │                       │
        │                   ├─> Set cookie         └─> 403 Forbidden
        │                   └─> Redirect to /
        │                           │
        └───────────────────────────┘
                        │
                        ▼
        ┌───────────────────────────────┐
        │   Serve static content        │
        └───────────────────────────────┘
```

### Implementation Steps

#### Step 1: Create GitHub OAuth App (Same as Solution 1)

#### Step 2: Create Edge Function (20 min)

Create `netlify/edge-functions/auth-check.ts`:

```typescript
import type { Context } from "https://edge.netlify.com";

const GITHUB_CLIENT_ID = Deno.env.get("GITHUB_CLIENT_ID");
const COOKIE_NAME = "github_auth";

export default async (request: Request, context: Context) => {
  const url = new URL(request.url);

  // Skip authentication for callback and public assets
  if (url.pathname.startsWith("/.netlify/") ||
      url.pathname.startsWith("/assets/") ||
      url.pathname === "/login.html") {
    return context.next();
  }

  // Check for authentication cookie
  const cookies = request.headers.get("cookie") || "";
  const authCookie = cookies.split(";").find(c => c.trim().startsWith(`${COOKIE_NAME}=`));

  if (!authCookie) {
    // Not authenticated - redirect to GitHub OAuth
    const githubAuthUrl = new URL("https://github.com/login/oauth/authorize");
    githubAuthUrl.searchParams.set("client_id", GITHUB_CLIENT_ID!);
    githubAuthUrl.searchParams.set("redirect_uri", `${url.origin}/.netlify/functions/oauth-callback`);
    githubAuthUrl.searchParams.set("scope", "read:user,read:org");
    githubAuthUrl.searchParams.set("state", url.pathname); // Return to original page

    return Response.redirect(githubAuthUrl.toString(), 302);
  }

  // Verify cookie/JWT (simplified - add proper JWT verification in production)
  try {
    const token = authCookie.split("=")[1];
    // In production: verify JWT signature, expiration, etc.

    // User is authenticated - serve content
    return context.next();
  } catch (error) {
    // Invalid cookie - redirect to login
    return Response.redirect(`${url.origin}/login.html`, 302);
  }
};

export const config = {
  path: "/*",
};
```

#### Step 3: Create OAuth Callback Function (25 min)

Create `netlify/functions/oauth-callback.ts`:

```typescript
import { Handler } from "@netlify/functions";

const GITHUB_CLIENT_ID = process.env.GITHUB_CLIENT_ID;
const GITHUB_CLIENT_SECRET = process.env.GITHUB_CLIENT_SECRET;
const ALLOWED_ORG = "your-github-org"; // Optional: restrict to org
const COOKIE_NAME = "github_auth";

export const handler: Handler = async (event) => {
  const code = event.queryStringParameters?.code;
  const state = event.queryStringParameters?.state || "/";

  if (!code) {
    return {
      statusCode: 400,
      body: "Missing authorization code",
    };
  }

  try {
    // Exchange code for access token
    const tokenResponse = await fetch("https://github.com/login/oauth/access_token", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: JSON.stringify({
        client_id: GITHUB_CLIENT_ID,
        client_secret: GITHUB_CLIENT_SECRET,
        code,
      }),
    });

    const tokenData = await tokenResponse.json();
    const accessToken = tokenData.access_token;

    if (!accessToken) {
      throw new Error("Failed to get access token");
    }

    // Get user information
    const userResponse = await fetch("https://api.github.com/user", {
      headers: {
        "Authorization": `Bearer ${accessToken}`,
        "Accept": "application/vnd.github.v3+json",
      },
    });

    const userData = await userResponse.json();

    // Optional: Check organization membership
    if (ALLOWED_ORG) {
      const orgResponse = await fetch(`https://api.github.com/orgs/${ALLOWED_ORG}/members/${userData.login}`, {
        headers: {
          "Authorization": `Bearer ${accessToken}`,
          "Accept": "application/vnd.github.v3+json",
        },
      });

      if (orgResponse.status !== 204) {
        return {
          statusCode: 403,
          body: "You are not a member of the authorized organization",
        };
      }
    }

    // Create JWT or encrypted cookie (simplified - use proper JWT library in production)
    const sessionData = {
      username: userData.login,
      email: userData.email,
      exp: Date.now() + (7 * 24 * 60 * 60 * 1000), // 7 days
    };

    const sessionToken = Buffer.from(JSON.stringify(sessionData)).toString("base64");

    // Set cookie and redirect
    return {
      statusCode: 302,
      headers: {
        "Location": state,
        "Set-Cookie": `${COOKIE_NAME}=${sessionToken}; HttpOnly; Secure; SameSite=Strict; Max-Age=${7 * 24 * 60 * 60}; Path=/`,
      },
      body: "",
    };
  } catch (error) {
    console.error("OAuth callback error:", error);
    return {
      statusCode: 500,
      body: `Authentication failed: ${error.message}`,
    };
  }
};
```

#### Step 4: Configure Environment Variables

Add to Netlify Dashboard → Site configuration → Environment variables:

```
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret
```

#### Step 5: Update netlify.toml

```toml
# Add to netlify.toml
[[edge_functions]]
  function = "auth-check"
  path = "/*"
```

### Pros & Cons

**Pros:**
- ✅ Full control over authentication logic
- ✅ Can restrict by GitHub organization/team
- ✅ Runs at edge (fast)
- ✅ No per-user pricing
- ✅ Works with existing static site

**Cons:**
- ⚠️ Requires custom code
- ⚠️ Need to manage JWT/cookie security
- ⚠️ More complex to set up
- ⚠️ Need to handle session expiration

**Cost:** Free (included with Netlify)

---

## Solution 3: Cloudflare Access with GitHub

### Overview

Use Cloudflare Access (Zero Trust) to protect the site with GitHub OAuth, then deploy to Cloudflare Pages or proxy through Cloudflare.

### Architecture

```
User → https://static-ukwa-site.pages.dev
       ↓
       Cloudflare Access checks authentication
       ↓
       ├─ Not authenticated → GitHub OAuth login
       │                      ↓
       │                      Cloudflare validates
       │                      ↓
       │                      Sets Cloudflare cookie
       │
       └─ Authenticated → Serve static content from Cloudflare Pages
```

### Implementation Steps

#### Step 1: Transfer to Cloudflare Pages (30 min)

1. **Create Cloudflare Account**
   - Go to: https://dash.cloudflare.com/sign-up

2. **Create Pages Project**
   - Dashboard → Pages → "Create a project"
   - Connect to GitHub → Select `min2ha/ukwa-site`
   - Branch: `dev_limited_access`
   - Build command: `hugo --minify`
   - Build output: `public`
   - Deploy

3. **Configure Custom Domain** (optional)
   - Add custom domain: `static-ukwa-site.yourdomain.com`
   - Or use: `static-ukwa-site.pages.dev`

#### Step 2: Enable Cloudflare Access (15 min)

1. **Navigate to Zero Trust**
   - Cloudflare Dashboard → Zero Trust

2. **Add GitHub as Identity Provider**
   - Settings → Authentication → "Add new"
   - Select "GitHub"
   - Enter GitHub OAuth App credentials
   - Save

3. **Create Access Policy**
   - Access → Applications → "Add an application"
   - Select "Self-hosted"
   - Configure:
     ```
     Application name: UKWA Limited Access
     Session duration: 24 hours
     Application domain: static-ukwa-site.pages.dev
     ```

4. **Add Policy Rule**
   - Rule name: GitHub Members Only
   - Action: Allow
   - Selector: GitHub Organization
   - Value: `your-org-name` (or specific users)
   - Save

#### Step 3: Test Access

1. Visit: https://static-ukwa-site.pages.dev
2. Redirected to Cloudflare Access login
3. Click "Login with GitHub"
4. Authorize
5. Redirected back to site (authenticated)

### Pros & Cons

**Pros:**
- ✅ Enterprise-grade security
- ✅ Can restrict by GitHub org/team
- ✅ Automatic HTTPS/CDN
- ✅ Advanced features (MFA, audit logs)
- ✅ No coding required

**Cons:**
- ⚠️ Requires Cloudflare (migration from Netlify)
- ⚠️ Free tier limited to 50 users
- ⚠️ Learning curve for Cloudflare setup

**Cost:**
- Free tier: Up to 50 users
- Paid: $3/user/month for additional users

---

## Solution 4: Custom Middleware Service

### Overview

Deploy a separate authentication middleware service (Node.js/Express) that sits between users and the static site.

### Architecture

```
User → auth-proxy.herokuapp.com (or similar)
       ↓
       GitHub OAuth check
       ↓
       ├─ Not authenticated → GitHub login flow
       │                      ↓
       │                      Set JWT token
       │
       └─ Authenticated → Proxy request to Netlify
                          ↓
                          static-ukwa-site.netlify.app
                          (served through proxy with auth)
```

### Implementation (High-Level)

1. Deploy Express.js app to Heroku/Railway/Render
2. Implement GitHub OAuth flow
3. Proxy authenticated requests to Netlify
4. Cache static assets

### Pros & Cons

**Pros:**
- ✅ Complete control
- ✅ Can add custom logic
- ✅ Works with any static host

**Cons:**
- ⚠️ Complex setup
- ⚠️ Need to maintain server
- ⚠️ Additional hosting costs
- ⚠️ Latency (additional hop)

**Cost:** $5-10/month (hosting)

---

## Solution 5: Auth0 with GitHub Social Login

### Overview

Use Auth0 as authentication provider with GitHub social login, protect site with Auth0 rules.

### Implementation (High-Level)

1. Create Auth0 account
2. Enable GitHub social connection
3. Create Auth0 application for static site
4. Add Auth0 Universal Login
5. Protect routes with Auth0 SDK

### Pros & Cons

**Pros:**
- ✅ Enterprise features
- ✅ Multiple auth providers
- ✅ Advanced user management
- ✅ Good documentation

**Cons:**
- ⚠️ Overkill for simple use case
- ⚠️ More complex setup
- ⚠️ Free tier limited to 7,000 users

**Cost:** Free (up to 7,000 users)

---

## Solution 6: Simple Password Protection (Basic Auth)

### Overview

Use HTTP Basic Authentication with Netlify's built-in password protection.

### Implementation

Add to `netlify.toml`:

```toml
[[headers]]
  for = "/*"
  [headers.values]
    Basic-Auth = "username:password"
```

Or use Netlify's site-wide password protection in dashboard.

### Pros & Cons

**Pros:**
- ✅ Simplest solution
- ✅ No setup required
- ✅ Works immediately

**Cons:**
- ⚠️ Not GitHub-based
- ⚠️ Single shared password
- ⚠️ No user tracking
- ⚠️ Less secure

**Cost:** Free

---

## Comparison Matrix

| Solution | Difficulty | GitHub Auth | Org/Team Restrict | Cost (50 users) | Best For |
|----------|------------|-------------|-------------------|-----------------|----------|
| **Netlify Identity** | ⭐⭐ Easy | ✅ Yes | ❌ No | Free | Small teams, simple needs |
| **Edge Functions** | ⭐⭐⭐⭐ Advanced | ✅ Yes | ✅ Yes | Free | Custom requirements |
| **Cloudflare Access** | ⭐⭐⭐ Medium | ✅ Yes | ✅ Yes | $3/user | Enterprise security |
| **Custom Proxy** | ⭐⭐⭐⭐⭐ Expert | ✅ Yes | ✅ Yes | $10/mo | Full control |
| **Auth0** | ⭐⭐⭐ Medium | ✅ Yes | ⚠️ Limited | Free | Multiple providers |
| **Basic Auth** | ⭐ Trivial | ❌ No | ❌ No | Free | Temporary protection |

---

## Implementation Recommendations

### For Your Use Case (UKWA Limited Access)

**Recommended: Solution 2 (Netlify Edge Functions)**

**Why:**
- ✅ You're already on Netlify
- ✅ Can restrict by GitHub organization
- ✅ No additional costs
- ✅ Full control over logic
- ✅ Fast (edge execution)

**Implementation Plan:**

1. **Week 1: Set up GitHub OAuth**
   - Create OAuth app
   - Test callback locally

2. **Week 2: Implement Edge Function**
   - Write auth-check edge function
   - Create oauth-callback function
   - Test authentication flow

3. **Week 3: Add Organization Check**
   - Implement GitHub org verification
   - Test with authorized/unauthorized users

4. **Week 4: Polish & Deploy**
   - Add error handling
   - Create login page UI
   - Deploy to production
   - User testing

**Alternative: Solution 1 (Netlify Identity)** if:
- You don't need org/team restrictions
- You want simpler setup
- You have < 1,000 users

---

## Example: Complete Edge Function Solution

### File Structure

```
ukwa-site-original/
├── netlify/
│   ├── edge-functions/
│   │   └── auth-check.ts
│   └── functions/
│       └── oauth-callback.ts
├── static/
│   └── login.html
└── netlify.toml
```

### Complete netlify.toml Configuration

```toml
[build]
  command = "hugo --minify"
  publish = "public"

[build.environment]
  HUGO_VERSION = "0.111.3"
  HUGO_ENV = "production"
  HUGO_ENABLEGITINFO = "true"

# Edge function for authentication
[[edge_functions]]
  function = "auth-check"
  path = "/*"

# Environment variables needed (set in Netlify dashboard):
# GITHUB_CLIENT_ID
# GITHUB_CLIENT_SECRET
# GITHUB_ALLOWED_ORG (optional)
```

### Testing Locally

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Set environment variables
export GITHUB_CLIENT_ID=your_client_id
export GITHUB_CLIENT_SECRET=your_client_secret

# Run dev server with edge functions
netlify dev

# Test authentication
open http://localhost:8888
```

---

## Security Considerations

### Session Management

✅ **Use HttpOnly cookies**
- Prevents XSS attacks
- Not accessible via JavaScript

✅ **Set Secure flag**
- Only transmitted over HTTPS

✅ **SameSite=Strict**
- Prevents CSRF attacks

✅ **Short session lifetime**
- Max 7 days
- Refresh tokens for longer sessions

### Token Storage

✅ **Use JWT for stateless auth**
- Signed with secret key
- Include expiration
- Validate signature on each request

✅ **Never expose secrets in client code**
- Client ID is public (OK)
- Client Secret server-side only

### GitHub API

✅ **Request minimal scopes**
- `read:user` for user info
- `read:org` for org membership
- Don't request unnecessary permissions

✅ **Validate org membership on server**
- Never trust client-side checks
- Re-validate on each session

---

## Migration Path

### From Current Setup to Protected Site

**Phase 1: Test Environment (Week 1-2)**
1. Keep current public site running
2. Set up authentication on staging URL
3. Test with 2-3 users
4. Fix bugs

**Phase 2: Soft Launch (Week 3)**
1. Deploy to production URL
2. Invite all authorized users
3. Keep fallback plan ready
4. Monitor access logs

**Phase 3: Full Protection (Week 4)**
1. Verify all users can access
2. Remove public access
3. Monitor and support users

**Rollback Plan:**
- Keep public version in separate branch
- Can redeploy in < 5 minutes if issues

---

## Support & Resources

### Documentation

- **Netlify Edge Functions:** https://docs.netlify.com/edge-functions/overview/
- **GitHub OAuth Apps:** https://docs.github.com/en/developers/apps/building-oauth-apps
- **Cloudflare Access:** https://developers.cloudflare.com/cloudflare-one/applications/
- **Auth0:** https://auth0.com/docs/quickstarts

### Example Projects

- **Netlify OAuth Example:** https://github.com/netlify/netlify-oauth-example
- **Edge Auth Template:** https://github.com/netlify/edge-functions-examples

---

## Summary

### Quick Decision Guide

**Choose Netlify Identity if:**
- Small team (< 5 people)
- No GitHub org restrictions needed
- Want simplest setup

**Choose Edge Functions if:**
- Need GitHub org/team restrictions
- Want full control
- Already comfortable with TypeScript/JavaScript

**Choose Cloudflare Access if:**
- Need enterprise security
- Don't mind migration
- Want advanced features (MFA, audit logs)

**Choose Basic Auth if:**
- Need immediate temporary protection
- Don't need GitHub integration
- Very simple requirements

---

**Recommended for UKWA:** Solution 2 (Netlify Edge Functions with GitHub OAuth)
**Setup Time:** 2-4 hours
**Maintenance:** Low
**Cost:** Free

Ready to implement? Start with the Edge Functions implementation above!
