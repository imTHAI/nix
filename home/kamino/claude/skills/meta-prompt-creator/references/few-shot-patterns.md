# Few-Shot Patterns

## When to Use Examples
- Output format is non-obvious (custom JSON schema, unusual structure)
- Tone or style is hard to describe ("write like X")
- Task involves edge cases the model might mishandle
- Transformation tasks (input → output mapping)

## When NOT to Use
- Task is already unambiguous ("translate to French")
- Model already knows the domain well
- Adding examples would eat significant tokens for marginal gain

## Structure

```
Example 1:
Input: [sample input]
Output: [expected output]

Example 2:
Input: [sample input]
Output: [expected output]

Now process:
Input: [actual input]
Output:
```

The trailing `Output:` prefills the response and removes preamble.

## How Many Examples
- 1 example: establishes format
- 2-3 examples: establishes pattern + edge cases
- 4+ examples: rarely worth it; use a spec instead

## Example Quality
- Use realistic data, not obviously fake placeholders
- Cover edge cases if they matter (empty input, special characters, etc.)
- Keep examples consistent with each other

## Negative Examples (optional)
Show what NOT to do only if the model keeps making the same mistake:
```
❌ Wrong: [bad output]
✅ Right: [correct output]
```

## For Claude Specifically
Place examples inside `<examples>` XML tags to clearly separate them from the task:
```xml
<examples>
<example>
<input>The cat sat.</input>
<output>{"subject": "cat", "verb": "sat"}</output>
</example>
</examples>
```
