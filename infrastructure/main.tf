terraform {
  required_version = ">= 1.6.0"

  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      # The 0.8 series exposes the stable libvirt_domain, libvirt_volume, and
      # libvirt_cloudinit_disk resource model used by this configuration.
      version = "~> 0.9.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

locals {
  ssh_public_key_path  = pathexpand(var.ssh_public_key_path)
  ssh_private_key_path = trimsuffix(local.ssh_public_key_path, ".pub")
  ssh_public_key = var.ssh_public_key != null ? trimspace(var.ssh_public_key) : (
    fileexists(local.ssh_public_key_path) ? trimspace(file(local.ssh_public_key_path)) : ""
  )
}

resource "libvirt_volume" "agent_vm" {
  name   = "${var.name}.qcow2"
  pool   = var.storage_pool
  source = var.ubuntu_image_source
  format = "qcow2"
  size   = var.disk_size_gib * 1024 * 1024 * 1024
}

resource "libvirt_cloudinit_disk" "agent_vm" {
  name = "${var.name}-cloud-init.iso"
  pool = var.storage_pool
  meta_data = yamlencode({
    instance-id    = var.name
    local-hostname = var.name
  })
  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    hostname       = var.name
    ssh_public_key = local.ssh_public_key
  })

  lifecycle {
    precondition {
      condition     = local.ssh_public_key != ""
      error_message = "An SSH public key is required. Set ssh_public_key or provide the file selected by ssh_public_key_path."
    }
  }
}

resource "libvirt_domain" "agent_vm" {
  name       = var.name
  memory     = var.memory_mib
  vcpu       = var.vcpu
  autostart  = true
  qemu_agent = false
  cloudinit  = libvirt_cloudinit_disk.agent_vm.id

  network_interface {
    network_name   = var.network_name
    mac            = var.mac_address
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.agent_vm.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}
