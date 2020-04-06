provider "helm" {
    kubernetes {}
}

provider "kubernetes" {}

data "helm_repository" "nginx-stable" {
    name = "nginx-stable"
    url  = "https://helm.nginx.com/stable"
}

data "helm_repository" "jetstack" {
    name = "jetstack"
    url = "https://charts.jetstack.io"
}

resource "kubernetes_namespace" "cert-manager" {
    metadata {
        annotations = {
            name = "cert-manager"
        }

        labels = {
            mylabel = "cert-manager"
        }

        name = "cert-manager"
    }
}
resource "helm_release" "nginx-ingress" {
    name  = "nginx-ingress-r3"
    repository = data.helm_repository.nginx-stable.metadata[0].name
    chart = "nginx-stable/nginx-ingress"
}

resource "helm_release" "cert-manager" {
    name  = "nginx-ingress-r3"
    repository = data.helm_repository.jetstack.metadata[0].name
    namespace = "${kubernetes_namespace.cert-manager.metadata[0].name}"
    version = "v0.14.1"
    chart = "jetstack/cert-manager"
}


