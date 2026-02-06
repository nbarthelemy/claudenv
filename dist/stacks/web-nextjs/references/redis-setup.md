# Redis Setup Guide

Complete setup for Redis with BullMQ in Next.js projects.

## Installation

### macOS (Homebrew)

```bash
# Install Redis
brew install redis

# Start as service (auto-start on boot)
brew services start redis

# Or run manually
redis-server
```

### Verify Installation

```bash
redis-cli ping
# Returns: PONG

redis-cli info server | head -5
```

## Project Setup

### 1. Install Dependencies

```bash
pnpm add bullmq ioredis
pnpm add -D @types/ioredis
```

### 2. Environment Variables

Add to `.env.local`:

```bash
REDIS_URL="redis://localhost:6379"
```

### 3. Connection Configuration

```typescript
// lib/redis.ts
import Redis from 'ioredis'

const getRedisUrl = () => {
  if (process.env.REDIS_URL) {
    return process.env.REDIS_URL
  }
  throw new Error('REDIS_URL is not defined')
}

export const redis = new Redis(getRedisUrl())

// For BullMQ (requires separate instances)
export const connection = {
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT || '6379'),
}
```

### 4. Queue Setup

```typescript
// lib/queue/queues.ts
import { Queue } from 'bullmq'
import { connection } from '../redis'

export const emailQueue = new Queue('email', {
  connection,
  defaultJobOptions: {
    attempts: 3,
    backoff: {
      type: 'exponential',
      delay: 1000,
    },
    removeOnComplete: 100,  // Keep last 100 completed
    removeOnFail: 500,      // Keep last 500 failed
  }
})

export const webhookQueue = new Queue('webhook', { connection })
export const aiQueue = new Queue('ai', { connection })
```

### 5. Worker Setup

```typescript
// lib/queue/workers/email.worker.ts
import { Worker, Job } from 'bullmq'
import { connection } from '../../redis'

interface EmailJobData {
  to: string
  subject: string
  template: string
  data: Record<string, unknown>
}

export const emailWorker = new Worker<EmailJobData>(
  'email',
  async (job: Job<EmailJobData>) => {
    const { to, subject, template, data } = job.data

    // Update progress
    await job.updateProgress(10)

    // Send email
    await sendEmail({ to, subject, template, data })

    await job.updateProgress(100)
    return { sent: true, to }
  },
  {
    connection,
    concurrency: 5,  // Process 5 jobs at once
  }
)

emailWorker.on('completed', (job) => {
  console.log(`Email job ${job.id} completed`)
})

emailWorker.on('failed', (job, err) => {
  console.error(`Email job ${job?.id} failed:`, err)
})
```

### 6. Adding Jobs

```typescript
// In API routes or server actions
import { emailQueue } from '@/lib/queue/queues'

// Add a job
await emailQueue.add('welcome-email', {
  to: user.email,
  subject: 'Welcome!',
  template: 'welcome',
  data: { name: user.name }
})

// Add with delay
await emailQueue.add('reminder', data, {
  delay: 24 * 60 * 60 * 1000  // 24 hours
})

// Add recurring job
await emailQueue.add('daily-digest', data, {
  repeat: {
    pattern: '0 9 * * *'  // 9am daily
  }
})
```

### 7. Worker Initialization

Create an API route to initialize workers (or use a separate process):

```typescript
// app/api/workers/route.ts
import { emailWorker } from '@/lib/queue/workers/email.worker'
import { webhookWorker } from '@/lib/queue/workers/webhook.worker'

// Workers auto-start on import
export async function GET() {
  return Response.json({
    workers: ['email', 'webhook'],
    status: 'running'
  })
}
```

## BullMQ Dashboard (Optional)

```bash
pnpm add -D bull-board @bull-board/api @bull-board/express
```

```typescript
// app/api/queues/route.ts
import { createBullBoard } from '@bull-board/api'
import { BullMQAdapter } from '@bull-board/api/bullMQAdapter'
import { ExpressAdapter } from '@bull-board/express'
import { emailQueue, webhookQueue } from '@/lib/queue/queues'

const serverAdapter = new ExpressAdapter()
serverAdapter.setBasePath('/api/queues')

createBullBoard({
  queues: [
    new BullMQAdapter(emailQueue),
    new BullMQAdapter(webhookQueue),
  ],
  serverAdapter,
})

export const GET = serverAdapter.getRouter()
```

## Troubleshooting

### Redis not running

```bash
# Check status
brew services list | grep redis

# View logs
tail -f /opt/homebrew/var/log/redis.log

# Restart
brew services restart redis
```

### Connection refused

```bash
# Check if Redis is listening
lsof -i :6379

# Test connection
redis-cli -h localhost -p 6379 ping
```

### Memory issues

```bash
# Check memory usage
redis-cli info memory

# Clear all data (development only!)
redis-cli FLUSHALL
```

### Jobs stuck

```typescript
// Clean up stuck jobs
await emailQueue.clean(0, 1000, 'failed')
await emailQueue.clean(0, 1000, 'completed')

// Retry all failed jobs
const failed = await emailQueue.getFailed()
await Promise.all(failed.map(job => job.retry()))
```

## Production Considerations

### Upstash Redis (Recommended for serverless)

```bash
REDIS_URL="rediss://default:xxx@xxx.upstash.io:6379"
```

### Connection pooling

```typescript
// For serverless, use connection pooling
import { Redis } from '@upstash/redis'

export const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL!,
  token: process.env.UPSTASH_REDIS_REST_TOKEN!,
})
```

### Separate worker process

For production, run workers in a separate process:

```json
// package.json
{
  "scripts": {
    "workers": "tsx watch lib/queue/start-workers.ts"
  }
}
```

```typescript
// lib/queue/start-workers.ts
import './workers/email.worker'
import './workers/webhook.worker'
import './workers/ai.worker'

console.log('Workers started')
```
