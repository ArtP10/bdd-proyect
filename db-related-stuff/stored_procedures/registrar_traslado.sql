CREATE OR REPLACE PROCEDURE sp_registrar_traslado(
    IN i_usu_codigo INTEGER,
    IN i_rut_codigo INTEGER,
    IN i_med_tra_codigo INTEGER,
    IN i_fecha_inicio TIMESTAMP,
    IN i_fecha_fin TIMESTAMP,
    IN i_co2 NUMERIC,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_pro_id INTEGER;
BEGIN
    -- A. Validar Privilegio
    IF NOT EXISTS (
        SELECT 1 FROM usuario u JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'crear_recursos'
    ) THEN
        o_status_code := 403; o_mensaje := 'No tiene permisos para crear traslados.'; RETURN;
    END IF;

    -- B. VALIDACIONES DE FECHA (NUEVO)
    -- 1. No se puede viajar al pasado
    IF i_fecha_inicio < CURRENT_TIMESTAMP THEN
        o_status_code := 400; -- Bad Request
        o_mensaje := 'Error: La fecha de salida no puede ser en el pasado.';
        RETURN;
    END IF;

    -- 2. Coherencia temporal
    IF i_fecha_fin <= i_fecha_inicio THEN
        o_status_code := 400; 
        o_mensaje := 'Error: La fecha de llegada debe ser posterior a la salida.';
        RETURN;
    END IF;

    -- C. Obtener ID del Proveedor
    SELECT p.pro_codigo INTO v_pro_id
    FROM proveedor p JOIN usuario u ON p.fk_usu_codigo = u.usu_codigo
    WHERE u.usu_codigo = i_usu_codigo;

    IF v_pro_id IS NULL THEN
        o_status_code := 404; o_mensaje := 'Usuario no es proveedor.'; RETURN;
    END IF;

    -- D. Validar Propiedad (Ruta y Transporte)
    IF NOT EXISTS (SELECT 1 FROM ruta WHERE rut_codigo = i_rut_codigo AND fk_pro_codigo = v_pro_id) THEN
        o_status_code := 409; o_mensaje := 'Error: La ruta no pertenece a su organización.'; RETURN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM medio_transporte WHERE med_tra_codigo = i_med_tra_codigo AND fk_pro_codigo = v_pro_id) THEN
        o_status_code := 409; o_mensaje := 'Error: El transporte no pertenece a su flota.'; RETURN;
    END IF;

    -- E. Validar Disponibilidad (Solapamiento)
    IF EXISTS (
        SELECT 1 FROM traslado 
        WHERE fk_med_tra_codigo = i_med_tra_codigo
        AND (
            (tras_fecha_hora_inicio BETWEEN i_fecha_inicio AND i_fecha_fin) OR
            (tras_fecha_hora_fin BETWEEN i_fecha_inicio AND i_fecha_fin) OR
            (i_fecha_inicio BETWEEN tras_fecha_hora_inicio AND tras_fecha_hora_fin)
        )
    ) THEN
        o_status_code := 409; 
        o_mensaje := 'El avión ya tiene un viaje programado que choca con este horario.'; 
        RETURN;
    END IF;

    -- F. Insertar
    INSERT INTO traslado (tras_fecha_hora_inicio, tras_fecha_hora_fin, tras_CO2_Emitido, fk_rut_codigo, fk_med_tra_codigo)
    VALUES (i_fecha_inicio, i_fecha_fin, i_co2, i_rut_codigo, i_med_tra_codigo);

    o_status_code := 201;
    o_mensaje := 'Traslado programado exitosamente.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500; o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;