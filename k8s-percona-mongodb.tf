# resource "helm_release" "percona-mongodb-operator" {
#   name       = "percona-mongodb-operator"

#   repository = "https://percona.github.io/percona-helm-charts/"
#   chart      = "psmdb-operator"

#   version = "1.17.0"
# }

# resource "random_password" "percona-mongodb-database-password" {
#   length           = 64
#   special          = false
# }

# resource "kubernetes_secret" "percona-mongodb-database-password" {
#   metadata {
#     name      = "percona-mongodb-database-password"
#   }

#   data = {
#     "password" = random_password.percona-mongodb-database-password.result
#   }

#   type = "kubernetes.io/secret"

#   lifecycle {
#     ignore_changes = [ metadata ]
#   }
# }

# resource "helm_release" "percona-mongodb-db" {
#   name       = "percona-mongodb-db"

#   repository = "https://percona.github.io/percona-helm-charts/"
#   chart      = "psmdb-db"

#   version = "1.17.0"

#   values = [<<EOT
#   allowUnsafeConfigurations: true
#   unsafeFlags:
#     tls: true
#     replsetSize: true
#     mongosSize: true
#     terminationGracePeriod: true
#     backupIfUnhealthy: true
#   tls:
#     mode: disabled
#   users:
#   - name: travigo
#     db: travigo
#     passwordSecretRef: 
#       name: percona-mongodb-database-password
#       key: password
#     roles:
#       - name: clusterAdmin
#         db: admin
#       - name: userAdminAnyDatabase
#         db: admin
#       - name: dbAdminAnyDatabase
#         db: admin
#       - name: readWrite
#         db: admin
#       - name: readWrite
#         db: travigo
#   replsets:
#     rs0:
#       name: rs0
#       size: 2
#       resources:
#         limits:
#           cpu: "4"
#           memory: "10G"
#         requests:
#           cpu: "0"
#           memory: "0"
#       configuration: |
#         security:
#           enableEncryption: false
#       storage:
#         engine: inMemory
#         inMemory:
#           engineConfig:
#             inMemorySizeGB: 5
#             statisticsLogDelaySecs: 0
#       tolerations:
#         - effect: "NoSchedule"
#           key: "DATABASE-REALTIME"
#           operator: "Equal"
#           value: "true"
#   sharding:
#     enabled: false
#   backup:
#     enabled: false
#   EOT
#   ]
# }
