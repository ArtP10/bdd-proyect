-- ================================================================
-- 0. LIMPIEZA TOTAL (Evita conflictos de parámetros)
-- ================================================================
-- Borramos las funciones viejas para crearlas de cero limpias
DROP PROCEDURE IF EXISTS registrar_promocion CASCADE;
DROP PROCEDURE IF EXISTS editar_promocion CASCADE;
DROP PROCEDURE IF EXISTS eliminar_promocion CASCADE;
DROP PROCEDURE IF EXISTS gestionar_asignacion_promocion CASCADE;
DROP FUNCTION IF EXISTS get_elementos_busqueda CASCADE;
DROP FUNCTION IF EXISTS get_habitaciones_por_hotel CASCADE;
DROP FUNCTION IF EXISTS sp_obtener_detalle_promocion CASCADE;
DROP FUNCTION IF EXISTS fn_listar_promociones CASCADE;

-- ================================================================
-- 1. AJUSTES DE TABLA (Solo si no lo has hecho)
-- ================================================================
-- Asegura que Restaurante tenga la columna para la promoción (1:N)
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='restaurante' AND column_name='fk_promocion') THEN
        ALTER TABLE restaurante ADD COLUMN fk_promocion INTEGER REFERENCES promocion(prom_codigo);
    END IF;
END $$;

-- ================================================================
-- 2. CRUD BÁSICO (Registrar, Editar, Eliminar)
-- ================================================================

-- A. Registrar
CREATE OR REPLACE PROCEDURE registrar_promocion(
    _nombre VARCHAR, _descripcion VARCHAR, _fecha TIMESTAMP, _descuento NUMERIC
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO promocion (prom_nombre, prom_descripcion, prom_fecha_hora_vencimiento, prom_descuento)
    VALUES (_nombre, _descripcion, _fecha, _descuento);
END; $$;

-- B. Editar
CREATE OR REPLACE PROCEDURE editar_promocion(
    _id INT, _nombre VARCHAR, _descripcion VARCHAR, _fecha TIMESTAMP, _descuento NUMERIC
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE promocion SET 
        prom_nombre = _nombre, prom_descripcion = _descripcion,
        prom_fecha_hora_vencimiento = _fecha, prom_descuento = _descuento
    WHERE prom_codigo = _id;
END; $$;

-- C. Eliminar (Con limpieza de referencias para evitar error 500)
CREATE OR REPLACE PROCEDURE eliminar_promocion(_id INT) 
LANGUAGE plpgsql AS $$
BEGIN
    -- 1. Limpiar Tablas Intermedias (N:M)
    DELETE FROM ser_prom WHERE fk_prom_codigo = _id;  
    DELETE FROM tras_prom WHERE fk_prom_codigo = _id;
    DELETE FROM paq_prom WHERE fk_prom_codigo = _id;
    
    -- 2. Limpiar Tablas con FK directa (1:N)
    UPDATE habitacion SET fk_promocion = NULL WHERE fk_promocion = _id; 
    UPDATE restaurante SET fk_promocion = NULL WHERE fk_promocion = _id; -- ¡Importante!
    
    -- 3. Borrar la promoción
    DELETE FROM promocion WHERE prom_codigo = _id;
END; $$;


-- ================================================================
-- 3. MOTOR DE BÚSQUEDA Y BUILDER
-- ================================================================

-- A. Buscador Global (Sin filtro de estado)
CREATE OR REPLACE FUNCTION get_elementos_busqueda(_tipo VARCHAR)
RETURNS TABLE (
    elemento_id INT,
    nombre_elemento VARCHAR,
    tipo_detallado VARCHAR,
    costo NUMERIC,
    info_basica TEXT
) AS $$
BEGIN
    -- SERVICIOS
    IF _tipo = 'servicio' THEN
        RETURN QUERY SELECT s.ser_codigo, s.ser_nombre::VARCHAR, s.ser_tipo::VARCHAR, s.ser_costo, s.ser_descripcion::TEXT
        FROM servicio s;
        
    -- HOTELES (Devuelve Hoteles, no habitaciones)
    ELSIF _tipo = 'hotel' THEN
        RETURN QUERY 
        SELECT h.hot_codigo, h.hot_nombre::VARCHAR, 'Hotel'::VARCHAR, 0::NUMERIC, (h.hot_descripcion || ' (' || l.lug_nombre || ')')::TEXT
        FROM hotel h JOIN lugar l ON h.fk_lugar = l.lug_codigo;

    -- RESTAURANTES
    ELSIF _tipo = 'restaurante' THEN
        RETURN QUERY SELECT r.res_codigo, r.res_nombre::VARCHAR, 'Restaurante'::VARCHAR, 0::NUMERIC, r.res_descripcion::TEXT
        FROM restaurante r;

    -- TRASLADOS
    ELSIF _tipo = 'traslado' THEN
        RETURN QUERY SELECT t.tras_codigo, 
               (mt.med_tra_tipo || ': ' || ter_o.ter_nombre || ' -> ' || ter_d.ter_nombre)::VARCHAR, 
               r.rut_tipo::VARCHAR, r.rut_costo, TO_CHAR(t.tras_fecha_hora_inicio, 'DD/MM/YYYY HH24:MI')::TEXT
        FROM traslado t JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo JOIN terminal ter_o ON r.fk_terminal_origen = ter_o.ter_codigo JOIN terminal ter_d ON r.fk_terminal_destino = ter_d.ter_codigo JOIN medio_transporte mt ON t.fk_med_tra_codigo = mt.med_tra_codigo;

    -- PAQUETES
    ELSIF _tipo = 'paquete' THEN
        RETURN QUERY SELECT p.paq_tur_codigo, p.paq_tur_nombre::VARCHAR, 'Paquete'::VARCHAR, p.paq_tur_monto_total, ('Millas: ' || p.paq_tur_costo_en_millas)::TEXT FROM paquete_turistico p;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- B. Buscador de Habitaciones por Hotel (Drill-down)
CREATE OR REPLACE FUNCTION get_habitaciones_por_hotel(_hotel_id INT)
RETURNS TABLE (
    elemento_id INT,
    nombre_elemento VARCHAR,
    tipo_detallado VARCHAR,
    costo NUMERIC,
    info_basica TEXT
) AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        h.hab_num_hab, 
        ('Habitación ' || h.hab_descripcion)::VARCHAR, 
        'Habitación'::VARCHAR, 
        h.hab_costo_noche, 
        ('Capacidad: ' || h.hab_capacidad || ' pers.')::TEXT
    FROM habitacion h
    WHERE h.fk_hotel = _hotel_id;
END;
$$ LANGUAGE plpgsql;


-- ================================================================
-- 4. GESTOR DE ASIGNACIÓN (Logica Mixta UPDATE/INSERT)
-- ================================================================

CREATE OR REPLACE PROCEDURE gestionar_asignacion_promocion(
    _prom_id INT, _elem_id INT, _tipo VARCHAR, _accion VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    -- ACCIÓN: APLICAR
    IF _accion = 'aplicar' THEN
        IF _tipo = 'servicio' THEN INSERT INTO ser_prom (fk_ser_codigo, fk_prom_codigo) VALUES (_elem_id, _prom_id) ON CONFLICT DO NOTHING;
        
        -- Casos 1:N (UPDATE)
        ELSIF _tipo = 'habitacion' THEN UPDATE habitacion SET fk_promocion = _prom_id WHERE hab_num_hab = _elem_id;
        ELSIF _tipo = 'restaurante' THEN UPDATE restaurante SET fk_promocion = _prom_id WHERE res_codigo = _elem_id;
        
        -- Casos N:M (INSERT)
        ELSIF _tipo = 'traslado' THEN INSERT INTO tras_prom (fk_tras_codigo, fk_prom_codigo) VALUES (_elem_id, _prom_id) ON CONFLICT DO NOTHING;
        ELSIF _tipo = 'paquete' THEN INSERT INTO paq_prom (fk_paq_tur_codigo, fk_prom_codigo) VALUES (_elem_id, _prom_id) ON CONFLICT DO NOTHING;
        END IF;

    -- ACCIÓN: REMOVER
    ELSIF _accion = 'remover' THEN
        IF _tipo = 'servicio' THEN DELETE FROM ser_prom WHERE fk_ser_codigo = _elem_id AND fk_prom_codigo = _prom_id;
        
        -- Casos 1:N (NULLIFY)
        ELSIF _tipo = 'habitacion' THEN UPDATE habitacion SET fk_promocion = NULL WHERE hab_num_hab = _elem_id AND fk_promocion = _prom_id;
        ELSIF _tipo = 'restaurante' THEN UPDATE restaurante SET fk_promocion = NULL WHERE res_codigo = _elem_id AND fk_promocion = _prom_id;
        
        -- Casos N:M (DELETE)
        ELSIF _tipo = 'traslado' THEN DELETE FROM tras_prom WHERE fk_tras_codigo = _elem_id AND fk_prom_codigo = _prom_id;
        ELSIF _tipo = 'paquete' THEN DELETE FROM paq_prom WHERE fk_paq_tur_codigo = _elem_id AND fk_prom_codigo = _prom_id;
        END IF;
    END IF;
END; $$;


-- ================================================================
-- 5. VISUALIZADOR DE DETALLES (Botón Ojo)
-- ================================================================

CREATE OR REPLACE FUNCTION sp_obtener_detalle_promocion(_id INT)
RETURNS TABLE (detalle JSON) AS $$
BEGIN
    RETURN QUERY
    SELECT json_build_object(
        'info', (SELECT row_to_json(p) FROM (SELECT prom_nombre, prom_descuento FROM promocion WHERE prom_codigo = _id) p),
        
        'servicios', (
            SELECT COALESCE(json_agg(row_to_json(s)), '[]') FROM (
                SELECT ser.ser_nombre, ser.ser_tipo
                FROM ser_prom sp JOIN servicio ser ON sp.fk_ser_codigo = ser.ser_codigo
                WHERE sp.fk_prom_codigo = _id
            ) s
        ),
        
        'habitaciones', (
            SELECT COALESCE(json_agg(row_to_json(h)), '[]') FROM (
                SELECT hot.hot_nombre, hab.hab_descripcion, hab.hab_costo_noche
                FROM habitacion hab JOIN hotel hot ON hab.fk_hotel = hot.hot_codigo
                WHERE hab.fk_promocion = _id
            ) h
        ),

        'restaurantes', (
            SELECT COALESCE(json_agg(row_to_json(r)), '[]') FROM (
                SELECT res_nombre, res_descripcion
                FROM restaurante
                WHERE fk_promocion = _id
            ) r
        ),
        
        'traslados', (
            SELECT COALESCE(json_agg(row_to_json(t)), '[]') FROM (
                SELECT mt.med_tra_tipo, ter_o.ter_nombre as origen, ter_d.ter_nombre as destino
                FROM tras_prom tp
                JOIN traslado tr ON tp.fk_tras_codigo = tr.tras_codigo
                JOIN ruta r ON tr.fk_rut_codigo = r.rut_codigo
                JOIN terminal ter_o ON r.fk_terminal_origen = ter_o.ter_codigo
                JOIN terminal ter_d ON r.fk_terminal_destino = ter_d.ter_codigo
                JOIN medio_transporte mt ON tr.fk_med_tra_codigo = mt.med_tra_codigo
                WHERE tp.fk_prom_codigo = _id
            ) t
        ),

        'paquetes', (
            SELECT COALESCE(json_agg(row_to_json(pq)), '[]') FROM (
                SELECT p.paq_tur_nombre, p.paq_tur_monto_total
                FROM paq_prom pp JOIN paquete_turistico p ON pp.fk_paq_tur_codigo = p.paq_tur_codigo
                WHERE pp.fk_prom_codigo = _id
            ) pq
        )
    );
END;
$$ LANGUAGE plpgsql;


-- ================================================================
-- D. Obtener todas las promociones
-- ===============================================================
-- Creación de la función con NOMBRE NUEVO para evitar conflictos
CREATE OR REPLACE FUNCTION fn_listar_promociones()
RETURNS TABLE (
    prom_codigo INT,
    prom_nombre VARCHAR,
    prom_descripcion VARCHAR,
    prom_fecha_hora_vencimiento TIMESTAMP,
    prom_descuento NUMERIC
) AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        p.prom_codigo, 
        p.prom_nombre::VARCHAR, 
        p.prom_descripcion::VARCHAR, 
        p.prom_fecha_hora_vencimiento, 
        p.prom_descuento
    FROM promocion p
    ORDER BY p.prom_codigo DESC;
END;
$$ LANGUAGE plpgsql;