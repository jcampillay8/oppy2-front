# 🛠️ Stage 1: Compilar Flutter Web
FROM ghcr.io/cirrusci/flutter:3.24.0 AS build

WORKDIR /app

# Copiar archivos de dependencias e instalarlas
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copiar todo el código fuente del frontend
COPY . .

# Compilar Flutter para Web en modo release
ARG API_BASE_URL=https://oppy2-back-production.up.railway.app
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

# 🚀 Stage 2: Servidor Web ultraligero con NGINX
FROM nginx:alpine

# Copiar configuración NGINX para SPA
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar artefactos web compilados
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
