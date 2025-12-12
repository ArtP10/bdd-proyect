CREATE OR REPLACE PROCEDURE sp_registrar_proveedor(
    IN i_admin_id INTEGER,
    IN i_pro_nombre VARCHAR,
    IN i_pro_anos INTEGER,
    IN i_pro_tipo VARCHAR,
    IN i_fk_lugar INTEGER,    -- Este lugar se usará para el Proveedor Y para el Usuario
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
    -- A. Validar Privilegio
    IF NOT EXISTS (
        SELECT 1 FROM rol_privilegio rp 
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo 
        JOIN usuario u ON u.fk_rol_codigo = rp.fk_rol_codigo 
        WHERE u.usu_codigo = i_admin_id AND p.pri_nombre = 'crear_usuarios'
    ) THEN
        o_status_code := 403;
        o_mensaje := 'No tiene privilegios para crear proveedores.';
        RETURN;
    END IF;

    -- B. Obtener Rol
    SELECT rol_codigo INTO v_rol_prov_id FROM rol WHERE rol_nombre = 'Proveedor';
    
    IF v_rol_prov_id IS NULL THEN
        o_status_code := 500;
        o_mensaje := 'Error: El rol Proveedor no existe en BD.';
        RETURN;
    END IF;

    -- C. Crear Usuario (Asignándole el MISMO lugar que al proveedor)
    INSERT INTO usuario (
        usu_nombre_usuario, 
        usu_contrasena, 
        fk_rol_codigo, 
        usu_total_millas, 
        usu_email,
        fk_lugar -- NUEVO CAMPO
    )
    VALUES (
        i_usu_nombre, 
        i_usu_contrasena, 
        v_rol_prov_id, 
        0, 
        i_usu_email,
        i_fk_lugar -- Reutilizamos el lugar del input
    )
    RETURNING usu_codigo INTO v_nuevo_usu_id;

    -- D. Crear Proveedor
    INSERT INTO proveedor (pro_nombre, pro_anos_servicio, pro_tipo, fk_lugar, fk_usu_codigo)
    VALUES (i_pro_nombre, i_pro_anos, i_pro_tipo, i_fk_lugar, v_nuevo_usu_id);

    o_status_code := 201;
    o_mensaje := 'Proveedor registrado exitosamente.';

EXCEPTION 
    WHEN unique_violation THEN
        o_status_code := 409;
        o_mensaje := 'El usuario o correo ya existe.';
    WHEN OTHERS THEN
        o_status_code := 500;
        o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;