resource "kubernetes_deployment" "myapp-deployment" {
  metadata {
    name = "myapp-deployment"
    labels = {
      App = "myapp"
    }
  }

  spec {
    replicas = 3
    selector {
      match_labels = {
        App = "myapp"
      }
    }

    template {
      metadata {
        labels = {
          App = "myapp"
        }
      }

      spec {
        container {
          name    = "myapp"
          image   = "myapp:latest"
          command = ["./start.sh"]
          env {
            name  = "DATABASE_URL"
            value = "jdbc:postgresql://db:5432/mydb"
          }
          env {
            name  = "LOG_LEVEL"
            value = "info"
          }
		  port {
            container_port = 8080
          }
        }
      }
    }
  }
}
