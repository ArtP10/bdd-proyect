CREATE OR REPLACE PROCEDURE sp_obtener_nacionalidades(
    INOUT o_cursor REFCURSOR DEFAULT NULL,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN o_cursor FOR
    SELECT nac_codigo, nac_nombre FROM nacionalidad ORDER BY nac_nombre ASC;

    o_status_code := 200;
    o_mensaje := 'Lista de nacionalidades obtenida.';
EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;