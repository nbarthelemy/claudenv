# Stripe Setup Guide

Complete setup guide for Stripe payment integration.

## Step 1: Create Stripe Account

1. Go to [Stripe Dashboard](https://dashboard.stripe.com)
2. Sign up or log in
3. Make sure you're in **Test mode** (toggle in sidebar)

## Step 2: Get API Keys

1. Go to **Developers** → **API keys**
2. Copy the **Publishable key** (starts with `pk_test_`)
3. Copy the **Secret key** (starts with `sk_test_`)

```bash
STRIPE_SECRET_KEY="sk_test_..."
STRIPE_PUBLISHABLE_KEY="pk_test_..."
```

## Step 3: Create Products and Prices

1. Go to **Products** → **Add product**
2. Create products for each tier in your app
3. After creating each price, copy the Price ID (starts with `price_`)
4. Add Price IDs to your environment variables

**Example pricing structure:**
```bash
STRIPE_STARTER_PRICE="price_xxx"
STRIPE_PRO_PRICE="price_xxx"
STRIPE_TEAM_PRICE="price_xxx"
```

## Step 4: Set Up Webhooks (Local Development)

1. Install [Stripe CLI](https://stripe.com/docs/stripe-cli):
   ```bash
   # macOS
   brew install stripe/stripe-cli/stripe

   # Login
   stripe login
   ```

2. Forward webhooks to local server:
   ```bash
   stripe listen --forward-to localhost:3000/api/webhooks/stripe
   ```

3. Copy the webhook signing secret (starts with `whsec_`):
   ```bash
   STRIPE_WEBHOOK_SECRET="whsec_..."
   ```

## Step 5: Set Up Webhooks (Production)

1. Go to **Developers** → **Webhooks**
2. Click **Add endpoint**
3. Endpoint URL: `https://your-app.ai/api/webhooks/stripe`
4. Select events:
   - `checkout.session.completed`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.paid`
   - `invoice.payment_failed`
5. Click **Add endpoint**
6. Copy the signing secret

## Environment Variables Summary

```bash
# Stripe API
STRIPE_SECRET_KEY="sk_test_..."
STRIPE_PUBLISHABLE_KEY="pk_test_..."
STRIPE_WEBHOOK_SECRET="whsec_..."

# Product Price IDs (project-specific)
STRIPE_STARTER_PRICE="price_..."
STRIPE_PRO_PRICE="price_..."
STRIPE_TEAM_PRICE="price_..."
```

## Troubleshooting

### "Stripe webhook signature verification failed"

- Make sure you're using the correct webhook secret
- For local dev, use Stripe CLI: `stripe listen --forward-to localhost:3000/api/webhooks/stripe`
- The webhook secret from CLI is different from production

### "No such price" error

- Verify the Price ID exists in your Stripe Dashboard
- Make sure you're using test mode prices with test API keys
