-- =====================================================
-- SCRIPT DE INSERCIÓN COMPLETO PARA BASE DE DATOS
-- SISTEMA DE GESTIÓN DE VIAJES Y TURISMO
-- =====================================================

-- =====================================================
-- 1. ESTADOS CIVILES (4 registros - EXACTOS)
-- =====================================================
INSERT INTO estado_civil (edo_civ_nombre, edo_civ_descripcion) VALUES 
('Soltero/a', 'Persona que nunca ha contraído matrimonio'),
('Casado/a', 'Persona unida en matrimonio'),
('Divorciado/a', 'Persona que ha disuelto su vínculo matrimonial'),
('Viudo/a', 'Persona cuyo cónyuge ha fallecido');

-- =====================================================
-- 2. ROLES (3 registros - EXACTOS)
-- =====================================================
INSERT INTO rol(rol_nombre, rol_descripcion) VALUES 
('Administrador', 'Administrador del sistema.'),
('Proveedor', 'Responsable de proveedor de servicios'),
('Cliente', 'Consumidor/Comprador de servicios');

-- =====================================================
-- 3. PRIVILEGIOS (9 registros - EXACTOS)
-- =====================================================
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

-- =====================================================
-- 4. ROL_PRIVILEGIO (Asignación de privilegios)
-- =====================================================
-- Administrador tiene todos los privilegios
INSERT INTO rol_privilegio(fk_rol_codigo, fk_pri_codigo) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9);

-- Proveedor tiene privilegios limitados
INSERT INTO rol_privilegio(fk_rol_codigo, fk_pri_codigo) VALUES
(2, 3), (2, 5), (2, 6), (2, 7);

-- Cliente tiene privilegios básicos
INSERT INTO rol_privilegio(fk_rol_codigo, fk_pri_codigo) VALUES
(3, 8), (3, 9);

-- =====================================================
-- 5. LUGARES (Jerarquía completa)
-- =====================================================
-- Países (Venezuela + 5 países de diferentes continentes)
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES
('Pais', 'Venezuela', NULL),           -- 1
('Pais', 'Estados Unidos', NULL),      -- 2 (América del Norte)
('Pais', 'España', NULL),              -- 3 (Europa)
('Pais', 'Japón', NULL),               -- 4 (Asia)
('Pais', 'Sudáfrica', NULL),           -- 5 (África)
('Pais', 'Australia', NULL);           -- 6 (Oceanía)

-- Ciudades internacionales (1 por país extranjero)
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES
('Ciudad', 'Nueva York', 2),           -- 7
('Ciudad', 'Madrid', 3),               -- 8
('Ciudad', 'Tokio', 4),                -- 9
('Ciudad', 'Ciudad del Cabo', 5),      -- 10
('Ciudad', 'Sídney', 6);               -- 11

-- Estados de Venezuela (24 estados)
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES
('Estado', 'Distrito Capital', 1),     -- 12
('Estado', 'Miranda', 1),              -- 13
('Estado', 'Zulia', 1),                -- 14
('Estado', 'Carabobo', 1),             -- 15
('Estado', 'Aragua', 1),               -- 16
('Estado', 'Anzoátegui', 1),           -- 17
('Estado', 'Lara', 1),                 -- 18
('Estado', 'Bolívar', 1),              -- 19
('Estado', 'Táchira', 1),              -- 20
('Estado', 'Mérida', 1),               -- 21
('Estado', 'Falcón', 1),               -- 22
('Estado', 'Portuguesa', 1),           -- 23
('Estado', 'Sucre', 1),                -- 24
('Estado', 'Barinas', 1),              -- 25
('Estado', 'Trujillo', 1),             -- 26
('Estado', 'Yaracuy', 1),              -- 27
('Estado', 'Monagas', 1),              -- 28
('Estado', 'Cojedes', 1),              -- 29
('Estado', 'Apure', 1),                -- 30
('Estado', 'Guárico', 1),              -- 31
('Estado', 'Nueva Esparta', 1),        -- 32
('Estado', 'Amazonas', 1),             -- 33
('Estado', 'Delta Amacuro', 1),        -- 34
('Estado', 'Vargas', 1);               -- 35

-- Municipios de Venezuela (2 por cada estado = 48)
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES
-- Distrito Capital
('Municipio', 'Libertador', 12),       -- 36
('Municipio', 'Chacao', 12),           -- 37
-- Miranda
('Municipio', 'Baruta', 13),           -- 38
('Municipio', 'Sucre', 13),            -- 39
-- Zulia
('Municipio', 'Maracaibo', 14),        -- 40
('Municipio', 'Cabimas', 14),          -- 41
-- Carabobo
('Municipio', 'Valencia', 15),         -- 42
('Municipio', 'Puerto Cabello', 15),   -- 43
-- Aragua
('Municipio', 'Maracay', 16),          -- 44
('Municipio', 'La Victoria', 16),      -- 45
-- Anzoátegui
('Municipio', 'Barcelona', 17),        -- 46
('Municipio', 'Puerto La Cruz', 17),   -- 47
-- Lara
('Municipio', 'Barquisimeto', 18),     -- 48
('Municipio', 'Cabudare', 18),         -- 49
-- Bolívar
('Municipio', 'Ciudad Bolívar', 19),   -- 50
('Municipio', 'Puerto Ordaz', 19),     -- 51
-- Táchira
('Municipio', 'San Cristóbal', 20),    -- 52
('Municipio', 'Táriba', 20),           -- 53
-- Mérida
('Municipio', 'Mérida', 21),           -- 54
('Municipio', 'Ejido', 21),            -- 55
-- Falcón
('Municipio', 'Coro', 22),             -- 56
('Municipio', 'Punto Fijo', 22),       -- 57
-- Portuguesa
('Municipio', 'Guanare', 23),          -- 58
('Municipio', 'Acarigua', 23),         -- 59
-- Sucre
('Municipio', 'Cumaná', 24),           -- 60
('Municipio', 'Carúpano', 24),         -- 61
-- Barinas
('Municipio', 'Barinas', 25),          -- 62
('Municipio', 'Barinitas', 25),        -- 63
-- Trujillo
('Municipio', 'Trujillo', 26),         -- 64
('Municipio', 'Valera', 26),           -- 65
-- Yaracuy
('Municipio', 'San Felipe', 27),       -- 66
('Municipio', 'Yaritagua', 27),        -- 67
-- Monagas
('Municipio', 'Maturín', 28),          -- 68
('Municipio', 'Punta de Mata', 28),    -- 69
-- Cojedes
('Municipio', 'San Carlos', 29),       -- 70
('Municipio', 'Tinaquillo', 29),       -- 71
-- Apure
('Municipio', 'San Fernando', 30),     -- 72
('Municipio', 'Biruaca', 30),          -- 73
-- Guárico
('Municipio', 'San Juan', 31),         -- 74
('Municipio', 'Calabozo', 31),         -- 75
-- Nueva Esparta
('Municipio', 'La Asunción', 32),      -- 76
('Municipio', 'Porlamar', 32),         -- 77
-- Amazonas
('Municipio', 'Puerto Ayacucho', 33),  -- 78
('Municipio', 'Atures', 33),           -- 79
-- Delta Amacuro
('Municipio', 'Tucupita', 34),         -- 80
('Municipio', 'Pedernales', 34),       -- 81
-- Vargas
('Municipio', 'La Guaira', 35),        -- 82
('Municipio', 'Macuto', 35);           -- 83

-- =====================================================
-- 6. USUARIO ADMINISTRADOR (EXACTO)
-- =====================================================
INSERT INTO usuario(usu_nombre_usuario, usu_contrasena, usu_email, fk_rol_codigo, fk_lugar)
VALUES('artadmin', '1234', '10arturojpinto@gmail.com', 1, 1);

-- =====================================================
-- 7. USUARIOS PROVEEDORES (95 usuarios para 95 proveedores)
-- =====================================================
DO $$
DECLARE
    i INTEGER;
BEGIN
    FOR i IN 1..95 LOOP
        INSERT INTO usuario(usu_nombre_usuario, usu_contrasena, usu_email, fk_rol_codigo, fk_lugar)
        VALUES(
            'proveedor' || i,
            'pass' || i,
            'proveedor' || i || '@turismo.com',
            2,
            1
        );
    END LOOP;
END $$;

-- =====================================================
-- 8. PROVEEDORES (95 total)
-- =====================================================
-- 20 AEROLÍNEAS
INSERT INTO proveedor (prov_nombre, prov_tipo, fk_lugar, fk_usu_codigo) VALUES
('Avior Airlines', 'Aerolinea', 1, 2),
('Conviasa', 'Aerolinea', 1, 3),
('Laser Airlines', 'Aerolinea', 1, 4),
('Turpial Airlines', 'Aerolinea', 1, 5),
('Estelar Latinoamerica', 'Aerolinea', 1, 6),
('Copa Airlines', 'Aerolinea', 2, 7),
('American Airlines', 'Aerolinea', 2, 8),
('United Airlines', 'Aerolinea', 2, 9),
('Delta Air Lines', 'Aerolinea', 2, 10),
('Iberia', 'Aerolinea', 3, 11),
('Air Europa', 'Aerolinea', 3, 12),
('LATAM Airlines', 'Aerolinea', 1, 13),
('Avianca', 'Aerolinea', 1, 14),
('Air France', 'Aerolinea', 3, 15),
('Lufthansa', 'Aerolinea', 3, 16),
('British Airways', 'Aerolinea', 3, 17),
('KLM', 'Aerolinea', 3, 18),
('Turkish Airlines', 'Aerolinea', 4, 19),
('Emirates', 'Aerolinea', 4, 20),
('Qatar Airways', 'Aerolinea', 4, 21);

-- 5 EMPRESAS DE CRUCEROS (Marítimo)
INSERT INTO proveedor (prov_nombre, prov_tipo, fk_lugar, fk_usu_codigo) VALUES
('Caribbean Cruise Line', 'Maritimo', 1, 22),
('Ocean Adventures', 'Maritimo', 2, 23),
('Royal Cruises', 'Maritimo', 3, 24),
('MSC Cruceros', 'Maritimo', 3, 25),
('Costa Cruceros', 'Maritimo', 3, 26);

-- 20 EMPRESAS DE ALQUILER DE VEHÍCULOS (Terrestre)
INSERT INTO proveedor (prov_nombre, prov_tipo, fk_lugar, fk_usu_codigo) VALUES
('Rent A Car VE', 'Terrestre', 1, 27),
('Auto Rental Venezuela', 'Terrestre', 1, 28),
('Budget Venezuela', 'Terrestre', 1, 29),
('Hertz Venezuela', 'Terrestre', 1, 30),
('Avis Venezuela', 'Terrestre', 1, 31),
('National Car Rental', 'Terrestre', 2, 32),
('Enterprise Rent-A-Car', 'Terrestre', 2, 33),
('Thrifty Car Rental', 'Terrestre', 2, 34),
('Dollar Rent A Car', 'Terrestre', 2, 35),
('Sixt Rent A Car', 'Terrestre', 3, 36),
('Europcar', 'Terrestre', 3, 37),
('Alamo Rent A Car', 'Terrestre', 2, 38),
('Payless Car Rental', 'Terrestre', 2, 39),
('Advantage Rent A Car', 'Terrestre', 2, 40),
('Fox Rent A Car', 'Terrestre', 2, 41),
('Ace Rent A Car', 'Terrestre', 2, 42),
('Economy Rent A Car', 'Terrestre', 1, 43),
('Green Motion', 'Terrestre', 3, 44),
('Firefly Car Rental', 'Terrestre', 3, 45),
('Goldcar', 'Terrestre', 3, 46);

-- 20 EMPRESAS DE SERVICIOS TURÍSTICOS (Otros)
INSERT INTO proveedor (prov_nombre, prov_tipo, fk_lugar, fk_usu_codigo) VALUES
('Tours Venezuela', 'Otros', 1, 47),
('Aventura Extrema VE', 'Otros', 1, 48),
('Eco Tours Caribe', 'Otros', 1, 49),
('Guías Turísticas VE', 'Otros', 1, 50),
('Safari Tours', 'Otros', 5, 51),
('Mountain Adventures', 'Otros', 2, 52),
('Jungle Expeditions', 'Otros', 1, 53),
('Diving World', 'Otros', 6, 54),
('Sky Adventures', 'Otros', 2, 55),
('Cultural Tours VE', 'Otros', 1, 56),
('Beach Paradise Tours', 'Otros', 1, 57),
('Desert Safari Co', 'Otros', 4, 58),
('Wildlife Tours', 'Otros', 5, 59),
('City Tours Express', 'Otros', 3, 60),
('Adventure Sports VE', 'Otros', 1, 61),
('Historical Routes', 'Otros', 3, 62),
('Nature Expeditions', 'Otros', 6, 63),
('Water Sports VE', 'Otros', 1, 64),
('Gastronomic Tours', 'Otros', 3, 65),
('Photography Tours', 'Otros', 4, 66);

-- 10 PARQUES (Otros)
INSERT INTO proveedor (prov_nombre, prov_tipo, fk_lugar, fk_usu_codigo) VALUES
('Parque Nacional Canaima', 'Otros', 19, 67),
('Los Roques', 'Otros', 35, 68),
('Parque La Llovizna', 'Otros', 19, 69),
('Parque Warairarepano', 'Otros', 35, 70),
('Parque Henri Pittier', 'Otros', 16, 71),
('Morrocoy', 'Otros', 22, 72),
('Parque Mochima', 'Otros', 17, 73),
('Medanos de Coro', 'Otros', 22, 74),
('Parque El Agua', 'Otros', 32, 75),
('Parque Chorros Milla', 'Otros', 21, 76);

-- 20 HOTELES (20 adicionales para servicios)
INSERT INTO proveedor (prov_nombre, prov_tipo, fk_lugar, fk_usu_codigo) VALUES
('Hotel Service Corp 1', 'Otros', 1, 77),
('Hotel Service Corp 2', 'Otros', 1, 78),
('Hotel Service Corp 3', 'Otros', 1, 79),
('Hotel Service Corp 4', 'Otros', 1, 80),
('Hotel Service Corp 5', 'Otros', 1, 81),
('Hotel Service Corp 6', 'Otros', 1, 82),
('Hotel Service Corp 7', 'Otros', 1, 83),
('Hotel Service Corp 8', 'Otros', 1, 84),
('Hotel Service Corp 9', 'Otros', 1, 85),
('Hotel Service Corp 10', 'Otros', 1, 86),
('Hotel Service Corp 11', 'Otros', 1, 87),
('Hotel Service Corp 12', 'Otros', 1, 88),
('Hotel Service Corp 13', 'Otros', 1, 89),
('Hotel Service Corp 14', 'Otros', 1, 90),
('Hotel Service Corp 15', 'Otros', 1, 91),
('Hotel Service Corp 16', 'Otros', 1, 92),
('Hotel Service Corp 17', 'Otros', 1, 93),
('Hotel Service Corp 18', 'Otros', 1, 94),
('Hotel Service Corp 19', 'Otros', 1, 95),
('Hotel Service Corp 20', 'Otros', 1, 96);

-- =====================================================
-- 9. HOTELES (20 hoteles)
-- =====================================================
INSERT INTO hotel (hot_nombre, hot_descripcion, hot_valoracion, hot_anos_servicio, fk_lugar) VALUES
('Hotel Caracas Plaza', 'Hotel 5 estrellas en Caracas', 4.5, 25, 36),
('Gran Meliá Caracas', 'Lujo en el centro', 4.8, 30, 36),
('Hotel Maracaibo', 'Confort en Zulia', 4.2, 15, 40),
('Eurobuilding Express', 'Negocios y turismo', 4.3, 20, 36),
('Hesperia WTC Valencia', 'Hotel moderno', 4.4, 18, 42),
('Lidotel Boutique', 'Exclusivo en Margarita', 4.7, 22, 76),
('Tibisay Hotel', 'Vista al Orinoco', 4.0, 12, 50),
('Posada La Montaña', 'Encanto andino', 4.6, 10, 54),
('Hotel del Lago', 'Junto al lago', 4.1, 14, 40),
('Hotel Stauffer', 'Clásico en Barquisimeto', 3.9, 35, 48),
('Margarita Dynasty', 'Resort playero', 4.5, 20, 77),
('Doral Beach Hotel', 'Frente al mar', 4.3, 16, 47),
('Hotel Venetur', 'Cadena nacional', 4.2, 25, 60),
('Kristoff Hotel', 'Negocios en San Cristobal', 4.0, 18, 52),
('Hotel Prado Rio', 'Confort en Mérida', 4.4, 15, 54),
('Ávila Beach Hotel', 'Playa de La Guaira', 3.8, 20, 82),
('Hotel Colón', 'Tradicional en Valencia', 3.7, 40, 42),
('Hotel Bella Vista', 'Vista panorámica', 4.1, 12, 44),
('Caribbean Inn', 'Acogedor en Barcelona', 4.0, 10, 46),
('Posada Los Roques', 'Paraíso caribeño', 4.9, 8, 77);

-- =====================================================
-- 10. RESTAURANTES (10 registros)
-- =====================================================
INSERT INTO restaurante (res_nombre, res_descripcion, res_anos_servicio, res_valoracion, fk_lugar) VALUES
('El Budare Criollo', 'Comida venezolana', 20, 4.5, 36),
('La Casa Bistró', 'Cocina internacional', 15, 4.6, 36),
('Astrid y Gastón', 'Alta cocina', 18, 4.8, 40),
('Maremoto Seafood', 'Especialidad mariscos', 12, 4.4, 47),
('El Fogón de Mamá', 'Comida casera', 25, 4.2, 42),
('La Parrilla del Chef', 'Carnes premium', 10, 4.7, 36),
('Sushi Rolls VE', 'Comida japonesa', 8, 4.3, 36),
('Trattoria Italiana', 'Pasta artesanal', 22, 4.5, 42),
('La Terraza Gourmet', 'Vista panorámica', 14, 4.4, 54),
('Café Colonial', 'Desayunos y meriendas', 30, 4.1, 48);

-- =====================================================
-- 11. TELÉFONOS (10 registros)
-- =====================================================
INSERT INTO telefono (tel_prefijo_pais, tel_prefijo_operador, tel_sufijo, fk_prov_codigo) VALUES
('+58', '212', '5551234', 1),
('+58', '212', '5555678', 2),
('+58', '261', '7778899', 3),
('+1', '305', '8881234', 6),
('+34', '91', '9992345', 10);

INSERT INTO telefono (tel_prefijo_pais, tel_prefijo_operador, tel_sufijo, fk_hotel) VALUES
('+58', '212', '4445566', 1),
('+58', '212', '3337788', 2),
('+58', '261', '2229988', 3),
('+58', '243', '1112233', 5),
('+58', '295', '6667788', 6);

-- =====================================================
-- 12. PLATOS (10 registros)
-- =====================================================
INSERT INTO plato (pla_codigo, pla_nombre, pla_descripcion, pla_costo, fk_restaurante) VALUES
(1, 'Pabellón Criollo', 'Plato típico venezolano', 15.00, 1),
(2, 'Hallaca', 'Especialidad navideña', 8.00, 1),
(3, 'Asado Negro', 'Carne en salsa especial', 18.00, 5),
(4, 'Arroz con Camarones', 'Mariscos frescos', 22.00, 4),
(5, 'Paella Valenciana', 'Arroz con mariscos', 25.00, 8),
(6, 'Sushi Variado', 'Rolls especiales', 28.00, 7),
(7, 'Pasta Carbonara', 'Receta italiana', 16.00, 8),
(8, 'Churrasco', 'Carne a la parrilla', 20.00, 6),
(9, 'Trucha al Ajillo', 'Pescado fresco', 19.00, 9),
(10, 'Desayuno Continental', 'Variado y completo', 12.00, 10);

-- =====================================================
-- 13. NACIONALIDADES (10 registros)
-- =====================================================
INSERT INTO nacionalidad (nac_nombre, nac_descripcion) VALUES
('Venezolana', 'Ciudadano de Venezuela'),
('Estadounidense', 'Ciudadano de Estados Unidos'),
('Española', 'Ciudadano de España'),
('Colombiana', 'Ciudadano de Colombia'),
('Argentina', 'Ciudadano de Argentina'),
('Brasileña', 'Ciudadano de Brasil'),
('Mexicana', 'Ciudadano de México'),
('Chilena', 'Ciudadano de Chile'),
('Peruana', 'Ciudadano de Perú'),
('Italiana', 'Ciudadano de Italia');

-- =====================================================
-- 14. USUARIOS CLIENTES (2 por cada estado = 48 clientes)
-- =====================================================
DO $$
DECLARE
    estado_counter INTEGER;
    municipio_base INTEGER := 36; -- Primer municipio
    usu_id INTEGER;
    via_id INTEGER;
    edo_civil_id INTEGER;
BEGIN
    -- Iterar por cada estado (24 estados)
    FOR estado_counter IN 1..24 LOOP
        -- Cliente 1 del estado
        INSERT INTO usuario (usu_nombre_usuario, usu_contrasena, usu_email, usu_total_millas, fk_rol_codigo, fk_lugar)
        VALUES (
            'cliente_' || estado_counter || '_1',
            'pass123',
            'cliente' || estado_counter || '1@mail.com',
            0,
            3,
            municipio_base + (estado_counter - 1) * 2
        )
        RETURNING usu_codigo INTO usu_id;

        -- Viajero 1 para Cliente 1
        INSERT INTO viajero (via_prim_nombre, via_seg_nombre, via_prim_apellido, via_seg_apellido, via_fecha_nacimiento, fk_usu_codigo)
        VALUES (
            'Juan',
            'Carlos',
            'Pérez',
            'González',
            '1985-03-15',
            usu_id
        )
        RETURNING via_codigo INTO via_id;

        -- Estado civil para viajero 1
        edo_civil_id := ((estado_counter - 1) % 4) + 1;
        INSERT INTO via_edo (fk_via_codigo, fk_edo_codigo, via_edo_fecha_inicio)
        VALUES (via_id, edo_civil_id, '2020-01-01');

        -- Viajero 2 para Cliente 1
        INSERT INTO viajero (via_prim_nombre, via_seg_nombre, via_prim_apellido, via_seg_apellido, via_fecha_nacimiento, fk_usu_codigo)
        VALUES (
            'María',
            'Elena',
            'Rodríguez',
            'Martínez',
            '1990-07-20',
            usu_id
        )
        RETURNING via_codigo INTO via_id;

        -- Estado civil para viajero 2
        edo_civil_id := ((estado_counter) % 4) + 1;
        INSERT INTO via_edo (fk_via_codigo, fk_edo_codigo, via_edo_fecha_inicio)
        VALUES (via_id, edo_civil_id, '2020-01-01');

        -- Cliente 2 del estado
        INSERT INTO usuario (usu_nombre_usuario, usu_contrasena, usu_email, usu_total_millas, fk_rol_codigo, fk_lugar)
        VALUES (
            'cliente_' || estado_counter || '_2',
            'pass123',
            'cliente' || estado_counter || '2@mail.com',
            0,
            3,
            municipio_base + (estado_counter - 1) * 2 + 1
        )
        RETURNING usu_codigo INTO usu_id;

        -- Viajero 1 para Cliente 2
        INSERT INTO viajero (via_prim_nombre, via_seg_nombre, via_prim_apellido, via_seg_apellido, via_fecha_nacimiento, fk_usu_codigo)
        VALUES (
            'Pedro',
            'José',
            'García',
            'López',
            '1988-11-10',
            usu_id
        )
        RETURNING via_codigo INTO via_id;

        -- Estado civil para viajero 1
        edo_civil_id := ((estado_counter + 1) % 4) + 1;
        INSERT INTO via_edo (fk_via_codigo, fk_edo_codigo, via_edo_fecha_inicio)
        VALUES (via_id, edo_civil_id, '2020-01-01');

        -- Viajero 2 para Cliente 2
        INSERT INTO viajero (via_prim_nombre, via_seg_nombre, via_prim_apellido, via_seg_apellido, via_fecha_nacimiento, fk_usu_codigo)
        VALUES (
            'Ana',
            'Lucía',
            'Fernández',
            'Díaz',
            '1992-05-25',
            usu_id
        )
        RETURNING via_codigo INTO via_id;

        -- Estado civil para viajero 2
        edo_civil_id := ((estado_counter + 2) % 4) + 1;
        INSERT INTO via_edo (fk_via_codigo, fk_edo_codigo, via_edo_fecha_inicio)
        VALUES (via_id, edo_civil_id, '2020-01-01');
    END LOOP;
END $$;

-- =====================================================
-- 15. DOCUMENTOS (10 registros de ejemplo)
-- =====================================================
INSERT INTO documento (doc_fecha_emision, doc_fecha_vencimiento, doc_numero_documento, doc_tipo, fk_nac_codigo, fk_via_codigo) VALUES
('2020-01-15', '2030-01-15', 'V12345678', 'Cedula', 1, 1),
('2019-06-20', '2029-06-20', 'P87654321', 'Pasaporte', 1, 2),
('2021-03-10', '2031-03-10', 'V23456789', 'Cedula', 1, 3),
('2020-09-25', '2030-09-25', 'V34567890', 'Cedula', 1, 4),
('2018-12-05', '2028-12-05', 'P11223344', 'Pasaporte', 2, 5),
('2022-02-14', '2032-02-14', 'V45678901', 'Cedula', 1, 6),
('2019-11-30', '2024-11-30', 'VISA001', 'Visa', 3, 7),
('2021-07-18', '2031-07-18', 'V56789012', 'Cedula', 1, 8),
('2020-04-22', '2030-04-22', 'P55667788', 'Pasaporte', 1, 9),
('2022-08-09', '2032-08-09', 'V67890123', 'Cedula', 1, 10);

-- =====================================================
-- 16. PROMOCIONES (10 registros)
-- =====================================================
INSERT INTO promocion (prom_nombre, prom_descripcion, prom_fecha_hora_vencimiento, prom_descuento) VALUES
('Black Friday', 'Desc especial fin año', '2025-11-30 23:59:59', 25.00),
('Cyber Monday', 'Ofertas online', '2025-12-02 23:59:59', 20.00),
('Verano 2025', 'Temporada playera', '2025-08-31 23:59:59', 15.00),
('Semana Santa', 'Vacaciones religiosas', '2025-04-20 23:59:59', 18.00),
('Carnaval', 'Fiesta nacional', '2025-03-05 23:59:59', 12.00),
('Navidad', 'Fin de año', '2025-12-25 23:59:59', 30.00),
('Aniversario', 'Celebración especial', '2025-09-15 23:59:59', 22.00),
('Early Bird', 'Reserva anticipada', '2025-06-30 23:59:59', 10.00),
('Last Minute', 'Última hora', '2025-05-15 23:59:59', 35.00),
('Paquete Familiar', 'Para toda la familia', '2025-12-31 23:59:59', 20.00);

-- =====================================================
-- 17. HABITACIONES (10 registros)
-- =====================================================
INSERT INTO habitacion (hab_capacidad, hab_descripcion, hab_costo_noche, fk_hotel, fk_promocion) VALUES
(2, 'Habitación doble', 80.00, 1, 1),
(4, 'Suite familiar', 150.00, 2, 2),
(2, 'Hab con vista al mar', 120.00, 11, 3),
(3, 'Triple estándar', 100.00, 5, NULL),
(2, 'Doble ejecutiva', 90.00, 14, 4),
(5, 'Suite presidencial', 300.00, 1, 5),
(2, 'Hab económica', 50.00, 17, NULL),
(2, 'Doble con balcón', 95.00, 18, 6),
(4, 'Familiar con cocina', 140.00, 11, 7),
(1, 'Individual', 60.00, 10, NULL);

-- =====================================================
-- 18. TERMINALES (10 registros)
-- =====================================================
INSERT INTO terminal (ter_nombre, fk_lugar, ter_tipo) VALUES
('Aeropuerto Maiquetía', 82, 'Aeropuerto'),
('Aeropuerto La Chinita', 40, 'Aeropuerto'),
('Terminal Oriente', 36, 'Terrestre'),
('Puerto La Guaira', 82, 'Maritimo'),
('Aeropuerto Valencia', 42, 'Aeropuerto'),
('Terminal Nuevo Circo', 36, 'Terrestre'),
('Puerto Cabello', 43, 'Maritimo'),
('Aeropuerto Barcelona', 46, 'Aeropuerto'),
('Terminal La Bandera', 36, 'Terrestre'),
('Aeropuerto Mérida', 54, 'Aeropuerto');

-- =====================================================
-- 19. MEDIOS DE TRANSPORTE (10 registros)
-- =====================================================
INSERT INTO medio_transporte (med_tra_capacidad, med_tra_descripcion, med_tra_tipo, fk_prov_codigo) VALUES
(180, 'Boeing 737', 'Avion', 1),
(150, 'Airbus A320', 'Avion', 2),
(50, 'Bus ejecutivo', 'Autobus', 27),
(2000, 'Crucero Caribe', 'Barco', 22),
(200, 'Boeing 777', 'Avion', 6),
(45, 'Van turística', 'Camioneta', 28),
(300, 'Airbus A380', 'Avion', 10),
(1500, 'Ferry Los Roques', 'Barco', 23),
(4, 'SUV 4x4', 'Camioneta', 29),
(160, 'Embraer 190', 'Avion', 3);

-- =====================================================
-- 20. PUESTOS (10 registros)
-- =====================================================
INSERT INTO puesto (pue_codigo, pue_descripcion, pue_costo_agregado, fk_med_tra_codigo) VALUES
(1, 'Asiento ventana clase económica', 0.00, 1),
(2, 'Asiento pasillo clase económica', 0.00, 1),
(3, 'Asiento ventana clase ejecutiva', 150.00, 1),
(1, 'Asiento estándar', 0.00, 2),
(2, 'Asiento preferencial', 50.00, 2),
(1, 'Asiento bus normal', 0.00, 3),
(1, 'Camarote interior', 0.00, 4),
(2, 'Camarote con balcón', 200.00, 4),
(1, 'Asiento primera clase', 300.00, 5),
(1, 'Asiento van', 0.00, 6);

-- =====================================================
-- 21. RUTAS (10 registros)
-- =====================================================
INSERT INTO ruta (rut_costo, rut_millas_otorgadas, rut_tipo, rut_descripcion,fk_terminal_origen, fk_terminal_destino, fk_prov_codigo) VALUES
(250.00, 500, 'Aerea', 'Practico',1, 2, 1),
(180.00, 350, 'Aerea', 'Corporativo',1, 5, 2),
(30.00, 50, 'Terrestre', 'Practico',3, 6, 27),
(400.00, 800, 'Maritima', 'Corporativo',4, 7, 22),
(220.00, 450, 'Aerea', 'Familiar',5, 8, 6),
(25.00, 40, 'Terrestre', 'Practico',6, 9, 28),
(500.00, 1000, 'Aerea', 'Explorador',1, 10, 10),
(150.00, 300, 'Maritima', 'Familiar',7, 4, 23),
(40.00, 60, 'Terrestre', 'Practico',3, 9, 27),
(280.00, 550, 'Aerea', 'Comfort',2, 5, 3);

-- =====================================================
-- 22. TRASLADOS (10 registros)
-- =====================================================
INSERT INTO traslado (tras_fecha_hora_inicio, tras_fecha_hora_fin, tras_Co2_emitido, fk_rut_codigo, fk_med_tra_codigo) VALUES
('2025-06-15 08:00:00', '2025-06-15 09:30:00', 120.50, 1, 1),
('2025-07-20 10:00:00', '2025-07-20 11:15:00', 95.30, 2, 2),
('2025-08-05 14:00:00', '2025-08-05 18:00:00', 45.20, 3, 3),
('2025-09-10 09:00:00', '2025-09-12 18:00:00', 250.75, 4, 4),
('2025-10-01 07:00:00', '2025-10-01 08:45:00', 110.00, 5, 5),
('2025-11-15 16:00:00', '2025-11-15 20:00:00', 35.60, 6, 6),
('2025-12-20 06:00:00', '2025-12-20 18:00:00', 380.90, 7, 7),
('2026-01-10 11:00:00', '2026-01-12 15:00:00', 180.45, 8, 8),
('2026-02-14 13:00:00', '2026-02-14 17:00:00', 40.20, 9, 9),
('2026-03-05 15:00:00', '2026-03-05 16:30:00', 88.75, 10, 10);

-- =====================================================
-- 23. SERVICIOS (10 registros)
-- =====================================================
INSERT INTO servicio (ser_nombre, ser_descripcion, ser_costo, ser_fecha_hora_inicio, ser_fecha_hora_fin, ser_millas_otorgadas, ser_tipo, fk_prov_codigo) VALUES
('Tour Salto Ángel', 'Explorador', 350.00, '2025-07-15 06:00:00', '2025-07-15 18:00:00', 200, 'Tour', 47),
('Buceo Los Roques', 'Explorador', 180.00, '2025-08-20 08:00:00', '2025-08-20 14:00:00', 100, 'Actividad', 54),
('City Tour Caracas', 'Corporativo', 80.00, '2025-06-10 09:00:00', '2025-06-10 15:00:00', 50, 'Tour', 56),
('Safari Hato Piñero', 'Familiar', 420.00, '2025-09-05 07:00:00', '2025-09-07 17:00:00', 250, 'Tour', 53),
('Parapente Mérida', 'Explorador', 150.00, '2025-10-12 10:00:00', '2025-10-12 12:00:00', 80, 'Actividad', 48),
('Gastronomía Andina', 'Familiar', 95.00, '2025-11-08 11:00:00', '2025-11-08 16:00:00', 60, 'Comida', 65),
('Rafting Río Caura', 'Explorador', 220.00, '2025-12-01 08:00:00', '2025-12-01 15:00:00', 120, 'Actividad', 61),
('Observación Delfines', 'Familiar', 130.00, '2026-01-20 07:00:00', '2026-01-20 11:00:00', 70, 'Tour', 57),
('Escalada Roraima', 'Explorador', 890.00, '2026-02-10 06:00:00', '2026-02-15 16:00:00', 500, 'Tour', 52),
('Seguro de Viaje', 'Corporativo', 50.00, '2025-06-01 00:00:00', '2025-12-31 23:59:59', 0, 'Seguro', 47);

-- =====================================================
-- 24. PAQUETES TURÍSTICOS (10 registros)
-- =====================================================
INSERT INTO paquete_turistico (paq_tur_nombre, paq_tur_monto_total, paq_tur_monto_subtotal, paq_tur_costo_en_millas) VALUES
('Caribe Completo', 1200.00, 1100.00, 5000),
('Aventura Andina', 950.00, 900.00, 4000),
('Relax Playero', 800.00, 750.00, 3500),
('Tour Cultural', 650.00, 600.00, 2800),
('Extremo Venezuela', 1500.00, 1400.00, 6500),
('Familia Feliz', 1800.00, 1700.00, 8000),
('Luna de Miel', 2200.00, 2100.00, 10000),
('Ejecutivo Express', 550.00, 500.00, 2500),
('Eco Turismo', 890.00, 850.00, 3800),
('Gran Tour Nacional', 2500.00, 2400.00, 11000);

-- =====================================================
-- 25. REGLAS DE PAQUETE (10 registros)
-- =====================================================
INSERT INTO regla_paquete (reg_paq_atributo, reg_paq_operador, reg_paq_valor) VALUES
('edad_minima', '>=', '18'),
('edad_maxima', '<=', '65'),
('num_personas', '>=', '2'),
('num_personas', '<=', '6'),
('temporada', '=', 'Verano'),
('experiencia', '=', 'Intermedio'),
('condicion_fisica', '=', 'Buena'),
('certificacion', '=', 'Buceo'),
('peso_max', '<=', '100'),
('altura_min', '>=', '150');

-- =====================================================
-- 26. TABLAS INTERMEDIAS SERVICIOS/PAQUETES/PROMOCIONES
-- =====================================================
INSERT INTO ser_prom (fk_ser_codigo, fk_prom_codigo) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
(6, 6), (7, 7), (8, 8), (9, 9), (10, 1);

INSERT INTO paq_prom (fk_paq_tur_codigo, fk_prom_codigo) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
(6, 6), (7, 7), (8, 8), (9, 9), (10, 10);

INSERT INTO tras_prom (fk_tras_codigo, fk_prom_codigo) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
(6, 6), (7, 7), (8, 8), (9, 9), (10, 10);

INSERT INTO paq_ser (fk_paq_tur_codigo, fk_ser_codigo, cantidad) VALUES
(1, 1, 1), (1, 2, 1), (2, 5, 1), (3, 2, 2),
(4, 3, 1), (5, 7, 1), (6, 3, 2), (7, 2, 1),
(8, 9, 1), (9, 1, 1);

INSERT INTO paq_tras (fk_paq_tur_codigo, fk_tras_codigo) VALUES
(1, 1), (2, 5), (3, 4), (4, 2), (5, 7),
(6, 1), (7, 4), (8, 5), (9, 9), (10, 1);

INSERT INTO reg_paq_paq (fk_reg_paq_codigo, fk_paq_tur_codigo) VALUES
(1, 5), (2, 5), (3, 6), (4, 6), (5, 1),
(6, 9), (7, 9), (8, 2), (9, 7), (10, 5);

-- =====================================================
-- 27. TASAS DE CAMBIO (5 tasas para 3 monedas)
-- =====================================================
INSERT INTO tasa_de_cambio (tas_cam_tasa_valor, tas_cam_fecha_hora_inicio, tas_cam_fecha_hora_fin, tas_cam_moneda) VALUES
(36.50, '2025-01-01 00:00:00', '2025-03-31 23:59:59', 'USD'),
(39.20, '2025-04-01 00:00:00', '2025-06-30 23:59:59', 'USD'),
(42.80, '2025-07-01 00:00:00', NULL, 'USD'),
(40.50, '2025-01-01 00:00:00', '2025-06-30 23:59:59', 'EUR'),
(43.75, '2025-07-01 00:00:00', NULL, 'EUR');

-- =====================================================
-- 28. MILLAS (5 tasas de valor de millas)
-- =====================================================
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

-- =====================================================
-- 29. MÉTODOS DE PAGO (10 registros)
-- ==========================================
INSERT INTO metodo_pago (met_pag_descripcion) VALUES
('Tarjeta de crédito Visa'),
('Tarjeta débito Mastercard'),
('Pago móvil'),
('Transferencia bancaria'),
('Efectivo USD'),
('Zelle'),
('Cheque'),
('Depósito bancario'),
('Criptomoneda Bitcoin'),
('Pago con millas');

-- Detalles de métodos de pago
INSERT INTO tarjeta_credito (met_pago_codigo, tar_cre_numero, tar_cre_cvv, tar_cre_fecha_vencimiento, tar_cre_banco_emisor, tar_cre_nombre_titular) VALUES
(1, '4111111111111111', '123', '2027-12-31', 'Banco de Venezuela', 'Juan Pérez');

INSERT INTO tarjeta_debito (met_pago_codigo, tar_deb_numero, tar_deb_cvv, tar_deb_fecha_vencimiento, tar_deb_banco_emisor, tar_deb_nombre_titular) VALUES
(2, '5500000000000004', '456', '2026-08-31', 'Banesco', 'María Rodríguez');

INSERT INTO pago_movil_interbancario (met_pago_codigo, pag_movil_int_numero_referencia, pag_movil_int_fecha_hora) VALUES
(3, '123456789012345', '2025-06-01 10:30:00');

INSERT INTO transferencia_bancaria (met_pago_codigo, trans_ban_numero_referencia, trans_ban_fecha_hora, tras_ban_numero_cuenta_emisora) VALUES
(4, 987654321, '2025-06-02 14:20:00', '01020123456789012345');

INSERT INTO efectivo (met_pago_codigo, efe_moneda, efe_codigo) VALUES
(5, 'USD', 'CASH001');

INSERT INTO zelle (met_pago_codigo, zel_titular_cuenta, zel_correo_electronico, zel_codigo_transaccion) VALUES
(6, 'Juan Pérez', 'juan@email.com', 'ZEL123456789');

INSERT INTO cheque (met_pago_codigo, che_codigo_cuenta_cliente, che_numero, che_nombre_titular, che_banco_emisor, cheque_fecha_emision) VALUES
(7, '0102012345678', '00012345', 'Pedro García', 'Banco Mercantil', '2025-06-03');

INSERT INTO deposito_bancario (met_pago_codigo, dep_ban_numero_cuenta, dep_ban_banco_emisor, dep_ban_numero_referencia, dep_fecha_transaccion) VALUES
(8, '01020987654321', 'Provincial', 'DEP456789', '2025-06-04');

INSERT INTO criptomoneda (met_pago_codigo, cri_hash_transaccion, cri_direccion_billetera_emisora) VALUES
(9, 'abc123def456', '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa');

INSERT INTO milla_pago (met_pag_codigo, mil_codigo, mil_cantidad_utilizada) VALUES
(10, NULL, 0);

-- =====================================================
-- 30. COMPRAS Y SERVICIOS COMBINADOS
-- =====================================================
-- Compras para los primeros 10 clientes (cada uno con 2 viajeros)
-- Cada compra combina al menos 2 servicios

-- Compra 1: Cliente 1 - Vuelo + Hotel
INSERT INTO compra (com_monto_total, com_monto_subtotal, com_fecha, fk_usuario, fk_plan_financiamiento)
VALUES (530.00, 500.00, '2025-06-01', 97, NULL);

-- Detalle 1: Traslado aéreo
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado)
VALUES (1, '2025-06-01', '10:00:00', 250.00, 250.00, 1, 1, 1, NULL, 'Confirmada');

-- Asignar puesto del traslado
INSERT INTO pue_tras (fk_tras_codigo, fk_pue_codigo, fk_med_tra_codigo, fk_paq_tur_codigo)
VALUES (1, 1, 1, NULL);

UPDATE detalle_reserva SET fk_pue_tras = 1, fk_pue_tras1 = 1, fk_pue_tras2 = 1
WHERE fk_compra = 1 AND det_res_codigo = 1;

-- Detalle 2: Estadía hotel
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado)
VALUES (2, '2025-06-01', '10:05:00', 280.00, 250.00, 1, 1, 1, NULL, 'Confirmada');

-- Reserva de habitación
INSERT INTO reserva_de_habitacion (res_hab_fecha_hora_inicio, res_hab_fecha_hora_fin, res_hab_costo_unitario, fk_habitacion, fk_detalle_reserva, fk_detalle_reserva_2, fk_paquete_turistico)
VALUES ('2025-06-15 14:00:00', '2025-06-18 12:00:00', 80.00, 1, 1, 2, NULL);

-- Compra 2: Cliente 2 - Tour + Restaurante
INSERT INTO compra (com_monto_total, com_monto_subtotal, com_fecha, fk_usuario, fk_plan_financiamiento)
VALUES (465.00, 430.00, '2025-07-10', 98, NULL);

INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado)
VALUES (1, '2025-07-10', '11:00:00', 350.00, 350.00, 3, 1, 2, 1, 'Confirmada');

INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado)
VALUES (2, '2025-07-10', '11:10:00', 115.00, 80.00, 3, 1, 2, NULL, 'Confirmada');

INSERT INTO reserva_restaurante (res_rest_fecha_hora, res_rest_num_mesa, res_rest_tamano_mesa, fk_restaurante, fk_detalle_reserva, fk_detalle_reserva_2, fk_paquete_turistico)
VALUES ('2025-07-15 19:00:00', 5, 4, 1, 2, 2, NULL);

-- Compra 3: Cliente 3 - Paquete turístico completo
INSERT INTO compra (com_monto_total, com_monto_subtotal, com_fecha, fk_usuario, fk_plan_financiamiento)
VALUES (1200.00, 1100.00, '2025-08-05', 99, NULL);

INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_paquete_turistico, det_res_estado)
VALUES (1, '2025-08-05', '09:00:00', 1200.00, 1100.00, 5, 1, 3, 1, 'Confirmada');

-- Compra 4: Cliente 4 - Vuelo + Servicio
INSERT INTO compra (com_monto_total, com_monto_subtotal, com_fecha, fk_usuario, fk_plan_financiamiento)
VALUES (400.00, 380.00, '2025-09-12', 100, NULL);

INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado)
VALUES (1, '2025-09-12', '15:00:00', 220.00, 220.00, 7, 1, 4, 7, 'Confirmada');

INSERT INTO pue_tras (fk_tras_codigo, fk_pue_codigo, fk_med_tra_codigo, fk_paq_tur_codigo)
VALUES (5, 1, 5, NULL);

INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_pue_tras, fk_pue_tras1, fk_pue_tras2, det_res_estado)
VALUES (2, '2025-09-12', '15:05:00', 180.00, 160.00, 7, 1, 4, 2, 5, 5, 'Confirmada');

-- Compra 5: Cliente 5 - Hotel + Tour
INSERT INTO compra (com_monto_total, com_monto_subtotal, com_fecha, fk_usuario, fk_plan_financiamiento)
VALUES (530.00, 500.00, '2025-10-20', 101, NULL);

INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado)
VALUES (1, '2025-10-20', '12:00:00', 350.00, 350.00, 9, 1, 5, 4, 'Confirmada');

INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado)
VALUES (2, '2025-10-20', '12:10:00', 180.00, 150.00, 9, 1, 5, NULL, 'Confirmada');

INSERT INTO reserva_de_habitacion (res_hab_fecha_hora_inicio, res_hab_fecha_hora_fin, res_hab_costo_unitario, fk_habitacion, fk_detalle_reserva, fk_detalle_reserva_2, fk_paquete_turistico)
VALUES ('2025-10-25 14:00:00', '2025-10-27 12:00:00', 80.00, 2, 5, 2, NULL);

-- Compra 6: Cliente 6 - Traslado + Servicio
INSERT INTO compra (com_monto_total, com_monto_subtotal, com_fecha, fk_usuario, fk_plan_financiamiento)
VALUES (210.00, 200.00, '2025-11-05', 102, NULL);

INSERT INTO pue_tras (fk_tras_codigo, fk_pue_codigo, fk_med_tra_codigo, fk_paq_tur_codigo)
VALUES (3, 1, 3, NULL);

INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_pue_tras, fk_pue_tras1, fk_pue_tras2, det_res_estado)
VALUES (1, '2025-11-05', '08:00:00', 30.00, 30.00, 11, 1, 6, 3, 3, 3, 'Confirmada');

INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado)
VALUES (2, '2025-11-05', '08:10:00', 180.00, 170.00, 11, 1, 6, 2, 'Confirmada');

-- Compra 7: Cliente 7 - Paquete turístico
INSERT INTO compra (com_monto_total, com_monto_subtotal, com_fecha, fk_usuario, fk_plan_financiamiento)
VALUES (950.00, 900.00, '2025-11-20', 103, NULL);

INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_paquete_turistico, det_res_estado)
VALUES (1, '2025-11-20', '10:00:00', 950.00, 900.00, 13, 1, 7, 2, 'Confirmada');

-- Compra 8: Cliente 8 - Vuelo + Hotel + Tour
INSERT INTO compra (com_monto_total, com_monto_subtotal, com_fecha, fk_usuario, fk_plan_financiamiento)
VALUES (810.00, 780.00, '2025-12-01', 104, NULL);

INSERT INTO pue_tras (fk_tras_codigo, fk_pue_codigo, fk_med_tra_codigo, fk_paq_tur_codigo)
VALUES (2, 1, 2, NULL);

INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_pue_tras, fk_pue_tras1, fk_pue_tras2, det_res_estado)
VALUES (1, '2025-12-01', '09:00:00', 180.00, 180.00, 15, 1, 8, 4, 2, 2, 'Confirmada');

INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado)
VALUES (2, '2025-12-01', '09:10:00', 450.00, 420.00, 15, 1, 8, NULL, 'Confirmada');

INSERT INTO reserva_de_habitacion (res_hab_fecha_hora_inicio, res_hab_fecha_hora_fin, res_hab_costo_unitario, fk_habitacion, fk_detalle_reserva, fk_detalle_reserva_2, fk_paquete_turistico)
VALUES ('2025-12-10 14:00:00', '2025-12-15 12:00:00', 80.00, 3, 8, 2, NULL);

INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado)
VALUES (3, '2025-12-01', '09:20:00', 180.00, 180.00, 15, 1, 8, 2, 'Confirmada');

-- Compra 9: Cliente 9 - Tour + Restaurante
INSERT INTO compra (com_monto_total, com_monto_subtotal, com_fecha, fk_usuario, fk_plan_financiamiento)
VALUES (445.00, 430.00, '2025-12-15', 105, NULL);

INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado)
VALUES (1, '2025-12-15', '11:00:00', 350.00, 350.00, 17, 1, 9, 1, 'Confirmada');

INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado)
VALUES (2, '2025-12-15', '11:10:00', 95.00, 80.00, 17, 1, 9, 6, 'Confirmada');

INSERT INTO reserva_restaurante (res_rest_fecha_hora, res_rest_num_mesa, res_rest_tamano_mesa, fk_restaurante, fk_detalle_reserva, fk_detalle_reserva_2, fk_paquete_turistico)
VALUES ('2025-12-20 20:00:00', 8, 4, 2, 9, 2, NULL);

-- Compra 10: Cliente 10 - Hotel + Tour
INSERT INTO compra (com_monto_total, com_monto_subtotal, com_fecha, fk_usuario, fk_plan_financiamiento)
VALUES (500.00, 480.00, '2026-01-10', 106, NULL);

INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado)
VALUES (1, '2026-01-10', '10:00:00', 320.00, 300.00, 19, 1, 10, NULL, 'Confirmada');

INSERT INTO reserva_de_habitacion (res_hab_fecha_hora_inicio, res_hab_fecha_hora_fin, res_hab_costo_unitario, fk_habitacion, fk_detalle_reserva, fk_detalle_reserva_2, fk_paquete_turistico)
VALUES ('2026-01-20 14:00:00', '2026-01-24 12:00:00', 80.00, 4, 10, 1, NULL);

INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado)
VALUES (2, '2026-01-10', '10:10:00', 180.00, 180.00, 19, 1, 10, 2, 'Confirmada');

-- =====================================================
-- 31. PAGOS (10 registros)
-- =====================================================
INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago) VALUES
(530.00, '2025-06-01 10:30:00', 'USD', 1, 1, 1),
(465.00, '2025-07-10 11:30:00', 'USD', 2, 2, 2),
(1200.00, '2025-08-05 09:30:00', 'USD', 3, 3, 3),
(400.00, '2025-09-12 15:30:00', 'EUR', 4, 4, 4),
(530.00, '2025-10-20 12:30:00', 'USD', 5, 3, 5),
(210.00, '2025-11-05 08:30:00', 'USD', 6, 3, 6),
(950.00, '2025-11-20 10:30:00', 'EUR', 7, 5, 7),
(810.00, '2025-12-01 09:30:00', 'USD', 8, 3, 8),
(445.00, '2025-12-15 11:30:00', 'USD', 9, 3, 9),
(500.00, '2026-01-10 10:30:00', 'USD', 10, 3, 1);

-- =====================================================
-- 32. MILLAS GENERADAS (10 registros)
-- =====================================================
INSERT INTO milla (mil_valor_obtenido, mil_fecha_inicio, mil_fecha_fin, mil_valor_restado, fk_compra, fk_pago) VALUES
(500, '2025-06-01', '2026-06-01', 0, 1, 1),
(200, '2025-07-10', '2026-07-10', 0, 2, 2),
(1000, '2025-08-05', '2026-08-05', 0, 3, 3),
(450, '2025-09-12', '2026-09-12', 0, 4, 4),
(500, '2025-10-20', '2026-10-20', 0, 5, 5),
(100, '2025-11-05', '2026-11-05', 0, 6, 6),
(800, '2025-11-20', '2026-11-20', 0, 7, 7),
(600, '2025-12-01', '2026-12-01', 0, 8, 8),
(250, '2025-12-15', '2026-12-15', 0, 9, 9),
(400, '2026-01-10', '2027-01-10', 0, 10, 10);

-- =====================================================
-- 33. ESTADOS (10 registros)
-- =====================================================
INSERT INTO estado (est_nombre, est_descripcion) VALUES
('Pendiente', 'Reserva en espera de confirmación'),
('Confirmado', 'Reserva confirmada'),
('En Proceso', 'Servicio en ejecución'),
('Completado', 'Servicio finalizado'),
('Cancelado', 'Reserva cancelada'),
('Reembolsado', 'Pago devuelto'),
('Vencido', 'Plazo expirado'),
('Pagado', 'Pago procesado'),
('Pendiente Pago', 'Esperando pago'),
('En Espera', 'Estado temporal');

-- =====================================================
-- 34. ACCIONES (10 registros)
-- =====================================================
INSERT INTO accion (acc_nombre, acc_descripcion) VALUES
('Crear', 'Creación de nuevo registro'),
('Actualizar', 'Modificación de registro'),
('Eliminar', 'Borrado de registro'),
('Consultar', 'Lectura de información'),
('Login', 'Inicio de sesión'),
('Logout', 'Cierre de sesión'),
('Reservar', 'Crear reservación'),
('Cancelar', 'Cancelar operación'),
('Pagar', 'Procesar pago'),
('Reembolsar', 'Devolver dinero');

-- =====================================================
-- 35. RECURSOS (10 registros)
-- =====================================================
INSERT INTO recurso (recu_nombre_tabla, recu_descripcion) VALUES
('usuario', 'Tabla de usuarios del sistema'),
('compra', 'Tabla de compras realizadas'),
('detalle_reserva', 'Detalles de reservaciones'),
('pago', 'Registro de pagos'),
('proveedor', 'Proveedores de servicios'),
('servicio', 'Servicios ofrecidos'),
('traslado', 'Traslados programados'),
('hotel', 'Hoteles disponibles'),
('viajero', 'Información de viajeros'),
('paquete_turistico', 'Paquetes turísticos');

-- =====================================================
-- 36. PREFERENCIAS (10 registros)
-- =====================================================
INSERT INTO preferencia (fk_usuario, fk_categoria) VALUES
(97, 1), (97, 2), (98, 3), (98, 4), (99, 5),
(100, 1), (101, 7), (102, 8), (103, 9), (104, 10);

-- =====================================================
-- 37. LISTA DE DESEOS (10 registros)
-- =====================================================
INSERT INTO lista_deseos (fk_usuario, fk_paquete_turistico, fk_servicio, fk_traslado) VALUES
(97, 1, 1, 1),
(98, 2, 2, 2),
(99, 3, 3, 3),
(100, 4, 4, 4),
(101, 5, 5, 5),
(102, 6, 6, 6),
(103, 7, 7, 7),
(104, 8, 8, 8),
(105, 9, 9, 9),
(106, 10, 10, 10);

-- =====================================================
-- 38. RESEÑAS (10 registros)
-- =====================================================
INSERT INTO resena (res_calificacion_numerica, res_descripcion, res_fecha_hota_creacion, fk_detalle_reserva, fk_detalle_reserva_2) VALUES
(5, 'Excelente servicio', '2025-06-20 10:00:00', 1, 1),
(4, 'Muy buena experiencia', '2025-07-25 11:00:00', 2, 1),
(5, 'Recomendado totalmente', '2025-08-20 12:00:00', 3, 1),
(3, 'Aceptable', '2025-09-20 13:00:00', 4, 1),
(4, 'Buen servicio', '2025-10-30 14:00:00', 5, 1),
(5, 'Perfecto', '2025-11-10 15:00:00', 6, 1),
(4, 'Muy satisfecho', '2025-11-25 16:00:00', 7, 1),
(5, 'Increíble experiencia', '2025-12-20 17:00:00', 8, 1),
(4, 'Recomendable', '2025-12-25 18:00:00', 9, 1),
(5, 'Excelente', '2026-01-25 19:00:00', 10, 1);

-- =====================================================
-- 39. RECLAMOS (10 registros)
-- =====================================================
INSERT INTO reclamo (rec_contenido, rec_fecha_hora, fk_detalle_reserva, fk_detalle_reserva_2) VALUES
('Retraso en el vuelo', '2025-06-16 10:00:00', 1, 1),
('Habitación no disponible', '2025-07-21 11:00:00', 2, 2),
('Servicio no prestado', '2025-08-16 12:00:00', 3, 1),
('Comida fría', '2025-09-16 13:00:00', 4, 2),
('Guía no llegó', '2025-10-26 14:00:00', 5, 1),
('Bus en mal estado', '2025-11-06 15:00:00', 6, 1),
('Hotel sucio', '2025-11-21 16:00:00', 7, 1),
('Tour cancelado', '2025-12-16 17:00:00', 8, 3),
('Mesa no reservada', '2025-12-21 18:00:00', 9, 2),
('Paquete incompleto', '2026-01-21 19:00:00', 10, 2);

-- =====================================================
-- 40. COMPENSACIONES (10 registros)
-- =====================================================
INSERT INTO compensacion (com_co2_compensado, com_monto_agregado, fk_compra) VALUES
(120.50, 10.00, 1),
(95.30, 8.00, 2),
(250.75, 20.00, 3),
(110.00, 9.00, 4),
(45.20, 4.00, 5),
(380.90, 30.00, 6),
(180.45, 15.00, 7),
(88.75, 7.00, 8),
(150.00, 12.00, 9),
(200.00, 16.00, 10);

-- =====================================================
-- SCRIPT COMPLETADO EXITOSAMENTE
-- =====================================================
