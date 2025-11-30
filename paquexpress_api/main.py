from fastapi import FastAPI, Depends, HTTPException, status, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime, timedelta
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from typing import List
from passlib.context import CryptContext
from jose import JWTError, jwt
import shutil
import os

# Importaciones locales
import models, schemas
from database import engine, get_db

# Crear tablas automáticamente al iniciar
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="API Paquexpress")

origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- CONFIGURACIÓN DE SEGURIDAD [cite: 13] ---
SECRET_KEY = "tu_clave_secreta_super_segura_cambiala_en_produccion"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# Funciones de utilidad para seguridad
def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

# Dependencia para obtener el usuario actual desde el Token
# Esto asegura las sesiones [cite: 12]
def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="No se pudieron validar las credenciales",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    user = db.query(models.Agente).filter(models.Agente.username == username).first()
    if user is None:
        raise credentials_exception
    return user

# --- ENDPOINTS ---

# 1. Registro de usuario (Solo para crear pruebas con contraseña encriptada)
@app.post("/crear-agente-prueba")
def create_agent(username: str, password: str, nombre: str, db: Session = Depends(get_db)):
    hashed_pw = get_password_hash(password) # Encriptación [cite: 13]
    db_agent = models.Agente(username=username, password_hash=hashed_pw, nombre_completo=nombre)
    db.add(db_agent)
    db.commit()
    return {"msg": "Agente creado exitosamente"}

# 2. Login (Generar Token) [cite: 12]
@app.post("/token", response_model=schemas.Token)
def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(models.Agente).filter(models.Agente.username == form_data.username).first()
    if not user or not verify_password(form_data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario o contraseña incorrectos",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token = create_access_token(data={"sub": user.username})
    return {"access_token": access_token, "token_type": "bearer"}

# 3. Obtener paquetes asignados al agente logueado [cite: 6]
@app.get("/mis-paquetes", response_model=List[schemas.PaqueteOut])
def read_paquetes(db: Session = Depends(get_db), current_user: models.Agente = Depends(get_current_user)):
    # Solo mostramos los pendientes asignados a ESTE agente
    paquetes = db.query(models.Paquete).filter(
        models.Paquete.agente_asignado_id == current_user.id,
        models.Paquete.estado == 'pendiente'
    ).all()
    return paquetes

# 4. Registrar Entrega (Foto + GPS) [cite: 7, 8, 9]
@app.post("/paquetes/{paquete_id}/entregar")
async def registrar_entrega(
    paquete_id: int,
    latitud: float = Form(...),
    longitud: float = Form(...),
    file: UploadFile = File(...), # La foto de evidencia
    db: Session = Depends(get_db),
    current_user: models.Agente = Depends(get_current_user)
):
    # Buscar el paquete
    paquete = db.query(models.Paquete).filter(models.Paquete.id == paquete_id).first()
    
    if not paquete:
        raise HTTPException(status_code=404, detail="Paquete no encontrado")
    
    # Guardar la imagen en una carpeta local
    upload_folder = "uploads"
    os.makedirs(upload_folder, exist_ok=True)
    file_location = f"{upload_folder}/{file.filename}"
    
    with open(file_location, "wb+") as file_object:
        shutil.copyfileobj(file.file, file_object)
    
    # Actualizar BD [cite: 9]
    paquete.estado = "entregado"
    paquete.evidencia_foto_url = file_location
    paquete.latitud_entrega = latitud
    paquete.longitud_entrega = longitud
    paquete.fecha_entrega = datetime.now()
    
    db.commit()
    
    return {"msg": "Entrega registrada exitosamente"}

# NUEVO: Endpoint para ver el historial de entregas
@app.get("/mi-historial", response_model=List[schemas.PaqueteOut])
def read_historial(db: Session = Depends(get_db), current_user: models.Agente = Depends(get_current_user)):
    # Filtramos por el usuario Y por estado 'entregado'
    paquetes = db.query(models.Paquete).filter(
        models.Paquete.agente_asignado_id == current_user.id,
        models.Paquete.estado == 'entregado'
    ).all()
    return paquetes