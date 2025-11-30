from pydantic import BaseModel
from typing import Optional, List

# Esquema para devolver datos del Agente (sin la contraseña)
class AgenteOut(BaseModel):
    id: int
    username: str
    nombre_completo: str
    class Config:
        orm_mode = True

# Esquema para devolver datos de un Paquete
class PaqueteOut(BaseModel):
    id: int
    direccion_destino: str
    latitud_destino: float
    longitud_destino: float
    estado: str
    class Config:
        orm_mode = True

# Esquema para el Token de acceso (Login)
class Token(BaseModel):
    access_token: str
    token_type: str