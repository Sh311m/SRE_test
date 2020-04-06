provider "kubernetes" {}

data "local_file" "news_api_key" { #TODO change to k8s secret 
  filename = "${path.module}/../private/.news_api_key"
}

resource "kubernetes_service" "web_app" {
  metadata {
    name = var.wapp_image_name
    labels = {
      app = var.wapp_image_name
    }
  }
  spec {
    selector = {
      app = "${kubernetes_deployment.web_app_dep.metadata.0.labels.app}"
    }
    port {
      port        = 80
      target_port = 3000
    }

    type = "NodePort"
  }
}

resource "kubernetes_deployment" "web_app_dep" {
  metadata {
    name = var.wapp_image_name
    labels = {
      app = var.wapp_image_name
    }
  }

  spec {
    replicas = 1
    selector {
        match_labels = {
            app = var.wapp_image_name
        }
    }
    template {
        metadata {
            labels = {
                app = var.wapp_image_name
            }
        }

        spec {
            container {
              image = "${var.wapp_gcr}/${var.wapp_image_name}:latest"
              name  = var.wapp_image_name
              image_pull_policy = "Always"
              port {
                container_port = 3000
              }
              env {
                name = "API_KEY"
                value = data.local_file.news_api_key.content
              }
              resources {
                  limits {
                    cpu    = "0.5"
                    memory = "512Mi"
                  }
                  requests {
                    cpu    = "250m"
                    memory = "50Mi"
                  }
              }
           }
        }
    }
  }
}
