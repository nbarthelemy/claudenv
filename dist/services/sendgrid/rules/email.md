# Email Rules (SendGrid)

> Full setup: `.claude/references/setup/sendgrid-setup.md`

## Integration Pattern

1. **API key** in env: `SENDGRID_API_KEY`
2. **From address** in env: `EMAIL_FROM`
3. Use `@siquora/email` package for sending

## Usage

```typescript
import { sendEmail } from "@siquora/email";

await sendEmail({
  to: user.email,
  subject: "Welcome",
  template: "welcome",
  data: { name: user.name }
});
```

## Domain Pattern

All emails sent from `{project}.ai` domain:
- `noreply@cmdstack.ai`
- `noreply@brandcmd.ai`

## Security

- Never expose `SENDGRID_API_KEY` to client
- Verify sender domain in production
- Use templates for consistent branding
