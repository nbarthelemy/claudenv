---
name: auth-flow-generator
description: Generate authentication flows with NextAuth.js v5
allowed-tools:
  - Read
  - Write
  - Glob
  - WebFetch
---

# Auth Flow Generator

Generate authentication components and flows with NextAuth.js.

## Triggers

- "create login"
- "add authentication"
- "auth flow"
- "sign in page"
- "protected route"

## Documentation Access

**Research before implementing.** Consult:
- https://authjs.dev - Auth.js v5 documentation
- https://authjs.dev/reference/nextjs - Next.js adapter

## Process

1. **Check Auth Configuration**
   - Verify auth.ts exists
   - Check configured providers

2. **Determine Flow Type**
   - Login page (OAuth + Credentials)
   - Protected route/page
   - Sign out functionality
   - Session display

3. **Generate Components**
   - Create form components
   - Add server actions
   - Set up middleware if needed

## Output

Creates:
- `app/(auth)/login/page.tsx` - Login page
- `components/auth/` - Auth components
- `lib/actions/auth.ts` - Server actions

## Templates

### Login Page
```tsx
import { signIn } from "@/auth"
import { AuthError } from "next-auth"
import { redirect } from "next/navigation"

export default function LoginPage() {
  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="w-full max-w-sm space-y-6">
        <h1 className="text-2xl font-bold text-center">Sign In</h1>

        <form
          action={async (formData) => {
            "use server"
            try {
              await signIn("credentials", formData)
            } catch (error) {
              if (error instanceof AuthError) {
                return redirect(`/login?error=${error.type}`)
              }
              throw error
            }
          }}
          className="space-y-4"
        >
          <input name="email" type="email" placeholder="Email" required />
          <input name="password" type="password" placeholder="Password" required />
          <button type="submit">Sign In</button>
        </form>

        <div className="relative">
          <div className="absolute inset-0 flex items-center">
            <div className="w-full border-t" />
          </div>
          <div className="relative flex justify-center text-sm">
            <span className="bg-white px-2 text-muted-foreground">Or</span>
          </div>
        </div>

        <form action={async () => {
          "use server"
          await signIn("google")
        }}>
          <button type="submit">Continue with Google</button>
        </form>
      </div>
    </div>
  )
}
```

### Protected Layout
```tsx
import { auth } from "@/auth"
import { redirect } from "next/navigation"

export default async function ProtectedLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const session = await auth()

  if (!session) {
    redirect("/login")
  }

  return <>{children}</>
}
```

## Best Practices

- Use server actions for auth mutations
- Implement proper error handling
- Add loading states for better UX
- Use middleware for route protection
- Never expose sensitive data client-side
