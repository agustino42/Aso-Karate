-- =====================================================
-- 🥋 ASO KARATE 2 - FASE 1: CONFIGURACIÓN BÁSICA
-- =====================================================
-- Tablas de configuración: dojos, reglas, categorías
-- =====================================================

-- =====================================================
-- 1. TABLA DE DOJOS
-- =====================================================
CREATE TABLE dojos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(255) NOT NULL,
    direccion TEXT,
    telefono VARCHAR(20),
    email VARCHAR(255),
    responsable VARCHAR(255),
    ciudad VARCHAR(100),
    departamento VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. TABLA DE REGLAS DE KARATE
-- =====================================================
CREATE TABLE reglas_karate (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    duracion_combate INTEGER NOT NULL DEFAULT 180, -- segundos
    puntos_ippon INTEGER DEFAULT 3,
    puntos_wazari INTEGER DEFAULT 2,
    puntos_yuko INTEGER DEFAULT 1,
    max_penalizaciones INTEGER DEFAULT 4,
    tiempo_descanso INTEGER DEFAULT 60, -- segundos
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 3. TABLA DE CATEGORÍAS POR EDAD
-- =====================================================
CREATE TABLE categorias_edad (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL,
    edad_minima INTEGER NOT NULL,
    edad_maxima INTEGER NOT NULL,
    descripcion TEXT,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 4. TABLA DE CATEGORÍAS POR PESO
-- =====================================================
CREATE TABLE categorias_peso (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    categoria_edad_id UUID NOT NULL REFERENCES categorias_edad(id),
    nombre VARCHAR(100) NOT NULL,
    peso_minimo DECIMAL(5,2),
    peso_maximo DECIMAL(5,2),
    genero VARCHAR(10) NOT NULL CHECK (genero IN ('masculino', 'femenino', 'mixto')),
    descripcion TEXT,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 5. TABLA DE TÉCNICAS DE KARATE
-- =====================================================
CREATE TABLE tecnicas_karate (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(255) NOT NULL,
    nombre_japones VARCHAR(255),
    tipo VARCHAR(50) NOT NULL, -- puño, patada, bloqueo, kata
    descripcion TEXT,
    puntos_base INTEGER DEFAULT 1,
    dificultad INTEGER DEFAULT 1 CHECK (dificultad BETWEEN 1 AND 5),
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- =====================================================
CREATE INDEX idx_dojos_activo ON dojos(activo);
CREATE INDEX idx_dojos_ciudad ON dojos(ciudad);
CREATE INDEX idx_reglas_activo ON reglas_karate(activo);
CREATE INDEX idx_categorias_edad_activo ON categorias_edad(activo);
CREATE INDEX idx_categorias_peso_edad ON categorias_peso(categoria_edad_id);
CREATE INDEX idx_categorias_peso_genero ON categorias_peso(genero);
CREATE INDEX idx_tecnicas_tipo ON tecnicas_karate(tipo);

-- =====================================================
-- TRIGGERS PARA UPDATED_AT
-- =====================================================
CREATE TRIGGER update_dojos_updated_at 
    BEFORE UPDATE ON dojos 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reglas_updated_at 
    BEFORE UPDATE ON reglas_karate 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categorias_edad_updated_at 
    BEFORE UPDATE ON categorias_edad 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categorias_peso_updated_at 
    BEFORE UPDATE ON categorias_peso 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- DATOS INICIALES - REGLAS ESTÁNDAR
-- =====================================================
INSERT INTO reglas_karate (nombre, descripcion, duracion_combate, puntos_ippon, puntos_wazari, puntos_yuko) VALUES
('WKF Estándar', 'Reglas oficiales de la World Karate Federation', 180, 3, 2, 1),
('Nacional Colombia', 'Reglas adaptadas para competencias nacionales', 120, 3, 2, 1),
('Regional', 'Reglas para competencias regionales', 90, 2, 1, 1);

-- =====================================================
-- DATOS INICIALES - CATEGORÍAS DE EDAD
-- =====================================================
INSERT INTO categorias_edad (nombre, edad_minima, edad_maxima, descripcion) VALUES
('Pre-Infantil', 6, 8, 'Categoría para niños de 6 a 8 años'),
('Infantil', 9, 11, 'Categoría para niños de 9 a 11 años'),
('Cadete', 12, 13, 'Categoría para adolescentes de 12 a 13 años'),
('Juvenil', 14, 15, 'Categoría para jóvenes de 14 a 15 años'),
('Junior', 16, 17, 'Categoría para jóvenes de 16 a 17 años'),
('Sub-21', 18, 20, 'Categoría para adultos jóvenes de 18 a 20 años'),
('Senior', 21, 34, 'Categoría para adultos de 21 a 34 años'),
('Veteranos', 35, 100, 'Categoría para veteranos de 35 años en adelante');

-- =====================================================
-- DATOS INICIALES - CATEGORÍAS DE PESO JUVENIL
-- =====================================================
INSERT INTO categorias_peso (categoria_edad_id, nombre, peso_minimo, peso_maximo, genero) 
SELECT id, 'Hasta 45kg', NULL, 45.00, 'masculino' FROM categorias_edad WHERE nombre = 'Juvenil'
UNION ALL
SELECT id, 'Hasta 50kg', 45.01, 50.00, 'masculino' FROM categorias_edad WHERE nombre = 'Juvenil'
UNION ALL
SELECT id, 'Hasta 55kg', 50.01, 55.00, 'masculino' FROM categorias_edad WHERE nombre = 'Juvenil'
UNION ALL
SELECT id, 'Hasta 60kg', 55.01, 60.00, 'masculino' FROM categorias_edad WHERE nombre = 'Juvenil'
UNION ALL
SELECT id, 'Hasta 65kg', 60.01, 65.00, 'masculino' FROM categorias_edad WHERE nombre = 'Juvenil'
UNION ALL
SELECT id, 'Más de 65kg', 65.01, NULL, 'masculino' FROM categorias_edad WHERE nombre = 'Juvenil'
UNION ALL
SELECT id, 'Hasta 40kg', NULL, 40.00, 'femenino' FROM categorias_edad WHERE nombre = 'Juvenil'
UNION ALL
SELECT id, 'Hasta 45kg', 40.01, 45.00, 'femenino' FROM categorias_edad WHERE nombre = 'Juvenil'
UNION ALL
SELECT id, 'Hasta 50kg', 45.01, 50.00, 'femenino' FROM categorias_edad WHERE nombre = 'Juvenil'
UNION ALL
SELECT id, 'Hasta 55kg', 50.01, 55.00, 'femenino' FROM categorias_edad WHERE nombre = 'Juvenil'
UNION ALL
SELECT id, 'Más de 55kg', 55.01, NULL, 'femenino' FROM categorias_edad WHERE nombre = 'Juvenil';

-- =====================================================
-- DATOS INICIALES - TÉCNICAS BÁSICAS
-- =====================================================
INSERT INTO tecnicas_karate (nombre, nombre_japones, tipo, descripcion, puntos_base, dificultad) VALUES
-- Puños
('Puño directo', 'Choku-zuki', 'puño', 'Golpe directo con el puño', 1, 1),
('Puño invertido', 'Gyaku-zuki', 'puño', 'Golpe con el puño contrario', 1, 2),
('Gancho', 'Kagi-zuki', 'puño', 'Golpe en gancho', 2, 3),

-- Patadas
('Patada frontal', 'Mae-geri', 'patada', 'Patada directa al frente', 2, 2),
('Patada circular', 'Mawashi-geri', 'patada', 'Patada en arco', 2, 3),
('Patada lateral', 'Yoko-geri', 'patada', 'Patada hacia el lado', 2, 3),
('Patada hacia atrás', 'Ushiro-geri', 'patada', 'Patada hacia atrás', 3, 4),

-- Bloqueos
('Bloqueo alto', 'Age-uke', 'bloqueo', 'Bloqueo hacia arriba', 1, 1),
('Bloqueo medio', 'Chudan-uke', 'bloqueo', 'Bloqueo al nivel medio', 1, 1),
('Bloqueo bajo', 'Gedan-barai', 'bloqueo', 'Bloqueo hacia abajo', 1, 1);