CREATE OR REPLACE PROCEDURE sp_crear_viajero(
    IN i_usu_codigo INTEGER,         -- ID del usuario que hace la petición
    IN i_via_prim_nombre VARCHAR,
    IN i_via_seg_nombre VARCHAR,
    IN i_via_prim_apellido VARCHAR,
    IN i_via_seg_apellido VARCHAR,
    IN i_via_fecha_nacimiento DATE,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL,
    INOUT o_via_codigo INTEGER DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validación de privilegio
    IF NOT EXISTS (
        SELECT 1 FROM rol_privilegio rp 
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo 
        JOIN usuario u ON u.fk_rol_codigo = rp.fk_rol_codigo 
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'manipular_viajeros'
    ) THEN
        o_status_code := 403;
        o_mensaje := 'No tiene privilegios para manipular viajeros.';
        RETURN;
    END IF;

    INSERT INTO viajero (via_prim_nombre, via_seg_nombre, via_prim_apellido, via_seg_apellido, via_fecha_nacimiento, fk_usu_codigo)
    VALUES (i_via_prim_nombre, i_via_seg_nombre, i_via_prim_apellido, i_via_seg_apellido, i_via_fecha_nacimiento, i_usu_codigo)
    RETURNING via_codigo INTO o_via_codigo;

    o_status_code := 201;
    o_mensaje := 'Viajero registrado exitosamente.';
EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;