CREATE OR REPLACE PROCEDURE eliminar_rol(
    IN p_codigo INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM rol 
    WHERE rol_codigo = p_codigo;
END;
$$;
