# GCP Platform Documentation References

All agents and skills have **permission to research before asking**.

## Official Documentation

### Compute
| Service | Documentation URL | Notes |
|---------|-------------------|-------|
| Cloud Run | https://cloud.google.com/run/docs | Serverless containers |
| Cloud Build | https://cloud.google.com/build/docs | CI/CD |
| Artifact Registry | https://cloud.google.com/artifact-registry/docs | Container registry |

### Database
| Service | Documentation URL | Notes |
|---------|-------------------|-------|
| Cloud SQL | https://cloud.google.com/sql/docs | Managed PostgreSQL |
| Cloud Spanner | https://cloud.google.com/spanner/docs | Global database |
| Firestore | https://cloud.google.com/firestore/docs | NoSQL |

### Storage
| Service | Documentation URL | Notes |
|---------|-------------------|-------|
| Cloud Storage | https://cloud.google.com/storage/docs | Object storage |

### AI/ML
| Service | Documentation URL | Notes |
|---------|-------------------|-------|
| Vertex AI | https://cloud.google.com/vertex-ai/docs | ML platform |
| Gemini | https://cloud.google.com/vertex-ai/generative-ai/docs | Generative AI |

### Security
| Service | Documentation URL | Notes |
|---------|-------------------|-------|
| Secret Manager | https://cloud.google.com/secret-manager/docs | Secrets |
| IAM | https://cloud.google.com/iam/docs | Access control |
| VPC | https://cloud.google.com/vpc/docs | Networking |

### Infrastructure
| Technology | Documentation URL | Notes |
|------------|-------------------|-------|
| Terraform | https://registry.terraform.io/providers/hashicorp/google/latest/docs | IaC |
| gcloud CLI | https://cloud.google.com/sdk/gcloud/reference | CLI reference |

## Key References

### Cloud Run Patterns
- CPU allocation: Always-on vs request-based
- Concurrency: 80 for web apps, 1 for background jobs
- VPC Connector: For Cloud SQL private IP

### Cloud SQL Connection
- Use Cloud SQL Connector library
- Private IP preferred over public
- Connection pooling essential

### Terraform Patterns
- Use modules for reusability
- Remote state in GCS
- Workspaces for environments
