# resource "kubernetes_namespace" "kube-dashboard" {
#   metadata {
#     name        = "kube-dashboard"
#     annotations = {}
#     labels      = {}
#   }
# }

# resource "helm_release" "kube-dashboard" {
#   name       = "kube-dashboard"

#   repository = "https://kubernetes.github.io/dashboard/"
#   chart      = "kubernetes-dashboard"

#   version = "7.0.0-alpha1"

#   namespace = kubernetes_namespace.kube-dashboard.metadata[0].name

#   set {
#     name  = "nginx.enabled"
#     value = "false"
#   }
#   set {
#     name  = "metrics-server.enabled"
#     value = "false"
#   }
  
#   set {
#     name = "app.ingress.hosts[0]"
#     value = "kube.travigo.app"
#   }
# }