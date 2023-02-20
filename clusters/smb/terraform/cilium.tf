# https://registry.terraform.io/providers/hashicorp/helm/latest/docs
# We want to use the rendered template for cluster.inlineManifest
# https://www.talos.dev/v1.3/reference/configuration/#clusterconfig
# https://www.talos.dev/v1.3/reference/configuration/#clusterinlinemanifest
# We want to install the cilium chart with the correct values for talos
# https://www.talos.dev/v1.3/kubernetes-guides/network/deploying-cilium/#method-1-helm-install
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/data-sources/template
data "helm_template" "cilium" {
  name             = "cilium"
  repository       = "https://helm.cilium.io/"
  chart            = "cilium"
  version          = "1.13.0"
  description      = "Cilium Bootstrapped via terraform helm_templates injected into talos cluster.inlineManifests"
  create_namespace = true
  skip_tests       = false
  atomic           = true
  values = [
    <<-EOT
    ipam:
      mode: kubernetes
    kubeProxyReplacement: strict
    k8sServiceHost: 192.168.1.222
    k8sServicePort: 6443
    EOT
  ]
}
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/data-sources/template#attributes-reference
# data.helm_template.cilium.manifest
