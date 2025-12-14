-- Insertamos un lugar dummy (ej. Venezuela) para asignarselo al admin
INSERT INTO lugar (lug_nombre, lug_tipo, fk_lugar) 
VALUES ('Venezuela', 'Pais', NULL); 
-- Asumiremos que este insert genera el ID 1.


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