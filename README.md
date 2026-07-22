# Terraform VM

Terraform configuration for an Ubuntu 26.04 LTS VM on KVM/libvirt.

## Defaults

| Setting | Value |
| --- | --- |
| Name | `agent-vm` |
| CPU / memory | 2 vCPU / 4 GiB |
| Disk | 60 GiB sparse QCOW2 |
| Network | `default` libvirt NAT |
| User | `ubuntu` |
| SSH key | `~/.ssh/id_rsa.pub` |
| Autostart | Enabled |

SSH is key-only, root login is disabled, and `ubuntu` has passwordless sudo.
See [`infrastructure/variables.tf`](infrastructure/variables.tf) to override
defaults.

## Requirements

- Terraform 1.6 or newer.
- KVM/libvirt with access to `qemu:///system`.
- Existing libvirt pool and NAT network named `default`.
- An SSH public key at `~/.ssh/id_rsa.pub` or an override through
  `ssh_public_key_path` or `ssh_public_key`.

## Deploy

```zsh
terraform -chdir=infrastructure init
terraform -chdir=infrastructure fmt -check
terraform -chdir=infrastructure validate
terraform -chdir=infrastructure plan
terraform -chdir=infrastructure apply
```

Connect using the generated command:

```zsh
terraform -chdir=infrastructure output -raw ssh_command
```

## SSH alias

Get the assigned address with
`terraform -chdir=infrastructure output -raw ipv4_address`, then add:

```sshconfig
Host agent-vm
    HostName <guest-ip>
    User ubuntu
    IdentityFile ~/.ssh/id_rsa
    IdentitiesOnly yes
    PreferredAuthentications publickey
    PasswordAuthentication no
    HostKeyAlias agent-vm
```

Connect with `ssh agent-vm`.

## Verify

```zsh
ssh agent-vm '. /etc/os-release; echo "$PRETTY_NAME"'
ssh agent-vm 'nproc; free -h; lsblk; df -hT /'
ssh agent-vm 'sudo -n id -u'
ssh agent-vm 'ping -c 3 1.1.1.1'
ssh agent-vm 'curl --fail --head https://ubuntu.com/'
terraform -chdir=infrastructure plan
```

## Important notes

- Terraform state and variable files are ignored because rendered cloud-init
  contains the SSH public key and infrastructure metadata.
- The pinned libvirt provider may replace an existing disk when its configured
  size changes. Review `terraform -chdir=infrastructure plan` before applying a
  resize.
- The QCOW2 disk is sparse; host storage grows as guest data is written.
- `terraform -chdir=infrastructure destroy` permanently removes the VM, disk,
  and cloud-init ISO.

Run Gitleaks before pushing:

```zsh
gitleaks dir . --no-banner --redact
gitleaks git . --no-banner --redact
```
