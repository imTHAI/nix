# Reasoning Techniques

## Chain-of-Thought (CoT)
**When:** Multi-step problems, math, logic, decisions with tradeoffs.
**How:** Add before the task:
```
Think step by step before giving your final answer.
```
Or for Claude, use extended thinking via API.

**Don't use for:** Simple retrieval, formatting, translation — adds tokens with no benefit.

## Step-Back Prompting
Ask the model to identify the general principle before solving the specific case.
```
Before answering, identify the general principle that applies here.
Then apply it to the specific case.
```
**When:** The model keeps solving the surface problem, missing the deeper issue.

## Self-Consistency
Run the same prompt multiple times, take the majority answer.
**When:** High-stakes single answers where you can afford multiple calls.

## Scratchpad / Think Aloud
```
Use a <thinking> block to reason through this before writing your answer.
Do not include the thinking block in your final response.
```
**When:** Complex tasks where intermediate reasoning would pollute the output.

## Decomposition
Break the task explicitly:
```
1. First, list all relevant facts from the document.
2. Then, identify contradictions.
3. Finally, write your conclusion based only on step 1 and 2.
```
**When:** The model skips steps or conflates analysis with conclusion.

## Devil's Advocate
```
After giving your answer, argue the strongest case against it in 2-3 sentences.
```
**When:** Decisions, recommendations, evaluations — forces balanced output.

## Model-Specific Notes
- **o1/o3**: Has internal reasoning — don't add CoT prompts, they interfere
- **Claude**: Responds well to `<thinking>` tags for separating reasoning from output
- **GPT-4o**: CoT prompts improve accuracy on complex tasks
