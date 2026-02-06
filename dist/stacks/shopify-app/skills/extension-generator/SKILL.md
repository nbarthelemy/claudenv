---
name: extension-generator
description: Generate Shopify App Extensions for checkout, admin, and theme customization
allowed-tools:
  - Read
  - Write
  - Bash(npm *, npx *)
  - Glob
---

# Shopify Extension Generator

Generate Shopify App Extensions for UI customization.

## Triggers

- "create checkout extension"
- "admin extension"
- "theme app extension"
- "web pixel"
- "post purchase extension"

## Process

1. **Determine Extension Type**
   - `checkout_ui` - Checkout UI customization
   - `admin_block` - Admin UI blocks
   - `admin_action` - Admin action extensions
   - `theme_app_extension` - Theme blocks
   - `web_pixel` - Event tracking
   - `post_purchase` - Post-purchase upsells

2. **Scaffold Extension**
   ```bash
   npm run shopify app generate extension -- --type {type} --name {name}
   ```

3. **Implement UI**
   - Use Shopify UI components
   - Add extension settings
   - Handle loading/error states

4. **Test Extension**
   - Use dev mode for live preview
   - Test on mobile viewports

## Output

Creates:
- `extensions/{name}/` - Extension directory
- `extensions/{name}/src/` - Source files
- `extensions/{name}/shopify.extension.toml` - Configuration

## Templates

### Checkout UI Extension
```jsx
// extensions/{name}/src/Checkout.jsx
import {
  Banner,
  BlockStack,
  Text,
  useSettings,
  reactExtension,
} from "@shopify/ui-extensions-react/checkout";

export default reactExtension("purchase.checkout.block.render", () => (
  <Extension />
));

function Extension() {
  const { banner_title, banner_content } = useSettings();

  return (
    <Banner title={banner_title || "Special Offer"}>
      <BlockStack>
        <Text>{banner_content || "Thank you for shopping with us!"}</Text>
      </BlockStack>
    </Banner>
  );
}
```

### Admin Block Extension
```jsx
// extensions/{name}/src/BlockExtension.jsx
import {
  AdminBlock,
  BlockStack,
  Text,
  Button,
  useApi,
} from "@shopify/ui-extensions-react/admin";

export default function App() {
  const { data } = useApi();
  const productId = data.selected?.[0]?.id;

  return (
    <AdminBlock title="Product Insights">
      <BlockStack gap="base">
        <Text>Analytics for this product</Text>
        <Button onPress={() => console.log("clicked")}>
          View Details
        </Button>
      </BlockStack>
    </AdminBlock>
  );
}
```

### Theme App Extension Block
```liquid
{% comment %} blocks/{name}.liquid {% endcomment %}
{% schema %}
{
  "name": "{{ name }}",
  "target": "section",
  "settings": [
    {
      "type": "text",
      "id": "heading",
      "label": "Heading",
      "default": "Featured Content"
    },
    {
      "type": "richtext",
      "id": "content",
      "label": "Content"
    }
  ]
}
{% endschema %}

<div class="{{ name | handleize }}-block">
  <h2>{{ block.settings.heading }}</h2>
  <div class="content">
    {{ block.settings.content }}
  </div>
</div>

{% stylesheet %}
.{{ name | handleize }}-block {
  padding: 2rem;
}
{% endstylesheet %}
```

### Web Pixel Extension
```javascript
// extensions/{name}/src/index.js
import { register } from "@shopify/web-pixels-extension";

register(({ analytics, browser, settings }) => {
  // Page view tracking
  analytics.subscribe("page_viewed", (event) => {
    sendEvent("page_view", {
      page_path: event.context.document.location.pathname,
    });
  });

  // Purchase tracking
  analytics.subscribe("checkout_completed", (event) => {
    const checkout = event.data.checkout;
    sendEvent("purchase", {
      transaction_id: checkout.order.id,
      value: checkout.totalPrice.amount,
      currency: checkout.currencyCode,
      items: checkout.lineItems.map(item => ({
        item_id: item.variant.product.id,
        item_name: item.title,
        quantity: item.quantity,
        price: item.variant.price.amount,
      })),
    });
  });

  function sendEvent(name, params) {
    // Send to your analytics service
    fetch(settings.endpoint, {
      method: "POST",
      body: JSON.stringify({ event: name, ...params }),
    });
  }
});
```

## Best Practices

- Use Shopify UI components for consistent UX
- Add settings for merchant customization
- Handle loading and error states
- Test on mobile devices
- Follow accessibility guidelines
- Keep checkout extensions lightweight
