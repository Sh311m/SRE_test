provider "helm" {
    kubernetes {}
}

data "local_file" "grafana_pwd" { #TODO change to k8s secret
    filename = "${path.module}/../private/grafana_admin"
}

resource "helm_release" "prometheus-operator" {
    name = "prometheus-operator-stable"
    chart = "stable/prometheus-operator"
    
    values = [
        "${file("values.yaml")}"
    ]

    set {
        name = "grafana.defaultDashboardsEnabled" 
        value = "false"
    }
    set {
        name = "grafana.adminPassword"
        value = data.local_file.grafana_pwd.content
    }
    set {
        name = "prometheus.service.type"
        value = "NodePort"
    }
    set {
        name = "alertmanager.service.type"
        value = "NodePort"
    }
    set {
        name = "grafana.service.type"
        value = "NodePort"
    }
}
