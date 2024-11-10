FROM python:3.10-slim

# Instalar dependencias del sistema para pyodbc y el driver ODBC para SQL Server
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    unixodbc-dev gcc curl gnupg && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17 && \
    rm -rf /var/lib/apt/lists/*

# El resto de tu Dockerfile
WORKDIR /app
COPY . .
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

CMD ["flask", "run", "--host=0.0.0.0"]
