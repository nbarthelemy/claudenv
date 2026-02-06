# GCP Platform Rules

> Infrastructure decisions and patterns for Google Cloud Platform.

## Documentation Access

**Research before implementing.** All agents and skills have permission to consult:

| Service | Documentation URL |
|---------|-------------------|
| Cloud Run | https://cloud.google.com/run/docs |
| Cloud SQL | https://cloud.google.com/sql/docs |
| Cloud Build | https://cloud.google.com/build/docs |
| Cloud Storage | https://cloud.google.com/storage/docs |
| Secret Manager | https://cloud.google.com/secret-manager/docs |
| Vertex AI | https://cloud.google.com/vertex-ai/docs |
| Artifact Registry | https://cloud.google.com/artifact-registry/docs |
| IAM | https://cloud.google.com/iam/docs |
| Terraform GCP | https://registry.terraform.io/providers/hashicorp/google/latest/docs |

## Mandatory Rules

1. **Infrastructure as Code** - All infrastructure MUST be defined in Terraform or `cloud.yml`. Never configure manually in GCP Console.

2. **Private Networking** - Cloud SQL MUST use private IP with VPC peering. Public IPs are forbidden for databases.

3. **Secret Manager Only** - All secrets MUST be stored in GCP Secret Manager. Never use environment variables for secrets in production.

4. **Connection Pooling** - All database connections MUST use connection pooling. Use Cloud SQL Connector or Auth Proxy.

5. **Least Privilege IAM** - Service accounts MUST have only required permissions. Never use Project Editor or Owner roles for services.

6. **Regional Consistency** - All resources MUST be in the same region (us-central1 default) unless globally distributed.

7. **Enable High Availability** - Production databases MUST use `REGIONAL` availability type with point-in-time recovery enabled.

8. **Container Scanning** - All container images MUST be scanned for vulnerabilities before deployment via Artifact Registry.

## Infrastructure Decisions

These decisions are binding for all GCP-hosted projects.

### Hosting: Cloud Run

- **Decision:** All projects use GCP Cloud Run
- **Rationale:** Unified billing, consistent deployment, GCP AI services integration
- **No exceptions** for Vercel, AWS, or other hosting

### Database: Cloud SQL PostgreSQL

- **Decision:** PostgreSQL via Cloud SQL
- **ORM:** Drizzle ORM for all stacks
- **Rationale:** Managed service, automatic backups, scales with Cloud Run
- **No exceptions** for alternative databases in production

### Storage: Google Cloud Storage

- **Decision:** All file storage uses GCS via `@siquora/storage`
- **Rationale:** Native GCP integration, CDN-ready, unified access patterns

### AI Services

- **Primary:** Google Vertex AI (Gemini, Imagen, Veo)
- **Secondary:** Anthropic Claude (via `@siquora/ai`)
- **Rule:** Use Vertex AI for image/video generation, Claude for complex reasoning

### Secrets

- **Decision:** GCP Secret Manager for all production secrets
- **Local:** `.env.local` (never committed)
- **Rule:** Reference secrets in `cloud.yml`, never hardcode

### DNS & SSL

- **DNS:** Cloudflare for all domains
- **SSL:** Automatic via Cloud Run (production), Caddy (local)
- **Pattern:** `{project}.ai` (prod), `{project}.dev` (local)

## Infrastructure as Code

**Key Principle:** Everything must be defined in `cloud.yml`.

```yaml
# cloud.yml - Single source of truth
name: {project}
region: us-central1

services:
  web:
    source: ./apps/web
    memory: 512Mi
    cpu: 1
    minInstances: 0
    maxInstances: 10
    env:
      DATABASE_URL: ${secret:DATABASE_URL}
      NEXTAUTH_SECRET: ${secret:NEXTAUTH_SECRET}

database:
  type: postgres
  tier: db-f1-micro

storage:
  bucket: {project}-assets
  cors: true
```

## Deployment

```bash
# Deploy to production
gcloud builds submit

# Preview deployment
gcloud builds submit --substitutions=_DEPLOY_ENV=preview
```

## Domain Mapping

| Environment | Pattern | Example |
|-------------|---------|---------|
| Production | `{project}.ai` | `cmdstack.ai` |
| Staging | `staging.{project}.ai` | `staging.cmdstack.ai` |
| Local | `{project}.dev` | `cmdstack.dev` |

## Error Recovery

| Error Type | Resolution |
|------------|------------|
| Cloud Run deploy fails | Check `cloud.yml`, verify secrets exist |
| Database connection fails | Check Cloud SQL proxy, verify DATABASE_URL |
| Secret not found | Add secret via `gcloud secrets create` |
| Domain not resolving | Check Cloudflare DNS, verify domain mapping |

## Automatic Behaviors

| Trigger | Action |
|---------|--------|
| Adding environment variable | Add to `cloud.yml` env section |
| New secret needed | Create in Secret Manager, reference in cloud.yml |
| Storage needed | Use `@siquora/storage`, configure bucket in cloud.yml |

## Never Do

- Manually configure in GCP Console (use cloud.yml)
- Hardcode secrets in code
- Use different regions across services
- Deploy without cloud.yml changes committed
