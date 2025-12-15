CREATE OR REPLACE PROCEDURE editar_rol(
    IN p_codigo INT,
    IN p_nombre VARCHAR(30),
    IN p_descripcion TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE rol
    SET 
        rol_nombre = p_nombre,
        rol_descripcion = p_descripcion
    WHERE rol_codigo = p_codigo;
END;
$$;
