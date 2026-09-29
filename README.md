# 💸 SaveMyMoney

**Aplicación web para registrar tus gastos por categoría y visualizarlos en gráficas.**

SaveMyMoney es una app hecha con **Flask (Python)** y **SQL Server** que te permite crear tipos de gasto (comida, transporte, renta…), registrar gastos dentro de cada uno y generar gráficas de barras y de pastel filtradas por periodo. Incluye configuración con **Docker Compose** para levantar la app y la base de datos con un solo comando.

![Python](https://img.shields.io/badge/Python-3.9-3776AB?logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-2.3.2-000000?logo=flask)
![SQL Server](https://img.shields.io/badge/SQL%20Server-2022-CC2927?logo=microsoftsqlserver&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)
![Estado](https://img.shields.io/badge/Estado-En%20desarrollo-orange)

---

## 📑 Tabla de contenido

1. [Características](#-características)
2. [Tecnologías](#-tecnologías)
3. [Estructura del repositorio](#-estructura-del-repositorio)
4. [Modelo de datos](#-modelo-de-datos)
5. [Rutas de la aplicación](#-rutas-de-la-aplicación)
6. [Requisitos previos](#-requisitos-previos)
7. [Instalación y ejecución con Docker](#-instalación-y-ejecución-con-docker-recomendada)
8. [Ejecución local sin Docker](#-ejecución-local-sin-docker)
9. [Guía de uso](#-guía-de-uso)
10. [Variables de entorno](#-variables-de-entorno)
11. [Problemas conocidos y mejoras sugeridas](#-problemas-conocidos-y-mejoras-sugeridas)
12. [Créditos](#-créditos)

---

## ✨ Características

| Función | Descripción |
|---|---|
| 🗂️ **Tipos de gasto** | Crea, edita y elimina categorías con nombre y descripción. |
| 🧾 **Gastos** | Dentro de cada tipo, agrega, edita y elimina gastos (nombre, monto y fecha automática). |
| 📊 **Gráficos** | Genera una gráfica de **barras** y otra de **pastel** por tipo de gasto. |
| 🔎 **Filtros de periodo** | Distribución **Individual** (todos los gastos del tipo), **Mensual** (mes del año en curso) o **Anual**. |
| 🌙 **Interfaz oscura** | Diseño con Bootstrap 5.3 en tema oscuro, con alertas de confirmación y modales para eliminar. |
| 🐳 **Docker** | `docker-compose.yml` con la app Flask y un contenedor de SQL Server 2022. |

---

## 🧰 Tecnologías

- **Backend:** Python 3.9, [Flask](https://flask.palletsprojects.com/) 2.3.2
- **Base de datos:** Microsoft SQL Server 2022, acceso mediante [pyodbc](https://github.com/mkleehammer/pyodbc) 4.0.35 y el driver *ODBC Driver 17 for SQL Server*
- **Gráficas:** [Plotly](https://plotly.com/python/) 5.11.0
- **Frontend:** plantillas Jinja2 + [Bootstrap](https://getbootstrap.com/) 5.3.3 (CDN)
- **Contenedores:** Docker y Docker Compose

---

## 📁 Estructura del repositorio

```
SaveMyMoney/
├── app.py                 # Aplicación Flask: conexión a BD, rutas y gráficas
├── requirements.txt       # Dependencias de Python (Flask, pyodbc, plotly)
├── dockerfile             # Imagen de la app (Python 3.9 + ODBC Driver 17)
├── docker-compose.yml     # Servicios: app Flask + SQL Server 2022
├── static/img/            # Íconos (icon.png, github.png)
└── templates/             # Vistas HTML (Jinja2)
    ├── layout.html        # Plantilla base: encabezado, navegación y pie
    ├── index.html         # Lista de tipos de gasto
    ├── addTG.html         # Formulario: nuevo tipo de gasto
    ├── editTG.html        # Formulario: editar tipo de gasto
    ├── Gastos.html        # Lista de gastos de un tipo
    ├── addG.html          # Formulario: nuevo gasto
    ├── editG.html         # Formulario: editar gasto
    ├── Graficos.html      # Formulario para generar gráficas
    └── newGraph.html      # Resultado: gráfica de barras y de pastel
```

> ℹ️ El repositorio también contiene una carpeta `venv/` (entorno virtual de Windows) y `__pycache__/`. No son necesarias para ejecutar el proyecto; ver [mejoras sugeridas](#-problemas-conocidos-y-mejoras-sugeridas).

---

## 🗄️ Modelo de datos

Base de datos: **`SaveMyMoney`**. El script de creación está en `app.py` (dentro de un comentario) y es este:

```sql
CREATE DATABASE SaveMyMoney;
GO
USE SaveMyMoney;
GO

CREATE TABLE TipoGasto (
    ID          INT PRIMARY KEY IDENTITY(1,1),
    Tipo        VARCHAR(40)  NOT NULL,
    Descripcion VARCHAR(100)
);

CREATE TABLE Gastos (
    ID     INT PRIMARY KEY IDENTITY(1,1),
    TipoID INT NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Gasto  DECIMAL(10,2) NOT NULL,
    Fecha  DATE NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Gastos_TipoGasto FOREIGN KEY (TipoID) REFERENCES TipoGasto(ID)
);
```

```
TipoGasto (1) ────────< (N) Gastos
```

> ⚠️ **La app no crea la base de datos ni las tablas por sí sola.** Debes ejecutar este script una vez antes de usarla (ver los pasos de instalación).

---

## 🧭 Rutas de la aplicación

| Ruta | Método | Función |
|---|---|---|
| `/` | GET | Lista los tipos de gasto. |
| `/nuevo-tipo` | GET | Formulario para crear un tipo de gasto. |
| `/addTG` | POST | Guarda el nuevo tipo de gasto. |
| `/editar/tipo-de-gasto-<id>` | GET | Formulario para editar un tipo. |
| `/actualizar/tipo-de-gasto-<id>` | POST | Guarda los cambios del tipo. |
| `/eliminar/<id>` | GET | Elimina un tipo **y todos sus gastos**. |
| `/gastos/<id>` | GET | Lista los gastos de un tipo. |
| `/gastos/<id>/nuevo-gasto/` | GET | Formulario para crear un gasto. |
| `/add/<tipo>` | POST | Guarda el nuevo gasto. |
| `/gastos/editar/<id>` | GET | Formulario para editar un gasto. |
| `/actualizar/<id>` | POST | Guarda los cambios del gasto. |
| `/gastos/eliminar/<id>` | GET | Elimina un gasto. |
| `/graficos/` | GET | Formulario para generar gráficas. |
| `/generate` | POST | Consulta los gastos según el filtro y redirige a la gráfica. |
| `/graphic/<info>` | GET | Muestra la gráfica de barras y la de pastel. |

---

## ✅ Requisitos previos

**Para usar Docker (recomendado):**

- [Docker](https://docs.docker.com/get-docker/) y Docker Compose
- Puertos **5000** (app) y **1433** (SQL Server) libres
- Conexión a internet (descarga de imágenes, paquetes y Bootstrap por CDN)

**Para ejecución local sin Docker:**

- Python 3.9 o superior
- Una instancia de SQL Server accesible
- [ODBC Driver 17 for SQL Server](https://learn.microsoft.com/sql/connect/odbc/download-odbc-driver-for-sql-server) instalado

---

## 🐳 Instalación y ejecución con Docker (recomendada)

### 1. Clonar el repositorio

```bash
git clone https://github.com/noejsl/SaveMyMoney.git
cd SaveMyMoney
```

### 2. Revisar la contraseña de SQL Server

Abre `docker-compose.yml` y cambia el valor de `SA_PASSWORD` (servicio `sql_server`) y de `SQL_SERVER_PASSWORD` (servicio `app`): **deben ser idénticos**. SQL Server exige una contraseña robusta (mínimo 8 caracteres con mayúsculas, minúsculas, números y símbolos).

### 3. Levantar solo la base de datos

```bash
docker compose up -d sql_server
```

Espera unos 20–30 segundos a que SQL Server termine de iniciar.

### 4. Crear la base de datos y las tablas

Guarda el [script SQL](#-modelo-de-datos) en un archivo `init.sql` y ejecútalo dentro del contenedor:

```bash
docker cp init.sql sql_server:/tmp/init.sql
docker exec -it sql_server /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "<TU_CONTRASEÑA>" -C -i /tmp/init.sql
```

> Si tu imagen trae la versión anterior de las herramientas, la ruta es `/opt/mssql-tools/bin/sqlcmd` y no necesita `-C`.
> Alternativa: conéctate con Azure Data Studio o SSMS a `localhost,1433` (usuario `sa`) y ejecuta el script.

### 5. Levantar la aplicación

```bash
docker compose up --build
```

El servicio `app` espera 30 segundos antes de arrancar para dar tiempo a SQL Server.

### 6. Abrir la app

Visita **http://localhost:5000**.

### Detener y limpiar

```bash
docker compose down        # detiene los contenedores
docker compose down -v     # además elimina volúmenes
```

> ⚠️ El servicio `sql_server` **no define un volumen** de datos: si eliminas el contenedor (`docker compose down`), perderás la base de datos y tendrás que repetir el paso 4.

---

## 💻 Ejecución local sin Docker

### 1. Crear el entorno virtual e instalar dependencias

```bash
git clone https://github.com/noejsl/SaveMyMoney.git
cd SaveMyMoney

python -m venv .venv
# Windows (PowerShell):
.venv\Scripts\Activate.ps1
# Linux / macOS:
source .venv/bin/activate

pip install -r requirements.txt
```

> `requirements.txt` está guardado en codificación UTF-16. Si `pip` marca error al leerlo, vuelve a guardarlo como UTF-8 o instala directamente: `pip install Flask==2.3.2 pyodbc==4.0.35 plotly==5.11.0`.

### 2. Crear la base de datos

Ejecuta el [script SQL](#-modelo-de-datos) en tu instancia de SQL Server (con SSMS, Azure Data Studio o `sqlcmd`).

### 3. Configurar la conexión

Por defecto la app busca el servidor `sql_server` (el nombre del contenedor), así que en local debes definir las variables de entorno:

**Windows (PowerShell):**

```powershell
$env:SQL_SERVER_SERVER   = "localhost"
$env:SQL_SERVER_USER     = "sa"
$env:SQL_SERVER_PASSWORD = "<TU_CONTRASEÑA>"
$env:SQL_SERVER_DATABASE = "SaveMyMoney"
```

**Linux / macOS:**

```bash
export SQL_SERVER_SERVER=localhost
export SQL_SERVER_USER=sa
export SQL_SERVER_PASSWORD='<TU_CONTRASEÑA>'
export SQL_SERVER_DATABASE=SaveMyMoney
```

### 4. Ejecutar

```bash
python app.py
```

Abre **http://localhost:5000**.

---

## 📖 Guía de uso

### 1️⃣ Crear un tipo de gasto
1. En **Inicio**, pulsa **Agregar Tipo**.
2. Escribe el **Tipo** (máx. 40 caracteres) y una **Descripción** (máx. 100).
3. Guarda. Verás el mensaje de confirmación y la nueva tarjeta en la lista.

### 2️⃣ Editar o eliminar un tipo
- **Editar:** cambia el nombre o la descripción.
- **Eliminar:** confirma en el modal. ⚠️ Se borran también **todos los gastos** de ese tipo.

### 3️⃣ Registrar gastos
1. En la tarjeta del tipo, pulsa **Ver gastos**.
2. Pulsa el botón para agregar un gasto e ingresa **Nombre** y **Total** (por ejemplo `250.50`).
3. La **fecha** se asigna automáticamente con el día actual.
4. Desde la lista puedes **editar** o **eliminar** cada gasto.

### 4️⃣ Generar gráficas
1. Ve a **Gráficos** en el menú superior.
2. Elige el **tipo de gasto**.
3. Elige la **distribución**:
   - **Individual:** todos los gastos de ese tipo.
   - **Mensual:** selecciona un mes (se usa el año en curso).
   - **Anual:** selecciona un año (2024–2030).
4. Pulsa el botón para generar. Verás una **gráfica de barras** y una **de pastel** con el nombre y el monto de cada gasto.

---

## 🔧 Variables de entorno

| Variable | Valor por defecto en el código | Descripción |
|---|---|---|
| `SQL_SERVER_SERVER` | `sql_server` | Host del servidor SQL. |
| `SQL_SERVER_DATABASE` | `SaveMyMoney` | Nombre de la base de datos. |
| `SQL_SERVER_USER` | `sa` | Usuario. |
| `SQL_SERVER_PASSWORD` | *(definida en el código)* | Contraseña del usuario. |

---

## 🚨 Problemas conocidos y mejoras sugeridas

Encontré estos puntos al revisar el código. No los probé ejecutando la app, así que verifícalos antes de dar por hecho el comportamiento.

**Seguridad**
- 🔑 **Contraseña de SQL Server escrita en el repositorio público**, tanto en `docker-compose.yml` como en el valor por defecto de `app.py`. Cámbiala y sácala del código, por ejemplo con un archivo `.env` que esté en `.gitignore` y `${SQL_PASSWORD}` en el compose.
- 🔐 `app.secret_key` está fijo en el código (`'mysecretkey'`); conviene leerlo de una variable de entorno.
- 🐞 La app corre con `debug=True`, que no debe usarse en producción.
- ⚠️ Eliminar tipos y gastos se hace con enlaces `GET` (`/eliminar/<id>`); lo recomendable es usar `POST` para acciones que modifican datos.

**Funcionamiento**
- 🌐 `app.run(port=5000, debug=True)` no define `host`, por lo que Flask escucha solo en `127.0.0.1`. Dentro de un contenedor, eso normalmente impide abrir la app desde tu navegador aunque el puerto esté publicado. Si pasa, cambia la última línea a `app.run(host="0.0.0.0", port=5000, debug=True)`.
- 🗄️ La base de datos y las tablas **no se crean automáticamente** (el script está comentado en `app.py`). Sería útil incluir un `init.sql` y ejecutarlo al iniciar.
- 🔌 La conexión a SQL Server se intenta **varias veces en el arranque** y el compose usa `sleep 30`; un *healthcheck* en el servicio `sql_server` sería más confiable.
- 💾 Sin volumen para SQL Server, los datos se pierden al borrar el contenedor.
- 🧱 El `dockerfile` usa `python:3.9-slim` (Debian) pero agrega el repositorio de Microsoft de **Ubuntu 22.04** y `apt-key`, que está obsoleto; puede fallar al construir la imagen en versiones recientes de Debian.
- 📋 La lista de gastos (`Gastos.html`) muestra `g.Tipo`, pero la tabla `Gastos` no tiene esa columna, por lo que ese texto aparece vacío.

**Organización del repo**
- 🧹 Quita `venv/` y `__pycache__/` del repositorio y agrega un `.gitignore`:
  ```gitignore
  venv/
  .venv/
  __pycache__/
  .env
  ```
  ```bash
  git rm -r --cached venv __pycache__
  ```
- 📝 Convierte `requirements.txt` a UTF-8.

---

## 👥 Créditos

Proyecto desarrollado por **DevLine** ([@AlainLobato](https://github.com/AlainLobato)), **Noejsl** ([@noejsl](https://github.com/noejsl)) y **Carlos8092** ([@Carlos8092](https://github.com/Carlos8092)), según el pie de página de la aplicación.
