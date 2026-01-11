/* ==========================================================================
   SCRIPT UNIFICADO DE DATOS PARA REPORTES (1 al 5)
   COMPATIBLE CON INSERTS V4
   ========================================================================== */

-- ==========================================================================
-- SECCIÓN 1: PREPARACIÓN (INVENTARIO ADICIONAL Y PAQUETES DE REPORTE)
-- ==========================================================================

-- 1.1 Crear Habitaciones específicas para garantizar disponibilidad en los reportes
INSERT INTO habitacion (hab_capacidad, hab_descripcion, hab_costo_noche, fk_hotel, fk_promocion) VALUES
(2, 'Cabaña Andina VIP', 120.00, 15, NULL), -- Hotel Prado Rio (Mérida)
(2, 'Suite Ejecutiva Colonial', 180.00, 17, NULL), -- Hotel Colón (Valencia)
(2, 'Vista Mar Deluxe', 150.00, 19, NULL), -- Caribbean Inn (Barcelona)
(4, 'Familiar Llanera', 130.00, 7, NULL); -- Tibisay Hotel (Orinoco)

-- 1.2 Crear 10 Nuevos Paquetes Turísticos (IDs 11 al 20)
-- Estos paquetes se usarán para medir popularidad y ventas específicas
INSERT INTO paquete_turistico (paq_tur_codigo, paq_tur_nombre, paq_tur_monto_total, paq_tur_monto_subtotal, paq_tur_costo_en_millas) VALUES
(11, 'Mérida Inolvidable', 450.00, 420.00, 15000),
(12, 'Ruta Histórica Valencia', 380.00, 350.00, 12000),
(13, 'Los Roques Exclusivo', 2500.00, 2200.00, 100000),
(14, 'Margarita Tropical', 850.00, 800.00, 28000),
(15, 'Expedición Kerepakupai', 3500.00, 3200.00, 150000),
(16, 'Full Day Mochima', 120.00, 100.00, 5000),
(17, 'Escapada Romántica Galipán', 250.00, 220.00, 8000),
(18, 'Selva Amazónica Profunda', 900.00, 850.00, 35000),
(19, 'Ruta del Cacao Choroní', 300.00, 280.00, 10000),
(20, 'Pesca Deportiva La Guaira', 550.00, 500.00, 18000);

-- 1.3 Asignar Servicios a estos Paquetes (Tabla paq_ser)
INSERT INTO paq_ser (fk_paq_tur_codigo, fk_ser_codigo, cantidad) VALUES 
(11, 1, 2), (11, 10, 1), -- Mérida: Hotel + Seguro
(12, 6, 1), (12, 3, 1),  -- Valencia: Comida + Tour
(13, 2, 3), (13, 10, 1), -- Roques: Buceo + Seguro
(14, 8, 1), (14, 1, 2),  -- Margarita: Delfines + Hotel
(15, 1, 3), (15, 9, 1),  -- Canaima: Hotel + Escalada
(16, 7, 1), (16, 6, 1),  -- Mochima: Rafting/Agua + Comida
(17, 1, 1), (17, 6, 1),  -- Galipán: Hotel + Comida
(18, 4, 1), (18, 10, 1), -- Amazonas: Safari + Seguro
(19, 1, 2), (19, 3, 1),  -- Choroní: Hotel + Tour
(20, 7, 1), (20, 6, 1);  -- Pesca: Actividad + Comida

-- 1.4 Asignar Traslados (Tabla paq_tras)
INSERT INTO paq_tras (fk_paq_tur_codigo, fk_tras_codigo) VALUES 
(11, 10), (13, 1), (15, 1), (16, 3), (17, 9), (18, 5), (19, 3), (20, 4);


-- ==========================================================================
-- SECCIÓN 2: REPORTE 1 (VENTAS DETALLADAS CON RESERVAS ESPECÍFICAS)
-- ==========================================================================
-- Usamos IDs de compra 20000+ para no chocar con el script base

-- Compra 1: Cliente 97 compra "Mérida Inolvidable" con reserva de Hotel
INSERT INTO compra (com_codigo, com_monto_total, com_monto_subtotal, com_fecha, fk_usuario, fk_plan_financiamiento) 
VALUES (20000, 450.00, 420.00, '2025-08-01', 97, NULL);

INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago) 
VALUES (450.00, '2025-08-01 10:00:00', 'USD', 20000, 2, 1);

INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, fk_paquete_turistico, det_res_estado) 
VALUES (1, '2025-08-01', '10:00:00', 450.00, 420.00, 1, 1, 20000, NULL, 11, 'Confirmada');

-- Reserva de Habitación (Vinculada al detalle de la compra 20000)
INSERT INTO reserva_de_habitacion (res_hab_fecha_hora_inicio, res_hab_fecha_hora_fin, res_hab_costo_unitario, fk_habitacion, fk_detalle_reserva, fk_detalle_reserva_2, fk_paquete_turistico)
VALUES ('2025-08-10 15:00:00', '2025-08-12 12:00:00', 0.00, (SELECT hab_num_hab FROM habitacion WHERE fk_hotel = 15 LIMIT 1), 20000, 1, NULL); 


-- Compra 2: Cliente 98 compra "Ruta Histórica Valencia" con reserva de Restaurante
INSERT INTO compra (com_codigo, com_monto_total, com_monto_subtotal, com_fecha, fk_usuario, fk_plan_financiamiento) 
VALUES (20001, 380.00, 350.00, '2025-09-15', 98, NULL);

INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago) 
VALUES (380.00, '2025-09-15 14:00:00', 'USD', 20001, 2, 2);

INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, fk_paquete_turistico, det_res_estado) 
VALUES (1, '2025-09-15', '14:00:00', 380.00, 350.00, 3, 1, 20001, NULL, 12, 'Confirmada');

-- Reserva de Restaurante (Vinculada al detalle de la compra 20001)
INSERT INTO reserva_restaurante (res_rest_fecha_hora, res_rest_num_mesa, res_rest_tamano_mesa, fk_restaurante, fk_detalle_reserva, fk_detalle_reserva_2, fk_paquete_turistico)
VALUES ('2025-09-20 20:00:00', 5, 2, 1, 20001, 1, NULL);


-- ==========================================================================
-- SECCIÓN 3: REPORTE 2 (TOP 5 CANJES DE MILLAS - GENERACIÓN MASIVA)
-- ==========================================================================
-- Generamos cientos de transacciones pagadas con Millas (ID Método 10)
-- IDs Compra 30000+

DO $$
DECLARE
    i INTEGER;
    cliente_random INTEGER;
    fecha_random DATE;
    id_compra_base INTEGER := 30000;
    contador_global INTEGER := 0;
BEGIN
    -- A. EL "BEST SELLER": Full Day Mochima (ID 16) - 120 Ventas
    FOR i IN 1..120 LOOP
        contador_global := contador_global + 1;
        cliente_random := 97 + floor(random() * 47)::int;
        fecha_random := (CURRENT_DATE - (floor(random() * 180) || ' days')::interval)::date;
        
        INSERT INTO compra (com_codigo, com_monto_total, com_fecha, fk_usuario) VALUES (id_compra_base + contador_global, 120.00, fecha_random, cliente_random);
        INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago) VALUES (120.00, fecha_random + '10:00:00'::time, 'USD', id_compra_base + contador_global, 2, 10);
        INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_paquete_turistico, det_res_estado) VALUES (1, fecha_random, '10:00:00', 120.00, 100.00, 1, 1, id_compra_base + contador_global, 16, 'Pagado');
    END LOOP;

    -- B. EL POPULAR: Ruta Valencia (ID 12) - 85 Ventas
    FOR i IN 1..85 LOOP
        contador_global := contador_global + 1;
        cliente_random := 97 + floor(random() * 47)::int;
        fecha_random := (CURRENT_DATE - (floor(random() * 180) || ' days')::interval)::date;
        
        INSERT INTO compra (com_codigo, com_monto_total, com_fecha, fk_usuario) VALUES (id_compra_base + contador_global, 380.00, fecha_random, cliente_random);
        INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago) VALUES (380.00, fecha_random + '11:00:00'::time, 'USD', id_compra_base + contador_global, 2, 10);
        INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_paquete_turistico, det_res_estado) VALUES (1, fecha_random, '11:00:00', 380.00, 350.00, 1, 1, id_compra_base + contador_global, 12, 'Pagado');
    END LOOP;

    -- C. EL INTERMEDIO: Margarita (ID 14) - 50 Ventas
    FOR i IN 1..50 LOOP
        contador_global := contador_global + 1;
        cliente_random := 97 + floor(random() * 47)::int;
        fecha_random := (CURRENT_DATE - (floor(random() * 150) || ' days')::interval)::date;
        
        INSERT INTO compra (com_codigo, com_monto_total, com_fecha, fk_usuario) VALUES (id_compra_base + contador_global, 850.00, fecha_random, cliente_random);
        INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago) VALUES (850.00, fecha_random + '12:00:00'::time, 'USD', id_compra_base + contador_global, 2, 10);
        INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_paquete_turistico, det_res_estado) VALUES (1, fecha_random, '12:00:00', 850.00, 800.00, 1, 1, id_compra_base + contador_global, 14, 'Pagado');
    END LOOP;

    -- D. EL LUJO ACCESIBLE: Mérida (ID 11) - 40 Ventas
    FOR i IN 1..40 LOOP
        contador_global := contador_global + 1;
        cliente_random := 97 + floor(random() * 47)::int;
        fecha_random := (CURRENT_DATE - (floor(random() * 120) || ' days')::interval)::date;
        
        INSERT INTO compra (com_codigo, com_monto_total, com_fecha, fk_usuario) VALUES (id_compra_base + contador_global, 450.00, fecha_random, cliente_random);
        INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago) VALUES (450.00, fecha_random + '14:00:00'::time, 'USD', id_compra_base + contador_global, 2, 10);
        INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_paquete_turistico, det_res_estado) VALUES (1, fecha_random, '14:00:00', 450.00, 420.00, 1, 1, id_compra_base + contador_global, 11, 'Pagado');
    END LOOP;

    -- E. EL EXCLUSIVO: Los Roques (ID 13) - 15 Ventas
    FOR i IN 1..15 LOOP
        contador_global := contador_global + 1;
        cliente_random := 97 + floor(random() * 47)::int;
        fecha_random := (CURRENT_DATE - (floor(random() * 90) || ' days')::interval)::date;
        
        INSERT INTO compra (com_codigo, com_monto_total, com_fecha, fk_usuario) VALUES (id_compra_base + contador_global, 2500.00, fecha_random, cliente_random);
        INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago) VALUES (2500.00, fecha_random + '15:00:00'::time, 'USD', id_compra_base + contador_global, 2, 10);
        INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_paquete_turistico, det_res_estado) VALUES (1, fecha_random, '15:00:00', 2500.00, 2200.00, 1, 1, id_compra_base + contador_global, 13, 'Pagado');
    END LOOP;

    -- F. EL ULTRA EXCLUSIVO: Canaima (ID 15) - 5 Ventas
    FOR i IN 1..5 LOOP
        contador_global := contador_global + 1;
        cliente_random := 97 + floor(random() * 47)::int;
        fecha_random := (CURRENT_DATE - (floor(random() * 60) || ' days')::interval)::date;
        
        INSERT INTO compra (com_codigo, com_monto_total, com_fecha, fk_usuario) VALUES (id_compra_base + contador_global, 3500.00, fecha_random, cliente_random);
        INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago) VALUES (3500.00, fecha_random + '16:00:00'::time, 'USD', id_compra_base + contador_global, 2, 10);
        INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_paquete_turistico, det_res_estado) VALUES (1, fecha_random, '16:00:00', 3500.00, 3200.00, 1, 1, id_compra_base + contador_global, 15, 'Pagado');
    END LOOP;

    -- G. ALEATORIOS DE RELLENO (Paquetes 17-20) - 30 Ventas
    FOR i IN 1..30 LOOP
        contador_global := contador_global + 1;
        cliente_random := 97 + floor(random() * 47)::int;
        fecha_random := (CURRENT_DATE - (floor(random() * 100) || ' days')::interval)::date;
        
        INSERT INTO compra (com_codigo, com_monto_total, com_fecha, fk_usuario) VALUES (id_compra_base + contador_global, 400.00, fecha_random, cliente_random);
        INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago) VALUES (400.00, fecha_random + '17:00:00'::time, 'USD', id_compra_base + contador_global, 2, 10);
        INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_paquete_turistico, det_res_estado) VALUES (1, fecha_random, '17:00:00', 400.00, 350.00, 1, 1, id_compra_base + contador_global, 17 + floor(random() * 4)::int, 'Pagado');
    END LOOP;
END $$;


-- ==========================================================================
-- SECCIÓN 4: REPORTE 3 (AUDITORÍA DE REEMBOLSOS)
-- ==========================================================================
-- IDs Compra 20500+
-- 20 Casos Correctos (90%), 5 Casos Incorrectos (100% u otro monto)

DO $$
BEGIN
    FOR i IN 0..24 LOOP
        -- Compra cancelada (Hace 30 días)
        INSERT INTO compra (com_codigo, com_monto_total, com_monto_subtotal, com_fecha, fk_usuario, fk_plan_financiamiento)
        VALUES (20500 + i, 1000.00, 900.00, (CURRENT_DATE - INTERVAL '30 days')::date, 100 + (i%40), NULL);
        
        -- Detalle Cancelado
        INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado)
        VALUES (1, CURRENT_DATE, '09:00:00', 1000.00, 900.00, 1, 1, 20500 + i, 1, 'Cancelada');
        
        -- Pago Original (Hace 35 días)
        INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago)
        VALUES (1000.00, (CURRENT_DATE - INTERVAL '35 days'), 'USD', 20500 + i, 2, 1);
        
        -- Pago Reembolso (Hoy) - Simulación de Auditoría
        IF i < 20 THEN
            -- 20 Casos Correctos (90% de 1000 = 900)
            INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago)
            VALUES (900.00, CURRENT_TIMESTAMP, 'USD', 20500 + i, 2, 4);
        ELSE
            -- 5 Casos con Error de Cálculo (Se devuelve 1000 en vez de 900)
            INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago)
            VALUES (1000.00, CURRENT_TIMESTAMP, 'USD', 20500 + i, 2, 4);
        END IF;
    END LOOP;
END $$;


-- ==========================================================================
-- SECCIÓN 5: REPORTE 4 (PREFERENCIAS VS REALIDAD)
-- ==========================================================================
-- Creamos usuarios nuevos (IDs 300+) para no contaminar los clientes base.
-- Insertamos preferencias declaradas y luego compras que pueden coincidir o no.

DO $$
DECLARE 
    new_user_id INTEGER;
BEGIN
    FOR i IN 0..24 LOOP
        -- Crear Usuario Nuevo (Usuario 300 al 324)
        INSERT INTO usuario (usu_codigo, usu_nombre_usuario, usu_contrasena, usu_email, fk_rol_codigo, fk_lugar)
        VALUES (300 + i, 'user_pref_' || i, 'pass', 'pref' || i || '@test.com', 3, 36)
        RETURNING usu_codigo INTO new_user_id;
        
        -- Asignar Preferencias (Solo a los primeros 15, el resto salen 'Sin Preferencias')
        -- Cat 1=Explorador, Cat 2=Comfort
        IF i < 15 THEN
            INSERT INTO preferencia (fk_usuario, fk_categoria) VALUES (new_user_id, (i % 10) + 1);
        END IF;
        
        -- Asignar Compras (IDs 21000+)
        -- Si 'i' es par compra Paq 13 (Playa), si impar Paq 15 (Aventura)
        INSERT INTO compra (com_codigo, com_monto_total, com_fecha, fk_usuario) 
        VALUES (21000 + i, 500.00, CURRENT_DATE, new_user_id);
        
        INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_paquete_turistico, det_res_estado)
        VALUES (1, CURRENT_DATE, '12:00:00', 500, 450, 1, 1, 21000 + i, CASE WHEN i%2=0 THEN 13 ELSE 15 END, 'Pagado');
        
        INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago)
        VALUES (500.00, CURRENT_TIMESTAMP, 'USD', 21000 + i, 2, 1);
    END LOOP;
END $$;


-- ==========================================================================
-- SECCIÓN 6: REPORTE 5 (ACUMULADORES DE MILLAS / HOARDERS)
-- ==========================================================================
-- Actualizamos clientes existentes (130-144) con saldo alto y sin canjes recientes.

UPDATE usuario 
SET usu_total_millas = (usu_codigo * 1500) + 50000 
WHERE usu_codigo BETWEEN 130 AND 144;

-- Registramos la obtención de millas (valor restado 0 = nunca usadas)
INSERT INTO milla (mil_valor_obtenido, mil_fecha_inicio, mil_fecha_fin, mil_valor_restado, fk_compra, fk_pago)
SELECT 
    usu_total_millas, '2025-01-01', '2026-12-31', 0,
    (SELECT com_codigo FROM compra WHERE fk_usuario = u.usu_codigo LIMIT 1), 
    NULL
FROM usuario u
WHERE u.usu_codigo BETWEEN 130 AND 144;