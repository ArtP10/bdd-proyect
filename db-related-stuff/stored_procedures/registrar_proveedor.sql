CREATE OR REPLACE PROCEDURE sp_registrar_proveedor(
    IN i_admin_id INTEGER,
    IN i_prov_nombre VARCHAR,
    IN i_prov_fecha_creacion DATE, -- Nuevo parámetro DATE
    IN i_prov_tipo VARCHAR,
    IN i_fk_lugar INTEGER,
    IN i_usu_nombre VARCHAR,
    IN i_usu_contrasena VARCHAR,
    IN i_usu_email VARCHAR,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_rol_prov_id INTEGER;
    v_nuevo_usu_id INTEGER;
BEGIN
    -- Validar Privilegio 'crear_usuarios'
    IF NOT EXISTS (
        SELECT 1 FROM usuario u 
        JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo 
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo 
        WHERE u.usu_codigo = i_admin_id AND p.pri_nombre = 'crear_usuarios'
    ) THEN
        o_status_code := 403; o_mensaje := 'No tiene privilegios para crear proveedores.'; RETURN;
    END IF;

    -- Obtener Rol 'Proveedor'
    SELECT rol_codigo INTO v_rol_prov_id FROM rol WHERE rol_nombre = 'Proveedor';
    
    -- Crear Usuario (asociado al lugar)
    INSERT INTO usuario (usu_nombre_usuario, usu_contrasena, fk_rol_codigo, usu_total_millas, usu_email, fk_lugar)
    VALUES (i_usu_nombre, i_usu_contrasena, v_rol_prov_id, 0, i_usu_email, i_fk_lugar)
    RETURNING usu_codigo INTO v_nuevo_usu_id;

    -- Crear Proveedor (Usando prov_fecha_creacion)
    INSERT INTO proveedor (prov_nombre, prov_fecha_creacion, prov_tipo, fk_lugar, fk_usu_codigo)
    VALUES (i_prov_nombre, i_prov_fecha_creacion, i_prov_tipo, i_fk_lugar, v_nuevo_usu_id);

    o_status_code := 201;
    o_mensaje := 'Proveedor registrado exitosamente.';

EXCEPTION 
    WHEN unique_violation THEN
        o_status_code := 409; o_mensaje := 'El usuario o correo ya existe.';
    WHEN OTHERS THEN
        o_status_code := 500; o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;