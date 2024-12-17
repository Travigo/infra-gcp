module "travigo-assistant-workload-identity" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version = "35.0.0"

  name       = "travigo-assistant"
  namespace  = "default"
  project_id = var.gcp_project_id
  roles      = ["roles/aiplatform.user"]
}