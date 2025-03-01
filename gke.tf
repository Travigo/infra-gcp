# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "travigo-gke"
  location = var.gcp_zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.primary-subnet.name

  ip_allocation_policy {
    cluster_ipv4_cidr_block = ""
    services_ipv4_cidr_block = ""
  }

  # This enables data-plane v2 which does support network_policy
  datapath_provider = "ADVANCED_DATAPATH"

  min_master_version = "1.29"

  workload_identity_config {
    workload_pool = "${var.gcp_project_id}.svc.id.goog"
  }

  deletion_protection = false
}

# Spot Nodes
resource "google_container_node_pool" "spot_runner_nodes" {
  name       = "spot-runner-node-pool"
  location   = var.gcp_zone
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.gcp_project_id
    }

    spot  = true

    machine_type = "e2-custom-8-18432"
    disk_size_gb = 32

    tags         = ["gke-node", "${var.gcp_project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# Database Nodes
resource "google_container_node_pool" "spot_database_nodes" {
  name       = "spot-database-node-pool"
  location   = var.gcp_zone
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.gcp_project_id
    }

    spot  = true

    machine_type = "e2-custom-8-28672" # 8 CPU, 20GB RAM e2-custom-8-18432  maybe e2-custom-10-20480
    disk_size_gb = 32

    tags         = ["gke-node", "${var.gcp_project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }

    taint {
      effect = "NO_SCHEDULE"
      key = "DATABASE"
      value = "true"
    }
  }
}

# Realtime Nodes
# resource "google_container_node_pool" "spot_realtime_database_nodes" {
#   name       = "spot-realtime-database-node-pool"
#   location   = var.gcp_zone
#   cluster    = google_container_cluster.primary.name
#   node_count = 2

#   node_config {
#     oauth_scopes = [
#       "https://www.googleapis.com/auth/logging.write",
#       "https://www.googleapis.com/auth/monitoring",
#     ]

#     labels = {
#       env = var.gcp_project_id
#     }

#     spot  = true

#     machine_type = "e2-custom-4-8192"
#     disk_size_gb = 32

#     tags         = ["gke-node", "${var.gcp_project_id}-gke"]
#     metadata = {
#       disable-legacy-endpoints = "true"
#     }

#     taint {
#       effect = "NO_SCHEDULE"
#       key = "DATABASE-REALTIME"
#       value = "true"
#     }
#   }
# }

# Batch Burst Nodes
resource "google_container_node_pool" "large_batch_burst_nodes" {
  name       = "large-batch-burst"
  location   = var.gcp_zone
  cluster    = google_container_cluster.primary.name

  autoscaling {
    min_node_count = 0
    max_node_count = 1
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.gcp_project_id
    }

    machine_type = "e2-custom-8-65536"
    disk_size_gb = 32

    tags         = ["gke-node", "${var.gcp_project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }

    taint {
      effect = "NO_SCHEDULE"
      key = "BATCH_BURST"
      value = "true"
    }
  }
}

# Batch Burst Nodes
resource "google_container_node_pool" "small_batch_burst_nodes" {
  name       = "small-batch-burst"
  location   = var.gcp_zone
  cluster    = google_container_cluster.primary.name

  autoscaling {
    min_node_count = 0
    max_node_count = 1
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.gcp_project_id
    }

    machine_type = "e2-custom-2-8192"
    disk_size_gb = 32

    tags         = ["gke-node", "${var.gcp_project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }

    taint {
      effect = "NO_SCHEDULE"
      key = "SMALL_BATCH_BURST"
      value = "true"
    }
  }
}
