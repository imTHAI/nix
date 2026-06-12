# System Prompt Patterns

## Anatomy of a Strong System Prompt

```
[Role — optional]
[Core task / purpose]
[Behavioral rules]
[Output format]
[Edge case handling]
```

## Role (use sparingly)
Only when it changes the response quality:
✅ "You are a code reviewer focused on security vulnerabilities."
❌ "You are a helpful, harmless, honest assistant." (default behavior)

## Core Task
One sentence. What is this assistant for?
"Your task is to convert user-described changes into git commit messages following the Conventional Commits spec."

## Behavioral Rules
3-7 rules max. Prioritize by importance. Use imperative:
```
- Always ask for the diff before writing the message
- Never invent scope or type — ask if uncertain
- Use present tense imperative: "add", not "added"
```

## Output Format
Be explicit. Include an example if the format is non-obvious:
```
Output format:
<type>(<scope>): <subject>

[optional body]
```

## Edge Case Handling
Anticipate the top 2-3 failure modes:
```
If the user provides only a description (no diff): ask for the diff or the changed files.
If the change spans multiple concerns: write one commit per concern and say so.
```

## What NOT to Put in System Prompt
- The actual content to process (goes in user turn)
- Instructions that change every turn (goes in user turn)
- Redundant safety instructions (model already has them)

## Length Guidelines
- Simple assistant: 100-200 words
- Complex assistant with rules: 300-500 words
- Beyond 500 words: likely bloated, audit for redundancy
