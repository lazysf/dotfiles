# ADR Format

ADRs live in `docs/adr/` and use sequential numbering: `0001-slug.md`, `0002-slug.md`, etc.
This repo uses lightweight ADR bodies with mandatory decision status.

## When To Create An ADR

Create an ADR only when all three are true:

1. Hard to reverse: the cost of changing direction later is meaningful.
2. Surprising without context: a future reader would wonder why this path was chosen.
3. Real trade-off: there were genuine alternatives and one was chosen for specific reasons.

Skip the ADR if the decision is easy to reverse, obvious, or had no real alternative.

## Minimum Template

```markdown
# NNNN: [Short decision title]

- Status: Proposed

[1-3 sentences explaining the context, decision, and why.]
```

## Status

`Status` is mandatory in this repo.

Allowed values:

- `Proposed`: created but not yet accepted
- `Accepted`: adopted and currently valid
- `Superseded`: replaced by a later ADR
- `Rejected`: kept as a rejected option

Use relationship metadata only when explicitly known:

- `- Supersedes: 0003`
- `- Superseded-By: 0005`

Do not infer supersede relationships.

## Optional Sections

Only add sections when they carry real value:

```markdown
## Context

[Confirmed background that explains why the decision was needed.]

## Decision

[The chosen direction.]

## Consequences

[Non-obvious downstream effects, constraints, or residual risks.]
```

Other optional sections, such as considered options, are allowed only when the rejected alternatives are worth remembering.

## Numbering

- Scan `docs/adr/` for the highest existing number.
- Increment by one.
- Use a short kebab-case slug.
- Add new ADRs to `docs/README.md`.
