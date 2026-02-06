# Stripe Rules

> Full setup: `.claude/references/setup/stripe-setup.md`

## Integration Pattern

1. **API keys** in env: `STRIPE_SECRET_KEY`, `STRIPE_PUBLISHABLE_KEY`
2. **Webhooks** via `/api/webhooks/stripe` endpoint
3. **Products/Prices** created in Stripe Dashboard, IDs in env

## Webhook Events

Required events for subscription billing:
- `checkout.session.completed`
- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`
- `invoice.paid`
- `invoice.payment_failed`

## Local Development

```bash
stripe listen --forward-to localhost:3000/api/webhooks/stripe
```

## Security

- Never expose `STRIPE_SECRET_KEY` to client
- Always verify webhook signatures
- Use test mode (`sk_test_`, `pk_test_`) for development
