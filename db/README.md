# 🗄️ Base de Datos - Aso Karate 2

## Descripción General

Base de datos diseñada para el sistema integral de gestión de asociaciones de karate con **arquitectura de doble interfaz**:
- **Panel Administrativo**: Control total del sistema por parte del administrador
- **Interfaz Pública**: Vista limitada para usuarios finales

Utiliza PostgreSQL a través de Supabase con Row Level Security (RLS) para garantizar la seguridad de los datos.

## 🏗️ Arquitectura del Sistema

### **Modelo de Acceso Dual**

```
┌─────────────────────────────────────────────────────────────┐
│                    🔐 PANEL ADMINISTRATIVO                  │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  👨‍💼 SUPER ADMINISTRADOR                                │ │
│  │  • Gestión completa de usuarios y roles                │ │
│  │  • Creación y administración de dojos                  │ │
│  │  • Gestión total de competencias                       │ │
│  │  • Control de inscripciones y sorteos                 │ │
│  │  • Supervisión de combates y resultados               │ │
│  │  • Acceso a todas las estadísticas y reportes         │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                   👥 INTERFAZ PÚBLICA                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │ 🥋 ATLETAS  │  │👨‍🏫 ENTRENA. │  │ ⚖️ ÁRBITROS │         │
│  │ • Mi perfil │  │ • Mi perfil │  │ • Mi perfil │         │
│  │ • Mis comp. │  │ • Mis atlet.│  │ • Mis comb. │         │
│  │ • Rankings  │  │ • Estadíst. │  │ • Horarios  │         │
│  │ • Historial │  │ • Reportes  │  │ • Resultados│         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
```

## 📊 Diagrama de Relaciones Reestructurado

```
                    ┌─────────────────┐
                    │    auth.users   │
                    │   (Supabase)    │
                    └─────────┬───────┘
                              │
                    ┌─────────▼───────┐
                    │    usuarios     │ ◄─── 🔑 TABLA CENTRAL
                    │ - id            │
                    │ - email         │
                    │ - nombre_comp.  │
                    │ - rol           │
                    │ - estado        │
                    │ - creado_por    │ ◄─── Admin que lo registró
                    │ - es_admin      │ ◄─── Flag de administrador
                    └─────────┬───────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
┌───────▼───────┐    ┌────────▼────────┐    ┌──────▼──────┐
│    atletas    │    │  entrenadores   │    │   arbitros  │
│ - id          │    │ - id            │    │ - id        │
│ - usuario_id  │    │ - usuario_id    │    │ - usuario_id│
│ - fecha_nac   │    │ - dojo_id       │    │ - nivel     │
│ - genero      │    │ - certificacion │    │ - licencia  │
│ - peso        │    │ - experiencia   │    │ - especialid│
│ - altura      │    │ - especialidad  │    │ - estado    │
│ - cinturon    │    │ - asignado_por  │◄───┤ - asign_por │◄─── Admin
│ - dojo_id     │    └─────────────────┘    └─────────────┘
│ - entrenador  │
│ - registr_por │◄─── Admin que lo registró
└───────┬───────┘
        │
        │    ┌─────────────────┐
        └────┤     dojos       │
             │ - id            │
             │ - nombre        │
             │ - direccion     │
             │ - creado_por    │◄─── Admin
             │ - estado        │
             └─────────────────┘
```

## 🏆 Diagrama del Sistema de Competencias

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  competencias   │    │   categorias    │    │ inscripciones   │
│ - id            │◄───┤ - id            │◄───┤ - id            │
│ - nombre        │    │ - competencia_id│    │ - atleta_id     │
│ - descripcion   │    │ - nombre        │    │ - categoria_id  │
│ - fecha_inicio  │    │ - genero        │    │ - competencia_id│
│ - fecha_fin     │    │ - edad_min/max  │    │ - estado        │
│ - ubicacion     │    │ - peso_min/max  │    │ - fecha_inscr   │
│ - tipo          │    │ - cinturones    │    └─────────────────┘
│ - estado        │    │ - modalidad     │
└─────────────────┘    └─────────────────┘
        │
        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    sorteos      │    │    brackets     │    │    combates     │
│ - id            │◄───┤ - id            │    │ - id            │
│ - competencia_id│    │ - sorteo_id     │    │ - competencia_id│
│ - categoria_id  │    │ - atleta_id     │    │ - categoria_id  │
│ - tipo_sorteo   │    │ - posicion      │    │ - atleta1_id    │
│ - fecha_sorteo  │    │ - ronda_actual  │    │ - atleta2_id    │
│ - estado        │    │ - estado        │    │ - ronda         │
└─────────────────┘    └─────────────────┘    │ - tatami        │
                                              │ - ganador_id    │
                                              │ - arbitro_id    │
                                              └─────────┬───────┘
                                                        │
                                              ┌─────────▼───────┐
                                              │  puntuaciones   │
                                              │ - id            │
                                              │ - combate_id    │
                                              │ - atleta_id     │
                                              │ - puntos        │
                                              │ - penalizaciones│
                                              │ - tecnica       │
                                              └─────────────────┘
```

## 📈 Diagrama del Sistema de Rankings

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ clasificaciones │    │estadisticas_atl │    │historial_comp   │
│ - id            │    │ - id            │    │ - id            │
│ - atleta_id     │◄───┤ - atleta_id     │    │ - atleta_id     │
│ - categoria_id  │    │ - temporada     │    │ - competencia_id│
│ - temporada     │    │ - total_combates│    │ - categoria_id  │
│ - puntos_total  │    │ - victorias     │    │ - posicion_final│
│ - combates_gan  │    │ - derrotas      │    │ - medalla       │
│ - combates_perd │    │ - empates       │    │ - puntos_obt    │
│ - posicion      │    │ - puntos_anot   │    └─────────────────┘
└─────────────────┘    │ - puntos_recib  │
                       │ - kos_realiz    │
                       │ - kos_recib     │
                       │ - porcentaje    │
                       └─────────────────┘
```

## 💡 Mejoras Basadas en Proyecto Anterior

### **Separación de Autenticación **

#### `autenticacion_usuarios`
```sql
CREATE TABLE autenticacion_usuarios (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID REFERENCES usuarios(id) NOT NULL,
    proveedor TEXT CHECK (proveedor IN ('supabase', 'google', 'facebook', 'apple')) DEFAULT 'supabase',
    proveedor_id TEXT, -- ID del proveedor externo
    email_verificado BOOLEAN DEFAULT FALSE,
    telefono_verificado BOOLEAN DEFAULT FALSE,
    autenticacion_doble_factor BOOLEAN DEFAULT FALSE,
    ultimo_login TIMESTAMP WITH TIME ZONE,
    intentos_fallidos INTEGER DEFAULT 0,
    bloqueado_hasta TIMESTAMP WITH TIME ZONE,
    token_recuperacion TEXT,
    fecha_expiracion_token TIMESTAMP WITH TIME ZONE,
    ip_ultimo_acceso INET,
    dispositivo_ultimo_acceso TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### **Sistema de Competencias Mejorado **

#### `competencias_modalidades`
```sql
CREATE TABLE competencias_modalidades (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    competencia_id UUID REFERENCES competencias(id) NOT NULL,
    modalidad TEXT CHECK (modalidad IN ('kata_individual', 'kata_equipo', 'kumite_individual', 'kumite_equipo')) NOT NULL,
    categoria_edad TEXT, -- "infantil", "juvenil", "senior"
    categoria_peso TEXT, -- Solo para kumite
    genero TEXT CHECK (genero IN ('masculino', 'femenino', 'mixto')) NOT NULL,
    max_participantes INTEGER,
    participantes_actuales INTEGER DEFAULT 0,
    costo_inscripcion DECIMAL(10,2) DEFAULT 0,
    fecha_limite_inscripcion TIMESTAMP WITH TIME ZONE,
    estado TEXT CHECK (estado IN ('abierta', 'cerrada', 'en_progreso', 'finalizada')) DEFAULT 'abierta',
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `participaciones` (Inspirado en tu competencias_participantes)
```sql
CREATE TABLE participaciones (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    modalidad_id UUID REFERENCES competencias_modalidades(id) NOT NULL,
    tipo_participacion TEXT CHECK (tipo_participacion IN ('individual', 'equipo')) NOT NULL,
    
    -- Para participación individual
    atleta_id UUID REFERENCES atletas(id),
    
    -- Para participación en equipo
    equipo_id UUID REFERENCES equipos_entrenador(id),
    
    fecha_inscripcion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    estado_inscripcion TEXT CHECK (estado_inscripcion IN ('pendiente', 'confirmada', 'cancelada')) DEFAULT 'pendiente',
    pagado BOOLEAN DEFAULT FALSE,
    fecha_pago TIMESTAMP WITH TIME ZONE,
    observaciones TEXT,
    
    -- Validación: debe ser individual O equipo, no ambos
    CHECK (
        (tipo_participacion = 'individual' AND atleta_id IS NOT NULL AND equipo_id IS NULL) OR
        (tipo_participacion = 'equipo' AND equipo_id IS NOT NULL AND atleta_id IS NULL)
    ),
    
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### **Sistema de Grupos/Llaves **

#### `grupos_competencia`
```sql
CREATE TABLE grupos_competencia (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    modalidad_id UUID REFERENCES competencias_modalidades(id) NOT NULL,
    nombre_grupo TEXT NOT NULL, -- "Grupo A", "Grupo B", "Semifinal", "Final"
    tipo_grupo TEXT CHECK (tipo_grupo IN ('eliminatoria', 'round_robin', 'semifinal', 'final')) NOT NULL,
    orden_grupo INTEGER, -- Para ordenar los grupos
    max_participantes INTEGER DEFAULT 8,
    participantes_actuales INTEGER DEFAULT 0,
    estado TEXT CHECK (estado IN ('formacion', 'activo', 'completado')) DEFAULT 'formacion',
    fecha_inicio TIMESTAMP WITH TIME ZONE,
    fecha_fin TIMESTAMP WITH TIME ZONE,
    ganador_id UUID, -- Puede referenciar participaciones
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `grupos_participantes`
```sql
CREATE TABLE grupos_participantes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    grupo_id UUID REFERENCES grupos_competencia(id) NOT NULL,
    participacion_id UUID REFERENCES participaciones(id) NOT NULL,
    posicion_grupo INTEGER, -- Posición dentro del grupo
    puntos_grupo INTEGER DEFAULT 0,
    combates_ganados INTEGER DEFAULT 0,
    combates_perdidos INTEGER DEFAULT 0,
    puntos_favor INTEGER DEFAULT 0,
    puntos_contra INTEGER DEFAULT 0,
    clasificado BOOLEAN DEFAULT FALSE, -- Si clasifica a siguiente ronda
    fecha_ingreso TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(grupo_id, participacion_id)
);
```

### **Sistema de Resultados Mejorado **

#### `enfrentamientos_detallados`
```sql
CREATE TABLE enfrentamientos_detallados (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    grupo_id UUID REFERENCES grupos_competencia(id) NOT NULL,
    participante1_id UUID REFERENCES grupos_participantes(id) NOT NULL,
    participante2_id UUID REFERENCES grupos_participantes(id) NOT NULL,
    
    -- Información del combate
    fecha_programada TIMESTAMP WITH TIME ZONE,
    tatami INTEGER,
    arbitro_principal_id UUID REFERENCES arbitros(id),
    
    -- Resultados
    puntos_participante1 INTEGER DEFAULT 0,
    puntos_participante2 INTEGER DEFAULT 0,
    ganador_id UUID REFERENCES grupos_participantes(id),
    tipo_victoria TEXT CHECK (tipo_victoria IN ('puntos', 'ippon', 'penalizacion', 'abandono')),
    
    -- Estado
    estado TEXT CHECK (estado IN ('programado', 'en_vivo', 'finalizado', 'cancelado')) DEFAULT 'programado',
    
    -- Detalles adicionales
    duracion_combate INTEGER, -- en segundos
    observaciones TEXT,
    video_url TEXT,
    
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CHECK (participante1_id != participante2_id)
);
```

## 🏆 Sistema de Resultados Tipo Champions

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   temporadas    │    │ tabla_posiciones│    │ enfrentamientos │
│ - id            │◄───┤ - id            │    │ - id            │
│ - nombre        │    │ - temporada_id  │    │ - temporada_id  │
│ - año           │    │ - atleta_id     │    │ - atleta_local  │
│ - fecha_inicio  │    │ - puntos        │    │ - atleta_visit  │
│ - fecha_fin     │    │ - partidos_jug  │    │ - fecha_combate │
│ - estado        │    │ - ganados       │    │ - resultado     │
│ - tipo_torneo   │    │ - perdidos      │    │ - puntos_local  │
└─────────────────┘    │ - empates       │    │ - puntos_visit  │
                       │ - goles_favor   │    │ - estado        │
                       │ - goles_contra  │    │ - jornada       │
                       │ - diferencia    │    └─────────────────┘
                       │ - posicion      │
                       └─────────────────┘
                               │
                               ▼
                    ┌─────────────────┐
                    │ historico_champ │
                    │ - id            │
                    │ - temporada_id  │
                    │ - atleta_id     │
                    │ - posicion_final│
                    │ - titulo        │
                    │ - medalla       │
                    │ - puntos_total  │
                    └─────────────────┘
```

## ⚔️ Sistema de Simulación de Combates

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ reglas_karate   │    │ combate_tiempo  │    │ acciones_combate│
│ - id            │    │ - id            │    │ - id            │
│ - modalidad     │    │ - combate_id    │    │ - combate_id    │
│ - duracion      │    │ - tiempo_total  │    │ - atleta_id     │
│ - puntos_yuko   │    │ - tiempo_activo │    │ - tipo_accion   │
│ - puntos_wazari │    │ - tiempo_pausa  │    │ - puntos_obt    │
│ - puntos_ippon  │    │ - round_actual  │    │ - tecnica       │
│ - penalizaciones│    │ - estado_tiempo │    │ - tiempo_accion │
│ - criterios_vic │    └─────────────────┘    │ - validada_por  │
└─────────────────┘                          │ - observaciones │
        │                                    └─────────────────┘
        ▼                                            │
┌─────────────────┐    ┌─────────────────┐          ▼
│ tecnicas_karate │    │ penalizaciones  │    ┌─────────────────┐
│ - id            │    │ - id            │    │ marcador_tiempo │
│ - nombre        │    │ - combate_id    │    │ - id            │
│ - tipo          │    │ - atleta_id     │    │ - combate_id    │
│ - puntos_valor  │    │ - tipo_penal    │    │ - minuto        │
│ - zona_contacto │    │ - descripcion   │    │ - segundo       │
│ - dificultad    │    │ - tiempo_penal  │    │ - puntos_atl1   │
│ - es_valida     │    │ - arbitro_id    │    │ - puntos_atl2   │
└─────────────────┘    └─────────────────┘    │ - estado_combate│
                                              └─────────────────┘
```

## 🔄 Flujo de Datos Administrativo

```
1. 👨‍💼 ADMINISTRADOR REGISTRA USUARIOS
   Admin → auth.users → usuarios → [atletas|entrenadores|arbitros]
   
2. 🏢 ADMINISTRADOR GESTIONA DOJOS
   Admin → dojos → asigna atletas/entrenadores
   
3. 🏆 ADMINISTRADOR CREA COMPETENCIAS
   Admin → competencias → categorias → configuración
   
4. 📝 ADMINISTRADOR GESTIONA INSCRIPCIONES
   Admin → revisa/aprueba inscripciones → confirma participantes
   
5. 🎲 ADMINISTRADOR REALIZA SORTEOS
   Admin → genera sorteos → crea brackets → programa combates
   
6. ⚔️ ADMINISTRADOR SUPERVISA COMBATES
   Admin → asigna árbitros → supervisa puntuaciones → valida resultados
   
7. 📊 ADMINISTRADOR GENERA REPORTES
   Admin → actualiza clasificaciones → genera estadísticas → publica rankings
```

## 🎯 Flujo de Usuario Final

```
1. 👤 USUARIO SE AUTENTICA
   Usuario → login → verifica rol → redirige a interfaz correspondiente
   
2. 🥋 ATLETA VE SUS DATOS
   Atleta → mi perfil → mis competencias → mi ranking
   
3. 👨‍🏫 ENTRENADOR GESTIONA
   Entrenador → mis atletas → estadísticas → reportes limitados
   
4. ⚖️ ÁRBITRO ACCEDE
   Árbitro → combates asignados → registro de puntuaciones
```

## 🏆 Nuevas Tablas para Sistema Champions

### **1. Temporadas y Torneos**

#### `temporadas`
```sql
CREATE TABLE temporadas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre TEXT NOT NULL, -- "Liga Nacional 2024", "Copa Internacional"
    descripcion TEXT,
    año INTEGER NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    tipo_torneo TEXT CHECK (tipo_torneo IN ('liga', 'copa', 'eliminatoria', 'round_robin')) NOT NULL,
    estado TEXT CHECK (estado IN ('planificada', 'en_curso', 'finalizada', 'suspendida')) DEFAULT 'planificada',
    categoria_id UUID REFERENCES categorias(id),
    premio_campeon TEXT,
    premio_subcampeon TEXT,
    premio_tercer_lugar TEXT,
    creado_por UUID REFERENCES usuarios(id) NOT NULL,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `tabla_posiciones`
```sql
CREATE TABLE tabla_posiciones (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    temporada_id UUID REFERENCES temporadas(id) NOT NULL,
    atleta_id UUID REFERENCES atletas(id) NOT NULL,
    puntos INTEGER DEFAULT 0,
    partidos_jugados INTEGER DEFAULT 0,
    ganados INTEGER DEFAULT 0,
    perdidos INTEGER DEFAULT 0,
    empates INTEGER DEFAULT 0,
    puntos_favor INTEGER DEFAULT 0, -- Puntos anotados
    puntos_contra INTEGER DEFAULT 0, -- Puntos recibidos
    diferencia_puntos INTEGER DEFAULT 0, -- Diferencia de puntos
    posicion INTEGER,
    racha_actual TEXT, -- "3G", "2P", "1E" (Ganados, Perdidos, Empates)
    mejor_posicion INTEGER,
    peor_posicion INTEGER,
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(temporada_id, atleta_id)
);
```

#### `enfrentamientos`
```sql
CREATE TABLE enfrentamientos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    temporada_id UUID REFERENCES temporadas(id) NOT NULL,
    atleta_local UUID REFERENCES atletas(id) NOT NULL,
    atleta_visitante UUID REFERENCES atletas(id) NOT NULL,
    fecha_combate TIMESTAMP WITH TIME ZONE NOT NULL,
    jornada INTEGER NOT NULL,
    resultado TEXT CHECK (resultado IN ('local', 'visitante', 'empate', 'pendiente')) DEFAULT 'pendiente',
    puntos_local INTEGER DEFAULT 0,
    puntos_visitante INTEGER DEFAULT 0,
    estado TEXT CHECK (estado IN ('programado', 'en_vivo', 'finalizado', 'suspendido', 'cancelado')) DEFAULT 'programado',
    arbitro_principal UUID REFERENCES arbitros(id),
    tatami INTEGER,
    observaciones TEXT,
    combate_id UUID REFERENCES combates(id), -- Referencia al combate real
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CHECK (atleta_local != atleta_visitante)
);
```

#### `historico_champions`
```sql
CREATE TABLE historico_champions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    temporada_id UUID REFERENCES temporadas(id) NOT NULL,
    atleta_id UUID REFERENCES atletas(id) NOT NULL,
    posicion_final INTEGER NOT NULL,
    titulo TEXT, -- "Campeón", "Subcampeón", "Tercer Lugar"
    medalla TEXT CHECK (medalla IN ('oro', 'plata', 'bronce', 'participacion')),
    puntos_totales INTEGER DEFAULT 0,
    partidos_totales INTEGER DEFAULT 0,
    victorias_totales INTEGER DEFAULT 0,
    mejor_combate_id UUID REFERENCES combates(id),
    estadisticas_json JSONB, -- Estadísticas detalladas en JSON
    fecha_coronacion DATE,
    observaciones TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## ⚔️ Sistema de Simulación de Combates

### **2. Reglas y Técnicas de Karate**

#### `reglas_karate`
```sql
CREATE TABLE reglas_karate (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    modalidad TEXT CHECK (modalidad IN ('kumite', 'kata')) NOT NULL,
    categoria TEXT, -- "senior", "junior", "cadete"
    duracion_combate INTEGER NOT NULL, -- En segundos
    duracion_round INTEGER, -- Para combates con rounds
    numero_rounds INTEGER DEFAULT 1,
    puntos_yuko INTEGER DEFAULT 1, -- Técnica básica
    puntos_wazari INTEGER DEFAULT 2, -- Técnica media
    puntos_ippon INTEGER DEFAULT 3, -- Técnica perfecta
    diferencia_victoria INTEGER DEFAULT 8, -- Diferencia para victoria automática
    penalizacion_chukoku INTEGER DEFAULT 0, -- Advertencia
    penalizacion_keikoku INTEGER DEFAULT 1, -- Penalización menor
    penalizacion_hansoku_chui INTEGER DEFAULT 2, -- Penalización mayor
    penalizacion_hansoku INTEGER DEFAULT 3, -- Descalificación
    criterios_victoria TEXT[], -- Criterios para determinar ganador
    tiempo_descanso INTEGER DEFAULT 60, -- Entre rounds
    es_activa BOOLEAN DEFAULT TRUE,
    version_reglas TEXT DEFAULT 'WKF 2023',
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `tecnicas_karate`
```sql
CREATE TABLE tecnicas_karate (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre TEXT NOT NULL,
    nombre_japones TEXT,
    tipo TEXT CHECK (tipo IN ('puño', 'patada', 'bloqueo', 'barrido', 'proyeccion')) NOT NULL,
    zona_contacto TEXT CHECK (zona_contacto IN ('cabeza', 'torso', 'piernas', 'brazos')) NOT NULL,
    puntos_base INTEGER DEFAULT 1,
    dificultad INTEGER CHECK (dificultad BETWEEN 1 AND 5) DEFAULT 1,
    requiere_distancia TEXT CHECK (requiere_distancia IN ('corta', 'media', 'larga')) DEFAULT 'media',
    es_valida_competencia BOOLEAN DEFAULT TRUE,
    descripcion TEXT,
    video_demostracion TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### **3. Simulación en Tiempo Real**

#### `combate_simulacion`
```sql
CREATE TABLE combate_simulacion (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    combate_id UUID REFERENCES combates(id) NOT NULL,
    reglas_id UUID REFERENCES reglas_karate(id) NOT NULL,
    tiempo_total INTEGER NOT NULL, -- Duración total en segundos
    tiempo_transcurrido INTEGER DEFAULT 0,
    tiempo_activo INTEGER DEFAULT 0, -- Tiempo real de combate
    tiempo_pausado INTEGER DEFAULT 0,
    round_actual INTEGER DEFAULT 1,
    estado_simulacion TEXT CHECK (estado_simulacion IN ('iniciado', 'en_pausa', 'finalizado', 'suspendido')) DEFAULT 'iniciado',
    puntos_atleta1 INTEGER DEFAULT 0,
    puntos_atleta2 INTEGER DEFAULT 0,
    penalizaciones_atleta1 INTEGER DEFAULT 0,
    penalizaciones_atleta2 INTEGER DEFAULT 0,
    ganador_id UUID REFERENCES atletas(id),
    tipo_victoria TEXT CHECK (tipo_victoria IN ('puntos', 'diferencia', 'penalizacion', 'abandono', 'descalificacion')),
    arbitro_controlador UUID REFERENCES usuarios(id) NOT NULL,
    fecha_inicio TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_fin TIMESTAMP WITH TIME ZONE,
    observaciones TEXT
);
```

#### `acciones_combate`
```sql
CREATE TABLE acciones_combate (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    combate_simulacion_id UUID REFERENCES combate_simulacion(id) NOT NULL,
    atleta_id UUID REFERENCES atletas(id) NOT NULL,
    tipo_accion TEXT CHECK (tipo_accion IN ('tecnica', 'penalizacion', 'pausa', 'reanudacion', 'tiempo')) NOT NULL,
    tecnica_id UUID REFERENCES tecnicas_karate(id),
    puntos_otorgados INTEGER DEFAULT 0,
    tiempo_accion INTEGER NOT NULL, -- Segundo en que ocurrió la acción
    round_accion INTEGER DEFAULT 1,
    zona_impacto TEXT,
    efectividad INTEGER CHECK (efectividad BETWEEN 1 AND 5), -- Calidad de la técnica
    validada_por UUID REFERENCES usuarios(id) NOT NULL, -- Árbitro que validó
    confirmada BOOLEAN DEFAULT FALSE,
    observaciones TEXT,
    video_replay TEXT, -- URL del video de la acción
    fecha_accion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `penalizaciones_combate`
```sql
CREATE TABLE penalizaciones_combate (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    combate_simulacion_id UUID REFERENCES combate_simulacion(id) NOT NULL,
    atleta_id UUID REFERENCES atletas(id) NOT NULL,
    tipo_penalizacion TEXT CHECK (tipo_penalizacion IN ('chukoku', 'keikoku', 'hansoku_chui', 'hansoku')) NOT NULL,
    razon TEXT NOT NULL, -- "contacto excesivo", "salida del área", "conducta antideportiva"
    descripcion TEXT,
    tiempo_penalizacion INTEGER NOT NULL,
    round_penalizacion INTEGER DEFAULT 1,
    puntos_descontados INTEGER DEFAULT 0,
    arbitro_id UUID REFERENCES usuarios(id) NOT NULL,
    es_acumulativa BOOLEAN DEFAULT TRUE,
    revocada BOOLEAN DEFAULT FALSE,
    fecha_penalizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `marcador_tiempo_real`
```sql
CREATE TABLE marcador_tiempo_real (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    combate_simulacion_id UUID REFERENCES combate_simulacion(id) NOT NULL,
    minuto INTEGER NOT NULL,
    segundo INTEGER NOT NULL,
    puntos_atleta1 INTEGER DEFAULT 0,
    puntos_atleta2 INTEGER DEFAULT 0,
    penalizaciones_atleta1 INTEGER DEFAULT 0,
    penalizaciones_atleta2 INTEGER DEFAULT 0,
    estado_combate TEXT CHECK (estado_combate IN ('activo', 'pausado', 'finalizado')) DEFAULT 'activo',
    ultima_accion TEXT,
    ventaja TEXT, -- "atleta1", "atleta2", "empate"
    timestamp_real TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(combate_simulacion_id, minuto, segundo)
);
```

## 📋 Estructura Detallada de Tablas

### 1. **Gestión de Usuarios**

#### `usuarios` (Tabla Central)
```sql
CREATE TABLE usuarios (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    nombre_completo TEXT NOT NULL,
    rol TEXT CHECK (rol IN ('super_admin', 'admin', 'entrenador', 'arbitro', 'atleta')) NOT NULL,
    estado TEXT CHECK (estado IN ('activo', 'inactivo', 'pendiente', 'suspendido')) DEFAULT 'pendiente',
    es_administrador BOOLEAN DEFAULT FALSE,
    creado_por UUID REFERENCES usuarios(id), -- Admin que registró al usuario
    aprobado_por UUID REFERENCES usuarios(id), -- Admin que aprobó el registro
    fecha_aprobacion TIMESTAMP WITH TIME ZONE,
    foto_perfil TEXT,
    telefono TEXT,
    direccion TEXT,
    ciudad TEXT,
    fecha_nacimiento DATE,
    documento_identidad TEXT,
    observaciones TEXT, -- Notas del administrador
    ultimo_acceso TIMESTAMP WITH TIME ZONE,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `atletas`
```sql
CREATE TABLE atletas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID REFERENCES usuarios(id) NOT NULL,
    genero TEXT CHECK (genero IN ('masculino', 'femenino')) NOT NULL,
    peso DECIMAL(5,2),
    altura DECIMAL(5,2),
    nivel_cinturon TEXT CHECK (nivel_cinturon IN ('blanco', 'amarillo', 'naranja', 'verde', 'azul', 'marron', 'negro')) NOT NULL,
    nivel_dan INTEGER DEFAULT 0,
    dojo_id UUID REFERENCES dojos(id),
    entrenador_id UUID REFERENCES usuarios(id),
    categoria_edad TEXT, -- Calculada automáticamente
    categoria_peso TEXT, -- Calculada automáticamente
    estado_medico TEXT CHECK (estado_medico IN ('apto', 'no_apto', 'revision_pendiente')) DEFAULT 'revision_pendiente',
    certificado_medico_url TEXT,
    fecha_ultimo_examen DATE,
    contacto_emergencia TEXT,
    telefono_emergencia TEXT,
    registrado_por UUID REFERENCES usuarios(id) NOT NULL, -- Admin que lo registró
    aprobado_por UUID REFERENCES usuarios(id), -- Admin que aprobó
    observaciones_admin TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `dojos`
```sql
CREATE TABLE dojos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    direccion TEXT NOT NULL,
    ciudad TEXT NOT NULL,
    telefono TEXT,
    email TEXT,
    instructor_principal_id UUID REFERENCES usuarios(id),
    estado TEXT CHECK (estado IN ('activo', 'inactivo', 'suspendido')) DEFAULT 'activo',
    capacidad_maxima INTEGER,
    horarios_atencion TEXT,
    servicios_ofrecidos TEXT[],
    creado_por UUID REFERENCES usuarios(id) NOT NULL, -- Admin que creó el dojo
    fecha_fundacion DATE,
    licencia_funcionamiento TEXT,
    observaciones_admin TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `entrenadores`
```sql
CREATE TABLE entrenadores (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID REFERENCES usuarios(id) NOT NULL,
    dojo_id UUID REFERENCES dojos(id),
    nivel_certificacion TEXT NOT NULL,
    numero_licencia TEXT UNIQUE,
    años_experiencia INTEGER DEFAULT 0,
    especialidad TEXT CHECK (especialidad IN ('kata', 'kumite', 'ambos')) DEFAULT 'ambos',
    fecha_certificacion DATE,
    fecha_vencimiento_cert DATE,
    institucion_certificadora TEXT,
    grados_puede_enseñar TEXT[],
    estado_certificacion TEXT CHECK (estado_certificacion IN ('vigente', 'vencida', 'suspendida')) DEFAULT 'vigente',
    asignado_por UUID REFERENCES usuarios(id) NOT NULL, -- Admin que lo asignó
    evaluado_por UUID REFERENCES usuarios(id), -- Admin que evaluó sus credenciales
    observaciones_admin TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `arbitros`
```sql
CREATE TABLE arbitros (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID REFERENCES usuarios(id) NOT NULL,
    nivel_arbitraje TEXT CHECK (nivel_arbitraje IN ('regional', 'nacional', 'internacional')) NOT NULL,
    licencia_numero TEXT UNIQUE NOT NULL,
    fecha_licencia DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    especialidad TEXT CHECK (especialidad IN ('kata', 'kumite', 'ambos')) DEFAULT 'ambos',
    federacion_certificadora TEXT,
    cursos_completados TEXT[],
    evaluaciones_realizadas INTEGER DEFAULT 0,
    calificacion_promedio DECIMAL(3,2),
    disponibilidad_horaria TEXT,
    estado_licencia TEXT CHECK (estado_licencia IN ('vigente', 'vencida', 'suspendida', 'revocada')) DEFAULT 'vigente',
    asignado_por UUID REFERENCES usuarios(id) NOT NULL, -- Admin que lo registró
    evaluado_por UUID REFERENCES usuarios(id), -- Admin que validó credenciales
    observaciones_admin TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 2. **Sistema de Competencias**

#### `competencias`
```sql
CREATE TABLE competencias (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    ubicacion TEXT NOT NULL,
    direccion_completa TEXT,
    tipo TEXT CHECK (tipo IN ('local', 'regional', 'nacional', 'internacional')) DEFAULT 'local',
    modalidades TEXT[] DEFAULT ARRAY['kumite', 'kata'], -- Modalidades permitidas
    estado TEXT CHECK (estado IN ('planificada', 'inscripciones_abiertas', 'inscripciones_cerradas', 'en_progreso', 'completada', 'cancelada')) DEFAULT 'planificada',
    costo_inscripcion DECIMAL(10,2) DEFAULT 0,
    limite_participantes INTEGER,
    participantes_actuales INTEGER DEFAULT 0,
    requisitos_participacion TEXT,
    premios_descripcion TEXT,
    patrocinadores TEXT[],
    contacto_organizador TEXT,
    telefono_contacto TEXT,
    email_contacto TEXT,
    reglamento_url TEXT,
    creado_por UUID REFERENCES usuarios(id) NOT NULL, -- Admin creador
    supervisado_por UUID REFERENCES usuarios(id), -- Admin supervisor
    observaciones_admin TEXT, del administrador
    ultimo_acceso TIMESTAMP WITH TIME ZONE,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `atletas`
```sql
CREATE TABLE atletas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID REFERENCES usuarios(id) NOT NULL,
    genero TEXT CHECK (genero IN ('masculino', 'femenino')) NOT NULL,
    peso DECIMAL(5,2),
    altura DECIMAL(5,2),
    nivel_cinturon TEXT CHECK (nivel_cinturon IN ('blanco', 'amarillo', 'naranja', 'verde', 'azul', 'marron', 'negro')) NOT NULL,
    nivel_dan INTEGER DEFAULT 0,
    dojo_id UUID REFERENCES dojos(id),
    entrenador_id UUID REFERENCES usuarios(id),
    categoria_edad TEXT, -- Calculada automáticamente
    categoria_peso TEXT, -- Calculada automáticamente
    estado_medico TEXT CHECK (estado_medico IN ('apto', 'no_apto', 'revision_pendiente')) DEFAULT 'revision_pendiente',
    certificado_medico_url TEXT,
    fecha_ultimo_examen DATE,
    contacto_emergencia TEXT,
    telefono_emergencia TEXT,
    registrado_por UUID REFERENCES usuarios(id) NOT NULL, -- Admin que lo registró
    aprobado_por UUID REFERENCES usuarios(id), -- Admin que aprobó
    observaciones_admin TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `dojos`
```sql
CREATE TABLE dojos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    direccion TEXT NOT NULL,
    ciudad TEXT NOT NULL,
    telefono TEXT,
    email TEXT,
    instructor_principal_id UUID REFERENCES usuarios(id),
    estado TEXT CHECK (estado IN ('activo', 'inactivo', 'suspendido')) DEFAULT 'activo',
    capacidad_maxima INTEGER,
    horarios_atencion TEXT,
    servicios_ofrecidos TEXT[],
    creado_por UUID REFERENCES usuarios(id) NOT NULL, -- Admin que creó el dojo
    fecha_fundacion DATE,
    licencia_funcionamiento TEXT,
    observaciones_admin TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `entrenadores`
```sql
CREATE TABLE entrenadores (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID REFERENCES usuarios(id) NOT NULL,
    dojo_id UUID REFERENCES dojos(id),
    nivel_certificacion TEXT NOT NULL,
    numero_licencia TEXT UNIQUE,
    años_experiencia INTEGER DEFAULT 0,
    especialidad TEXT CHECK (especialidad IN ('kata', 'kumite', 'ambos')) DEFAULT 'ambos',
    fecha_certificacion DATE,
    fecha_vencimiento_cert DATE,
    institucion_certificadora TEXT,
    grados_puede_enseñar TEXT[],
    estado_certificacion TEXT CHECK (estado_certificacion IN ('vigente', 'vencida', 'suspendida')) DEFAULT 'vigente',
    asignado_por UUID REFERENCES usuarios(id) NOT NULL, -- Admin que lo asignó
    evaluado_por UUID REFERENCES usuarios(id), -- Admin que evaluó sus credenciales
    observaciones_admin TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `arbitros`
```sql
CREATE TABLE arbitros (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID REFERENCES usuarios(id) NOT NULL,
    nivel_arbitraje TEXT CHECK (nivel_arbitraje IN ('regional', 'nacional', 'internacional')) NOT NULL,
    licencia_numero TEXT UNIQUE NOT NULL,
    fecha_licencia DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    especialidad TEXT CHECK (especialidad IN ('kata', 'kumite', 'ambos')) DEFAULT 'ambos',
    federacion_certificadora TEXT,
    cursos_completados TEXT[],
    evaluaciones_realizadas INTEGER DEFAULT 0,
    calificacion_promedio DECIMAL(3,2),
    disponibilidad_horaria TEXT,
    estado_licencia TEXT CHECK (estado_licencia IN ('vigente', 'vencida', 'suspendida', 'revocada')) DEFAULT 'vigente',
    asignado_por UUID REFERENCES usuarios(id) NOT NULL, -- Admin que lo registró
    evaluado_por UUID REFERENCES usuarios(id), -- Admin que validó credenciales
    observaciones_admin TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 2. **Sistema de Competencias**

#### `competencias`
```sql
CREATE TABLE competencias (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    ubicacion TEXT NOT NULL,
    direccion_completa TEXT,
    tipo TEXT CHECK (tipo IN ('local', 'regional', 'nacional', 'internacional')) DEFAULT 'local',
    modalidades TEXT[] DEFAULT ARRAY['kumite', 'kata'], -- Modalidades permitidas
    estado TEXT CHECK (estado IN ('planificada', 'inscripciones_abiertas', 'inscripciones_cerradas', 'en_progreso', 'completada', 'cancelada')) DEFAULT 'planificada',
    costo_inscripcion DECIMAL(10,2) DEFAULT 0,
    limite_participantes INTEGER,
    participantes_actuales INTEGER DEFAULT 0,
    requisitos_participacion TEXT,
    premios_descripcion TEXT,
    patrocinadores TEXT[],
    contacto_organizador TEXT,
    telefono_contacto TEXT,
    email_contacto TEXT,
    reglamento_url TEXT,
    creado_por UUID REFERENCES usuarios(id) NOT NULL, -- Admin creador
    supervisado_por UUID REFERENCES usuarios(id), -- Admin supervisor
    observaciones_admin TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `categorias`
```sql
CREATE TABLE categorias (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    competencia_id UUID REFERENCES competencias(id) NOT NULL,
    nombre TEXT NOT NULL,
    genero TEXT CHECK (genero IN ('masculino', 'femenino', 'mixto')) NOT NULL,
    edad_minima INTEGER,
    edad_maxima INTEGER,
    peso_minimo DECIMAL(5,2),
    peso_maximo DECIMAL(5,2),
    cinturones_permitidos TEXT[],
    modalidad TEXT CHECK (modalidad IN ('kata', 'kumite', 'ambos')) NOT NULL,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `inscripciones`
```sql
CREATE TABLE inscripciones (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    atleta_id UUID REFERENCES atletas(id) NOT NULL,
    categoria_id UUID REFERENCES categorias(id) NOT NULL,
    competencia_id UUID REFERENCES competencias(id) NOT NULL,
    fecha_inscripcion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    estado TEXT CHECK (estado IN ('pendiente', 'confirmada', 'cancelada')) DEFAULT 'pendiente',
    costo_inscripcion DECIMAL(10,2) DEFAULT 0,
    pagado BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(atleta_id, categoria_id, competencia_id)
);
```

### 3. **Sistema de Combates**

#### `sorteos`
```sql
CREATE TABLE sorteos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    competencia_id UUID REFERENCES competencias(id) NOT NULL,
    categoria_id UUID REFERENCES categorias(id) NOT NULL,
    tipo_sorteo TEXT CHECK (tipo_sorteo IN ('eliminacion_directa', 'round_robin', 'suizo')) DEFAULT 'eliminacion_directa',
    fecha_sorteo TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    estado TEXT CHECK (estado IN ('pendiente', 'realizado', 'modificado')) DEFAULT 'pendiente',
    realizado_por UUID REFERENCES perfiles(id) NOT NULL,
    observaciones TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `brackets`
```sql
CREATE TABLE brackets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    sorteo_id UUID REFERENCES sorteos(id) NOT NULL,
    atleta_id UUID REFERENCES atletas(id) NOT NULL,
    posicion_inicial INTEGER NOT NULL,
    ronda_actual TEXT DEFAULT 'primera',
    estado TEXT CHECK (estado IN ('activo', 'eliminado', 'bye')) DEFAULT 'activo',
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `combates`
```sql
CREATE TABLE combates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    competencia_id UUID REFERENCES competencias(id) NOT NULL,
    categoria_id UUID REFERENCES categorias(id) NOT NULL,
    atleta1_id UUID REFERENCES atletas(id) NOT NULL,
    atleta2_id UUID REFERENCES atletas(id) NOT NULL,
    ronda TEXT NOT NULL,
    tatami INTEGER,
    hora_programada TIMESTAMP WITH TIME ZONE,
    estado TEXT CHECK (estado IN ('programado', 'en_progreso', 'completado', 'cancelado')) DEFAULT 'programado',
    ganador_id UUID REFERENCES atletas(id),
    puntos_atleta1 INTEGER DEFAULT 0,
    puntos_atleta2 INTEGER DEFAULT 0,
    arbitro_principal_id UUID REFERENCES arbitros(id),
    arbitro_asistente1_id UUID REFERENCES arbitros(id),
    arbitro_asistente2_id UUID REFERENCES arbitros(id),
    observaciones TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CHECK (atleta1_id != atleta2_id)
);
```

#### `puntuaciones`
```sql
CREATE TABLE puntuaciones (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    combate_id UUID REFERENCES combates(id) NOT NULL,
    atleta_id UUID REFERENCES atletas(id) NOT NULL,
    puntos INTEGER DEFAULT 0,
    penalizaciones INTEGER DEFAULT 0,
    tecnica_utilizada TEXT,
    tiempo_marca TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    arbitro_id UUID REFERENCES arbitros(id) NOT NULL,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 4. **Sistema de Rankings**

#### `clasificaciones`
```sql
CREATE TABLE clasificaciones (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    atleta_id UUID REFERENCES atletas(id) NOT NULL,
    categoria_id UUID REFERENCES categorias(id) NOT NULL,
    temporada TEXT NOT NULL,
    puntos_totales INTEGER DEFAULT 0,
    combates_ganados INTEGER DEFAULT 0,
    combates_perdidos INTEGER DEFAULT 0,
    posicion INTEGER,
    ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(atleta_id, categoria_id, temporada)
);
```

#### `estadisticas_atletas`
```sql
CREATE TABLE estadisticas_atletas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    atleta_id UUID REFERENCES atletas(id) NOT NULL,
    temporada TEXT NOT NULL,
    total_combates INTEGER DEFAULT 0,
    victorias INTEGER DEFAULT 0,
    derrotas INTEGER DEFAULT 0,
    empates INTEGER DEFAULT 0,
    puntos_anotados INTEGER DEFAULT 0,
    puntos_recibidos INTEGER DEFAULT 0,
    kos_realizados INTEGER DEFAULT 0,
    kos_recibidos INTEGER DEFAULT 0,
    porcentaje_victoria DECIMAL(5,2) DEFAULT 0,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(atleta_id, temporada)
);
```

#### `historial_competencias`
```sql
CREATE TABLE historial_competencias (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    atleta_id UUID REFERENCES atletas(id) NOT NULL,
    competencia_id UUID REFERENCES competencias(id) NOT NULL,
    categoria_id UUID REFERENCES categorias(id) NOT NULL,
    posicion_final INTEGER,
    medalla TEXT CHECK (medalla IN ('oro', 'plata', 'bronce', 'participacion')),
    puntos_obtenidos INTEGER DEFAULT 0,
    observaciones TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(atleta_id, competencia_id, categoria_id)
);
```

## 🔐 Políticas de Seguridad (RLS) Reestructuradas

### **Niveles de Acceso Redefinidos:**

#### **🔴 SUPER ADMINISTRADOR**
- Acceso completo a todas las tablas
- Puede crear otros administradores
- Control total del sistema

#### **🟠 ADMINISTRADOR**
- Gestión completa de usuarios (excepto otros admins)
- Creación y gestión de dojos
- Gestión completa de competencias
- Supervisión de todos los procesos

#### **🟡 ENTRENADOR - ACCESO AMPLIADO**
- ✏️ **Gestión completa de su perfil profesional**
- 👥 **Agregar/gestionar atletas a su equipo**
- 📊 **Crear y editar planes de entrenamiento**
- 📈 **Acceso completo a estadísticas de sus atletas**
- 📝 **Registrar evaluaciones y progreso**
- 🏆 **Inscribir atletas en competencias**
- 📅 **Gestionar calendario de entrenamientos**
- 💬 **Comunicación directa con atletas**

#### **🟢 ÁRBITRO - ACCESO AMPLIADO**
- ✏️ **Gestión completa de su perfil profesional**
- ⚖️ **Actualizar certificaciones y licencias**
- 🥋 **Registro detallado de combates arbitrados**
- 📊 **Acceso a estadísticas de arbitraje**
- 🕐 **Gestionar disponibilidad horaria**
- 📝 **Reportes post-combate**
- 🎯 **Evaluación de rendimiento propio**

#### **🔵 ATLETA - ACCESO AMPLIADO**
- ✏️ **Gestión completa de su perfil deportivo**
- 🏥 **Subir/actualizar certificados médicos**
- 📈 **Seguimiento detallado de progreso**
- 🏆 **Solicitar inscripciones a competencias**
- 📊 **Acceso completo a sus estadísticas**
- 📅 **Ver calendario de entrenamientos**
- 🎯 **Establecer metas personales**
- 💬 **Comunicación con su entrenador**

## 👥 Nuevas Tablas para Gestión de Equipos

### **Gestión de Equipos de Entrenadores**

#### `equipos_entrenador`
```sql
CREATE TABLE equipos_entrenador (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    entrenador_id UUID REFERENCES entrenadores(id) NOT NULL,
    nombre_equipo TEXT NOT NULL,
    descripcion TEXT,
    dojo_id UUID REFERENCES dojos(id),
    categoria_principal TEXT, -- "juvenil", "senior", "mixto"
    especialidad TEXT CHECK (especialidad IN ('kata', 'kumite', 'ambos')) DEFAULT 'ambos',
    maximo_atletas INTEGER DEFAULT 20,
    atletas_actuales INTEGER DEFAULT 0,
    estado TEXT CHECK (estado IN ('activo', 'inactivo', 'suspendido')) DEFAULT 'activo',
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `atletas_equipo`
```sql
CREATE TABLE atletas_equipo (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    equipo_id UUID REFERENCES equipos_entrenador(id) NOT NULL,
    atleta_id UUID REFERENCES atletas(id) NOT NULL,
    fecha_ingreso DATE DEFAULT CURRENT_DATE,
    estado_en_equipo TEXT CHECK (estado_en_equipo IN ('activo', 'inactivo', 'lesionado', 'suspendido')) DEFAULT 'activo',
    posicion_equipo TEXT, -- "capitán", "subcapitán", "miembro"
    notas_entrenador TEXT,
    objetivos_personales TEXT,
    fecha_ultima_evaluacion DATE,
    calificacion_actual INTEGER CHECK (calificacion_actual BETWEEN 1 AND 10),
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(equipo_id, atleta_id)
);
```

### **Planes de Entrenamiento**

#### `planes_entrenamiento`
```sql
CREATE TABLE planes_entrenamiento (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    entrenador_id UUID REFERENCES entrenadores(id) NOT NULL,
    nombre_plan TEXT NOT NULL,
    descripcion TEXT,
    tipo_plan TEXT CHECK (tipo_plan IN ('individual', 'grupal', 'competencia', 'tecnico', 'fisico')) NOT NULL,
    duracion_semanas INTEGER DEFAULT 4,
    nivel_dificultad INTEGER CHECK (nivel_dificultad BETWEEN 1 AND 5) DEFAULT 1,
    objetivos TEXT[],
    ejercicios_incluidos TEXT[],
    material_necesario TEXT[],
    estado TEXT CHECK (estado IN ('borrador', 'activo', 'completado', 'archivado')) DEFAULT 'borrador',
    fecha_inicio DATE,
    fecha_fin DATE,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `asignaciones_plan`
```sql
CREATE TABLE asignaciones_plan (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    plan_id UUID REFERENCES planes_entrenamiento(id) NOT NULL,
    atleta_id UUID REFERENCES atletas(id) NOT NULL,
    fecha_asignacion DATE DEFAULT CURRENT_DATE,
    estado_progreso TEXT CHECK (estado_progreso IN ('no_iniciado', 'en_progreso', 'completado', 'pausado')) DEFAULT 'no_iniciado',
    porcentaje_completado INTEGER DEFAULT 0 CHECK (porcentaje_completado BETWEEN 0 AND 100),
    notas_progreso TEXT,
    evaluacion_final INTEGER CHECK (evaluacion_final BETWEEN 1 AND 10),
    comentarios_atleta TEXT,
    fecha_inicio_real DATE,
    fecha_completado DATE,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(plan_id, atleta_id)
);
```

### **Evaluaciones y Seguimiento**

#### `evaluaciones_atleta`
```sql
CREATE TABLE evaluaciones_atleta (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    atleta_id UUID REFERENCES atletas(id) NOT NULL,
    evaluador_id UUID REFERENCES usuarios(id) NOT NULL, -- Entrenador o admin
    tipo_evaluacion TEXT CHECK (tipo_evaluacion IN ('tecnica', 'fisica', 'mental', 'competitiva', 'general')) NOT NULL,
    fecha_evaluacion DATE DEFAULT CURRENT_DATE,
    
    -- Puntuaciones específicas (1-10)
    tecnica_puntuacion INTEGER CHECK (tecnica_puntuacion BETWEEN 1 AND 10),
    fuerza_puntuacion INTEGER CHECK (fuerza_puntuacion BETWEEN 1 AND 10),
    velocidad_puntuacion INTEGER CHECK (velocidad_puntuacion BETWEEN 1 AND 10),
    flexibilidad_puntuacion INTEGER CHECK (flexibilidad_puntuacion BETWEEN 1 AND 10),
    resistencia_puntuacion INTEGER CHECK (resistencia_puntuacion BETWEEN 1 AND 10),
    concentracion_puntuacion INTEGER CHECK (concentracion_puntuacion BETWEEN 1 AND 10),
    disciplina_puntuacion INTEGER CHECK (disciplina_puntuacion BETWEEN 1 AND 10),
    
    puntuacion_general DECIMAL(3,1) CHECK (puntuacion_general BETWEEN 1.0 AND 10.0),
    
    -- Observaciones
    fortalezas TEXT,
    areas_mejora TEXT,
    recomendaciones TEXT,
    objetivos_proximos TEXT,
    
    -- Comparación con evaluación anterior
    mejora_desde_anterior BOOLEAN,
    comentarios_progreso TEXT,
    
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### **Comunicación Entrenador-Atleta**

#### `mensajes_entrenamiento`
```sql
CREATE TABLE mensajes_entrenamiento (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    remitente_id UUID REFERENCES usuarios(id) NOT NULL,
    destinatario_id UUID REFERENCES usuarios(id) NOT NULL,
    asunto TEXT NOT NULL,
    mensaje TEXT NOT NULL,
    tipo_mensaje TEXT CHECK (tipo_mensaje IN ('general', 'evaluacion', 'plan_entrenamiento', 'competencia', 'motivacional')) DEFAULT 'general',
    prioridad TEXT CHECK (prioridad IN ('baja', 'media', 'alta', 'urgente')) DEFAULT 'media',
    
    -- Archivos adjuntos
    archivos_adjuntos TEXT[], -- URLs de archivos
    
    -- Estado del mensaje
    leido BOOLEAN DEFAULT FALSE,
    fecha_lectura TIMESTAMP WITH TIME ZONE,
    respondido BOOLEAN DEFAULT FALSE,
    mensaje_padre_id UUID REFERENCES mensajes_entrenamiento(id), -- Para hilos de conversación
    
    -- Metadata
    es_automatico BOOLEAN DEFAULT FALSE, -- Si fue generado automáticamente
    plan_relacionado UUID REFERENCES planes_entrenamiento(id),
    evaluacion_relacionada UUID REFERENCES evaluaciones_atleta(id),
    
    fecha_envio TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_expiracion TIMESTAMP WITH TIME ZONE -- Para mensajes temporales
);
```

### **Gestión de Metas Personales (Atletas)**

#### `metas_atleta`
```sql
CREATE TABLE metas_atleta (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    atleta_id UUID REFERENCES atletas(id) NOT NULL,
    titulo_meta TEXT NOT NULL,
    descripcion TEXT,
    tipo_meta TEXT CHECK (tipo_meta IN ('tecnica', 'competitiva', 'fisica', 'personal', 'academica')) NOT NULL,
    
    -- Fechas
    fecha_inicio DATE DEFAULT CURRENT_DATE,
    fecha_objetivo DATE NOT NULL,
    fecha_completado DATE,
    
    -- Progreso
    estado_meta TEXT CHECK (estado_meta IN ('activa', 'en_progreso', 'completada', 'pausada', 'cancelada')) DEFAULT 'activa',
    porcentaje_progreso INTEGER DEFAULT 0 CHECK (porcentaje_progreso BETWEEN 0 AND 100),
    
    -- Métricas específicas
    valor_inicial DECIMAL(10,2), -- Ej: peso actual, tiempo actual
    valor_objetivo DECIMAL(10,2), -- Ej: peso objetivo, tiempo objetivo
    valor_actual DECIMAL(10,2), -- Progreso actual
    unidad_medida TEXT, -- "kg", "segundos", "puntos", etc.
    
    -- Seguimiento
    notas_progreso TEXT,
    obstaculos_encontrados TEXT,
    estrategias_utilizadas TEXT,
    
    -- Aprobación del entrenador
    aprobada_por_entrenador BOOLEAN DEFAULT FALSE,
    comentarios_entrenador TEXT,
    fecha_aprobacion TIMESTAMP WITH TIME ZONE,
    
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### **Políticas RLS Mejoradas:**
```sql
-- TABLA USUARIOS: Usuarios pueden editar su propio perfil
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_full_access" ON usuarios
    FOR ALL USING (auth.jwt() ->> 'role' IN ('super_admin', 'admin'));

CREATE POLICY "users_own_profile" ON usuarios
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "users_edit_own_profile" ON usuarios
    FOR UPDATE USING (auth.uid() = id);

-- TABLA ATLETAS: Atletas pueden editar sus datos, entrenadores ven/editan sus atletas
ALTER TABLE atletas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "athletes_own_data" ON atletas
    FOR ALL USING (
        usuario_id = auth.uid() OR
        entrenador_id = auth.uid() OR 
        auth.jwt() ->> 'role' IN ('super_admin', 'admin')
    );

-- TABLA ENTRENADORES: Entrenadores gestionan sus datos
ALTER TABLE entrenadores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "trainers_own_data" ON entrenadores
    FOR ALL USING (
        usuario_id = auth.uid() OR
        auth.jwt() ->> 'role' IN ('super_admin', 'admin')
    );

-- TABLA ÁRBITROS: Árbitros gestionan sus datos
ALTER TABLE arbitros ENABLE ROW LEVEL SECURITY;

CREATE POLICY "referees_own_data" ON arbitros
    FOR ALL USING (
        usuario_id = auth.uid() OR
        auth.jwt() ->> 'role' IN ('super_admin', 'admin')
    );

-- TABLA EQUIPOS: Entrenadores gestionan sus equipos
ALTER TABLE equipos_entrenador ENABLE ROW LEVEL SECURITY;

CREATE POLICY "trainers_manage_teams" ON equipos_entrenador
    FOR ALL USING (
        entrenador_id IN (
            SELECT id FROM entrenadores WHERE usuario_id = auth.uid()
        ) OR
        auth.jwt() ->> 'role' IN ('super_admin', 'admin')
    );

-- TABLA EVALUACIONES: Entrenadores evalúan, atletas ven sus evaluaciones
ALTER TABLE evaluaciones_atleta ENABLE ROW LEVEL SECURITY;

CREATE POLICY "evaluations_access" ON evaluaciones_atleta
    FOR SELECT USING (
        atleta_id IN (SELECT id FROM atletas WHERE usuario_id = auth.uid()) OR
        evaluador_id = auth.uid() OR
        auth.jwt() ->> 'role' IN ('super_admin', 'admin')
    );

CREATE POLICY "trainers_create_evaluations" ON evaluaciones_atleta
    FOR INSERT WITH CHECK (
        evaluador_id = auth.uid() AND
        auth.jwt() ->> 'role' IN ('entrenador', 'super_admin', 'admin')
    );

-- TABLA METAS: Atletas gestionan sus metas, entrenadores las ven
ALTER TABLE metas_atleta ENABLE ROW LEVEL SECURITY;

CREATE POLICY "athletes_manage_goals" ON metas_atleta
    FOR ALL USING (
        atleta_id IN (SELECT id FROM atletas WHERE usuario_id = auth.uid()) OR
        atleta_id IN (
            SELECT a.id FROM atletas a 
            JOIN entrenadores e ON a.entrenador_id = e.usuario_id 
            WHERE e.usuario_id = auth.uid()
        ) OR
        auth.jwt() ->> 'role' IN ('super_admin', 'admin')
    );
```

## 🔧 Funciones para Gestión de Equipos

### **Función para Agregar Atleta al Equipo**
```sql
CREATE OR REPLACE FUNCTION agregar_atleta_equipo(
    p_entrenador_id UUID,
    p_atleta_id UUID,
    p_equipo_id UUID DEFAULT NULL,
    p_notas TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    equipo_id_final UUID;
    equipo_principal_id UUID;
BEGIN
    -- Verificar que el entrenador existe
    IF NOT EXISTS (SELECT 1 FROM entrenadores WHERE usuario_id = p_entrenador_id) THEN
        RAISE EXCEPTION 'Entrenador no encontrado';
    END IF;
    
    -- Si no se especifica equipo, usar el equipo principal del entrenador
    IF p_equipo_id IS NULL THEN
        SELECT id INTO equipo_principal_id 
        FROM equipos_entrenador 
        WHERE entrenador_id = (SELECT id FROM entrenadores WHERE usuario_id = p_entrenador_id)
        AND estado = 'activo'
        ORDER BY fecha_creacion ASC
        LIMIT 1;
        
        -- Si no tiene equipo, crear uno
        IF equipo_principal_id IS NULL THEN
            INSERT INTO equipos_entrenador (entrenador_id, nombre_equipo)
            VALUES (
                (SELECT id FROM entrenadores WHERE usuario_id = p_entrenador_id),
                'Equipo Principal'
            ) RETURNING id INTO equipo_principal_id;
        END IF;
        
        equipo_id_final := equipo_principal_id;
    ELSE
        equipo_id_final := p_equipo_id;
    END IF;
    
    -- Asignar atleta al entrenador
    UPDATE atletas SET 
        entrenador_id = p_entrenador_id,
        fecha_actualizacion = NOW()
    WHERE id = p_atleta_id;
    
    -- Agregar atleta al equipo
    INSERT INTO atletas_equipo (
        equipo_id, atleta_id, notas_entrenador
    ) VALUES (
        equipo_id_final, p_atleta_id, p_notas
    )
    ON CONFLICT (equipo_id, atleta_id) DO UPDATE SET
        estado_en_equipo = 'activo',
        notas_entrenador = p_notas,
        fecha_actualizacion = NOW();
    
    -- Actualizar contador de atletas en equipo
    UPDATE equipos_entrenador SET
        atletas_actuales = (
            SELECT COUNT(*) FROM atletas_equipo 
            WHERE equipo_id = equipo_id_final AND estado_en_equipo = 'activo'
        ),
        fecha_actualizacion = NOW()
    WHERE id = equipo_id_final;
    
    RETURN equipo_id_final;
END;
$$ LANGUAGE plpgsql;
```

### **Función para Crear Evaluación**
```sql
CREATE OR REPLACE FUNCTION crear_evaluacion_atleta(
    p_entrenador_id UUID,
    p_atleta_id UUID,
    p_tipo_evaluacion TEXT,
    p_puntuaciones JSONB,
    p_observaciones JSONB
) RETURNS UUID AS $$
DECLARE
    evaluacion_id UUID;
    puntuacion_general DECIMAL(3,1);
BEGIN
    -- Calcular puntuación general
    SELECT AVG(value::INTEGER) INTO puntuacion_general
    FROM jsonb_each_text(p_puntuaciones)
    WHERE key LIKE '%_puntuacion';
    
    -- Crear evaluación
    INSERT INTO evaluaciones_atleta (
        atleta_id, evaluador_id, tipo_evaluacion,
        tecnica_puntuacion, fuerza_puntuacion, velocidad_puntuacion,
        flexibilidad_puntuacion, resistencia_puntuacion, 
        concentracion_puntuacion, disciplina_puntuacion,
        puntuacion_general, fortalezas, areas_mejora, recomendaciones
    ) VALUES (
        p_atleta_id, p_entrenador_id, p_tipo_evaluacion,
        (p_puntuaciones->>'tecnica_puntuacion')::INTEGER,
        (p_puntuaciones->>'fuerza_puntuacion')::INTEGER,
        (p_puntuaciones->>'velocidad_puntuacion')::INTEGER,
        (p_puntuaciones->>'flexibilidad_puntuacion')::INTEGER,
        (p_puntuaciones->>'resistencia_puntuacion')::INTEGER,
        (p_puntuaciones->>'concentracion_puntuacion')::INTEGER,
        (p_puntuaciones->>'disciplina_puntuacion')::INTEGER,
        puntuacion_general,
        p_observaciones->>'fortalezas',
        p_observaciones->>'areas_mejora',
        p_observaciones->>'recomendaciones'
    ) RETURNING id INTO evaluacion_id;
    
    -- Actualizar fecha de última evaluación en atletas_equipo
    UPDATE atletas_equipo SET
        fecha_ultima_evaluacion = CURRENT_DATE,
        calificacion_actual = puntuacion_general::INTEGER,
        fecha_actualizacion = NOW()
    WHERE atleta_id = p_atleta_id;
    
    RETURN evaluacion_id;
END;
$$ LANGUAGE plpgsql;
```

### **Vista para Dashboard del Entrenador**
```sql
CREATE VIEW vista_dashboard_entrenador AS
SELECT 
    e.usuario_id as entrenador_id,
    u.nombre_completo as nombre_entrenador,
    COUNT(DISTINCT eq.id) as equipos_activos,
    COUNT(DISTINCT ae.atleta_id) as total_atletas,
    COUNT(DISTINCT CASE WHEN ae.estado_en_equipo = 'activo' THEN ae.atleta_id END) as atletas_activos,
    COUNT(DISTINCT ev.id) as evaluaciones_realizadas,
    COUNT(DISTINCT pt.id) as planes_creados,
    AVG(ev.puntuacion_general) as promedio_evaluaciones,
    COUNT(DISTINCT CASE WHEN ev.fecha_evaluacion >= CURRENT_DATE - INTERVAL '30 days' THEN ev.id END) as evaluaciones_mes_actual
FROM entrenadores e
JOIN usuarios u ON e.usuario_id = u.id
LEFT JOIN equipos_entrenador eq ON e.id = eq.entrenador_id
LEFT JOIN atletas_equipo ae ON eq.id = ae.equipo_id
LEFT JOIN evaluaciones_atleta ev ON ae.atleta_id = ev.atleta_id AND ev.evaluador_id = e.usuario_id
LEFT JOIN planes_entrenamiento pt ON e.id = pt.entrenador_id
WHERE u.estado = 'activo'
GROUP BY e.usuario_id, u.nombre_completo;
```

## 📊 Índices Optimizados para Administración

```sql
-- Índices principales para consultas administrativas
CREATE INDEX idx_usuarios_rol ON usuarios(rol);
CREATE INDEX idx_usuarios_estado ON usuarios(estado);
CREATE INDEX idx_usuarios_creado_por ON usuarios(creado_por);
CREATE INDEX idx_atletas_dojo ON atletas(dojo_id);
CREATE INDEX idx_atletas_entrenador ON atletas(entrenador_id);
CREATE INDEX idx_atletas_registrado_por ON atletas(registrado_por);
CREATE INDEX idx_dojos_creado_por ON dojos(creado_por);
CREATE INDEX idx_competencias_creado_por ON competencias(creado_por);
CREATE INDEX idx_competencias_estado ON competencias(estado);
CREATE INDEX idx_inscripciones_competencia ON inscripciones(competencia_id);
CREATE INDEX idx_combates_arbitro ON combates(arbitro_principal_id);
CREATE INDEX idx_clasificaciones_temporada ON clasificaciones(temporada);

-- Índices para nuevas tablas de gestión
CREATE INDEX idx_equipos_entrenador ON equipos_entrenador(entrenador_id);
CREATE INDEX idx_atletas_equipo_equipo ON atletas_equipo(equipo_id);
CREATE INDEX idx_atletas_equipo_atleta ON atletas_equipo(atleta_id);
CREATE INDEX idx_evaluaciones_atleta ON evaluaciones_atleta(atleta_id);
CREATE INDEX idx_evaluaciones_evaluador ON evaluaciones_atleta(evaluador_id);
CREATE INDEX idx_planes_entrenador ON planes_entrenamiento(entrenador_id);
CREATE INDEX idx_asignaciones_plan ON asignaciones_plan(plan_id, atleta_id);
CREATE INDEX idx_mensajes_destinatario ON mensajes_entrenamiento(destinatario_id);
CREATE INDEX idx_metas_atleta ON metas_atleta(atleta_id);

-- Índices compuestos para reportes administrativos
CREATE INDEX idx_usuarios_rol_estado ON usuarios(rol, estado);
CREATE INDEX idx_atletas_dojo_estado ON atletas(dojo_id, estado_medico);
CREATE INDEX idx_competencias_tipo_estado ON competencias(tipo, estado);

-- Índices compuestos para gestión de equipos
CREATE INDEX idx_atletas_equipo_estado ON atletas_equipo(equipo_id, estado_en_equipo);
CREATE INDEX idx_evaluaciones_fecha ON evaluaciones_atleta(atleta_id, fecha_evaluacion DESC);
CREATE INDEX idx_planes_estado ON planes_entrenamiento(entrenador_id, estado);
CREATE INDEX idx_metas_estado ON metas_atleta(atleta_id, estado_meta);
CREATE INDEX idx_mensajes_leido ON mensajes_entrenamiento(destinatario_id, leido);

## 🔄 Funciones Inspiradas en tu Proyecto

### **Función para Crear Competencia Completa**
```sql
CREATE OR REPLACE FUNCTION crear_competencia_completa(
    p_admin_id UUID,
    p_nombre_competencia TEXT,
    p_fecha_inicio DATE,
    p_fecha_fin DATE,
    p_modalidades JSONB -- Array de modalidades con sus configuraciones
) RETURNS UUID AS $$
DECLARE
    competencia_id UUID;
    modalidad JSONB;
    modalidad_id UUID;
BEGIN
    -- Crear competencia principal
    INSERT INTO competencias (
        nombre, fecha_inicio, fecha_fin, creado_por
    ) VALUES (
        p_nombre_competencia, p_fecha_inicio, p_fecha_fin, p_admin_id
    ) RETURNING id INTO competencia_id;
    
    -- Crear modalidades
    FOR modalidad IN SELECT * FROM jsonb_array_elements(p_modalidades) LOOP
        INSERT INTO competencias_modalidades (
            competencia_id, modalidad, categoria_edad, categoria_peso, 
            genero, max_participantes, costo_inscripcion
        ) VALUES (
            competencia_id,
            modalidad->>'modalidad',
            modalidad->>'categoria_edad',
            modalidad->>'categoria_peso',
            modalidad->>'genero',
            (modalidad->>'max_participantes')::INTEGER,
            (modalidad->>'costo_inscripcion')::DECIMAL
        ) RETURNING id INTO modalidad_id;
        
        -- Crear grupos automáticamente si es necesario
        IF (modalidad->>'crear_grupos')::BOOLEAN THEN
            PERFORM crear_grupos_automaticos(modalidad_id, (modalidad->>'tipo_grupo')::TEXT);
        END IF;
    END LOOP;
    
    RETURN competencia_id;
END;
$$ LANGUAGE plpgsql;
```

### **Función para Inscripción Inteligente**
```sql
CREATE OR REPLACE FUNCTION inscribir_participante(
    p_modalidad_id UUID,
    p_tipo TEXT, -- 'individual' o 'equipo'
    p_atleta_id UUID DEFAULT NULL,
    p_equipo_id UUID DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    participacion_id UUID;
    grupo_disponible_id UUID;
BEGIN
    -- Validar capacidad
    IF (SELECT participantes_actuales FROM competencias_modalidades WHERE id = p_modalidad_id) >= 
       (SELECT max_participantes FROM competencias_modalidades WHERE id = p_modalidad_id) THEN
        RAISE EXCEPTION 'Modalidad llena';
    END IF;
    
    -- Crear participación
    INSERT INTO participaciones (
        modalidad_id, tipo_participacion, atleta_id, equipo_id
    ) VALUES (
        p_modalidad_id, p_tipo, p_atleta_id, p_equipo_id
    ) RETURNING id INTO participacion_id;
    
    -- Buscar grupo disponible
    SELECT id INTO grupo_disponible_id
    FROM grupos_competencia 
    WHERE modalidad_id = p_modalidad_id 
    AND participantes_actuales < max_participantes
    AND estado = 'formacion'
    ORDER BY participantes_actuales ASC
    LIMIT 1;
    
    -- Si no hay grupo, crear uno nuevo
    IF grupo_disponible_id IS NULL THEN
        INSERT INTO grupos_competencia (
            modalidad_id, nombre_grupo, tipo_grupo
        ) VALUES (
            p_modalidad_id, 'Grupo ' || chr(65 + (SELECT COUNT(*) FROM grupos_competencia WHERE modalidad_id = p_modalidad_id)), 'eliminatoria'
        ) RETURNING id INTO grupo_disponible_id;
    END IF;
    
    -- Agregar a grupo
    INSERT INTO grupos_participantes (
        grupo_id, participacion_id
    ) VALUES (
        grupo_disponible_id, participacion_id
    );
    
    -- Actualizar contadores
    UPDATE competencias_modalidades SET 
        participantes_actuales = participantes_actuales + 1
    WHERE id = p_modalidad_id;
    
    UPDATE grupos_competencia SET 
        participantes_actuales = participantes_actuales + 1
    WHERE id = grupo_disponible_id;
    
    RETURN participacion_id;
END;
$$ LANGUAGE plpgsql;
```

### **Vista Completa de Competencias (Como tu proyecto)**
```sql
CREATE VIEW vista_competencias_completa AS
SELECT 
    c.id as competencia_id,
    c.nombre as competencia_nombre,
    c.fecha_inicio,
    c.fecha_fin,
    c.estado as competencia_estado,
    
    -- Modalidades
    cm.id as modalidad_id,
    cm.modalidad,
    cm.categoria_edad,
    cm.categoria_peso,
    cm.genero,
    cm.participantes_actuales,
    cm.max_participantes,
    
    -- Grupos
    gc.id as grupo_id,
    gc.nombre_grupo,
    gc.tipo_grupo,
    gc.estado as grupo_estado,
    
    -- Participaciones
    p.id as participacion_id,
    p.tipo_participacion,
    
    -- Datos del atleta (si es individual)
    CASE WHEN p.tipo_participacion = 'individual' THEN u.nombre_completo END as atleta_nombre,
    CASE WHEN p.tipo_participacion = 'individual' THEN a.nivel_cinturon END as atleta_cinturon,
    
    -- Datos del equipo (si es equipo)
    CASE WHEN p.tipo_participacion = 'equipo' THEN ee.nombre_equipo END as equipo_nombre,
    
    -- Estadísticas del grupo
    gp.puntos_grupo,
    gp.combates_ganados,
    gp.combates_perdidos,
    gp.clasificado
    
FROM competencias c
JOIN competencias_modalidades cm ON c.id = cm.competencia_id
LEFT JOIN grupos_competencia gc ON cm.id = gc.modalidad_id
LEFT JOIN grupos_participantes gp ON gc.id = gp.grupo_id
LEFT JOIN participaciones p ON gp.participacion_id = p.id
LEFT JOIN atletas a ON p.atleta_id = a.id
LEFT JOIN usuarios u ON a.usuario_id = u.id
LEFT JOIN equipos_entrenador ee ON p.equipo_id = ee.id
ORDER BY c.fecha_inicio DESC, cm.modalidad, gc.orden_grupo, gp.puntos_grupo DESC;
```

## 📊 DIAGRAMA DE FLUJO PRINCIPAL - ASO KARATE 2

```
                    🥋 ASO KARATE 2 - FLUJO PRINCIPAL
                              |
                              ▼
                    ┌─────────────────────┐
                    │   🔐 REGISTRO       │
                    │   auth.users        │
                    └──────────┬──────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │   👤 USUARIO        │
                    │   usuarios          │
                    │   (estado: pendiente)│
                    └──────────┬──────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │   📱 SOLICITA ROL   │
                    │   solicitudes_rol   │
                    └──────────┬──────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │   🔔 NOTIFICA       │
                    │   notificaciones    │
                    └──────────┬──────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │   👨💼 ADMIN        │
                    │   REVISA Y APRUEBA  │
                    └──────────┬──────────┘
                              │
                              ▼
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ 🥋 ATLETA   │    │👨🏫 ENTRENA. │    │ ⚖️ ÁRBITRO │
│ atletas     │    │ entrenadores │    │ arbitros    │
└─────┬───────┘    └─────┬───────┘    └─────┬───────┘
      │                  │                  │
      ▼                  ▼                  ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ 📊 PERFIL   │    │ 👥 EQUIPOS  │    │ 🕐 HORARIOS │
│ DEPORTIVO   │    │ equipos_ent │    │ disponibil. │
└─────┬───────┘    └─────┬───────┘    └─────┬───────┘
      │                  │                  │
      ▼                  ▼                  ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ 🎯 METAS    │    │ 📝 EVALÚA   │    │ ⚔️ ARBITRA  │
│ metas_atl   │    │ evaluaciones│    │ combates    │
└─────────────┘    └─────────────┘    └─────────────┘
```

## 🏆 DIAGRAMA DE COMPETENCIAS

```
                    🏆 SISTEMA DE COMPETENCIAS
                              |
                              ▼
                    ┌─────────────────────┐
                    │   👨💼 ADMIN CREA   │
                    │   competencias      │
                    └──────────┬──────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │   🎯 MODALIDADES    │
                    │   comp_modalidades  │
                    │   kata|kumite       │
                    │   individual|equipo │
                    └──────────┬──────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │   📝 INSCRIPCIONES  │
                    │   participaciones   │
                    └──────────┬──────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │   🎲 SORTEOS        │
                    │   grupos_competencia│
                    └──────────┬──────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │   ⚔️ COMBATES       │
                    │   enfrentamientos   │
                    └──────────┬──────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │   🏅 RESULTADOS     │
                    │   tabla_posiciones  │
                    └─────────────────────┘
```

## ⚔️ DIAGRAMA DE SIMULACIÓN DE COMBATES

```
                    ⚔️ SIMULACIÓN EN TIEMPO REAL
                              |
                              ▼
                    ┌─────────────────────┐
                    │   📋 REGLAS WKF     │
                    │   reglas_karate     │
                    │   Yuko|Wazari|Ippon │
                    └──────────┬──────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │   🎮 INICIA COMBATE │
                    │   combate_simulacion│
                    └──────────┬──────────┘
                              │
                              ▼
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ 🥊 TÉCNICAS │    │ ⏱️ TIEMPO   │    │ ⚠️ PENALIZ. │
│ acciones_c  │    │ marcador_t  │    │ penaliz_c   │
└─────┬───────┘    └─────┬───────┘    └─────┬───────┘
      │                  │                  │
      └─────────┬────────┴────────┬─────────┘
                │                 │
                ▼                 ▼
      ┌─────────────────┐ ┌─────────────────┐
      │ 📊 MARCADOR     │ │ 🏆 GANADOR      │
      │ TIEMPO REAL     │ │ AUTOMÁTICO      │
      └─────────────────┘ └─────────────────┘
```

## 🎯 Formularios y Funcionalidades por Rol

### **📝 FORMULARIOS PARA ENTRENADORES**

#### **Agregar Atleta al Equipo**
```typescript
interface FormularioAgregarAtleta {
  atleta_id: string;
  equipo_id?: string; // Opcional, usa equipo principal si no se especifica
  posicion_equipo: 'miembro' | 'capitán' | 'subcapitán';
  objetivos_personales: string;
  notas_entrenador: string;
  fecha_ingreso: Date;
}
```

#### **Crear Plan de Entrenamiento**
```typescript
interface FormularioPlanEntrenamiento {
  nombre_plan: string;
  descripcion: string;
  tipo_plan: 'individual' | 'grupal' | 'competencia' | 'tecnico' | 'fisico';
  duracion_semanas: number;
  nivel_dificultad: 1 | 2 | 3 | 4 | 5;
  objetivos: string[];
  ejercicios_incluidos: string[];
  material_necesario: string[];
  fecha_inicio: Date;
  atletas_asignados: string[]; // IDs de atletas
}
```

#### **Evaluar Atleta**
```typescript
interface FormularioEvaluacion {
  atleta_id: string;
  tipo_evaluacion: 'tecnica' | 'fisica' | 'mental' | 'competitiva' | 'general';
  puntuaciones: {
    tecnica_puntuacion: number; // 1-10
    fuerza_puntuacion: number;
    velocidad_puntuacion: number;
    flexibilidad_puntuacion: number;
    resistencia_puntuacion: number;
    concentracion_puntuacion: number;
    disciplina_puntuacion: number;
  };
  observaciones: {
    fortalezas: string;
    areas_mejora: string;
    recomendaciones: string;
    objetivos_proximos: string;
  };
}
```

### **📝 FORMULARIOS PARA ATLETAS**

#### **Actualizar Perfil Deportivo**
```typescript
interface FormularioPerfilAtleta {
  peso: number;
  altura: number;
  nivel_cinturon: 'blanco' | 'amarillo' | 'naranja' | 'verde' | 'azul' | 'marron' | 'negro';
  nivel_dan?: number;
  certificado_medico_url?: string;
  fecha_ultimo_examen?: Date;
  contacto_emergencia: string;
  telefono_emergencia: string;
  objetivos_personales: string;
  especialidad_preferida: 'kata' | 'kumite' | 'ambos';
}
```

#### **Crear Meta Personal**
```typescript
interface FormularioMetaPersonal {
  titulo_meta: string;
  descripcion: string;
  tipo_meta: 'tecnica' | 'competitiva' | 'fisica' | 'personal' | 'academica';
  fecha_objetivo: Date;
  valor_inicial?: number;
  valor_objetivo?: number;
  unidad_medida?: string;
  estrategias_utilizadas: string;
}
```

### **📝 FORMULARIOS PARA ÁRBITROS**

#### **Actualizar Perfil Profesional**
```typescript
interface FormularioPerfilArbitro {
  nivel_arbitraje: 'regional' | 'nacional' | 'internacional';
  licencia_numero: string;
  fecha_licencia: Date;
  fecha_vencimiento: Date;
  especialidad: 'kata' | 'kumite' | 'ambos';
  federacion_certificadora: string;
  cursos_completados: string[];
  disponibilidad_horaria: string;
  observaciones_personales: string;
}
```

#### **Reporte Post-Combate**
```typescript
interface FormularioReporteCombate {
  combate_id: string;
  observaciones_generales: string;
  incidentes_reportados?: string;
  calidad_combate: 1 | 2 | 3 | 4 | 5;
  comportamiento_atletas: 1 | 2 | 3 | 4 | 5;
  recomendaciones: string;
  tiempo_total_efectivo: number; // en minutos
  penalizaciones_aplicadas: {
    atleta_id: string;
    tipo_penalizacion: string;
    motivo: string;
  }[];
}
```
```

## 📊 Dashboards Personalizados por Rol

### **🎛️ Dashboard del Entrenador**
```sql
-- Vista completa del dashboard del entrenador
CREATE VIEW dashboard_entrenador_completo AS
SELECT 
    e.usuario_id,
    u.nombre_completo,
    -- Estadísticas de equipos
    COUNT(DISTINCT eq.id) as total_equipos,
    COUNT(DISTINCT ae.atleta_id) as total_atletas,
    COUNT(DISTINCT CASE WHEN ae.estado_en_equipo = 'activo' THEN ae.atleta_id END) as atletas_activos,
    
    -- Estadísticas de evaluaciones
    COUNT(DISTINCT ev.id) as evaluaciones_realizadas,
    AVG(ev.puntuacion_general) as promedio_evaluaciones,
    COUNT(DISTINCT CASE WHEN ev.fecha_evaluacion >= CURRENT_DATE - INTERVAL '7 days' THEN ev.id END) as evaluaciones_semana,
    
    -- Estadísticas de planes
    COUNT(DISTINCT pt.id) as planes_creados,
    COUNT(DISTINCT CASE WHEN pt.estado = 'activo' THEN pt.id END) as planes_activos,
    
    -- Próximas actividades
    COUNT(DISTINCT CASE WHEN ap.estado_progreso = 'en_progreso' THEN ap.id END) as planes_en_progreso,
    COUNT(DISTINCT CASE WHEN mg.estado_meta = 'activa' AND mg.fecha_objetivo <= CURRENT_DATE + INTERVAL '30 days' THEN mg.id END) as metas_proximas,
    
    -- Comunicación
    COUNT(DISTINCT CASE WHEN me.leido = FALSE AND me.destinatario_id = e.usuario_id THEN me.id END) as mensajes_no_leidos
    
FROM entrenadores e
JOIN usuarios u ON e.usuario_id = u.id
LEFT JOIN equipos_entrenador eq ON e.id = eq.entrenador_id
LEFT JOIN atletas_equipo ae ON eq.id = ae.equipo_id
LEFT JOIN evaluaciones_atleta ev ON ae.atleta_id = ev.atleta_id AND ev.evaluador_id = e.usuario_id
LEFT JOIN planes_entrenamiento pt ON e.id = pt.entrenador_id
LEFT JOIN asignaciones_plan ap ON pt.id = ap.plan_id
LEFT JOIN metas_atleta mg ON ae.atleta_id = mg.atleta_id
LEFT JOIN mensajes_entrenamiento me ON e.usuario_id = me.destinatario_id
WHERE u.estado = 'activo'
GROUP BY e.usuario_id, u.nombre_completo;
```

### **🥋 Dashboard del Atleta**
```sql
-- Vista completa del dashboard del atleta
CREATE VIEW dashboard_atleta_completo AS
SELECT 
    a.usuario_id,
    u.nombre_completo,
    a.nivel_cinturon,
    a.peso,
    
    -- Información del equipo
    eq.nombre_equipo,
    ae.posicion_equipo,
    ae.calificacion_actual,
    
    -- Estadísticas de evaluaciones
    COUNT(DISTINCT ev.id) as total_evaluaciones,
    AVG(ev.puntuacion_general) as promedio_evaluaciones,
    MAX(ev.fecha_evaluacion) as ultima_evaluacion,
    
    -- Planes de entrenamiento
    COUNT(DISTINCT ap.id) as planes_asignados,
    COUNT(DISTINCT CASE WHEN ap.estado_progreso = 'en_progreso' THEN ap.id END) as planes_activos,
    AVG(ap.porcentaje_completado) as progreso_promedio,
    
    -- Metas personales
    COUNT(DISTINCT mg.id) as metas_totales,
    COUNT(DISTINCT CASE WHEN mg.estado_meta = 'activa' THEN mg.id END) as metas_activas,
    COUNT(DISTINCT CASE WHEN mg.estado_meta = 'completada' THEN mg.id END) as metas_completadas,
    
    -- Competencias
    COUNT(DISTINCT ins.id) as inscripciones_totales,
    COUNT(DISTINCT CASE WHEN c.estado IN ('inscripciones_abiertas', 'en_progreso') THEN ins.id END) as competencias_activas,
    
    -- Comunicación
    COUNT(DISTINCT CASE WHEN me.leido = FALSE AND me.destinatario_id = a.usuario_id THEN me.id END) as mensajes_no_leidos
    
FROM atletas a
JOIN usuarios u ON a.usuario_id = u.id
LEFT JOIN atletas_equipo ae ON a.id = ae.atleta_id AND ae.estado_en_equipo = 'activo'
LEFT JOIN equipos_entrenador eq ON ae.equipo_id = eq.id
LEFT JOIN evaluaciones_atleta ev ON a.id = ev.atleta_id
LEFT JOIN asignaciones_plan ap ON a.id = ap.atleta_id
LEFT JOIN metas_atleta mg ON a.id = mg.atleta_id
LEFT JOIN inscripciones ins ON a.id = ins.atleta_id
LEFT JOIN competencias c ON ins.competencia_id = c.id
LEFT JOIN mensajes_entrenamiento me ON a.usuario_id = me.destinatario_id
WHERE u.estado = 'activo'
GROUP BY a.usuario_id, u.nombre_completo, a.nivel_cinturon, a.peso, 
         eq.nombre_equipo, ae.posicion_equipo, ae.calificacion_actual;
```

### **⚖️ Dashboard del Árbitro**
```sql
-- Vista completa del dashboard del árbitro
CREATE VIEW dashboard_arbitro_completo AS
SELECT 
    ar.usuario_id,
    u.nombre_completo,
    ar.nivel_arbitraje,
    ar.especialidad,
    ar.estado_licencia,
    ar.fecha_vencimiento,
    
    -- Estadísticas de arbitraje
    COUNT(DISTINCT cb.id) as combates_arbitrados,
    COUNT(DISTINCT CASE WHEN cb.estado = 'completado' THEN cb.id END) as combates_completados,
    COUNT(DISTINCT CASE WHEN cb.fecha_creacion >= CURRENT_DATE - INTERVAL '30 days' THEN cb.id END) as combates_mes_actual,
    
    -- Próximos combates
    COUNT(DISTINCT CASE WHEN cb.estado = 'programado' AND cb.hora_programada >= NOW() THEN cb.id END) as combates_programados,
    MIN(CASE WHEN cb.estado = 'programado' AND cb.hora_programada >= NOW() THEN cb.hora_programada END) as proximo_combate,
    
    -- Evaluaciones
    ar.evaluaciones_realizadas,
    ar.calificacion_promedio,
    
    -- Comunicación
    COUNT(DISTINCT CASE WHEN me.leido = FALSE AND me.destinatario_id = ar.usuario_id THEN me.id END) as mensajes_no_leidos,
    
    -- Estado de licencia
    CASE 
        WHEN ar.fecha_vencimiento <= CURRENT_DATE THEN 'vencida'
        WHEN ar.fecha_vencimiento <= CURRENT_DATE + INTERVAL '30 days' THEN 'proxima_vencer'
        ELSE 'vigente'
    END as estado_licencia_calculado
    
FROM arbitros ar
JOIN usuarios u ON ar.usuario_id = u.id
LEFT JOIN combates cb ON ar.id = cb.arbitro_principal_id
LEFT JOIN mensajes_entrenamiento me ON ar.usuario_id = me.destinatario_id
WHERE u.estado = 'activo'
GROUP BY ar.usuario_id, u.nombre_completo, ar.nivel_arbitraje, ar.especialidad, 
         ar.estado_licencia, ar.fecha_vencimiento, ar.evaluaciones_realizadas, ar.calificacion_promedio;
```

## 📲 Sistema de Solicitudes de Rol

### **Flujo de Solicitud de Roles**

```
👤 USUARIO NUEVO REGISTRA → 📱 SOLICITA ROL → 🔔 NOTIFICA ADMIN → ✅ ADMIN APRUEBA → 🔓 DESBLOQUEA FUNCIONES

1. Usuario se registra (solo perfil básico)
2. Usuario solicita ser: Atleta | Entrenador | Árbitro
3. Admin recibe notificación
4. Admin revisa documentos/credenciales
5. Admin aprueba/rechaza solicitud
6. Usuario obtiene acceso a funciones específicas
```

### **Tablas del Sistema de Solicitudes**

#### `solicitudes_rol`
```sql
CREATE TABLE solicitudes_rol (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID REFERENCES usuarios(id) NOT NULL,
    rol_solicitado TEXT CHECK (rol_solicitado IN ('atleta', 'entrenador', 'arbitro')) NOT NULL,
    estado_solicitud TEXT CHECK (estado_solicitud IN ('pendiente', 'en_revision', 'aprobada', 'rechazada', 'requiere_info')) DEFAULT 'pendiente',
    motivo_solicitud TEXT NOT NULL, -- Por qué quiere ese rol
    experiencia_previa TEXT,
    certificaciones TEXT[], -- URLs o descripciones de certificados
    documentos_adjuntos TEXT[], -- URLs de documentos subidos
    dojo_preferido UUID REFERENCES dojos(id), -- Para atletas y entrenadores
    especialidad_preferida TEXT CHECK (especialidad_preferida IN ('kata', 'kumite', 'ambos')),
    disponibilidad_horaria TEXT,
    contacto_referencia TEXT, -- Contacto de referencia
    telefono_referencia TEXT,
    
    -- Campos administrativos
    revisado_por UUID REFERENCES usuarios(id), -- Admin que revisa
    fecha_revision TIMESTAMP WITH TIME ZONE,
    comentarios_admin TEXT, -- Comentarios del admin
    motivo_rechazo TEXT, -- Si es rechazada
    informacion_adicional_requerida TEXT, -- Si requiere más info
    
    -- Campos de seguimiento
    prioridad INTEGER DEFAULT 1 CHECK (prioridad BETWEEN 1 AND 5), -- 1=baja, 5=alta
    fecha_limite_respuesta DATE, -- Fecha límite para responder
    recordatorios_enviados INTEGER DEFAULT 0,
    
    fecha_solicitud TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Un usuario solo puede tener una solicitud activa por rol
    UNIQUE(usuario_id, rol_solicitado, estado_solicitud) 
    WHERE estado_solicitud IN ('pendiente', 'en_revision', 'requiere_info')
);
```

#### `documentos_solicitud`
```sql
CREATE TABLE documentos_solicitud (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    solicitud_id UUID REFERENCES solicitudes_rol(id) NOT NULL,
    tipo_documento TEXT CHECK (tipo_documento IN (
        'cedula', 'certificado_medico', 'certificado_karate', 
        'licencia_entrenador', 'licencia_arbitro', 'foto_perfil',
        'carta_recomendacion', 'curriculum', 'otro'
    )) NOT NULL,
    nombre_archivo TEXT NOT NULL,
    url_archivo TEXT NOT NULL,
    tamaño_archivo INTEGER, -- En bytes
    tipo_mime TEXT,
    es_requerido BOOLEAN DEFAULT FALSE,
    verificado_por UUID REFERENCES usuarios(id), -- Admin que verificó
    fecha_verificacion TIMESTAMP WITH TIME ZONE,
    estado_verificacion TEXT CHECK (estado_verificacion IN ('pendiente', 'aprobado', 'rechazado')) DEFAULT 'pendiente',
    observaciones_verificacion TEXT,
    fecha_subida TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `notificaciones_sistema`
```sql
CREATE TABLE notificaciones_sistema (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    tipo_notificacion TEXT CHECK (tipo_notificacion IN (
        'nueva_solicitud_rol', 'solicitud_aprobada', 'solicitud_rechazada',
        'requiere_documentos', 'recordatorio_solicitud', 'bienvenida_rol',
        'competencia_disponible', 'combate_programado', 'resultado_combate'
    )) NOT NULL,
    
    -- Destinatarios
    usuario_destinatario UUID REFERENCES usuarios(id), -- Usuario específico
    rol_destinatario TEXT, -- O todos los usuarios de un rol
    es_para_admins BOOLEAN DEFAULT FALSE, -- O para todos los admins
    
    -- Contenido
    titulo TEXT NOT NULL,
    mensaje TEXT NOT NULL,
    datos_adicionales JSONB, -- Datos extra en formato JSON
    url_accion TEXT, -- URL para acción (ej: revisar solicitud)
    texto_boton TEXT, -- Texto del botón de acción
    
    -- Estado
    leida BOOLEAN DEFAULT FALSE,
    fecha_lectura TIMESTAMP WITH TIME ZONE,
    archivada BOOLEAN DEFAULT FALSE,
    
    -- Prioridad y categoría
    prioridad TEXT CHECK (prioridad IN ('baja', 'media', 'alta', 'urgente')) DEFAULT 'media',
    categoria TEXT CHECK (categoria IN ('sistema', 'solicitud', 'competencia', 'combate', 'general')) DEFAULT 'general',
    
    -- Metadata
    creado_por UUID REFERENCES usuarios(id), -- Quién generó la notificación
    solicitud_relacionada UUID REFERENCES solicitudes_rol(id), -- Si está relacionada con solicitud
    
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_expiracion TIMESTAMP WITH TIME ZONE -- Fecha de expiración opcional
);
```

#### `historial_cambios_rol`
```sql
CREATE TABLE historial_cambios_rol (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID REFERENCES usuarios(id) NOT NULL,
    rol_anterior TEXT,
    rol_nuevo TEXT NOT NULL,
    motivo_cambio TEXT NOT NULL,
    solicitud_relacionada UUID REFERENCES solicitudes_rol(id),
    
    -- Quién autorizó el cambio
    autorizado_por UUID REFERENCES usuarios(id) NOT NULL,
    fecha_autorizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Detalles del cambio
    observaciones TEXT,
    documentos_respaldo TEXT[], -- URLs de documentos que respaldan el cambio
    
    -- Metadata
    ip_address INET,
    user_agent TEXT,
    
    fecha_cambio TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### **Configuración de Requisitos por Rol**

#### `requisitos_rol`
```sql
CREATE TABLE requisitos_rol (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    rol TEXT CHECK (rol IN ('atleta', 'entrenador', 'arbitro')) NOT NULL,
    tipo_requisito TEXT CHECK (tipo_requisito IN (
        'documento', 'experiencia', 'certificacion', 'edad', 'otro'
    )) NOT NULL,
    nombre_requisito TEXT NOT NULL,
    descripcion TEXT NOT NULL,
    es_obligatorio BOOLEAN DEFAULT TRUE,
    orden_presentacion INTEGER DEFAULT 1,
    
    -- Validaciones específicas
    edad_minima INTEGER,
    edad_maxima INTEGER,
    años_experiencia_minima INTEGER,
    tipos_documento_aceptados TEXT[], -- ['pdf', 'jpg', 'png']
    tamaño_maximo_mb INTEGER DEFAULT 5,
    
    -- Configuración
    activo BOOLEAN DEFAULT TRUE,
    fecha_vigencia_desde DATE DEFAULT CURRENT_DATE,
    fecha_vigencia_hasta DATE,
    
    creado_por UUID REFERENCES usuarios(id) NOT NULL,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🔔 Sistema de Notificaciones Mejorado

### **Dashboard de Notificaciones para Admin**

#### `panel_admin_solicitudes`
```sql
CREATE VIEW panel_admin_solicitudes AS
SELECT 
    sr.id,
    sr.rol_solicitado,
    sr.estado_solicitud,
    u.nombre_completo,
    u.email,
    sr.fecha_solicitud,
    sr.prioridad,
    COUNT(ds.id) as documentos_subidos,
    COUNT(CASE WHEN ds.estado_verificacion = 'aprobado' THEN 1 END) as documentos_aprobados,
    sr.fecha_limite_respuesta,
    CASE 
        WHEN sr.fecha_limite_respuesta < CURRENT_DATE THEN 'vencida'
        WHEN sr.fecha_limite_respuesta <= CURRENT_DATE + INTERVAL '3 days' THEN 'proxima_vencer'
        ELSE 'en_tiempo'
    END as estado_tiempo,
    EXTRACT(days FROM (CURRENT_DATE - sr.fecha_solicitud::date)) as dias_pendiente
FROM solicitudes_rol sr
JOIN usuarios u ON sr.usuario_id = u.id
LEFT JOIN documentos_solicitud ds ON sr.id = ds.solicitud_id
WHERE sr.estado_solicitud IN ('pendiente', 'en_revision', 'requiere_info')
GROUP BY sr.id, sr.rol_solicitado, sr.estado_solicitud, u.nombre_completo, 
         u.email, sr.fecha_solicitud, sr.prioridad, sr.fecha_limite_respuesta
ORDER BY 
    CASE sr.prioridad WHEN 5 THEN 1 WHEN 4 THEN 2 WHEN 3 THEN 3 WHEN 2 THEN 4 ELSE 5 END,
    sr.fecha_solicitud ASC;
```

## 🎯 Nuevas Tablas Administrativas

### **Auditoría y Control**

#### `auditoria_acciones`
```sql
CREATE TABLE auditoria_acciones (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID REFERENCES usuarios(id) NOT NULL,
    accion TEXT NOT NULL, -- 'crear', 'editar', 'eliminar', 'login', etc.
    tabla_afectada TEXT,
    registro_id UUID,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    ip_address INET,
    user_agent TEXT,
    fecha_accion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `configuracion_sistema`
```sql
CREATE TABLE configuracion_sistema (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    clave TEXT UNIQUE NOT NULL,
    valor TEXT NOT NULL,
    descripcion TEXT,
    tipo TEXT CHECK (tipo IN ('texto', 'numero', 'booleano', 'json')) DEFAULT 'texto',
    modificado_por UUID REFERENCES usuarios(id),
    fecha_modificacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `notificaciones_admin`
```sql
CREATE TABLE notificaciones_admin (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    tipo TEXT CHECK (tipo IN ('nuevo_usuario', 'inscripcion_pendiente', 'error_sistema', 'reporte_generado')) NOT NULL,
    titulo TEXT NOT NULL,
    mensaje TEXT NOT NULL,
    usuario_destinatario UUID REFERENCES usuarios(id),
    leida BOOLEAN DEFAULT FALSE,
    datos_adicionales JSONB,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 📱 Funciones del Sistema de Solicitudes

### **Función para Crear Solicitud de Rol**
```sql
CREATE OR REPLACE FUNCTION crear_solicitud_rol(
    p_usuario_id UUID,
    p_rol_solicitado TEXT,
    p_motivo TEXT,
    p_experiencia TEXT DEFAULT NULL,
    p_dojo_preferido UUID DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    solicitud_id UUID;
    admin_ids UUID[];
    admin_id UUID;
BEGIN
    -- Verificar que no tenga solicitud pendiente para ese rol
    IF EXISTS (
        SELECT 1 FROM solicitudes_rol 
        WHERE usuario_id = p_usuario_id 
        AND rol_solicitado = p_rol_solicitado 
        AND estado_solicitud IN ('pendiente', 'en_revision', 'requiere_info')
    ) THEN
        RAISE EXCEPTION 'Ya tienes una solicitud pendiente para el rol de %', p_rol_solicitado;
    END IF;
    
    -- Crear solicitud
    INSERT INTO solicitudes_rol (
        usuario_id, rol_solicitado, motivo_solicitud, 
        experiencia_previa, dojo_preferido, fecha_limite_respuesta
    ) VALUES (
        p_usuario_id, p_rol_solicitado, p_motivo, 
        p_experiencia, p_dojo_preferido, CURRENT_DATE + INTERVAL '7 days'
    ) RETURNING id INTO solicitud_id;
    
    -- Notificar a todos los administradores
    SELECT ARRAY_AGG(id) INTO admin_ids 
    FROM usuarios WHERE es_administrador = TRUE AND estado = 'activo';
    
    FOREACH admin_id IN ARRAY admin_ids LOOP
        INSERT INTO notificaciones_sistema (
            tipo_notificacion, usuario_destinatario, titulo, mensaje,
            datos_adicionales, url_accion, texto_boton, prioridad,
            categoria, solicitud_relacionada
        ) VALUES (
            'nueva_solicitud_rol', admin_id, 
            'Nueva Solicitud de Rol: ' || UPPER(p_rol_solicitado),
            'Un usuario ha solicitado el rol de ' || p_rol_solicitado || '. Revisa la solicitud y los documentos.',
            json_build_object('usuario_id', p_usuario_id, 'rol', p_rol_solicitado),
            '/admin/solicitudes/' || solicitud_id,
            'Revisar Solicitud',
            'alta', 'solicitud', solicitud_id
        );
    END LOOP;
    
    RETURN solicitud_id;
END;
$$ LANGUAGE plpgsql;
```

### **Función para Aprobar Solicitud**
```sql
CREATE OR REPLACE FUNCTION aprobar_solicitud_rol(
    p_solicitud_id UUID,
    p_admin_id UUID,
    p_comentarios TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    solicitud_record RECORD;
    nuevo_registro_id UUID;
BEGIN
    -- Obtener datos de la solicitud
    SELECT * INTO solicitud_record 
    FROM solicitudes_rol WHERE id = p_solicitud_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Solicitud no encontrada';
    END IF;
    
    -- Verificar que quien aprueba es admin
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE id = p_admin_id AND es_administrador = TRUE) THEN
        RAISE EXCEPTION 'Solo administradores pueden aprobar solicitudes';
    END IF;
    
    -- Actualizar solicitud
    UPDATE solicitudes_rol SET
        estado_solicitud = 'aprobada',
        revisado_por = p_admin_id,
        fecha_revision = NOW(),
        comentarios_admin = p_comentarios,
        fecha_actualizacion = NOW()
    WHERE id = p_solicitud_id;
    
    -- Actualizar rol del usuario
    UPDATE usuarios SET
        rol = solicitud_record.rol_solicitado,
        estado = 'activo',
        aprobado_por = p_admin_id,
        fecha_aprobacion = NOW()
    WHERE id = solicitud_record.usuario_id;
    
    -- Crear registro específico según el rol
    IF solicitud_record.rol_solicitado = 'atleta' THEN
        INSERT INTO atletas (usuario_id, dojo_id, registrado_por, aprobado_por)
        VALUES (solicitud_record.usuario_id, solicitud_record.dojo_preferido, p_admin_id, p_admin_id)
        RETURNING id INTO nuevo_registro_id;
    ELSIF solicitud_record.rol_solicitado = 'entrenador' THEN
        INSERT INTO entrenadores (usuario_id, dojo_id, asignado_por, evaluado_por)
        VALUES (solicitud_record.usuario_id, solicitud_record.dojo_preferido, p_admin_id, p_admin_id)
        RETURNING id INTO nuevo_registro_id;
    ELSIF solicitud_record.rol_solicitado = 'arbitro' THEN
        INSERT INTO arbitros (usuario_id, asignado_por, evaluado_por)
        VALUES (solicitud_record.usuario_id, p_admin_id, p_admin_id)
        RETURNING id INTO nuevo_registro_id;
    END IF;
    
    -- Registrar cambio de rol
    INSERT INTO historial_cambios_rol (
        usuario_id, rol_anterior, rol_nuevo, motivo_cambio,
        solicitud_relacionada, autorizado_por
    ) VALUES (
        solicitud_record.usuario_id, 'usuario', solicitud_record.rol_solicitado,
        'Aprobación de solicitud de rol', p_solicitud_id, p_admin_id
    );
    
    -- Notificar al usuario
    INSERT INTO notificaciones_sistema (
        tipo_notificacion, usuario_destinatario, titulo, mensaje,
        datos_adicionales, prioridad, categoria
    ) VALUES (
        'solicitud_aprobada', solicitud_record.usuario_id,
        '¡Solicitud Aprobada! 🎉',
        'Tu solicitud para ser ' || solicitud_record.rol_solicitado || ' ha sido aprobada. Ya puedes acceder a todas las funciones.',
        json_build_object('rol_nuevo', solicitud_record.rol_solicitado, 'registro_id', nuevo_registro_id),
        'alta', 'solicitud'
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
```

### **Función para Rechazar Solicitud**
```sql
CREATE OR REPLACE FUNCTION rechazar_solicitud_rol(
    p_solicitud_id UUID,
    p_admin_id UUID,
    p_motivo_rechazo TEXT
) RETURNS BOOLEAN AS $$
DECLARE
    solicitud_record RECORD;
BEGIN
    -- Obtener datos de la solicitud
    SELECT * INTO solicitud_record 
    FROM solicitudes_rol WHERE id = p_solicitud_id;
    
    -- Actualizar solicitud
    UPDATE solicitudes_rol SET
        estado_solicitud = 'rechazada',
        revisado_por = p_admin_id,
        fecha_revision = NOW(),
        motivo_rechazo = p_motivo_rechazo,
        fecha_actualizacion = NOW()
    WHERE id = p_solicitud_id;
    
    -- Notificar al usuario
    INSERT INTO notificaciones_sistema (
        tipo_notificacion, usuario_destinatario, titulo, mensaje,
        datos_adicionales, prioridad, categoria
    ) VALUES (
        'solicitud_rechazada', solicitud_record.usuario_id,
        'Solicitud No Aprobada',
        'Tu solicitud para ser ' || solicitud_record.rol_solicitado || ' no fue aprobada. Motivo: ' || p_motivo_rechazo,
        json_build_object('motivo', p_motivo_rechazo, 'puede_reenviar', true),
        'media', 'solicitud'
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
```

### **Función para Obtener Estadísticas del Dashboard Admin**
```sql
CREATE OR REPLACE FUNCTION obtener_estadisticas_admin()
RETURNS JSON AS $$
DECLARE
    resultado JSON;
BEGIN
    SELECT json_build_object(
        'solicitudes_pendientes', (
            SELECT COUNT(*) FROM solicitudes_rol 
            WHERE estado_solicitud IN ('pendiente', 'en_revision')
        ),
        'solicitudes_vencidas', (
            SELECT COUNT(*) FROM solicitudes_rol 
            WHERE estado_solicitud IN ('pendiente', 'en_revision') 
            AND fecha_limite_respuesta < CURRENT_DATE
        ),
        'usuarios_activos', (
            SELECT COUNT(*) FROM usuarios WHERE estado = 'activo'
        ),
        'atletas_registrados', (
            SELECT COUNT(*) FROM atletas a 
            JOIN usuarios u ON a.usuario_id = u.id 
            WHERE u.estado = 'activo'
        ),
        'entrenadores_activos', (
            SELECT COUNT(*) FROM entrenadores e 
            JOIN usuarios u ON e.usuario_id = u.id 
            WHERE u.estado = 'activo'
        ),
        'arbitros_certificados', (
            SELECT COUNT(*) FROM arbitros ar 
            JOIN usuarios u ON ar.usuario_id = u.id 
            WHERE u.estado = 'activo' AND ar.estado_licencia = 'vigente'
        ),
        'competencias_activas', (
            SELECT COUNT(*) FROM competencias 
            WHERE estado IN ('inscripciones_abiertas', 'en_progreso')
        ),
        'notificaciones_no_leidas', (
            SELECT COUNT(*) FROM notificaciones_sistema 
            WHERE es_para_admins = TRUE AND leida = FALSE
        )
    ) INTO resultado;
    
    RETURN resultado;
END;
$$ LANGUAGE plpgsql;
```

## 🔄 Flujo Completo del Sistema

### **Proceso de Registro y Solicitud**

```
🎆 FLUJO COMPLETO DE USUARIO

1. 👤 REGISTRO INICIAL
   • Usuario se registra con email/contraseña
   • Solo perfil básico (nombre, email, teléfono)
   • Rol inicial: 'usuario' (sin permisos especiales)
   • Estado: 'pendiente'

2. 📱 SOLICITUD DE ROL
   • Usuario accede a "Solicitar Rol"
   • Elige: Atleta | Entrenador | Árbitro
   • Completa formulario con:
     - Motivo de solicitud
     - Experiencia previa
     - Dojo preferido (si aplica)
     - Documentos requeridos
   • Sistema crea solicitud_rol

3. 🔔 NOTIFICACIÓN AUTOMÁTICA
   • Todos los admins reciben notificación
   • Email automático (opcional)
   • Notificación en dashboard admin
   • Prioridad según tipo de rol

4. 👨💼 REVISIÓN ADMINISTRATIVA
   • Admin ve lista de solicitudes pendientes
   • Revisa documentos subidos
   • Verifica credenciales
   • Puede solicitar información adicional
   • Aprueba o rechaza con comentarios

5. ✅ APROBACIÓN Y ACTIVACIÓN
   • Si aprueba: 
     - Cambia rol del usuario
     - Crea registro en tabla específica
     - Desbloquea funciones del rol
     - Notifica al usuario
   • Si rechaza:
     - Notifica motivo al usuario
     - Usuario puede reenviar solicitud

6. 🎉 ACCESO COMPLETO
   • Usuario accede a su panel específico
   • Funciones desbloqueadas según rol
   • Puede participar en competencias
```

### **Roles y Permisos Desbloqueados**

```
🥋 ATLETA APROBADO:
• Ver/editar perfil deportivo
• Inscribirse en competencias
• Ver sus combates programados
• Ver su ranking y estadísticas
• Subir certificado médico

👨🏫 ENTRENADOR APROBADO:
• Gestionar atletas asignados
• Ver estadísticas de sus atletas
• Inscribir atletas en competencias
• Acceso a reportes de rendimiento
• Calendario de entrenamientos

⚖️ ÁRBITRO APROBADO:
• Ver combates asignados
• Registrar puntuaciones en tiempo real
• Gestionar penalizaciones
• Acceso al sistema de simulación
• Reportes de arbitraje
```

## 🎮 Funciones Especiales para Simulación

### **Función para Iniciar Combate Simulado**
```sql
CREATE OR REPLACE FUNCTION iniciar_combate_simulacion(
    p_combate_id UUID,
    p_reglas_id UUID,
    p_arbitro_id UUID
) RETURNS UUID AS $$
DECLARE
    simulacion_id UUID;
    duracion_combate INTEGER;
BEGIN
    -- Obtener duración del combate según las reglas
    SELECT duracion_combate INTO duracion_combate 
    FROM reglas_karate WHERE id = p_reglas_id;
    
    -- Crear simulación
    INSERT INTO combate_simulacion (
        combate_id, reglas_id, tiempo_total, arbitro_controlador
    ) VALUES (
        p_combate_id, p_reglas_id, duracion_combate, p_arbitro_id
    ) RETURNING id INTO simulacion_id;
    
    -- Crear marcador inicial
    INSERT INTO marcador_tiempo_real (
        combate_simulacion_id, minuto, segundo
    ) VALUES (simulacion_id, 0, 0);
    
    RETURN simulacion_id;
END;
$$ LANGUAGE plpgsql;
```

### **Función para Registrar Técnica**
```sql
CREATE OR REPLACE FUNCTION registrar_tecnica(
    p_simulacion_id UUID,
    p_atleta_id UUID,
    p_tecnica_id UUID,
    p_tiempo INTEGER,
    p_efectividad INTEGER,
    p_arbitro_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
    puntos_tecnica INTEGER;
    reglas_record RECORD;
BEGIN
    -- Obtener reglas del combate
    SELECT r.* INTO reglas_record
    FROM combate_simulacion cs
    JOIN reglas_karate r ON cs.reglas_id = r.id
    WHERE cs.id = p_simulacion_id;
    
    -- Calcular puntos según efectividad y técnica
    SELECT 
        CASE 
            WHEN p_efectividad >= 4 THEN reglas_record.puntos_ippon
            WHEN p_efectividad >= 3 THEN reglas_record.puntos_wazari
            ELSE reglas_record.puntos_yuko
        END INTO puntos_tecnica;
    
    -- Registrar acción
    INSERT INTO acciones_combate (
        combate_simulacion_id, atleta_id, tipo_accion, tecnica_id,
        puntos_otorgados, tiempo_accion, efectividad, validada_por
    ) VALUES (
        p_simulacion_id, p_atleta_id, 'tecnica', p_tecnica_id,
        puntos_tecnica, p_tiempo, p_efectividad, p_arbitro_id
    );
    
    -- Actualizar marcador
    PERFORM actualizar_marcador(p_simulacion_id, p_atleta_id, puntos_tecnica);
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
```

### **Función para Actualizar Tabla de Posiciones**
```sql
CREATE OR REPLACE FUNCTION actualizar_tabla_posiciones(
    p_temporada_id UUID,
    p_atleta_ganador UUID,
    p_atleta_perdedor UUID,
    p_puntos_ganador INTEGER,
    p_puntos_perdedor INTEGER
) RETURNS VOID AS $$
BEGIN
    -- Actualizar ganador
    INSERT INTO tabla_posiciones (
        temporada_id, atleta_id, puntos, partidos_jugados, ganados, 
        puntos_favor, puntos_contra, diferencia_puntos
    ) VALUES (
        p_temporada_id, p_atleta_ganador, 3, 1, 1, 
        p_puntos_ganador, p_puntos_perdedor, p_puntos_ganador - p_puntos_perdedor
    )
    ON CONFLICT (temporada_id, atleta_id) DO UPDATE SET
        puntos = tabla_posiciones.puntos + 3,
        partidos_jugados = tabla_posiciones.partidos_jugados + 1,
        ganados = tabla_posiciones.ganados + 1,
        puntos_favor = tabla_posiciones.puntos_favor + p_puntos_ganador,
        puntos_contra = tabla_posiciones.puntos_contra + p_puntos_perdedor,
        diferencia_puntos = tabla_posiciones.diferencia_puntos + (p_puntos_ganador - p_puntos_perdedor),
        fecha_actualizacion = NOW();
    
    -- Actualizar perdedor
    INSERT INTO tabla_posiciones (
        temporada_id, atleta_id, puntos, partidos_jugados, perdidos,
        puntos_favor, puntos_contra, diferencia_puntos
    ) VALUES (
        p_temporada_id, p_atleta_perdedor, 0, 1, 1,
        p_puntos_perdedor, p_puntos_ganador, p_puntos_perdedor - p_puntos_ganador
    )
    ON CONFLICT (temporada_id, atleta_id) DO UPDATE SET
        partidos_jugados = tabla_posiciones.partidos_jugados + 1,
        perdidos = tabla_posiciones.perdidos + 1,
        puntos_favor = tabla_posiciones.puntos_favor + p_puntos_perdedor,
        puntos_contra = tabla_posiciones.puntos_contra + p_puntos_ganador,
        diferencia_puntos = tabla_posiciones.diferencia_puntos + (p_puntos_perdedor - p_puntos_ganador),
        fecha_actualizacion = NOW();
    
    -- Recalcular posiciones
    PERFORM recalcular_posiciones(p_temporada_id);
END;
$$ LANGUAGE plpgsql;
```

## 🚀 Plan de Implementación Administrativo

### **Fase 1: Configuración Base**
1. **Crear usuario super administrador inicial**
2. **Implementar sistema de roles y permisos**
3. **Configurar auditoría de acciones**

### **Fase 2: Panel Administrativo**
1. **Dashboard administrativo con métricas**
2. **Gestión completa de usuarios**
3. **Sistema de aprobación de registros**

### **Fase 3: Gestión de Contenido**
1. **Administración de dojos**
2. **Creación y gestión de competencias**
3. **Control de inscripciones**

### **Fase 4: Operaciones Avanzadas**
1. **Sistema de sorteos y brackets**
2. **Gestión de combates**
3. **Generación de reportes y estadísticas**

### **Fase 5: Interfaz Pública**
1. **Portal para atletas**
2. **Panel para entrenadores**
3. **Interfaz para árbitros**

## 🔧 Funciones Administrativas Especiales

```sql
-- Función para crear usuario con rol específico
CREATE OR REPLACE FUNCTION crear_usuario_con_rol(
    p_email TEXT,
    p_nombre TEXT,
    p_rol TEXT,
    p_admin_id UUID
) RETURNS UUID AS $$
DECLARE
    nuevo_usuario_id UUID;
BEGIN
    -- Verificar que quien crea es administrador
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE id = p_admin_id AND es_administrador = TRUE) THEN
        RAISE EXCEPTION 'Solo administradores pueden crear usuarios';
    END IF;
    
    -- Crear usuario en auth.users (esto se haría desde la aplicación)
    -- Crear registro en tabla usuarios
    INSERT INTO usuarios (email, nombre_completo, rol, creado_por, estado)
    VALUES (p_email, p_nombre, p_rol, p_admin_id, 'pendiente')
    RETURNING id INTO nuevo_usuario_id;
    
    -- Registrar acción en auditoría
    INSERT INTO auditoria_acciones (usuario_id, accion, tabla_afectada, registro_id)
    VALUES (p_admin_id, 'crear_usuario', 'usuarios', nuevo_usuario_id);
    
    RETURN nuevo_usuario_id;
END;
$$ LANGUAGE plpgsql;
```

## 📊 Vistas Especiales para Reportes

### **Vista de Tabla de Posiciones Completa**
```sql
CREATE VIEW vista_tabla_posiciones AS
SELECT 
    tp.*,
    u.nombre_completo as nombre_atleta,
    t.nombre as nombre_temporada,
    t.año,
    RANK() OVER (PARTITION BY tp.temporada_id ORDER BY tp.puntos DESC, tp.diferencia_puntos DESC) as posicion_actual,
    CASE 
        WHEN tp.posicion = 1 THEN '🥇'
        WHEN tp.posicion = 2 THEN '🥈' 
        WHEN tp.posicion = 3 THEN '🥉'
        ELSE ''
    END as emoji_posicion
FROM tabla_posiciones tp
JOIN atletas a ON tp.atleta_id = a.id
JOIN usuarios u ON a.usuario_id = u.id
JOIN temporadas t ON tp.temporada_id = t.id;
```

### **Vista de Estadísticas de Combate**
```sql
CREATE VIEW vista_estadisticas_combate AS
SELECT 
    cs.combate_id,
    cs.tiempo_total,
    cs.tiempo_transcurrido,
    cs.puntos_atleta1,
    cs.puntos_atleta2,
    u1.nombre_completo as atleta1_nombre,
    u2.nombre_completo as atleta2_nombre,
    COUNT(ac.id) as total_acciones,
    COUNT(CASE WHEN ac.tipo_accion = 'tecnica' THEN 1 END) as total_tecnicas,
    COUNT(pc.id) as total_penalizaciones,
    AVG(ac.efectividad) as efectividad_promedio
FROM combate_simulacion cs
JOIN combates c ON cs.combate_id = c.id
JOIN atletas a1 ON c.atleta1_id = a1.id
JOIN atletas a2 ON c.atleta2_id = a2.id
JOIN usuarios u1 ON a1.usuario_id = u1.id
JOIN usuarios u2 ON a2.usuario_id = u2.id
LEFT JOIN acciones_combate ac ON cs.id = ac.combate_simulacion_id
LEFT JOIN penalizaciones_combate pc ON cs.id = pc.combate_simulacion_id
GROUP BY cs.id, cs.combate_id, cs.tiempo_total, cs.tiempo_transcurrido, 
         cs.puntos_atleta1, cs.puntos_atleta2, u1.nombre_completo, u2.nombre_completo;
```

### **Vista de Técnicas Más Utilizadas**
```sql
CREATE VIEW vista_tecnicas_populares AS
SELECT 
    tk.nombre,
    tk.nombre_japones,
    tk.tipo,
    COUNT(ac.id) as veces_utilizada,
    AVG(ac.efectividad) as efectividad_promedio,
    AVG(ac.puntos_otorgados) as puntos_promedio,
    COUNT(DISTINCT ac.atleta_id) as atletas_diferentes
FROM tecnicas_karate tk
JOIN acciones_combate ac ON tk.id = ac.tecnica_id
WHERE ac.tipo_accion = 'tecnica'
GROUP BY tk.id, tk.nombre, tk.nombre_japones, tk.tipo
ORDER BY veces_utilizada DESC;
```

## 🎯 Triggers Automáticos

### **Trigger para Actualizar Posiciones Automáticamente**
```sql
CREATE OR REPLACE FUNCTION trigger_actualizar_posiciones()
RETURNS TRIGGER AS $$
BEGIN
    -- Recalcular posiciones cuando se actualiza la tabla
    UPDATE tabla_posiciones 
    SET posicion = subquery.nueva_posicion
    FROM (
        SELECT 
            id,
            ROW_NUMBER() OVER (
                PARTITION BY temporada_id 
                ORDER BY puntos DESC, diferencia_puntos DESC, puntos_favor DESC
            ) as nueva_posicion
        FROM tabla_posiciones 
        WHERE temporada_id = NEW.temporada_id
    ) as subquery
    WHERE tabla_posiciones.id = subquery.id
    AND tabla_posiciones.temporada_id = NEW.temporada_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_recalcular_posiciones
    AFTER INSERT OR UPDATE ON tabla_posiciones
    FOR EACH ROW
    EXECUTE FUNCTION trigger_actualizar_posiciones();
```

### **Trigger para Auditoría de Combates**
```sql
CREATE OR REPLACE FUNCTION trigger_auditoria_combate()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO auditoria_acciones (
        usuario_id, accion, tabla_afectada, registro_id, datos_nuevos
    ) VALUES (
        NEW.arbitro_controlador, 
        'combate_simulacion', 
        'combate_simulacion', 
        NEW.id,
        row_to_json(NEW)
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_audit_combate_simulacion
    AFTER INSERT OR UPDATE ON combate_simulacion
    FOR EACH ROW
    EXECUTE FUNCTION trigger_auditoria_combate();
```

---

**🏆 Sistema Completo de Gestión de Karate con Simulación - Equipo Dinamita**
