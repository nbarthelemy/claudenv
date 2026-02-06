# SMS Rules (Twilio)

> Full setup: `.claude/references/setup/twilio-setup.md`

## Integration Pattern

1. **Credentials** in env: `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`
2. **Phone number** in env: `TWILIO_PHONE_NUMBER`
3. Use `@siquora/sms` package for sending

## Usage

```typescript
import { sendSMS } from "@siquora/sms";

await sendSMS({
  to: user.phone,
  body: "Your verification code is 123456"
});
```

## Twilio Verify (OTP)

For built-in OTP verification:

```typescript
import { sendOTP, verifyOTP } from "@siquora/sms";

// Send OTP
await sendOTP(phoneNumber);

// Verify OTP
const valid = await verifyOTP(phoneNumber, code);
```

Requires `TWILIO_VERIFY_SERVICE_SID` in env.

## Security

- Never expose credentials to client
- Use Verify service for OTP (handles rate limiting)
- Validate phone numbers before sending
