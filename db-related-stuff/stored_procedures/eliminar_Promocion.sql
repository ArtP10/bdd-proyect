CREATE OR REPLACE PROCEDURE eliminar_promocion(
    IN p_codigo INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM promocion 
    WHERE prom_codigo = p_codigo;
END;
$$;