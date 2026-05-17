# Frontend Despachos

Aplicacion React/Vite servida por Nginx para la gestion de ventas y despachos.

## Runtime en contenedor

- La imagen final usa Nginx sin privilegios de root.
- El contenedor escucha internamente en el puerto `8082`.
- En ambiente local, Docker Compose publica la aplicacion por `http://localhost`.

## Nota de despliegue

Esta actualizacion tambien fuerza una nueva ejecucion del flujo CI/CD en la rama `deploy`, necesaria para volver a publicar las imagenes en Amazon ECR despues de recrear la infraestructura.
