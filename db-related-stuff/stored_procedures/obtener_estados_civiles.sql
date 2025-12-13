CREATE OR REPLACE PROCEDURE sp_obtener_estados_civiles(
    INOUT o_cursor REFCURSOR DEFAULT NULL,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    OPEN o_cursor FOR SELECT * FROM estado_civil ORDER BY edo_civ_codigo ASC;
    o_status_code := 200;
END; $$;