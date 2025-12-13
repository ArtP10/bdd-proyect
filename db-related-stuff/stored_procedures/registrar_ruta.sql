CREATE OR REPLACE PROCEDURE sp_registrar_ruta(
    IN i_usu_codigo INTEGER,
    IN i_costo NUMERIC,
    IN i_millas NUMERIC,
    IN i_fk_origen INTEGER,
    IN i_fk_destino INTEGER,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_pro_id INTEGER;
    v_pro_tipo VARCHAR;
    v_tipo_origen VARCHAR;
    v_tipo_destino VARCHAR;
BEGIN
    -- A. Validar Privilegio 'crear_recursos'
    IF NOT EXISTS (
        SELECT 1 FROM usuario u JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'crear_recursos'
    ) THEN
        o_status_code := 403; o_mensaje := 'No tiene permisos para crear rutas.'; RETURN;
    END IF;

    -- B. Obtener Datos del Proveedor
    SELECT pro_codigo, pro_tipo INTO v_pro_id, v_pro_tipo
    FROM proveedor WHERE fk_usu_codigo = i_usu_codigo;

    -- C. Validar Origen != Destino
    IF i_fk_origen = i_fk_destino THEN
        o_status_code := 400; o_mensaje := 'El origen y el destino no pueden ser iguales.'; RETURN;
    END IF;

    -- D. Obtener Tipos de las Terminales seleccionadas
    SELECT ter_tipo INTO v_tipo_origen FROM terminal WHERE ter_codigo = i_fk_origen;
    SELECT ter_tipo INTO v_tipo_destino FROM terminal WHERE ter_codigo = i_fk_destino;

    -- E. VALIDACIÓN DE CONSISTENCIA (El Constraint Lógico)
    IF v_pro_tipo = 'Aerolinea' AND (v_tipo_origen <> 'Aeropuerto' OR v_tipo_destino <> 'Aeropuerto') THEN
        o_status_code := 409; o_mensaje := 'Una Aerolínea solo puede crear rutas entre Aeropuertos.'; RETURN;
    END IF;

    IF v_pro_tipo = 'Maritimo' AND (v_tipo_origen <> 'Puerto' OR v_tipo_destino <> 'Puerto') THEN
        o_status_code := 409; o_mensaje := 'Un proveedor Marítimo solo opera entre Puertos.'; RETURN;
    END IF;

    IF v_pro_tipo = 'Terrestre' AND (v_tipo_origen NOT IN ('Terminal Terrestre', 'Estacion') OR v_tipo_destino NOT IN ('Terminal Terrestre', 'Estacion')) THEN
        o_status_code := 409; o_mensaje := 'Proveedor Terrestre solo opera en Terminales o Estaciones.'; RETURN;
    END IF;

    -- F. Insertar
    INSERT INTO ruta (rut_costo, rut_millas_otorgadas, fk_terminal_origen, fk_terminal_destino, fk_pro_codigo)
    VALUES (i_costo, i_millas, i_fk_origen, i_fk_destino, v_pro_id);

    o_status_code := 201;
    o_mensaje := 'Ruta creada exitosamente.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500; o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;