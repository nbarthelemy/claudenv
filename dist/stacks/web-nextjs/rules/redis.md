# Redis Rules

> Full setup: `.claude/references/redis-setup.md`

## Use Cases

- **BullMQ** - Background job processing (emails, webhooks, AI tasks)
- **Caching** - API response caching, session storage
- **Rate limiting** - API rate limits, abuse prevention

## BullMQ Pattern

```typescript
// lib/queue/index.ts
import { Queue, Worker } from 'bullmq'

const connection = { host: 'localhost', port: 6379 }

export const emailQueue = new Queue('email', { connection })

// Worker in separate process or API route
new Worker('email', async (job) => {
  await sendEmail(job.data)
}, { connection })
```

## Environment

```bash
REDIS_URL="redis://localhost:6379"
```

## Local Development

```bash
brew install redis
brew services start redis
redis-cli ping  # Should return PONG
```

## Best Practices

- Use separate queues per job type (email, webhooks, ai)
- Set appropriate job timeouts and retry limits
- Use job progress for long-running tasks
- Clean up completed jobs to prevent memory growth
