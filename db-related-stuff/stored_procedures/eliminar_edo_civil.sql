CREATE OR REPLACE PROCEDURE sp_eliminar_historial_civil(
    IN i_via_codigo INTEGER,
    IN i_edo_codigo INTEGER,
    IN i_fecha_inicio DATE,
    INOUT o_status_code INTEGER DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM via_edo 
    WHERE fk_via_codigo = i_via_codigo 
    AND fk_edo_codigo = i_edo_codigo 
    AND via_edo_fecha_inicio = i_fecha_inicio;
    o_status_code := 200;
END; $$;