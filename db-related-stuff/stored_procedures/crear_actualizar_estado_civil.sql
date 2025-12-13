CREATE OR REPLACE PROCEDURE sp_actualizar_estado_civil(
    IN i_fk_via_codigo INTEGER,
    IN i_fk_edo_codigo INTEGER,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Paso A: "Cerrar" el estado civil anterior si existe uno activo (fecha fin null)
    UPDATE via_edo 
    SET via_edo_fecha_fin = CURRENT_DATE 
    WHERE fk_via_codigo = i_fk_via_codigo AND via_edo_fecha_fin IS NULL;

    -- Paso B: Insertar nuevo estado
    INSERT INTO via_edo (fk_via_codigo, fk_edo_codigo, via_edo_fecha_inicio, via_edo_fecha_fin)
    VALUES (i_fk_via_codigo, i_fk_edo_codigo, CURRENT_DATE, NULL);

    o_status_code := 200;
    o_mensaje := 'Estado civil actualizado.';
EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;