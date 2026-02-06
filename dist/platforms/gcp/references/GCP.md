# GCP Infrastructure Reference

> Standard GCP setup for {org} projects.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Cloud Run                                 │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│   │  project-1  │  │  project-2  │  │  project-3  │  ...       │
│   └─────────────┘  └─────────────┘  └─────────────┘            │
├─────────────────────────────────────────────────────────────────┤
│  Cloud SQL (PostgreSQL)  │  Cloud Storage  │  Secret Manager   │
└─────────────────────────────────────────────────────────────────┘
```

---

## cloud.yml Schema

Every GCP project must have a `cloud.yml`:

```yaml
# cloud.yml
project: {org}-{app}
region: us-central1

services:
  web:
    source: apps/web
    runtime: nodejs22
    memory: 512Mi
    cpu: 1
    minInstances: 0
    maxInstances: 10
    env:
      DATABASE_URL: ${secrets.DATABASE_URL}
      NEXTAUTH_SECRET: ${secrets.NEXTAUTH_SECRET}

database:
  instance: {org}-{app}-db
  tier: db-f1-micro
  databases:
    - name: main

storage:
  buckets:
    - name: {org}-{app}-assets
      location: US
      uniformAccess: true

secrets:
  - DATABASE_URL
  - NEXTAUTH_SECRET
  - GOOGLE_CLIENT_ID
  - GOOGLE_CLIENT_SECRET
  - STRIPE_SECRET_KEY
```

---

## Deployment

### First Time Setup

```bash
# 1. Create GCP project
gcloud projects create {org}-{app}
gcloud config set project {org}-{app}

# 2. Enable APIs
gcloud services enable \
  run.googleapis.com \
  cloudbuild.googleapis.com \
  sqladmin.googleapis.com \
  secretmanager.googleapis.com

# 3. Deploy infrastructure
cd cloud && terraform init && terraform apply

# 4. Build and deploy
gcloud builds submit
```

### Subsequent Deployments

```bash
# Just rebuild and deploy
gcloud builds submit
```

---

## Secret Management

All secrets stored in GCP Secret Manager:

```bash
# Add a secret
echo -n "value" | gcloud secrets create SECRET_NAME --data-file=-

# Update a secret
echo -n "new-value" | gcloud secrets versions add SECRET_NAME --data-file=-

# List secrets
gcloud secrets list

# Access in Cloud Run
gcloud run services update web \
  --set-secrets=DATABASE_URL=DATABASE_URL:latest
```

**Standard secrets:**
| Secret | Purpose |
|--------|---------|
| `DATABASE_URL` | PostgreSQL connection string |
| `NEXTAUTH_SECRET` | NextAuth.js session encryption |
| `GOOGLE_CLIENT_ID` | OAuth client ID |
| `GOOGLE_CLIENT_SECRET` | OAuth client secret |
| `STRIPE_SECRET_KEY` | Stripe API key |
| `STRIPE_WEBHOOK_SECRET` | Webhook signature verification |

---

## Database

### Cloud SQL Setup

| Setting | Dev | Production |
|---------|-----|------------|
| Instance | `{org}-{app}-db` | `{org}-{app}-db` |
| Version | PostgreSQL 15 | PostgreSQL 15 |
| Tier | `db-f1-micro` | `db-custom-2-4096` |
| Connection | Cloud SQL Proxy | Cloud SQL Proxy |

### Migrations

```bash
# Generate migration
pnpm --filter @{org}/{app} db:migrate:dev --name description

# Apply to production (automatic in Cloud Build)
# Or manually:
pnpm --filter @{org}/{app} db:migrate:deploy
```

### Connection String Format

```
postgresql://USER:PASSWORD@/DATABASE?host=/cloudsql/PROJECT:REGION:INSTANCE
```

---

## Storage

### Cloud Storage Buckets

```bash
# Create bucket
gsutil mb -l US gs://{org}-{app}-assets

# Set uniform access
gsutil uniformbucketlevelaccess set on gs://{org}-{app}-assets

# CORS for uploads
gsutil cors set cors.json gs://{org}-{app}-assets
```

### Signed URLs

```typescript
import { Storage } from "@google-cloud/storage";

const storage = new Storage();
const bucket = storage.bucket("{org}-{app}-assets");

// Generate upload URL
const [url] = await bucket.file("path/file.jpg").getSignedUrl({
  action: "write",
  expires: Date.now() + 15 * 60 * 1000, // 15 minutes
  contentType: "image/jpeg",
});
```

---

## Domains

| Environment | Pattern | Example |
|-------------|---------|---------|
| Production | `{app}{domain_suffix}` | `cmdstack.ai` |
| Staging | `staging.{app}{domain_suffix}` | `staging.cmdstack.ai` |

### Domain Mapping

```bash
# Map custom domain
gcloud run domain-mappings create \
  --service web \
  --domain {app}{domain_suffix} \
  --region us-central1

# Verify ownership (add DNS TXT record)
gcloud domains verify {app}{domain_suffix}
```

### SSL Certificates

Cloud Run provisions SSL automatically for mapped domains.

---

## Monitoring

### Logs

```bash
# View recent logs
gcloud logging read "resource.type=cloud_run_revision" --limit 100

# Stream logs
gcloud alpha run services logs tail web

# Filter by severity
gcloud logging read "severity>=ERROR" --limit 50
```

### Alerts

Set up in Cloud Monitoring:
- Error rate > 1%
- P95 latency > 2s
- Instance count spike

### Error Reporting

Automatic via Cloud Run. View in Console:
`https://console.cloud.google.com/errors?project={org}-{app}`

---

## Cost Optimization

| Resource | Dev Setting | Notes |
|----------|-------------|-------|
| Cloud Run | `minInstances: 0` | Scale to zero |
| Cloud SQL | `db-f1-micro` | Smallest tier |
| Storage | `STANDARD` class | Default |

**Estimated monthly cost (dev):** ~$15-30
