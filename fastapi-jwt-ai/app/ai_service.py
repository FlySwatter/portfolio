import os, requests

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")

def summarize_text(text: str) -> str:
    if not OPENAI_API_KEY:
        return "(AI disabled: set OPENAI_API_KEY) " + text[:120]
    # Minimal example hitting OpenAI's Chat Completions (placeholder endpoint for demonstration)
    try:
        resp = requests.post(
            "https://api.openai.com/v1/chat/completions",
            headers={"Authorization": f"Bearer {OPENAI_API_KEY}"},
            json={
                "model": "gpt-4o-mini",
                "messages": [
                    {"role": "system", "content": "Summarize the user's text."},
                    {"role": "user", "content": text},
                ],
                "temperature": 0.2
            },
            timeout=15,
        )
        data = resp.json()
        return data.get("choices", [{}])[0].get("message", {}).get("content", "No summary")
    except Exception as e:
        return f"(AI error) {e}"
