# Clarity Principles

## One Instruction Per Sentence
Each sentence = one action. No compound instructions.

❌ "Read the document, extract the key points, and write a summary in French keeping only the technical concepts."
✅ Three separate instructions, or use a numbered list.

## Imperative Mood
Start task instructions with a verb.

❌ "The model should provide a summary..."
✅ "Summarize..."

## Quantify Everything Vague
Replace adjectives with numbers or criteria.

| Vague | Clear |
|-------|-------|
| "brief summary" | "summary in 3 bullet points" |
| "detailed explanation" | "explanation covering X, Y, Z" |
| "soon" | "in the next response" |
| "simple language" | "no jargon, 8th grade reading level" |

## Explicit > Implicit
Don't rely on the model inferring your intent.

❌ "Make it professional." (professional for whom? what industry?)
✅ "Use formal register, no contractions, British English."

## Separate Signal From Noise
Put the task instruction close to the content it applies to, not buried after paragraphs of context.

## Prioritize Rules
If you have multiple constraints, say which matters most.
"Most important: stay under 100 words. If needed, skip the examples."

## Test Your Clarity
Read the prompt as if you know nothing about the task. Is every term defined? Is the expected output unambiguous?
