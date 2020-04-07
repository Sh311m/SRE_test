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
          host = var.domain 
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
          host = "gr.${var.domain}"
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
          host = "prom.${var.domain}"
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
          host = "alm.${var.domain}"
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
                "${var.domain}",
                "gr.${var.domain}",
                "prom.${var.domain}",
                "alm.${var.domain}"
            ]
            secret_name = "tls-echo"
        }
    }
}


