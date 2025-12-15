CREATE OR REPLACE PROCEDURE registrar_rol(
    IN p_nombre VARCHAR(30),
    IN p_descripcion TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO rol(rol_nombre, rol_descripcion)
    VALUES (p_nombre, p_descripcion);
END;
$$;
