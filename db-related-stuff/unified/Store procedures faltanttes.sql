-- 1. OBTENER SERVICIOS (Para llenar el select de Hoteles/Restaurantes)
CREATE OR REPLACE FUNCTION sp_listar_servicios_disponibles()
RETURNS TABLE (
    id INT,
    nombre VARCHAR,
    tipo VARCHAR,
    costo NUMERIC
) AS $$
BEGIN
    RETURN QUERY 
    SELECT ser_codigo, ser_nombre, ser_tipo, ser_costo 
    FROM servicio 
    WHERE ser_tipo IN ('Alojamiento', 'Comida', 'Restaurante', 'Hotel'); 
END;
$$ LANGUAGE plpgsql;

-- 2. OBTENER TRASLADOS (Con información legible de la ruta)
CREATE OR REPLACE FUNCTION sp_listar_traslados_disponibles()
RETURNS TABLE (
    id INT,
    descripcion TEXT,
    costo NUMERIC
) AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        t.tras_codigo, 
        (mt.med_tra_tipo || ' - ' || term_o.ter_nombre || ' -> ' || term_d.ter_nombre)::TEXT,
        r.rut_costo
    FROM traslado t
    JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
    JOIN terminal term_o ON r.fk_terminal_origen = term_o.ter_codigo
    JOIN terminal term_d ON r.fk_terminal_destino = term_d.ter_codigo
    JOIN medio_transporte mt ON t.fk_med_tra_codigo = mt.med_tra_codigo;
END;
$$ LANGUAGE plpgsql;

-- 3. ASIGNAR SERVICIO A PAQUETE (Hoteles, Restaurantes, etc.)
CREATE OR REPLACE PROCEDURE sp_asignar_servicio_paquete(
    _id_paquete INT,
    _id_servicio INT,
    _cantidad INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insertar si no existe (upsert simple)
    INSERT INTO paq_ser (fk_paq_tur_codigo, fk_ser_codigo, cantidad)
    VALUES (_id_paquete, _id_servicio, _cantidad)
    ON CONFLICT (fk_paq_tur_codigo, fk_ser_codigo) 
    DO UPDATE SET cantidad = paq_ser.cantidad + _cantidad;
END;
$$;

-- 4. ASIGNAR TRASLADO A PAQUETE
CREATE OR REPLACE PROCEDURE sp_asignar_traslado_paquete(
    _id_paquete INT,
    _id_traslado INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO paq_tras (fk_paq_tur_codigo, fk_tras_codigo)
    VALUES (_id_paquete, _id_traslado)
    ON CONFLICT (fk_paq_tur_codigo, fk_tras_codigo) DO NOTHING;
END;
$$;


-- 2. OBTENER REGLAS (Con Cursor)
-- Coincide con: CALL sp_obtener_reglas_paquete(NULL, NULL, NULL)
CREATE OR REPLACE PROCEDURE sp_obtener_reglas_paquete(
    INOUT o_cursor REFCURSOR DEFAULT NULL,
    INOUT o_status_code INT DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    o_cursor := 'cur_reglas'; -- Nombre del cursor
    
    OPEN o_cursor FOR
        SELECT * FROM regla_paquete ORDER BY reg_paq_codigo DESC;

    o_status_code := 200;
    o_mensaje := 'Reglas obtenidas correctamente';
EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error al listar reglas: ' || SQLERRM;
END;
$$;

-- 3. ASIGNAR REGLA A PAQUETE
-- Coincide con: CALL sp_asignar_regla_paquete($1, $2, NULL, NULL)
CREATE OR REPLACE PROCEDURE sp_asignar_regla_paquete(
    IN _fk_paquete INT,
    IN _fk_regla INT,
    INOUT o_status_code INT DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificamos si ya existe la asignación para no duplicar
    IF EXISTS (SELECT 1 FROM reg_paq_paq WHERE fk_paq_tur_codigo = _fk_paquete AND fk_reg_paq_codigo = _fk_regla) THEN
        o_status_code := 409; -- Conflict
        o_mensaje := 'Esta regla ya está asignada al paquete';
        RETURN;
    END IF;

    INSERT INTO reg_paq_paq (fk_paq_tur_codigo, fk_reg_paq_codigo)
    VALUES (_fk_paquete, _fk_regla);

    o_status_code := 201;
    o_mensaje := 'Regla asignada correctamente';
EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error al asignar regla: ' || SQLERRM;
END;
$$;


CREATE OR REPLACE PROCEDURE sp_obtener_paquetes_turisticos(
    OUT o_cursor REFCURSOR,
    OUT o_status_code INTEGER,
    OUT o_mensaje VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Abrimos el cursor con todos los datos
    OPEN o_cursor FOR
        SELECT 
            paq_tur_codigo,
            paq_tur_nombre,
            paq_tur_monto_total,
            paq_tur_monto_subtotal,
            paq_tur_costo_en_millas
        FROM paquete_turistico
        ORDER BY paq_tur_codigo DESC; -- Ordenados del más nuevo al más viejo

    o_status_code := 200;
    o_mensaje := 'Paquetes obtenidos exitosamente';

EXCEPTION
    WHEN OTHERS THEN
        o_status_code := 500;
        o_mensaje := 'Error al obtener paquetes: ' || SQLERRM;
        o_cursor := NULL;
END;
$$;