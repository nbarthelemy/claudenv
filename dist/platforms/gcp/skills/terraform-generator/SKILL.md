---
name: terraform-generator
description: Generate Terraform configurations for GCP infrastructure
allowed-tools:
  - Read
  - Write
  - Glob
  - WebFetch
---

# Terraform Generator

Generate Terraform configurations for GCP infrastructure.

## Triggers

- "create terraform"
- "infrastructure as code"
- "iac"
- "terraform config"

## Documentation Access

**Research before implementing.** Consult:
- https://registry.terraform.io/providers/hashicorp/google/latest/docs - GCP Provider
- https://cloud.google.com/docs/terraform - Terraform on GCP

## Process

1. **Identify Resources**
   - List required GCP services
   - Determine dependencies

2. **Generate Modules**
   - Create modular structure
   - Define variables and outputs

3. **Set Up State**
   - Configure remote state in GCS
   - Set up workspaces if needed

## Output

Creates:
- `terraform/main.tf` - Main configuration
- `terraform/variables.tf` - Input variables
- `terraform/outputs.tf` - Output values
- `terraform/backend.tf` - State configuration

## Templates

### Main Configuration
```hcl
# terraform/main.tf
terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Cloud Run Service
resource "google_cloud_run_v2_service" "app" {
  name     = var.service_name
  location = var.region

  template {
    containers {
      image = var.image

      resources {
        limits = {
          memory = "512Mi"
          cpu    = "1"
        }
      }

      env {
        name  = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_url.secret_id
            version = "latest"
          }
        }
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 10
    }

    vpc_access {
      connector = google_vpc_access_connector.connector.id
      egress    = "PRIVATE_RANGES_ONLY"
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}

# Cloud SQL
resource "google_sql_database_instance" "db" {
  name             = "${var.service_name}-db"
  database_version = "POSTGRES_16"
  region           = var.region

  settings {
    tier              = "db-custom-2-8192"
    availability_type = "REGIONAL"

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
    }
  }

  deletion_protection = true
}
```

### Variables
```hcl
# terraform/variables.tf
variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "service_name" {
  description = "Name of the Cloud Run service"
  type        = string
}

variable "image" {
  description = "Container image to deploy"
  type        = string
}
```

### Backend
```hcl
# terraform/backend.tf
terraform {
  backend "gcs" {
    bucket = "terraform-state-PROJECT_ID"
    prefix = "terraform/state"
  }
}
```

## Best Practices

- Use modules for reusable components
- Store state in GCS with versioning
- Use workspaces for environments
- Implement least-privilege IAM
- Tag all resources consistently
