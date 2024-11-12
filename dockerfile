# Usar una imagen oficial de Python como base
FROM python:3.9-slim

# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar los archivos de la aplicación al contenedor
COPY . /app

# Instalar dependencias del sistema
RUN apt-get update && \
    apt-get install -y \
    curl \
    gnupg2 \
    apt-transport-https \
    ca-certificates && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17


# Instalar las dependencias de Python
RUN pip install --no-cache-dir -r requirements.txt

# Exponer el puerto en el que la aplicación Flask va a correr
EXPOSE 5000

# Comando para ejecutar la aplicación Flask
CMD ["python", "app.py"]
