---
title: Documenting
description: Capture durable post-task knowledge safely and publish it at the right scope.
---

## Purpose

Use this skill at the end of a task when the work produced durable knowledge
that will prevent repeated investigation, reduce operational risk, or let a
future agent act without relying on task-chat context.

Typical candidates include non-obvious architecture, operational procedures,
decisions and trade-offs, integration or configuration guidance, incident
learnings, and known limitations or follow-up work.

Do not create documentation for routine, self-evident changes that have no
reusable insight.

## Decide the scope

Publish a note as **global** only when all of the following are true:

- It is useful across agents, projects, or repositories.
- It is stable enough to prescribe rather than merely record as an experiment.
- It contains no secrets, personal data, private endpoints, tenant details, or
  other access-sensitive information.
- An owner or reviewer can maintain it through the repository pull-request
  process.

Keep the knowledge local when it is repository-specific, temporary,
speculative, sensitive, or relevant only to the task that just completed.

| Scope | Preferred destination | Example |
| --- | --- | --- |
| Global | `knowledge-based/src/content/docs/skills/global/` | A reusable incident-documentation workflow |
| Project | The project's documented knowledge-base area or project overview | A team-wide deployment decision |
| Repository | The repository's `docs/`, runbook, ADR, or `README` location | A service's migration procedure |
| Task | The issue, task handoff, or a short linked note | A one-off investigation result |

Link local material from global documentation only when the reference is durable
and access-safe. Never use a global page to disclose a protected local URL or
environment-specific topology.

## Write the document

Start every Starlight page with frontmatter containing at least `title` and
`description`:

```md
---
title: Rotate an integration credential
description: Safely rotate a service credential without exposing its value.
---
```

Use the following sections when they add information; do not add empty headings
just to satisfy a template:

1. **Purpose / outcome** — what a reader can accomplish.
2. **When to use (and when not to)** — trigger and exclusions.
3. **Prerequisites and scope** — permissions, affected systems, and boundaries.
4. **Procedure or guidance** — ordered, reproducible actions.
5. **Validation / completion evidence** — observable proof of success.
6. **Decisions, caveats, and security considerations** — trade-offs, risks, and
   what must not be recorded.
7. **Related links and follow-up work** — durable references and unresolved work.

Write for a reader who cannot see the original task chat. Prefer commands with
safe placeholders and expected results. Do not include credential values,
tokens, private IPs, customer data, or unredacted logs.

## Examples

### Runbook

An operations runbook should state the trigger, prerequisites, reversible
steps, validation command or signal, rollback boundary, and escalation owner.
For example, a daemon-restart note should identify the maintenance window,
show how to verify service health after the restart, and warn that active work
will be interrupted.

### Architecture or decision note

Record the context, decision, alternatives considered, trade-offs, and the
consequences for operators. Keep environment-specific identifiers in the
repository or project that owns them; a global page may describe the decision
method without naming private infrastructure.

### Short task handoff

For work that does not justify a durable page, leave a concise issue handoff:
the completed outcome, the remaining blocker or next action, links to the
authoritative code or documentation, and how to verify it. Avoid copying raw
logs; preserve only the conclusion and evidence needed by the next owner.

## Completion checklist

- Is the knowledge non-obvious and likely to be reused?
- Is its global, project, repository, or task scope explicit?
- Does the page include the required frontmatter and only relevant sections?
- Can a new agent follow it without the original conversation?
- Has sensitive data been removed or replaced with safe placeholders?
- Do links resolve and does the documentation site build successfully?
- Has the global publication been reviewed through the repository pull request?

## Publication and maintenance

English is the current documentation language, matching the existing knowledge
base. `title` and `description` are the required metadata. Add other metadata
only once the knowledge base adopts and documents a site-wide schema; do not
invent inconsistent owner, tag, or review-date fields per page.

Review global skill changes through a repository pull request. The change
author should identify the appropriate owner or reviewer in that pull request;
approval is the publication gate. Update or retire guidance when its procedure,
security assumptions, or supported tooling changes.

## Related reference

Use the [post-task documentation template](../post-task-documentation/) when a
new durable page is warranted.
