<h1 align="center">🥋 Aso Karate 2</h1>

<p align="center">
 Sistema de gestión  integral y Panel de Control para asociaciones de karate
</p>

<p align="center">
  <a href="#características"><strong>Características</strong></a> ·
  <a href="#módulos"><strong>Módulos</strong></a> ·
  <a href="#instalación"><strong>Instalación</strong></a> ·
  <a href="#tecnologías"><strong>Tecnologías</strong></a> ·
  <a href="#equipo"><strong>Equipo</strong></a>
</p>
<br/>

## Descripción

**Aso Karate 2** es un sistema de gestión integral diseñado específicamente para asociaciones de karate. Esta aplicación web permite administrar de manera eficiente todos los aspectos relacionados con la organización de competencias, gestión de atletas, y administración general de la asociación.

## Características

- 🔐 **Autenticación segura** con roles diferenciados
- 📱 **Interfaz responsive** adaptable a cualquier dispositivo
- 🌙 **Modo claro/oscuro** para mejor experiencia de usuario
- ⚡ **Rendimiento optimizado** con Next.js 14
- 🔄 **Actualizaciones en tiempo real** con Supabase
- 📊 **Reportes y estadísticas** detalladas
- 🎯 **Sistema de categorización** automático por edad y peso

## Módulos

### 🎛️ Panel de Control
Dashboard principal con métricas clave, resumen de actividades recientes y accesos rápidos a las funciones más utilizadas.

### 👥 Gestión de Jugadores
- Registro completo de atletas
- Historial de competencias
- Seguimiento de progreso
- Gestión de documentos
- Categorización automática

### 👤 Gestión de Usuarios
- Control de acceso por roles
- Perfiles personalizables
- Historial de actividades
- Configuración de permisos

### 🛡️ Gestión de Administradores
- Panel de administración avanzado
- Gestión de roles y permisos
- Configuración del sistema
- Auditoría de actividades

### 🏆 Tabla de Puntuaciones
- Sistema de ranking dinámico
- Puntuaciones por categoría
- Historial de competencias
- Exportación de resultados

### 📈 Estadísticas
- Análisis de rendimiento
- Gráficos interactivos
- Reportes personalizados
- Métricas de participación

### 🎲 Sorteos
- Generación automática de llaves
- Sorteos aleatorios justos
- Gestión de brackets
- Programación de combates

### ⚖️ Categorías por Edad y Peso
- Clasificación automática
- Configuración flexible de categorías
- Validación de requisitos
- Gestión de excepciones

## Tecnologías

- **Frontend**: Next.js 14, React, TypeScript
- **Backend**: Supabase (PostgreSQL, Auth, Real-time)
- **Estilos**: Tailwind CSS, shadcn/ui
- **Autenticación**: Supabase Auth
- **Base de datos**: PostgreSQL (Supabase)
- **Despliegue**: Vercel

## Instalación

### Prerrequisitos
- Node.js 18+ 
- npm, yarn o pnpm
- Cuenta de Supabase

### Pasos de instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/tu-usuario/aso-karate-2.git
   cd aso-karate-2
   ```

2. **Instalar dependencias**
   ```bash
   npm install
   # o
   yarn install
   # o
   pnpm install
   ```



3. **Configurar base de datos**
   
   Ejecuta las migraciones de Supabase para crear las tablas necesarias.

4. **Ejecutar en desarrollo**
   ```bash
   npm run dev
   ```
   
   La aplicación estará disponible en [http://localhost:3000](http://localhost:3000)

### Configuración de Supabase

1. Crea un nuevo proyecto en [Supabase](https://database.new)
2. Configura las políticas de seguridad (RLS)
3. Crea las tablas necesarias usando las migraciones incluidas
4. Configura la autenticación por email

## Equipo de Desarrollo

**Equipo Dinamita** - Desarrollo de Aplicaciones 2

Este proyecto fue desarrollado como parte del Sub-Proyecto de Desarrollo de Aplicaciones 2, enfocándose en crear una solución integral para la gestión de asociaciones deportivas de karate.

### Objetivos del Proyecto

- Digitalizar la gestión de competencias de karate
- Automatizar procesos administrativos
- Mejorar la experiencia de usuarios y administradores
- Implementar un sistema escalable y mantenible
- Aplicar mejores prácticas de desarrollo web moderno

## Contribución

Este es un proyecto académico desarrollado por el Equipo Dinamita.

## Licencia

Este proyecto es desarrollado con fines académicos para el curso de Desarrollo de Aplicaciones 2.

---

**Desarrollado con ❤️ por el Equipo Dinamita**
