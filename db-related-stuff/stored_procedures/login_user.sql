CREATE OR REPLACE PROCEDURE sp_login_usuario(
    IN i_busqueda_nombre varchar,
    IN i_busqueda_contrasena varchar,
    IN i_busqueda_tipo varchar,
    INOUT o_usu_codigo integer DEFAULT NULL,
    INOUT o_usu_nombre varchar DEFAULT NULL,
    INOUT o_usu_rol varchar DEFAULT NULL,
    INOUT o_status_code integer DEFAULT NULL,
    INOUT o_mensaje varchar DEFAULT NULL,
    INOUT o_rol_privilegios TEXT[] DEFAULT NULL,
    INOUT o_usu_correo varchar DEFAULT NULL -- Se eliminó la coma aquí
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_contrasena_guardada varchar;
    v_rol_nombre varchar;
    v_rol_codigo Integer;
BEGIN
    -- 1. Buscar Usuario y Rol
    -- Corregido: u.usu_email en vez de u.o_usu_correo
    -- Corregido: r.rol_codigo en vez de r.rol_codigom
    SELECT u.usu_codigo, u.usu_nombre_usuario, u.usu_contrasena, r.rol_nombre, r.rol_codigo, u.usu_email
    INTO o_usu_codigo, o_usu_nombre, v_contrasena_guardada, v_rol_nombre, v_rol_codigo, o_usu_correo
    FROM usuario u
    JOIN rol r ON u.fk_rol_codigo = r.rol_codigo
    WHERE u.usu_nombre_usuario = i_busqueda_nombre;

    -- 2. Validaciones
    
    -- Caso 404: Usuario no existe
    IF o_usu_codigo IS NULL THEN
        o_status_code := 404;
        o_mensaje := 'Nombre de usuario no encontrado';
        RETURN;
    END IF;

    -- Caso 401: Contraseña incorrecta
    IF v_contrasena_guardada <> i_busqueda_contrasena THEN
        o_status_code := 401;
        o_mensaje := 'Contraseña incorrecta';
        o_usu_codigo := NULL;
        o_usu_nombre := NULL;
        o_usu_correo := NULL; -- Limpiamos el correo también por seguridad
        RETURN;
    END IF;

    -- Caso 403: Rol incorrecto
    IF v_rol_nombre <> i_busqueda_tipo THEN
        o_status_code := 403;
        o_mensaje := 'No tiene permisos para este rol';
        o_usu_codigo := NULL;
        o_usu_nombre := NULL;
        o_usu_correo := NULL;
        RETURN;
    END IF;

    -- 3. Éxito (200)
    o_usu_rol := v_rol_nombre;
    o_status_code := 200;
    o_mensaje := 'Sesion iniciada correctamente';

    -- 4. Obtener Privilegios
    SELECT COALESCE(ARRAY_AGG(p.pri_nombre), '{}')
    INTO o_rol_privilegios
    FROM privilegio p
    JOIN rol_privilegio rp ON rp.fk_pri_codigo = p.pri_codigo
    WHERE rp.fk_rol_codigo = v_rol_codigo;

END;
$$;