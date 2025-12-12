CREATE OR REPLACE PROCEDURE sp_obtener_lugares_operacion(
    INOUT o_cursor REFCURSOR DEFAULT NULL,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    OPEN o_cursor FOR 
    SELECT 
        est.lug_codigo,
        -- Concatenamos: "NombreEstado, NombrePais"
        (est.lug_nombre || ', ' || pai.lug_nombre) AS lug_nombre,
        est.lug_tipo
    FROM lugar est
    -- Unimos con su padre (El País)
    JOIN lugar pai ON est.fk_lugar = pai.lug_codigo
    -- Filtramos ÚNICAMENTE los Estados
    WHERE est.lug_tipo = 'Estado'
    ORDER BY pai.lug_nombre ASC, est.lug_nombre ASC;

    o_status_code := 200;
    o_mensaje := 'Lista de Estados obtenida correctamente.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;