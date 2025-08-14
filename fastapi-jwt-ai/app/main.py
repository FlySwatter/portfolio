import os
from fastapi import FastAPI, HTTPException, Depends, Header
from fastapi.responses import JSONResponse
from jose import jwt, JWTError
from typing import List, Optional
from .auth import create_access_token
from .models import LoginRequest, Item
from .ai_service import summarize_text

app = FastAPI(title="FastAPI JWT + AI")

SECRET_KEY = os.getenv("SECRET_KEY", "devsecret")
ALGORITHM = "HS256"
DB = []

def get_user(token: Optional[str] = Header(default=None, alias="Authorization")):
    if not token or not token.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing Bearer token")
    try:
        payload = jwt.decode(token.split()[1], SECRET_KEY, algorithms=[ALGORITHM])
        return payload.get("sub")
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

@app.post("/auth/login")
def login(body: LoginRequest):
    # Demo-only auth
    if body.username and body.password:
        token = create_access_token(body.username, SECRET_KEY, 120)
        return {"access_token": token, "token_type": "bearer"}
    raise HTTPException(status_code=400, detail="Invalid credentials")

@app.get("/items", response_model=List[Item])
def list_items(user=Depends(get_user)):
    return DB

@app.post("/items", response_model=Item)
def create_item(item: Item, user=Depends(get_user)):
    DB.append(item.model_dump())
    return item

@app.post("/ai/summarize")
def ai_summarize(payload: dict):
    text = payload.get("text", "")
    if not text:
        raise HTTPException(status_code=400, detail="text is required")
    return {"summary": summarize_text(text)}
