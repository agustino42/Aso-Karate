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

## Mapa Conceptual del Sistema

```
🥋 ASO KARATE 2 - SISTEMA INTEGRAL
│
├── 🎛️ DASHBOARD PRINCIPAL
│   ├── Métricas en tiempo real
│   ├── Resumen de competencias activas
│   ├── Estadísticas generales
│   ├── Notificaciones importantes
│   └── Accesos rápidos
│
├──
│   │
│   ├── 👨‍🏫 ENTRENADORES
│   │   ├── Perfil profesional
│   │   ├── Certificaciones y licencias
│   │   ├── Atletas asignados
│   │   ├── Historial de entrenamientos
│   │   ├── Evaluaciones de rendimiento
│   │   └── Calendario de actividades
│   │
│   └── 👨‍⚖️ ÁRBITROS
│       ├── Datos de certificación
│       ├── Nivel de arbitraje
│       ├── Competencias asignadas
│       ├── Evaluaciones de desempeño
│       ├── Disponibilidad y horarios
│       └── Historial de arbitrajes
│
├── 🏆 SISTEMA DE COMPETENCIAS
│   │
│   ├── 📊 TABLA DE CLASIFICACIÓN
│   │   ├── Rankings por categoría
│   │   ├── Puntuaciones acumuladas
│   │   ├── Posiciones históricas
│   │   ├── Filtros por edad/peso/cinturón
│   │   ├── Exportación de resultados
│   │   └── Gráficos de progreso
│   │
│   ├── 🎲 SISTEMA DE SORTEOS
│   │   ├── Generación automática de brackets
│   │   ├── Sorteos aleatorios justos
│   │   ├── Eliminación directa/round robin
│   │   ├── Programación de combates
│   │   ├── Asignación de tatamis
│   │   └── Cronograma de eventos
│   │
│   └── ⚖️ CATEGORIZACIÓN
│       ├── Por edad (sub-categorías)
│       ├── Por peso (divisiones)
│       ├── Por cinturón/grado
│       ├── Por modalidad (kata/kumite)
│       ├── Validación automática
│       └── Gestión de excepciones
│
├── 📈 ANÁLISIS Y REPORTES
│   ├── Estadísticas de participación
│   ├── Análisis de rendimiento
│   ├── Reportes por competencia
│   ├── Gráficos interactivos
│   ├── Exportación de datos
│   └── Métricas de crecimiento
│
├──
└── ⚙️ ADMINISTRACIÓN
    ├── Configuración del sistema
    ├── Gestión de eventos
    ├── Backup y restauración
    ├── Auditoría de actividades
    └── Mantenimiento de datos
```

### Flujo de Trabajo Principal

1. **Registro de Participantes** → Jugadores, Entrenadores, Árbitros
2. **Configuración de Competencia** → Categorías, Reglas, Fechas
3. **Proceso de Sorteo** → Generación automática de brackets
4. **Ejecución de Combates** → Registro de resultados en tiempo real
5. **Actualización de Rankings** → Cálculo automático de puntuaciones
6. **Generación de Reportes** → Estadísticas y análisis post-competencia

## Arquitectura del Dashboard

### 🎛️ Panel Principal
```
┌─────────────────────────────────────────────────────────────┐
│  🥋 ASO KARATE 2 - DASHBOARD                               │
├─────────────────────────────────────────────────────────────┤
│  📊 Métricas Rápidas                                       │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐          │
│  │ 👥 245  │ │ 🏆 12   │ │ 📅 3    │ │ 🎯 89%  │          │
│  │Atletas  │ │Torneos  │ │Próximos │ │Asist.   │          │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘          │
├─────────────────────────────────────────────────────────────┤
│  📈 Gráfico de Participación        🔔 Notificaciones      │
│  ┌─────────────────────────┐        ┌─────────────────────┐ │
│  │     ▄▄▄▄                │        │ • Torneo Regional   │ │
│  │   ▄▄    ▄▄              │        │   inicia mañana     │ │
│  │ ▄▄        ▄▄            │        │ • 15 nuevos atletas │ │
│  │              ▄▄▄▄       │        │ • Actualizar ranks  │ │
│  └─────────────────────────┘        └─────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  🚀 Accesos Rápidos                                        │
│  [👥 Jugadores] [👨‍🏫 Entrenadores] [🏆 Torneos] [📊 Stats] │
└─────────────────────────────────────────────────────────────┘
```

### 👥 Ventana de Gestión de Jugadores
```
┌─────────────────────────────────────────────────────────────┐
│  👥 GESTIÓN DE JUGADORES                    [+ Nuevo] [📤]  │
├─────────────────────────────────────────────────────────────┤
│  🔍 [Buscar jugador...]  📋 Filtros: [Categoría▼] [Dojo▼]  │
├─────────────────────────────────────────────────────────────┤
│  📋 Lista de Jugadores                                      │
│  ┌───┬─────────────────┬──────┬──────┬─────────┬─────────┐  │
│  │📷 │ Nombre          │ Edad │ Peso │ Cinturón│ Estado  │  │
│  ├───┼─────────────────┼──────┼──────┼─────────┼─────────┤  │
│  │👤 │ Juan Pérez      │  16  │ 65kg │ Marrón  │ Activo  │  │
│  │👤 │ María García    │  14  │ 52kg │ Verde   │ Activo  │  │
│  │👤 │ Carlos López    │  18  │ 70kg │ Negro   │ Lesión  │  │
│  └───┴─────────────────┴──────┴──────┴─────────┴─────────┘  │
├─────────────────────────────────────────────────────────────┤
│  📊 Panel de Detalles (al seleccionar)                     │
│  ┌─────────────────┬─────────────────────────────────────┐  │
│  │ 📋 Info Personal│ 🏆 Historial de Competencias       │  │
│  │ • Fecha Nac.    │ • Regional 2024: 🥇 1er lugar     │  │
│  │ • Contacto      │ • Nacional 2023: 🥈 2do lugar     │  │
│  │ • Dojo          │ • Local 2023: 🥉 3er lugar        │  │
│  └─────────────────┴─────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 🏆 Ventana de Tabla de Clasificación
```
┌─────────────────────────────────────────────────────────────┐
│  🏆 TABLA DE CLASIFICACIÓN              📅 Temporada 2024   │
├─────────────────────────────────────────────────────────────┤
│  🎯 Filtros: [Categoría▼] [Modalidad▼] [Región▼] [📊 Ver]  │
├─────────────────────────────────────────────────────────────┤
│  📊 Ranking - Juvenil Masculino (-65kg)                    │
│  ┌────┬─────────────────┬─────┬─────┬─────┬──────────────┐  │
│  │Pos │ Atleta          │Pts  │ P-G │ P-P │ Última Act.  │  │
│  ├────┼─────────────────┼─────┼─────┼─────┼──────────────┤  │
│  │🥇 1│ Juan Pérez      │ 850 │12-2 │ 89% │ 15/01/2024   │  │
│  │🥈 2│ Carlos Ruiz     │ 720 │10-3 │ 77% │ 12/01/2024   │  │
│  │🥉 3│ Diego Silva     │ 680 │ 9-4 │ 69% │ 10/01/2024   │  │
│  │  4 │ Miguel Torres   │ 620 │ 8-5 │ 62% │ 08/01/2024   │  │
│  └────┴─────────────────┴─────┴─────┴─────┴──────────────┘  │
├─────────────────────────────────────────────────────────────┤
│  📈 Gráfico de Evolución    📋 Próximos Eventos            │
│  ┌─────────────────────┐    ┌─────────────────────────────┐ │
│  │    📈 Puntos        │    │ • Torneo Regional: 25/01   │ │
│  │ 900│     ●          │    │ • Copa Nacional: 15/02     │ │
│  │ 800│   ●   ●        │    │ • Selectivo: 01/03         │ │
│  │ 700│ ●       ●      │    │                            │ │
│  │ 600└─────────────── │    └─────────────────────────────┘ │
│  └─────────────────────┘                                   │
└─────────────────────────────────────────────────────────────┘
```

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
![Imagen de WhatsApp 2025-10-17 a las 15 08 48_db5db2a6](https://github.com/user-attachments/assets/925ecca3-1f73-4f4d-ad68-a9ad21c0de94)

**Desarrollado con ❤️ por el Equipo Dinamita**
