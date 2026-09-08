# 🛠️ Stage 1: Entorno de compilación oficial con Ubuntu + Flutter SDK
FROM ubuntu:22.04 AS build

ENV DEBIAN_FRONTEND=noninteractive

# Instalar herramientas básicas necesarias para Flutter
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Clonar Flutter SDK rama stable directamente desde el repositorio oficial
RUN git clone https://github.com/flutter/flutter.git -b stable /sdks/flutter
ENV PATH="/sdks/flutter/bin:$PATH"

# Habilitar soporte web en Flutter
RUN flutter config --enable-web

WORKDIR /app

# Copiar dependencias y resolver paquetes
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copiar el código fuente completo del frontend
COPY . .

# Compilar Flutter para Web en modo release con API_BASE_URL
ARG API_BASE_URL=https://oppy2-back-production.up.railway.app
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

# 🚀 Stage 2: Servidor Web ultraligero con NGINX
FROM nginx:alpine

# Copiar la configuración NGINX para Single Page Application (SPA)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar artefactos web compilados desde el stage build
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
