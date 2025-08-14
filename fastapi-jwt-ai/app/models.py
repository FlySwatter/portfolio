from pydantic import BaseModel

class LoginRequest(BaseModel):
    username: str
    password: str

class Item(BaseModel):
    id: int
    name: str
