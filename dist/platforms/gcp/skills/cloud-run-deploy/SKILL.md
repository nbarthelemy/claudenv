---
name: cloud-run-deploy
description: Generate Cloud Run deployment configurations and CI/CD pipelines
allowed-tools:
  - Read
  - Write
  - Glob
  - WebFetch
---

# Cloud Run Deploy Generator

Generate Cloud Run service configurations and deployment pipelines.

## Triggers

- "deploy to cloud run"
- "cloud run config"
- "create cloudbuild"
- "ci/cd pipeline"

## Documentation Access

**Research before implementing.** Consult:
- https://cloud.google.com/run/docs - Cloud Run docs
- https://cloud.google.com/build/docs - Cloud Build docs

## Process

1. **Analyze Application**
   - Check Dockerfile exists
   - Determine resource requirements
   - Identify environment variables

2. **Generate Configs**
   - Create service.yaml
   - Create cloudbuild.yaml
   - Set up secrets

3. **Test Locally**
   - Validate Docker build
   - Test with Cloud Run emulator

## Output

Creates:
- `Dockerfile` (if missing)
- `service.yaml` - Cloud Run config
- `cloudbuild.yaml` - CI/CD pipeline

## Templates

### Dockerfile
```dockerfile
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

EXPOSE 8080
CMD ["node", "dist/index.js"]
```

### Cloud Build
```yaml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - 'gcr.io/$PROJECT_ID/${_SERVICE_NAME}:$COMMIT_SHA'
      - '.'

  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - 'gcr.io/$PROJECT_ID/${_SERVICE_NAME}:$COMMIT_SHA'

  - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
    entrypoint: gcloud
    args:
      - 'run'
      - 'deploy'
      - '${_SERVICE_NAME}'
      - '--image=gcr.io/$PROJECT_ID/${_SERVICE_NAME}:$COMMIT_SHA'
      - '--region=${_REGION}'
      - '--platform=managed'

substitutions:
  _SERVICE_NAME: my-service
  _REGION: us-central1

images:
  - 'gcr.io/$PROJECT_ID/${_SERVICE_NAME}:$COMMIT_SHA'
```

## Best Practices

- Use multi-stage Docker builds
- Pin base image versions
- Set resource limits
- Use Cloud Secret Manager
- Enable container scanning
