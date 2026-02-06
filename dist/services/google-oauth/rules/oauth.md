# Google OAuth Rules

> Full setup: `.claude/references/setup/google-oauth-setup.md`

## Integration Pattern

1. **Credentials** in env: `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`
2. Use NextAuth.js with Google provider
3. Callback URL: `/api/auth/callback/google`

## NextAuth Configuration

```typescript
// auth.ts
import Google from "next-auth/providers/google";

export const authConfig = {
  providers: [
    Google({
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    }),
  ],
};
```

## Required Scopes

- `email` - User's email address
- `profile` - User's name and picture
- `openid` - OpenID Connect

## Redirect URIs

| Environment | URI |
|-------------|-----|
| Local | `http://localhost:3000/api/auth/callback/google` |
| Local (HTTPS) | `https://{project}.dev/api/auth/callback/google` |
| Production | `https://{project}.ai/api/auth/callback/google` |

## Security

- Never expose `GOOGLE_CLIENT_SECRET` to client
- Use HTTPS in production
- Restrict to verified domains
