# Anti-Patterns — What Makes Prompts Fail

## The Bracket Trap
Delivering `[insert your task here]` templates. The user asked for a prompt, not a fill-in form.
**Fix:** Ask the missing question instead of leaving placeholders.

## Invented Conventions
Assuming a format (gitmoji, snake_case, specific structure) without validating it with the user.
**Fix:** Ask "do you follow a specific convention?" before applying one.

## The Vague Superlative
"Write a comprehensive, detailed, high-quality response."
**Fix:** Specify criteria. "Write a response under 300 words covering X, Y, Z."

## Telling What NOT to Do
"Don't be vague. Don't be too long. Don't use jargon."
**Fix:** State what TO do. "Be specific. Keep under 200 words. Use plain language."

## Missing Output Format
No instruction on how the response should look → model chooses freely → inconsistent results.
**Fix:** Always end with an explicit output format section.

## Role Inflation
"You are a world-class expert with 30 years of experience..."
Adds noise without changing behavior for most tasks.
**Fix:** Use role only when it genuinely shifts the response (critic, devil's advocate, domain expert).

## The Wall of Instructions
20+ rules in a flat list. Model loses track of priorities.
**Fix:** Group by category. Put the 3 most important rules first. Use hierarchy.

## Ambiguous Scope
"Summarize this document." — How long? Which parts? For what audience?
**Fix:** One sentence of context + explicit constraints on length and focus.

## Context Dumping
Pasting 5000 tokens of context before a simple question.
**Fix:** Include only what's necessary to answer. See context-management.md.
