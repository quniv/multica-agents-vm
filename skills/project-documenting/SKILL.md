---
name: project-documenting
description: Create and update concise, factual project documentation only inside the repository's agent-docs/ directory. Use when asked to write, rewrite, organize, search, or maintain project docs, setup guides, tutorials, how-to guides, runbooks, references, or architecture explanations. Initialize a missing agent-docs/ from the bundled template only after asking permission. Always read agent-docs/index.md first, store new pages in sequentially numbered folder/index.md paths, and keep parent indexes and statuses synchronized. Never edit README.md, AGENTS.md, source comments, or documentation outside agent-docs/.
---

# Project Documenting

Maintain clear project documentation without allowing documentation work to
spread across the repository.

## Establish the boundary

1. Resolve the repository root with `git rev-parse --show-toplevel`. If this
   fails, ask the user which directory is the repository root.
2. Record the initial working-tree status so unrelated changes remain distinct.
3. Set the only writable documentation root to `<repo-root>/agent-docs/`.
4. Resolve the bundled scaffold relative to this skill at
   `_templates/agent-docs/` and verify that it contains `index.md`.
5. Inspect the target with `ls -la`. If `agent-docs/` does not exist, ask the
   user for explicit permission to initialize it from the bundled template. Do
   not create a directory or write a file while waiting.
6. After approval, confirm the target is still absent, then copy the complete
   template tree to `<repo-root>/agent-docs/`. Never merge the template into or
   overwrite an existing directory. If initialization fails, report any partial
   target and stop; do not delete or replace it automatically.
7. Resolve the documentation root and every intended target before editing.
   Refuse traversal or symlinks that resolve outside `agent-docs/`.
8. Never modify a root `README.md`, `AGENTS.md`, `CLAUDE.md`, `CHANGELOG`, source
   comment, generated documentation, or another documentation directory. Offer
   an equivalent page inside `agent-docs/` when a request falls outside scope.

## Navigate through indexes

1. Read `agent-docs/index.md` before opening other documentation or searching
   broadly. Treat it as the entry point and documentation map.
2. Follow its links through each relevant parent `index.md` until reaching the
   requested topic. Use repository search only when the index path is missing,
   stale, or insufficient.
3. Before creating or updating a child page, read its parent `index.md` and
   follow the documented naming, required fields, table columns, and status
   vocabulary.
4. If an existing `agent-docs/` has no root `index.md`, create a concise one from
   the current directory structure before making the requested documentation
   change.

## Ground the content

1. Read applicable repository instructions and the files that prove the
   requested behavior: manifests, configuration, implementation, tests, current
   documentation, and history when needed.
2. Treat repository evidence as the source of truth for project facts. Use
   current primary documentation for external tools, libraries, APIs, or
   services whose behavior may have changed.
3. Verify commands, paths, keys, versions, defaults, and prerequisites. Never
   invent deployment URLs, support claims, architecture, compatibility, or
   operational status.
4. Distinguish declared configuration from verified runtime behavior and state
   what was not tested.
5. Exclude credentials, secrets, private keys, rendered state, tokens, and
   sensitive local values.

## Follow the folder format

- Store every documentation topic as `<topic>/index.md`. Do not create loose
  topic files such as `<topic>.md`.
- Keep `agent-docs/index.md` as the root index. Each section and nested topic
  also uses its own `index.md`.
- For a new topic, create its folder and `index.md`, then add a concise entry to
  the parent index and every ancestor index whose routing or summary changes.
- When a page changes, review and synchronize its entry in the parent index and
  affected ancestor indexes. Update titles, links, summaries, and statuses when
  needed; do not add timestamps or meaningless churn merely to touch an index.
- Preserve the bundled product, technical, and team hierarchy unless the user
  explicitly requests a structural change.

### Create a numbered topic

1. Read the destination's parent `index.md` to determine its code prefix,
   required fields, status vocabulary, and table columns.
2. Inspect both sibling directory names and codes already recorded in the parent
   index. Find the highest number for the required prefix, add one, and format it
   as three digits. Start at `001` when no entries exist. Count legacy
   `<prefix>-NNN` entries so their codes are never reused.
3. Convert the topic name to a short lowercase kebab-case slug. Create
   `<prefix>-NNN_<slug>/index.md`; the underscore separates the code from the
   descriptive slug. For example, a first user-authentication feature is
   `product/feat/feat-001_user-authentication/index.md`.
4. Recheck that neither the code nor target directory exists before writing. Do
   not overwrite, renumber, or reuse an existing entry to resolve a collision.
5. Put the same code, description, and other index metadata in the new page. If
   the parent defines a Status field, use the requested allowed status or
   default to `in progress` when none was provided. Ask before using a status
   outside the parent's vocabulary.
6. Add one parent-index row that links to the new `index.md` and matches the new
   page's metadata exactly, including its status. Keep rows in ascending code
   order.

The bundled formats use these paths:

| Section | New topic path |
| --- | --- |
| Features | `product/feat/feat-NNN_<feature-name>/index.md` |
| MVPs | `product/mvp/mvp-NNN_<mvp-name>/index.md` |
| Architecture | `technical/architecture/arch-NNN_<topic-name>/index.md` |
| Operations | `technical/operation/ops-NNN_<procedure-name>/index.md` |
| Git | `technical/git/git-NNN_<topic-name>/index.md` |
| Team | `team/member-NNN_<member-name>/index.md` |

Choose the page type that matches the reader's need:

- Tutorial for guided learning.
- How-to guide for a specific goal.
- Reference for precise lookup.
- Explanation for concepts, tradeoffs, and rationale.

## Write clearly

- Lead with what the reader needs to know or do.
- Use direct language, active voice, second person, and sentence-case headings.
- Prefer one precise sentence over several vague sentences.
- Keep paragraphs short and each section focused on one concern.
- Remove filler, repetition, obvious commentary, and text that restates a
  heading or the preceding sentence.
- Use numbered lists for sequences and bullets for non-sequential information.
- Put commands beside their steps in language-tagged code fences.
- Use descriptive relative links to other repository files.
- Omit welcomes, marketing copy, decorative badges, redundant summaries, empty
  sections, repeated warnings, and tables that do not improve lookup.
- Be concise without omitting prerequisites, risks, verification, failure
  behavior, or other information required to complete the task safely.
- Use Mermaid only when it makes a relationship or sequence materially clearer
  and the target renderer supports it.

## Validate before handoff

1. Confirm `agent-docs/index.md` and every affected parent index accurately route
   to the changed documentation.
2. Confirm all documentation pages follow the `folder/index.md` convention and
   any format defined by their parent index.
3. For every new topic, confirm its number is the next unused number, its slug
   matches its subject, and its parent row links to the correct directory.
4. Confirm codes, descriptions, statuses, and other shared metadata match
   between changed pages and their parent-index rows.
5. Check factual support, relative links, code fences, heading hierarchy, table
   structure, and unresolved placeholders.
6. Run existing Markdown formatting, lint, link, or documentation-build checks
   when available. Do not install new tooling without approval.
7. Run safe documented commands when practical; otherwise verify them against
   their defining configuration and report that they were not executed.
8. Inspect the final diff and prove this task changed only `agent-docs/` paths.
   Preserve unrelated working-tree changes.
9. Report affected pages, index updates, reader-visible impact, validation
   results, and anything still unverified.
