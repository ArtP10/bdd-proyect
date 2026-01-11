-- =====================================================
-- SCRIPT DE INSERCIÓN COMPLETO Y CORREGIDO
-- SISTEMA DE GESTIÓN DE VIAJES Y TURISMO
-- =====================================================

-- =====================================================
-- 1. ESTADOS CIVILES (4 registros)
-- =====================================================
INSERT INTO estado_civil (edo_civ_nombre, edo_civ_descripcion) VALUES 
('Soltero/a', 'Persona que nunca ha contraído matrimonio'),
('Casado/a', 'Persona unida en matrimonio'),
('Divorciado/a', 'Persona que ha disuelto su vínculo matrimonial'),
('Viudo/a', 'Persona cuyo cónyuge ha fallecido');

-- =====================================================
-- 2. ROLES (3 registros)
-- =====================================================
INSERT INTO rol(rol_nombre, rol_descripcion) VALUES 
('Administrador', 'Administrador del sistema.'),
('Proveedor', 'Responsable de proveedor de servicios'),
('Cliente', 'Consumidor/Comprador de servicios');

-- =====================================================
-- 3. PRIVILEGIOS (9 registros)
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
-- 4. ROL_PRIVILEGIO (Asignación)
-- =====================================================
INSERT INTO rol_privilegio(fk_rol_codigo, fk_pri_codigo) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9), -- Admin
(2, 3), (2, 5), (2, 6), (2, 7), -- Proveedor
(3, 8), (3, 9); -- Cliente

-- =====================================================
-- 5. LUGARES (Jerarquía completa: País -> Ciudad / Estado -> Municipio)
-- =====================================================
-- Países
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES
('Pais', 'Venezuela', NULL), ('Pais', 'Estados Unidos', NULL), ('Pais', 'España', NULL),
('Pais', 'Japón', NULL), ('Pais', 'Sudáfrica', NULL), ('Pais', 'Australia', NULL);

-- Ciudades internacionales
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES
('Ciudad', 'Nueva York', 2), ('Ciudad', 'Madrid', 3), ('Ciudad', 'Tokio', 4),
('Ciudad', 'Ciudad del Cabo', 5), ('Ciudad', 'Sídney', 6);

-- Estados de Venezuela (IDs 12 al 35)
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES
('Estado', 'Distrito Capital', 1), ('Estado', 'Miranda', 1), ('Estado', 'Zulia', 1),
('Estado', 'Carabobo', 1), ('Estado', 'Aragua', 1), ('Estado', 'Anzoátegui', 1),
('Estado', 'Lara', 1), ('Estado', 'Bolívar', 1), ('Estado', 'Táchira', 1),
('Estado', 'Mérida', 1), ('Estado', 'Falcón', 1), ('Estado', 'Portuguesa', 1),
('Estado', 'Sucre', 1), ('Estado', 'Barinas', 1), ('Estado', 'Trujillo', 1),
('Estado', 'Yaracuy', 1), ('Estado', 'Monagas', 1), ('Estado', 'Cojedes', 1),
('Estado', 'Apure', 1), ('Estado', 'Guárico', 1), ('Estado', 'Nueva Esparta', 1),
('Estado', 'Amazonas', 1), ('Estado', 'Delta Amacuro', 1), ('Estado', 'Vargas', 1);

-- Municipios de Venezuela (IDs 36 al 83)
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES
('Municipio', 'Libertador', 12), ('Municipio', 'Chacao', 12),
('Municipio', 'Baruta', 13), ('Municipio', 'Sucre', 13),
('Municipio', 'Maracaibo', 14), ('Municipio', 'Cabimas', 14),
('Municipio', 'Valencia', 15), ('Municipio', 'Puerto Cabello', 15),
('Municipio', 'Maracay', 16), ('Municipio', 'La Victoria', 16),
('Municipio', 'Barcelona', 17), ('Municipio', 'Puerto La Cruz', 17),
('Municipio', 'Barquisimeto', 18), ('Municipio', 'Cabudare', 18),
('Municipio', 'Ciudad Bolívar', 19), ('Municipio', 'Puerto Ordaz', 19),
('Municipio', 'San Cristóbal', 20), ('Municipio', 'Táriba', 20),
('Municipio', 'Mérida', 21), ('Municipio', 'Ejido', 21),
('Municipio', 'Coro', 22), ('Municipio', 'Punto Fijo', 22),
('Municipio', 'Guanare', 23), ('Municipio', 'Acarigua', 23),
('Municipio', 'Cumaná', 24), ('Municipio', 'Carúpano', 24),
('Municipio', 'Barinas', 25), ('Municipio', 'Barinitas', 25),
('Municipio', 'Trujillo', 26), ('Municipio', 'Valera', 26),
('Municipio', 'San Felipe', 27), ('Municipio', 'Yaritagua', 27),
('Municipio', 'Maturín', 28), ('Municipio', 'Punta de Mata', 28),
('Municipio', 'San Carlos', 29), ('Municipio', 'Tinaquillo', 29),
('Municipio', 'San Fernando', 30), ('Municipio', 'Biruaca', 30),
('Municipio', 'San Juan', 31), ('Municipio', 'Calabozo', 31),
('Municipio', 'La Asunción', 32), ('Municipio', 'Porlamar', 32),
('Municipio', 'Puerto Ayacucho', 33), ('Municipio', 'Atures', 33),
('Municipio', 'Tucupita', 34), ('Municipio', 'Pedernales', 34),
('Municipio', 'La Guaira', 35), ('Municipio', 'Macuto', 35);

-- =====================================================
-- 6. USUARIO ADMINISTRADOR
-- =====================================================
INSERT INTO usuario(usu_nombre_usuario, usu_contrasena, usu_email, fk_rol_codigo, fk_lugar)
VALUES('artadmin', '1234', '10arturojpinto@gmail.com', 1, 36);

-- =====================================================
-- 7. USUARIOS PROVEEDORES (95 usuarios)
-- =====================================================
DO $$
DECLARE i INTEGER;
BEGIN
    FOR i IN 1..95 LOOP
        INSERT INTO usuario(usu_nombre_usuario, usu_contrasena, usu_email, fk_rol_codigo, fk_lugar)
        VALUES('proveedor' || i, 'pass' || i, 'proveedor' || i || '@turismo.com', 2, 36);
    END LOOP;
END $$;

-- =====================================================
-- 8. PROVEEDORES (95 total - FECHA DE CREACIÓN 1 a 50 AÑOS)
-- =====================================================
-- 20 AEROLÍNEAS
INSERT INTO proveedor (prov_nombre, prov_tipo, fk_lugar, fk_usu_codigo, prov_fecha_creacion) VALUES
('Avior Airlines', 'Aerolinea', 36, 2, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Conviasa', 'Aerolinea', 36, 3, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Laser Airlines', 'Aerolinea', 36, 4, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Turpial Airlines', 'Aerolinea', 36, 5, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Estelar Latinoamerica', 'Aerolinea', 36, 6, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Copa Airlines', 'Aerolinea', 7, 7, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('American Airlines', 'Aerolinea', 7, 8, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('United Airlines', 'Aerolinea', 7, 9, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Delta Air Lines', 'Aerolinea', 7, 10, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Iberia', 'Aerolinea', 8, 11, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Air Europa', 'Aerolinea', 8, 12, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('LATAM Airlines', 'Aerolinea', 36, 13, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Avianca', 'Aerolinea', 36, 14, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Air France', 'Aerolinea', 8, 15, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Lufthansa', 'Aerolinea', 8, 16, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('British Airways', 'Aerolinea', 8, 17, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('KLM', 'Aerolinea', 8, 18, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Turkish Airlines', 'Aerolinea', 9, 19, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Emirates', 'Aerolinea', 9, 20, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Qatar Airways', 'Aerolinea', 9, 21, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date);

-- 5 EMPRESAS DE CRUCEROS
INSERT INTO proveedor (prov_nombre, prov_tipo, fk_lugar, fk_usu_codigo, prov_fecha_creacion) VALUES
('Caribbean Cruise Line', 'Maritimo', 36, 22, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Ocean Adventures', 'Maritimo', 7, 23, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Royal Cruises', 'Maritimo', 8, 24, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('MSC Cruceros', 'Maritimo', 8, 25, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Costa Cruceros', 'Maritimo', 8, 26, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date);

-- 20 EMPRESAS DE ALQUILER DE VEHÍCULOS
INSERT INTO proveedor (prov_nombre, prov_tipo, fk_lugar, fk_usu_codigo, prov_fecha_creacion) VALUES
('Rent A Car VE', 'Terrestre', 36, 27, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Auto Rental Venezuela', 'Terrestre', 36, 28, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Budget Venezuela', 'Terrestre', 36, 29, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Hertz Venezuela', 'Terrestre', 36, 30, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Avis Venezuela', 'Terrestre', 36, 31, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('National Car Rental', 'Terrestre', 7, 32, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Enterprise Rent-A-Car', 'Terrestre', 7, 33, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Thrifty Car Rental', 'Terrestre', 7, 34, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Dollar Rent A Car', 'Terrestre', 7, 35, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Sixt Rent A Car', 'Terrestre', 8, 36, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Europcar', 'Terrestre', 8, 37, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Alamo Rent A Car', 'Terrestre', 7, 38, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Payless Car Rental', 'Terrestre', 7, 39, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Advantage Rent A Car', 'Terrestre', 7, 40, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Fox Rent A Car', 'Terrestre', 7, 41, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Ace Rent A Car', 'Terrestre', 7, 42, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Economy Rent A Car', 'Terrestre', 36, 43, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Green Motion', 'Terrestre', 8, 44, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Firefly Car Rental', 'Terrestre', 8, 45, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Goldcar', 'Terrestre', 8, 46, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date);

-- 20 EMPRESAS DE SERVICIOS TURÍSTICOS
INSERT INTO proveedor (prov_nombre, prov_tipo, fk_lugar, fk_usu_codigo, prov_fecha_creacion) VALUES
('Tours Venezuela', 'Otros', 36, 47, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Aventura Extrema VE', 'Otros', 36, 48, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Eco Tours Caribe', 'Otros', 36, 49, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Guías Turísticas VE', 'Otros', 36, 50, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Safari Tours', 'Otros', 10, 51, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Mountain Adventures', 'Otros', 7, 52, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Jungle Expeditions', 'Otros', 36, 53, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Diving World', 'Otros', 11, 54, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Sky Adventures', 'Otros', 7, 55, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Cultural Tours VE', 'Otros', 36, 56, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Beach Paradise Tours', 'Otros', 36, 57, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Desert Safari Co', 'Otros', 9, 58, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Wildlife Tours', 'Otros', 10, 59, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('City Tours Express', 'Otros', 8, 60, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Adventure Sports VE', 'Otros', 36, 61, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Historical Routes', 'Otros', 8, 62, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Nature Expeditions', 'Otros', 11, 63, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Water Sports VE', 'Otros', 36, 64, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Gastronomic Tours', 'Otros', 8, 65, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Photography Tours', 'Otros', 9, 66, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date);

-- 10 PARQUES
INSERT INTO proveedor (prov_nombre, prov_tipo, fk_lugar, fk_usu_codigo, prov_fecha_creacion) VALUES
('Parque Nacional Canaima', 'Otros', 50, 67, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Los Roques', 'Otros', 82, 68, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Parque La Llovizna', 'Otros', 50, 69, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Parque Warairarepano', 'Otros', 36, 70, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Parque Henri Pittier', 'Otros', 44, 71, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Morrocoy', 'Otros', 56, 72, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Parque Mochima', 'Otros', 46, 73, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Medanos de Coro', 'Otros', 56, 74, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Parque El Agua', 'Otros', 77, 75, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Parque Chorros Milla', 'Otros', 54, 76, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date);

-- 20 HOTELES (Proveedores)
INSERT INTO proveedor (prov_nombre, prov_tipo, fk_lugar, fk_usu_codigo, prov_fecha_creacion) VALUES
('Hotel Service Corp 1', 'Otros', 36, 77, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Hotel Service Corp 2', 'Otros', 36, 78, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Hotel Service Corp 3', 'Otros', 36, 79, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Hotel Service Corp 4', 'Otros', 36, 80, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Hotel Service Corp 5', 'Otros', 36, 81, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Hotel Service Corp 6', 'Otros', 36, 82, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Hotel Service Corp 7', 'Otros', 36, 83, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Hotel Service Corp 8', 'Otros', 36, 84, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Hotel Service Corp 9', 'Otros', 36, 85, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Hotel Service Corp 10', 'Otros', 36, 86, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Hotel Service Corp 11', 'Otros', 36, 87, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Hotel Service Corp 12', 'Otros', 36, 88, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Hotel Service Corp 13', 'Otros', 36, 89, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Hotel Service Corp 14', 'Otros', 36, 90, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Hotel Service Corp 15', 'Otros', 36, 91, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Hotel Service Corp 16', 'Otros', 36, 92, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Hotel Service Corp 17', 'Otros', 36, 93, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Hotel Service Corp 18', 'Otros', 36, 94, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Hotel Service Corp 19', 'Otros', 36, 95, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date),
('Hotel Service Corp 20', 'Otros', 36, 96, (CURRENT_DATE - (floor(365 + random() * 17885) || ' days')::interval)::date);
-- =====================================================
-- 9. HOTELES (20 establecimientos)
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
('+58', '212', '5551234', 1), ('+58', '212', '5555678', 2), ('+58', '261', '7778899', 3),
('+1', '305', '8881234', 6), ('+34', '91', '9992345', 10);

INSERT INTO telefono (tel_prefijo_pais, tel_prefijo_operador, tel_sufijo, fk_hotel) VALUES
('+58', '212', '4445566', 1), ('+58', '212', '3337788', 2), ('+58', '261', '2229988', 3),
('+58', '243', '1112233', 5), ('+58', '295', '6667788', 6);

-- =====================================================
-- 12. PLATOS (10 registros)
-- =====================================================
INSERT INTO plato (pla_codigo, pla_nombre, pla_descripcion, pla_costo, fk_restaurante) VALUES
(1, 'Pabellón Criollo', 'Plato típico', 15.00, 1), (2, 'Hallaca', 'Especialidad', 8.00, 1),
(3, 'Asado Negro', 'Carne salsa', 18.00, 5), (4, 'Arroz Camarones', 'Mariscos', 22.00, 4),
(5, 'Paella', 'Arroz mariscos', 25.00, 8), (6, 'Sushi Variado', 'Rolls', 28.00, 7),
(7, 'Pasta Carbonara', 'Italiana', 16.00, 8), (8, 'Churrasco', 'Parrilla', 20.00, 6),
(9, 'Trucha', 'Pescado', 19.00, 9), (10, 'Desayuno', 'Variado', 12.00, 10);

-- =====================================================
-- 13. NACIONALIDADES (10 registros)
-- =====================================================
INSERT INTO nacionalidad (nac_nombre) VALUES
('Venezolana'), ('Estadounidense'), ('Española'), ('Colombiana'), ('Argentina'),
('Brasileña'), ('Mexicana'), ('Chilena'), ('Peruana'), ('Italiana');

-- =====================================================
-- 14. USUARIOS CLIENTES (Generación Automática: 48 clientes, 2 por estado)
-- =====================================================
DO $$
DECLARE
    estado_counter INTEGER;
    municipio_base INTEGER := 36;
    usu_id INTEGER;
    via_id INTEGER;
BEGIN
    FOR estado_counter IN 1..24 LOOP
        -- Cliente 1
        INSERT INTO usuario (usu_nombre_usuario, usu_contrasena, usu_email, fk_rol_codigo, fk_lugar)
        VALUES ('cliente_' || estado_counter || '_1', 'pass', 'c' || estado_counter || '1@mail.com', 3, municipio_base + (estado_counter - 1) * 2)
        RETURNING usu_codigo INTO usu_id;
        
        -- Viajeros para Cliente 1
        INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo)
        VALUES ('Juan', 'Perez', '1990-01-01', usu_id) RETURNING via_codigo INTO via_id;
        INSERT INTO via_edo (fk_via_codigo, fk_edo_codigo, via_edo_fecha_inicio) VALUES (via_id, 1, '2020-01-01');
        
        INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo)
        VALUES ('Maria', 'Gomez', '1992-01-01', usu_id) RETURNING via_codigo INTO via_id;
        INSERT INTO via_edo (fk_via_codigo, fk_edo_codigo, via_edo_fecha_inicio) VALUES (via_id, 2, '2020-01-01');

        -- Cliente 2
        INSERT INTO usuario (usu_nombre_usuario, usu_contrasena, usu_email, fk_rol_codigo, fk_lugar)
        VALUES ('cliente_' || estado_counter || '_2', 'pass', 'c' || estado_counter || '2@mail.com', 3, municipio_base + (estado_counter - 1) * 2 + 1)
        RETURNING usu_codigo INTO usu_id;

        -- Viajeros para Cliente 2
        INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo)
        VALUES ('Pedro', 'Lopez', '1985-05-05', usu_id) RETURNING via_codigo INTO via_id;
        INSERT INTO via_edo (fk_via_codigo, fk_edo_codigo, via_edo_fecha_inicio) VALUES (via_id, 1, '2020-01-01');
        
        INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo)
        VALUES ('Ana', 'Diaz', '1988-08-08', usu_id) RETURNING via_codigo INTO via_id;
        INSERT INTO via_edo (fk_via_codigo, fk_edo_codigo, via_edo_fecha_inicio) VALUES (via_id, 2, '2020-01-01');
    END LOOP;
END $$;

-- =====================================================
-- 15. DOCUMENTOS (10 registros)
-- =====================================================
INSERT INTO documento (doc_fecha_emision, doc_fecha_vencimiento, doc_numero_documento, doc_tipo, fk_nac_codigo, fk_via_codigo) VALUES
('2020-01-15', '2030-01-15', 'V12345678', 'Cedula', 1, 1), ('2019-06-20', '2029-06-20', 'P87654321', 'Pasaporte', 1, 2),
('2021-03-10', '2031-03-10', 'V23456789', 'Cedula', 1, 3), ('2020-09-25', '2030-09-25', 'V34567890', 'Cedula', 1, 4),
('2018-12-05', '2028-12-05', 'P11223344', 'Pasaporte', 2, 5), ('2022-02-14', '2032-02-14', 'V45678901', 'Cedula', 1, 6),
('2019-11-30', '2024-11-30', 'VISA001', 'Visa', 3, 7), ('2021-07-18', '2031-07-18', 'V56789012', 'Cedula', 1, 8),
('2020-04-22', '2030-04-22', 'P55667788', 'Pasaporte', 1, 9), ('2022-08-09', '2032-08-09', 'V67890123', 'Cedula', 1, 10);

-- =====================================================
-- 16. PROMOCIONES (10 registros)
-- =====================================================
INSERT INTO promocion (prom_nombre, prom_descripcion, prom_fecha_hora_vencimiento, prom_descuento) VALUES
('Black Friday', 'Desc especial', '2025-11-30 23:59:59', 25.00), ('Cyber Monday', 'Ofertas online', '2025-12-02 23:59:59', 20.00),
('Verano 2025', 'Temporada', '2025-08-31 23:59:59', 15.00), ('Semana Santa', 'Vacaciones', '2025-04-20 23:59:59', 18.00),
('Carnaval', 'Fiesta', '2025-03-05 23:59:59', 12.00), ('Navidad', 'Fin de año', '2025-12-25 23:59:59', 30.00),
('Aniversario', 'Especial', '2025-09-15 23:59:59', 22.00), ('Early Bird', 'Anticipada', '2025-06-30 23:59:59', 10.00),
('Last Minute', 'Ultima hora', '2025-05-15 23:59:59', 35.00), ('Paquete Familiar', 'Familia', '2025-12-31 23:59:59', 20.00);

-- =====================================================
-- 17. HABITACIONES (10 registros)
-- =====================================================
INSERT INTO habitacion (hab_capacidad, hab_descripcion, hab_costo_noche, fk_hotel, fk_promocion) VALUES
(2, 'Doble', 80.00, 1, 1), (4, 'Familiar', 150.00, 2, 2), (2, 'Vista Mar', 120.00, 11, 3),
(3, 'Triple', 100.00, 5, NULL), (2, 'Ejecutiva', 90.00, 14, 4), (5, 'Presidencial', 300.00, 1, 5),
(2, 'Economica', 50.00, 17, NULL), (2, 'Balcon', 95.00, 18, 6), (4, 'Cocina', 140.00, 11, 7),
(1, 'Individual', 60.00, 10, NULL);

-- =====================================================
-- 18. TERMINALES (10 registros)
-- =====================================================
INSERT INTO terminal (ter_nombre, fk_lugar, ter_tipo) VALUES
('Aeropuerto Maiquetía', 82, 'Aeropuerto'), ('Aeropuerto La Chinita', 40, 'Aeropuerto'),
('Terminal Oriente', 36, 'Terrestre'), ('Puerto La Guaira', 82, 'Maritimo'),
('Aeropuerto Valencia', 42, 'Aeropuerto'), ('Terminal Nuevo Circo', 36, 'Terrestre'),
('Puerto Cabello', 43, 'Maritimo'), ('Aeropuerto Barcelona', 46, 'Aeropuerto'),
('Terminal La Bandera', 36, 'Terrestre'), ('Aeropuerto Mérida', 54, 'Aeropuerto');

-- =====================================================
-- 19. MEDIOS DE TRANSPORTE (10 registros)
-- =====================================================
INSERT INTO medio_transporte (med_tra_capacidad, med_tra_descripcion, med_tra_tipo, fk_prov_codigo) VALUES
(180, 'Boeing 737', 'Avion', 1), (150, 'Airbus A320', 'Avion', 2), (50, 'Bus ejecutivo', 'Autobus', 27),
(2000, 'Crucero Caribe', 'Barco', 22), (200, 'Boeing 777', 'Avion', 6), (45, 'Van turística', 'Camioneta', 28),
(300, 'Airbus A380', 'Avion', 10), (1500, 'Ferry Los Roques', 'Barco', 23), (4, 'SUV 4x4', 'Camioneta', 29),
(160, 'Embraer 190', 'Avion', 3);

-- =====================================================
-- 20. PUESTOS (10 registros)
-- =====================================================
INSERT INTO puesto (pue_codigo, pue_descripcion, pue_costo_agregado, fk_med_tra_codigo) VALUES
(1, 'Ventana eco', 0.00, 1), (2, 'Pasillo eco', 0.00, 1), (3, 'Ventana ejec', 150.00, 1),
(1, 'Estandar', 0.00, 2), (2, 'Preferencial', 50.00, 2), (1, 'Normal', 0.00, 3),
(1, 'Interior', 0.00, 4), (2, 'Balcon', 200.00, 4), (1, 'Primera', 300.00, 5), (1, 'Van seat', 0.00, 6);

-- =====================================================
-- 21. RUTAS (10 registros)
-- =====================================================
INSERT INTO ruta (rut_costo, rut_millas_otorgadas, rut_tipo, fk_terminal_origen, fk_terminal_destino, fk_prov_codigo) VALUES
(250.00, 500, 'Aerea', 1, 2, 1), (180.00, 350, 'Aerea', 1, 5, 2), (30.00, 50, 'Terrestre', 3, 6, 27),
(400.00, 800, 'Maritima', 4, 7, 22), (220.00, 450, 'Aerea', 5, 8, 6), (25.00, 40, 'Terrestre', 6, 9, 28),
(500.00, 1000, 'Aerea', 1, 10, 10), (150.00, 300, 'Maritima', 7, 4, 23), (40.00, 60, 'Terrestre', 3, 9, 27),
(280.00, 550, 'Aerea', 2, 5, 3);

-- =====================================================
-- 22. TRASLADOS (10 registros)
-- =====================================================
INSERT INTO traslado (tras_fecha_hora_inicio, tras_fecha_hora_fin, tras_Co2_emitido, fk_rut_codigo, fk_med_tra_codigo) VALUES
('2025-06-15 08:00:00', '2025-06-15 09:30:00', 120.50, 1, 1), ('2025-07-20 10:00:00', '2025-07-20 11:15:00', 95.30, 2, 2),
('2025-08-05 14:00:00', '2025-08-05 18:00:00', 45.20, 3, 3), ('2025-09-10 09:00:00', '2025-09-12 18:00:00', 250.75, 4, 4),
('2025-10-01 07:00:00', '2025-10-01 08:45:00', 110.00, 5, 5), ('2025-11-15 16:00:00', '2025-11-15 20:00:00', 35.60, 6, 6),
('2025-12-20 06:00:00', '2025-12-20 18:00:00', 380.90, 7, 7), ('2026-01-10 11:00:00', '2026-01-12 15:00:00', 180.45, 8, 8),
('2026-02-14 13:00:00', '2026-02-14 17:00:00', 40.20, 9, 9), ('2026-03-05 15:00:00', '2026-03-05 16:30:00', 88.75, 10, 10);

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
('Caribe Completo', 1200.00, 1100.00, 5000), ('Aventura Andina', 950.00, 900.00, 4000),
('Relax Playero', 800.00, 750.00, 3500), ('Tour Cultural', 650.00, 600.00, 2800),
('Extremo Venezuela', 1500.00, 1400.00, 6500), ('Familia Feliz', 1800.00, 1700.00, 8000),
('Luna de Miel', 2200.00, 2100.00, 10000), ('Ejecutivo Express', 550.00, 500.00, 2500),
('Eco Turismo', 890.00, 850.00, 3800), ('Gran Tour Nacional', 2500.00, 2400.00, 11000);

-- =====================================================
-- 25. REGLAS DE PAQUETE (10 registros)
-- =====================================================
INSERT INTO regla_paquete (reg_paq_atributo, reg_paq_operador, reg_paq_valor) VALUES
('edad_minima', '>=', '18'), ('edad_maxima', '<=', '65'), ('num_personas', '>=', '2'),
('num_personas', '<=', '6'), ('temporada', '=', 'Verano'), ('experiencia', '=', 'Intermedio'),
('condicion_fisica', '=', 'Buena'), ('certificacion', '=', 'Buceo'),
('peso_max', '<=', '100'), ('altura_min', '>=', '150');

-- =====================================================
-- 26. TABLAS INTERMEDIAS (Llenado base)
-- =====================================================
INSERT INTO ser_prom (fk_ser_codigo, fk_prom_codigo) VALUES (1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),(10,1);
INSERT INTO paq_prom (fk_paq_tur_codigo, fk_prom_codigo) VALUES (1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),(10,10);
INSERT INTO tras_prom (fk_tras_codigo, fk_prom_codigo) VALUES (1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),(10,10);
INSERT INTO paq_ser (fk_paq_tur_codigo, fk_ser_codigo, cantidad) VALUES (1,1,1),(1,2,1),(2,5,1),(3,2,2),(4,3,1),(5,7,1),(6,3,2),(7,2,1),(8,9,1),(9,1,1);
INSERT INTO paq_tras (fk_paq_tur_codigo, fk_tras_codigo) VALUES (1,1),(2,5),(3,4),(4,2),(5,7),(6,1),(7,4),(8,5),(9,9),(10,1);
INSERT INTO reg_paq_paq (fk_reg_paq_codigo, fk_paq_tur_codigo) VALUES (1,5),(2,5),(3,6),(4,6),(5,1),(6,9),(7,9),(8,2),(9,7),(10,5);

-- =====================================================
-- 27. TASAS DE CAMBIO (5 tasas, 5 monedas originales)
-- =====================================================
INSERT INTO tasa_de_cambio (tas_cam_tasa_valor, tas_cam_fecha_hora_inicio, tas_cam_fecha_hora_fin, tas_cam_moneda) VALUES
(295.35, '2025-12-01 00:00:00', NULL, 'BS'), (1.00, '2025-04-01 00:00:00', NULL, 'USD'),
(0.74, '2025-07-01 00:00:00', NULL, 'GBP'), (0.85, '2025-01-01 00:00:00', NULL, 'EUR'),
(156.18, '2025-07-01 00:00:00', NULL, 'YEN');

-- =====================================================
-- 28. TASAS DE MILLAS (5 tasas - CORREGIDO)
-- =====================================================
INSERT INTO tasa_de_cambio (tas_cam_tasa_valor, tas_cam_fecha_hora_inicio, tas_cam_fecha_hora_fin, tas_cam_moneda) VALUES
(0.010, '2025-01-01 00:00:00', '2025-03-30 23:59:59', 'MILLA'),
(0.012, '2025-04-01 00:00:00', '2025-06-30 23:59:59', 'MILLA'),
(0.015, '2025-07-01 00:00:00', '2025-09-30 23:59:59', 'MILLA'),
(0.018, '2025-10-01 00:00:00', '2025-12-31 23:59:59', 'MILLA'),
(0.020, '2026-01-01 00:00:00', NULL, 'MILLA');

-- =====================================================
-- 29. CATEGORÍAS ADICIONALES (Estaba mal ubicado antes)
-- =====================================================
INSERT INTO categoria (cat_nombre, cat_descripcion) VALUES
('Explorador', 'Actividades extremas'), ('Comfort', 'Destinos costeros'),
('Corporativo', 'Sitios históricos'), ('Familiar', 'Experiencias culinarias'),
('Practico', 'Ecoturismo'), ('Deportes', 'Actividades deportivas'),
('Negocios', 'Viajes corporativos'), ('Romance', 'Parejas y luna de miel'),
('Juvenil', 'Viajes estudiantes'), ('Senior', 'Tercera edad');

-- =====================================================
-- 30. MÉTODOS DE PAGO (10 registros)
-- =====================================================
INSERT INTO tipo_metodo_pago (tip_met_nombre) VALUES
('Tarjeta de Crédito'), ('Tarjeta de Débito'), ('Pago Móvil'), ('Transferencia Bancaria'),
('Efectivo'), ('Zelle'), ('Cheque'), ('Depósito Bancario'), ('Criptomoneda'), ('Millas');

INSERT INTO metodo_pago (met_pag_descripcion, fk_tipo_metodo) VALUES
('TDC Genérica', 1), ('TDD Genérica', 2), ('PagoMovil Std', 3), ('Transf Std', 4),
('Cash USD', 5), ('Zelle Std', 6), ('Cheque Gerencia', 7), ('Depósito', 8),
('BTC', 9), ('Millas Club', 10);

INSERT INTO tarjeta_credito (met_pago_codigo, tar_cre_numero, tar_cre_cvv, tar_cre_fecha_vencimiento, tar_cre_banco_emisor, tar_cre_nombre_titular) 
VALUES (1, '4111222233334444', '123', '2028-12-31', 'Banco Central', 'Usuario Genérico');

-- =====================================================
-- 31. COMPRAS, DETALLES Y PAGOS (CORREGIDO: Fechas y Habitaciones Dinámicas)
-- =====================================================
DO $$
DECLARE
    cliente_id INTEGER;
    compra_id INTEGER;
    servicio_vuelo INTEGER;
    servicio_otro INTEGER;
    monto_vuelo NUMERIC(10,2);
    monto_otro NUMERIC(10,2);
    total_compra NUMERIC(10,2);
    
    -- Variables para evitar el error de llave duplicada
    fecha_viaje DATE;
    fecha_reserva_inicio TIMESTAMP;
    fecha_reserva_fin TIMESTAMP;
    habitacion_id INTEGER;
BEGIN
    -- Iterar por los 48 clientes (IDs 97 al 144)
    FOR i IN 0..47 LOOP
        cliente_id := 97 + i;
        
        -- FECHA DINÁMICA: Cada cliente viaja en un día distinto para evitar choques
        -- Cliente 1 viaja el 1 de junio, Cliente 2 el 2 de junio, etc.
        fecha_viaje := '2025-06-01'::DATE + (i || ' days')::INTERVAL;
        
        -- Asignar Servicios
        servicio_vuelo := 2; 
        IF (i % 2 = 0) THEN servicio_vuelo := 7; END IF;
        
        servicio_otro := (i % 5) + 1; 
        IF servicio_otro = 2 THEN servicio_otro := 9; END IF; 
        
        monto_vuelo := 150.00;
        monto_otro := 100.00;
        total_compra := monto_vuelo + monto_otro;

        -- 1. Insertar Compra
        INSERT INTO compra (com_monto_total, com_monto_subtotal, com_fecha, fk_usuario, fk_plan_financiamiento)
        VALUES (total_compra, total_compra * 0.90, fecha_viaje, cliente_id, NULL)
        RETURNING com_codigo INTO compra_id;

        -- 2. Insertar Detalle 1 (Vuelo)
        INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado)
        SELECT 1, fecha_viaje, '10:00:00', monto_vuelo, monto_vuelo*0.9, via_codigo, 1, compra_id, servicio_vuelo, 'Confirmada'
        FROM viajero WHERE fk_usu_codigo = cliente_id ORDER BY via_codigo ASC LIMIT 1;

        -- 3. Insertar Detalle 2 (Otro Servicio)
        INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado)
        SELECT 2, fecha_viaje, '10:05:00', monto_otro, monto_otro*0.9, via_codigo, 2, compra_id, servicio_otro, 'Confirmada'
        FROM viajero WHERE fk_usu_codigo = cliente_id ORDER BY via_codigo DESC LIMIT 1;

        -- 4. Insertar Pago
        INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago)
        VALUES (total_compra, fecha_viaje + '10:30:00'::TIME, 'USD', compra_id, 3, (i % 10) + 1);

        -- 5. Insertar Reserva de Habitación (CORRECCIÓN)
        -- Si servicio_otro es 1 (Hotel Std) o 9 (Hotel Suite), creamos la reserva
        IF servicio_otro IN (1, 9) THEN
            -- Calculamos fechas basadas en la fecha de viaje del cliente actual
            fecha_reserva_inicio := fecha_viaje + '14:00:00'::TIME;
            fecha_reserva_fin := fecha_viaje + '2 days'::INTERVAL + '12:00:00'::TIME;
            
            -- Rotamos la habitación entre la 1 y la 10 para variar
            habitacion_id := (i % 10) + 1; 

            INSERT INTO reserva_de_habitacion (res_hab_fecha_hora_inicio, res_hab_fecha_hora_fin, res_hab_costo_unitario, fk_habitacion, fk_detalle_reserva, fk_detalle_reserva_2, fk_paquete_turistico)
            VALUES (fecha_reserva_inicio, fecha_reserva_fin, 80.00, habitacion_id, compra_id, 2, NULL);
        END IF;
        
    END LOOP;
END $$;

-- =====================================================
-- 32. MILLAS GENERADAS (10 registros)
-- =====================================================
INSERT INTO milla (mil_valor_obtenido, mil_fecha_inicio, mil_fecha_fin, mil_valor_restado, fk_compra, fk_pago) VALUES
(500, '2025-06-01', '2026-06-01', 0, 1, NULL), (200, '2025-07-10', '2026-07-10', 0, 2, NULL),
(1000, '2025-08-05', '2026-08-05', 0, 3, NULL), (450, '2025-09-12', '2026-09-12', 0, 4, NULL),
(500, '2025-10-20', '2026-10-20', 0, 5, NULL), (100, '2025-11-05', '2026-11-05', 0, 6, NULL),
(800, '2025-11-20', '2026-11-20', 0, 7, NULL), (600, '2025-12-01', '2026-12-01', 0, 8, NULL),
(250, '2025-12-15', '2026-12-15', 0, 9, NULL), (400, '2026-01-10', '2027-01-10', 0, 10, NULL);

-- =====================================================
-- 33. ESTADOS (10 registros)
-- =====================================================
INSERT INTO estado (est_nombre, est_descripcion) VALUES
('Pendiente', 'Reserva en espera'), ('Confirmado', 'Reserva OK'), ('En Proceso', 'Ejecutando'),
('Completado', 'Finalizado'), ('Cancelado', 'Anulado'), ('Reembolsado', 'Devuelto'),
('Vencido', 'Expirado'), ('Pagado', 'Cobrado'), ('Pendiente Pago', 'Espera pago'), ('En Espera', 'Temporal');

-- =====================================================
-- 34. ACCIONES (10 registros)
-- =====================================================
INSERT INTO accion (acc_nombre, acc_descripcion) VALUES
('Crear', 'Nuevo registro'), ('Actualizar', 'Modificar'), ('Eliminar', 'Borrar'),
('Consultar', 'Leer'), ('Login', 'Entrar'), ('Logout', 'Salir'),
('Reservar', 'Hacer reserva'), ('Cancelar', 'Anular'), ('Pagar', 'Procesar pago'), ('Reembolsar', 'Devolver');

-- =====================================================
-- 35. RECURSOS (10 registros)
-- =====================================================
INSERT INTO recurso (recu_nombre_tabla, recu_descripcion) VALUES
('usuario', 'Usuarios'), ('compra', 'Compras'), ('detalle_reserva', 'Detalles'),
('pago', 'Pagos'), ('proveedor', 'Proveedores'), ('servicio', 'Servicios'),
('traslado', 'Traslados'), ('hotel', 'Hoteles'), ('viajero', 'Viajeros'), ('paquete_turistico', 'Paquetes');

-- =====================================================
-- 36. PREFERENCIAS (10 registros)
-- =====================================================
INSERT INTO preferencia (fk_usuario, fk_categoria) VALUES
(97, 1), (97, 2), (98, 3), (98, 4), (99, 5), (100, 1), (101, 7), (102, 8), (103, 9), (104, 10);

-- =====================================================
-- 37. LISTA DE DESEOS (10 registros)
-- =====================================================
INSERT INTO lista_deseos (fk_usuario, fk_paquete_turistico, fk_servicio, fk_traslado) VALUES
(97, 1, 1, 1), (98, 2, 2, 2), (99, 3, 3, 3), (100, 4, 4, 4), (101, 5, 5, 5),
(102, 6, 6, 6), (103, 7, 7, 7), (104, 8, 8, 8), (105, 9, 9, 9), (106, 10, 10, 10);

-- =====================================================
-- 38. RESEÑAS (10 registros)
-- =====================================================
INSERT INTO resena (res_calificacion_numerica, res_descripcion, res_fecha_hota_creacion, fk_detalle_reserva, fk_detalle_reserva_2) VALUES
(5, 'Excelente servicio', '2025-06-20 10:00:00', 1, 1), (4, 'Muy buena experiencia', '2025-07-25 11:00:00', 1, 2),
(5, 'Recomendado', '2025-08-20 12:00:00', 2, 1), (3, 'Aceptable', '2025-09-20 13:00:00', 2, 2),
(4, 'Buen servicio', '2025-10-30 14:00:00', 3, 1), (5, 'Perfecto', '2025-11-10 15:00:00', 3, 2),
(4, 'Muy satisfecho', '2025-11-25 16:00:00', 4, 1), (5, 'Increíble', '2025-12-20 17:00:00', 4, 2),
(4, 'Recomendable', '2025-12-25 18:00:00', 5, 1), (5, 'Excelente', '2026-01-25 19:00:00', 5, 2);

-- =====================================================
-- 39. RECLAMOS (10 registros)
-- =====================================================
INSERT INTO reclamo (rec_contenido, rec_fecha_hora, fk_detalle_reserva, fk_detalle_reserva_2) VALUES
('Retraso', '2025-06-16 10:00:00', 1, 1), ('Habitación sucia', '2025-07-21 11:00:00', 1, 2),
('Servicio no prestado', '2025-08-16 12:00:00', 2, 1), ('Comida fría', '2025-09-16 13:00:00', 2, 2),
('Guía no llegó', '2025-10-26 14:00:00', 3, 1), ('Mal bus', '2025-11-06 15:00:00', 3, 2),
('Ruido', '2025-11-21 16:00:00', 4, 1), ('Cancelado', '2025-12-16 17:00:00', 4, 2),
('Sin mesa', '2025-12-21 18:00:00', 5, 1), ('Incompleto', '2026-01-21 19:00:00', 5, 2);

-- =====================================================
-- 40. COMPENSACIONES (10 registros)
-- =====================================================
INSERT INTO compensacion (com_co2_compensado, com_monto_agregado, fk_compra) VALUES
(120.50, 10.00, 1), (95.30, 8.00, 2), (250.75, 20.00, 3), (110.00, 9.00, 4), (45.20, 4.00, 5),
(380.90, 30.00, 6), (180.45, 15.00, 7), (88.75, 7.00, 8), (150.00, 12.00, 9), (200.00, 16.00, 10);


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

-- Registramos los canjes