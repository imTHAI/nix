---
name: exa-search
description: Use when you need to find technical libraries, npm packages, alternatives to existing tools, recent blog posts or articles about a technical topic, or when semantic search over technical content would surface better results than keyword search. Triggers on: "find a library for X", "alternative to [tool]", "recent articles about [topic]", "how do people solve X". Do NOT use for official API documentation (use context7), debugging existing code, or general non-technical web searches.
---

# Exa Semantic Search

Use Exa's neural search API for technical discovery. Exa finds content by meaning, not keywords — better for libraries, alternatives, and real-world usage patterns.

## When to use

Trigger when the user wants to:
- Find a library or package for a specific use case
- Find alternatives to an existing tool or library
- Find recent articles, blog posts, or discussions about a technical topic
- Understand how people solve a technical problem in practice

Do **not** trigger for:
- Official library documentation → use `context7`
- Debugging or conceptual questions about existing code
- General non-technical web searches → use `WebSearch`

## How to call the API

Build a clear semantic query from the user's intent. Then run:

```bash
EXA_KEY=$(cat ~/.config/exa/api-key 2>/dev/null)
if [ -z "$EXA_KEY" ]; then
  # Key not provisioned — fall back to WebSearch
  echo "FALLBACK"
fi
curl -sf --max-time 10 -X POST https://api.exa.ai/search \
  -H "x-api-key: $EXA_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "<semantic query based on user intent>",
    "numResults": 5,
    "contents": {
      "text": { "maxCharacters": 2000 }
    }
  }' | jq '.'
```

The response JSON has structure: `{ results: [{ title, url, text }] }`. Extract `results[].title`, `results[].url`, and `results[].text` to synthesize your answer.

## How to respond

Do **not** dump raw URLs or raw JSON at the user. Synthesize a direct answer from the results. Cite sources inline when useful (e.g., `[article title](url)`).

If `~/.config/exa/api-key` does not exist or `curl` fails, fall back to `WebSearch` and note the fallback briefly.
