resource "kubernetes_namespace" "kube-dashboard" {
  metadata {
    name        = "kube-dashboard"
    annotations = {}
    labels      = {}
  }
}

resource "helm_release" "kube-dashboard" {
  name       = "kube-dashboard"

  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "kubernetes-dashboard"

  version = "7.5.0"

  namespace = kubernetes_namespace.kube-dashboard.metadata[0].name

  set {
    name  = "nginx.enabled"
    value = "false"
  }
  set {
    name  = "metrics-server.enabled"
    value = "false"
  }
  
  set {
    name = "app.ingress.enabled"
    value = true
  }
  set {
    name = "app.ingress.ingressClassName"
    value = "nginx"
  }
  set {
    name = "app.ingress.hosts[0]"
    value = "kube.travigo.app"
  }

  set {
    name = "app.ingress.tls.enabled"
    value = false
  }

  set {
    name = "kong.admin.addresses[0]"
    value = "127.0.0.1"
  }
}

resource "kubernetes_service_account" "dahsboard_admin_user" {
  metadata {
    name = "admin-user"
    namespace = kubernetes_namespace.kube-dashboard.metadata[0].name
  }
}

resource "kubernetes_secret" "dashboard_admin_user" {
  metadata {
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.dahsboard_admin_user.metadata[0].name
    }

    name      = "dashboard-admin-user"
    namespace = kubernetes_namespace.kube-dashboard.metadata[0].name
  }

  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

resource "kubernetes_cluster_role_binding" "dashboard_admin_user" {
  metadata {
    name = "admin-user"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.dahsboard_admin_user.metadata[0].name
    namespace = kubernetes_namespace.kube-dashboard.metadata[0].name
  }
}
