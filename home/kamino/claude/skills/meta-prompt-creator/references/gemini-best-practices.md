# Google Gemini — Best Practices

Source: https://ai.google.dev/gemini-api/docs/prompting-intro

## Model Selection

| Model | Use case |
|-------|----------|
| Gemini Flash (2.0, 3) | Fast, cost-efficient, everyday tasks |
| Gemini Pro (1.5, 2.0) | Complex reasoning, long context |
| Gemini 3.5 Flash | Latest default, good balance |

Flash = speed/cost. Pro = quality/depth.

## System Instructions

Set via `system_instruction` parameter (API) or the system prompt field (AI Studio).

Official template:
```xml
<role>
You are a specialized assistant for [domain].
You are precise, analytical, and persistent.
</role>

<instructions>
1. Plan: Analyze the task and create a step-by-step plan.
2. Execute: Carry out the plan.
3. Validate: Review your output against the user's task.
4. Format: Present the final answer in the requested structure.
</instructions>

<constraints>
- Verbosity: [Low/Medium/High]
- Tone: [Formal/Casual/Technical]
</constraints>

<output_format>
Structure your response as follows:
1. Executive Summary: [Short overview]
2. Detailed Response: [The main content]
</output_format>
```

## XML-Style Tags
Gemini responds well to XML tags for structuring prompts (same pattern as Claude):
- `<role>`, `<instructions>`, `<constraints>`, `<output_format>`
- Use tags to clearly separate sections in complex prompts

## Few-Shot Examples
Place examples before the actual task. Use consistent input/output pairs:
```
Determine the city along with the landmark.
[image of Colosseum]
city: Rome, landmark: the Colosseum.

[image of Forbidden City]
city: Beijing, landmark: Forbidden City

[actual image]
```

## Structured Output
Use `response_schema` (JSON schema) via API for reliable structured output — more robust than asking for JSON in the prompt.

## Context Window
- Gemini 1.5 Pro: up to 1M tokens
- Gemini 2.0 Flash: up to 1M tokens
- Gemini 3.5 Flash: up to 1M tokens

Long context is a Gemini strength — can process entire codebases, books, or long conversations.

## Reasoning / Thinking
Gemini 2.0 Flash Thinking and Gemini 3 have built-in reasoning modes. For these:
- Don't add "think step by step" — reasoning is internal
- State the task directly and concisely (same pattern as o1)

## Key Differences vs Claude
- XML tags work but are less central than in Claude
- `system_instruction` is a separate API parameter (not part of the messages array)
- Multimodal (images, video, audio) is a core strength — include media naturally
- Very long context windows make document-heavy prompts viable without chunking

## Avoid
- Overly long system prompts for Flash models
- Repeating instructions already in system_instruction in every user turn
- "Do not hallucinate" — not effective
