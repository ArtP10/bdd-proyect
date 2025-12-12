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
BEGIN
    -- 1. Validar que el rol 'Cliente' exista
    SELECT rol_codigo INTO v_rol_cliente_id FROM rol WHERE rol_nombre = 'Cliente';
    
    IF v_rol_cliente_id IS NULL THEN
        o_status_code := 500;
        o_mensaje := 'Error: El rol Cliente no está configurado en la base de datos.';
        RETURN;
    END IF;

    -- 2. Validar si el usuario ya existe
    IF EXISTS (SELECT 1 FROM usuario WHERE usu_nombre_usuario = i_nombre_usuario) THEN
        o_status_code := 409; -- Conflict
        o_mensaje := 'El nombre de usuario ya está en uso.';
        RETURN;
    END IF;

    -- 3. Validar si el correo ya existe (Dada tu restricción UNIQUE)
    IF EXISTS (SELECT 1 FROM usuario WHERE usu_email = i_correo) THEN
        o_status_code := 409; -- Conflict
        o_mensaje := 'El correo electrónico ya está registrado.';
        RETURN;
    END IF;

    -- 4. Insertar el Usuario (AHORA INCLUYENDO EL EMAIL)
    INSERT INTO usuario (
        usu_nombre_usuario, 
        usu_contrasena, 
        fk_rol_codigo, 
        usu_total_millas, 
        usu_email -- <--- Aquí estaba el problema, ahora lo incluimos
    )
    VALUES (
        i_nombre_usuario, 
        i_contrasena, 
        v_rol_cliente_id, 
        0, 
        i_correo -- <--- Insertamos el valor que viene de Vue
    )
    RETURNING usu_codigo INTO o_usu_codigo;

    -- 5. Retornar éxito
    o_status_code := 201; -- Created
    o_mensaje := 'Usuario registrado exitosamente.';
    o_usu_nombre := i_nombre_usuario;
    o_usu_correo := i_correo;

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error interno del servidor: ' || SQLERRM;
END;
$$;