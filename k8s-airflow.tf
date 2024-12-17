resource "kubernetes_namespace" "airflow" {
  metadata {
    name        = "airflow"
    annotations = {}
    labels      = {}
  }
}

resource "helm_release" "airflow" {
  name       = "airflow"

  repository = "https://airflow.apache.org"
  chart      = "airflow"

  version = "1.15.0"

  namespace = kubernetes_namespace.airflow.metadata[0].name

  values = [
  <<-EOF
    webserverSecretKey: notsosecrettravigo

    createUserJob:
      useHelmHooks: false
      applyCustomEnv: false
    migrateDatabaseJob:
      useHelmHooks: false
      applyCustomEnv: false

    ingress:
      web:
        enabled: true
        annotations:
          kubernetes.io/ingress.class: nginx
        hosts:
        - name: airflow.travigo.app

    dags:
      persistence:
        enabled: true
        size: 0.5Gi
      gitSync:
        enabled: true
        repo: https://github.com/travigo/travigo.git
        branch: airflow-test
        subPath: "airflow/dags"
        period: 30s
  EOF
  ] 
}