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
    v_pro_id INTEGER;
    v_rut_pro_id INTEGER;
    v_med_tra_id INTEGER;
BEGIN
    -- A. Validar Privilegio
    IF NOT EXISTS (
        SELECT 1 FROM usuario u JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'modificar_recursos'
    ) THEN
        o_status_code := 403; o_mensaje := 'No tiene permisos para modificar traslados.'; RETURN;
    END IF;

    -- B. VALIDACIONES DE FECHA (NUEVO)
    -- 1. No se puede reprogramar al pasado
    IF i_nueva_fecha_inicio < CURRENT_TIMESTAMP THEN
        o_status_code := 400; 
        o_mensaje := 'Error: No se puede reprogramar un vuelo a una fecha pasada.';
        RETURN;
    END IF;

    -- 2. Coherencia
    IF i_nueva_fecha_fin <= i_nueva_fecha_inicio THEN
        o_status_code := 400; 
        o_mensaje := 'Error: La fecha de llegada debe ser posterior a la salida.';
        RETURN;
    END IF;

    -- C. Validar Propiedad
    SELECT p.pro_codigo INTO v_pro_id
    FROM proveedor p JOIN usuario u ON p.fk_usu_codigo = u.usu_codigo
    WHERE u.usu_codigo = i_usu_codigo;

    SELECT r.fk_pro_codigo, t.fk_med_tra_codigo INTO v_rut_pro_id, v_med_tra_id
    FROM traslado t JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
    WHERE t.tras_codigo = i_tras_codigo;

    IF v_pro_id <> v_rut_pro_id OR v_rut_pro_id IS NULL THEN
        o_status_code := 403; o_mensaje := 'No puede modificar un traslado que no le pertenece.'; RETURN;
    END IF;

    -- D. Validar Disponibilidad (Solapamiento al reprogramar)
    -- Debemos excluir el MISMO traslado que estamos editando (AND tras_codigo <> i_tras_codigo)
    IF EXISTS (
        SELECT 1 FROM traslado 
        WHERE fk_med_tra_codigo = v_med_tra_id
        AND tras_codigo <> i_tras_codigo -- ¡Importante! No chocar consigo mismo
        AND (
            (tras_fecha_hora_inicio BETWEEN i_nueva_fecha_inicio AND i_nueva_fecha_fin) OR
            (tras_fecha_hora_fin BETWEEN i_nueva_fecha_inicio AND i_nueva_fecha_fin) OR
            (i_nueva_fecha_inicio BETWEEN tras_fecha_hora_inicio AND tras_fecha_hora_fin)
        )
    ) THEN
        o_status_code := 409; 
        o_mensaje := 'El nuevo horario entra en conflicto con otro vuelo de este avión.'; 
        RETURN;
    END IF;

    -- E. Actualizar
    UPDATE traslado
    SET tras_fecha_hora_inicio = i_nueva_fecha_inicio,
        tras_fecha_hora_fin = i_nueva_fecha_fin
    WHERE tras_codigo = i_tras_codigo;

    o_status_code := 200;
    o_mensaje := 'Horario del traslado actualizado.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500; o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;