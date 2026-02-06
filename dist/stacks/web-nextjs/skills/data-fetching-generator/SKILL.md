---
name: data-fetching-generator
description: Generate data fetching patterns for Server Components and Client Components
allowed-tools:
  - Read
  - Write
  - Glob
  - WebFetch
---

# Data Fetching Generator

Generate data fetching patterns using React 19 and Next.js 16 best practices.

## Triggers

- "fetch data"
- "data fetching"
- "load data"
- "api call"
- "server component data"

## Documentation Access

**Research before implementing.** Consult:
- https://nextjs.org/docs/app/building-your-application/data-fetching - Next.js data fetching
- https://react.dev/reference/react/use - React use() hook

## Process

1. **Determine Fetching Pattern**
   - Server Component (recommended for most cases)
   - Client Component with SWR/React Query
   - Server Action for mutations

2. **Check Existing Patterns**
   - Look for data fetching in `lib/` or `services/`
   - Match error handling patterns

3. **Generate Code**
   - Create data fetching function
   - Add proper typing
   - Include error handling

## Output

Creates:
- `lib/data/{resource}.ts` - Data fetching functions
- Component with data fetching integrated

## Templates

### Server Component Pattern
```tsx
// lib/data/products.ts
import { db } from "@/lib/db"
import { unstable_cache } from "next/cache"

export const getProducts = unstable_cache(
  async (categoryId?: string) => {
    return db.product.findMany({
      where: categoryId ? { categoryId } : undefined,
      include: { category: true },
      orderBy: { createdAt: "desc" },
    })
  },
  ["products"],
  { revalidate: 60, tags: ["products"] }
)

export async function getProduct(id: string) {
  const product = await db.product.findUnique({
    where: { id },
    include: { category: true, reviews: true },
  })

  if (!product) {
    throw new Error("Product not found")
  }

  return product
}
```

### Server Component Usage
```tsx
// app/products/page.tsx
import { getProducts } from "@/lib/data/products"
import { ProductCard } from "@/components/ProductCard"

export default async function ProductsPage() {
  const products = await getProducts()

  return (
    <div className="grid grid-cols-3 gap-4">
      {products.map(product => (
        <ProductCard key={product.id} product={product} />
      ))}
    </div>
  )
}
```

### Parallel Data Fetching
```tsx
export default async function DashboardPage() {
  const [user, stats, notifications] = await Promise.all([
    getUser(),
    getStats(),
    getNotifications(),
  ])

  return (
    <div>
      <UserHeader user={user} />
      <StatsGrid stats={stats} />
      <NotificationList notifications={notifications} />
    </div>
  )
}
```

### Client Component with use()
```tsx
"use client"

import { use } from "react"

interface ProductListProps {
  productsPromise: Promise<Product[]>
}

export function ProductList({ productsPromise }: ProductListProps) {
  const products = use(productsPromise)

  return (
    <ul>
      {products.map(p => <li key={p.id}>{p.name}</li>)}
    </ul>
  )
}
```

### Streaming with Suspense
```tsx
import { Suspense } from "react"
import { ProductList } from "@/components/ProductList"
import { getProducts } from "@/lib/data/products"

export default function Page() {
  const productsPromise = getProducts()

  return (
    <div>
      <h1>Products</h1>
      <Suspense fallback={<ProductsSkeleton />}>
        <ProductList productsPromise={productsPromise} />
      </Suspense>
    </div>
  )
}
```

## Best Practices

- Fetch data in Server Components when possible
- Use unstable_cache for expensive operations
- Implement parallel fetching with Promise.all
- Use Suspense for streaming
- Handle errors with error.tsx boundaries
- Revalidate with tags for precise cache control
