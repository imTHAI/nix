# OpenAI / GPT — Best Practices

## Model Selection Impact

| Model | Prompt style |
|-------|-------------|
| GPT-4o | Detailed instructions work well, handles markdown |
| o1 / o3 | Minimal prompt — model reasons itself. Avoid step-by-step. |
| GPT-4o-mini | Explicit and concise — less inference from context |

## Core Principles

- **Markdown renders**: GPT-4o displays headers, bold, lists properly in ChatGPT UI.
- **Delimiters matter**: Use `"""`, `---`, or XML-style tags to separate sections.
- **Persona helps**: "You are a senior software engineer..." shifts tone and depth effectively.

## System Prompt Structure (GPT)

```
You are [role].

Your task: [what to do]

Rules:
- [constraint 1]
- [constraint 2]

Output format: [exact format]
```

## o1 / o3 Specifics

These models reason internally — don't prompt them to reason:
- ❌ "Think step by step"
- ❌ "Let's think about this carefully"
- ✅ Just state the task directly and concisely

For o1: shorter prompts often outperform longer ones.

## Few-Shot

GPT models respond well to examples in the user turn:

```
Input: The cat sat on the mat.
Output: {"subject": "cat", "action": "sat", "location": "mat"}

Input: Birds fly south in winter.
Output:
```

## Function Calling / Structured Output

If using the API, prefer `response_format: { type: "json_schema" }` over asking for JSON in the prompt — more reliable.

## Avoid

- Overly long system prompts for o1 (counter-productive)
- Relying on markdown in API-only contexts (not rendered)
- "Do not hallucinate" — ineffective instruction
