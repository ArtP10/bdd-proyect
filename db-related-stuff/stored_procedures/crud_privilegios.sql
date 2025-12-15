-- 1. Obtener todos los privilegios disponibles
CREATE OR REPLACE PROCEDURE listar_todos_privilegios(
    INOUT p_cursor REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_cursor FOR
    SELECT pri_codigo, pri_nombre, pri_descripcion 
    FROM privilegio
    ORDER BY pri_codigo;
END;
$$;

-- 2. Obtener los IDs de privilegios asignados a un rol específico
CREATE OR REPLACE PROCEDURE obtener_privilegios_rol(
    IN p_rol_codigo INT,
    INOUT p_cursor REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_cursor FOR
    SELECT fk_pri_codigo 
    FROM rol_privilegio
    WHERE fk_rol_codigo = p_rol_codigo;
END;
$$;

-- 3. Asignar un privilegio a un rol
-- Usamos ON CONFLICT DO NOTHING para evitar errores si ya existe
CREATE OR REPLACE PROCEDURE asignar_privilegio_rol(
    IN p_rol_codigo INT,
    IN p_pri_codigo INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO rol_privilegio(fk_rol_codigo, fk_pri_codigo)
    VALUES (p_rol_codigo, p_pri_codigo)
    ON CONFLICT (fk_pri_codigo, fk_rol_codigo) DO NOTHING;
END;
$$;

-- 4. Quitar un privilegio de un rol
CREATE OR REPLACE PROCEDURE revocar_privilegio_rol(
    IN p_rol_codigo INT,
    IN p_pri_codigo INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM rol_privilegio
    WHERE fk_rol_codigo = p_rol_codigo AND fk_pri_codigo = p_pri_codigo;
END;
$$;