variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint for the Talos cluster"
  type        = string
}

variable "node_data" {
  description = "A map of node data"
  type = object({
    controlplanes = map(object({
      hostname              = optional(string)
      install_disk_bus_path = string
    }))
    workers = map(object({
      hostname              = optional(string)
      install_disk_bus_path = string
    }))
  })
  default = {
    controlplanes = {
      "192.168.1.162" = {
        hostname              = "smb2"
        install_disk_bus_path = "/pci0000:00/0000:00:1f.2/ata1/host0/target0:0:0/0:0:0:0/"
      }
    }
    workers = {
    }
  }
}
