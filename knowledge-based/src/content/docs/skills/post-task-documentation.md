---
title: Post-task documentation template
description: A Starlight-compatible structure for runbooks, decision notes, and task handoffs.
---

Use this reference after applying the [Documenting](global/documenting/) skill.
Keep the frontmatter, then retain only sections that help the intended reader.

```md
---
title: <clear action or decision>
description: <outcome, audience, and scope in one sentence>
---

## Purpose

<What the reader will understand or be able to do.>

## When to use

<Trigger, exclusions, and intended audience.>

## Prerequisites and scope

<Required access, systems affected, and boundaries.>

## Procedure

1. <Safe, reproducible action.>
2. <Next action and expected result.>

## Validation

<Command, metric, test, or observation that proves completion.>

## Decisions and security considerations

<Trade-offs, caveats, rollback limits, and information that must not be stored.>

## Related links and follow-up

<Durable references, owner, and unresolved work.>
```

For a runbook, retain procedure and validation. For a decision note, emphasize
context, alternatives, decision, and consequences. For a short task handoff,
write only the outcome, verification evidence, next action, and authoritative
links in the issue or task system instead of creating a new global page.
