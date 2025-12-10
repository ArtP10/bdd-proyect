CREATE OR REPLACE PROCEDURE sp_registrar_usuario_cliente(
    IN i_nombre_usuario VARCHAR,
    IN i_contrasena VARCHAR,
    IN i_correo VARCHAR,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL,
    INOUT o_usu_codigo INTEGER DEFAULT NULL,
    INOUT o_usu_nombre VARCHAR DEFAULT NULL,
    INOUT o_usu_correo VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_rol_cliente_id INTEGER;
    v_correo_prefijo VARCHAR;
    v_correo_dominio VARCHAR;
    v_existe_usuario INTEGER;
BEGIN
    -- 1. Validar que el rol 'Cliente' exista
    SELECT rol_codigo INTO v_rol_cliente_id FROM rol WHERE rol_nombre = 'Cliente';
    
    IF v_rol_cliente_id IS NULL THEN
        o_status_code := 500;
        o_mensaje := 'Error: El rol Cliente no está configurado en la base de datos.';
        RETURN;
    END IF;

    -- 2. Validar si el usuario ya existe
    SELECT COUNT(*) INTO v_existe_usuario FROM usuario WHERE usu_nombre_usuario = i_nombre_usuario;
    
    IF v_existe_usuario > 0 THEN
        o_status_code := 409; -- Conflict
        o_mensaje := 'El nombre de usuario ya está en uso.';
        RETURN;
    END IF;

    -- 3. Desglosar el correo (separar por @)
    -- Si el correo es "juan@gmail.com", split_part 1 es "juan", 2 es "gmail.com"
    v_correo_prefijo := split_part(i_correo, '@', 1);
    v_correo_dominio := split_part(i_correo, '@', 2);

    IF v_correo_prefijo = '' OR v_correo_dominio = '' THEN
        o_status_code := 400; 
        o_mensaje := 'Formato de correo inválido.';
        RETURN;
    END IF;

    -- 4. Insertar el Usuario
    INSERT INTO usuario (usu_nombre_usuario, usu_contrasena, fk_rol_codigo, usu_total_millas)
    VALUES (i_nombre_usuario, i_contrasena, v_rol_cliente_id, 0) -- Iniciamos con 0 millas
    RETURNING usu_codigo INTO o_usu_codigo;

    -- 5. Insertar el Correo asociado
    INSERT INTO correo_electronico (cor_ele_prefijo, cor_ele_dominio, fk_usu_codigo)
    VALUES (v_correo_prefijo, v_correo_dominio, o_usu_codigo);

    -- 6. Retornar éxito y datos para el Dashboard
    o_status_code := 201; -- Created
    o_mensaje := 'Usuario registrado exitosamente.';
    o_usu_nombre := i_nombre_usuario;
    o_usu_correo := i_correo;

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error interno del servidor: ' || SQLERRM;
END;
$$;