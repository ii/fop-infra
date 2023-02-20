resource "talos_machine_secrets" "machine_secrets" {}

# resource "talos_machine_configuration_apply" "cp_config_apply" {
#   for_each              = var.node_data.controlplanes
#   endpoint              = each.key
#   node                  = each.key
#   talos_config          = talos_client_configuration.talosconfig.talos_config
#   machine_configuration = talos_machine_configuration_controlplane.machineconfig_cp.machine_config
#   config_patches = [
#     <<-EOT
#     machine:
#        network:
#          hostname: ${each.value.hostname == null ? format("%s-cp-%s", var.cluster_name, index(keys(var.node_data.workers), each.key)) : each.value.hostname}
#          interfaces:
#            - interface: eth0
#              dhcp: true
#              vip:
#                ip: 192.168.1.222
#        install:
#          diskSelector:
#            busPath: ${each.value.install_disk_bus_path}
#     EOT
#   ]
# }

# resource "talos_machine_configuration_apply" "worker_config_apply" {
#   talos_config          = talos_client_configuration.talosconfig.talos_config
#   machine_configuration = talos_machine_configuration_worker.machineconfig_worker.machine_config
#   for_each              = var.node_data.workers
#   endpoint              = each.key
#   node                  = each.key
#   config_patches = [
#     <<-EOT
#     machine:
#        network:
#          hostname: ${each.value.hostname == null ? format("%s-cp-%s", var.cluster_name, index(keys(var.node_data.workers), each.key)) : each.value.hostname}
#          interfaces:
#            - interface: eth0
#              dhcp: true
#              vip:
#                ip: 192.168.1.222
#        install:
#          diskSelector:
#            busPath: ${each.value.install_disk_bus_path}
#     EOT
#   ]
# }


resource "talos_machine_configuration_controlplane" "machineconfig_cp" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
  docs_enabled     = false
  examples_enabled = false
  config_patches = [
    <<-EOT
    machine:
       network:
         hostname: smb2
         interfaces:
           - interface: eth0
             dhcp: true
             vip:
               ip: 192.168.1.222
       install:
         diskSelector:
           busPath: /pci0000:00/0000:00:1f.2/ata1/host0/target0:0:0/0:0:0:0/
    EOT
    ,
    <<-EOT
    machine:
       certSANs:
         - k8s.hachbach.nz
         - smb1
         - smb2
         - smb3
         - smb4
         - smb5
         - smb6
         - smb7
         - smb8
         - 192.168.1.222
         - 192.168.1.161
         - 192.168.1.162
         - 192.168.1.163
         - 192.168.1.164
         - 192.168.1.165
         - 192.168.1.166
         - 192.168.1.167
         - 192.168.1.168
       kubelet:
         extraMounts:
         - destination: /var/local-path-provisioner
           type: bind
           source: /var/local-path-provisioner
           options:
             - bind
             - rshared
             - rw
    cluster:
       allowSchedulingOnMasters: true
       # The rest of this is for cilium
       #  https://www.talos.dev/v1.3/kubernetes-guides/network/deploying-cilium/
       proxy:
         disabled: true
       network:
         cni:
           name: none
       apiServer:
         certSANs:
           - k8s.hackbach.nz
           - smb1
           - smb2
           - smb3
           - 192.168.1.222
           - 192.168.1.161
           - 192.168.1.162
           - 192.168.1.163
       # Going to try and add this via patch so we can inline the rendered cilium helm template
       inlineManifests:
         - name: cilium
    EOT
    ,
    yamlencode([
      {
        "op" : "replace",
        "path" : "/cluster/inlineManifests/0/contents",
        "value" : data.helm_template.cilium.manifest
      }
    ])
  ]
}

# resource "talos_machine_configuration_worker" "machineconfig_worker" {
#   cluster_name     = var.cluster_name
#   cluster_endpoint = var.cluster_endpoint
#   machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
#   docs_enabled     = false
#   examples_enabled = false
# }

resource "talos_client_configuration" "talosconfig" {
  cluster_name    = var.cluster_name
  machine_secrets = talos_machine_secrets.machine_secrets.machine_secrets
  endpoints       = [for k, v in var.node_data.controlplanes : k]
}

# resource "talos_machine_bootstrap" "bootstrap" {
#   talos_config = talos_client_configuration.talosconfig.talos_config
#   endpoint     = [for k, v in var.node_data.controlplanes : k][0]
#   node         = [for k, v in var.node_data.controlplanes : k][0]
# }

# resource "talos_cluster_kubeconfig" "kubeconfig" {
#   talos_config = talos_client_configuration.talosconfig.talos_config
#   endpoint     = [for k, v in var.node_data.controlplanes : k][0]
#   node         = [for k, v in var.node_data.controlplanes : k][0]
# }

# notes
#
# yamlencode({
#   machine : {
#     network : {
#       hostname : each.value.hostname == null ? format("%s-cp-%s", var.cluster_name, index(keys(var.node_data.workers), each.key)) : each.value.hostname
#     }
#     install : {
#       disk : each.value.install_disk
#     }
#   }
# }),
# yamlencode([
#   {
#     "op" : "replace",
#     "path" : "/machine/network/hostname",
#     "value" : each.value.hostname == null ? format(
#       "%s-cp-%s", var.cluster_name,
#     index(keys(var.node_data.workers), each.key)) : each.value.hostname
#   },
#   {
#     "op" : "replace",
#     "path" : "/cluster/allowSchedulingOnMasters",
#     "value" : true
#   },
#   {
#     "op" : "replace",
#     "path" : "/machine/kubelet/extraMounts",
#     "value" : [
#       {
#         "type" : "bind",
#         "source" : "/var/local-path-provisioner",
#         "destination" : "/var/local-path-provisioner",
#         "options" : ["bind", "rshared", "rw"]
#       }
#     ]
#   }
# ])
# templatefile("${path.module}/templates/patch.yaml.tmpl", {
#   hostname     = each.value.hostname == null ? format("%s-cp-%s", var.cluster_name, index(keys(var.node_data.workers), each.key)) : each.value.hostname
#   install_disk = each.value.install_disk
# }),
# file("${path.module}/patches/local-path-provisioner.yaml"),
# file("${path.module}/patches/schedule-on-master.yaml"),
#file("${path.module}/patches/patch.json"),
