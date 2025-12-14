CREATE OR REPLACE PROCEDURE sp_modificar_ruta(
    IN i_usu_codigo INTEGER,
    IN i_rut_codigo INTEGER,
    IN i_nuevo_costo NUMERIC,
    IN i_nuevas_millas INTEGER,
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
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'modificar_recursos'
    ) THEN
        o_status_code := 403; o_mensaje := 'No tiene permisos para modificar rutas.'; RETURN;
    END IF;

    -- Validar Propiedad
    SELECT prov_codigo INTO v_prov_id FROM proveedor WHERE fk_usu_codigo = i_usu_codigo;
    SELECT fk_prov_codigo INTO v_rut_prov_id FROM ruta WHERE rut_codigo = i_rut_codigo;

    IF v_prov_id <> v_rut_prov_id OR v_rut_prov_id IS NULL THEN
        o_status_code := 403; o_mensaje := 'No puede modificar una ruta que no le pertenece.'; RETURN;
    END IF;

    -- Actualizar
    UPDATE ruta
    SET rut_costo = i_nuevo_costo,
        rut_millas_otorgadas = i_nuevas_millas
    WHERE rut_codigo = i_rut_codigo;

    o_status_code := 200; o_mensaje := 'Ruta actualizada correctamente.';
EXCEPTION WHEN OTHERS THEN
    o_status_code := 500; o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;