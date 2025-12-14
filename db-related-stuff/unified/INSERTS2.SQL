-- =====================================================
-- SCRIPT DE INSERCIÓN DE DATOS
-- Sistema de Gestión Turística
-- =====================================================

-- =====================================================
-- 1. ROLES Y PRIVILEGIOS
-- =====================================================

-- Roles (3 registros)
INSERT INTO estado_civil (edo_civ_nombre, edo_civ_descripcion) VALUES 
('Soltero/a', 'Persona que nunca ha contraído matrimonio'),
('Casado/a', 'Persona unida en matrimonio'),
('Divorciado/a', 'Persona que ha disuelto su vínculo matrimonial'),
('Viudo/a', 'Persona cuyo cónyuge ha fallecido');

INSERT INTO rol(rol_nombre, rol_descripcion) VALUES 
('Administrador', 'Administrador del sistema.'),
('Proveedor', 'Responsable de proveedor de servicios'),
('Cliente', 'Consumidor/Comprador de servicios');



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
-- =====================================================
-- 3. LUGARES (Jerarquía: País -> Estado -> Municipio)
-- =====================================================

-- VENEZUELA
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES ('Pais', 'Venezuela', NULL);
-- Estados de Venezuela (24 estados)
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES
('Estado', 'Amazonas', 1),
('Estado', 'Anzoategui', 1),
('Estado', 'Apure', 1),
('Estado', 'Aragua', 1),
('Estado', 'Barinas', 1),
('Estado', 'Bolivar', 1),
('Estado', 'Carabobo', 1),
('Estado', 'Cojedes', 1),
('Estado', 'Delta Amacuro', 1),
('Estado', 'Falcon', 1),
('Estado', 'Guarico', 1),
('Estado', 'Lara', 1),
('Estado', 'Merida', 1),
('Estado', 'Miranda', 1),
('Estado', 'Monagas', 1),
('Estado', 'Nueva Esparta', 1),
('Estado', 'Portuguesa', 1),
('Estado', 'Sucre', 1),
('Estado', 'Tachira', 1),
('Estado', 'Trujillo', 1),
('Estado', 'Vargas', 1),
('Estado', 'Yaracuy', 1),
('Estado', 'Zulia', 1),
('Estado', 'Distrito Capital', 1);

-- Municipios (2 por estado, 48 total)
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES
('Municipio', 'Atures', 2), ('Municipio', 'Autana', 2),
('Municipio', 'Bolivar', 3), ('Municipio', 'Freites', 3),
('Municipio', 'Achaguas', 4), ('Municipio', 'Biruaca', 4),
('Municipio', 'Girardot', 5), ('Municipio', 'Mariño', 5),
('Municipio', 'Barinas', 6), ('Municipio', 'Ezequiel', 6),
('Municipio', 'Heres', 7), ('Municipio', 'Caroni', 7),
('Municipio', 'Valencia', 8), ('Municipio', 'Naguanagua', 8),
('Municipio', 'San Carlos', 9), ('Municipio', 'Ezequiel', 9),
('Municipio', 'Tucupita', 10), ('Municipio', 'Pedernales', 10),
('Municipio', 'Miranda', 11), ('Municipio', 'Falcon', 11),
('Municipio', 'San Juan', 12), ('Municipio', 'Ortiz', 12),
('Municipio', 'Iribarren', 13), ('Municipio', 'Torres', 13),
('Municipio', 'Libertador', 14), ('Municipio', 'Santos', 14),
('Municipio', 'Sucre', 15), ('Municipio', 'Plaza', 15),
('Municipio', 'Maturin', 16), ('Municipio', 'Punceres', 16),
('Municipio', 'Mariño', 17), ('Municipio', 'Garcia', 17),
('Municipio', 'Guanare', 18), ('Municipio', 'Araure', 18),
('Municipio', 'Sucre', 19), ('Municipio', 'Bermudez', 19),
('Municipio', 'San Cristobal', 20), ('Municipio', 'Cardenas', 20),
('Municipio', 'Trujillo', 21), ('Municipio', 'Valera', 21),
('Municipio', 'Vargas', 22), ('Municipio', 'Caraballeda', 22),
('Municipio', 'San Felipe', 23), ('Municipio', 'Nirgua', 23),
('Municipio', 'Maracaibo', 24), ('Municipio', 'San Francisco', 24),
('Municipio', 'Libertador', 25), ('Municipio', 'Sucre', 25);

-- PAÍSES INTERNACIONALES (5 continentes)
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES
('Pais', 'Estados Unidos', NULL),
('Pais', 'España', NULL),
('Pais', 'Brasil', NULL),
('Pais', 'Japon', NULL),
('Pais', 'Australia', NULL);

-- Ciudades internacionales (1 por país)
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES
('Municipio', 'Miami', 77),
('Municipio', 'Madrid', 78),
('Municipio', 'Rio de Janeiro', 79),
('Municipio', 'Tokio', 80),
('Municipio', 'Sidney', 81);

-- =====================================================
-- 4. USUARIOS Y PROVEEDORES
-- =====================================================

-- Usuario Administrador
INSERT INTO usuario (usu_nombre_usuario, usu_contrasena, usu_email, usu_total_millas, fk_rol_codigo, fk_lugar) 
VALUES ('artadmin', '1234', 'admin@sistematur.com', 0, 1, 49);

-- PROVEEDORES: 20 Aerolíneas
DO $$
DECLARE
    v_user_id INTEGER;
    v_prov_id INTEGER;
    aerolineas TEXT[] := ARRAY[
        'Aerolineas Globales',
        'SkyWings',
        'FlyHigh Airlines',
        'AirConnect',
        'StarJet',
        'OceanAir',
        'Continental Express',
        'Pacific Wings',
        'Atlantic Air',
        'SunRise Airlines',
        'Galaxy Airways',
        'HorizonJet',
        'BlueSky',
        'WindJet',
        'TropicAir',
        'CloudNine',
        'FastWings',
        'EagleAir',
        'ThunderJet',
        'SilverWings'
    ];
    i INTEGER;
BEGIN
    FOR i IN 1..20 LOOP
        INSERT INTO usuario (usu_nombre_usuario, usu_contrasena, usu_email, usu_total_millas, fk_rol_codigo, fk_lugar)
        VALUES ('aero' || i, 'pass123', 'aero' || i || '@mail.com', 0, 2, 49)
        RETURNING usu_codigo INTO v_user_id;
        
        INSERT INTO proveedor (prov_nombre, prov_fecha_creacion, prov_tipo, fk_lugar, fk_usu_codigo)
        VALUES (aerolineas[i], CURRENT_DATE - (i * 30), 'Aerolinea', 49, v_user_id);
    END LOOP;
END $$;

-- PROVEEDORES: 5 Cruceros (Marítimo)
DO $$
DECLARE
    v_user_id INTEGER;
    cruceros TEXT[] := ARRAY[
        'Caribbean Cruises',
        'Ocean Paradise',
        'Sea Voyager',
        'Marina Cruise Line',
        'BlueSea Tours'
    ];
    i INTEGER;
BEGIN
    FOR i IN 1..5 LOOP
        INSERT INTO usuario (usu_nombre_usuario, usu_contrasena, usu_email, usu_total_millas, fk_rol_codigo, fk_lugar)
        VALUES ('cruc' || i, 'pass123', 'cruc' || i || '@mail.com', 0, 2, 82)
        RETURNING usu_codigo INTO v_user_id;
        
        INSERT INTO proveedor (prov_nombre, prov_fecha_creacion, prov_tipo, fk_lugar, fk_usu_codigo)
        VALUES (cruceros[i], CURRENT_DATE - (i * 60), 'Maritimo', 82, v_user_id);
    END LOOP;
END $$;

-- PROVEEDORES: 20 Alquiler de Vehículos (Terrestre)
DO $$
DECLARE
    v_user_id INTEGER;
    alquileres TEXT[] := ARRAY[
        'RentCar Express',
        'AutoMobil',
        'DriveNow',
        'CarRental Plus',
        'VehicleHire',
        'QuickRent',
        'AutoFleet',
        'SpeedRent',
        'CityDrive',
        'MegaRent',
        'FastCar',
        'UltraRent',
        'PremiumCar',
        'EasyDrive',
        'TopRental',
        'CarGo',
        'ProRent',
        'SafeDrive',
        'EliteRental',
        'MaxiCar'
    ];
    i INTEGER;
BEGIN
    FOR i IN 1..20 LOOP
        INSERT INTO usuario (usu_nombre_usuario, usu_contrasena, usu_email, usu_total_millas, fk_rol_codigo, fk_lugar)
        VALUES ('rent' || i, 'pass123', 'rent' || i || '@mail.com', 0, 2, 39)
        RETURNING usu_codigo INTO v_user_id;
        
        INSERT INTO proveedor (prov_nombre, prov_fecha_creacion, prov_tipo, fk_lugar, fk_usu_codigo)
        VALUES (alquileres[i], CURRENT_DATE - (i * 45), 'Terrestre', 39, v_user_id);
    END LOOP;
END $$;

-- PROVEEDORES: 20 Servicios Turísticos (Otros)
DO $$
DECLARE
    v_user_id INTEGER;
    servicios TEXT[] := ARRAY[
        'Tours Venezuela',
        'Adventure Time',
        'EcoTours',
        'Mountain Trekking',
        'Beach Explorer',
        'City Tours VE',
        'Safari Tours',
        'Nature Walk',
        'Cultural Tours',
        'Historic Sites',
        'Food Tours',
        'Night Life Tours',
        'Water Sports',
        'Diving Adventures',
        'Hiking Expeditions',
        'Photography Tours',
        'Wellness Retreats',
        'Gastronomy Tours',
        'Shopping Tours',
        'Sports Tours'
    ];
    i INTEGER;
BEGIN
    FOR i IN 1..20 LOOP
        INSERT INTO usuario (usu_nombre_usuario, usu_contrasena, usu_email, usu_total_millas, fk_rol_codigo, fk_lugar)
        VALUES ('tour' || i, 'pass123', 'tour' || i || '@mail.com', 0, 2, 26)
        RETURNING usu_codigo INTO v_user_id;
        
        INSERT INTO proveedor (prov_nombre, prov_fecha_creacion, prov_tipo, fk_lugar, fk_usu_codigo)
        VALUES (servicios[i], CURRENT_DATE - (i * 20), 'Otros', 26 + (i % 24), v_user_id);
    END LOOP;
END $$;

-- PROVEEDORES: 10 Parques (Otros)
DO $$
DECLARE
    v_user_id INTEGER;
    parques TEXT[] := ARRAY[
        'Parque Nacional Canaima',
        'Los Roques Park',
        'Morrocoy Park',
        'Henri Pittier',
        'Mochima Park',
        'Sierra Nevada Park',
        'El Avila Park',
        'Medanos de Coro',
        'Archipelago Los Roques',
        'Laguna de la Restinga'
    ];
    i INTEGER;
BEGIN
    FOR i IN 1..10 LOOP
        INSERT INTO usuario (usu_nombre_usuario, usu_contrasena, usu_email, usu_total_millas, fk_rol_codigo, fk_lugar)
        VALUES ('park' || i, 'pass123', 'park' || i || '@mail.com', 0, 2, 26)
        RETURNING usu_codigo INTO v_user_id;
        
        INSERT INTO proveedor (prov_nombre, prov_fecha_creacion, prov_tipo, fk_lugar, fk_usu_codigo)
        VALUES (parques[i], CURRENT_DATE - (i * 100), 'Otros', 26 + ((i * 2) % 24), v_user_id);
    END LOOP;
END $$;

-- =====================================================
-- 5. HOTELES (20 registros)
-- =====================================================
INSERT INTO hotel (hot_nombre, hot_descripcion, hot_valoracion, hot_anos_servicio, fk_lugar) VALUES
('Hotel Caracas Plaza', 'Hotel 5 estrellas centro', 4.8, 15, 49),
('Maracaibo Inn', 'Hotel ejecutivo', 4.5, 10, 73),
('Valencia Resort', 'Resort familiar', 4.7, 8, 39),
('Margarita Beach Hotel', 'Hotel playero', 4.9, 12, 63),
('Merida Mountain Lodge', 'Cabañas montaña', 4.6, 20, 51),
('Maturin Business Hotel', 'Hotel negocios', 4.3, 7, 65),
('Los Roques Paradise', 'Hotel boutique', 5.0, 5, 63),
('Puerto La Cruz Inn', 'Hotel costero', 4.4, 9, 28),
('Barinas Country Club', 'Club campestre', 4.2, 18, 33),
('Ciudad Bolivar Hotel', 'Hotel turistico', 4.5, 11, 37),
('San Cristobal Plaza', 'Hotel centro', 4.4, 14, 71),
('Barquisimeto Tower', 'Hotel ejecutivo', 4.6, 6, 49),
('Cumana Suites', 'Suites ejecutivas', 4.3, 8, 67),
('Falcon Beach Resort', 'Resort playa', 4.7, 10, 45),
('Amazonas Lodge', 'Ecolodge', 4.8, 15, 26),
('Delta Amacuro Camp', 'Campamento turistico', 4.1, 5, 43),
('Apure Ranch Hotel', 'Hotel tipo rancho', 4.0, 12, 30),
('Cojedes Inn', 'Posada rural', 4.2, 7, 41),
('Trujillo Hotel', 'Hotel colonial', 4.5, 25, 69),
('Yaracuy Posada', 'Posada familiar', 4.3, 10, 72);

-- =====================================================
-- 6. RESTAURANTES (10 registros)
-- =====================================================
INSERT INTO restaurante (res_nombre, res_descripcion, res_anos_servicio, res_valoracion, fk_lugar) VALUES
('El Sabor Criollo', 'Comida tradicional', 15, 4.7, 49),
('Parrilla del Este', 'Carnes y parrillas', 10, 4.5, 28),
('Marisqueria El Puerto', 'Pescados y mariscos', 12, 4.8, 63),
('Pizzeria Napoli', 'Pizza artesanal', 8, 4.4, 39),
('Sushi Zen', 'Comida japonesa', 5, 4.6, 49),
('Taqueria Mexicana', 'Comida mexicana', 7, 4.3, 73),
('Cafe Paris', 'Cafeteria francesa', 20, 4.9, 49),
('Hamburgueseria Gourmet', 'Hamburguesas premium', 6, 4.2, 39),
('Pasta Italiana', 'Pastas caseras', 18, 4.7, 49),
('Arepera La Tradicion', 'Arepas venezolanas', 25, 4.8, 28);

-- =====================================================
-- 7. TELÉFONOS (10 registros: proveedores, hoteles, restaurantes)
-- =====================================================
INSERT INTO telefono (tel_prefijo_pais, tel_prefijo_operador, tel_sufijo, fk_prov_codigo, fk_hotel, fk_restaurante) VALUES
('+58', '0212', '1234567', 1, NULL, NULL),
('+58', '0212', '2345678', 5, NULL, NULL),
('+58', '0212', '3456789', 10, NULL, NULL),
('+58', '0212', '4567890', NULL, 1, NULL),
('+58', '0261', '5678901', NULL, 2, NULL),
('+58', '0241', '6789012', NULL, 3, NULL),
('+58', '0212', '7890123', NULL, NULL, 1),
('+58', '0281', '8901234', NULL, NULL, 2),
('+58', '0295', '9012345', NULL, NULL, 3),
('+58', '0212', '0123456', NULL, 5, NULL);

-- =====================================================
-- 8. NACIONALIDADES (10 registros)
-- =====================================================
INSERT INTO nacionalidad (nac_nombre, nac_descripcion) VALUES
('Venezolana', 'Nacionalidad Venezuela'),
('Colombiana', 'Nacionalidad Colombia'),
('Estadounidense', 'Nacionalidad USA'),
('Española', 'Nacionalidad España'),
('Brasileña', 'Nacionalidad Brasil'),
('Argentina', 'Nacionalidad Argentina'),
('Chilena', 'Nacionalidad Chile'),
('Mexicana', 'Nacionalidad Mexico'),
('Peruana', 'Nacionalidad Peru'),
('Ecuatoriana', 'Nacionalidad Ecuador');

-- =====================================================
-- 9. CLIENTES (2 por estado = 48 clientes)
-- =====================================================
DO $$
DECLARE
    v_user_id INTEGER;
    estados INTEGER[] := ARRAY[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25];
    nombres TEXT[] := ARRAY['maria', 'jose', 'ana', 'luis', 'carmen', 'pedro', 'sofia', 'carlos', 'laura', 'juan', 'elena', 'miguel', 'lucia', 'jorge', 'rosa', 'daniel', 'marta', 'raul', 'isabel', 'pablo', 'teresa', 'diego', 'patricia', 'andres'];
    i INTEGER;
    j INTEGER;
    counter INTEGER := 1;
    municipio_base INTEGER := 26;
BEGIN
    FOR i IN 1..24 LOOP
        FOR j IN 1..2 LOOP
            INSERT INTO usuario (usu_nombre_usuario, usu_contrasena, usu_email, usu_total_millas, fk_rol_codigo, fk_lugar)
            VALUES (nombres[counter] || j, 'pass123', nombres[counter] || j || '@mail.com', 0, 3, municipio_base + (i-1)*2 + (j-1))
            RETURNING usu_codigo INTO v_user_id;
            
            counter := counter + 1;
            IF counter > 24 THEN
                counter := 1;
            END IF;
        END LOOP;
    END LOOP;
END $$;

-- =====================================================
-- 10. VIAJEROS (2 pasajeros por cliente = 96 viajeros)
-- =====================================================
DO $$
DECLARE
    cliente_id INTEGER;
    v_viajero_id INTEGER;
    nombres TEXT[] := ARRAY['Ana', 'Luis', 'Maria', 'Carlos', 'Sofia', 'Pedro', 'Laura', 'Jose', 'Elena', 'Miguel'];
    apellidos TEXT[] := ARRAY['Gomez', 'Rodriguez', 'Martinez', 'Lopez', 'Garcia', 'Perez', 'Hernandez', 'Gonzalez', 'Diaz', 'Sanchez'];
    i INTEGER;
    j INTEGER;
BEGIN
    FOR cliente_id IN 2..49 LOOP
        FOR j IN 1..2 LOOP
            INSERT INTO viajero (via_prim_nombre, via_seg_nombre, via_prim_apellido, via_seg_apellido, via_fecha_nacimiento, fk_usu_codigo)
            VALUES (
                nombres[(cliente_id % 10) + 1],
                nombres[((cliente_id + j) % 10) + 1],
                apellidos[(cliente_id % 10) + 1],
                apellidos[((cliente_id + 5) % 10) + 1],
                CURRENT_DATE - (25 * 365 + (cliente_id % 20) * 365),
                cliente_id
            )
            RETURNING via_codigo INTO v_viajero_id;
            
            -- IMPORTANTE: Insertar estado civil para cada viajero
            INSERT INTO via_edo (fk_via_codigo, fk_edo_codigo, via_edo_fecha_inicio)
            VALUES (v_viajero_id, ((v_viajero_id % 4) + 1), CURRENT_DATE - (365 * 5));
        END LOOP;
    END LOOP;
END $$;

-- =====================================================
-- 11. DOCUMENTOS (10 registros)
-- =====================================================
INSERT INTO documento (doc_fecha_emision, doc_fecha_vencimiento, doc_numero_documento, doc_tipo, fk_nac_codigo, fk_via_codigo) VALUES
('2020-01-15', '2030-01-15', 'V12345678', 'Pasaporte', 1, 1),
('2021-03-20', '2031-03-20', 'V23456789', 'Pasaporte', 1, 2),
('2019-05-10', '2029-05-10', 'V34567890', 'Cedula', 1, 3),
('2022-07-25', '2032-07-25', 'C45678901', 'Pasaporte', 2, 4),
('2020-09-30', '2030-09-30', 'V56789012', 'Visa', 1, 5),
('2021-11-12', '2031-11-12', 'V67890123', 'Pasaporte', 1, 6),
('2023-02-18', '2033-02-18', 'V78901234', 'Cedula', 1, 7),
('2019-04-22', '2029-04-22', 'V89012345', 'Pasaporte', 1, 8),
('2022-06-28', '2032-06-28', 'V90123456', 'Visa', 1, 9),
('2020-08-14', '2030-08-14', 'V01234567', 'Pasaporte', 1, 10);

-- =====================================================
-- 12. TERMINALES (10 registros)
-- =====================================================
INSERT INTO terminal (ter_nombre, fk_lugar, ter_tipo) VALUES
('Aerop Simon Bolivar', 49, 'Aeropuerto'),
('Aerop La Chinita', 73, 'Aeropuerto'),
('Aerop Arturo Michelena', 39, 'Aeropuerto'),
('Aerop Santiago Mariño', 63, 'Aeropuerto'),
('Puerto La Guaira', 74, 'Puerto'),
('Puerto Maracaibo', 73, 'Puerto'),
('Terminal La Bandera', 49, 'Terminal'),
('Terminal Oriente', 28, 'Terminal'),
('Puerto Guanta', 28, 'Puerto'),
('Aerop Manuel Piar', 37, 'Aeropuerto');

-- =====================================================
-- 13. MEDIOS DE TRANSPORTE (10 registros)
-- =====================================================
INSERT INTO medio_transporte (med_tra_capacidad, med_tra_descripcion, med_tra_tipo, fk_prov_codigo) VALUES
(180, 'Boeing 737-800', 'Avion', 1),
(150, 'Airbus A320', 'Avion', 2),
(250, 'Boeing 777', 'Avion', 3),
(50, 'Autobus ejecutivo', 'Autobus', 21),
(40, 'Minibus turistico', 'Autobus', 22),
(2000, 'Crucero Caribe', 'Barco', 21),
(5, 'Toyota RAV4', 'Automovil', 23),
(7, 'Ford Explorer', 'Camioneta', 24),
(4, 'Chevrolet Spark', 'Automovil', 25),
(200, 'Embraer E195', 'Avion', 4);

-- =====================================================
-- 14. PUESTOS (10 por medio de transporte, total 100)
-- =====================================================
DO $$
DECLARE
    medio_id INTEGER;
    capacidad INTEGER;
    i INTEGER;
BEGIN
    FOR medio_id IN 1..10 LOOP
        SELECT med_tra_capacidad INTO capacidad FROM medio_transporte WHERE med_tra_codigo = medio_id;
        
        FOR i IN 1..LEAST(capacidad, 10) LOOP
            INSERT INTO puesto (pue_codigo, pue_descripcion, pue_costo_agregado, fk_med_tra_codigo)
            VALUES (i, 'Asiento ' || i, 0.00, medio_id);
        END LOOP;
    END LOOP;
END $$;

-- =====================================================
-- 15. RUTAS (10 registros)
-- =====================================================
INSERT INTO ruta (rut_costo, rut_millas_otorgadas, rut_tipo, rut_descripcion,fk_terminal_origen, fk_terminal_destino, fk_prov_codigo) VALUES
(250.00, 500, 'Aerea', 'Practico',1, 2, 1),
(180.00, 350, 'Aerea', 'Corporativo',1, 5, 2),
(30.00, 50, 'Terrestre', 'Practico',3, 6, 27),
(400.00, 800, 'Maritima', 'Corporativo',4, 7, 22),
(220.00, 450, 'Aerea', 'Familiar',5, 8, 6),
(25.00, 40, 'Terrestre', 'Practico',6, 9, 28),
(500.00, 1000, 'Aerea', 'Explorador',1, 10, 10),
(150.00, 300, 'Maritima', 'Famliar',7, 4, 23),
(40.00, 60, 'Terrestre', 'Practico',3, 9, 27),
(280.00, 550, 'Aerea', 'Comfort',2, 5, 3);


-- =====================================================
-- 16. TRASLADOS (10 registros)
-- =====================================================
INSERT INTO traslado (tras_fecha_hora_inicio, tras_fecha_hora_fin, tras_Co2_emitido, fk_rut_codigo, fk_med_tra_codigo) VALUES
('2025-01-15 08:00:00', '2025-01-15 10:30:00', 120.50, 1, 1),
('2025-01-20 14:00:00', '2025-01-20 16:00:00', 95.30, 2, 2),
('2025-02-05 06:30:00', '2025-02-05 09:15:00', 135.80, 3, 3),
('2025-02-10 10:00:00', '2025-02-10 18:00:00', 200.00, 4, 6),
('2025-02-15 07:00:00', '2025-02-15 11:00:00', 15.20, 5, 4),
('2025-03-01 12:00:00', '2025-03-01 14:30:00', 88.40, 6, 10),
('2025-03-05 09:00:00', '2025-03-05 17:00:00', 180.00, 7, 6),
('2025-03-10 15:30:00', '2025-03-10 18:30:00', 12.50, 8, 5),
('2025-03-20 07:45:00', '2025-03-20 10:00:00', 105.60, 9, 1),
('2025-04-01 11:00:00', '2025-04-01 13:45:00', 115.70, 10, 2);

-- =====================================================
-- 17. SERVICIOS (10 registros)
-- =====================================================
INSERT INTO servicio (ser_nombre, ser_descripcion, ser_costo, ser_fecha_hora_inicio, ser_fecha_hora_fin, ser_millas_otorgadas, ser_tipo, fk_prov_codigo) VALUES
('Tour Salto Ángel', 'Explorador', 350.00, '2025-07-15 06:00:00', '2025-07-15 18:00:00', 200, 'Tour', 47),
('Buceo Los Roques', 'Explorador', 180.00, '2025-08-20 08:00:00', '2025-08-20 14:00:00', 100, 'Actividad', 54),
('City Tour Caracas', 'Corporativo', 80.00, '2025-06-10 09:00:00', '2025-06-10 15:00:00', 50, 'Tour', 56),
('Safari Hato Piñero', 'Familia', 420.00, '2025-09-05 07:00:00', '2025-09-07 17:00:00', 250, 'Tour', 53),
('Parapente Mérida', 'Explorador', 150.00, '2025-10-12 10:00:00', '2025-10-12 12:00:00', 80, 'Actividad', 48),
('Gastronomía Andina', 'Familia', 95.00, '2025-11-08 11:00:00', '2025-11-08 16:00:00', 60, 'Comida', 65),
('Rafting Río Caura', 'Explorador', 220.00, '2025-12-01 08:00:00', '2025-12-01 15:00:00', 120, 'Actividad', 61),
('Observación Delfines', 'Familia', 130.00, '2026-01-20 07:00:00', '2026-01-20 11:00:00', 70, 'Tour', 57),
('Escalada Roraima', 'Explorador', 890.00, '2026-02-10 06:00:00', '2026-02-15 16:00:00', 500, 'Tour', 52),
('Seguro de Viaje', 'Corporativo', 50.00, '2025-06-01 00:00:00', '2025-12-31 23:59:59', 0, 'Seguro', 47);

-- =====================================================
-- 18. PROMOCIONES (10 registros)
-- =====================================================
INSERT INTO promocion (prom_nombre, prom_descripcion, prom_fecha_hora_vencimiento, prom_descuento) VALUES
('Descuento Verano', 'Promo temporada', '2025-08-31 23:59:59', 15.00),
('Black Friday', 'Oferta especial', '2025-11-30 23:59:59', 30.00),
('Promo Familiar', 'Descuento familias', '2025-12-31 23:59:59', 20.00),
('Oferta Relampago', 'Solo 48 horas', '2025-06-15 23:59:59', 25.00),
('Descuento Senior', 'Mayores 60 años', '2025-12-31 23:59:59', 18.00),
('Promo Estudiante', 'Con carnet', '2025-12-31 23:59:59', 12.00),
('Early Bird', 'Reserva anticipada', '2025-05-31 23:59:59', 22.00),
('Descuento Grupal', '4 o mas personas', '2025-12-31 23:59:59', 28.00),
('Promo Pareja', 'Especial romantico', '2025-02-28 23:59:59', 16.00),
('Oferta Cumpleaños', 'Mes tu cumple', '2025-12-31 23:59:59', 10.00);

-- =====================================================
-- 19. HABITACIONES (10 por hotel, muestra de 30)
-- =====================================================
DO $$
DECLARE
    hotel_id INTEGER;
    i INTEGER;
BEGIN
    FOR hotel_id IN 1..10 LOOP
        FOR i IN 1..3 LOOP
            INSERT INTO habitacion (hab_capacidad, hab_descripcion, hab_costo_noche, fk_hotel, fk_promocion)
            VALUES (
                CASE WHEN i = 1 THEN 2 WHEN i = 2 THEN 4 ELSE 6 END,
                CASE WHEN i = 1 THEN 'Habitacion doble' WHEN i = 2 THEN 'Suite familiar' ELSE 'Suite presidencial' END,
                50.00 + (i * 30) + (hotel_id * 5),
                hotel_id,
                CASE WHEN hotel_id % 3 = 0 THEN 1 ELSE NULL END
            );
        END LOOP;
    END LOOP;
END $$;

-- =====================================================
-- 20. PLATOS (10 registros distribuidos)
-- =====================================================
INSERT INTO plato (pla_codigo, pla_nombre, pla_descripcion, pla_costo, fk_restaurante) VALUES
(1, 'Pabellon Criollo', 'Plato tipico', 12.50, 1),
(2, 'Asado Negro', 'Carne en salsa', 18.00, 1),
(1, 'Parrillada Mixta', 'Carnes variadas', 25.00, 2),
(2, 'Churrasco', 'Carne a la parrilla', 22.00, 2),
(1, 'Cazuela Mariscos', 'Mariscos frescos', 28.00, 3),
(2, 'Pargo Frito', 'Pescado entero', 24.00, 3),
(1, 'Pizza Margarita', 'Pizza clasica', 15.00, 4),
(1, 'Sushi Roll', 'Roll especial', 20.00, 5),
(1, 'Tacos al Pastor', 'Tacos mexicanos', 14.00, 6),
(1, 'Croissant', 'Pan frances', 5.00, 7);

-- =====================================================
-- 21. PAQUETES TURÍSTICOS (10 registros)
-- =====================================================
INSERT INTO paquete_turistico (paq_tur_nombre, paq_tur_monto_total, paq_tur_monto_subtotal, paq_tur_costo_en_millas) VALUES
('Paquete Los Roques', 850.00, 800.00, 8000),
('Escapada Margarita', 650.00, 600.00, 6000),
('Tour Andes', 720.00, 680.00, 7000),
('Aventura Canaima', 1200.00, 1100.00, 12000),
('Relax Morrocoy', 580.00, 550.00, 5500),
('City Break CCS', 420.00, 400.00, 4000),
('Tour Oriente', 680.00, 640.00, 6500),
('Paquete Familiar', 950.00, 900.00, 9000),
('Romance en Playa', 780.00, 750.00, 7500),
('Aventura Extrema', 890.00, 850.00, 8500);

-- =====================================================
-- 22. TASAS DE CAMBIO (5 tasas para 3 monedas)
-- =====================================================
INSERT INTO tasa_de_cambio (tas_cam_tasa_valor, tas_cam_fecha_hora_inicio, tas_cam_fecha_hora_fin, tas_cam_moneda) VALUES
(36.50, '2025-01-01 00:00:00', '2025-01-31 23:59:59', 'USD'),
(39.20, '2025-02-01 00:00:00', '2025-02-28 23:59:59', 'USD'),
(40.10, '2025-03-01 00:00:00', '2025-03-31 23:59:59', 'USD'),
(0.032, '2025-01-01 00:00:00', '2025-02-28 23:59:59', 'EUR'),
(0.029, '2025-01-01 00:00:00', '2025-03-31 23:59:59', 'COP');

-- =====================================================
-- 23. MÉTODOS DE PAGO (10 registros base)
-- =====================================================
INSERT INTO metodo_pago (met_pag_descripcion) VALUES
('Tarjeta credito Visa'),
('Tarjeta debito Master'),
('Transferencia bancaria'),
('Pago movil'),
('Efectivo USD'),
('Zelle'),
('Tarjeta credito Amex'),
('Cheque'),
('Criptomoneda BTC'),
('Millas acumuladas');

-- Detalles de métodos de pago
INSERT INTO tarjeta_credito (met_pago_codigo, tar_cre_numero, tar_cre_cvv, tar_cre_fecha_vencimiento, tar_cre_banco_emisor, tar_cre_nombre_titular) VALUES
(1, '4111111111111111', '123', '2028-12-31', 'Banco Venezuela', 'Maria Gomez');

INSERT INTO tarjeta_debito (met_pago_codigo, tar_deb_numero, tar_deb_cvv, tar_deb_fecha_vencimiento, tar_deb_banco_emisor, tar_deb_nombre_titular) VALUES
(2, '5500000000000004', '456', '2027-10-31', 'Banesco', 'Jose Rodriguez');

INSERT INTO transferencia_bancaria (met_pago_codigo, trans_ban_numero_referencia, trans_ban_fecha_hora, tras_ban_numero_cuenta_emisora) VALUES
(3, 123456789, '2025-01-15 10:30:00', '01020123456789012345');

INSERT INTO pago_movil_interbancario (met_pago_codigo, pag_movil_int_numero_referencia, pag_movil_int_fecha_hora) VALUES
(4, '987654321', '2025-01-16 14:20:00');

INSERT INTO efectivo (met_pago_codigo, efe_moneda, efe_codigo) VALUES
(5, 'USD', 'EFECTIVO-001');

INSERT INTO zelle (met_pago_codigo, zel_titular_cuenta, zel_correo_electronico, zel_codigo_transaccion) VALUES
(6, 'Maria Gomez', 'maria@mail.com', 'ZELLE-TX-001');

-- =====================================================
-- 24. COMPRAS Y DETALLES DE RESERVA (48 compras, 96 detalles)
-- Cada cliente hace 1 compra con 2 detalles (traslado + hotel o servicio)
-- =====================================================
DO $$
DECLARE
    cliente_id INTEGER;
    v_compra_id INTEGER;
    v_viajero1 INTEGER;
    v_viajero2 INTEGER;
    counter INTEGER := 1;
BEGIN
    FOR cliente_id IN 2..49 LOOP
        -- Obtener los 2 viajeros del cliente
        SELECT via_codigo INTO v_viajero1 FROM viajero WHERE fk_usu_codigo = cliente_id ORDER BY via_codigo LIMIT 1;
        SELECT via_codigo INTO v_viajero2 FROM viajero WHERE fk_usu_codigo = cliente_id ORDER BY via_codigo DESC LIMIT 1;
        
        -- Crear compra
        INSERT INTO compra (com_monto_total, com_monto_subtotal, com_fecha, fk_usuario, fk_plan_financiamiento)
        VALUES (
            400.00 + (counter * 50),
            380.00 + (counter * 45),
            CURRENT_DATE - (counter % 30),
            cliente_id,
            NULL
        )
        RETURNING com_codigo INTO v_compra_id;
        
        -- Detalle 1: Traslado para viajero 1
        INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, fk_paquete_turistico, fk_pue_tras, fk_pue_tras1, fk_pue_tras2, det_res_estado)
        VALUES (
            1,
            CURRENT_DATE - (counter % 30),
            '10:00:00',
            350.00,
            330.00,
            v_viajero1,
            v_viajero1,
            v_compra_id,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            'Confirmada'
        );
        
        -- Detalle 2: Servicio o hotel para viajero 2
        INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, fk_paquete_turistico, fk_pue_tras, fk_pue_tras1, fk_pue_tras2, det_res_estado)
        VALUES (
            2,
            CURRENT_DATE - (counter % 30),
            '10:15:00',
            50.00 + (counter * 10),
            45.00 + (counter * 9),
            v_viajero2,
            v_viajero2,
            v_compra_id,
            ((counter % 10) + 1),
            NULL,
            NULL,
            NULL,
            NULL,
            'Confirmada'
        );
        
        counter := counter + 1;
    END LOOP;
END $$;

-- =====================================================
-- 25. PAGOS (10 registros muestra)
-- =====================================================
INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago) VALUES
(450.00, '2025-01-15 11:00:00', 'USD', 1, 1, 1),
(500.00, '2025-01-16 12:30:00', 'USD', 2, 1, 2),
(480.00, '2025-01-17 14:00:00', 'USD', 3, 1, 3),
(520.00, '2025-01-18 15:30:00', 'USD', 4, 1, 4),
(460.00, '2025-01-19 16:00:00', 'USD', 5, 1, 5),
(490.00, '2025-01-20 17:00:00', 'USD', 6, 1, 6),
(510.00, '2025-01-21 18:00:00', 'USD', 7, 1, 1),
(470.00, '2025-01-22 19:00:00', 'USD', 8, 1, 2),
(530.00, '2025-01-23 20:00:00', 'USD', 9, 1, 3),
(500.00, '2025-01-24 21:00:00', 'USD', 10, 1, 4);

-- =====================================================
-- 26. MILLAS (5 registros para valor de millas)
-- =====================================================
INSERT INTO milla (mil_valor_obtenido, mil_fecha_inicio, mil_fecha_fin, mil_valor_restado, fk_compra, fk_pago) VALUES
(500, '2025-01-15', NULL, 0, 1, 1),
(400, '2025-01-16', NULL, 0, 2, 2),
(600, '2025-01-17', NULL, 100, 3, 3),
(550, '2025-01-18', NULL, 0, 4, 4),
(450, '2025-01-19', NULL, 50, 5, 5);

-- =====================================================
-- 27. RESTO DE TABLAS (10 registros cada una)
-- =====================================================

-- CATEGORÍAS
INSERT INTO categoria (cat_nombre, cat_descripcion) VALUES
('Explorador', 'Actividades extremas'),
('Comfort', 'Destinos costeros'),
('Corporativo', 'Sitios históricos'),
('Familiar', 'Experiencias culinarias'),
('Practico', 'Ecoturismo'),
('Deportes', 'Actividades deportivas'),
('Relax', 'Spa y descanso'),
('Familia', 'Actividades familiares'),
('Negocios', 'Viajes corporativos'),
('Romance', 'Parejas y luna de miel');


-- ACCIONES
INSERT INTO accion (acc_nombre, acc_descripcion) VALUES
('Crear', 'Creacion de registro'),
('Actualizar', 'Modificacion de registro'),
('Eliminar', 'Eliminacion de registro'),
('Consultar', 'Consulta de informacion'),
('Login', 'Inicio de sesion'),
('Logout', 'Cierre de sesion'),
('Comprar', 'Realizar compra'),
('Cancelar', 'Cancelar reserva'),
('Confirmar', 'Confirmar reserva'),
('Pagar', 'Realizar pago');

-- RECURSOS
INSERT INTO recurso (recu_nombre_tabla, recu_descripcion) VALUES
('usuario', 'Tabla de usuarios'),
('compra', 'Tabla de compras'),
('servicio', 'Tabla de servicios'),
('proveedor', 'Tabla de proveedores'),
('detalle_reserva', 'Tabla de reservas'),
('pago', 'Tabla de pagos'),
('hotel', 'Tabla de hoteles'),
('viajero', 'Tabla de viajeros'),
('paquete_turistico', 'Tabla de paquetes'),
('promocion', 'Tabla de promociones');

-- AUDITORÍA
INSERT INTO auditoria (aud_fecha_hora, fk_accion, fk_recurso, fk_usuario) VALUES
('2025-01-15 10:00:00', 1, 1, 1),
('2025-01-16 11:00:00', 2, 2, 1),
('2025-01-17 12:00:00', 7, 2, 2),
('2025-01-18 13:00:00', 7, 5, 3),
('2025-01-19 14:00:00', 10, 6, 4),
('2025-01-20 15:00:00', 9, 5, 5),
('2025-01-21 16:00:00', 4, 3, 1),
('2025-01-22 17:00:00', 1, 4, 1),
('2025-01-23 18:00:00', 2, 7, 1),
('2025-01-24 19:00:00', 8, 5, 6);

-- ESTADOS (para cuotas y reservas)
INSERT INTO estado (est_nombre, est_descripcion) VALUES
('Pendiente', 'Pendiente de proceso'),
('Confirmado', 'Confirmado y activo'),
('Cancelado', 'Cancelado por usuario'),
('Completado', 'Proceso completado'),
('En Proceso', 'En proceso de ejecucion'),
('Rechazado', 'Rechazado por sistema'),
('Expirado', 'Tiempo vencido'),
('En Revision', 'Bajo revision'),
('Aprobado', 'Aprobado por admin'),
('Pagado', 'Pago confirmado');

-- RESEÑAS
INSERT INTO resena (res_calificacion_numerica, res_descripcion, res_fecha_hota_creacion, fk_detalle_reserva, fk_detalle_reserva_2) VALUES
(5, 'Excelente servicio', '2025-01-25 10:00:00', 1, 1),
(4, 'Muy buena experiencia', '2025-01-26 11:00:00', 2, 1),
(5, 'Perfecto todo', '2025-01-27 12:00:00', 3, 1),
(3, 'Regular, puede mejorar', '2025-01-28 13:00:00', 4, 1),
(4, 'Recomendado', '2025-01-29 14:00:00', 5, 1),
(5, 'Increible experiencia', '2025-01-30 15:00:00', 6, 1),
(4, 'Muy satisfecho', '2025-01-31 16:00:00', 7, 1),
(5, 'Superó expectativas', '2025-02-01 17:00:00', 8, 1),
(3, 'Aceptable', '2025-02-02 18:00:00', 9, 1),
(4, 'Buena atencion', '2025-02-03 19:00:00', 10, 1);

-- RECLAMOS
INSERT INTO reclamo (rec_contenido, rec_fecha_hora, fk_detalle_reserva, fk_detalle_reserva_2) VALUES
('Retraso en el vuelo', '2025-01-26 10:00:00', 1, 1),
('Habitacion no coincide', '2025-01-27 11:00:00', 2, 1),
('Servicio incompleto', '2025-01-28 12:00:00', 3, 1),
('Mala atencion', '2025-01-29 13:00:00', 4, 1),
('Comida fria', '2025-01-30 14:00:00', 5, 1),
('Tour cancelado', '2025-01-31 15:00:00', 6, 1),
('Equipo en mal estado', '2025-02-01 16:00:00', 7, 1),
('No respetan horarios', '2025-02-02 17:00:00', 8, 1),
('Cobro incorrecto', '2025-02-03 18:00:00', 9, 1),
('Informacion errada', '2025-02-04 19:00:00', 10, 1);

-- REGLAS DE PAQUETE
INSERT INTO regla_paquete (reg_paq_atributo, reg_paq_operador, reg_paq_valor) VALUES
('edad_minima', '>=', '18'),
('edad_maxima', '<=', '65'),
('personas_min', '>=', '2'),
('personas_max', '<=', '6'),
('dias_anticipacion', '>=', '15'),
('temporada', '=', 'Alta'),
('descuento_grupo', '>', '4'),
('millas_minimas', '>=', '5000'),
('restriccion_fecha', 'BETWEEN', '2025-06-01'),
('nacionalidad', '=', 'Venezolana');

-- PLAN FINANCIAMIENTO
INSERT INTO plan_financiamiento (plan_fin_tasa_interes, plan_fin_numero_cuotas, plan_fin_inicial, fk_compra) VALUES
(5.50, 3, 150.00, NULL),
(7.00, 6, 200.00, NULL),
(4.50, 3, 100.00, NULL),
(6.00, 4, 180.00, NULL),
(5.00, 3, 120.00, NULL),
(8.00, 12, 250.00, NULL),
(6.50, 6, 160.00, NULL),
(5.50, 3, 140.00, NULL),
(7.50, 9, 220.00, NULL),
(4.00, 3, 110.00, NULL);

-- CUOTAS
INSERT INTO cuota (cuo_monto, cuo_fecha_tope, cuo_fecha_fin, fk_plan_financiamiento) VALUES
(100.00, '2025-02-15', NULL, 1),
(100.00, '2025-03-15', NULL, 1),
(100.00, '2025-04-15', NULL, 1),
(90.00, '2025-02-20', '2025-02-18', 2),
(90.00, '2025-03-20', NULL, 2),
(85.00, '2025-02-25', NULL, 3),
(95.00, '2025-03-10', NULL, 4),
(105.00, '2025-03-15', NULL, 5),
(110.00, '2025-04-01', NULL, 6),
(88.00, '2025-02-28', NULL, 7);

-- COMPENSACIÓN CO2
INSERT INTO compensacion (com_co2_compensado, com_monto_agregado, fk_compra) VALUES
(120.50, 12.00, 1),
(95.30, 9.50, 2),
(135.80, 13.50, 3),
(200.00, 20.00, 4),
(15.20, 1.50, 5),
(88.40, 8.80, 6),
(180.00, 18.00, 7),
(12.50, 1.25, 8),
(105.60, 10.50, 9),
(115.70, 11.50, 10);

-- REEMBOLSOS
INSERT INTO reembolso (rem_monto_reembolsado, rem_monto_retenido, rem_fecha, fk_pago) VALUES
(400.00, 50.00, '2025-02-01', 1),
(450.00, 50.00, '2025-02-02', 2),
(430.00, 50.00, '2025-02-03', 3),
(470.00, 50.00, '2025-02-04', 4),
(410.00, 50.00, '2025-02-05', 5),
(440.00, 50.00, '2025-02-06', 6),
(460.00, 50.00, '2025-02-07', 7),
(420.00, 50.00, '2025-02-08', 8),
(480.00, 50.00, '2025-02-09', 9),
(450.00, 50.00, '2025-02-10', 10);

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================
