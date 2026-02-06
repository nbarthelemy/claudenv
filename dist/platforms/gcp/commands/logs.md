---
description: View GCP Cloud Run logs
allowed-tools:
  - Bash
---

# /logs - GCP Cloud Run Logs

View logs from Cloud Run services.

## Commands

```bash
# Stream recent logs
gcloud run services logs read SERVICE_NAME --region us-central1 --limit 100

# Tail logs (live)
gcloud run services logs tail SERVICE_NAME --region us-central1

# Filter by severity
gcloud logging read "resource.type=cloud_run_revision AND severity>=ERROR" --limit 50
```

## Notes

- Logs are automatically sent to Cloud Logging
- Use `--format=json` for structured output
- Filter by time with `--freshness` flag
