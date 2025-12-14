BEGIN;

-- =================================================================
-- 1. CREACIÓN DE PROVEEDORES ESPECÍFICOS (SI NO EXISTEN)
-- =================================================================
-- Usamos DO para evitar duplicados si ya corriste scripts anteriores
DO $$ 
DECLARE v_lugar_ccs INTEGER := 6; -- Caracas
DECLARE v_usu_id INTEGER;
BEGIN
    -- Proveedor: Museo de Bellas Artes
    IF NOT EXISTS (SELECT 1 FROM proveedor WHERE prov_nombre = 'Museo de Bellas Artes') THEN
        INSERT INTO usuario (usu_nombre_usuario, usu_contrasena, usu_email, fk_rol_codigo, fk_lugar)
        VALUES ('usu_museo_ba', '1234', 'museoba@mail.com', 2, v_lugar_ccs) RETURNING usu_codigo INTO v_usu_id;
        
        INSERT INTO proveedor (prov_nombre, prov_tipo, fk_lugar, fk_usu_codigo)
        VALUES ('Museo de Bellas Artes', 'Otros', v_lugar_ccs, v_usu_id);
    END IF;

    -- Proveedor: Zoologico Caricuao
    IF NOT EXISTS (SELECT 1 FROM proveedor WHERE prov_nombre = 'Zoologico Caricuao') THEN
        INSERT INTO usuario (usu_nombre_usuario, usu_contrasena, usu_email, fk_rol_codigo, fk_lugar)
        VALUES ('usu_zoo_cari', '1234', 'zoocari@mail.com', 2, v_lugar_ccs) RETURNING usu_codigo INTO v_usu_id;
        
        INSERT INTO proveedor (prov_nombre, prov_tipo, fk_lugar, fk_usu_codigo)
        VALUES ('Zoologico Caricuao', 'Otros', v_lugar_ccs, v_usu_id);
    END IF;

     -- Proveedor: Parques Nacionales
    IF NOT EXISTS (SELECT 1 FROM proveedor WHERE prov_nombre = 'Inparques General') THEN
        INSERT INTO usuario (usu_nombre_usuario, usu_contrasena, usu_email, fk_rol_codigo, fk_lugar)
        VALUES ('usu_inparques_gen', '1234', 'inparques@mail.com', 2, v_lugar_ccs) RETURNING usu_codigo INTO v_usu_id;
        
        INSERT INTO proveedor (prov_nombre, prov_tipo, fk_lugar, fk_usu_codigo)
        VALUES ('Inparques General', 'Otros', v_lugar_ccs, v_usu_id);
    END IF;
END $$;

-- =================================================================
-- 2. GENERACIÓN DE SERVICIOS (Futuros para que aparezcan)
-- =================================================================
DO $$
DECLARE 
    prov_museo INT; prov_zoo INT; prov_parque INT; prov_paseo INT;
BEGIN
    SELECT prov_codigo INTO prov_museo FROM proveedor WHERE prov_nombre = 'Museo de Bellas Artes';
    SELECT prov_codigo INTO prov_zoo FROM proveedor WHERE prov_nombre = 'Zoologico Caricuao';
    SELECT prov_codigo INTO prov_parque FROM proveedor WHERE prov_nombre = 'Inparques General';
    SELECT prov_codigo INTO prov_paseo FROM proveedor WHERE prov_nombre = 'Turismo Maso'; -- Usamos agencia existente para paseos

    -- 5 Servicios de Museos
    FOR i IN 1..5 LOOP
        INSERT INTO servicio (ser_nombre, ser_descripcion, ser_costo, ser_fecha_hora_inicio, ser_fecha_hora_fin, ser_tipo, fk_prov_codigo)
        VALUES ('Entrada Museo ' || i, 'Museos', 10.00 * i, NOW() + INTERVAL '5 days', NOW() + INTERVAL '30 days', 'Actividad', prov_museo);
    END LOOP;

    -- 5 Servicios de Zoologico
    FOR i IN 1..5 LOOP
        INSERT INTO servicio (ser_nombre, ser_descripcion, ser_costo, ser_fecha_hora_inicio, ser_fecha_hora_fin, ser_tipo, fk_prov_codigo)
        VALUES ('Visita Guiada Zoo ' || i, 'Zoologico', 15.00 * i, NOW() + INTERVAL '2 days', NOW() + INTERVAL '20 days', 'Actividad', prov_zoo);
    END LOOP;

    -- 5 Servicios de Parques
    FOR i IN 1..5 LOOP
        INSERT INTO servicio (ser_nombre, ser_descripcion, ser_costo, ser_fecha_hora_inicio, ser_fecha_hora_fin, ser_tipo, fk_prov_codigo)
        VALUES ('Excursión Parque ' || i, 'Parques', 5.00, NOW() + INTERVAL '10 days', NOW() + INTERVAL '40 days', 'Actividad', prov_parque);
    END LOOP;
    
    -- 5 Servicios de Paseos
    FOR i IN 1..5 LOOP
        INSERT INTO servicio (ser_nombre, ser_descripcion, ser_costo, ser_fecha_hora_inicio, ser_fecha_hora_fin, ser_tipo, fk_prov_codigo)
        VALUES ('City Tour ' || i, 'Paseos', 50.00, NOW() + INTERVAL '3 days', NOW() + INTERVAL '15 days', 'Tour', prov_paseo);
    END LOOP;
END $$;

-- =================================================================
-- 3. GENERACIÓN DE TRASLADOS Y PUESTOS
-- =================================================================
DO $$
DECLARE 
    r_aerea INT; r_maritima INT; r_terrestre INT;
    m_avion INT; m_barco INT; m_carro INT;
    t_id INT; p_id INT;
BEGIN
    -- Obtenemos rutas y medios (Asumiendo que existen del script inserts.sql anterior, si no, crear dummy)
    -- Ajusta los nombres de proveedores según tu BD real si difieren
    SELECT rut_codigo INTO r_aerea FROM ruta WHERE rut_tipo = 'Aerea' LIMIT 1;
    SELECT rut_codigo INTO r_maritima FROM ruta WHERE rut_tipo = 'Maritima' LIMIT 1;
    SELECT rut_codigo INTO r_terrestre FROM ruta WHERE rut_tipo = 'Terrestre' LIMIT 1;

    SELECT med_tra_codigo INTO m_avion FROM medio_transporte WHERE med_tra_tipo = 'Avion' LIMIT 1;
    SELECT med_tra_codigo INTO m_barco FROM medio_transporte WHERE med_tra_tipo = 'Barco' LIMIT 1;
    SELECT med_tra_codigo INTO m_carro FROM medio_transporte WHERE med_tra_tipo = 'Van' LIMIT 1;

    -- Crear Puestos genéricos para los medios si no existen
    INSERT INTO puesto (pue_codigo, pue_descripcion, fk_med_tra_codigo) VALUES (1, 'Asiento 1', m_avion) ON CONFLICT DO NOTHING;
    INSERT INTO puesto (pue_codigo, pue_descripcion, fk_med_tra_codigo) VALUES (1, 'Camarote 1', m_barco) ON CONFLICT DO NOTHING;
    INSERT INTO puesto (pue_codigo, pue_descripcion, fk_med_tra_codigo) VALUES (1, 'Puesto 1', m_carro) ON CONFLICT DO NOTHING;

    -- 5 Traslados Aéreos
    FOR i IN 1..5 LOOP
        INSERT INTO traslado (tras_fecha_hora_inicio, tras_fecha_hora_fin, tras_Co2_emitido, fk_rut_codigo, fk_med_tra_codigo)
        VALUES (NOW() + INTERVAL '10 days', NOW() + INTERVAL '10 days' + INTERVAL '4 hours', 100.0, r_aerea, m_avion)
        RETURNING tras_codigo INTO t_id;
        
        -- Crear Disponibilidad (pue_tras)
        INSERT INTO pue_tras (fk_tras_codigo, fk_pue_codigo, fk_med_tra_codigo) VALUES (t_id, 1, m_avion);
    END LOOP;

    -- 5 Traslados Marítimos
    FOR i IN 1..5 LOOP
        INSERT INTO traslado (tras_fecha_hora_inicio, tras_fecha_hora_fin, tras_Co2_emitido, fk_rut_codigo, fk_med_tra_codigo)
        VALUES (NOW() + INTERVAL '20 days', NOW() + INTERVAL '27 days', 500.0, r_maritima, m_barco)
        RETURNING tras_codigo INTO t_id;
        INSERT INTO pue_tras (fk_tras_codigo, fk_pue_codigo, fk_med_tra_codigo) VALUES (t_id, 1, m_barco);
    END LOOP;

    -- 5 Traslados Terrestres
    FOR i IN 1..5 LOOP
        INSERT INTO traslado (tras_fecha_hora_inicio, tras_fecha_hora_fin, tras_Co2_emitido, fk_rut_codigo, fk_med_tra_codigo)
        VALUES (NOW() + INTERVAL '2 days', NOW() + INTERVAL '2 days' + INTERVAL '5 hours', 20.0, r_terrestre, m_carro)
        RETURNING tras_codigo INTO t_id;
        INSERT INTO pue_tras (fk_tras_codigo, fk_pue_codigo, fk_med_tra_codigo) VALUES (t_id, 1, m_carro);
    END LOOP;
END $$;

-- =================================================================
-- 4. SIMULACIÓN DE VENTAS (Para ranking "Más Solicitados")
-- =================================================================
DO $$
DECLARE
    u_id INT; c_id INT; 
    s_rec RECORD; t_rec RECORD;
BEGIN
    -- Crear 5 Usuarios Compradores
    FOR i IN 1..5 LOOP
        INSERT INTO usuario (usu_nombre_usuario, usu_contrasena, usu_email, fk_rol_codigo, fk_lugar)
        VALUES ('comprador_home_' || i, '1234', 'buyer' || i || '@test.com', 3, 6)
        RETURNING usu_codigo INTO u_id;

        -- Crear 4 Compras por usuario
        FOR j IN 1..4 LOOP
            INSERT INTO compra (com_monto_total, com_fecha, fk_usuario)
            VALUES (1000.00, CURRENT_DATE, u_id)
            RETURNING com_codigo INTO c_id;

            -- Insertar Servicios Aleatorios en Detalle Reserva (Priorizando 'Paseos' y 'Museos' para que salgan en top)
            FOR s_rec IN SELECT ser_codigo FROM servicio WHERE ser_descripcion IN ('Paseos', 'Museos') ORDER BY RANDOM() LIMIT 2 LOOP
                INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado)
                VALUES (floor(random()*100000)::int, CURRENT_DATE, CURRENT_TIME, 100, 100, 1, 1, c_id, s_rec.ser_codigo, 'Confirmada');
            END LOOP;

            -- Insertar Traslados Aleatorios (Priorizando Aereos)
            FOR t_rec IN SELECT pt.pue_tras_codigo FROM pue_tras pt 
                         JOIN traslado t ON pt.fk_tras_codigo = t.tras_codigo 
                         JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
                         WHERE r.rut_tipo = 'Aerea' ORDER BY RANDOM() LIMIT 1 LOOP
                
                INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_pue_tras, det_res_estado)
                VALUES (floor(random()*100000)::int, CURRENT_DATE, CURRENT_TIME, 200, 200, 1, 1, c_id, t_rec.pue_tras_codigo, 'Confirmada');
            END LOOP;
        END LOOP;
    END LOOP;
END $$;

COMMIT;