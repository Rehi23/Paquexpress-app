from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from database import Base

class Agente(Base):
    __tablename__ = "agentes"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True)
    password_hash = Column(String(255))
    nombre_completo = Column(String(100))

class Paquete(Base):
    __tablename__ = "paquetes"
    id = Column(Integer, primary_key=True, index=True)
    direccion_destino = Column(String(200))
    latitud_destino = Column(Float)
    longitud_destino = Column(Float)
    estado = Column(String(20)) # 'pendiente' o 'entregado'
    agente_asignado_id = Column(Integer, ForeignKey("agentes.id"))
    fecha_entrega = Column(DateTime)
    evidencia_foto_url = Column(String(255), nullable=True)
    latitud_entrega = Column(Float, nullable=True)
    longitud_entrega = Column(Float, nullable=True)
