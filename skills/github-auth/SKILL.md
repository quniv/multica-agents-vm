---
title: GitHub App authentication
description: Operate and troubleshoot short-lived GitHub App authentication for Multica agents.
---

Multica agent runtimes use a GitHub App installation instead of a long-lived personal access token. A fresh, short-lived installation token is minted on demand for every authenticated GitHub CLI invocation and whenever Git requests HTTPS credentials.

This design provides:

- automatic recovery from installation-token expiry;
- repository access limited by the GitHub App installation and permissions;
- no token persisted in Git configuration, credential files, or Git remote URLs;
- one authentication path shared by GitHub CLI and HTTPS Git operations;
- compatibility with tools that inspect either `GH_TOKEN` or `GITHUB_TOKEN`.

## Installed components

### `/home/ubuntu/.local/bin/gh-app-token`

The shared token generator:

1. enables strict Bash handling with `set -euo pipefail` and `umask 077`;
2. reads configuration from `${GITHUB_APP_CONFIG}` or, by default, `/home/ubuntu/.config/github-app/multica-coffee.env`;
3. validates that the App ID, installation ID, and private-key path are configured;
4. validates that the private key is readable;
5. runs `/usr/bin/gh token generate --token-only` using the configured GitHub App installation.

The token is written only to standard output for consumption by a wrapper. Do not invoke this command in a context that logs standard output.

### `/home/ubuntu/.local/bin/gh-app`

The authenticated GitHub CLI wrapper:

1. calls `gh-app-token` to mint a fresh token;
2. fails if token generation returns an empty value;
3. supplies the token to `/usr/bin/gh` through both `GH_TOKEN` and `GITHUB_TOKEN` for the lifetime of that process only;
4. forwards all CLI arguments unchanged.

Use `gh-app` instead of invoking authenticated `/usr/bin/gh` commands directly:

```bash
gh-app api /installation/repositories
gh-app repo view OWNER/REPOSITORY
gh-app pr list --repo OWNER/REPOSITORY
```

Never enable shell tracing (`set -x`) around these commands because environment values could be exposed by diagnostic tooling.

### `/home/ubuntu/.local/bin/git-credential-github-app`

The Git credential helper for GitHub HTTPS operations:

1. responds only to Git's `get` credential operation;
2. parses the requested protocol and host from Git's credential protocol;
3. returns no credentials unless the request is exactly for `https://github.com`;
4. mints a fresh installation token through `gh-app-token`;
5. returns `x-access-token` as the username and the short-lived token as the password.

The global Git configuration scopes the helper to GitHub only:

```ini
[credential "https://github.com"]
    helper = /home/ubuntu/.local/bin/git-credential-github-app
```

Normal HTTPS commands therefore obtain a fresh credential automatically:

```bash
git clone https://github.com/OWNER/REPOSITORY.git
git fetch origin
git push origin BRANCH
```

Do not place a token in a remote URL.

### `/home/ubuntu/.config/github-app/multica-coffee.env`

The runtime configuration identifies the GitHub App installation and private-key path:

```bash
GITHUB_APP_ID=<github-app-id>
GITHUB_APP_INSTALLATION_ID=<installation-id>
GITHUB_APP_PRIVATE_KEY_FILE=/home/ubuntu/.github-app/<private-key-file>.pem
```

The private key is the sensitive credential. Never commit it, copy it into documentation, attach it to an issue, or print it in logs.

## File ownership and permissions

The deployed files must be owned by `ubuntu:ubuntu` with these modes:

| Path | Mode | Purpose |
| --- | ---: | --- |
| `/home/ubuntu/.local/bin/gh-app-token` | `0700` | Shared token generator |
| `/home/ubuntu/.local/bin/gh-app` | `0700` | Authenticated `gh` wrapper |
| `/home/ubuntu/.local/bin/git-credential-github-app` | `0700` | Git credential helper |
| `/home/ubuntu/.config/github-app/multica-coffee.env` | `0600` | App installation configuration |
| `/home/ubuntu/.github-app/<private-key-file>.pem` | `0600` | GitHub App private key |

The GitHub CLI version at implementation time was `2.96.0`. Revalidate commands when upgrading GitHub CLI.

## Token lifecycle

GitHub App installation tokens are short-lived and are not manually reset. Each wrapper invocation mints a new token immediately before use:

- `gh-app ...` mints once for the GitHub CLI subprocess;
- the Git credential helper mints whenever Git asks for credentials.

No cron-based refresh or permanently exported `GH_TOKEN` is required. A running command that receives HTTP 401 should mint a new token and retry once. Repeated 401 responses indicate configuration, installation, clock, key, or permission problems rather than ordinary expiry.

## Verification procedure

Run checks without displaying the token:

```bash
# Confirm required files, ownership, and restrictive modes.
stat -c '%a %U:%G %n' \
  /home/ubuntu/.local/bin/gh-app-token \
  /home/ubuntu/.local/bin/gh-app \
  /home/ubuntu/.local/bin/git-credential-github-app \
  /home/ubuntu/.config/github-app/multica-coffee.env \
  /home/ubuntu/.github-app/<private-key-file>.pem

# Confirm the scoped Git credential helper.
git config --global --get-all credential.https://github.com.helper

# Confirm authenticated GitHub App access.
gh-app api /installation/repositories --jq '.total_count'

# Confirm repository metadata and API access.
gh-app api repos/OWNER/REPOSITORY --include
gh-app api repos/OWNER/REPOSITORY/contents --include
gh-app api repos/OWNER/REPOSITORY/pulls --include
gh-app api repos/OWNER/REPOSITORY/issues --include
gh-app api repos/OWNER/REPOSITORY/actions/runs --include
gh-app api repos/OWNER/REPOSITORY/check-runs --include \
  -H 'Accept: application/vnd.github+json'

# Confirm HTTPS Git authentication without changing the repository.
git ls-remote https://github.com/OWNER/PRIVATE-REPOSITORY.git HEAD
```

Expected results are restrictive file modes, a GitHub-only credential helper, successful repository enumeration, HTTP 200 from permitted APIs, and a successful read-only `git ls-remote`.

Do not test write access against a production branch. If a write test is required, use a disposable branch and clean it up after verification.

## Verified deployment state

At installation time:

- fresh token generation succeeded without printing the token;
- the GitHub App installation could access 17 repositories, including private repositories;
- authenticated Metadata, Contents, Pull Requests, Issues, Actions workflow/run, and Check Runs requests returned HTTP 200;
- HTTPS Git authentication succeeded against the private `quniv/aws-eks-helm-deploy` repository;
- GitHub's token response reported write access for Actions, Checks, Contents, Deployments, Environments, Issues, Packages, Pages, Pull Requests, repository hooks, secret-scanning alerts, secrets, security events, commit statuses, vulnerability alerts, and Workflows; admin access for repository projects; and read access for repository administration and metadata.

These are historical verification results, not a permanent guarantee. GitHub App settings and repository installations can change, so re-query effective permissions during audits.

## Security requirements

- Store the private key outside repositories and documentation systems.
- Keep the private key and config at mode `0600`; keep executable wrappers at `0700`.
- Never print, log, cache, or persist generated tokens.
- Never add generated tokens to shell profiles, Kubernetes manifests, Git remotes, issue comments, or CI variables with broad visibility.
- Limit the GitHub App installation to required repositories.
- Apply least privilege to GitHub App permissions and review them periodically.
- Rotate the GitHub App private key if disclosure is suspected; update the configured key path and remove the old key from GitHub after verification.
- Ensure backups and node snapshots protect or exclude the private key according to the organization's secret-management policy.

## Troubleshooting

### `GitHub App config is not readable`

Confirm the config exists, is owned by the runtime user, has mode `0600`, and that `GITHUB_APP_CONFIG` is unset or points to the intended file.

### A required variable is missing

Verify that the config defines `GITHUB_APP_ID`, `GITHUB_APP_INSTALLATION_ID`, and `GITHUB_APP_PRIVATE_KEY_FILE`. Do not paste the file contents into public logs.

### `GitHub App private key is not readable`

Confirm the configured path, file ownership, and mode. The runtime user needs read access. Do not relax the key to world-readable permissions.

### GitHub API returns 401

Mint a new token by rerunning the wrapper. If 401 persists, verify the App ID, installation ID, private key, GitHub App installation status, key validity, and system clock.

### GitHub API returns 403

The token is valid but lacks permission, the repository is not included in the installation, or a GitHub policy or rate limit blocks the request. Review the response headers and App installation permissions without exposing credentials.

### Git works for public repositories but not private repositories

Confirm the remote uses `https://github.com/...`, the repository belongs to the App installation, and the scoped credential helper is present in global Git configuration.

### Git repeatedly prompts for credentials

Inspect the helper configuration and confirm the helper is executable. Avoid adding competing broad credential helpers that store the short-lived token.

## Maintenance and rollback

To update the GitHub App installation, change the config file while preserving mode `0600`, then run the verification procedure.

To rotate the private key, deploy the new key at mode `0600`, update the config path, verify access, and only then revoke or delete the old GitHub key.

To remove this integration:

1. remove the scoped `credential.https://github.com.helper` Git configuration;
2. remove the three wrapper/helper scripts;
3. remove the config file;
4. securely remove the private-key file if it is not used elsewhere;
5. revoke the key or uninstall the GitHub App installation in GitHub;
6. verify that no Git process or runtime environment retains a generated token.
