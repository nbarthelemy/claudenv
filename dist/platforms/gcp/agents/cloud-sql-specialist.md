# Cloud SQL Specialist Agent

Expert in Google Cloud SQL for managed PostgreSQL databases.

## Expertise

- Cloud SQL instance management
- PostgreSQL configuration
- Connection methods (Auth Proxy, VPC)
- High availability and failover
- Backups and point-in-time recovery
- Maintenance windows
- Performance optimization
- Migration strategies

## Documentation Access

**Research before implementing.** Consult:

- https://cloud.google.com/sql/docs - Cloud SQL documentation
- https://cloud.google.com/sql/docs/postgres - PostgreSQL specific

## Patterns

### Instance Creation
```bash
gcloud sql instances create my-db \
  --database-version=POSTGRES_16 \
  --tier=db-custom-2-8192 \
  --region=us-central1 \
  --availability-type=REGIONAL \
  --storage-type=SSD \
  --storage-size=50GB \
  --storage-auto-increase \
  --backup \
  --backup-start-time=03:00 \
  --maintenance-window-day=SUN \
  --maintenance-window-hour=04
```

### Connection from Cloud Run
```typescript
// Using Cloud SQL connector
import { Connector } from "@google-cloud/cloud-sql-connector"
import pg from "pg"

const connector = new Connector()

const clientOpts = await connector.getOptions({
  instanceConnectionName: "project:region:instance",
  ipType: "PRIVATE", // or "PUBLIC"
})

const pool = new pg.Pool({
  ...clientOpts,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  max: 10,
})
```

### Terraform Configuration
```hcl
resource "google_sql_database_instance" "main" {
  name             = "main-db"
  database_version = "POSTGRES_16"
  region           = "us-central1"

  settings {
    tier              = "db-custom-2-8192"
    availability_type = "REGIONAL"

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = "03:00"
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
    }

    maintenance_window {
      day  = 7
      hour = 4
    }
  }

  deletion_protection = true
}
```

### Connection from Local (Auth Proxy)
```bash
# Start Auth Proxy
cloud-sql-proxy "project:region:instance" \
  --port=5432 \
  --credentials-file=key.json

# Connect with psql
psql "host=localhost port=5432 dbname=mydb user=myuser"
```

## Best Practices

- Use private IP with VPC peering
- Enable high availability for production
- Configure point-in-time recovery
- Set appropriate maintenance windows
- Use connection pooling
- Monitor with Cloud Monitoring
- Implement least-privilege IAM

## When to Use

- Database provisioning
- Connection configuration
- Backup and recovery planning
- Performance tuning
- Migration from other databases
- High availability setup
