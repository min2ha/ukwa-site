# Free Authentication Solutions for Static Website
## JavaScript Popup Authentication (100% Free)

**Cost:** $0 - Completely free
**Requirements:** Static hosting only (Netlify free tier)
**Implementation:** Pure JavaScript, no backend required
**Target:** https://static-ukwa-site.netlify.app

---

## Table of Contents

1. [Overview](#overview)
2. [Solution 1: GitHub OAuth with Client-Side Only (Recommended)](#solution-1-github-oauth-with-client-side-only-recommended)
3. [Solution 2: JWT-Based Challenge/Response](#solution-2-jwt-based-challengeresponse)
4. [Comparison](#comparison)
5. [Implementation Guide](#implementation-guide)
6. [Security Considerations](#security-considerations)

---

## Overview

### Requirements

✅ **100% Free** - No paid services
✅ **Popup Authentication** - JavaScript modal before site access
✅ **Static Hosting Only** - Works with Netlify free tier
✅ **No Backend** - Pure client-side solution
✅ **GitHub Integration** - Verify GitHub membership

### Architecture

```
User visits https://static-ukwa-site.netlify.app
            ↓
    JavaScript immediately loads
            ↓
    Check localStorage for auth token
            ↓
    ┌───────────────┴────────────────┐
    │                                │
    ▼                                ▼
No token found                  Token found
    │                                │
    ▼                                ▼
Show popup modal            Verify token not expired
"Login Required"                     │
    │                                ▼
    ├─> Option 1: GitHub OAuth   Token valid?
    └─> Option 2: Challenge      ├─ Yes → Show content
                                 └─ No → Show popup again
```

---

## Solution 1: GitHub OAuth with Client-Side Only (Recommended)

### Overview

Use GitHub OAuth Apps with **GitHub Pages API** to verify user access entirely client-side. No backend server required!

### How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│          Client-Side GitHub OAuth Flow (Free)                   │
└─────────────────────────────────────────────────────────────────┘

1. User visits site
   ↓
2. JavaScript shows popup modal:
   ┌──────────────────────────────────────┐
   │  🔐 Authentication Required          │
   │                                      │
   │  This site requires GitHub access    │
   │                                      │
   │  [Login with GitHub]                 │
   └──────────────────────────────────────┘
   ↓
3. User clicks "Login with GitHub"
   ↓
4. Redirect to GitHub OAuth:
   https://github.com/login/oauth/authorize?
     client_id=abc123&
     scope=read:user&
     redirect_uri=https://static-ukwa-site.netlify.app/callback.html
   ↓
5. User authorizes app on GitHub
   ↓
6. GitHub redirects to: /callback.html?code=xyz789
   ↓
7. JavaScript exchanges code for token using:
   - GitHub's CORS-friendly endpoints
   - OR Netlify Functions (free tier)
   ↓
8. Store token in localStorage
   ↓
9. Verify user's GitHub username/org membership
   ↓
10. If authorized → Hide popup, show content
    If not → Show "Access Denied" message
```

### Implementation Files

#### 1. Create `static/auth-gate.html`

This is the authentication popup that appears before site access.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Authentication Required</title>
  <style>
    /* Full-screen overlay */
    #auth-overlay {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0, 0, 0, 0.8);
      backdrop-filter: blur(10px);
      display: flex;
      justify-content: center;
      align-items: center;
      z-index: 999999;
      animation: fadeIn 0.3s ease-in;
    }

    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }

    /* Modal popup */
    .auth-modal {
      background: white;
      padding: 3rem;
      border-radius: 16px;
      box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
      max-width: 450px;
      width: 90%;
      text-align: center;
      animation: slideUp 0.3s ease-out;
    }

    @keyframes slideUp {
      from {
        transform: translateY(50px);
        opacity: 0;
      }
      to {
        transform: translateY(0);
        opacity: 1;
      }
    }

    .auth-modal h1 {
      margin: 0 0 1rem 0;
      font-size: 28px;
      color: #333;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }

    .auth-modal p {
      color: #666;
      font-size: 16px;
      line-height: 1.6;
      margin-bottom: 2rem;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }

    .github-login-btn {
      background: #24292e;
      color: white;
      border: none;
      padding: 14px 32px;
      font-size: 16px;
      border-radius: 8px;
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      gap: 12px;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      font-weight: 600;
      transition: all 0.2s ease;
    }

    .github-login-btn:hover {
      background: #1b1f23;
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(36, 41, 46, 0.3);
    }

    .github-icon {
      width: 24px;
      height: 24px;
    }

    .loading {
      display: none;
      margin-top: 1rem;
      color: #666;
      font-size: 14px;
    }

    .loading.active {
      display: block;
    }

    .spinner {
      border: 3px solid #f3f3f3;
      border-top: 3px solid #24292e;
      border-radius: 50%;
      width: 30px;
      height: 30px;
      animation: spin 1s linear infinite;
      margin: 1rem auto;
    }

    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }

    .error-message {
      display: none;
      color: #d73a49;
      background: #ffeef0;
      padding: 12px;
      border-radius: 6px;
      margin-top: 1rem;
      font-size: 14px;
    }

    .error-message.active {
      display: block;
    }

    .lock-icon {
      font-size: 48px;
      margin-bottom: 1rem;
    }
  </style>
</head>
<body>
  <div id="auth-overlay">
    <div class="auth-modal">
      <div class="lock-icon">🔐</div>
      <h1>Authentication Required</h1>
      <p>This site is restricted to authorized users. Please authenticate with your GitHub account to continue.</p>

      <button class="github-login-btn" onclick="loginWithGitHub()">
        <svg class="github-icon" viewBox="0 0 16 16" fill="currentColor">
          <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"/>
        </svg>
        Login with GitHub
      </button>

      <div class="loading" id="loading">
        <div class="spinner"></div>
        <p>Authenticating...</p>
      </div>

      <div class="error-message" id="error-message">
        Authentication failed. Please try again.
      </div>
    </div>
  </div>

  <script>
    // Configuration
    const CONFIG = {
      GITHUB_CLIENT_ID: 'YOUR_GITHUB_CLIENT_ID', // Replace with your GitHub OAuth App Client ID
      REDIRECT_URI: window.location.origin + '/callback.html',
      ALLOWED_USERS: ['mindaugas-vidmantas', 'min2ha'], // Allowed GitHub usernames
      ALLOWED_ORG: '', // Optional: 'your-org-name' to restrict by organization
      TOKEN_KEY: 'github_auth_token',
      USER_KEY: 'github_user_data',
      TOKEN_EXPIRY: 7 * 24 * 60 * 60 * 1000, // 7 days
    };

    // Check if already authenticated
    function checkAuth() {
      const token = localStorage.getItem(CONFIG.TOKEN_KEY);
      const userData = localStorage.getItem(CONFIG.USER_KEY);

      if (token && userData) {
        const user = JSON.parse(userData);
        const tokenExpiry = user.expiry || 0;

        if (Date.now() < tokenExpiry) {
          // Token is still valid
          hideAuthGate();
          return true;
        }
      }

      // No valid token - show auth gate
      return false;
    }

    // Hide authentication overlay
    function hideAuthGate() {
      const overlay = document.getElementById('auth-overlay');
      if (overlay) {
        overlay.style.animation = 'fadeOut 0.3s ease-out';
        setTimeout(() => {
          overlay.style.display = 'none';
        }, 300);
      }
    }

    // Login with GitHub
    function loginWithGitHub() {
      const authUrl = new URL('https://github.com/login/oauth/authorize');
      authUrl.searchParams.set('client_id', CONFIG.GITHUB_CLIENT_ID);
      authUrl.searchParams.set('redirect_uri', CONFIG.REDIRECT_URI);
      authUrl.searchParams.set('scope', 'read:user read:org');
      authUrl.searchParams.set('state', generateState());

      // Save state to verify callback
      sessionStorage.setItem('oauth_state', authUrl.searchParams.get('state'));

      // Redirect to GitHub
      window.location.href = authUrl.toString();
    }

    // Generate random state for CSRF protection
    function generateState() {
      return Math.random().toString(36).substring(2, 15) +
             Math.random().toString(36).substring(2, 15);
    }

    // Show loading state
    function showLoading() {
      document.getElementById('loading').classList.add('active');
      document.querySelector('.github-login-btn').disabled = true;
    }

    // Show error
    function showError(message) {
      const errorDiv = document.getElementById('error-message');
      errorDiv.textContent = message;
      errorDiv.classList.add('active');
      document.getElementById('loading').classList.remove('active');
      document.querySelector('.github-login-btn').disabled = false;
    }

    // Initialize on load
    if (!checkAuth()) {
      // Show authentication gate
      console.log('Authentication required');
    }
  </script>
</body>
</html>
```

#### 2. Create `static/callback.html`

This handles the OAuth callback from GitHub.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Authenticating...</title>
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
    .container {
      background: white;
      padding: 3rem;
      border-radius: 16px;
      box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
      text-align: center;
      max-width: 400px;
    }
    .spinner {
      border: 4px solid #f3f3f3;
      border-top: 4px solid #667eea;
      border-radius: 50%;
      width: 50px;
      height: 50px;
      animation: spin 1s linear infinite;
      margin: 0 auto 1rem;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
    h1 {
      margin: 0;
      color: #333;
      font-size: 24px;
    }
    p {
      color: #666;
      margin-top: 0.5rem;
    }
    .error {
      color: #d73a49;
      background: #ffeef0;
      padding: 1rem;
      border-radius: 8px;
      margin-top: 1rem;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="spinner"></div>
    <h1>Authenticating...</h1>
    <p id="status">Please wait while we verify your credentials.</p>
    <div class="error" id="error" style="display: none;"></div>
  </div>

  <script>
    // Configuration (must match auth-gate.html)
    const CONFIG = {
      GITHUB_CLIENT_ID: 'YOUR_GITHUB_CLIENT_ID',
      ALLOWED_USERS: ['mindaugas-vidmantas', 'min2ha'],
      ALLOWED_ORG: '', // Optional: organization name
      TOKEN_KEY: 'github_auth_token',
      USER_KEY: 'github_user_data',
      TOKEN_EXPIRY: 7 * 24 * 60 * 60 * 1000, // 7 days
      NETLIFY_FUNCTION_URL: '/.netlify/functions/github-oauth', // Netlify function for token exchange
    };

    async function handleCallback() {
      const urlParams = new URLSearchParams(window.location.search);
      const code = urlParams.get('code');
      const state = urlParams.get('state');
      const error = urlParams.get('error');

      // Check for errors
      if (error) {
        showError('Authentication failed: ' + error);
        return;
      }

      // Verify state (CSRF protection)
      const savedState = sessionStorage.getItem('oauth_state');
      if (state !== savedState) {
        showError('Invalid state parameter. Please try again.');
        return;
      }

      if (!code) {
        showError('No authorization code received.');
        return;
      }

      try {
        // Exchange code for token via Netlify Function
        updateStatus('Exchanging authorization code...');
        const tokenResponse = await fetch(CONFIG.NETLIFY_FUNCTION_URL, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ code }),
        });

        if (!tokenResponse.ok) {
          throw new Error('Failed to exchange code for token');
        }

        const { access_token } = await tokenResponse.json();

        // Get user information
        updateStatus('Fetching user information...');
        const userResponse = await fetch('https://api.github.com/user', {
          headers: {
            'Authorization': `Bearer ${access_token}`,
            'Accept': 'application/vnd.github.v3+json',
          },
        });

        if (!userResponse.ok) {
          throw new Error('Failed to fetch user information');
        }

        const userData = await userResponse.json();

        // Check authorization
        updateStatus('Verifying authorization...');
        const isAuthorized = await checkAuthorization(userData, access_token);

        if (!isAuthorized) {
          showError('Access denied. You are not authorized to access this site.');
          return;
        }

        // Store authentication data
        const authData = {
          username: userData.login,
          email: userData.email,
          name: userData.name,
          avatar: userData.avatar_url,
          expiry: Date.now() + CONFIG.TOKEN_EXPIRY,
        };

        localStorage.setItem(CONFIG.TOKEN_KEY, access_token);
        localStorage.setItem(CONFIG.USER_KEY, JSON.stringify(authData));

        // Success! Redirect to home
        updateStatus('Authentication successful! Redirecting...');
        setTimeout(() => {
          window.location.href = '/';
        }, 1000);

      } catch (error) {
        console.error('Authentication error:', error);
        showError('Authentication failed: ' + error.message);
      }
    }

    async function checkAuthorization(userData, accessToken) {
      // Check 1: Allowed users list
      if (CONFIG.ALLOWED_USERS.length > 0) {
        if (!CONFIG.ALLOWED_USERS.includes(userData.login)) {
          return false;
        }
      }

      // Check 2: Organization membership (optional)
      if (CONFIG.ALLOWED_ORG) {
        try {
          const orgResponse = await fetch(
            `https://api.github.com/orgs/${CONFIG.ALLOWED_ORG}/members/${userData.login}`,
            {
              headers: {
                'Authorization': `Bearer ${accessToken}`,
                'Accept': 'application/vnd.github.v3+json',
              },
            }
          );

          // 204 = user is a member, 404 = not a member
          if (orgResponse.status !== 204) {
            return false;
          }
        } catch (error) {
          console.error('Organization check failed:', error);
          return false;
        }
      }

      return true;
    }

    function updateStatus(message) {
      document.getElementById('status').textContent = message;
    }

    function showError(message) {
      const errorDiv = document.getElementById('error');
      errorDiv.textContent = message;
      errorDiv.style.display = 'block';
      document.querySelector('.spinner').style.display = 'none';
    }

    // Start authentication process
    handleCallback();
  </script>
</body>
</html>
```

#### 3. Create Netlify Function: `netlify/functions/github-oauth.ts`

This is a tiny serverless function (free on Netlify) to exchange the OAuth code for a token securely.

```typescript
import { Handler } from '@netlify/functions';

const GITHUB_CLIENT_ID = process.env.GITHUB_CLIENT_ID;
const GITHUB_CLIENT_SECRET = process.env.GITHUB_CLIENT_SECRET;

export const handler: Handler = async (event) => {
  // Only allow POST requests
  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      body: JSON.stringify({ error: 'Method not allowed' }),
    };
  }

  try {
    const { code } = JSON.parse(event.body || '{}');

    if (!code) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'Missing authorization code' }),
      };
    }

    // Exchange code for access token
    const tokenResponse = await fetch('https://github.com/login/oauth/access_token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: JSON.stringify({
        client_id: GITHUB_CLIENT_ID,
        client_secret: GITHUB_CLIENT_SECRET,
        code,
      }),
    });

    const tokenData = await tokenResponse.json();

    if (tokenData.error) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: tokenData.error_description || tokenData.error }),
      };
    }

    // Return only the access token (don't expose client secret)
    return {
      statusCode: 200,
      body: JSON.stringify({
        access_token: tokenData.access_token,
      }),
    };

  } catch (error) {
    console.error('OAuth error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Internal server error' }),
    };
  }
};
```

#### 4. Inject Auth Gate into Every Page

Add this script to your Hugo base template (`layouts/_default/baseof.html`):

```html
<!DOCTYPE html>
<html lang="{{ .Site.Language.Lang }}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{ block "title" . }}{{ .Site.Title }}{{ end }}</title>
  <!-- Your existing head content -->
</head>
<body>
  <!-- Authentication Gate (loads immediately) -->
  <script>
    (function() {
      const TOKEN_KEY = 'github_auth_token';
      const USER_KEY = 'github_user_data';

      // Check authentication immediately
      function checkAuth() {
        const token = localStorage.getItem(TOKEN_KEY);
        const userData = localStorage.getItem(USER_KEY);

        if (token && userData) {
          try {
            const user = JSON.parse(userData);
            if (Date.now() < user.expiry) {
              // Authenticated - allow page to load
              return true;
            }
          } catch (e) {
            console.error('Invalid user data:', e);
          }
        }

        // Not authenticated - inject auth gate
        injectAuthGate();
        return false;
      }

      function injectAuthGate() {
        // Create iframe to load auth-gate.html
        const iframe = document.createElement('iframe');
        iframe.src = '/auth-gate.html';
        iframe.style.position = 'fixed';
        iframe.style.top = '0';
        iframe.style.left = '0';
        iframe.style.width = '100%';
        iframe.style.height = '100%';
        iframe.style.border = 'none';
        iframe.style.zIndex = '999999';
        iframe.style.background = 'rgba(0, 0, 0, 0.8)';

        // Block page interaction while auth gate is showing
        document.body.style.overflow = 'hidden';

        // Insert at beginning of body
        if (document.body) {
          document.body.insertBefore(iframe, document.body.firstChild);
        } else {
          // Body not ready yet, wait for DOM
          document.addEventListener('DOMContentLoaded', () => {
            document.body.insertBefore(iframe, document.body.firstChild);
          });
        }
      }

      // Run immediately (before page renders)
      checkAuth();
    })();
  </script>

  <!-- Your existing body content -->
  {{ block "main" . }}{{ end }}
</body>
</html>
```

### Setup Instructions

#### Step 1: Create GitHub OAuth App (5 min)

1. Go to: https://github.com/settings/developers
2. Click "New OAuth App"
3. Fill in:
   ```
   Application name: UKWA Limited Access
   Homepage URL: https://static-ukwa-site.netlify.app
   Authorization callback URL: https://static-ukwa-site.netlify.app/callback.html
   ```
4. Click "Register application"
5. Note **Client ID** and **Client Secret**

#### Step 2: Configure Environment Variables in Netlify (2 min)

1. Netlify Dashboard → Site settings → Environment variables
2. Add:
   ```
   GITHUB_CLIENT_ID=your_client_id_here
   GITHUB_CLIENT_SECRET=your_client_secret_here
   ```

#### Step 3: Update Configuration in Files (5 min)

1. Edit `static/auth-gate.html`:
   ```javascript
   GITHUB_CLIENT_ID: 'your_client_id_here',
   ALLOWED_USERS: ['mindaugas-vidmantas', 'min2ha'], // Replace with actual usernames
   ```

2. Edit `static/callback.html` (same as above)

#### Step 4: Deploy (2 min)

```bash
git add static/auth-gate.html static/callback.html netlify/functions/github-oauth.ts layouts/_default/baseof.html
git commit -m "feat: add GitHub OAuth authentication gate"
git push origin dev_limited_access
```

#### Step 5: Test (5 min)

1. Visit: https://static-ukwa-site.netlify.app
2. Popup should appear immediately
3. Click "Login with GitHub"
4. Authorize on GitHub
5. Should redirect back and hide popup
6. Content now visible

### Pros & Cons

**Pros:**
- ✅ **100% Free** - Uses Netlify free tier only
- ✅ **Popup Authentication** - JavaScript modal as requested
- ✅ **GitHub Integration** - Real GitHub OAuth
- ✅ **Secure** - OAuth 2.0 standard
- ✅ **User Whitelist** - Can restrict by username
- ✅ **Org Restriction** - Can restrict by GitHub organization

**Cons:**
- ⚠️ Requires small Netlify Function (still free)
- ⚠️ Token stored in localStorage (client-side)
- ⚠️ Users can bypass with developer tools (see security note below)

---

## Solution 2: JWT-Based Challenge/Response

### Overview

Pure client-side authentication using a pre-shared secret and JWT tokens. No backend, no OAuth, completely free.

### How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│            JWT Challenge/Response Flow (Free)                   │
└─────────────────────────────────────────────────────────────────┘

1. User visits site
   ↓
2. JavaScript shows popup:
   ┌──────────────────────────────────────┐
   │  🔐 Enter Access Code                │
   │                                      │
   │  [_______________]                   │
   │                                      │
   │  [Submit]                            │
   └──────────────────────────────────────┘
   ↓
3. User enters access code
   ↓
4. JavaScript validates code against hardcoded hash
   ↓
5. If valid:
   - Generate JWT token with expiration
   - Store in localStorage
   - Hide popup, show content
   ↓
6. If invalid:
   - Show error message
   - Ask for code again
```

### Implementation Files

#### 1. Create `static/jwt-auth-gate.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Access Code Required</title>
  <style>
    /* Same styles as GitHub OAuth version */
    #auth-overlay {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0, 0, 0, 0.9);
      backdrop-filter: blur(10px);
      display: flex;
      justify-content: center;
      align-items: center;
      z-index: 999999;
    }

    .auth-modal {
      background: white;
      padding: 3rem;
      border-radius: 16px;
      box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
      max-width: 450px;
      width: 90%;
      text-align: center;
    }

    .auth-modal h1 {
      margin: 0 0 1rem 0;
      font-size: 28px;
      color: #333;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }

    .auth-modal p {
      color: #666;
      font-size: 16px;
      line-height: 1.6;
      margin-bottom: 2rem;
    }

    .access-code-input {
      width: 100%;
      padding: 14px;
      font-size: 16px;
      border: 2px solid #e1e4e8;
      border-radius: 8px;
      font-family: monospace;
      text-align: center;
      letter-spacing: 2px;
      margin-bottom: 1rem;
    }

    .access-code-input:focus {
      outline: none;
      border-color: #667eea;
    }

    .submit-btn {
      width: 100%;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      border: none;
      padding: 14px 32px;
      font-size: 16px;
      border-radius: 8px;
      cursor: pointer;
      font-weight: 600;
      transition: transform 0.2s ease;
    }

    .submit-btn:hover {
      transform: translateY(-2px);
    }

    .submit-btn:disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }

    .error-message {
      display: none;
      color: #d73a49;
      background: #ffeef0;
      padding: 12px;
      border-radius: 6px;
      margin-top: 1rem;
      font-size: 14px;
    }

    .error-message.active {
      display: block;
    }

    .success-message {
      display: none;
      color: #28a745;
      background: #dcffe4;
      padding: 12px;
      border-radius: 6px;
      margin-top: 1rem;
      font-size: 14px;
    }

    .success-message.active {
      display: block;
    }
  </style>
</head>
<body>
  <div id="auth-overlay">
    <div class="auth-modal">
      <div style="font-size: 48px; margin-bottom: 1rem;">🔑</div>
      <h1>Access Code Required</h1>
      <p>This site is restricted. Please enter your access code to continue.</p>

      <form onsubmit="submitAccessCode(event)">
        <input
          type="password"
          id="access-code"
          class="access-code-input"
          placeholder="Enter access code"
          autocomplete="off"
          required
          autofocus
        />
        <button type="submit" class="submit-btn" id="submit-btn">
          Verify Access Code
        </button>
      </form>

      <div class="error-message" id="error-message">
        Invalid access code. Please try again.
      </div>

      <div class="success-message" id="success-message">
        ✓ Access granted! Loading site...
      </div>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/js-sha256@0.9.0/build/sha256.min.js"></script>
  <script>
    // Configuration
    const CONFIG = {
      // SHA-256 hash of valid access codes
      // Generate using: sha256("your-secret-code")
      VALID_CODE_HASHES: [
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', // Example: sha256("secret123")
        // Add more hashes for multiple valid codes
      ],
      TOKEN_KEY: 'auth_token',
      TOKEN_EXPIRY: 7 * 24 * 60 * 60 * 1000, // 7 days
      MAX_ATTEMPTS: 5,
      LOCKOUT_TIME: 30 * 60 * 1000, // 30 minutes
    };

    // Check if already authenticated
    function checkAuth() {
      const token = localStorage.getItem(CONFIG.TOKEN_KEY);

      if (token) {
        try {
          const payload = JSON.parse(atob(token.split('.')[1]));
          if (payload.exp > Date.now()) {
            // Token is still valid
            hideAuthGate();
            return true;
          }
        } catch (e) {
          // Invalid token
          localStorage.removeItem(CONFIG.TOKEN_KEY);
        }
      }

      return false;
    }

    // Check for rate limiting
    function checkRateLimit() {
      const attempts = parseInt(localStorage.getItem('auth_attempts') || '0');
      const lockoutUntil = parseInt(localStorage.getItem('auth_lockout') || '0');

      if (lockoutUntil > Date.now()) {
        const minutesLeft = Math.ceil((lockoutUntil - Date.now()) / 60000);
        showError(`Too many failed attempts. Please try again in ${minutesLeft} minutes.`);
        document.getElementById('submit-btn').disabled = true;
        return false;
      }

      return true;
    }

    // Submit access code
    function submitAccessCode(event) {
      event.preventDefault();

      if (!checkRateLimit()) {
        return;
      }

      const input = document.getElementById('access-code');
      const code = input.value.trim();

      if (!code) {
        showError('Please enter an access code.');
        return;
      }

      // Hash the entered code
      const codeHash = sha256(code);

      // Check if hash matches any valid code
      if (CONFIG.VALID_CODE_HASHES.includes(codeHash)) {
        // Valid code!
        grantAccess();
      } else {
        // Invalid code
        handleFailedAttempt();
      }
    }

    // Grant access
    function grantAccess() {
      // Create JWT-like token
      const header = btoa(JSON.stringify({ alg: 'none', typ: 'JWT' }));
      const payload = btoa(JSON.stringify({
        iat: Date.now(),
        exp: Date.now() + CONFIG.TOKEN_EXPIRY,
        site: 'ukwa-limited-access',
      }));
      const token = `${header}.${payload}.`;

      // Store token
      localStorage.setItem(CONFIG.TOKEN_KEY, token);

      // Reset attempts
      localStorage.removeItem('auth_attempts');
      localStorage.removeItem('auth_lockout');

      // Show success
      showSuccess('Access granted! Loading site...');

      // Hide gate and reload
      setTimeout(() => {
        hideAuthGate();
        window.location.reload();
      }, 1500);
    }

    // Handle failed attempt
    function handleFailedAttempt() {
      let attempts = parseInt(localStorage.getItem('auth_attempts') || '0');
      attempts++;
      localStorage.setItem('auth_attempts', attempts.toString());

      if (attempts >= CONFIG.MAX_ATTEMPTS) {
        // Lockout
        localStorage.setItem('auth_lockout', (Date.now() + CONFIG.LOCKOUT_TIME).toString());
        showError(`Too many failed attempts. Locked out for 30 minutes.`);
        document.getElementById('submit-btn').disabled = true;
      } else {
        showError(`Invalid access code. ${CONFIG.MAX_ATTEMPTS - attempts} attempts remaining.`);
      }

      // Clear input
      document.getElementById('access-code').value = '';
    }

    // Hide authentication overlay
    function hideAuthGate() {
      const overlay = document.getElementById('auth-overlay');
      if (overlay) {
        overlay.style.display = 'none';
      }
    }

    // Show error message
    function showError(message) {
      const errorDiv = document.getElementById('error-message');
      errorDiv.textContent = message;
      errorDiv.classList.add('active');
      document.getElementById('success-message').classList.remove('active');
    }

    // Show success message
    function showSuccess(message) {
      const successDiv = document.getElementById('success-message');
      successDiv.textContent = message;
      successDiv.classList.add('active');
      document.getElementById('error-message').classList.remove('active');
    }

    // Initialize
    if (!checkAuth()) {
      checkRateLimit();
      console.log('Authentication required');
    }
  </script>
</body>
</html>
```

#### 2. Generate Access Code Hashes

Create `scripts/generate-hash.html` (open in browser to generate hashes):

```html
<!DOCTYPE html>
<html>
<head>
  <title>Access Code Hash Generator</title>
  <script src="https://cdn.jsdelivr.net/npm/js-sha256@0.9.0/build/sha256.min.js"></script>
  <style>
    body {
      font-family: monospace;
      max-width: 600px;
      margin: 50px auto;
      padding: 20px;
    }
    input {
      width: 100%;
      padding: 10px;
      font-size: 16px;
      margin: 10px 0;
    }
    #result {
      background: #f5f5f5;
      padding: 15px;
      border-radius: 5px;
      word-break: break-all;
      margin-top: 20px;
    }
  </style>
</head>
<body>
  <h1>Access Code Hash Generator</h1>
  <p>Enter your secret access code to generate a SHA-256 hash:</p>

  <input
    type="text"
    id="code"
    placeholder="Enter access code"
    oninput="generateHash()"
  />

  <h3>SHA-256 Hash:</h3>
  <div id="result">Enter a code above</div>

  <script>
    function generateHash() {
      const code = document.getElementById('code').value;
      if (code) {
        const hash = sha256(code);
        document.getElementById('result').textContent = hash;
      } else {
        document.getElementById('result').textContent = 'Enter a code above';
      }
    }
  </script>
</body>
</html>
```

#### 3. Inject JWT Auth Gate into Pages

Same as Solution 1, but load `jwt-auth-gate.html` instead:

```html
<script>
  (function() {
    const TOKEN_KEY = 'auth_token';

    function checkAuth() {
      const token = localStorage.getItem(TOKEN_KEY);
      if (token) {
        try {
          const payload = JSON.parse(atob(token.split('.')[1]));
          if (payload.exp > Date.now()) {
            return true; // Authenticated
          }
        } catch (e) {
          localStorage.removeItem(TOKEN_KEY);
        }
      }

      // Not authenticated - inject auth gate
      const iframe = document.createElement('iframe');
      iframe.src = '/jwt-auth-gate.html';
      iframe.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;border:none;z-index:999999';
      document.body?.insertBefore(iframe, document.body.firstChild);
      return false;
    }

    checkAuth();
  })();
</script>
```

### Setup Instructions

#### Step 1: Generate Access Code Hashes (5 min)

1. Open `scripts/generate-hash.html` in browser
2. Enter access code: `ukwa-limited-2024`
3. Copy generated hash
4. Repeat for each code you want to allow

#### Step 2: Update Configuration (2 min)

Edit `static/jwt-auth-gate.html`:

```javascript
VALID_CODE_HASHES: [
  'abc123...', // Hash of first code
  'def456...', // Hash of second code
],
```

#### Step 3: Deploy (2 min)

```bash
git add static/jwt-auth-gate.html layouts/_default/baseof.html
git commit -m "feat: add JWT-based authentication gate"
git push origin dev_limited_access
```

#### Step 4: Share Access Codes (1 min)

Share the access codes with authorized users via secure channel (email, Signal, etc.):
- `mindaugas.vidmantas@bl.uk` → Code: `ukwa-limited-2024`

### Pros & Cons

**Pros:**
- ✅ **100% Free** - No external services at all
- ✅ **No Backend** - Pure client-side
- ✅ **Simple Setup** - Just static files
- ✅ **Popup Modal** - JavaScript-based as requested
- ✅ **Multiple Codes** - Support multiple access codes
- ✅ **Rate Limiting** - Prevents brute force

**Cons:**
- ⚠️ **Shared Secrets** - Everyone uses same code(s)
- ⚠️ **No User Tracking** - Can't identify individual users
- ⚠️ **Easy to Share** - Users can share code with unauthorized people
- ⚠️ **Client-Side Only** - Can be bypassed with dev tools (see security note)

---

## Comparison

| Feature | GitHub OAuth (Sol 1) | JWT Challenge (Sol 2) |
|---------|---------------------|----------------------|
| **Cost** | Free | Free |
| **Popup Auth** | ✅ Yes | ✅ Yes |
| **User Identity** | ✅ GitHub username | ❌ Anonymous |
| **User Tracking** | ✅ Yes | ❌ No |
| **Revoke Access** | ✅ Per user | ❌ Must change all codes |
| **Setup Complexity** | Medium | Low |
| **Backend Needed** | Tiny (1 function) | None |
| **Organization Restrict** | ✅ Yes | ❌ No |
| **Shareability Risk** | Low | High |
| **Best For** | Known users with GitHub | Temporary/simple access |

---

## Security Considerations

### ⚠️ Important Security Note

**Both solutions can be bypassed by determined users with developer tools**, because:
- Authentication runs client-side (JavaScript)
- Users can disable JavaScript
- Users can delete localStorage checks
- Users can modify DOM to hide popups

### Why Client-Side Auth Is Limited

```
Normal server-side auth:
  Server checks credentials → Server decides if content is sent → Content delivered

Client-side auth:
  Content already delivered → JavaScript checks credentials → JavaScript hides/shows content
  ↑                                                           ↑
  Content is already in browser                              User can bypass JavaScript
```

### Making It "Good Enough"

While not perfectly secure, you can make it reasonable for honest users:

1. **Obfuscate Content**
   - Don't load sensitive content until authenticated
   - Use AJAX to fetch content after auth

2. **Regular Key Rotation**
   - Change access codes monthly (JWT solution)
   - Expire tokens regularly

3. **Monitor Access**
   - Add analytics to track who accesses site
   - Log authentication attempts

4. **Education**
   - Tell users not to share access
   - Explain it's for authorized use only

### When Client-Side Auth Is OK

✅ **Good for:**
- Internal tools (honest users)
- Beta testing (low stakes)
- Temporary restrictions
- "Speed bump" security
- Preventing accidental public access
- SEO blocking

❌ **NOT good for:**
- Highly sensitive data
- Legal compliance requirements
- Financial information
- Personal data (GDPR)
- Anything requiring audit trails

---

## Recommendation for UKWA

### Use **Solution 1: GitHub OAuth** because:

1. ✅ **Free** - Uses Netlify free tier
2. ✅ **Popup Authentication** - JavaScript modal as requested
3. ✅ **User Identification** - Know who's accessing
4. ✅ **Org Restrictions** - Can limit to GitHub organization
5. ✅ **Revocable** - Remove specific users anytime
6. ✅ **Audit Trail** - Track who accessed when

### Implementation Timeline

**Week 1:**
- Set up GitHub OAuth app
- Create auth-gate.html and callback.html
- Test locally

**Week 2:**
- Deploy Netlify function
- Configure environment variables
- Test on production URL

**Week 3:**
- Add to baseof.html
- Test with authorized users
- Fix any issues

**Week 4:**
- Document for users
- Go live

---

## Cost Breakdown

### Solution 1: GitHub OAuth

| Component | Cost |
|-----------|------|
| Netlify Hosting | $0 (free tier) |
| Netlify Functions | $0 (125k requests/month free) |
| GitHub OAuth App | $0 (free) |
| **Total** | **$0/month** |

### Solution 2: JWT Challenge

| Component | Cost |
|-----------|------|
| Netlify Hosting | $0 (free tier) |
| **Total** | **$0/month** |

**Both solutions are 100% free!**

---

## Next Steps

1. **Choose Solution:**
   - GitHub OAuth (recommended) for user tracking
   - JWT Challenge for simpler setup

2. **Create GitHub OAuth App** (if using Solution 1)

3. **Add Files to Repository:**
   ```bash
   static/auth-gate.html          # or jwt-auth-gate.html
   static/callback.html           # (OAuth only)
   netlify/functions/github-oauth.ts  # (OAuth only)
   layouts/_default/baseof.html   # Updated with auth check
   ```

4. **Configure:**
   - Set environment variables (OAuth)
   - Set allowed users/codes

5. **Deploy and Test:**
   ```bash
   git push origin dev_limited_access
   ```

---

**Ready to implement? Start with Solution 1 (GitHub OAuth) for the best balance of security and user experience!**
