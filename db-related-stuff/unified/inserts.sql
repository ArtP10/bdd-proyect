\-- Insertamos un lugar dummy (ej. Venezuela) para asignarselo al admin
INSERT INTO lugar (lug_nombre, lug_tipo, fk_lugar) 
VALUES ('Venezuela', 'Pais', NULL); 
-- Asumiremos que este insert genera el ID 1.

s
-- 2. Inserts para tabla de roles
INSERT INTO estado_civil (edo_civ_nombre, edo_civ_descripcion) VALUES 
('Soltero/a', 'Persona que nunca ha contraído matrimonio'),
('Casado/a', 'Persona unida en matrimonio'),
('Divorciado/a', 'Persona que ha disuelto su vínculo matrimonial'),
('Viudo/a', 'Persona cuyo cónyuge ha fallecido');

INSERT INTO rol(rol_nombre, rol_descripcion) VALUES 
('Administrador', 'Administrador del sistema ViajesUcab.'),
('Proveedor', 'Responsable de proveedor de servicios'),
('Cliente', 'Consumidor/Comprador de servicios');


-- 3. Insert para Usuario (CORREGIDO: Agregado fk_lugar)
INSERT INTO usuario(usu_nombre_usuario, usu_contrasena, usu_email, fk_rol_codigo, fk_lugar)
VALUES('artadmin', '1234', '10arturojpinto@gmail.com', 1, 1); -- Asumiendo Lugar ID 1 y Rol ID 1


-- 4. Insert para Privilegios (CORREGIDO: Eliminados duplicados)
INSERT INTO privilegio(pri_nombre, pri_descripcion) VALUES
-- Privilegios de Admin
('crear_usuarios', 'creacion de proveedores y clientes'),
('eliminar_usuarios', 'eliminacion de proveedores y clientes'),
('leer_usuarios', 'ver informacion sobre usuarios distintos a uno'),
('manipulacion_de_roles', 'creacion, eliminacion, lectura y actualizacion de roles y privilegios'),
-- Privilegios de Gestión de Recursos (Compartidos Admin/Proveedor)
('crear_recursos','creacion de viajes, rutas, servicios, paquetes, etc.'),
('modificar_recursos', 'modificacion de viajes, rutas, servicios, paquetes, etc'),
('eliminar_recursos', 'eliminacion de viajes, rutas, servicios, paquetes, etc.'),
-- Privilegios de Cliente
('reservar_y_comprar', 'reserva y compra de servicios'),
('manipular_viajeros', 'creacion, eliminacion, lectura y modificacion de viajeros');
-- Nota: Eliminé las repeticiones de crear/modificar/eliminar recursos del final


-- 5. Asignacion de privilegios (CORREGIDO: Sintaxis unificada)
-- IMPORTANTE: Esto asume que los IDs se generaron secuencialmente del 1 al 9 en el paso anterior.
INSERT INTO rol_privilegio(fk_pri_codigo, fk_rol_codigo) VALUES
-- Admin (Rol 1) tiene:
(1,1), -- crear_usuarios
(2,1), -- eliminar_usuarios
(3,1), -- leer_usuarios
(4,1), -- manipulacion_de_roles
(5,1), -- crear_recursos
(6,1), -- modificar_recursos
(7,1), -- eliminar_recursos

-- Cliente (Rol 3) tiene:
(8,3), -- reservar_y_comprar
(9,3), -- manipular_viajeros

-- Proveedor (Rol 2) tiene:
(5,2), -- crear_recursos (Reutilizamos el ID 5)
(6,2), -- modificar_recursos (Reutilizamos el ID 6)
(7,2); -- eliminar_recursos (Reutilizamos el ID 7)


-- 6. Nacionalidades
INSERT INTO nacionalidad (nac_nombre, nac_descripcion) VALUES
-- Latinas
('Venezolano', 'Ciudadano de Venezuela'),
('Colombiano', 'Ciudadano de Colombia'),
('Argentino', 'Ciudadano de Argentina'),
('Mexicano', 'Ciudadano de México'),
('Chileno', 'Ciudadano de Chile'),
-- Europeas
('Español', 'Ciudadano de España'),
('Italiano', 'Ciudadano de Italia'),
('Francés', 'Ciudadano de Francia'),
('Alemán', 'Ciudadano de Alemania'),
('Portugués', 'Ciudadano de Portugal');

-- INSERTS POR MELANIE

-- 20 Aerolíneas
INSERT INTO proveedor (prov_nombre, prov_fecha_creacion, prov_tipo, fk_lugar, fk_usu_codigo) VALUES
('Avior Airlines', CURRENT_DATE - 3650, 'Aerolínea', 6, 1), ('Laser Airlines', CURRENT_DATE - 5000, 'Aerolínea', 6, 1),
('Conviasa', CURRENT_DATE - 7000, 'Aerolínea', 6, 1), ('Rutaca', CURRENT_DATE - 2000, 'Aerolínea', 6, 1),
('Turpial Airlines', CURRENT_DATE - 1500, 'Aerolínea', 6, 1), ('Estelar', CURRENT_DATE - 2500, 'Aerolínea', 6, 1),
('Venezolana', CURRENT_DATE - 4000, 'Aerolínea', 6, 1), ('American Airlines', CURRENT_DATE - 15000, 'Aerolínea', 1, 1),
('United Airlines', CURRENT_DATE - 14000, 'Aerolínea', 1, 1), ('Delta', CURRENT_DATE - 13000, 'Aerolínea', 1, 1),
('Iberia', CURRENT_DATE - 16000, 'Aerolínea', 2, 1), ('Air Europa', CURRENT_DATE - 8000, 'Aerolínea', 2, 1),
('Air France', CURRENT_DATE - 17000, 'Aerolínea', 2, 1), ('Lufthansa', CURRENT_DATE - 17500, 'Aerolínea', 2, 1),
('Air China', CURRENT_DATE - 9000, 'Aerolínea', 3, 1), ('Japan Airlines', CURRENT_DATE - 10000, 'Aerolínea', 3, 1),
('EgyptAir', CURRENT_DATE - 11000, 'Aerolínea', 4, 1), ('Qantas', CURRENT_DATE - 12000, 'Aerolínea', 5, 1),
('Copa Airlines', CURRENT_DATE - 6000, 'Aerolínea', 6, 1), ('Latam', CURRENT_DATE - 7500, 'Aerolínea', 6, 1);

-- 5 Cruceros
INSERT INTO proveedor (prov_nombre, prov_fecha_creacion, prov_tipo, fk_lugar, fk_usu_codigo) VALUES
('Royal Caribbean', CURRENT_DATE - 10000, 'Maritimo', 1, 1),
('MSC Cruceros', CURRENT_DATE - 8000, 'Maritimo', 2, 1),
('Norwegian Cruise', CURRENT_DATE - 6000, 'Maritimo', 1, 1),
('Carnival', CURRENT_DATE - 9000, 'Maritimo', 1, 1),
('Disney Cruise Line', CURRENT_DATE - 5000, 'Maritimo', 1, 1);

-- 20 Alquiler de Vehículos
INSERT INTO proveedor (prov_nombre, prov_fecha_creacion, prov_tipo, fk_lugar, fk_usu_codigo) VALUES
('Hertz', CURRENT_DATE - 5000, 'Terrestre', 1, 1), ('Avis', CURRENT_DATE - 5000, 'Terrestre', 1, 1),
('Budget', CURRENT_DATE - 4000, 'Terrestre', 1, 1), ('Europcar', CURRENT_DATE - 3500, 'Terrestre', 2, 1),
('Sixt', CURRENT_DATE - 7000, 'Terrestre', 2, 1), ('Alamo', CURRENT_DATE - 3000, 'Terrestre', 1, 1),
('National', CURRENT_DATE - 6000, 'Terrestre', 1, 1), ('Dollar', CURRENT_DATE - 4500, 'Terrestre', 1, 1),
('Thrifty', CURRENT_DATE - 4000, 'Terrestre', 1, 1), ('Enterprise', CURRENT_DATE - 3000, 'Terrestre', 1, 1),
('Localiza', CURRENT_DATE - 2000, 'Terrestre', 6, 1), ('Unirent', CURRENT_DATE - 1000, 'Terrestre', 6, 1),
('Amigos Car Rental', CURRENT_DATE - 1500, 'Terrestre', 6, 1), ('Rent A Car Vzla', CURRENT_DATE - 1200, 'Terrestre', 6, 1),
('AutoEurope', CURRENT_DATE - 4000, 'Terrestre', 2, 1), ('Goldcar', CURRENT_DATE - 2500, 'Terrestre', 2, 1),
('Centauro', CURRENT_DATE - 5000, 'Terrestre', 2, 1), ('Firefly', CURRENT_DATE - 1500, 'Terrestre', 1, 1),
('Ace Rent A Car', CURRENT_DATE - 1200, 'Terrestre', 1, 1), ('Fox Rent A Car', CURRENT_DATE - 2000, 'Terrestre', 1, 1);

-- 20 Servicios Turísticos (Tipo: Otros)
INSERT INTO proveedor (prov_nombre, prov_fecha_creacion, prov_tipo, fk_lugar, fk_usu_codigo) VALUES
('Turismo Maso', CURRENT_DATE - 8000, 'Otros', 6, 1), ('Viajes Humboldt', CURRENT_DATE - 9000, 'Otros', 6, 1),
('Quo Vadis', CURRENT_DATE - 7000, 'Otros', 6, 1), ('Italcambio Viajes', CURRENT_DATE - 12000, 'Otros', 6, 1),
('Top Cruises', CURRENT_DATE - 5000, 'Otros', 6, 1), ('Bestravel', CURRENT_DATE - 3500, 'Otros', 6, 1),
('Tours & Trips', CURRENT_DATE - 1500, 'Otros', 1, 1), ('Expedia Services', CURRENT_DATE - 6000, 'Otros', 1, 1),
('Booking Tours', CURRENT_DATE - 4000, 'Otros', 2, 1), ('Civitatis', CURRENT_DATE - 3000, 'Otros', 2, 1),
('Viator', CURRENT_DATE - 3500, 'Otros', 1, 1), ('GetYourGuide', CURRENT_DATE - 2500, 'Otros', 2, 1),
('Despegar Servicios', CURRENT_DATE - 5000, 'Otros', 6, 1), ('Klook', CURRENT_DATE - 2000, 'Otros', 3, 1),
('TripAdvisor Tours', CURRENT_DATE - 4500, 'Otros', 1, 1), ('Airbnb Experiences', CURRENT_DATE - 3000, 'Otros', 1, 1),
('Canaima Tours', CURRENT_DATE - 7000, 'Otros', 6, 1), ('Mochima Diver', CURRENT_DATE - 4000, 'Otros', 6, 1),
('Roraima Trek', CURRENT_DATE - 5000, 'Otros', 6, 1), ('Los Roques Paradise', CURRENT_DATE - 6000, 'Otros', 6, 1);

-- 20 Hoteles
INSERT INTO hotel (hot_nombre, hot_descripcion, hot_valoracion, hot_anos_servicio, fk_lugar) VALUES
('Hotel Eurobuilding', '5 estrellas en Caracas', 4.8, 20, 8),
('Hotel Tamanaco', 'Clásico de Caracas', 4.5, 50, 8),
('Hesperia Valencia', 'Lujo en Carabobo', 4.6, 15, 10),
('Lidotel Barquisimeto', 'Confort en Lara', 4.7, 10, 11),
('Hotel Tibisay', 'Vista al lago', 4.9, 8, 9),
('Posada Galipan', 'Montaña y relax', 4.8, 12, 7),
('Hotel Marriot', 'Playa Grande', 4.7, 15, 7),
('Wyndham Concorde', 'Isla de Margarita', 4.6, 25, 14),
('Ikin Margarita', 'Lujo exclusivo', 4.9, 10, 14),
('Hotel Venetur', 'Mérida centro', 4.2, 30, 15),
('Belensate', 'Tradición andina', 4.5, 40, 15),
('Hotel Castillo', 'San Cristóbal', 4.3, 20, 16),
('Pestana Caracas', 'Moderno y chic', 4.6, 10, 8),
('Cayena Caracas', 'Boutique hotel', 4.9, 5, 8),
('Hotel Plaza', 'New York', 4.8, 100, 1),
('Ritz Paris', 'Lujo en Francia', 5.0, 120, 2),
('Burj Al Arab', 'Dubai', 5.0, 20, 4),
('Marina Bay Sands', 'Singapur', 4.9, 10, 3),
('Hotel Humboldt', 'Ávila Mágica', 4.7, 60, 8),
('Posada Los Roques', 'Paraíso azul', 4.8, 15, 7);

-- 10 Parques (Insertados como Lugares con tipo 'Ciudad' para pasar el check, o Proveedores si prefieres)
-- Asumiendo que quieres guardar la data, los pondré en PROVEEDOR tipo 'Otros' que gestionan parques
INSERT INTO proveedor (prov_nombre, prov_fecha_creacion, prov_tipo, fk_lugar, fk_usu_codigo) VALUES
('Inparques Ávila', CURRENT_DATE - 15000, 'Otros', 8, 1),
('Parque Canaima', CURRENT_DATE - 20000, 'Otros', 13, 1),
('Parque Mochima', CURRENT_DATE - 15000, 'Otros', 12, 1),
('Parque Morrocoy', CURRENT_DATE - 14000, 'Otros', 10, 1),
('Parque Los Roques', CURRENT_DATE - 12000, 'Otros', 7, 1),
('Parque Sierra Nevada', CURRENT_DATE - 18000, 'Otros', 15, 1),
('Parque Médanos de Coro', CURRENT_DATE - 16000, 'Otros', 10, 1),
('Parque Yellowstone', CURRENT_DATE - 30000, 'Otros', 1, 1),
('Parque El Retiro', CURRENT_DATE - 40000, 'Otros', 2, 1),
('Central Park Admin', CURRENT_DATE - 50000, 'Otros', 1, 1);

-- Usuarios del Estado Miranda (ID 7 aprox)
INSERT INTO usuario (usu_contrasena, usu_nombre_usuario, fk_rol_codigo, usu_email, fk_lugar) VALUES 
('1234', 'cliente_miranda_1', 1, 'miranda1@email.com', (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Miranda')),
('1234', 'cliente_miranda_2', 1, 'miranda2@email.com', (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Miranda'));

-- Usuarios del Distrito Capital (ID 8 aprox)
INSERT INTO usuario (usu_contrasena, usu_nombre_usuario, fk_rol_codigo, usu_email, fk_lugar) VALUES 
('1234', 'cliente_ccs_1', 1, 'ccs1@email.com', (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Distrito Capital')),
('1234', 'cliente_ccs_2', 1, 'ccs2@email.com', (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Distrito Capital'));

-- Usuarios del Zulia (ID 9 aprox)
INSERT INTO usuario (usu_contrasena, usu_nombre_usuario, fk_rol_codigo, usu_email, fk_lugar) VALUES 
('1234', 'cliente_zulia_1', 1, 'zulia1@email.com', (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Zulia')),
('1234', 'cliente_zulia_2', 1, 'zulia2@email.com', (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Zulia'));

-- Usuarios de Carabobo (ID 10 aprox)
INSERT INTO usuario (usu_contrasena, usu_nombre_usuario, fk_rol_codigo, usu_email, fk_lugar) VALUES 
('1234', 'cliente_carabobo_1', 1, 'carabobo1@email.com', (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Carabobo')),
('1234', 'cliente_carabobo_2', 1, 'carabobo2@email.com', (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Carabobo'));

-- Usuarios de Lara (ID 11 aprox)
INSERT INTO usuario (usu_contrasena, usu_nombre_usuario, fk_rol_codigo, usu_email, fk_lugar) VALUES 
('1234', 'cliente_lara_1', 1, 'lara1@email.com', (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Lara')),
('1234', 'cliente_lara_2', 1, 'lara2@email.com', (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Lara'));

-- Usuarios de Anzoátegui (ID 12 aprox)
INSERT INTO usuario (usu_contrasena, usu_nombre_usuario, fk_rol_codigo, usu_email, fk_lugar) VALUES 
('1234', 'cliente_anzo_1', 1, 'anzo1@email.com', (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Anzoategui')),
('1234', 'cliente_anzo_2', 1, 'anzo2@email.com', (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Anzoategui'));

-- Usuarios de Bolívar (ID 13 aprox)
INSERT INTO usuario (usu_contrasena, usu_nombre_usuario, fk_rol_codigo, usu_email, fk_lugar) VALUES 
('1234', 'cliente_bolivar_1', 1, 'bolivar1@email.com', (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Bolivar')),
('1234', 'cliente_bolivar_2', 1, 'bolivar2@email.com', (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Bolivar'));

-- Usuarios de Nueva Esparta (ID 14 aprox)
INSERT INTO usuario (usu_contrasena, usu_nombre_usuario, fk_rol_codigo, usu_email, fk_lugar) VALUES 
('1234', 'cliente_margarita_1', 1, 'margarita1@email.com', (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Nueva Esparta')),
('1234', 'cliente_margarita_2', 1, 'margarita2@email.com', (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Nueva Esparta'));

-- Usuarios de Mérida (ID 15 aprox)
INSERT INTO usuario (usu_contrasena, usu_nombre_usuario, fk_rol_codigo, usu_email, fk_lugar) VALUES 
('1234', 'cliente_merida_1', 1, 'merida1@email.com', (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Merida')),
('1234', 'cliente_merida_2', 1, 'merida2@email.com', (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Merida'));

-- Usuarios de Táchira (ID 16 aprox)
INSERT INTO usuario (usu_contrasena, usu_nombre_usuario, fk_rol_codigo, usu_email, fk_lugar) VALUES 
('1234', 'cliente_tachira_1', 1, 'tachira1@email.com', (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Tachira')),
('1234', 'cliente_tachira_2', 1, 'tachira2@email.com', (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Tachira'));

-- Viajeros para Cliente Miranda 1
INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
('Juan', 'Perez', '1990-05-20', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_miranda_1')),
('Maria', 'Perez', '1992-08-15', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_miranda_1'));

-- Viajeros para Cliente Miranda 2
INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
('Carlos', 'Gomez', '1985-03-10', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_miranda_2')),
('Ana', 'Gomez', '1988-11-25', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_miranda_2'));

-- Viajeros para Cliente Caracas 1
INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
('Luis', 'Rodriguez', '1995-01-30', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_ccs_1')),
('Sofia', 'Rodriguez', '1996-06-12', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_ccs_1'));

-- Viajeros para Cliente Caracas 2
INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
('Pedro', 'Fernandez', '1980-09-05', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_ccs_2')),
('Laura', 'Fernandez', '1982-04-18', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_ccs_2'));

-- Viajeros para Cliente Zulia 1
INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
('Jose', 'Martinez', '1993-07-22', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_zulia_1')),
('Elena', 'Martinez', '1994-12-01', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_zulia_1'));

-- Viajeros para Cliente Zulia 2
INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
('Miguel', 'Lopez', '1989-02-14', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_zulia_2')),
('Carmen', 'Lopez', '1991-10-30', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_zulia_2'));

-- Viajeros para Cliente Carabobo 1
INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
('David', 'Garcia', '1998-05-05', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_carabobo_1')),
('Lucia', 'Garcia', '1999-09-09', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_carabobo_1'));

-- Viajeros para Cliente Carabobo 2
INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
('Jorge', 'Sanchez', '1983-11-11', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_carabobo_2')),
('Patricia', 'Sanchez', '1986-06-06', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_carabobo_2'));

-- Viajeros para Cliente Lara 1
INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
('Raul', 'Hernandez', '1990-01-01', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_lara_1')),
('Marta', 'Hernandez', '1992-02-02', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_lara_1'));

-- Viajeros para Cliente Lara 2
INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
('Andres', 'Diaz', '1987-03-03', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_lara_2')),
('Isabel', 'Diaz', '1989-04-04', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_lara_2'));

-- Viajeros para Cliente Anzoategui 1
INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
('Fernando', 'Torres', '1995-07-07', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_anzo_1')),
('Gabriela', 'Torres', '1996-08-08', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_anzo_1'));

-- Viajeros para Cliente Anzoategui 2
INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
('Ricardo', 'Ramirez', '1981-12-12', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_anzo_2')),
('Daniela', 'Ramirez', '1984-10-10', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_anzo_2'));

-- Viajeros para Cliente Bolivar 1
INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
('Manuel', 'Flores', '1993-01-15', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_bolivar_1')),
('Rosa', 'Flores', '1994-06-20', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_bolivar_1'));

-- Viajeros para Cliente Bolivar 2
INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
('Alberto', 'Castillo', '1988-09-25', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_bolivar_2')),
('Teresa', 'Castillo', '1990-03-30', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_bolivar_2'));

-- Viajeros para Cliente Margarita 1
INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
('Eduardo', 'Rojas', '1997-05-10', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_margarita_1')),
('Clara', 'Rojas', '1998-11-05', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_margarita_1'));

-- Viajeros para Cliente Margarita 2
INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
('Hector', 'Vargas', '1982-08-18', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_margarita_2')),
('Adriana', 'Vargas', '1985-02-22', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_margarita_2'));

-- Viajeros para Cliente Merida 1
INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
('Oscar', 'Mendoza', '1991-04-12', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_merida_1')),
('Julia', 'Mendoza', '1993-09-08', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_merida_1'));

-- Viajeros para Cliente Merida 2
INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
('Roberto', 'Silva', '1986-12-25', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_merida_2')),
('Monica', 'Silva', '1989-07-14', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_merida_2'));

-- Viajeros para Cliente Tachira 1
INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
('Victor', 'Delgado', '1994-03-28', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_tachira_1')),
('Sara', 'Delgado', '1996-10-15', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_tachira_1'));

-- Viajeros para Cliente Tachira 2
INSERT INTO viajero (via_prim_nombre, via_prim_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
('Francisco', 'Ortiz', '1984-01-20', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_tachira_2')),
('Beatriz', 'Ortiz', '1987-05-30', (SELECT usu_codigo FROM usuario WHERE usu_nombre_usuario = 'cliente_tachira_2'));

-- Tasas de Cambio
INSERT INTO tasa_de_cambio (tas_cam_tasa_valor, tas_cam_fecha_hora_inicio, tas_cam_moneda) VALUES
(38.5, CURRENT_TIMESTAMP, 'Bolívar'),
(1.0, CURRENT_TIMESTAMP, 'Dólar'),
(0.92, CURRENT_TIMESTAMP, 'Euro'),
(39.0, CURRENT_TIMESTAMP - INTERVAL '1 day', 'Bolívar'), -- Historico
(0.93, CURRENT_TIMESTAMP - INTERVAL '1 day', 'Euro');    -- Historico

-- No tienes una tabla explicita de "Configuracion Millas", pero el PDF dice "5 tasas".
-- Asumo que va en alguna tabla de configuración o es data histórica en `milla`.
-- Insertaré ejemplos en la tabla `milla` simulando valores históricos.
INSERT INTO milla (mil_valor_obtenido, mil_fecha_inicio, fk_compra, fk_pago) VALUES -- Ajustar FKs cuando existan compras
(100, CURRENT_DATE, 1, 1), (200, CURRENT_DATE, 1, 1), (300, CURRENT_DATE, 1, 1), (400, CURRENT_DATE, 1, 1), (500, CURRENT_DATE, 1, 1);

-- Medios de Transporte
INSERT INTO medio_transporte (med_tra_capacidad, med_tra_descripcion, med_tra_tipo, fk_prov_codigo) VALUES
(150, 'Boeing 737', 'Avion', 1), (200, 'Airbus A320', 'Avion', 2),
(50, 'Bus Ejecutivo', 'Bus', 21), (3000, 'Crucero Oasis', 'Barco', 21),
(5, 'Toyota Corolla', 'Otros', 26), (180, 'Boeing 737', 'Avion', 3),
(40, 'Yate Privado', 'Barco', 22), (4, 'Ford Fiesta', 'Otros', 27),
(60, 'Bus Cama', 'Bus', 21), (250, 'Airbus A330', 'Avion', 4);

-- Terminales
INSERT INTO terminal (ter_nombre, ter_tipo, fk_lugar) VALUES
('Maiquetía', 'Aeropuerto', 7), ('Valencia Big Low', 'Estacion Terrestre', 10),
('Puerto La Guaira', 'Puerto Maritimo', 7), ('JFK Airport', 'Aeropuerto', 1),
('Barajas', 'Aeropuerto', 2), ('Aeropuerto Santiago Mariño', 'Aeropuerto', 14),
('Terminal La Bandera', 'Estacion Terrestre', 8), ('Puerto Guamache', 'Puerto Maritimo', 14),
('Aeropuerto La Chinita', 'Aeropuerto', 9), ('Aeropuerto Jacinto Lara', 'Aeropuerto', 11);

-- Rutas
INSERT INTO ruta (rut_costo, rut_millas_otorgadas, rut_tipo, fk_terminal_origen, fk_terminal_destino, fk_prov_codigo) VALUES
(100.00, 50, 'Aerea', 1, 6, 1), (120.00, 60, 'Aerea', 1, 9, 2),
(50.00, 20, 'Terrestre', 7, 2, 21), (800.00, 500, 'Maritima', 3, 8, 22),
(200.00, 100, 'Aerea', 1, 4, 8), (150.00, 80, 'Aerea', 1, 5, 11),
(60.00, 30, 'Terrestre', 2, 10, 21), (90.00, 40, 'Aerea', 6, 1, 1),
(110.00, 55, 'Aerea', 9, 1, 2), (500.00, 250, 'Maritima', 3, 8, 23);

-- Servicios (Ejemplos variados)
INSERT INTO servicio (ser_nombre, ser_descripcion, ser_costo, ser_fecha_hora_inicio, ser_fecha_hora_fin, ser_tipo, fk_prov_codigo) VALUES
('Vuelo Ccs-Porlamar', 'Ida', 100.00, NOW(), NOW() + INTERVAL '1 hour', 'Vuelo', 1),
('Alojamiento Eurobuilding', 'Noche', 150.00, NOW(), NOW() + INTERVAL '1 day', 'Alojamiento', 1),
('Alquiler Corolla', 'Dia', 40.00, NOW(), NOW() + INTERVAL '1 day', 'Transporte', 26),
('Crucero Caribe', '7 dias', 800.00, NOW(), NOW() + INTERVAL '7 days', 'Tour', 21),
('Vuelo Ccs-Miami', 'Ida', 300.00, NOW(), NOW() + INTERVAL '4 hours', 'Vuelo', 8),
('Tour Avila', 'Full day', 20.00, NOW(), NOW() + INTERVAL '8 hours', 'Tour', 41),
('Cena Romántica', 'Restaurante', 50.00, NOW(), NOW() + INTERVAL '2 hours', 'Comida', 1),
('Traslado Aeropuerto', 'Taxi', 30.00, NOW(), NOW() + INTERVAL '1 hour', 'Transporte', 26),
('Full Day Mochima', 'Lancha', 25.00, NOW(), NOW() + INTERVAL '8 hours', 'Tour', 43),
('Spa Relax', 'Masaje', 80.00, NOW(), NOW() + INTERVAL '1 hour', 'Otros', 1);

-- Métodos de Pago
INSERT INTO metodo_pago (met_pag_descripcion) VALUES 
('Tarjeta Crédito'), ('Tarjeta Débito'), ('Zelle'), ('Efectivo'), ('Transferencia'),
('Pago Móvil'), ('Criptomoneda'), ('Cheque'), ('Millas'), ('PayPal');