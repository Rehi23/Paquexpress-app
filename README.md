# Paquexpress App 📦

Aplicación móvil de logística para el seguimiento y entrega de paquetes en tiempo real. Desarrollada para la materia de Desarrollo Móvil.

## 🚀 Tecnologías Utilizadas
* **Frontend:** Flutter (Dart)
* **Backend:** Python (FastAPI)
* **Base de Datos:** MySQL
* **Seguridad:** OAuth2 con JWT y Encriptación Bcrypt

## 📋 Requisitos Previos
* Flutter SDK instalado.
* Python 3.9+ instalado.
* Servidor MySQL corriendo (XAMPP o Workbench).

## ⚙️ Instalación

### 1. Configuración de Base de Datos
Ejecuta el script `script_db.sql` en tu gestor de MySQL para crear la base de datos `paquexpress_db` y las tablas necesarias.

### 2. Backend (API)
1.  Navega a la carpeta del backend:
    ```bash
    cd backend_fastapi
    ```
2.  Crea un entorno virtual e instala dependencias:
    ```bash
    pip install fastapi uvicorn sqlalchemy mysql-connector-python passlib[bcrypt] python-multipart python-jose
    ```
3.  Ejecuta el servidor:
    ```bash
    uvicorn main:app --reload
    ```
    *La API correrá en http://127.0.0.1:8000*

### 3. Aplicación Móvil (Flutter)
1.  Navega a la carpeta de la app:
    ```bash
    cd app_flutter
    ```
2.  Instala las dependencias:
    ```bash
    flutter pub get
    ```
3.  Ejecuta la aplicación (asegúrate de tener un emulador abierto):
    ```bash
    flutter run
    ```

## 📱 Funcionalidades
1.  **Login Seguro:** Autenticación de agentes mediante Token JWT.
2.  **Lista de Envíos:** Visualización de paquetes pendientes y entregados.
3.  **Geolocalización:** Registro automático de coordenadas GPS al entregar.
4.  **Evidencia Fotográfica:** Captura de foto como prueba de entrega.
5.  **Mapa:** Integración con Google Maps para ver rutas.

## 👤 Autor
[Regina Sanchez (Rehi San)]