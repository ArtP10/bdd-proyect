CREATE OR REPLACE PROCEDURE sp_eliminar_ruta(
    IN i_usu_codigo INTEGER,
    IN i_rut_codigo INTEGER,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_prov_id INTEGER;
    v_rut_prov_id INTEGER;
BEGIN
    -- Validar Permisos
    IF NOT EXISTS (
        SELECT 1 FROM usuario u JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'eliminar_recursos'
    ) THEN
        o_status_code := 403; o_mensaje := 'No tiene permisos para eliminar rutas.'; RETURN;
    END IF;

    -- Validar Propiedad
    SELECT prov_codigo INTO v_prov_id FROM proveedor WHERE fk_usu_codigo = i_usu_codigo;
    SELECT fk_prov_codigo INTO v_rut_prov_id FROM ruta WHERE rut_codigo = i_rut_codigo;

    IF v_prov_id <> v_rut_prov_id OR v_rut_prov_id IS NULL THEN
        o_status_code := 403; o_mensaje := 'No puede eliminar una ruta que no le pertenece.'; RETURN;
    END IF;

    -- Validar Dependencias (Traslados)
    IF EXISTS (SELECT 1 FROM traslado WHERE fk_rut_codigo = i_rut_codigo) THEN
        o_status_code := 409; o_mensaje := 'No se puede eliminar: Existen vuelos asociados a esta ruta.'; RETURN;
    END IF;

    -- Eliminar
    DELETE FROM ruta WHERE rut_codigo = i_rut_codigo;

    o_status_code := 200; o_mensaje := 'Ruta eliminada correctamente.';
EXCEPTION WHEN OTHERS THEN
    o_status_code := 500; o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;