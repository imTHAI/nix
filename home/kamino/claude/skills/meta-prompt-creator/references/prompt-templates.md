# Prompt Templates — Common Task Types

## Summarization
```
Summarize the following [document type] in [N bullet points / N words].
Focus on: [key aspect 1], [key aspect 2].
Audience: [who will read this].

[CONTENT]
```

## Extraction
```
Extract all [entities: dates / names / prices / actions] from the text below.
Return as a JSON array: [{"field": "value"}]
If none found, return an empty array [].

[CONTENT]
```

## Classification
```
Classify the following [items] into one of these categories: [A, B, C].
Rules:
- If ambiguous, choose the closest match
- Return only the category name, nothing else

[ITEM]
```

## Code Review
```
Review the following [language] code for [focus: correctness / security / performance].
For each issue found:
- Line number
- Severity: low | medium | high
- Explanation (1 sentence)
- Suggested fix (code snippet)

[CODE]
```

## Transformation (rewrite/translate)
```
Rewrite the following text [in French / in formal register / for a non-technical audience].
Preserve: [meaning / structure / tone].
Do not add or remove information.

[TEXT]
```

## Q&A Over Document
```
Answer the question below using only information from the provided document.
If the answer is not in the document, say "Not found in document."
Do not infer or add external knowledge.

<document>
[CONTENT]
</document>

Question: [QUESTION]
```

## Structured Generation
```
Generate a [JSON / YAML / table] with the following fields:
- field1: [description]
- field2: [description]

Context: [relevant info]

Return only the raw [format], no explanation.
```

## Decision / Recommendation
```
You are evaluating [options / proposals].
Criteria (in order of importance):
1. [criterion 1]
2. [criterion 2]
3. [criterion 3]

For each option, score it against the criteria (1-5) and give a one-line rationale.
End with a final recommendation and the main tradeoff.

Options:
[OPTIONS]
```
