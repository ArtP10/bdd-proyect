CREATE OR REPLACE PROCEDURE sp_obtener_terminales_compatibles(
    IN i_usu_codigo INTEGER, -- Usamos el usuario para deducir el proveedor
    INOUT o_cursor REFCURSOR DEFAULT NULL,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_pro_tipo VARCHAR;
    v_pro_codigo INTEGER;
BEGIN
    -- 1. Obtener datos del proveedor
    SELECT p.pro_tipo, p.pro_codigo INTO v_pro_tipo, v_pro_codigo
    FROM proveedor p
    JOIN usuario u ON p.fk_usu_codigo = u.usu_codigo
    WHERE u.usu_codigo = i_usu_codigo;

    IF v_pro_tipo IS NULL THEN
        o_status_code := 404;
        o_mensaje := 'Usuario no es proveedor.';
        RETURN;
    END IF;

    -- 2. Seleccionar terminales según la lógica de negocio
    OPEN o_cursor FOR
    SELECT 
        t.ter_codigo, 
        (t.ter_nombre || ' - ' || l.lug_nombre || ', ' || p.lug_nombre) AS ter_nombre_completo,
        t.ter_tipo
    FROM terminal t
    JOIN lugar l ON t.fk_lug_codigo = l.lug_codigo
    JOIN lugar p ON l.fk_lugar = p.lug_codigo
    WHERE 
        (v_pro_tipo = 'Aerolinea' AND t.ter_tipo = 'Aeropuerto') OR
        (v_pro_tipo = 'Maritimo' AND t.ter_tipo = 'Puerto') OR
        (v_pro_tipo = 'Terrestre' AND t.ter_tipo IN ('Terminal Terrestre', 'Estacion')) OR
        (v_pro_tipo = 'Otros') -- 'Otros' puede ver todo
    ORDER BY p.lug_nombre, l.lug_nombre;

    o_status_code := 200;
    o_mensaje := 'Terminales obtenidas.';
END; $$;