BEGIN;

-- ==============================================================================
-- 1. LUGARES (Base para todo)
-- ==============================================================================
INSERT INTO lugar (lug_nombre, lug_tipo, fk_lugar) VALUES ('Venezuela', 'Pais', NULL); -- ID 1
INSERT INTO lugar (lug_nombre, lug_tipo, fk_lugar) VALUES ('España', 'Pais', NULL);    -- ID 2
INSERT INTO lugar (lug_nombre, lug_tipo, fk_lugar) VALUES ('Japón', 'Pais', NULL);     -- ID 3
INSERT INTO lugar (lug_nombre, lug_tipo, fk_lugar) VALUES ('Egipto', 'Pais', NULL);    -- ID 4
INSERT INTO lugar (lug_nombre, lug_tipo, fk_lugar) VALUES ('Australia', 'Pais', NULL); -- ID 5
INSERT INTO lugar (lug_nombre, lug_tipo, fk_lugar) VALUES ('Caracas', 'Ciudad', 1);    -- ID 6
INSERT INTO lugar (lug_nombre, lug_tipo, fk_lugar) VALUES ('La Guaira', 'Estado', 1);  -- ID 7
INSERT INTO lugar (lug_nombre, lug_tipo, fk_lugar) VALUES ('Distrito Capital', 'Estado', 1); -- ID 8
INSERT INTO lugar (lug_nombre, lug_tipo, fk_lugar) VALUES ('Zulia', 'Estado', 1);      -- ID 9
INSERT INTO lugar (lug_nombre, lug_tipo, fk_lugar) VALUES ('Carabobo', 'Estado', 1);   -- ID 10
INSERT INTO lugar (lug_nombre, lug_tipo, fk_lugar) VALUES ('Lara', 'Estado', 1);       -- ID 11
INSERT INTO lugar (lug_nombre, lug_tipo, fk_lugar) VALUES ('Anzoategui', 'Estado', 1); -- ID 12
INSERT INTO lugar (lug_nombre, lug_tipo, fk_lugar) VALUES ('Bolivar', 'Estado', 1);    -- ID 13
INSERT INTO lugar (lug_nombre, lug_tipo, fk_lugar) VALUES ('Nueva Esparta', 'Estado', 1); -- ID 14
INSERT INTO lugar (lug_nombre, lug_tipo, fk_lugar) VALUES ('Merida', 'Estado', 1);     -- ID 15
INSERT INTO lugar (lug_nombre, lug_tipo, fk_lugar) VALUES ('Tachira', 'Estado', 1);    -- ID 16
INSERT INTO lugar (lug_nombre, lug_tipo, fk_lugar) VALUES ('Miranda', 'Estado', 1);    -- ID 17

-- ==============================================================================
-- 2. ROLES, ESTADOS Y PRIVILEGIOS
-- ==============================================================================
INSERT INTO estado_civil (edo_civ_nombre, edo_civ_descripcion) VALUES 
('Soltero/a', 'Persona que nunca ha contraído matrimonio'),
('Casado/a', 'Persona unida en matrimonio'),
('Divorciado/a', 'Persona que ha disuelto su vínculo matrimonial'),
('Viudo/a', 'Persona cuyo cónyuge ha fallecido');

INSERT INTO rol(rol_nombre, rol_descripcion) VALUES 
('Administrador', 'Administrador del sistema.'),
('Proveedor', 'Responsable de proveedor de servicios'),
('Cliente', 'Consumidor/Comprador de servicios');

-- Usuario Admin
INSERT INTO usuario(usu_nombre_usuario, usu_contrasena, usu_email, fk_rol_codigo, fk_lugar)
VALUES('artadmin', '1234', '10arturojpinto@gmail.com', 1, 1);

-- Privilegios
INSERT INTO privilegio(pri_nombre, pri_descripcion) VALUES
('crear_usuarios', 'creacion de proveedores y clientes'),
('eliminar_usuarios', 'eliminacion de proveedores y clientes'),
('leer_usuarios', 'ver informacion sobre usuarios distintos a uno'),
('manipulacion_de_roles', 'creacion, eliminacion, lectura y actualizacion de roles'),
('crear_recursos','creacion de viajes, rutas, servicios, paquetes'),
('modificar_recursos', 'modificacion de viajes, rutas, servicios'),
('eliminar_recursos', 'eliminacion de viajes, rutas, servicios'),
('reservar_y_comprar', 'reserva y compra de servicios'),
('manipular_viajeros', 'creacion, eliminacion, lectura y modificacion de viajeros');

INSERT INTO rol_privilegio(fk_pri_codigo, fk_rol_codigo) VALUES
(1,1), (2,1), (3,1), (4,1), (5,1), (6,1), (7,1), -- Admin
(8,3), (9,3), -- Cliente
(5,2), (6,2), (7,2); -- Proveedor

-- Nacionalidades
INSERT INTO nacionalidad (nac_nombre, nac_descripcion) VALUES
('Venezolano', 'Ciudadano de Venezuela'), ('Colombiano', 'Ciudadano de Colombia'),
('Argentino', 'Ciudadano de Argentina'), ('Mexicano', 'Ciudadano de México'),
('Chileno', 'Ciudadano de Chile'), ('Español', 'Ciudadano de España'),
('Italiano', 'Ciudadano de Italia'), ('Francés', 'Ciudadano de Francia'),
('Alemán', 'Ciudadano de Alemania'), ('Portugués', 'Ciudadano de Portugal');


-- ==============================================================================
-- 3. GENERADOR AUTOMÁTICO DE PROVEEDORES (CORRECCIÓN CLAVE)
-- ==============================================================================
-- Este bloque crea un usuario único para cada proveedor antes de insertarlo
DO $$
DECLARE
    r RECORD;
    v_usu_id INTEGER;
    v_rol_prov INTEGER := 2; -- ID del rol Proveedor
BEGIN
    FOR r IN SELECT * FROM (VALUES 
        -- AEROLINEAS
        ('Avior Airlines', 'Aerolinea', 6), ('Laser Airlines', 'Aerolinea', 6),
        ('Conviasa', 'Aerolinea', 6), ('Rutaca', 'Aerolinea', 6),
        ('Turpial Airlines', 'Aerolinea', 6), ('Estelar', 'Aerolinea', 6),
        ('Venezolana', 'Aerolinea', 6), ('American Airlines', 'Aerolinea', 1),
        ('United Airlines', 'Aerolinea', 1), ('Delta', 'Aerolinea', 1),
        ('Iberia', 'Aerolinea', 2), ('Air Europa', 'Aerolinea', 2),
        ('Air France', 'Aerolinea', 2), ('Lufthansa', 'Aerolinea', 2),
        ('Air China', 'Aerolinea', 3), ('Japan Airlines', 'Aerolinea', 3),
        ('EgyptAir', 'Aerolinea', 4), ('Qantas', 'Aerolinea', 5),
        ('Copa Airlines', 'Aerolinea', 6), ('Latam', 'Aerolinea', 6),

        -- MARITIMO
        ('Royal Caribbean', 'Maritimo', 1), ('MSC Cruceros', 'Maritimo', 2),
        ('Norwegian Cruise', 'Maritimo', 1), ('Carnival', 'Maritimo', 1),
        ('Disney Cruise Line', 'Maritimo', 1),

        -- TERRESTRE
        ('Hertz', 'Terrestre', 1), ('Avis', 'Terrestre', 1),
        ('Budget', 'Terrestre', 1), ('Europcar', 'Terrestre', 2),
        ('Sixt', 'Terrestre', 2), ('Alamo', 'Terrestre', 1),
        ('National', 'Terrestre', 1), ('Dollar', 'Terrestre', 1),
        ('Thrifty', 'Terrestre', 1), ('Enterprise', 'Terrestre', 1),
        ('Localiza', 'Terrestre', 6), ('Unirent', 'Terrestre', 6),
        ('Amigos Car Rental', 'Terrestre', 6), ('Rent A Car Vzla', 'Terrestre', 6),
        ('AutoEurope', 'Terrestre', 2), ('Goldcar', 'Terrestre', 2),
        ('Centauro', 'Terrestre', 2), ('Firefly', 'Terrestre', 1),
        ('Ace Rent A Car', 'Terrestre', 1), ('Fox Rent A Car', 'Terrestre', 1),

        -- OTROS (Agencias y Parques)
        ('Turismo Maso', 'Otros', 6), ('Viajes Humboldt', 'Otros', 6),
        ('Quo Vadis', 'Otros', 6), ('Italcambio Viajes', 'Otros', 6),
        ('Top Cruises', 'Otros', 6), ('Bestravel', 'Otros', 6),
        ('Tours & Trips', 'Otros', 1), ('Expedia Services', 'Otros', 1),
        ('Booking Tours', 'Otros', 2), ('Civitatis', 'Otros', 2),
        ('Inparques Ávila', 'Otros', 8), ('Parque Canaima', 'Otros', 13),
        ('Parque Mochima', 'Otros', 12), ('Parque Morrocoy', 'Otros', 10),
        ('Parque Los Roques', 'Otros', 7)
    ) AS t(nombre, tipo, lugar_id)
    LOOP
        -- 1. Crear Usuario Único
        INSERT INTO usuario (usu_nombre_usuario, usu_contrasena, usu_email, fk_rol_codigo, fk_lugar)
        VALUES (
            -- Generamos un user tipo 'usu_avior_airlines'
            'usu_' || REPLACE(LOWER(r.nombre), ' ', '_'), 
            '1234', 
            REPLACE(LOWER(r.nombre), ' ', '_') || '@mail.com', 
            v_rol_prov, 
            r.lugar_id
        ) RETURNING usu_codigo INTO v_usu_id;

        -- 2. Crear Proveedor
        INSERT INTO proveedor (prov_nombre, prov_fecha_creacion, prov_tipo, fk_lugar, fk_usu_codigo)
        VALUES (
            r.nombre, 
            CURRENT_DATE - (FLOOR(RANDOM() * 10000)::INT), -- Fecha aleatoria histórica 
            r.tipo, 
            r.lugar_id, 
            v_usu_id
        );
    END LOOP;
END $$;


-- ==============================================================================
-- 4. USUARIOS CLIENTES Y VIAJEROS
-- ==============================================================================
INSERT INTO usuario (usu_contrasena, usu_nombre_usuario, fk_rol_codigo, usu_email, fk_lugar) VALUES 
('1234', 'cliente_miranda_1', 3, 'miranda1@email.com', 17),
('1234', 'cliente_miranda_2', 3, 'miranda2@email.com', 17),
('1234', 'cliente_ccs_1', 3, 'ccs1@email.com', 8),
('1234', 'cliente_ccs_2', 3, 'ccs2@email.com', 8),
('1234', 'cliente_zulia_1', 3, 'zulia1@email.com', 9),
('1234', 'cliente_zulia_2', 3, 'zulia2@email.com', 9);

INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
('Juan', 'Perez', '1990-05-20', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_miranda_1')),
('Maria', 'Perez', '1992-08-15', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_miranda_1')),
('Luis', 'Rodriguez', '1995-01-30', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_ccs_1')),
('Jose', 'Martinez', '1993-07-22', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_zulia_1'));


-- ==============================================================================
-- 5. RECURSOS DE FLOTA Y RUTAS (Asignados dinámicamente)
-- ==============================================================================
-- Asignamos flota a los primeros proveedores creados
-- Nota: Como los IDs se generan secuencialmente, Avior debería ser ID 1, Laser ID 2, etc.

INSERT INTO medio_transporte (med_tra_capacidad, med_tra_descripcion, med_tra_tipo, fk_prov_codigo) VALUES
(150, 'Boeing 737', 'Avion', (SELECT prov_codigo FROM proveedor WHERE prov_nombre = 'Avior Airlines')), 
(200, 'Airbus A320', 'Avion', (SELECT prov_codigo FROM proveedor WHERE prov_nombre = 'Laser Airlines')),
(3000, 'Crucero Oasis', 'Barco', (SELECT prov_codigo FROM proveedor WHERE prov_nombre = 'Royal Caribbean')),
(5, 'Toyota Corolla', 'Van', (SELECT prov_codigo FROM proveedor WHERE prov_nombre = 'Hertz')), 
(180, 'Boeing 737', 'Avion', (SELECT prov_codigo FROM proveedor WHERE prov_nombre = 'Conviasa'));

-- Terminales
INSERT INTO terminal (ter_nombre, ter_tipo, fk_lugar) VALUES
('Maiquetía', 'Aeropuerto', 7), ('Valencia Big Low', 'Terminal Terrestre', 10),
('Puerto La Guaira', 'Puerto', 7), ('JFK Airport', 'Aeropuerto', 1),
('Barajas', 'Aeropuerto', 2), ('Aeropuerto Santiago Mariño', 'Aeropuerto', 14),
('Terminal La Bandera', 'Terminal Terrestre', 8), ('Puerto Guamache', 'Puerto', 14),
('Aeropuerto La Chinita', 'Aeropuerto', 9), ('Aeropuerto Jacinto Lara', 'Aeropuerto', 11);

-- Rutas
-- Usamos subconsultas para obtener los IDs correctos de los proveedores
INSERT INTO ruta (rut_costo, rut_millas_otorgadas, rut_tipo, fk_terminal_origen, fk_terminal_destino, fk_prov_codigo) VALUES
(100.00, 50, 'Aerea', 1, 6, (SELECT prov_codigo FROM proveedor WHERE prov_nombre = 'Avior Airlines')), 
(120.00, 60, 'Aerea', 1, 9, (SELECT prov_codigo FROM proveedor WHERE prov_nombre = 'Laser Airlines')),
(50.00, 20, 'Terrestre', 7, 2, (SELECT prov_codigo FROM proveedor WHERE prov_nombre = 'Hertz')), 
(800.00, 500, 'Maritima', 3, 8, (SELECT prov_codigo FROM proveedor WHERE prov_nombre = 'Royal Caribbean')),
(200.00, 100, 'Aerea', 1, 4, (SELECT prov_codigo FROM proveedor WHERE prov_nombre = 'American Airlines')), 
(150.00, 80, 'Aerea', 1, 5, (SELECT prov_codigo FROM proveedor WHERE prov_nombre = 'Iberia'));


-- ==============================================================================
-- 6. SERVICIOS Y HOTELES
-- ==============================================================================
INSERT INTO servicio (ser_nombre, ser_descripcion, ser_costo, ser_fecha_hora_inicio, ser_fecha_hora_fin, ser_tipo, fk_prov_codigo) VALUES
('Vuelo Ccs-Porlamar', 'Ida', 100.00, NOW(), NOW() + INTERVAL '1 hour', 'Vuelo', (SELECT prov_codigo FROM proveedor WHERE prov_nombre = 'Avior Airlines')),
('Alojamiento Eurobuilding', 'Noche', 150.00, NOW(), NOW() + INTERVAL '1 day', 'Alojamiento', (SELECT prov_codigo FROM proveedor WHERE prov_nombre = 'Avior Airlines')),
('Alquiler Corolla', 'Dia', 40.00, NOW(), NOW() + INTERVAL '1 day', 'Transporte', (SELECT prov_codigo FROM proveedor WHERE prov_nombre = 'Hertz')),
('Crucero Caribe', '7 dias', 800.00, NOW(), NOW() + INTERVAL '7 days', 'Tour', (SELECT prov_codigo FROM proveedor WHERE prov_nombre = 'Royal Caribbean')),
('Vuelo Ccs-Miami', 'Ida', 300.00, NOW(), NOW() + INTERVAL '4 hours', 'Vuelo', (SELECT prov_codigo FROM proveedor WHERE prov_nombre = 'American Airlines'));

INSERT INTO hotel (hot_nombre, hot_descripcion, hot_valoracion, hot_anos_servicio, fk_lugar) VALUES
('Hotel Eurobuilding', '5 estrellas en Caracas', 4.8, 20, 8),
('Hotel Tamanaco', 'Clásico de Caracas', 4.5, 50, 8),
('Hesperia Valencia', 'Lujo en Carabobo', 4.6, 15, 10),
('Lidotel Barquisimeto', 'Confort en Lara', 4.7, 10, 11);

INSERT INTO metodo_pago (met_pag_descripcion) VALUES 
('Tarjeta Crédito'), ('Tarjeta Débito'), ('Zelle'), ('Efectivo'), ('Transferencia'),
('Pago Móvil'), ('Criptomoneda'), ('Cheque'), ('Millas'), ('PayPal');

COMMIT;