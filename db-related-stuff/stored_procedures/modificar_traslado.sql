CREATE OR REPLACE PROCEDURE sp_modificar_traslado(
    IN i_usu_codigo INTEGER,
    IN i_tras_codigo INTEGER,
    IN i_nueva_fecha_inicio TIMESTAMP,
    IN i_nueva_fecha_fin TIMESTAMP,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_prov_id INTEGER;
    v_rut_prov_id INTEGER;
    v_med_tra_id INTEGER;
BEGIN
    -- Validar Permisos
    IF NOT EXISTS (
        SELECT 1 FROM usuario u JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'modificar_recursos'
    ) THEN
        o_status_code := 403; o_mensaje := 'No tiene permisos.'; RETURN;
    END IF;

    -- Validaciones Fecha
    IF i_nueva_fecha_inicio < CURRENT_TIMESTAMP THEN
        o_status_code := 400; o_mensaje := 'No puede reprogramar al pasado.'; RETURN;
    END IF;
    IF i_nueva_fecha_fin <= i_nueva_fecha_inicio THEN
        o_status_code := 400; o_mensaje := 'Fecha fin inválida.'; RETURN;
    END IF;

    -- Obtener IDs y Validar Propiedad (CORRECCIÓN: prov_codigo y fk_prov_codigo)
    SELECT p.prov_codigo INTO v_prov_id
    FROM proveedor p JOIN usuario u ON p.fk_usu_codigo = u.usu_codigo
    WHERE u.usu_codigo = i_usu_codigo;

    SELECT r.fk_prov_codigo, t.fk_med_tra_codigo INTO v_rut_prov_id, v_med_tra_id
    FROM traslado t JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
    WHERE t.tras_codigo = i_tras_codigo;

    IF v_prov_id <> v_rut_prov_id OR v_rut_prov_id IS NULL THEN
        o_status_code := 403; o_mensaje := 'No le pertenece este traslado.'; RETURN;
    END IF;

    -- Validar Solapamiento (Excluyendo el propio vuelo)
    IF EXISTS (
        SELECT 1 FROM traslado 
        WHERE fk_med_tra_codigo = v_med_tra_id
        AND tras_codigo <> i_tras_codigo
        AND (
            (tras_fecha_hora_inicio BETWEEN i_nueva_fecha_inicio AND i_nueva_fecha_fin) OR
            (tras_fecha_hora_fin BETWEEN i_nueva_fecha_inicio AND i_nueva_fecha_fin) OR
            (i_nueva_fecha_inicio BETWEEN tras_fecha_hora_inicio AND tras_fecha_hora_fin)
        )
    ) THEN
        o_status_code := 409; o_mensaje := 'Conflicto de horario con otro vuelo.'; RETURN;
    END IF;

    -- Actualizar
    UPDATE traslado
    SET tras_fecha_hora_inicio = i_nueva_fecha_inicio,
        tras_fecha_hora_fin = i_nueva_fecha_fin
    WHERE tras_codigo = i_tras_codigo;

    o_status_code := 200; o_mensaje := 'Horario actualizado.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500; o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;