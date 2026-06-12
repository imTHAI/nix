# XML Structure in Prompts (Claude)

## Why XML
Claude is trained to treat XML tags as semantic separators. They outperform markdown headers, triple backticks, and `---` dividers for structuring complex prompts.

## Common Tags

| Tag | Use |
|-----|-----|
| `<task>` | The instruction to execute |
| `<context>` | Background the model needs |
| `<document>` / `<content>` | Text/data to process |
| `<examples>` + `<example>` | Few-shot examples |
| `<constraints>` | Rules and limits |
| `<output_format>` | Exact expected format |
| `<thinking>` | Model's reasoning (hidden from final output) |

## Basic Template

```xml
<context>
You are reviewing pull requests for a Python codebase. Focus on correctness and security.
</context>

<task>
Review the following diff and identify issues. For each issue, specify the line number, severity (low/medium/high), and a fix.
</task>

<diff>
{{DIFF}}
</diff>

<output_format>
Issue 1:
- Line: N
- Severity: high
- Fix: ...
</output_format>
```

## Nested Tags
Use for collections:
```xml
<examples>
  <example>
    <input>foo</input>
    <output>bar</output>
  </example>
  <example>
    <input>baz</input>
    <output>qux</output>
  </example>
</examples>
```

## Variable Injection
Mark dynamic content clearly:
```xml
<document>
{{USER_DOCUMENT}}
</document>
```
`{{VARIABLE}}` convention signals "this will be replaced."

## When XML Helps Most
- Prompt with 3+ distinct sections
- Few-shot examples that need clear boundaries
- Separating instructions from user-provided content
- When model confuses context with task

## When XML is Overkill
- Simple one-line prompts
- Conversational interactions
- When model is GPT (markdown works as well there)
