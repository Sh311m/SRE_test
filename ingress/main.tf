provider "kubernetes" {}

resource "kubernetes_ingress" "ingress-nginx-http" {
    metadata {
        name = "wak-ingress"
        annotations = {
            "nginx.ingress.kubernetes.io/use-regex" = "true"
            "kubernetes.io/ingress.class" = "nginx"
            "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
        }
    }

    spec {
        rule {
          host = "waaaaak.dev"
          http {
            path {
              path = "/"
              backend {
                service_name = "go-hw"
                service_port = 80
              }
            }
          }
        }

        rule {
          host = "gr.waaaaak.dev"
          http {
            path {
              path = "/"
              backend {
                service_name = "prometheus-operator-stable-grafana"
                service_port = 80
              }
            }
          }
        }

        rule {
          host = "prom.waaaaak.dev"
          http {
            path {
              path = "/"
              backend {
                service_name = "prometheus-operator-stable-prometheus"
                service_port = 9090
              }
            }
          }
        }

        rule {
          host = "alm.waaaaak.dev"
          http {
            path {
              path = "/"
              backend {
                service_name = "prometheus-operator-stable-alertmanager"
                service_port = 9093
              }
            }
          }
        }

        tls {
            hosts = [
                "waaaaak.dev",
                "gr.waaaaak.dev",
                "prom.waaaaak.dev",
                "alm.waaaaak.dev"
            ]
            secret_name = "tls-echo"
        }
    }
}


