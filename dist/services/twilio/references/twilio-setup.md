# Twilio Setup Guide

Complete setup guide for Twilio SMS integration.

## Step 1: Create Twilio Account

1. Go to [Twilio](https://www.twilio.com/try-twilio)
2. Sign up for a free trial ($15 credit)
3. Verify your phone number

## Step 2: Get a Phone Number

1. Go to **Phone Numbers** → **Manage** → **Buy a number**
2. Search for a number with SMS capability
3. Purchase the number

## Step 3: Get Credentials

1. Go to **Account** → **API keys & tokens**
2. Copy your **Account SID** and **Auth Token**

```bash
TWILIO_ACCOUNT_SID="ACxxxxx..."
TWILIO_AUTH_TOKEN="xxxxx..."
TWILIO_PHONE_NUMBER="+1234567890"
```

## Step 4: Set Up Twilio Verify (Optional)

For built-in OTP verification:

1. Go to **Verify** → **Services**
2. Click **Create new**
3. Name: `{Project}`
4. Enable SMS channel
5. Copy the Service SID

```bash
TWILIO_VERIFY_SERVICE_SID="VAxxxxx..."
```

## Environment Variables Summary

```bash
# Required
TWILIO_ACCOUNT_SID="ACxxxxx..."
TWILIO_AUTH_TOKEN="xxxxx..."
TWILIO_PHONE_NUMBER="+1234567890"

# Optional (for OTP)
TWILIO_VERIFY_SERVICE_SID="VAxxxxx..."
```

## Troubleshooting

### "Invalid phone number"

- Ensure phone number includes country code (+1 for US)
- Verify the number is SMS-capable

### "Authentication error"

- Check Account SID and Auth Token are correct
- Make sure there are no extra spaces in env vars
