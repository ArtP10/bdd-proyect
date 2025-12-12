CREATE OR REPLACE PROCEDURE sp_obtener_viajeros_usuario(
    IN i_usu_codigo INTEGER,
    INOUT o_cursor REFCURSOR DEFAULT NULL, -- Usamos cursor para devolver tablas en procedimientos
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
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
        o_mensaje := 'No tiene privilegios.';
        RETURN;
    END IF;

    OPEN o_cursor FOR
    SELECT * FROM viajero WHERE fk_usu_codigo = i_usu_codigo ORDER BY via_codigo DESC;

    o_status_code := 200;
    o_mensaje := 'Lista obtenida.';
END;
$$;