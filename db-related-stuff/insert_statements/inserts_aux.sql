--Inserts para tabla de roles

INSERT INTO rol(rol_nombre, rol_descripcion)
VALUES ('Administrador', 'Administrador del sistema ViajesUcab.')

INSERT INTO rol(rol_nombre, rol_descripcion)
VALUES ('Proveedor', 'Responsable de proveedor de servicios')

INSERT INTO rol(rol_nombre, rol_descripcion)
VALUES('Cliente', 'Consumidor/Comprador de servicios')

--Inserts para Usuario
INSERT INTO usuario(usu_nombre_usuario, usu_contrasena, usu_email, fk_rol_codigo)
VALUES('artadmin', '1234', '10arturojpinto@gmail.com', 1)


INSERT INTO privilegio(pri_nombre, pri_descripcion)
Values
('crear_usuarios', 'creacion de proveedores y clientes'),
('eliminar_usuarios', 'eliminacion de proveedores y clientes'),
('leer_usuarios', 'ver informacion sobre usuarios distintos a uno'),
('crear_recursos','creacion de viajes, rutas, servicios, paquetes, etc.'),
('modificar_recursos', 'modificacion de viajes, rutas, servicios, paquetes, etc'),
('eliminar_recursos', 'eliminacion de viajes, rutas, servicios, paquetes, etc.'),
('reservar_y_comprar', 'reserva y compra de servicios'),
('manipulacion_de_roles', 'creacion, eliminacion, lectura y actualizacion de roles y privilegios');

--Asignacion de privilegios a Adminsitrador
INSERT INTO rol_privilegio(fk_pri_codigo, fk_rol_codigo)
Values
(1,1),
(2,1),
(3,1),
(4,1),
(5,1),
(6,1),
(8,1);

Insert into privilegio(pri_nombre, pri_descripcion)
Values
('manipular_viajeros', 'creacion, eliminacion, lectura y modificacion de viajeros');

INSERT INTO rol_privilegio(fk_pri_codigo, fk_rol_codigo)
VALUES
(7,3),
(9,3)