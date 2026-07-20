---
title: Runtime Daemon Operations
description: Operate the Multica runtime daemon as a systemd service on agent-vm.
---

## Purpose

The Multica runtime daemon runs as a system-level `systemd` service on
`agent-vm` and starts automatically during VM boot. It claims Multica agent
tasks and launches the configured local agent providers.

The service runs as the existing unprivileged `ubuntu` account. Its home and
working directory are `/home/ubuntu`, which lets it read
`/home/ubuntu/.multica/config.json` and maintain state in
`/home/ubuntu/.multica`. The Multica executable is pinned to
`/usr/local/bin/multica`.

Implementation reference: QUN-15, *Run the Multica runtime daemon as a
system-level service on `agent-vm`*.

## Systemd unit

Install this unit as `/etc/systemd/system/multica-daemon.service`:

```ini
[Unit]
Description=Multica agent runtime daemon
Documentation=file:/usr/local/share/doc/multica-daemon/OPERATIONS.md
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=ubuntu
Group=ubuntu
WorkingDirectory=/home/ubuntu
Environment=HOME=/home/ubuntu
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ExecStart=/usr/local/bin/multica daemon start --foreground

# Restart and failure notification policies are intentionally out of scope.
Restart=no

[Install]
WantedBy=multi-user.target
```

## Installation or update

Keep the unit and this operations note in version-controlled configuration.
From the directory containing `systemd/`:

```sh
sudo install -o root -g root -m 0644 systemd/multica-daemon.service \
  /etc/systemd/system/multica-daemon.service
sudo install -d -o root -g root -m 0755 /usr/local/share/doc/multica-daemon
sudo install -o root -g root -m 0644 systemd/OPERATIONS.md \
  /usr/local/share/doc/multica-daemon/OPERATIONS.md
sudo systemctl daemon-reload
sudo systemctl enable multica-daemon.service
```

Before the initial service start, stop a daemon launched manually under the
same profile to prevent duplicate daemon processes:

```sh
multica daemon stop
sudo systemctl start multica-daemon.service
```

## Routine operations

```sh
# Start
sudo systemctl start multica-daemon.service

# Stop
sudo systemctl stop multica-daemon.service

# Restart
sudo systemctl restart multica-daemon.service

# Inspect current service state
sudo systemctl status multica-daemon.service

# Inspect recent logs
sudo journalctl -u multica-daemon.service -n 100 --no-pager

# Follow logs
sudo journalctl -u multica-daemon.service -f

# Inspect daemon-level health
multica daemon status
```

## Post-reboot validation

After a planned reboot, verify that no interactive login or manual daemon
start was required:

```sh
sudo systemctl is-enabled multica-daemon.service
sudo systemctl is-active multica-daemon.service
sudo systemctl status multica-daemon.service --no-pager
sudo journalctl -u multica-daemon.service -b --no-pager
multica daemon status
multica runtime list --output json
```

Expected results:

- The service is `enabled` and `active`.
- The main process is `/usr/local/bin/multica daemon start --foreground`,
  running as `ubuntu`.
- The current-boot journal shows a successful systemd start with no
  authentication or configuration errors.
- `multica daemon status` reports the daemon running.
- Configured runtimes report online with fresh heartbeats.

## Manual lifecycle validation

Run this from a separate SSH session, not from an agent task hosted by the
daemon:

```sh
sudo systemctl stop multica-daemon.service
sudo systemctl is-active multica-daemon.service
sudo systemctl start multica-daemon.service
sudo systemctl is-active multica-daemon.service
multica daemon status
```

Stopping or restarting the service terminates agent tasks running beneath its
systemd cgroup. Schedule a maintenance window and confirm that no important
task is active first.

## Security and reliability boundaries

- The daemon runs as non-root `ubuntu`; systemd only supervises the process.
- The authentication/configuration file remains
  `/home/ubuntu/.multica/config.json`. It must be owned by `ubuntu` with mode
  `0600`. Do not copy its token into the unit file or this documentation.
- The unit deliberately uses `Restart=no`. Automatic restart after failure and
  failure alerting were excluded from QUN-15.
- Add a bounded restart policy and an `OnFailure=` notification handler only in
  a separate reliability change after the monitoring destination and escalation
  owner are confirmed.

## Troubleshooting

```sh
# Validate unit syntax
sudo systemd-analyze verify /etc/systemd/system/multica-daemon.service

# Show the effective unit
sudo systemctl cat multica-daemon.service

# Show key runtime properties
sudo systemctl show multica-daemon.service \
  -p User -p Group -p ExecStart -p WorkingDirectory \
  -p After -p Wants -p Restart -p UnitFileState

# Inspect errors from the current boot
sudo journalctl -u multica-daemon.service -b -p warning --no-pager
```

If the service is active but runtimes are offline, inspect the journal for
authentication, network, or provider startup errors. Verify the ownership and
mode of `/home/ubuntu/.multica/config.json` without printing its token, then
confirm network availability and daemon heartbeats before changing the unit.
