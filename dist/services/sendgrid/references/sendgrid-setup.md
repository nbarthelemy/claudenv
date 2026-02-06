# SendGrid Setup Guide

Complete setup guide for SendGrid email integration.

## Option A: Direct SendGrid Account

1. Go to [SendGrid](https://signup.sendgrid.com)
2. Sign up for a free account (100 emails/day)
3. Go to **Settings** → **API Keys**
4. Click **Create API Key**
   - Name: `{Project} Dev`
   - Permissions: **Full Access** (or Restricted with Mail Send)
5. Copy the API key (only shown once!)

```bash
SENDGRID_API_KEY="SG.xxxxx..."
```

## Option B: Via GCP Marketplace (Recommended for Production)

1. Go to [GCP Marketplace - SendGrid](https://console.cloud.google.com/marketplace/product/sendgrid-app/sendgrid-email)
2. Click **Subscribe**
3. Select your billing account
4. Choose a plan (Free tier: 12,000 emails/month)
5. After activation, go to SendGrid Dashboard
6. Create API key as above

## Verify Sender Domain (Production)

1. In SendGrid, go to **Settings** → **Sender Authentication**
2. Click **Authenticate Your Domain**
3. Add DNS records to your domain:
   - CNAME records for email authentication
   - TXT record for SPF
4. Verify the domain

## Environment Variables

```bash
SENDGRID_API_KEY="SG.xxxxx..."
EMAIL_FROM="{Project} <noreply@{project}.ai>"
```

## Troubleshooting

### "SendGrid API key invalid"

- Make sure the API key has Mail Send permissions
- Check there are no extra spaces in your `.env.local`
- Verify the key starts with `SG.`

### Emails going to spam

- Verify your sender domain
- Set up SPF, DKIM, and DMARC records
- Use consistent "from" address
