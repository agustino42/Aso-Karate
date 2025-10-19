-- =====================================================
-- 🥋 ASO KARATE 2 - FUNCIONES BASE
-- =====================================================
-- Funciones esenciales para la gestión administrativa
-- =====================================================

-- =====================================================
-- FUNCIÓN: Verificar permisos de usuario
-- =====================================================
CREATE OR REPLACE FUNCTION verificar_permiso(
    p_usuario_id UUID,
    p_permiso VARCHAR(100)
) RETURNS BOOLEAN AS $$
DECLARE
    tiene_permiso BOOLEAN := FALSE;
BEGIN
    -- Verificar si es super admin
    IF EXISTS (
        SELECT 1 FROM usuarios u
        JOIN usuario_roles ur ON u.id = ur.usuario_id
        JOIN roles r ON ur.rol_id = r.id
        WHERE u.id = p_usuario_id 
        AND r.nombre = 'super_admin' 
        AND ur.activo = TRUE
    ) THEN
        RETURN TRUE;
    END IF;
    
    -- Verificar permiso específico
    SELECT EXISTS (
        SELECT 1 
        FROM usuarios u
        JOIN usuario_roles ur ON u.id = ur.usuario_id
        JOIN rol_permisos rp ON ur.rol_id = rp.rol_id
        JOIN permisos p ON rp.permiso_id = p.id
        WHERE u.id = p_usuario_id 
        AND p.nombre = p_permiso
        AND ur.activo = TRUE
    ) INTO tiene_permiso;
    
    RETURN tiene_permiso;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCIÓN: Crear usuario con rol
-- =====================================================
CREATE OR REPLACE FUNCTION crear_usuario_con_rol(
    p_email TEXT,
    p_nombre TEXT,
    p_rol TEXT,
    p_admin_id UUID
) RETURNS UUID AS $$
DECLARE
    nuevo_usuario_id UUID;
    rol_id UUID;
BEGIN
    -- Verificar permisos del administrador
    IF NOT verificar_permiso(p_admin_id, 'usuarios.crear') THEN
        RAISE EXCEPTION 'Sin permisos para crear usuarios';
    END IF;
    
    -- Obtener ID del rol
    SELECT id INTO rol_id FROM roles WHERE nombre = p_rol AND activo = TRUE;
    IF rol_id IS NULL THEN
        RAISE EXCEPTION 'Rol no encontrado: %', p_rol;
    END IF;
    
    -- Crear usuario (el ID viene de auth.users)
    INSERT INTO usuarios (id, email, nombre_completo, estado, creado_por)
    VALUES (uuid_generate_v4(), p_email, p_nombre, 'pendiente', p_admin_id)
    RETURNING id INTO nuevo_usuario_id;
    
    -- Asignar rol
    INSERT INTO usuario_roles (usuario_id, rol_id, asignado_por)
    VALUES (nuevo_usuario_id, rol_id, p_admin_id);
    
    -- Auditoría
    INSERT INTO auditoria_acciones (usuario_id, accion, tabla_afectada, registro_id)
    VALUES (p_admin_id, 'crear_usuario', 'usuarios', nuevo_usuario_id);
    
    RETURN nuevo_usuario_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCIÓN: Asignar rol a usuario
-- =====================================================
CREATE OR REPLACE FUNCTION asignar_rol_usuario(
    p_usuario_id UUID,
    p_rol_nombre VARCHAR(50),
    p_admin_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
    rol_id UUID;
BEGIN
    -- Verificar permisos
    IF NOT verificar_permiso(p_admin_id, 'roles.gestionar') THEN
        RAISE EXCEPTION 'Sin permisos para gestionar roles';
    END IF;
    
    -- Obtener ID del rol
    SELECT id INTO rol_id FROM roles WHERE nombre = p_rol_nombre AND activo = TRUE;
    IF rol_id IS NULL THEN
        RAISE EXCEPTION 'Rol no encontrado: %', p_rol_nombre;
    END IF;
    
    -- Asignar rol (ON CONFLICT para evitar duplicados)
    INSERT INTO usuario_roles (usuario_id, rol_id, asignado_por)
    VALUES (p_usuario_id, rol_id, p_admin_id)
    ON CONFLICT (usuario_id, rol_id) DO UPDATE SET
        activo = TRUE,
        fecha_asignacion = NOW(),
        asignado_por = p_admin_id;
    
    -- Auditoría
    INSERT INTO auditoria_acciones (usuario_id, accion, tabla_afectada, registro_id)
    VALUES (p_admin_id, 'asignar_rol', 'usuario_roles', p_usuario_id);
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCIÓN: Obtener categoría automática por edad y peso
-- =====================================================
CREATE OR REPLACE FUNCTION obtener_categoria_automatica(
    p_fecha_nacimiento DATE,
    p_peso DECIMAL(5,2),
    p_genero VARCHAR(10)
) RETURNS TABLE (
    categoria_edad_id UUID,
    categoria_peso_id UUID,
    categoria_edad_nombre VARCHAR(100),
    categoria_peso_nombre VARCHAR(100)
) AS $$
DECLARE
    edad_actual INTEGER;
BEGIN
    -- Calcular edad actual
    edad_actual := EXTRACT(YEAR FROM AGE(CURRENT_DATE, p_fecha_nacimiento));
    
    RETURN QUERY
    SELECT 
        ce.id as categoria_edad_id,
        cp.id as categoria_peso_id,
        ce.nombre as categoria_edad_nombre,
        cp.nombre as categoria_peso_nombre
    FROM categorias_edad ce
    JOIN categorias_peso cp ON ce.id = cp.categoria_edad_id
    WHERE ce.edad_minima <= edad_actual 
    AND ce.edad_maxima >= edad_actual
    AND ce.activo = TRUE
    AND cp.activo = TRUE
    AND cp.genero IN (p_genero, 'mixto')
    AND (cp.peso_minimo IS NULL OR p_peso >= cp.peso_minimo)
    AND (cp.peso_maximo IS NULL OR p_peso <= cp.peso_maximo)
    ORDER BY ce.edad_minima, cp.peso_minimo
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCIÓN: Registrar acción de auditoría
-- =====================================================
CREATE OR REPLACE FUNCTION registrar_auditoria(
    p_usuario_id UUID,
    p_accion VARCHAR(100),
    p_tabla VARCHAR(100),
    p_registro_id UUID DEFAULT NULL,
    p_datos_anteriores JSONB DEFAULT NULL,
    p_datos_nuevos JSONB DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    auditoria_id UUID;
BEGIN
    INSERT INTO auditoria_acciones (
        usuario_id, accion, tabla_afectada, registro_id,
        datos_anteriores, datos_nuevos
    ) VALUES (
        p_usuario_id, p_accion, p_tabla, p_registro_id,
        p_datos_anteriores, p_datos_nuevos
    ) RETURNING id INTO auditoria_id;
    
    RETURN auditoria_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCIÓN: Obtener estadísticas del dashboard
-- =====================================================
CREATE OR REPLACE FUNCTION obtener_estadisticas_dashboard()
RETURNS TABLE (
    total_usuarios INTEGER,
    usuarios_activos INTEGER,
    total_dojos INTEGER,
    dojos_activos INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*)::INTEGER FROM usuarios) as total_usuarios,
        (SELECT COUNT(*)::INTEGER FROM usuarios WHERE estado = 'activo') as usuarios_activos,
        (SELECT COUNT(*)::INTEGER FROM dojos) as total_dojos,
        (SELECT COUNT(*)::INTEGER FROM dojos WHERE activo = TRUE) as dojos_activos;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VISTA: Usuarios con roles
-- =====================================================
CREATE VIEW vista_usuarios_roles AS
SELECT 
    u.id,
    u.email,
    u.nombre_completo,
    u.telefono,
    u.estado,
    u.es_administrador,
    u.created_at,
    STRING_AGG(r.nombre, ', ') as roles,
    STRING_AGG(r.descripcion, ', ') as roles_descripcion
FROM usuarios u
LEFT JOIN usuario_roles ur ON u.id = ur.usuario_id AND ur.activo = TRUE
LEFT JOIN roles r ON ur.rol_id = r.id AND r.activo = TRUE
GROUP BY u.id, u.email, u.nombre_completo, u.telefono, u.estado, u.es_administrador, u.created_at;

-- =====================================================
-- VISTA: Permisos por usuario
-- =====================================================
CREATE VIEW vista_permisos_usuario AS
SELECT 
    u.id as usuario_id,
    u.email,
    u.nombre_completo,
    p.nombre as permiso,
    p.descripcion as permiso_descripcion,
    p.modulo,
    p.accion,
    r.nombre as rol
FROM usuarios u
JOIN usuario_roles ur ON u.id = ur.usuario_id AND ur.activo = TRUE
JOIN roles r ON ur.rol_id = r.id AND r.activo = TRUE
JOIN rol_permisos rp ON r.id = rp.rol_id
JOIN permisos p ON rp.permiso_id = p.id;

-- =====================================================
-- POLÍTICAS RLS (Row Level Security) para Supabase
-- =====================================================
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuario_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE auditoria_acciones ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios pueden ver su propia información
CREATE POLICY "usuarios_pueden_ver_su_info" ON usuarios
    FOR SELECT USING (auth.uid() = id);

-- Política: Solo admins pueden ver todos los usuarios
CREATE POLICY "admins_pueden_ver_usuarios" ON usuarios
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM usuario_roles ur
            JOIN roles r ON ur.rol_id = r.id
            WHERE ur.usuario_id = auth.uid()
            AND r.nombre IN ('super_admin', 'admin')
            AND ur.activo = TRUE
        )
    );

-- Política: Los usuarios pueden actualizar su propia información básica
CREATE POLICY "usuarios_pueden_actualizar_su_info" ON usuarios
    FOR UPDATE USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);