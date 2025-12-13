CREATE OR REPLACE PROCEDURE sp_eliminar_ruta(
    IN i_usu_codigo INTEGER,
    IN i_rut_codigo INTEGER,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    -- 1. Validar Permisos
    IF NOT EXISTS (
        SELECT 1 FROM usuario u JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'eliminar_recursos'
    ) THEN
        o_status_code := 403; o_mensaje := 'No tiene permisos para eliminar rutas.'; RETURN;
    END IF;

    -- 2. Validar Traslados Activos o Futuros
    IF EXISTS (
        SELECT 1 FROM traslado 
        WHERE fk_rut_codigo = i_rut_codigo 
        AND tras_fecha_hora_fin >= CURRENT_TIMESTAMP
    ) THEN
        o_status_code := 409; -- Conflict
        o_mensaje := 'No se puede eliminar: Hay vuelos activos o programados en esta ruta.';
        RETURN;
    END IF;

    -- 3. Eliminar (Si hay historial antiguo se puede bloquear o hacer soft-delete, aqui haremos hard delete si no hay activos)
    -- Nota: Si hay vuelos pasados, la FK de traslado fallará si no es ON DELETE CASCADE. 
    -- Asumiremos que solo queremos borrar si NO hay historial para integridad. 
    -- Si quieres permitir borrar rutas con historial viejo, habría que poner fk a null en traslados viejos.
    
    IF EXISTS (SELECT 1 FROM traslado WHERE fk_rut_codigo = i_rut_codigo) THEN
         o_status_code := 409; 
         o_mensaje := 'No se puede eliminar: Esta ruta tiene historial de vuelos. Contacte soporte.';
         RETURN;
    END IF;

    DELETE FROM ruta WHERE rut_codigo = i_rut_codigo;
    
    o_status_code := 200;
    o_mensaje := 'Ruta eliminada correctamente.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500; o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;