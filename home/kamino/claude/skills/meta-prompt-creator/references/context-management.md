# Context Management

## What to Include
Only information the model needs to answer correctly. Ask: "If I remove this, does the answer change?" If no → remove it.

## System vs User Split

| Goes in system | Goes in user |
|----------------|--------------|
| Persona, rules, output format | The actual content to process |
| Persistent constraints | Variable data (documents, code, queries) |
| Examples (few-shot) | The specific task for this turn |

## Token Budget Awareness

- Claude: up to 200k context, but long prompts slow response and dilute attention
- GPT-4o: 128k context
- o1/o3: shorter prompts often perform better

**Rule of thumb:** If the prompt exceeds 500 words without user content, it's probably bloated.

## Dynamic Content Placement
Put the content to process as close to the task instruction as possible.

❌ 2000 tokens of context → task → content
✅ Brief context → content → task

## Chunking for Long Documents
If document > ~50k tokens, instruct the model to process in sections:
"Process the document section by section. For each section, [task]. Then synthesize."

## Avoiding Context Pollution
In multi-turn prompts: don't let irrelevant prior turns accumulate. Summarize or clear context when switching tasks.

## Conversation vs Single-Shot
- **Single-shot**: Pack all context into one prompt. Be complete.
- **Multi-turn**: Start minimal. Add context only when the model asks or gets stuck.
