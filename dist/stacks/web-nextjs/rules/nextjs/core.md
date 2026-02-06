# Next.js Stack Rules

> Core conventions and patterns for Next.js 16 App Router projects.

## Research Before Implementing

All agents have **unfettered documentation access**. Before implementing any feature:
1. Consult official documentation at the URLs in `references/README.md`
2. Verify patterns match our framework versions
3. Check for breaking changes in recent updates

## Framework Versions

| Package | Version | Notes |
|---------|---------|-------|
| Next.js | 16.x | App Router only |
| React | 19.x | With React Compiler |
| TypeScript | 5.7.x | Strict mode required |
| Drizzle ORM | 0.38.x | |
| Tailwind CSS | 4.x | CSS-first config |
| NextAuth.js | 5.x (Auth.js) | |
| Node.js | 22.x | LTS |

## Project Structure

```
apps/web/
├── drizzle/                   # Database migrations
└── src/
    ├── app/                   # App Router pages
    │   ├── (auth)/            # Auth routes (login, register)
    │   ├── (marketing)/       # Public pages (landing, pricing)
    │   ├── (app)/             # Authenticated app routes
    │   └── api/               # API routes
    ├── components/            # React components
    │   └── ui/                # shadcn/ui components
    └── lib/                   # Business logic
        ├── db.ts              # Drizzle client
        ├── auth.ts            # Auth config
        └── api-utils.ts       # API helpers
```

---

## Mandatory Rules

### 1. Server Components First

**ALWAYS prefer Server Components** unless you need:
- Event handlers (onClick, onChange, etc.)
- Browser APIs (window, localStorage)
- React hooks (useState, useEffect, etc.)

### 2. Data Fetching in Server Components

**NEVER fetch data in Client Components** if it can be done in Server Components. Fetch in Server Component and pass data to Client Components as props.

### 3. Use Server Actions for Mutations

**ALWAYS use Server Actions** for data mutations. Never use API routes for mutations that can be server actions.

### 4. Type Everything

**NO `any` types allowed.** Use proper TypeScript throughout.

### 5. Validate All External Input

**ALWAYS validate** user input, API payloads, and URL params with Zod.

### 6. Handle Errors Properly

**ALWAYS implement proper error handling** with error boundaries and try/catch.

### 7. Use Proper Caching

**Understand and use Next.js caching** appropriately with cache tags and revalidation.

### 8. Optimize Images

**ALWAYS use next/image** for images.

---

## Automatic Behaviors

| Trigger | Action |
|---------|--------|
| File changes in `src/lib/db/schema.ts` | Run `pnpm db:generate` |
| New route created | Add to relevant route group `(auth)`, `(app)`, or `(marketing)` |
| API route created | Use `withErrorHandling` + `successResponse` pattern |
| Database operations | Use transactions for multi-model operations |

## Error Recovery

| Error Type | Resolution |
|------------|------------|
| Drizzle errors | Check schema, run `db:generate`, check migrations |
| Type errors | Check @siquora/* package versions match |
| Build errors | Check Next.js version matches canonical (15.x) |
| Hydration errors | Check for client/server mismatch, use `'use client'` |

## Validation Commands

```bash
pnpm typecheck    # TypeScript
pnpm lint         # ESLint
pnpm test         # Tests
pnpm build        # Build verification
```

---

## Reference Documentation

For detailed code patterns, examples, and best practices:
- Read `.claude/rules/nextjs/reference.md` when implementing complex features
- Read `.claude/references/README.md` for official documentation URLs
