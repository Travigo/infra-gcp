terraform {
  backend "gcs" { 
    bucket  = "travigo-infra"
    prefix  = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.1"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "4.48.0"
    }
  }

  required_version = ">= 1.5"
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "cloudflare" {
  email      = var.cloudflare_email
  api_key    = var.cloudflare_token
}

data "google_client_config" "current" {}

provider "kubernetes" {
  host     = "https://${google_container_cluster.primary.endpoint}"
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
}

provider "helm" {
  kubernetes {
    host     = "https://${google_container_cluster.primary.endpoint}"
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
    token                  = data.google_client_config.current.access_token
  }
}
