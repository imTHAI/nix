---
name: hand-over
description: Generate a self-contained handover of the current session and copy it to the clipboard, so the user can /clear and paste it into a fresh context.
disable-model-invocation: true
---

# Hand-over

The user wants to `/clear` because the context is too large. Produce a handover that lets a
fresh session continue the work immediately, without asking clarifying questions.

## Rules

- Write in the user's language (French by default).
- Self-contained: the next session has zero memory of this one. No "as discussed", no "the bug above".
- Dense, not exhaustive: keep what is needed to act, drop the narrative. Target under ~80 lines.
- Exact references: file paths with line numbers, commands, commit hashes, error messages verbatim.
- Include dead ends and why they failed, so they are not retried.
- Before writing, run `git status --short` and `git log --oneline -5` if in a git repo, to state the repo accurately.
- If `$ARGUMENTS` is provided, treat it as the focus of the next session and orient the plan around it.

## Format

```markdown
# Handover : <one-line subject>

## Objectif
<what we are trying to achieve, and why>

## État actuel
<where things stand right now>

## Fait
- <decisions, changes (files touched), validations>

## Pistes écartées
- <what was tried and why it did not work>

## Contexte technique
- <gotchas, environment quirks, key file paths with line numbers>

## État du repo
<branch, HEAD, uncommitted changes>

## Prochaines étapes
1. <concrete step, with command or file:line>

## Première action
<the exact first thing the next session should do>
```

## Delivery

Copy the handover to the clipboard with a quoted heredoc (prevents shell expansion of `$`, backticks):

```bash
cat <<'HANDOVER_EOF' | pbcopy
<handover content>
HANDOVER_EOF
```

Then reply with one short line: the handover is in the clipboard, run `/clear` then paste it.
Do not print the handover itself in the reply, it would only add tokens to a context about to be discarded.
