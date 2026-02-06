---
name: function-generator
description: Generate Shopify Functions for discounts, payments, and delivery customization
allowed-tools:
  - Read
  - Write
  - Bash(npm *, npx *)
  - Glob
---

# Shopify Function Generator

Generate Shopify Functions for extending Shopify's backend logic.

## Triggers

- "create shopify function"
- "discount function"
- "payment customization"
- "delivery customization"
- "cart transform"

## Process

1. **Determine Function Type**
   - `product_discounts` - Line item discounts
   - `order_discounts` - Order-level discounts
   - `shipping_discounts` - Shipping discounts
   - `payment_customization` - Payment methods
   - `delivery_customization` - Delivery options
   - `cart_transform` - Cart modifications

2. **Scaffold Function**
   ```bash
   npm run shopify app generate extension -- --type {function_type} --name {name}
   ```

3. **Implement Logic**
   - Create `run.js` or `run.graphql` + `run.js`
   - Define input query in `input.graphql`
   - Add configuration UI if needed

4. **Test Function**
   ```bash
   npm run shopify app function run
   ```

## Output

Creates:
- `extensions/{name}/` - Function extension directory
- `extensions/{name}/src/run.js` - Function implementation
- `extensions/{name}/input.graphql` - Input query
- `extensions/{name}/shopify.extension.toml` - Configuration

## Templates

### Discount Function
```javascript
// extensions/{name}/src/run.js
export function run(input) {
  const configuration = JSON.parse(input.discountNode.metafield?.value ?? "{}");
  const threshold = configuration.threshold ?? 100;
  const percentage = configuration.percentage ?? 10;

  const subtotal = parseFloat(input.cart.cost.subtotalAmount.amount);

  if (subtotal < threshold) {
    return { discounts: [] };
  }

  return {
    discounts: [{
      value: { percentage: { value: percentage.toString() } },
      targets: [{ orderSubtotal: { excludedVariantIds: [] } }],
      message: `${percentage}% off orders over $${threshold}`,
    }],
  };
}
```

### Payment Customization
```javascript
export function run(input) {
  const configuration = JSON.parse(input.paymentCustomization.metafield?.value ?? "{}");
  const hideMethod = configuration.hidePaymentMethod;

  const operations = input.paymentMethods
    .filter(method => method.name.includes(hideMethod))
    .map(method => ({ hide: { paymentMethodId: method.id } }));

  return { operations };
}
```

### Cart Transform (Bundle Expansion)
```javascript
export function run(input) {
  const operations = [];

  for (const line of input.cart.lines) {
    const bundleMetafield = line.merchandise.product?.bundleComponents?.value;
    if (!bundleMetafield) continue;

    const components = JSON.parse(bundleMetafield);
    operations.push({
      expand: {
        cartLineId: line.id,
        expandedCartItems: components.map(c => ({
          merchandiseId: c.variantId,
          quantity: c.quantity,
        })),
      },
    });
  }

  return { operations };
}
```

## Best Practices

- Keep execution time under 5ms
- Minimize input query to only needed fields
- Use Rust for complex logic (better performance)
- Test with realistic cart data
- Handle edge cases gracefully (empty cart, missing data)
