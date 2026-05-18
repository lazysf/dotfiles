# CONTEXT Format

`CONTEXT.md` is a glossary for context-specific language.
It is not a spec, scratchpad, implementation plan, decision record, or place for secrets.
In this repo, write `CONTEXT.md` content in Japanese unless preserving an established English term is clearer.

## Structure

```markdown
# [Context Name]

[One or two sentences describing what this context is and why it exists.]

## Language

**Term**: [A concise one-sentence definition of the concept.]
_Avoid_: [Aliases or overloaded words to avoid]

## Relationships

- **Term A** relates to **Term B**

## Example dialogue

> **Dev:** "[A question that uses the terms naturally]"
> **Domain expert:** "[An answer that clarifies the boundary]"

## Flagged ambiguities

- "[Ambiguous word]" was used to mean both **A** and **B**. Resolved: [resolution]
```

## Rules

- Be opinionated. Pick a canonical term and list aliases to avoid.
- Write prose in Japanese in this repo. Keep established English domain terms when translating them would make the glossary less precise.
- Keep definitions tight. One sentence max; define what it is, not implementation behavior.
- Include only terms specific to this context. General programming concepts do not belong.
- Show relationships with bold term names and cardinality when obvious.
- Flag conflicts explicitly in `Flagged ambiguities` with a clear resolution.
- Group terms under subheadings only when natural clusters emerge.
- Do not include secrets, credentials, private config values, unpublished personal data, temporary work notes, specs, or implementation decisions.

## Single vs Multi-Context

Single-context repo:

- Use one root `CONTEXT.md`.

Multi-context repo:

- Use root `CONTEXT-MAP.md`.
- List each context, where its `CONTEXT.md` lives, and how contexts relate.
- Place each `CONTEXT.md` near the thing it describes.

When updating:

- If `CONTEXT-MAP.md` exists, read it first and choose the relevant context.
- If only root `CONTEXT.md` exists, update it as the single context.
- If neither exists, create root `CONTEXT.md` only when the first term is resolved.
- If multiple contexts exist and the target context is unclear, ask instead of creating a new context by guesswork.
