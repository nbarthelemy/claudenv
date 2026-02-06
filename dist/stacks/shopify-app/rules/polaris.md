# Polaris App Rules

> Conventions and patterns for Shopify app development with Remix and Polaris.

## Framework Versions

| Package | Version |
|---------|---------|
| Node.js | 22.x |
| React | 19.x |
| TypeScript | 5.7.x |
| Remix | Latest |
| Polaris | Latest |
| Drizzle | 0.38.x |

## App Structure

```
app/
├── routes/              # Remix routes
│   ├── app._index.tsx   # Main app page
│   ├── app.settings.tsx # Settings page
│   └── webhooks.tsx     # Webhook handlers
├── components/          # React/Polaris components
├── services/            # Business logic
├── shopify.server.ts    # Shopify API client
└── db.server.ts         # Drizzle client
src/db/                  # Database schema (Drizzle)
extensions/              # Shopify extensions
```

## Page Pattern

```tsx
import { Page, Layout, Card, Text } from '@shopify/polaris';
import { TitleBar } from '@shopify/app-bridge-react';
import { useLoaderData } from '@remix-run/react';

export async function loader({ request }) {
  const { admin } = await authenticate.admin(request);
  // Load data...
  return json({ data });
}

export default function SettingsPage() {
  const { data } = useLoaderData();

  return (
    <Page>
      <TitleBar title="Settings" />
      <Layout>
        <Layout.Section>
          <Card>
            <Text as="p">Settings content</Text>
          </Card>
        </Layout.Section>
      </Layout>
    </Page>
  );
}
```

## Form Pattern

```tsx
import { Form, FormLayout, TextField, Button } from '@shopify/polaris';
import { useFetcher } from '@remix-run/react';
import { useState, useCallback } from 'react';

export function SettingsForm({ initialValue }) {
  const fetcher = useFetcher();
  const [value, setValue] = useState(initialValue);

  return (
    <fetcher.Form method="post">
      <FormLayout>
        <TextField
          label="Setting"
          name="setting"
          value={value}
          onChange={setValue}
          autoComplete="off"
        />
        <Button submit loading={fetcher.state === 'submitting'}>
          Save
        </Button>
      </FormLayout>
    </fetcher.Form>
  );
}
```

## API Pattern

```tsx
// Authenticated Admin API call
export async function action({ request }) {
  const { admin } = await authenticate.admin(request);

  const response = await admin.graphql(`
    mutation createProduct($input: ProductInput!) {
      productCreate(input: $input) {
        product {
          id
          title
        }
        userErrors {
          field
          message
        }
      }
    }
  `, {
    variables: { input: { title: "New Product" } }
  });

  const { data } = await response.json();
  return json(data);
}
```

## Best Practices

- Use Polaris components exclusively for admin UI
- Follow Shopify App Design Guidelines
- Use App Bridge for navigation and actions
- Implement loading and error states
- Use Remix data loading patterns
- Keep forms accessible

## Automatic Behaviors

| Trigger | Action |
|---------|--------|
| New page created | Use Page + Layout + Card structure |
| API call needed | Use authenticated admin client |
| Form created | Use Polaris Form components |
| Data loading | Use Remix loader pattern |
