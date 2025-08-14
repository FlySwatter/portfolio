from datetime import datetime, timedelta
from typing import Optional
from jose import jwt
from pydantic import BaseModel

ALGORITHM = "HS256"

class TokenData(BaseModel):
    username: str

def create_access_token(subject: str, secret_key: str, expires_minutes: int = 60) -> str:
    expire = datetime.utcnow() + timedelta(minutes=expires_minutes)
    to_encode = {"sub": subject, "exp": expire}
    return jwt.encode(to_encode, secret_key, algorithm=ALGORITHM)
