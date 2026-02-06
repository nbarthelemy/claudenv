# Next.js Stack Reference

> Detailed code patterns, examples, and best practices for Next.js 16 App Router projects.

## Code Examples

### Server Components First

```typescript
// ✅ Good - Server Component (default)
export default async function ProductPage({ params }: Props) {
  const product = await getProduct(params.id)
  return <ProductDetails product={product} />
}

// ✅ Good - Client Component only when needed
"use client"
export function AddToCartButton({ productId }: Props) {
  const [loading, setLoading] = useState(false)
  // ...
}
```

### Data Fetching in Server Components

```typescript
// ✅ Good - Fetch in Server Component, pass to Client
export default async function Dashboard() {
  const data = await fetchDashboardData()
  return <DashboardChart data={data} />
}

// ❌ Bad - Fetching in Client Component
"use client"
export function Dashboard() {
  const [data, setData] = useState(null)
  useEffect(() => { fetchData().then(setData) }, [])
}
```

### Server Actions

```typescript
// ✅ Good - Server Action
'use server'
export async function createPost(formData: FormData) {
  const data = schema.parse(Object.fromEntries(formData))
  await db.insert(posts).values(data)
  revalidatePath('/posts')
}

// ❌ Bad - API route for simple mutation
export async function POST(req: Request) {
  const data = await req.json()
  await db.insert(posts).values(data)
}
```

### Type Safety

```typescript
// ✅ Good
interface User {
  id: string
  name: string
  email: string
}

async function getUser(id: string): Promise<User | null> {
  return db.query.users.findFirst({ where: eq(users.id, id) })
}

// ❌ Bad
async function getUser(id: any): Promise<any> {
  return db.query.users.findFirst({ where: eq(users.id, id) })
}
```

### Input Validation

```typescript
// ✅ Good
const schema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(100),
})

export async function createUser(formData: FormData) {
  const result = schema.safeParse(Object.fromEntries(formData))
  if (!result.success) {
    return { error: result.error.flatten() }
  }
  // proceed with validated data
}

// ❌ Bad - No validation
export async function createUser(formData: FormData) {
  const email = formData.get('email') as string
  await db.insert(users).values({ email })
}
```

### Error Handling

```typescript
// ✅ Good - Server Action with error handling
export async function submitForm(formData: FormData) {
  try {
    const data = schema.parse(Object.fromEntries(formData))
    await db.insert(items).values(data)
    revalidatePath('/items')
    return { success: true }
  } catch (error) {
    if (error instanceof z.ZodError) {
      return { error: error.flatten() }
    }
    console.error('Form submission failed:', error)
    return { error: 'Something went wrong' }
  }
}
```

### Caching

```typescript
// ✅ Good - Cache with tags for invalidation
import { unstable_cache } from 'next/cache'

export const getProducts = unstable_cache(
  async () => db.query.products.findMany(),
  ['products'],
  { revalidate: 60, tags: ['products'] }
)

// Invalidate when data changes
import { revalidateTag } from 'next/cache'
revalidateTag('products')
```

### Image Optimization

```typescript
// ✅ Good
import Image from 'next/image'

<Image
  src={product.imageUrl}
  alt={product.name}
  width={400}
  height={300}
  className="rounded-lg"
/>

// ❌ Bad
<img src={product.imageUrl} alt={product.name} />
```

---

## Code Patterns

### API Route Pattern

```typescript
// apps/web/src/app/api/example/route.ts
import { NextRequest } from "next/server";
import { z } from "zod";
import { db } from "@/lib/db";
import {
  withErrorHandling,
  successResponse,
  requireAuth,
} from "@/lib/api-utils";

const schema = z.object({
  name: z.string().min(1),
});

export const POST = withErrorHandling(async (req: NextRequest) => {
  const user = await requireAuth();
  const body = await req.json();
  const data = schema.parse(body);

  const result = await db.insert(models).values(data).returning();
  return successResponse(result, 201);
});
```

### Database Pattern

```typescript
// Always use db from @/lib/db
import { db } from "@/lib/db";
import { users, workspaces } from "@/lib/db/schema";

// Use transactions for multi-step operations
await db.transaction(async (tx) => {
  const [user] = await tx.insert(users).values(data).returning();
  await tx.insert(workspaces).values({ ownerId: user.id });
});
```

### Component Pattern

```typescript
// Use shadcn/ui + @siquora/ui
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardContent } from "@/components/ui/card";

// Or from shared package
import { DataTable } from "@siquora/ui";
```

### Server Actions Pattern

```typescript
'use server'

import { revalidatePath } from 'next/cache'
import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1),
})

export async function createItem(formData: FormData) {
  const validated = schema.safeParse({
    name: formData.get('name'),
  })

  if (!validated.success) {
    return { error: validated.error.flatten() }
  }

  // Create item...

  revalidatePath('/items')
  return { success: true }
}
```

---

## Security Patterns

### Never Expose Secrets

```typescript
// ❌ NEVER include in client code
const apiKey = process.env.STRIPE_SECRET_KEY

// ✅ Only use in server-side code
// app/api/checkout/route.ts (server only)
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)
```

### Sanitize User Input

```typescript
// ✅ Always sanitize HTML content
import DOMPurify from 'isomorphic-dompurify'

const cleanHtml = DOMPurify.sanitize(userInput)
```

### Protect Routes with Middleware

```typescript
// middleware.ts
import { auth } from "@/auth"

export default auth((req) => {
  const isProtected = req.nextUrl.pathname.startsWith('/dashboard')
  if (isProtected && !req.auth) {
    return Response.redirect(new URL('/login', req.url))
  }
})
```

---

## Performance Patterns

### Avoid Waterfalls

```typescript
// ✅ Good - Parallel fetching
const [user, posts, stats] = await Promise.all([
  getUser(id),
  getPosts(id),
  getStats(id),
])

// ❌ Bad - Sequential fetching (waterfall)
const user = await getUser(id)
const posts = await getPosts(id)
const stats = await getStats(id)
```

### Use Suspense for Streaming

```typescript
// ✅ Good - Stream slow content
import { Suspense } from 'react'

export default function Page() {
  return (
    <div>
      <Header />
      <Suspense fallback={<Skeleton />}>
        <SlowDataComponent />
      </Suspense>
    </div>
  )
}
```
