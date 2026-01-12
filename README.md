<h1 align="center">English Classes Academy - Moodle Platform</h1>

<p align="center">
  <img alt="Github top language" src="https://img.shields.io/github/languages/top/Leandro-Bertoluzzi/curso-ingles?color=56BEB8">

  <img alt="Github language count" src="https://img.shields.io/github/languages/count/Leandro-Bertoluzzi/curso-ingles?color=56BEB8">

  <img alt="Repository size" src="https://img.shields.io/github/repo-size/Leandro-Bertoluzzi/curso-ingles?color=56BEB8">
</p>

<hr>

<p align="center">
    <a href="#dart-resumen">Resumen</a> &#xa0; | &#xa0;
    <a href="#rocket-tecnologías">Tecnologías</a> &#xa0; | &#xa0;
    <a href="#checkered_flag-inicio-rápido">Inicio Rápido</a> &#xa0; | &#xa0;
    <a href="#art-personalización">Personalización</a> &#xa0; | &#xa0;
    <a href="#package-estructura-del-proyecto">Estructura del Proyecto</a> &#xa0; | &#xa0;
   <a href="#wrench-comandos-útiles">Comandos Útiles</a> &#xa0; | &#xa0;
   <a href="#books-recursos-adicionales">Recursos Adicionales</a> &#xa0; | &#xa0;
   <a href="#memo-license">License</a> &#xa0; | &#xa0;
   <a href="#writing_hand-authors">Authors</a>
</p>

## :dart: Resumen

Sistema de gestión de clases de inglés basado en Moodle, diseñado para una profesora particular que busca gestionar sus cursos de manera profesional.

## :rocket: Tecnologías

- [Moodle](https://moodle.org/) - Plataforma LMS
- [Docker](https://www.docker.com/) - Contenedores
- [PHP](https://www.php.net/) - Lenguaje de programación
- [MySQL/MariaDB](https://mariadb.org/) - Base de datos

## :checkered_flag: Inicio Rápido

### Prerequisitos

- Docker y Docker Compose instalados

### Instalación

```bash
# 1) Clonar el repositorio
git clone https://github.com/Leandro-Bertoluzzi/curso-ingles.git
cd curso-ingles

# 2) Configurar variables de entorno
cp .env.example .env
# Edita .env con tus credenciales deseadas

# 3) Iniciar los contenedores
docker compose up -d

# 4) Esperar a que Moodle se inicialice (primera vez ~3-5 minutos)
docker compose logs -f moodle

# 5) Acceder a Moodle
# URL: http://localhost:8080
# Usuario: admin (o el configurado en .env)
# Contraseña: Admin123! (o la configurada en .env)
```

## :art: Personalización

### Activar el Tema Personalizado

1. Ingresa como administrador
2. Ve a **Administración del sitio** → **Apariencia** → **Temas** → **Selector de temas**
3. Selecciona **English Academy** como tema predeterminado

### Modificar Estilos

Edita el archivo de estilos:
```bash
src/presentation/theme/style/custom.css
```

Después de modificar, limpia la caché de Moodle:
**Administración del sitio** → **Desarrollo** → **Purgar cachés**

## :package: Estructura del Proyecto

```
.
├── docker-compose.yml         # Configuración de Docker
├── .env.example               # Variables de entorno de ejemplo
├── .gitignore                 # Archivos ignorados por Git
├── README.md                  # Este archivo
└── theme/                     # Código fuente del tema personalizado
    ├── style/                 # Archivos CSS
    ├── layout/                # Layouts de Moodle
    └── templates/             # Plantillas HTML
```

## :wrench: Comandos Útiles

### Gestión de Contenedores

```bash
# Iniciar servicios
docker compose up -d

# Detener servicios
docker compose down

# Ver logs
docker compose logs -f

# Reiniciar servicios
docker compose restart

# Reconstruir contenedores
docker compose up -d --build
```

### Backup y Restauración

```bash
# Backup de la base de datos
docker compose exec mariadb mysqldump -u moodleuser -p moodle > backup.sql

# Restaurar base de datos
docker compose exec -T mariadb mysql -u moodleuser -p moodle < backup.sql

# Backup de moodledata
tar -czf moodledata-backup.tar.gz moodledata/
```

### Desarrollo

```bash
# Acceder al contenedor de Moodle
docker compose exec moodle bash

# Ver logs de PHP
docker compose exec moodle tail -f /opt/bitnami/moodle/logs/error.log

# Limpiar caché desde CLI
docker compose exec moodle php admin/cli/purge_caches.php
```

## :books: Recursos Adicionales

- [Documentación de Moodle](https://docs.moodle.org/)
- [Desarrollo de Temas en Moodle](https://docs.moodle.org/dev/Themes)
- [API de Plugins en Moodle](https://docs.moodle.org/dev/Plugin_files)

## :memo: Licencia

Este proyecto está bajo la licencia MIT. Para más detalles, vea el archivo [LICENSE](LICENSE.md).

## :writing_hand: Autor

Hecho con :heart: por <a href="https://github.com/Leandro-Bertoluzzi" target="_blank">Leandro Bertoluzzi</a>.

<a href="#top">Volver arriba</a>