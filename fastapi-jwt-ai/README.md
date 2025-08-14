# FastAPI JWT Auth + AI Summarizer Endpoint

A secure FastAPI app with JWT-based auth and a demo AI endpoint that calls OpenAI to summarize text.

## Features
- `/auth/login` issues JWT (HS256) for demo users
- CRUD `/items` (in-memory)
- `/ai/summarize` calls OpenAI (set `OPENAI_API_KEY`)
- Dockerfile and pytest tests

## Quickstart
```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
export SECRET_KEY=devsecret OPENAI_API_KEY=sk-REPLACE
uvicorn app.main:app --reload
```
