CREATE OR REPLACE PROCEDURE sp_obtener_proveedores(
    INOUT o_cursor REFCURSOR DEFAULT NULL,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    OPEN o_cursor FOR 
    SELECT 
        p.prov_codigo, 
        p.prov_nombre, 
        p.prov_tipo, 
        p.prov_fecha_creacion,
        -- Cálculo dinámico de antigüedad
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.prov_fecha_creacion))::INTEGER AS anos_antiguedad,
        l.lug_nombre, 
        u.usu_nombre_usuario 
    FROM proveedor p
    JOIN lugar l ON p.fk_lugar = l.lug_codigo
    JOIN usuario u ON p.fk_usu_codigo = u.usu_codigo
    ORDER BY p.prov_codigo DESC;

    o_status_code := 200;
    o_mensaje := 'Lista obtenida.';
END; $$;