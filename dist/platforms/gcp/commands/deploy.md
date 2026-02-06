---
description: Deploy to GCP Cloud Run
allowed-tools:
  - Bash
  - Read
---

# /deploy - GCP Cloud Run Deployment

Deploy the application to Google Cloud Run.

## Prerequisites

1. `gcloud` CLI authenticated
2. `cloud.yml` or `cloudbuild.yaml` configured
3. Docker image builds successfully

## Commands

```bash
# Option 1: Cloud Build (recommended)
gcloud builds submit

# Option 2: Direct deploy (development)
gcloud run deploy SERVICE_NAME \
  --source . \
  --region us-central1 \
  --allow-unauthenticated
```

## Verification

After deployment:

```bash
# Check service status
gcloud run services describe SERVICE_NAME --region us-central1

# View logs
gcloud run services logs read SERVICE_NAME --region us-central1
```

## Notes

- Always deploy via Cloud Build for production
- Preview deployments use `_DEPLOY_ENV=preview` substitution
- Secrets must exist in Secret Manager before deploy
