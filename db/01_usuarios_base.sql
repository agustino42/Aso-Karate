-- =====================================================
-- 🥋 ASO KARATE 2 - FASE 1: CONFIGURACIÓN BASE
-- =====================================================
-- Tablas fundamentales para usuarios, roles y permisos
-- =====================================================

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. TABLA DE ROLES
-- =====================================================
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    nivel_acceso INTEGER NOT NULL DEFAULT 1, -- 1=básico, 5=super_admin
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. TABLA DE PERMISOS
-- =====================================================
CREATE TABLE permisos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT,
    modulo VARCHAR(50) NOT NULL, -- usuarios, atletas, competencias, etc.
    accion VARCHAR(50) NOT NULL, -- crear, leer, actualizar, eliminar
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 3. TABLA DE USUARIOS (extiende auth.users de Supabase)
-- =====================================================
CREATE TABLE usuarios (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    nombre_completo VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    fecha_nacimiento DATE,
    direccion TEXT,
    es_administrador BOOLEAN DEFAULT FALSE,
    estado VARCHAR(20) DEFAULT 'activo', -- activo, inactivo, pendiente, suspendido
    avatar_url TEXT,
    creado_por UUID REFERENCES usuarios(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 4. TABLA RELACIÓN USUARIO-ROLES
-- =====================================================
CREATE TABLE usuario_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    rol_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    asignado_por UUID REFERENCES usuarios(id),
    fecha_asignacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    activo BOOLEAN DEFAULT TRUE,
    UNIQUE(usuario_id, rol_id)
);

-- =====================================================
-- 5. TABLA RELACIÓN ROL-PERMISOS
-- =====================================================
CREATE TABLE rol_permisos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rol_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permiso_id UUID NOT NULL REFERENCES permisos(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(rol_id, permiso_id)
);

-- =====================================================
-- 6. TABLA DE AUDITORÍA
-- =====================================================
CREATE TABLE auditoria_acciones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID REFERENCES usuarios(id),
    accion VARCHAR(100) NOT NULL,
    tabla_afectada VARCHAR(100),
    registro_id UUID,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- =====================================================
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_estado ON usuarios(estado);
CREATE INDEX idx_usuario_roles_usuario ON usuario_roles(usuario_id);
CREATE INDEX idx_usuario_roles_rol ON usuario_roles(rol_id);
CREATE INDEX idx_auditoria_usuario ON auditoria_acciones(usuario_id);
CREATE INDEX idx_auditoria_fecha ON auditoria_acciones(created_at);
CREATE INDEX idx_auditoria_tabla ON auditoria_acciones(tabla_afectada);

-- =====================================================
-- TRIGGERS PARA UPDATED_AT
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_usuarios_updated_at 
    BEFORE UPDATE ON usuarios 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_roles_updated_at 
    BEFORE UPDATE ON roles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- DATOS INICIALES - ROLES BÁSICOS
-- =====================================================
INSERT INTO roles (nombre, descripcion, nivel_acceso) VALUES
('super_admin', 'Super Administrador del Sistema', 5),
('admin', 'Administrador General', 4),
('organizador', 'Organizador de Competencias', 3),
('arbitro', 'Árbitro de Competencias', 2),
('entrenador', 'Entrenador de Atletas', 2),
('atleta', 'Atleta/Competidor', 1);

-- =====================================================
-- DATOS INICIALES - PERMISOS BÁSICOS
-- =====================================================
INSERT INTO permisos (nombre, descripcion, modulo, accion) VALUES
-- Usuarios
('usuarios.crear', 'Crear nuevos usuarios', 'usuarios', 'crear'),
('usuarios.leer', 'Ver información de usuarios', 'usuarios', 'leer'),
('usuarios.actualizar', 'Actualizar información de usuarios', 'usuarios', 'actualizar'),
('usuarios.eliminar', 'Eliminar usuarios', 'usuarios', 'eliminar'),

-- Roles
('roles.gestionar', 'Gestionar roles y permisos', 'roles', 'gestionar'),

-- Dashboard
('dashboard.ver', 'Acceso al dashboard', 'dashboard', 'leer'),

-- Auditoría
('auditoria.ver', 'Ver logs de auditoría', 'auditoria', 'leer');

-- =====================================================
-- ASIGNAR PERMISOS A ROLES
-- =====================================================
-- Super Admin: todos los permisos
INSERT INTO rol_permisos (rol_id, permiso_id)
SELECT r.id, p.id 
FROM roles r, permisos p 
WHERE r.nombre = 'super_admin';

-- Admin: permisos básicos de gestión
INSERT INTO rol_permisos (rol_id, permiso_id)
SELECT r.id, p.id 
FROM roles r, permisos p 
WHERE r.nombre = 'admin' 
AND p.nombre IN ('usuarios.crear', 'usuarios.leer', 'usuarios.actualizar', 'dashboard.ver');

-- Otros roles: solo lectura básica
INSERT INTO rol_permisos (rol_id, permiso_id)
SELECT r.id, p.id 
FROM roles r, permisos p 
WHERE r.nombre IN ('organizador', 'arbitro', 'entrenador', 'atleta')
AND p.nombre IN ('dashboard.ver', 'usuarios.leer');