---
name: ajax-cart-generator
description: Generate AJAX cart functionality for Shopify themes
allowed-tools:
  - Read
  - Write
  - Glob
---

# AJAX Cart Generator

Generate AJAX-powered cart functionality for Shopify themes.

## Triggers

- "ajax cart"
- "cart drawer"
- "add to cart ajax"
- "cart api"
- "dynamic cart"

## Process

1. **Determine Cart Type**
   - Cart drawer (slide-out)
   - Cart modal (popup)
   - Mini cart (header dropdown)
   - Inline cart updates

2. **Check Existing Implementation**
   - Look for existing cart JavaScript
   - Check for cart section

3. **Generate Components**
   - JavaScript cart API wrapper
   - Cart section with section rendering
   - Add to cart button handling
   - Cart notifications

## Output

Creates:
- `assets/cart-api.js` - Cart API wrapper
- `sections/cart-drawer.liquid` - Cart drawer section
- `snippets/cart-item.liquid` - Cart item snippet
- `snippets/add-to-cart-button.liquid` - Add to cart button

## Templates

### Cart API Wrapper
```javascript
// assets/cart-api.js
class CartAPI {
  constructor() {
    this.queue = [];
    this.processing = false;
  }

  async add(items) {
    const response = await fetch('/cart/add.js', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ items }),
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.description || 'Failed to add to cart');
    }

    return response.json();
  }

  async update(updates) {
    const response = await fetch('/cart/update.js', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ updates }),
    });
    return response.json();
  }

  async change(line, quantity) {
    const response = await fetch('/cart/change.js', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ line, quantity }),
    });
    return response.json();
  }

  async get() {
    const response = await fetch('/cart.js');
    return response.json();
  }

  async clear() {
    const response = await fetch('/cart/clear.js', {
      method: 'POST',
    });
    return response.json();
  }

  // Fetch rendered cart section
  async getSection(sectionId) {
    const response = await fetch(`/?sections=${sectionId}`);
    const data = await response.json();
    return data[sectionId];
  }
}

window.cart = new CartAPI();
```

### Cart Drawer Section
```liquid
{% comment %} sections/cart-drawer.liquid {% endcomment %}
<cart-drawer id="cart-drawer" class="cart-drawer">
  <div class="cart-drawer__overlay" data-cart-close></div>
  <div class="cart-drawer__content">
    <header class="cart-drawer__header">
      <h2>{{ 'cart.title' | t }} ({{ cart.item_count }})</h2>
      <button type="button" class="cart-drawer__close" data-cart-close>
        {% render 'icon-close' %}
      </button>
    </header>

    {% if cart.item_count > 0 %}
      <div class="cart-drawer__items">
        {% for item in cart.items %}
          {% render 'cart-item', item: item %}
        {% endfor %}
      </div>

      <footer class="cart-drawer__footer">
        <div class="cart-drawer__subtotal">
          <span>{{ 'cart.subtotal' | t }}</span>
          <span>{{ cart.total_price | money }}</span>
        </div>
        <a href="{{ routes.cart_url }}" class="button button--secondary">
          {{ 'cart.view_cart' | t }}
        </a>
        <button type="submit" name="checkout" class="button button--primary">
          {{ 'cart.checkout' | t }}
        </button>
      </footer>
    {% else %}
      <div class="cart-drawer__empty">
        <p>{{ 'cart.empty' | t }}</p>
        <a href="{{ routes.collections_url }}" class="button">
          {{ 'cart.continue_shopping' | t }}
        </a>
      </div>
    {% endif %}
  </div>
</cart-drawer>

{% schema %}
{
  "name": "Cart Drawer",
  "settings": []
}
{% endschema %}
```

### Add to Cart Handler
```javascript
// assets/add-to-cart.js
class AddToCart extends HTMLElement {
  constructor() {
    super();
    this.form = this.querySelector('form');
    this.button = this.querySelector('[type="submit"]');
    this.form.addEventListener('submit', this.onSubmit.bind(this));
  }

  async onSubmit(event) {
    event.preventDefault();

    this.button.disabled = true;
    this.button.classList.add('loading');

    try {
      const formData = new FormData(this.form);
      const items = [{
        id: formData.get('id'),
        quantity: parseInt(formData.get('quantity') || 1),
      }];

      await window.cart.add(items);

      // Update cart drawer
      const html = await window.cart.getSection('cart-drawer');
      document.getElementById('cart-drawer').outerHTML = html;

      // Open cart drawer
      document.querySelector('cart-drawer').open();

    } catch (error) {
      console.error('Add to cart failed:', error);
      this.showError(error.message);
    } finally {
      this.button.disabled = false;
      this.button.classList.remove('loading');
    }
  }

  showError(message) {
    // Show error notification
  }
}

customElements.define('add-to-cart', AddToCart);
```

## Best Practices

- Use section rendering for dynamic updates
- Handle network errors gracefully
- Show loading states during requests
- Update cart count in header
- Announce changes to screen readers
- Support quantity limits
