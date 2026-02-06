# Google OAuth Setup Guide

Complete setup guide for Google OAuth authentication.

## Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Click **Select a project** → **New Project**
3. Name it `{project}-dev` (or similar)
4. Click **Create**

## Step 2: Configure OAuth Consent Screen

1. Go to **APIs & Services** → **OAuth consent screen**
2. Select **External** user type → **Create**
3. Fill in required fields:
   - App name: `{Project} (Dev)`
   - User support email: Your email
   - Developer contact: Your email
4. Click **Save and Continue**
5. **Scopes**: Click **Add or Remove Scopes**
   - Select `email`, `profile`, `openid`
   - Click **Update** → **Save and Continue**
6. **Test users**: Add your email address
7. Click **Save and Continue** → **Back to Dashboard**

## Step 3: Create OAuth Credentials

1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **OAuth client ID**
3. Application type: **Web application**
4. Name: `{Project} Web Client`
5. **Authorized JavaScript origins**:
   ```
   http://localhost:3000
   https://{project}.dev
   ```
6. **Authorized redirect URIs**:
   ```
   http://localhost:3000/api/auth/callback/google
   https://{project}.dev/api/auth/callback/google
   ```
7. Click **Create**
8. Copy **Client ID** and **Client Secret**

## Step 4: Add Production URLs (Before Launch)

Add to your OAuth credentials:

**Authorized JavaScript origins**:
```
https://{project}.ai
```

**Authorized redirect URIs**:
```
https://{project}.ai/api/auth/callback/google
```

## Environment Variables

```bash
GOOGLE_CLIENT_ID="your-client-id.apps.googleusercontent.com"
GOOGLE_CLIENT_SECRET="your-client-secret"
```

## Troubleshooting

### "Invalid OAuth redirect URI"

Make sure your redirect URI in Google Cloud Console exactly matches:
```
http://localhost:3000/api/auth/callback/google
```

Common issues:
- Missing trailing slash or extra trailing slash
- HTTP vs HTTPS mismatch
- Port number mismatch

### "Access blocked: This app's request is invalid"

- Check that all required scopes are added to consent screen
- Verify you're using the correct Client ID
- For development, add your email as a test user
