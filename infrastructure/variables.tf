variable "name" {
  description = "Name of the libvirt domain and cloud-init hostname."
  type        = string
  default     = "agent-vm"
}

variable "storage_pool" {
  description = "Existing libvirt storage pool for the VM disk and cloud-init ISO."
  type        = string
  default     = "default"
}

variable "network_name" {
  description = "Existing libvirt NAT network to attach to."
  type        = string
  default     = "default"
}

variable "mac_address" {
  description = "Stable MAC address for the VM NIC so cloud-init networking survives domain recreation."
  type        = string
  default     = "52:54:00:d6:e8:16"

  validation {
    condition     = can(regex("^(?i:[0-9a-f]{2}:){5}[0-9a-f]{2}$", var.mac_address))
    error_message = "mac_address must be a colon-separated six-byte MAC address."
  }
}

variable "ubuntu_image_source" {
  description = "Ubuntu cloud-image URL or local QCOW2 image path used as the disk base."
  type        = string
  default     = "https://cloud-images.ubuntu.com/releases/server/server/26.04/release/ubuntu-26.04-server-cloudimg-amd64.img"
}

variable "disk_size_gib" {
  description = "Virtual capacity of the root disk in GiB. Existing volumes can only be expanded safely."
  type        = number
  default     = 60

  validation {
    condition     = var.disk_size_gib >= 4 && floor(var.disk_size_gib) == var.disk_size_gib
    error_message = "disk_size_gib must be a whole number of at least 4 GiB."
  }
}

variable "memory_mib" {
  description = "Guest memory in MiB."
  type        = number
  default     = 4096
}

variable "vcpu" {
  description = "Number of virtual CPUs."
  type        = number
  default     = 2
}

variable "ssh_public_key" {
  description = "Optional SSH public key content for the ubuntu user. When unset, ssh_public_key_path is read."
  type        = string
  default     = null
  nullable    = true
}

variable "ssh_public_key_path" {
  description = "Public-key file used when ssh_public_key is unset. The matching private-key path is used in the SSH output."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
