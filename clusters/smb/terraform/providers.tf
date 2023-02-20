terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.1.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
  }
}
provider "talos" {
  # Configuration options
}
provider "helm" {
  # Configuration options
}
