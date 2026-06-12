# Anthropic / Claude — Best Practices

## Core Principles

- **Be direct**: Claude responds to clear instructions. No need to say "please" or hedge.
- **Structured > prose**: Use numbered lists, headers, or XML tags for multi-part instructions.
- **Role is optional**: Only add a role if it genuinely changes behavior (expert, critic, etc.). Skip generic "you are a helpful assistant."

## XML Tags (strongly recommended)

Claude handles XML tags better than markdown for separating prompt sections:

```xml
<task>Summarize the following document in 3 bullet points.</task>

<document>
{{DOCUMENT}}
</document>

<output_format>
- Bullet 1
- Bullet 2
- Bullet 3
</output_format>
```

Use tags for: `<task>`, `<context>`, `<document>`, `<examples>`, `<constraints>`, `<output_format>`, `<thinking>`.

## Prefill (Claude-specific)

Start Claude's response by prefilling the Assistant turn:

```
Human: Generate a JSON object for this user.
Assistant: {
```

Forces Claude to continue in the desired format without preamble.

## Thinking / Reasoning

For complex tasks, add before the task:
```
Think step by step before answering.
```
Or use extended thinking via API (budget_tokens parameter).

## System vs User Prompt

- **System**: Persistent persona, rules, output format, constraints
- **User**: The actual task + content to process

Keep format/rules in system. Keep variable content in user.

## Avoid

- "As an AI language model..." (Claude ignores or flags this)
- Contradictory instructions
- Vague superlatives ("best", "perfect", "comprehensive") without criteria
- Telling Claude what NOT to do without saying what TO do instead
