# Dockerfile para servir Flutter Web en Dokploy
FROM nginx:alpine

# Copiar la configuración personalizada de Nginx para evitar 404 en subrutas de Flutter Web y activar compresión
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar los archivos estáticos de la build web de Flutter al directorio de Nginx
COPY build/web /usr/share/nginx/html

# Exponer el puerto 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
