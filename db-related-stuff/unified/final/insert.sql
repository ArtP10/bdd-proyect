
-- 1. ROL (10 registros)
INSERT INTO rol (rol_nombre, rol_descripcion) VALUES
('Administrador', 'Control total del sistema'),
('Proveedor', 'Gestión de servicios y productos'),
('Cliente', 'Acceso a compras y reservas'),
('Viajero', 'Perfil de pasajero'),
('Auditor', 'Solo consulta de logs'),
('Soporte', 'Asistencia a usuarios'),
('EditorContenido', 'Gestión de promociones y descripciones'),
('Finanzas', 'Gestión de pagos y reembolsos'),
('Gerente', 'Reportes y supervisión general'),
('Desarrollador', 'Mantenimiento del sistema');

-- 2. PRIVILEGIO (10 registros)
INSERT INTO privilegio (pri_nombre, pri_descripcion) VALUES
('CrearUsuario', 'Permite crear nuevos usuarios'),
('EditarServicio', 'Permite modificar servicios'),
('EliminarReserva', 'Permite cancelar reservas'),
('VerReportes', 'Permite ver informes financieros'),
('GestionarRoles', 'Permite asignar roles'),
('CrearPromocion', 'Permite crear descuentos'),
('VerDatosViajero', 'Permite consultar información de pasajeros'),
('AuditarLogs', 'Permite ver registros de auditoría'),
('AprobarPagos', 'Permite confirmar transacciones'),
('GestionarMillas', 'Permite modificar saldos de millas');

-- 3. NACIONALIDAD (10 registros)
INSERT INTO nacionalidad (nac_nombre) VALUES
('Venezolana'), ('Estadounidense'), ('Argentina'), ('Española'),
('Francesa'), ('Japonesa'), ('Brasileña'), ('Mexicana'),
('Canadiense'), ('Italiana');

-- 4. ESTADO_CIVIL (10 registros)
INSERT INTO estado_civil (edo_civ_nombre) VALUES
('Soltero/a'), ('Casado/a'), ('Divorciado/a'), ('Viudo/a'),
('Concubinato'), ('Separado/a'), ('UnionLibre'), ('Comprometido/a'),
('EnRelacion'), ('NoEspecificado');

-- 5. METODO_PAGO (10 registros)
INSERT INTO metodo_pago (met_pag_descripcion) VALUES
('Tarjeta de Crédito'), ('Tarjeta de Débito'), ('Cheque'),
('Depósito Bancario'), ('Transferencia Bancaria'),
('Pago Móvil Interbancario'), ('Criptomoneda'), ('Zelle'),
('Efectivo'), ('Millas');

-- 6. ACCION (10 registros)
INSERT INTO accion (acc_nombre, acc_descripcion) VALUES
('Crear', 'Registro de un nuevo elemento'),
('Actualizar', 'Modificación de un elemento existente'),
('Eliminar', 'Borrado de un elemento'),
('Consultar', 'Acceso a la información'),
('Login', 'Inicio de sesión'),
('Logout', 'Cierre de sesión'),
('Aprobar', 'Confirmación de una transacción/proceso'),
('Cancelar', 'Anulación de una operación'),
('Bloquear', 'Restricción de acceso a un usuario/recurso'),
('Reembolsar', 'Proceso de devolución de dinero');

-- 7. RECURSO (10 registros)
INSERT INTO recurso (recu_nombre_tabla, recu_descripcion) VALUES
('usuario', 'Tabla de usuarios del sistema'),
('servicio', 'Tabla de servicios turísticos'),
('reserva', 'Tabla de detalles de reserva'),
('pago', 'Tabla de transacciones de pago'),
('promocion', 'Tabla de ofertas y descuentos'),
('proveedor', 'Tabla de proveedores de servicios'),
('viajero', 'Tabla de perfiles de viajeros'),
('lugar', 'Tabla de ubicación geográfica'),
('paquete_turistico', 'Tabla de paquetes'),
('reclamo', 'Tabla de quejas de clientes');

-- 8. CATEGORIA (10 registros)
INSERT INTO categoria (cat_nombre, cat_descripcion) VALUES
('Aventura', 'Viajes de alta adrenalina y exploración'),
('Playa', 'Destinos costeros y de sol'),
('Cultura', 'Viajes enfocados en historia y tradiciones'),
('Montaña', 'Destinos de altura y ecoturismo'),
('Ciudad', 'Viajes urbanos y de negocios'),
('Relax', 'Destinos de spa y bienestar'),
('Gastronomía', 'Viajes centrados en la comida local'),
('Deportes', 'Viajes para asistir o practicar deportes'),
('Familiar', 'Viajes aptos para toda la familia'),
('Lujo', 'Experiencias de viaje premium');

-- 9. ESTADO (10 registros)
INSERT INTO estado (est_nombre, est_descripcion) VALUES
('Activo', 'Entidad actualmente operativa/vigente'),
('Inactivo', 'Entidad no operativa/suspendida'),
('Pagado', 'Pago confirmado'),
('Pendiente', 'Esperando una acción o confirmación'),
('Confirmada', 'Reserva o servicio asegurado'),
('Cancelada', 'Anulación del servicio/reserva'),
('Reembolsado', 'Proceso de reembolso completado'),
('Vencido', 'Fecha límite superada'),
('EnProgreso', 'Proceso en ejecución'),
('Finalizado', 'Servicio completado');

-- 10. LUGAR (Componente geográfico)

-- Continentes (Para referencia, no requeridos por el esquema, pero útiles para la lógica)
-- 1. ASIA
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES ('Pais', 'Japón', NULL);
-- 2. ÁFRICA
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES ('Pais', 'Egipto', NULL);
-- 3. EUROPA
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES ('Pais', 'Alemania', NULL);
-- 4. OCEANÍA
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES ('Pais', 'Australia', NULL);
-- 5. AMÉRICA DEL NORTE
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES ('Pais', 'Canadá', NULL);

-- Ciudades por continente
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES ('Ciudad', 'Tokio', 1); -- Japón
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES ('Ciudad', 'El Cairo', 2); -- Egipto
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES ('Ciudad', 'Berlín', 3); -- Alemania
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES ('Ciudad', 'Sídney', 4); -- Australia
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES ('Ciudad', 'Toronto', 5); -- Canadá

-- Venezuela
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES ('Pais', 'Venezuela', NULL); -- lug_codigo = 11

-- Estados de Venezuela (24 en total)
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES
('Estado', 'Amazonas', 11), ('Estado', 'Anzoátegui', 11),
('Estado', 'Apure', 11), ('Estado', 'Aragua', 11),
('Estado', 'Barinas', 11), ('Estado', 'Bolívar', 11),
('Estado', 'Carabobo', 11), ('Estado', 'Cojedes', 11),
('Estado', 'Delta Amacuro', 11), ('Estado', 'Falcón', 11),
('Estado', 'Guárico', 11), ('Estado', 'Lara', 11),
('Estado', 'Mérida', 11), ('Estado', 'Miranda', 11),
('Estado', 'Monagas', 11), ('Estado', 'Nueva Esparta', 11),
('Estado', 'Portuguesa', 11), ('Estado', 'Sucre', 11),
('Estado', 'Táchira', 11), ('Estado', 'Trujillo', 11),
('Estado', 'La Guaira', 11), ('Estado', 'Yaracuy', 11),
('Estado', 'Zulia', 11), ('Estado', 'Distrito Capital', 11);

-- Ciudades principales (Capitales de Estado)
-- Los `fk_lugar` van del 12 (Amazonas) al 35 (Distrito Capital)
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) VALUES
('Ciudad', 'Puerto Ayacucho', 12), ('Ciudad', 'Barcelona', 13),
('Ciudad', 'San Fernando de Apure', 14), ('Ciudad', 'Maracay', 15),
('Ciudad', 'Barinas', 16), ('Ciudad', 'Ciudad Bolívar', 17),
('Ciudad', 'Valencia', 18), ('Ciudad', 'San Carlos', 19),
('Ciudad', 'Tucupita', 20), ('Ciudad', 'Coro', 21),
('Ciudad', 'San Juan de los Morros', 22), ('Ciudad', 'Barquisimeto', 23),
('Ciudad', 'Mérida', 24), ('Ciudad', 'Los Teques', 25),
('Ciudad', 'Maturín', 26), ('Ciudad', 'La Asunción', 27),
('Ciudad', 'Guanare', 28), ('Ciudad', 'Cumaná', 29),
('Ciudad', 'San Cristóbal', 30), ('Ciudad', 'Trujillo', 31),
('Ciudad', 'La Guaira', 32), ('Ciudad', 'San Felipe', 33),
('Ciudad', 'Maracaibo', 34), ('Ciudad', 'Caracas', 35);

INSERT INTO milla_pago (met_pag_codigo, mil_cantidad_utilizada) VALUES
(3, 300), -- Millas 6 (uso de 300 millas)
(10, 1200); -- Millas 7 (uso de 1200 millas)
-- 11. TASA_DE_CAMBIO (5 tasas para 3 monedas)
-- Monedas: USD, EUR, COP
INSERT INTO tasa_de_cambio (tas_cam_tasa_valor, tas_cam_fecha_hora_inicio, tas_cam_moneda) VALUES
(270.00, '2025-11-01 08:00:00', 'USD'),
(274.00, '2025-11-05 10:30:00', 'USD'),
(317.00, '2025-11-10 12:00:00', 'EUR'),
(323.00, '2025-11-15 14:00:00', 'EUR'),
(0.07, '2025-11-01 09:00:00', 'COP'),
(0.078, '2025-11-12 11:00:00', 'COP'),
(280.00, '2025-12-01 15:00:00', 'USD'),
(330.00, '2025-12-05 16:00:00', 'EUR'),
(0.080, '2025-12-01 17:00:00', 'COP'),
(0.090, '2025-12-03 17:00:00', 'COP');

-- Actualizar fechas fin (simulación de historización)
UPDATE tasa_de_cambio SET tas_cam_fecha_hora_fin = '2025-11-04 23:59:59' WHERE tas_cam_codigo = 1;
UPDATE tasa_de_cambio SET tas_cam_fecha_hora_fin = '2025-11-09 23:59:59' WHERE tas_cam_codigo = 2;
UPDATE tasa_de_cambio SET tas_cam_fecha_hora_fin = '2025-11-14 23:59:59' WHERE tas_cam_codigo = 3;
UPDATE tasa_de_cambio SET tas_cam_fecha_hora_fin = '2025-11-30 23:59:59' WHERE tas_cam_codigo = 4;
UPDATE tasa_de_cambio SET tas_cam_fecha_hora_fin = '2025-11-11 23:59:59' WHERE tas_cam_codigo = 5;
UPDATE tasa_de_cambio SET tas_cam_fecha_hora_fin = '2025-11-30 23:59:59' WHERE tas_cam_codigo = 6;
UPDATE tasa_de_cambio SET tas_cam_fecha_hora_fin = '2025-12-04 23:59:59' WHERE tas_cam_codigo = 7;
UPDATE tasa_de_cambio SET tas_cam_fecha_hora_fin = '2025-12-14 23:59:59' WHERE tas_cam_codigo = 8;
update tasa_de_cambio set tas_cam_fecha_hora_fin = '2025-12-15 23:59:59' where tas_cam_codigo = 9;
update tasa_de_cambio set tas_cam_fecha_hora_fin = '2025-12-16 23:59:59' where tas_cam_codigo = 10;

INSERT INTO tasa_de_cambio (tas_cam_tasa_valor, tas_cam_fecha_hora_inicio, tas_cam_moneda) VALUES
(0.030, '2025-10-01 10:00:00', 'MILLA'), -- Tasa 1 MILLA: 0.030 VEF/milla
(0.035, '2025-10-15 11:00:00', 'MILLA'), -- Tasa 2 MILLA: 0.035 VEF/milla
(0.040, '2025-11-01 12:00:00', 'MILLA'), -- Tasa 3 MILLA: 0.040 VEF/milla
(0.045, '2025-11-15 13:00:00', 'MILLA'), -- Tasa 4 MILLA: 0.045 VEF/milla
(0.050, '2025-12-01 14:00:00', 'MILLA'); -- Tasa 5 MILLA: 0.050 VEF/milla

-- Fechas de fin para las millas (Códigos 10 a 14)
UPDATE tasa_de_cambio SET tas_cam_fecha_hora_fin = '2025-10-14 10:59:59' WHERE tas_cam_codigo = 11;
UPDATE tasa_de_cambio SET tas_cam_fecha_hora_fin = '2025-10-31 11:59:59' WHERE tas_cam_codigo = 12;
UPDATE tasa_de_cambio SET tas_cam_fecha_hora_fin = '2025-11-14 12:59:59' WHERE tas_cam_codigo = 13;
UPDATE tasa_de_cambio SET tas_cam_fecha_hora_fin = '2025-11-30 13:59:59' WHERE tas_cam_codigo = 14;
-- Tasa 14 (MILLA) sigue vigente

-- 12. PROMOCION (10 registros)
INSERT INTO promocion (prom_nombre, prom_descripcion, prom_fecha_hora_vencimiento, prom_descuento) VALUES
('Verano25', '25% de descuento en servicios de playa', '2026-03-31 23:59:59', 25.00),
('EarlyBird', '15% de descuento en reservas anticipadas', '2026-06-30 23:59:59', 15.00),
('FindeSemana', '10% en hoteles los fines de semana', '2025-12-31 23:59:59', 10.00),
('EspecialViajero', '20% en paquetes turísticos', '2026-01-31 23:59:59', 20.00),
('MillasDoble', 'Acumula el doble de millas', '2026-02-28 23:59:59', 0.00),
('Hotel4Noches', 'Descuento del 18% en estancias largas', '2026-04-15 23:59:59', 18.00),
('TourAventura', '30% en tours de aventura', '2026-05-01 23:59:59', 30.00),
('RestauranteGourmet', '12% en restaurantes de alta cocina', '2026-03-01 23:59:59', 12.00),
('Navidad20', '20% en todo el catálogo de viajes', '2025-12-25 23:59:59', 20.00),
('Aniversario10', '10% de descuento por aniversario', '2026-10-07 23:59:59', 10.00);

--Inserts 48 Usuarios
INSERT INTO usuario (usu_contrasena, usu_nombre_usuario, fk_rol_codigo, usu_email, fk_lugar) VALUES
('pass123', 'juan.perez.am', 3, 'juan.perez.am@email.com', 12), -- Amazonas
('pass123', 'maria.rojas.am', 3, 'maria.rojas.am@email.com', 12),
('pass123', 'carlos.gomez.an', 3, 'carlos.gomez.an@email.com', 13), -- Anzoátegui
('pass123', 'ana.lopez.an', 3, 'ana.lopez.an@email.com', 13),
('pass123', 'pedro.diaz.ap', 3, 'pedro.diaz.ap@email.com', 14), -- Apure
('pass123', 'luisa.mendez.ap', 3, 'luisa.mendez.ap@email.com', 14),
('pass123', 'javier.soto.ar', 3, 'javier.soto.ar@email.com', 15), -- Aragua
('pass123', 'elena.castro.ar', 3, 'elena.castro.ar@email.com', 15),
('pass123', 'manuel.ruiz.ba', 3, 'manuel.ruiz.ba@email.com', 16), -- Barinas
('pass123', 'rosa.alvarez.ba', 3, 'rosa.alvarez.ba@email.com', 16),
('pass123', 'andres.morales.bo', 3, 'andres.morales.bo@email.com', 17), -- Bolívar
('pass123', 'sofia.fernandez.bo', 3, 'sofia.fernandez.bo@email.com', 17),
('pass123', 'ricardo.torres.ca', 3, 'ricardo.torres.ca@email.com', 18), -- Carabobo
('pass123', 'patricia.silva.ca', 3, 'patricia.silva.ca@email.com', 18),
('pass123', 'alejandro.vargas.co', 3, 'alejandro.vargas.co@email.com', 19), -- Cojedes
('pass123', 'gabriela.perez.co', 3, 'gabriela.perez.co@email.com', 19),
('pass123', 'daniel.herrera.da', 3, 'daniel.herrera.da@email.com', 20), -- Delta Amacuro
('pass123', 'natalia.gomez.da', 3, 'natalia.gomez.da@email.com', 20),
('pass123', 'jorge.ramirez.fa', 3, 'jorge.ramirez.fa@email.com', 21), -- Falcón
('pass123', 'adriana.blanco.fa', 3, 'adriana.blanco.fa@email.com', 21),
('pass123', 'miguel.acosta.gu', 3, 'miguel.acosta.gu@email.com', 22), -- Guárico
('pass123', 'veronica.sanchez.gu', 3, 'veronica.sanchez.gu@email.com', 22),
('pass123', 'felix.gonzalez.la', 3, 'felix.gonzalez.la@email.com', 23), -- Lara
('pass123', 'marisol.ruiz.la', 3, 'marisol.ruiz.la@email.com', 23),
('pass123', 'hector.mendoza.me', 3, 'hector.mendoza.me@email.com', 24), -- Mérida
('pass123', 'claudia.flores.me', 3, 'claudia.flores.me@email.com', 24),
('pass123', 'oscar.navarro.mi', 3, 'oscar.navarro.mi@email.com', 25), -- Miranda
('pass123', 'karla.espinoza.mi', 3, 'karla.espinoza.mi@email.com', 25),
('pass123', 'raul.valdez.mo', 3, 'raul.valdez.mo@email.com', 26), -- Monagas
('pass123', 'diana.pardo.mo', 3, 'diana.pardo.mo@email.com', 26),
('pass123', 'sergio.quintero.ne', 3, 'sergio.quintero.ne@email.com', 27), -- Nueva Esparta
('pass123', 'viviana.romero.ne', 3, 'viviana.romero.ne@email.com', 27),
('pass123', 'emilio.silva.po', 3, 'emilio.silva.po@email.com', 28), -- Portuguesa
('pass123', 'isabel.rojas.po', 3, 'isabel.rojas.po@email.com', 28),
('pass123', 'gregorio.rios.su', 3, 'gregorio.rios.su@email.com', 29), -- Sucre
('pass123', 'lorena.gomez.su', 3, 'lorena.gomez.su@email.com', 29),
('pass123', 'roberto.diaz.ta', 3, 'roberto.diaz.ta@email.com', 30), -- Táchira
('1234', 'melanie.gamboa.ta', 3, 'melanie.gamboa.ta@email.com', 30),
('pass123', 'alfonso.lopez.tr', 3, 'alfonso.lopez.tr@email.com', 31), -- Trujillo
('pass123', 'marta.perez.tr', 3, 'marta.perez.tr@email.com', 31),
('pass123', 'ernesto.soto.vg', 3, 'ernesto.soto.vg@email.com', 32), -- La Guaira (Vargas)
('pass123', 'paola.castro.vg', 3, 'paola.castro.vg@email.com', 32),
('pass123', 'ignacio.ruiz.ya', 3, 'ignacio.ruiz.ya@email.com', 33), -- Yaracuy
('pass123', 'monica.alvarez.ya', 3, 'monica.alvarez.ya@email.com', 33),
('pass123', 'javier.morales.zu', 3, 'javier.morales.zu@email.com', 34), -- Zulia
('pass123', 'valentina.fernandez.zu', 3, 'valentina.fernandez.zu@email.com', 34),
('1234', 'jesus.obando.dc', 3, 'jesus.obando.dc@email.com', 35), -- Distrito Capital
('1234', 'arturo.pinto.dc', 3, 'arturo.pinto.dc@email.com', 35);

    -- 20 Aerolíneas (fk_lugar: Maracay (15), Barcelona (13), Caracas (35))
    INSERT INTO usuario (usu_contrasena, usu_nombre_usuario, fk_rol_codigo, usu_email, fk_lugar) VALUES
    ('airpass', 'aero.global', 2, 'aero.global@prov.com', 15),
    ('airpass', 'vuela.facil', 2, 'vuela.facil@prov.com', 15),
    ('airpass', 'cielo.azul', 2, 'cielo.azul@prov.com', 15),
    ('airpass', 'alas.libres', 2, 'alas.libres@prov.com', 15),
    ('airpass', 'turbo.air', 2, 'turbo.air@prov.com', 24), -- Mérida
    ('airpass', 'air.speed', 2, 'air.speed@prov.com', 24),
    ('airpass', 'skyline.co', 2, 'skyline.co@prov.com', 24),
    ('airpass', 'jet.world', 2, 'jet.world@prov.com', 24),
    ('airpass', 'condor.express', 2, 'condor.express@prov.com', 13), -- Anzoátegui
    ('airpass', 'aguila.viajera', 2, 'aguila.viajera@prov.com', 13),
    ('airpass', 'vuelo.magico', 2, 'vuelo.magico@prov.com', 13),
    ('airpass', 'conexion.aerea', 2, 'conexion.aerea@prov.com', 13),
    ('airpass', 'air.max', 2, 'air.max@prov.com', 35), -- D. Capital
    ('airpass', 'premium.air', 2, 'premium.air@prov.com', 35),
    ('airpass', 'air.flyer', 2, 'air.flyer@prov.com', 35),
    ('airpass', 'star.wings', 2, 'star.wings@prov.com', 35),
    ('airpass', 'galaxy.air', 2, 'galaxy.air@prov.com', 35),
    ('airpass', 'oceanic.air', 2, 'oceanic.air@prov.com', 35),
    ('airpass', 'air.plus', 2, 'air.plus@prov.com', 35),
    ('airpass', 'air.route', 2, 'air.route@prov.com', 35);

    -- 5 Cruceros (fk_lugar: Nueva Esparta (27), Carabobo (18))
    INSERT INTO usuario (usu_contrasena, usu_nombre_usuario, fk_rol_codigo, usu_email, fk_lugar) VALUES
    ('shipass', 'crucero.mar', 2, 'crucero.mar@prov.com', 27),
    ('shipass', 'ocean.dream', 2, 'ocean.dream@prov.com', 27),
    ('shipass', 'barco.lujo', 2, 'barco.lujo@prov.com', 18),
    ('shipass', 'sea.explorer', 2, 'sea.explorer@prov.com', 18),
    ('shipass', 'yate.express', 2, 'yate.express@prov.com', 18);

    -- -- 20 Alquiler de Vehículos (fk_lugar: Zulia (34), Lara (23), Barinas (16))
    INSERT INTO usuario (usu_contrasena, usu_nombre_usuario, fk_rol_codigo, usu_email, fk_lugar) VALUES
    ('carpass', 'renta.auto', 2, 'renta.auto@prov.com', 34),
    ('carpass', 'vehiculo.rapido', 2, 'vehiculo.rapido@prov.com', 34),
    ('carpass', 'car.plus', 2, 'car.plus@prov.com', 34),
    ('carpass', 'rent.go', 2, 'rent.go@prov.com', 34),
    ('carpass', 'auto.seguro', 2, 'auto.seguro@prov.com', 34),
    ('carpass', 'road.trip', 2, 'road.trip@prov.com', 34),
    ('carpass', 'drive.easy', 2, 'drive.easy@prov.com', 34),
    ('carpass', 'car.best', 2, 'car.best@prov.com', 34),
    ('carpass', 'rent.pro', 2, 'rent.pro@prov.com', 34),
    ('carpass', 'auto.freedom', 2, 'auto.freedom@prov.com', 34),
    ('carpass', 'fast.cars', 2, 'fast.cars@prov.com', 23),
    ('carpass', 'renta.vip', 2, 'renta.vip@prov.com', 23),
    ('carpass', 'renta.premium', 2, 'renta.premium@prov.com', 23),
    ('carpass', 'rent.alfa', 2, 'rent.alfa@prov.com', 23),
    ('carpass', 'rent.omega', 2, 'rent.omega@prov.com', 23),
    ('carpass', 'renta.max', 2, 'renta.max@prov.com', 16),
    ('carpass', 'renta.plus', 2, 'renta.plus@prov.com', 16),
    ('carpass', 'renta.master', 2, 'renta.master@prov.com', 16),
    ('carpass', 'renta.class', 2, 'renta.class@prov.com', 16),
    ('carpass', 'renta.global', 2, 'renta.global@prov.com', 16);

    -- 1 Servicio Turístico (Otros) (fk_lugar: Táchira (30))
    INSERT INTO usuario (usu_contrasena, usu_nombre_usuario, fk_rol_codigo, usu_email, fk_lugar) VALUES
    ('otherpass', 'tour.guia', 2, 'tour.guia@prov.com', 30);

    -- 3. Usuarios Empleados (Rol 'Administrador' fk_rol_codigo = 1, Rol 'Finanzas' fk_rol_codigo = 8)
    INSERT INTO usuario (usu_contrasena, usu_nombre_usuario, fk_rol_codigo, usu_email, fk_lugar) VALUES
    ('adm123', 'admin.principal', 1, 'admin.principal@sistema.com', 35), -- D. Capital
    ('finpass', 'analista.finanzas', 8, 'analista.finanzas@sistema.com', 35);


    -- 20 Aerolíneas (fk_lugar: Ciudades)
    INSERT INTO proveedor (prov_nombre, prov_tipo, fk_lugar, fk_usu_codigo) VALUES
    ('Aero Global Inc.', 'Aerolinea', 39, 49),  -- Maracay
    ('Vuela Fácil Air', 'Aerolinea', 39, 50),
    ('Cielo Azul Airlines', 'Aerolinea', 39, 51),
    ('Alas Libres', 'Aerolinea', 39, 52),
    ('Turbo Air Express', 'Aerolinea', 45, 53), -- Mérida
    ('Air Speed Cargo', 'Aerolinea', 45, 54),
    ('Skyline Co.', 'Aerolinea', 45, 55),
    ('Jet World Airways', 'Aerolinea', 45, 56),
    ('Cóndor Express', 'Aerolinea', 37, 57),  -- Barcelona
    ('Águila Viajera', 'Aerolinea', 37, 58),
    ('Vuelo Mágico', 'Aerolinea', 37, 59),
    ('Conexión Aérea', 'Aerolinea', 37, 60),
    ('Air Max', 'Aerolinea', 57, 61),  -- Caracas
    ('Premium Air Services', 'Aerolinea', 57, 62),
    ('Air Flyer', 'Aerolinea', 57, 63),
    ('Star Wings', 'Aerolinea', 57, 64),
    ('Galaxy Air', 'Aerolinea', 57, 65),
    ('Oceanic Air', 'Aerolinea', 57, 66),
    ('Air Plus', 'Aerolinea', 57, 67),
    ('Air Route', 'Aerolinea', 57, 68);

    -- 5 Cruceros (fk_lugar: Ciudades)
    INSERT INTO proveedor (prov_nombre, prov_tipo, fk_lugar, fk_usu_codigo) VALUES
    ('Crucero del Mar', 'Maritimo', 48, 69), -- La Asunción
    ('Ocean Dream Cruise', 'Maritimo', 48, 70),
    ('Barco de Lujo', 'Maritimo', 40, 71),  -- Valencia
    ('Sea Explorer Ships', 'Maritimo', 40, 72),
    ('Yate Express Line', 'Maritimo', 40, 73);

    -- 20 Alquiler de Vehículos (Terrestre) (fk_lugar: Ciudades)
    INSERT INTO proveedor (prov_nombre, prov_tipo, fk_lugar, fk_usu_codigo) VALUES
    ('Renta Auto Zulia', 'Terrestre', 56, 74), -- Maracaibo
    ('Vehículo Rápido C.A.', 'Terrestre', 56, 75),
    ('Car Plus Rent', 'Terrestre', 56, 76),
    ('Rent and Go', 'Terrestre', 56, 77),
    ('Auto Seguro Rent', 'Terrestre', 56, 78),
    ('Road Trip Cars', 'Terrestre', 56, 79),
    ('Drive Easy', 'Terrestre', 56, 80),
    ('Car Best Rentals', 'Terrestre', 56, 81),
    ('Rent Pro Rental', 'Terrestre', 56, 82),
    ('Auto Freedom', 'Terrestre', 56, 83),
    ('Fast Cars Rentals', 'Terrestre', 44, 84), -- Barquisimeto
    ('Renta VIP', 'Terrestre', 44, 85),
    ('Renta Premium', 'Terrestre', 44, 86),
    ('Rent Alfa', 'Terrestre', 44, 87),
    ('Rent Omega', 'Terrestre', 44, 88),
    ('Renta Max C.A.', 'Terrestre', 38, 89),  -- Barinas
    ('Renta Plus', 'Terrestre', 38, 90),
    ('Renta Master', 'Terrestre', 38, 91),
    ('Renta Class', 'Terrestre', 38, 92),
    ('Renta Global', 'Terrestre', 38, 93);

    -- 1 Servicio Turístico (Otros)
    INSERT INTO proveedor (prov_nombre, prov_tipo, fk_lugar, fk_usu_codigo) VALUES
    ('Tour Guía Táchira', 'Otros', 51, 94); -- San Cristóbal

    INSERT INTO viajero (via_prim_nombre, via_seg_nombre, via_prim_apellido, via_seg_apellido, via_fecha_nacimiento, fk_usu_codigo) VALUES
    ('Juan', 'Jose', 'Perez', 'Garcia', '1985-05-10', 1),
    ('Manuel', 'David', 'Gomez', 'Mora', '1990-11-20', 1),

    ('Maria', 'Alejandra', 'Rojas', 'Vera', '1975-01-15', 2),
    ('Luisa', 'Elena', 'Mendez', 'Rivas', '1988-08-01', 2),

    ('Carlos', 'Alberto', 'Gomez', 'Soto', '1995-03-25', 3),
    ('Pedro', 'Luis', 'Diaz', 'Arias', '1980-07-07', 3),

    ('Ana', 'Beatriz', 'Lopez', 'Blanco', '1992-12-03', 4),
    ('Elena', 'Sofia', 'Castro', 'Luna', '1978-04-18', 4),

    ('Javier', 'Andres', 'Soto', 'Peña', '1983-09-12', 5),
    ('Andres', 'Felipe', 'Morales', 'Ramos', '1998-02-28', 5),

    ('Rosa', 'Maria', 'Alvarez', 'Suarez', '1970-06-30', 6),
    ('Sofia', 'Isabel', 'Fernandez', 'Torres', '1993-10-05', 6),

    ('Ricardo', 'Jose', 'Torres', 'Gil', '1987-05-01', 7),
    ('Alejandro', 'Gabriel', 'Vargas', 'Pardo', '1972-11-14', 7),

    ('Patricia', 'Carolina', 'Silva', 'Cardenas', '1996-01-22', 8),
    ('Gabriela', 'Maria', 'Perez', 'Ruiz', '1981-08-29', 8),

    ('Daniel', 'Ignacio', 'Herrera', 'Molina', '1976-03-08', 9),
    ('Jorge', 'Elias', 'Ramirez', 'Bello', '1991-04-04', 9),

    ('Natalia', 'Victoria', 'Gomez', 'Leon', '1989-10-19', 10),
    ('Adriana', 'Lucia', 'Blanco', 'Ortega', '1974-07-27', 10),

    ('Miguel', 'Angel', 'Acosta', 'Bravo', '1994-11-02', 11),
    ('Felix', 'Eduardo', 'Gonzalez', 'Marin', '1979-05-23', 11),

    ('Veronica', 'Paz', 'Sanchez', 'Guillen', '1986-12-07', 12),
    ('Marisol', 'De Jesus', 'Ruiz', 'Zambrano', '1997-02-16', 12),

    ('Hector', 'Luis', 'Mendoza', 'Carrillo', '1971-08-20', 13),
    ('Oscar', 'Jose', 'Navarro', 'Rangel', '1999-04-10', 13),

    ('Claudia', 'Patricia', 'Flores', 'Velez', '1984-01-28', 14),
    ('Karla', 'Genesis', 'Espinoza', 'Rondon', '1990-06-06', 14),

    ('Raul', 'Enrique', 'Valdez', 'Reyes', '1977-03-17', 15),
    ('Sergio', 'David', 'Quintero', 'Uzcategui', '1995-08-26', 15),

    ('Diana', 'Carolina', 'Pardo', 'Mejia', '1982-10-24', 16),
    ('Viviana', 'Alexandra', 'Romero', 'Mendoza', '1973-05-09', 16),

    ('Emilio', 'Rafael', 'Silva', 'Camacho', '1993-12-11', 17),
    ('Gregorio', 'Jesus', 'Rios', 'Guzman', '1978-01-05', 17),

    ('Isabel', 'Cristina', 'Rojas', 'Salazar', '1988-07-03', 18),
    ('Lorena', 'Fabiola', 'Gomez', 'Navas', '1996-09-15', 18),

    ('Roberto', 'Antonio', 'Diaz', 'Cabrera', '1985-02-09', 19),
    ('Alfonso', 'Simon', 'Lopez', 'Palacios', '1970-11-21', 19),

    ('Cecilia', 'Gabriela', 'Mendez', 'Serrano', '1991-04-29', 20),
    ('Marta', 'Liliana', 'Perez', 'Cordero', '1980-03-13', 20),

    ('Ernesto', 'Alejandro', 'Soto', 'Rangel', '1997-09-01', 21),
    ('Ignacio', 'Luis', 'Ruiz', 'Duarte', '1982-12-05', 21),

    ('Paola', 'Andreina', 'Castro', 'Abreu', '1975-06-19', 22),
    ('Monica', 'Estefania', 'Alvarez', 'Mata', '1994-01-26', 22),

    ('Javier', 'Alfredo', 'Morales', 'Briceno', '1983-04-02', 23),
    ('Oswaldo', 'Manuel', 'Martinez', 'Bastidas', '1978-11-08', 23),

    ('Valentina', 'Victoria', 'Fernandez', 'Leon', '1999-07-16', 24),
    ('Eugenia', 'Teresa', 'Silva', 'Escobar', '1987-02-10', 24),

    -- Segunda tanda de viajeros para los mismos clientes
    ('Raul', 'Camilo', 'Zamora', 'Vega', '1985-05-10', 25),
    ('Ana', 'Luisa', 'Herrera', 'Paz', '1990-11-20', 25),

    ('Gustavo', 'Adolfo', 'Vargas', 'Rondon', '1975-01-15', 26),
    ('Andrea', 'Carolina', 'Chavez', 'Mora', '1988-08-01', 26),

    ('Jorge', 'Ignacio', 'Marin', 'Diaz', '1995-03-25', 27),
    ('Mariana', 'Estrella', 'Pinto', 'Linares', '1980-07-07', 27),

    ('Pablo', 'Jesus', 'Vera', 'Rojas', '1992-12-03', 28),
    ('Laura', 'Maria', 'Sosa', 'Tellez', '1978-04-18', 28),

    ('Francisco', 'Javier', 'Mendez', 'Ortega', '1983-09-12', 29),
    ('Veronica', 'Luz', 'Valles', 'Guerra', '1998-02-28', 29),

    ('Angel', 'David', 'Rios', 'Colina', '1970-06-30', 30),
    ('Silvia', 'Corina', 'Nieves', 'Brito', '1993-10-05', 30),

    ('Jesus', 'Alberto', 'Quijada', 'Soto', '1987-05-01', 31),
    ('Marcia', 'Andreina', 'Flores', 'Luna', '1972-11-14', 31),

    ('Luis', 'Manuel', 'Castillo', 'Blanco', '1996-01-22', 32),
    ('Cindy', 'Vanessa', 'Gil', 'Lara', '1981-08-29', 32),

    ('Manuel', 'Ricardo', 'Alarcon', 'Perez', '1976-03-08', 33),
    ('Daniela', 'Carolina', 'Bastidas', 'Mora', '1991-04-04', 33),

    ('Rafael', 'Antonio', 'Salas', 'Rivas', '1989-10-19', 34),
    ('Erika', 'Yusmary', 'Paredes', 'Leal', '1974-07-27', 34),

    ('Guillermo', 'Enrique', 'Vargas', 'Marin', '1994-11-02', 35),
    ('Diana', 'Lucia', 'Ochoa', 'Diaz', '1979-05-23', 35),

    ('Humberto', 'Jose', 'Torres', 'Nava', '1986-12-07', 36),
    ('Jenifer', 'Karina', 'Bravo', 'Silva', '1997-02-16', 36),

    ('Jonathan', 'Daniel', 'Prieto', 'Alvarez', '1971-08-20', 37),
    ('Valeria', 'Sofia', 'Guerrero', 'Reyes', '1999-04-10', 37),

    ('Franklin', 'Javier', 'Ramos', 'Segovia', '1984-01-28', 38),
    ('Vanessa', 'Paola', 'Urbina', 'Zambrano', '1990-06-06', 38),

    ('Simón', 'Bolívar', 'Morales', 'Paz', '1977-03-17', 39),
    ('Rebeca', 'Milagros', 'Parra', 'Mata', '1995-08-26', 39),

    ('Alberto', 'Jose', 'Perez', 'Meza', '1982-10-24', 40),
    ('Alejandra', 'Maria', 'Soto', 'Ruiz', '1973-05-09', 40),

    ('Jairo', 'Alfonso', 'Guillen', 'Gomez', '1993-12-11', 41),
    ('Yelitza', 'Andreina', 'Mendez', 'Diaz', '1978-01-05', 41),

    ('Hilda', 'Marina', 'Gil', 'Herrera', '1988-07-03', 42),
    ('Samuel', 'Elias', 'Ortega', 'Leal', '1996-09-15', 42),

    ('Elias', 'Jose', 'Briceño', 'Torres', '1985-02-09', 43),
    ('Carmen', 'Elena', 'Cordero', 'Vargas', '1970-11-21', 43),

    ('Fanny', 'Carolina', 'Guzman', 'Soto', '1991-04-29', 44),
    ('Héctor', 'Luis', 'Salazar', 'Bravo', '1980-03-13', 44),

    ('Victor', 'Manuel', 'Rojas', 'Leon', '1997-09-01', 45),
    ('Laura', 'Cristina', 'Lopez', 'Mora', '1982-12-05', 45),

    ('Julio', 'Cesar', 'Perez', 'Quintero', '1975-06-19', 46),
    ('Esther', 'Sofia', 'Vega', 'Guillen', '1994-01-26', 46),

    ('Carlos', 'Eduardo', 'Zambrano', 'Vivas', '1983-04-02', 47),
    ('Alicia', 'Beatriz', 'Brito', 'Acosta', '1978-11-08', 47),

    ('Andrea', 'Veronica', 'Diaz', 'Pena', '1999-07-16', 48),
    ('Reinaldo', 'Jesus', 'Guzman', 'Gil', '1987-02-10', 48);

    -- Fk_nac_codigo 1 = Venezolana
    -- Fk_via_codigo = 1 al 10
    INSERT INTO documento (doc_fecha_emision, doc_fecha_vencimiento, doc_numero_documento, doc_tipo, fk_nac_codigo, fk_via_codigo) VALUES
    ('2018-01-20', '2028-01-20', 'V15000001', 'Pasaporte', 1, 1),
    ('2020-05-15', '2030-05-15', 'V15000002', 'Pasaporte', 1, 2),
    ('2021-08-01', '2031-08-01', 'V15000003', 'Pasaporte', 1, 3),
    ('2017-03-10', '2027-03-10', 'V15000004', 'Pasaporte', 1, 4),
    ('2019-11-05', '2029-11-05', 'V15000005', 'Pasaporte', 1, 5),
    ('2022-06-22', '2032-06-22', 'V15000006', 'Pasaporte', 1, 6),
    ('2016-02-18', '2026-02-18', 'V15000007', 'Pasaporte', 1, 7),
    ('2023-09-01', '2033-09-01', 'V15000008', 'Pasaporte', 1, 8),
    ('2015-07-12', '2025-07-12', 'V15000009', 'Pasaporte', 1, 9),
    ('2024-01-01', '2034-01-01', 'V15000010', 'Pasaporte', 1, 10);


    -- Administrador (1) tiene todos los privilegios (1-10)
    INSERT INTO rol_privilegio (fk_rol_codigo, fk_pri_codigo) VALUES
    (1, 1), (1, 2), (1, 3), (1, 4), (1, 5),
    (1, 6), (1, 7), (1, 8), (1, 9), (1, 10);

    -- 18. REGLA_PAQUETE (10 registros)
    INSERT INTO regla_paquete (reg_paq_atributo, reg_paq_operador, reg_paq_valor) VALUES
    ('Viaje Minimo 5 dias', '>=', '5'),
    ('Servicios Aerolinea', '=', '1'),
    ('Alojamiento Minimo', '>=', '2'),
    ('Monto Total', '>', '500.00'),
    ('Tipo Servicio', '=', 'Comfort'),
    ('Descuento Maximo', '<=', '20.00'),
    ('Fecha Caducidad', '>', '2026-06-01'),
    ('Numero Personas', '=', '4'),
    ('Destino', 'IN', 'Caribe'),
    ('Origen', '!=', 'CCS');

    -- 19. HOTEL (20 registros)
-- Usaremos las primeras 10 ciudades capitales:
-- 36: Puerto Ayacucho, 37: Barcelona, 38: San F. Apure, 39: Maracay, 40: Valencia,
-- 41: San Carlos, 42: Tucupita, 43: Coro, 44: Barquisimeto, 45: Mérida

INSERT INTO hotel (hot_nombre, hot_descripcion, hot_valoracion, hot_anos_servicio, fk_lugar) VALUES
('Hotel Amazonas Gran', 'Lujoso hotel con vista al río', 4.8, 15, 36), -- P. Ayacucho (36)
('Selva Resort', 'Un remanso de paz en la selva', 4.5, 8, 36),
('Playa Suites Barcelona', 'Apartamento frente al mar', 4.7, 20, 37), -- Barcelona (37)
('Hotel Oriente Vista', 'Cercano a las principales vías', 4.3, 10, 37),
('Hato Turístico Apure', 'Experiencia llanera auténtica', 4.9, 5, 38), -- San F. Apure (38)
('San Fernando Plaza', 'Hotel de negocios con piscina', 4.0, 12, 38),
('Maracay Gran Hotel', 'Histórico y céntrico', 4.6, 30, 39), -- Maracay (39)
('Hotel Jardín Aragua', 'Rodeado de naturaleza', 4.4, 7, 39),
('Valencia Suites & Casino', 'Máximo confort y entretenimiento', 4.8, 25, 40), -- Valencia (40)
('Hotel Lujo Carabobo', '5 estrellas con spa', 4.9, 10, 40),
('Cojedes Central', 'Económico y accesible', 3.5, 18, 41), -- San Carlos (41)
('San Carlos Inn', 'Posada campestre', 4.1, 4, 41),
('Hotel Orinoco Delta', 'Rústico con encanto', 4.2, 9, 42), -- Tucupita (42)
('Tucupita Palace', 'Única opción de lujo', 4.0, 6, 42),
('Coro Colonial Hotel', 'Arquitectura histórica', 4.7, 35, 43), -- Coro (43)
('Falcón Beach Resort', 'Cabañas privadas en la costa', 4.6, 14, 43),
('Hotel Barquisimeto VIP', 'Para viajeros de negocios', 4.5, 11, 44), -- Barquisimeto (44)
('Lara Suites', 'Apart-hotel moderno', 4.3, 3, 44),
('Hotel Teleférico Mérida', 'Con la mejor vista de la ciudad', 5.0, 40, 45), -- Mérida (45)
('Andes Mountain Lodge', 'Cabañas de alta montaña', 4.9, 16, 45);


-- 20. RESTAURANTE (10 registros)
-- Usaremos las ciudades de Caracas (57) y Maracaibo (56) y Barquisimeto (44)
-- fk_promocion y fk_telefono se dejan NULL por ahora.
INSERT INTO restaurante (res_nombre, res_descripcion, res_anos_servicio, res_valoracion, fk_lugar, fk_promocion, fk_telefono) VALUES
('El Gourmet Caraqueño', 'Cocina de autor con ingredientes locales', 15, 4.9, 57, NULL, NULL), -- Caracas (57)
('Bistró del Este', 'Comida francesa moderna', 8, 4.7, 57, NULL, NULL),
('Sabores del Lago', 'Especialidad en pescado y mariscos del Zulia', 20, 4.8, 56, NULL, NULL), -- Maracaibo (56)
('Asado y Parrilla', 'Las mejores carnes a la brasa', 12, 4.5, 56, NULL, NULL),
('La Arepera Criolla', 'Comida tradicional venezolana 24h', 30, 4.3, 56, NULL, NULL),
('Tapas de Barquisimeto', 'Especialidades españolas y vino', 10, 4.6, 44, NULL, NULL), -- Barquisimeto (44)
('Comida Saludable Lara', 'Opciones vegetarianas y veganas', 5, 4.4, 44, NULL, NULL),
('El Rincón Merideño', 'Platos andinos tradicionales', 18, 4.7, 45, NULL, NULL), -- Mérida (45)
('Pizzas Express', 'Pizza italiana al horno de leña', 7, 4.2, 40, NULL, NULL), -- Valencia (40)
('Sushi Palace', 'Fusión japonesa de alta calidad', 9, 4.8, 57, NULL, NULL); -- Caracas (57)

-- 21. PLATO (10 registros, asociados a los primeros 5 restaurantes)
INSERT INTO plato (pla_codigo, pla_nombre, pla_descripcion, pla_costo, fk_restaurante) VALUES
(1, 'Lomo de Res', 'Medallones de solomo con salsa de vino y papas trufadas', 35.50, 1),
(2, 'Risotto de Setas', 'Arroz Arborio cremoso con variedad de setas frescas', 28.00, 1),
(3, 'Cebiche Clásico', 'Pescado blanco marinado en limón con ají y cilantro', 22.90, 3),
(4, 'Pargo Frito', 'Pargo entero frito con tostones y ensalada rallada', 32.50, 3),
(5, 'Parrilla Mixta', 'Selección de carnes: pollo, res y cerdo. 500gr', 45.00, 4),
(6, 'Arepa Reina Pepiada', 'Arepa rellena de pollo, aguacate y mayonesa', 8.50, 5),
(7, 'Arepa Pabellón', 'Arepa rellena con carne mechada, caraotas y queso', 9.00, 5),
(8, 'Tortilla Española', 'Clásica tortilla de papas y huevos', 15.00, 6),
(9, 'Ensalada Quinoa', 'Quinoa, vegetales de estación y aderezo cítrico', 18.00, 7),
(10, 'Trucha Andina', 'Trucha fresca a la plancha con mantequilla de ajo', 25.00, 8);


-- 22. HABITACION (10 registros, asociados a los primeros 3 hoteles)
INSERT INTO habitacion (hab_capacidad, hab_descripcion, hab_costo_noche, fk_hotel, fk_promocion) VALUES
(2, 'Estándar, vista interior', 80.00, 1, NULL),
(4, 'Familiar, con dos camas dobles', 120.00, 1, NULL),
(2, 'Estándar, vista al mar', 95.00, 3, NULL),
(3, 'Suite Ejecutiva, cama King', 180.00, 3, 3), -- Con promoción FindeSemana (3)
(4, 'Villa Privada con jacuzzi', 250.00, 5, NULL),
(2, 'Habitación Doble Sencilla', 75.00, 5, NULL),
(2, 'Habitación Premium', 150.00, 7, NULL),
(1, 'Habitación Individual', 60.00, 7, NULL),
(2, 'Estándar, con balcón', 105.00, 9, 1), -- Con promoción Verano25 (1)
(4, 'Suite Presidencial', 400.00, 10, NULL);

-- 23. TERMINAL (10 registros)
-- Ciudades: Caracas (57), Maracaibo (56), Valencia (40), Barcelona (37), San Cristóbal (51)
-- Mérida (45), Barquisimeto (44), Porlamar/La Asunción (48), Pto. Ordaz/Cdad. Bolívar (42-Ciudad Bolívar es 42, no, 39, 40, 41.. Cdad. Bolívar es 39), (Ciudad Bolívar es 39 en el conteo)
-- La Guaira (53)
INSERT INTO terminal (ter_nombre, fk_lugar, ter_tipo) VALUES
('Aeropuerto Internacional Maiquetía', 53, 'Aéreo'), -- La Guaira (53)
('Terminal Terrestre Maracaibo', 56, 'Terrestre'), -- Maracaibo (56)
('Puerto de Valencia', 40, 'Marítimo'), -- Valencia (40)
('Aeropuerto José Antonio Anzoátegui', 37, 'Aéreo'), -- Barcelona (37)
('Terminal Terrestre San Cristóbal', 51, 'Terrestre'), -- San Cristóbal (51)
('Aeropuerto Alberto Carnevalli', 45, 'Aéreo'), -- Mérida (45)
('Terminal Terrestre Barquisimeto', 44, 'Terrestre'), -- Barquisimeto (44)
('Puerto de Guaranao', 43, 'Marítimo'), -- Coro (43)
('Aeropuerto Manuel Piar', 39, 'Aéreo'), -- Ciudad Bolívar (39)
('Terminal Caracas La Bandera', 57, 'Terrestre'); -- Caracas (57)

-- 25. TELEFONO (10 registros)

-- 3 para Proveedores (Códigos 1, 2, 3: Aero Global, Vuela Fácil, Cielo Azul)
INSERT INTO telefono (tel_prefijo_pais, tel_prefijo_operador, tel_sufijo, fk_prov_codigo, fk_hotel, fk_restaurante) VALUES
('58', '412', '1234567', 1, NULL, NULL),
('58', '212', '9876543', 2, NULL, NULL),
('58', '414', '5551122', 3, NULL, NULL);

-- 3 para Hoteles (Códigos 1, 3, 5: Hotel Amazonas, Playa Suites, Hato Turístico)
INSERT INTO telefono (tel_prefijo_pais, tel_prefijo_operador, tel_sufijo, fk_prov_codigo, fk_hotel, fk_restaurante) VALUES
('58', '241', '7890123', NULL, 1, NULL),
('58', '281', '3334455', NULL, 3, NULL),
('58', '416', '6667788', NULL, 5, NULL);

-- 4 para Restaurantes (Códigos 1, 3, 5, 10: El Gourmet, Sabores del Lago, La Arepera, Sushi Palace)
INSERT INTO telefono (tel_prefijo_pais, tel_prefijo_operador, tel_sufijo, fk_prov_codigo, fk_hotel, fk_restaurante) VALUES
('58', '212', '1112233', NULL, NULL, 1),
('58', '261', '8889900', NULL, NULL, 3),
('58', '424', '1010101', NULL, NULL, 5),
('58', '426', '2020202', NULL, NULL, 10);

-- 26. MEDIO_TRANSPORTE (10 registros)
INSERT INTO medio_transporte (med_tra_capacidad, med_tra_descripcion, med_tra_tipo, fk_prov_codigo) VALUES
(180, 'Boeing 737-800 estándar', 'Aereo', 1),   -- Aero Global
(150, 'Airbus A320 económico', 'Aereo', 2),    -- Vuela Fácil
(300, 'Crucero de Lujo Ocean Explorer', 'Maritimo', 21), -- Crucero del Mar
(50, 'Autobús Ejecutivo doble piso', 'Terrestre', 26), -- Renta Auto Zulia
(25, 'Minivan de 25 asientos', 'Terrestre', 27),
(4, 'Sedán de lujo', 'Terrestre', 28),
(8, 'Yate de recreo privado', 'Maritimo', 22), -- Ocean Dream Cruise
(350, 'Boeing 787 Dreamliner Premium', 'Aereo', 3), -- Cielo Azul Airlines
(6, 'SUV 4x4 todoterreno', 'Terrestre', 29),
(400, 'Barco ferry rápido', 'Maritimo', 23); -- Barco de Lujo

-- 27. PUESTO (10 registros)
-- Códigos de Medio_Transporte del 1 al 10
INSERT INTO puesto (pue_codigo, pue_descripcion, pue_costo_agregado, fk_med_tra_codigo) VALUES
(1, 'Ventana, fila 1', 50.00, 1),     -- Aéreo 1
(2, 'Pasillo, centro', 0.00, 1),
(10, 'Suite con Balcón', 200.00, 3),  -- Marítimo 3
(11, 'Asiento Ejecutivo', 15.00, 4),  -- Terrestre 4
(12, 'Asiento Estándar', 5.00, 4),
(20, 'Asiento Confort', 10.00, 5),
(30, 'Asiento trasero central', 0.00, 6),
(40, 'Asiento Business Class', 100.00, 8), -- Aéreo 8
(41, 'Asiento Económico', 0.00, 8),
(50, 'Asiento junto a ventana', 0.00, 10); -- Marítimo 10

-- 28. RUTA (10 registros)
-- Terminales: Maiquetía (1), Maracaibo T (2), Puerto Valencia (3), Barcelona A (4), San Cristóbal T (5)
-- Proveedores: Aéreos (1, 2), Marítimos (21, 22), Terrestres (26, 27)
INSERT INTO ruta (rut_costo, rut_millas_otorgadas, rut_tipo, rut_descripcion, fk_terminal_origen, fk_terminal_destino, fk_prov_codigo) VALUES
(150.00, 500, 'Aerea', 'Comfort', 1, 4, 1),    -- Maiquetía a Barcelona (Aero Global)
(80.00, 200, 'Aerea', 'Practico', 4, 1, 2),     -- Barcelona a Maiquetía (Vuela Fácil)
(500.00, 1000, 'Maritima', 'Lujo', 3, 3, 21),   -- Ruta Circular Crucero (Crucero del Mar)
(30.00, 50, 'Terrestre', 'Practico', 2, 7, 26),  -- Maracaibo a Barquisimeto (Renta Auto Zulia)
(45.00, 80, 'Terrestre', 'Comfort', 7, 5, 27),
(250.00, 750, 'Aerea', 'Corporativo', 1, 6, 1),   -- Maiquetía a Mérida
(120.00, 300, 'Aerea', 'Practico', 6, 1, 2),
(600.00, 1200, 'Maritima', 'Explorador', 3, 8, 22), -- Valencia a Coro (Ocean Dream)
(20.00, 40, 'Terrestre', 'Practico', 10, 3, 26), -- Caracas a Valencia
(180.00, 400, 'Aerea', 'Comfort', 4, 9, 3);    -- Barcelona a Ciudad Bolívar

-- 29. TRASLADO (10 registros)
-- Fechas en Noviembre/Diciembre 2025
-- Rutas del 1 al 10. Medios de transporte del 1 al 10.
INSERT INTO traslado (tras_fecha_hora_inicio, tras_fecha_hora_fin, tras_Co2_emitido, fk_rut_codigo, fk_med_tra_codigo) VALUES
('2025-11-20 10:00:00', '2025-11-20 11:30:00', 1.50, 1, 1), -- Vuelo (Ruta 1, Med. Tra. 1)
('2025-11-20 14:00:00', '2025-11-20 15:30:00', 1.30, 2, 2), -- Vuelo
('2025-12-01 18:00:00', '2025-12-05 08:00:00', 50.00, 3, 3), -- Crucero (4 días)
('2025-11-25 08:00:00', '2025-11-25 12:00:00', 3.00, 4, 4), -- Terrestre
('2025-11-25 13:00:00', '2025-11-25 18:00:00', 4.00, 5, 5), -- Terrestre
('2025-12-10 09:00:00', '2025-12-10 10:45:00', 1.80, 6, 8), -- Vuelo (Med. Tra. 8)
('2025-12-12 11:00:00', '2025-12-12 12:45:00', 1.60, 7, 2), -- Vuelo
('2025-12-15 09:00:00', '2025-12-18 19:00:00', 35.00, 8, 7), -- Yate (3 días)
('2025-11-28 16:00:00', '2025-11-28 18:30:00', 2.50, 9, 4), -- Terrestre
('2025-12-20 14:00:00', '2025-12-20 15:30:00', 1.40, 10, 1); -- Vuelo

-- 30. SERVICIO (10 registros)
-- Tipos de servicio válidos: 'Alojamiento', 'Actividad', 'Seguro', 'Aerolinea', 'Terrestre', 'Maritimo', 'Transporte', 'Tour', 'Comida', 'Vuelo', 'Otros'.
-- Usaremos Proveedores de hotel/restaurante o los específicos de transporte.

INSERT INTO servicio (ser_nombre, ser_descripcion, ser_costo, ser_fecha_hora_inicio, ser_fecha_hora_fin, ser_millas_otorgadas, ser_tipo, fk_prov_codigo) VALUES
-- 1. Alojamiento (Hotel Amazonas Gran, no es proveedor, usamos uno de 'Otros', código 46)
('Noche Hotel Std', 'Habitación Estándar', 90.00, '2025-12-20 14:00:00', '2025-12-21 12:00:00', 100, 'Alojamiento', 46),
-- 2. Vuelo (Aero Global, código 1)
('Vuelo Maiquetía-Barcelona', 'Clase Comfort con snack', 150.00, '2025-12-05 08:00:00', '2025-12-05 09:30:00', 300, 'Vuelo', 1),
-- 3. Actividad (Tour Guía Táchira, código 46)
('Tour Histórico', 'Recorrido a pie por San Cristóbal', 45.00, '2025-12-18 10:00:00', '2025-12-18 13:00:00', 50, 'Actividad', 46),
-- 4. Seguro (Otro Proveedor, código 46)
('Seguro Básico', 'Cobertura mínima por 5 días', 25.00, '2025-12-01 00:00:00', '2025-12-05 23:59:59', 10, 'Seguro', 46),
-- 5. Comida (Restaurante El Gourmet, no es proveedor, usamos uno de 'Otros', código 46)
('Cena Gourmet', 'Menú degustación para dos', 80.00, '2025-12-20 20:00:00', '2025-12-20 22:00:00', 80, 'Comida', 46),
-- 6. Transporte (Renta Auto Zulia, código 26)
('Alquiler SUV 1 día', 'SUV 4x4, kilometraje ilimitado', 110.00, '2025-12-10 09:00:00', '2025-12-11 09:00:00', 150, 'Terrestre', 26),
-- 7. Vuelo (Vuela Fácil, código 2)
('Vuelo Interno Económico', 'Vuelo corto, clase Práctico', 50.00, '2025-12-15 14:00:00', '2025-12-15 15:30:00', 150, 'Vuelo', 2),
-- 8. Actividad (Otro Proveedor, código 46)
('Entrada a Parque Nacional', 'Ticket de acceso y guía básico', 15.00, '2025-12-07 09:00:00', '2025-12-07 16:00:00', 20, 'Actividad', 46),
-- 9. Alojamiento (Hotel Playa Suites, código 46)
('Noche Hotel Suite', 'Suite con vista al mar', 150.00, '2025-12-22 14:00:00', '2025-12-23 12:00:00', 200, 'Alojamiento', 46),
-- 10. Marítimo (Ocean Dream Cruise, código 22)
('Excursión en Yate', '3 horas de navegación de lujo', 300.00, '2025-12-24 10:00:00', '2025-12-24 13:00:00', 400, 'Maritimo', 22);

-- 31. PAQUETE_TURISTICO (10 registros)
INSERT INTO paquete_turistico (paq_tur_nombre, paq_tur_monto_total, paq_tur_monto_subtotal, paq_tur_costo_en_millas, paq_tur_descripcion) VALUES
('Fin de Semana en Mérida', 450.00, 420.00, 15000, 'Incluye hotel y teleférico'),
('Ruta Aérea y Playa', 620.00, 600.00, 20000, 'Vuelo + 2 Noches en Barcelona'),
('Aventura Llanera', 780.00, 750.00, 25000, 'Hato, tour a caballo y comidas'),
('Crucero VIP Caribe', 3500.00, 3200.00, 100000, 'Todo incluido, 5 días/4 noches'),
('Escapada Romántica Valencia', 380.00, 350.00, 12000, 'Hotel 5 estrellas + Cena Gourmet'),
('Tour Histórico Coro', 290.00, 270.00, 9000, 'Transporte y guías turísticos'),
('Paquete Familiar Zulia', 550.00, 520.00, 18000, 'Alojamiento 3 días + alquiler de vehículo'),
('Viaje de Negocios Express', 200.00, 190.00, 6000, 'Vuelo ida y vuelta en el día'),
('Experiencia Gastronómica', 480.00, 450.00, 16000, 'Hoteles en 3 ciudades + reservas en restaurantes'),
('Buceo en Margarita', 850.00, 800.00, 28000, 'Vuelo, hotel y 2 inmersiones de buceo');

-- 32. COMPRA (96 registros: 1 compra por cliente)
-- Los fk_usuario son los clientes (del 1 al 48). Haremos 2 compras por cliente.

-- Generación de 96 compras: 
INSERT INTO compra (com_monto_total, com_monto_subtotal, com_fecha, fk_usuario, fk_plan_financiamiento) VALUES
-- Compras para Cliente 1 (Usuario 1: juan.perez.am)
(250.00, 240.00, '2025-12-01', 1, NULL),
(300.00, 280.00, '2025-12-01', 1, NULL),
-- Cliente 2 (Usuario 2: maria.rojas.am)
(500.00, 480.00, '2025-12-02', 2, NULL),
(180.00, 175.00, '2025-12-02', 2, NULL),
-- Cliente 3 (Usuario 3: carlos.gomez.an)
(350.00, 330.00, '2025-12-03', 3, NULL),
(400.00, 380.00, '2025-12-03', 3, NULL),
-- Cliente 4 (Usuario 4)
(600.00, 570.00, '2025-12-04', 4, NULL),
(220.00, 210.00, '2025-12-04', 4, NULL),
-- Cliente 5 (Usuario 5)
(150.00, 145.00, '2025-12-05', 5, NULL),
(450.00, 430.00, '2025-12-05', 5, NULL),
-- Cliente 6 (Usuario 6)
(700.00, 650.00, '2025-12-06', 6, NULL),
(190.00, 185.00, '2025-12-06', 6, NULL),
-- Cliente 7 (Usuario 7)
(320.00, 300.00, '2025-12-07', 7, NULL),
(550.00, 520.00, '2025-12-07', 7, NULL),
-- Cliente 8 (Usuario 8)
(280.00, 270.00, '2025-12-08', 8, NULL),
(420.00, 400.00, '2025-12-08', 8, NULL),
-- Cliente 9 (Usuario 9)
(160.00, 155.00, '2025-12-09', 9, NULL),
(680.00, 640.00, '2025-12-09', 9, NULL),
-- Cliente 10 (Usuario 10)
(310.00, 300.00, '2025-12-10', 10, NULL),
(520.00, 500.00, '2025-12-10', 10, NULL),
-- Cliente 11 (Usuario 11)
(240.00, 230.00, '2025-12-11', 11, NULL),
(360.00, 340.00, '2025-12-11', 11, NULL),
-- Cliente 12 (Usuario 12)
(480.00, 450.00, '2025-12-12', 12, NULL),
(200.00, 195.00, '2025-12-12', 12, NULL),
-- Cliente 13 (Usuario 13)
(330.00, 310.00, '2025-12-13', 13, NULL),
(470.00, 440.00, '2025-12-13', 13, NULL),
-- Cliente 14 (Usuario 14)
(610.00, 580.00, '2025-12-14', 14, NULL),
(230.00, 220.00, '2025-12-14', 14, NULL),
-- Cliente 15 (Usuario 15)
(170.00, 165.00, '2025-12-15', 15, NULL),
(460.00, 435.00, '2025-12-15', 15, NULL),
-- Cliente 16 (Usuario 16)
(720.00, 670.00, '2025-12-16', 16, NULL),
(210.00, 205.00, '2025-12-16', 16, NULL),
-- Cliente 17 (Usuario 17)
(340.00, 320.00, '2025-12-17', 17, NULL),
(570.00, 540.00, '2025-12-17', 17, NULL),
-- Cliente 18 (Usuario 18)
(290.00, 280.00, '2025-12-18', 18, NULL),
(430.00, 410.00, '2025-12-18', 18, NULL),
-- Cliente 19 (Usuario 19)
(180.00, 175.00, '2025-12-19', 19, NULL),
(690.00, 650.00, '2025-12-19', 19, NULL),
-- Cliente 20 (Usuario 20)
(300.00, 290.00, '2025-12-20', 20, NULL),
(510.00, 490.00, '2025-12-20', 20, NULL),
-- Cliente 21 (Usuario 21)
(260.00, 250.00, '2025-12-21', 21, NULL),
(370.00, 350.00, '2025-12-21', 21, NULL),
-- Cliente 22 (Usuario 22)
(490.00, 460.00, '2025-12-22', 22, NULL),
(220.00, 215.00, '2025-12-22', 22, NULL),
-- Cliente 23 (Usuario 23)
(350.00, 330.00, '2025-12-23', 23, NULL),
(480.00, 450.00, '2025-12-23', 23, NULL),
-- Cliente 24 (Usuario 24)
(620.00, 590.00, '2025-12-24', 24, NULL),
(240.00, 230.00, '2025-12-24', 24, NULL),
-- Cliente 25 (Usuario 25)
(190.00, 185.00, '2025-12-25', 25, NULL),
(470.00, 445.00, '2025-12-25', 25, NULL),
-- Cliente 26 (Usuario 26)
(730.00, 680.00, '2025-12-26', 26, NULL),
(230.00, 225.00, '2025-12-26', 26, NULL),
-- Cliente 27 (Usuario 27)
(360.00, 340.00, '2025-12-27', 27, NULL),
(580.00, 550.00, '2025-12-27', 27, NULL),
-- Cliente 28 (Usuario 28)
(300.00, 290.00, '2025-12-28', 28, NULL),
(440.00, 420.00, '2025-12-28', 28, NULL),
-- Cliente 29 (Usuario 29)
(200.00, 195.00, '2025-12-29', 29, NULL),
(700.00, 660.00, '2025-12-29', 29, NULL),
-- Cliente 30 (Usuario 30)
(320.00, 310.00, '2025-12-30', 30, NULL),
(530.00, 510.00, '2025-12-30', 30, NULL),
-- Cliente 31 (Usuario 31)
(270.00, 260.00, '2025-12-31', 31, NULL),
(380.00, 360.00, '2025-12-31', 31, NULL),
-- Cliente 32 (Usuario 32)
(500.00, 470.00, '2026-01-01', 32, NULL),
(230.00, 225.00, '2026-01-01', 32, NULL),
-- Cliente 33 (Usuario 33)
(370.00, 350.00, '2026-01-02', 33, NULL),
(490.00, 460.00, '2026-01-02', 33, NULL),
-- Cliente 34 (Usuario 34)
(630.00, 600.00, '2026-01-03', 34, NULL),
(250.00, 240.00, '2026-01-03', 34, NULL),
-- Cliente 35 (Usuario 35)
(200.00, 195.00, '2026-01-04', 35, NULL),
(480.00, 455.00, '2026-01-04', 35, NULL),
-- Cliente 36 (Usuario 36)
(740.00, 690.00, '2026-01-05', 36, NULL),
(240.00, 235.00, '2026-01-05', 36, NULL),
-- Cliente 37 (Usuario 37)
(380.00, 360.00, '2026-01-06', 37, NULL),
(590.00, 560.00, '2026-01-06', 37, NULL),
-- Cliente 38 (Usuario 38)
(310.00, 300.00, '2026-01-07', 38, NULL),
(450.00, 430.00, '2026-01-07', 38, NULL),
-- Cliente 39 (Usuario 39)
(210.00, 205.00, '2026-01-08', 39, NULL),
(710.00, 670.00, '2026-01-08', 39, NULL),
-- Cliente 40 (Usuario 40)
(330.00, 320.00, '2026-01-09', 40, NULL),
(540.00, 520.00, '2026-01-09', 40, NULL),
-- Cliente 41 (Usuario 41)
(280.00, 270.00, '2026-01-10', 41, NULL),
(390.00, 370.00, '2026-01-10', 41, NULL),
-- Cliente 42 (Usuario 42)
(510.00, 480.00, '2026-01-11', 42, NULL),
(240.00, 235.00, '2026-01-11', 42, NULL),
-- Cliente 43 (Usuario 43)
(380.00, 360.00, '2026-01-12', 43, NULL),
(500.00, 470.00, '2026-01-12', 43, NULL),
-- Cliente 44 (Usuario 44)
(640.00, 610.00, '2026-01-13', 44, NULL),
(260.00, 250.00, '2026-01-13', 44, NULL),
-- Cliente 45 (Usuario 45)
(210.00, 205.00, '2026-01-14', 45, NULL),
(490.00, 465.00, '2026-01-14', 45, NULL),
-- Cliente 46 (Usuario 46)
(750.00, 700.00, '2026-01-15', 46, NULL),
(250.00, 245.00, '2026-01-15', 46, NULL),
-- Cliente 47 (Usuario 47)
(390.00, 370.00, '2026-01-16', 47, NULL),
(600.00, 570.00, '2026-01-16', 47, NULL),
-- Cliente 48 (Usuario 48)
(320.00, 310.00, '2026-01-17', 48, NULL),
(460.00, 440.00, '2026-01-17', 48, NULL);

-- TRUNCATE TABLE detalle_reserva RESTART IDENTITY; -- Útil si ya se ejecutaron las inserciones anteriores

-- =========================================================
-- COMPRAS 1 - 48 (Viajeros 1 - 48)
-- Lógica: Vuelo (2 o 7) + Alojamiento/Actividad (1 o 3)
-- =========================================================

-- Cliente 1 (Usuario 1: Juan P.) - Compra 1 (Monto Total: 250.00) - Viajero 1 (Juan Jose)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-01', '10:00:00', 125.00, 120.00, 1, 1, 1, 2, 'Confirmada'), -- Vuelo Maiquetía-Barcelona (2)
(2, '2025-12-01', '10:05:00', 125.00, 120.00, 1, 1, 1, 1, 'Confirmada'); -- Noche Hotel Std (1)

-- Cliente 1 (Usuario 1: Juan P.) - Compra 2 (Monto Total: 300.00) - Viajero 2 (Manuel David)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-01', '10:00:00', 150.00, 140.00, 2, 1, 2, 7, 'Confirmada'), -- Vuelo Interno Económico (7)
(2, '2025-12-01', '10:05:00', 150.00, 140.00, 2, 1, 2, 3, 'Confirmada'); -- Tour Histórico (3)

-- Cliente 2 (Usuario 2: Maria R.) - Compra 3 (Monto Total: 500.00) - Viajero 3 (Maria Alejandra)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-02', '10:00:00', 250.00, 240.00, 3, 1, 3, 2, 'Confirmada'), -- Vuelo Maiquetía-Barcelona (2)
(2, '2025-12-02', '10:05:00', 250.00, 240.00, 3, 1, 3, 1, 'Confirmada'); -- Noche Hotel Std (1)

-- Cliente 2 (Usuario 2: Maria R.) - Compra 4 (Monto Total: 180.00) - Viajero 4 (Luisa Elena)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-02', '10:00:00', 90.00, 87.50, 4, 1, 4, 7, 'Confirmada'), -- Vuelo Interno Económico (7)
(2, '2025-12-02', '10:05:00', 90.00, 87.50, 4, 1, 4, 3, 'Confirmada'); -- Tour Histórico (3)

-- Cliente 3 (Usuario 3: Carlos G.) - Compra 5 (Monto Total: 350.00) - Viajero 5 (Carlos Alberto)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-03', '10:00:00', 175.00, 165.00, 5, 1, 5, 2, 'Confirmada'),
(2, '2025-12-03', '10:05:00', 175.00, 165.00, 5, 1, 5, 1, 'Confirmada');

-- Cliente 3 (Usuario 3: Carlos G.) - Compra 6 (Monto Total: 400.00) - Viajero 6 (Pedro Luis)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-03', '10:00:00', 200.00, 190.00, 6, 1, 6, 7, 'Confirmada'),
(2, '2025-12-03', '10:05:00', 200.00, 190.00, 6, 1, 6, 3, 'Confirmada');

-- Cliente 4 (Usuario 4: Ana L.) - Compra 7 (Monto Total: 600.00) - Viajero 7 (Ana Beatriz)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-04', '10:00:00', 300.00, 285.00, 7, 1, 7, 2, 'Confirmada'),
(2, '2025-12-04', '10:05:00', 300.00, 285.00, 7, 1, 7, 1, 'Confirmada');

-- Cliente 4 (Usuario 4: Ana L.) - Compra 8 (Monto Total: 220.00) - Viajero 8 (Elena Sofia)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-04', '10:00:00', 110.00, 105.00, 8, 1, 8, 7, 'Confirmada'),
(2, '2025-12-04', '10:05:00', 110.00, 105.00, 8, 1, 8, 3, 'Confirmada');

-- Cliente 5 (Usuario 5: Javier S.) - Compra 9 (Monto Total: 150.00) - Viajero 9 (Javier Andres)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-05', '10:00:00', 75.00, 72.50, 9, 1, 9, 2, 'Confirmada'),
(2, '2025-12-05', '10:05:00', 75.00, 72.50, 9, 1, 9, 1, 'Confirmada');

-- Cliente 5 (Usuario 5: Javier S.) - Compra 10 (Monto Total: 450.00) - Viajero 10 (Andres Felipe)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-05', '10:00:00', 225.00, 215.00, 10, 1, 10, 7, 'Confirmada'),
(2, '2025-12-05', '10:05:00', 225.00, 215.00, 10, 1, 10, 3, 'Confirmada');

-- Cliente 6 (Usuario 6: Rosa A.) - Compra 11 (Monto Total: 700.00) - Viajero 11 (Rosa Maria)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-06', '10:00:00', 350.00, 325.00, 11, 1, 11, 2, 'Confirmada'),
(2, '2025-12-06', '10:05:00', 350.00, 325.00, 11, 1, 11, 1, 'Confirmada');

-- Cliente 6 (Usuario 6: Rosa A.) - Compra 12 (Monto Total: 190.00) - Viajero 12 (Sofia Isabel)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-06', '10:00:00', 95.00, 92.50, 12, 1, 12, 7, 'Confirmada'),
(2, '2025-12-06', '10:05:00', 95.00, 92.50, 12, 1, 12, 3, 'Confirmada');

-- Cliente 7 (Usuario 7: Ricardo T.) - Compra 13 (Monto Total: 320.00) - Viajero 13 (Ricardo Jose)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-07', '10:00:00', 160.00, 150.00, 13, 1, 13, 2, 'Confirmada'),
(2, '2025-12-07', '10:05:00', 160.00, 150.00, 13, 1, 13, 1, 'Confirmada');

-- Cliente 7 (Usuario 7: Ricardo T.) - Compra 14 (Monto Total: 550.00) - Viajero 14 (Alejandro Gabriel)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-07', '10:00:00', 275.00, 260.00, 14, 1, 14, 7, 'Confirmada'),
(2, '2025-12-07', '10:05:00', 275.00, 260.00, 14, 1, 14, 3, 'Confirmada');

-- Cliente 8 (Usuario 8: Patricia S.) - Compra 15 (Monto Total: 280.00) - Viajero 15 (Patricia Carolina)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-08', '10:00:00', 140.00, 135.00, 15, 1, 15, 2, 'Confirmada'),
(2, '2025-12-08', '10:05:00', 140.00, 135.00, 15, 1, 15, 1, 'Confirmada');

-- Cliente 8 (Usuario 8: Patricia S.) - Compra 16 (Monto Total: 420.00) - Viajero 16 (Gabriela Maria)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-08', '10:00:00', 210.00, 200.00, 16, 1, 16, 7, 'Confirmada'),
(2, '2025-12-08', '10:05:00', 210.00, 200.00, 16, 1, 16, 3, 'Confirmada');

-- Cliente 9 (Usuario 9: Daniel H.) - Compra 17 (Monto Total: 160.00) - Viajero 17 (Daniel Ignacio)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-09', '10:00:00', 80.00, 77.50, 17, 1, 17, 2, 'Confirmada'),
(2, '2025-12-09', '10:05:00', 80.00, 77.50, 17, 1, 17, 1, 'Confirmada');

-- Cliente 9 (Usuario 9: Daniel H.) - Compra 18 (Monto Total: 680.00) - Viajero 18 (Jorge Elias)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-09', '10:00:00', 340.00, 320.00, 18, 1, 18, 7, 'Confirmada'),
(2, '2025-12-09', '10:05:00', 340.00, 320.00, 18, 1, 18, 3, 'Confirmada');

-- Cliente 10 (Usuario 10: Natalia G.) - Compra 19 (Monto Total: 310.00) - Viajero 19 (Natalia Victoria)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-10', '10:00:00', 155.00, 150.00, 19, 1, 19, 2, 'Confirmada'),
(2, '2025-12-10', '10:05:00', 155.00, 150.00, 19, 1, 19, 1, 'Confirmada');

-- Cliente 10 (Usuario 10: Natalia G.) - Compra 20 (Monto Total: 520.00) - Viajero 20 (Adriana Lucia)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-10', '10:00:00', 260.00, 250.00, 20, 1, 20, 7, 'Confirmada'),
(2, '2025-12-10', '10:05:00', 260.00, 250.00, 20, 1, 20, 3, 'Confirmada');

-- Cliente 11 (Usuario 11: Miguel A.) - Compra 21 (Monto Total: 240.00) - Viajero 21 (Miguel Angel)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-11', '10:00:00', 120.00, 115.00, 21, 1, 21, 2, 'Confirmada'),
(2, '2025-12-11', '10:05:00', 120.00, 115.00, 21, 1, 21, 1, 'Confirmada');

-- Cliente 11 (Usuario 11: Miguel A.) - Compra 22 (Monto Total: 360.00) - Viajero 22 (Felix Eduardo)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-11', '10:00:00', 180.00, 170.00, 22, 1, 22, 7, 'Confirmada'),
(2, '2025-12-11', '10:05:00', 180.00, 170.00, 22, 1, 22, 3, 'Confirmada');

-- Cliente 12 (Usuario 12: Veronica S.) - Compra 23 (Monto Total: 480.00) - Viajero 23 (Veronica Paz)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-12', '10:00:00', 240.00, 225.00, 23, 1, 23, 2, 'Confirmada'),
(2, '2025-12-12', '10:05:00', 240.00, 225.00, 23, 1, 23, 1, 'Confirmada');

-- Cliente 12 (Usuario 12: Veronica S.) - Compra 24 (Monto Total: 200.00) - Viajero 24 (Marisol De Jesus)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-12', '10:00:00', 100.00, 97.50, 24, 1, 24, 7, 'Confirmada'),
(2, '2025-12-12', '10:05:00', 100.00, 97.50, 24, 1, 24, 3, 'Confirmada');

-- Cliente 13 (Usuario 13: Hector M.) - Compra 25 (Monto Total: 330.00) - Viajero 25 (Hector Luis)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-13', '10:00:00', 165.00, 155.00, 25, 1, 25, 2, 'Confirmada'),
(2, '2025-12-13', '10:05:00', 165.00, 155.00, 25, 1, 25, 1, 'Confirmada');

-- Cliente 13 (Usuario 13: Hector M.) - Compra 26 (Monto Total: 470.00) - Viajero 26 (Oscar Jose)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-13', '10:00:00', 235.00, 220.00, 26, 1, 26, 7, 'Confirmada'),
(2, '2025-12-13', '10:05:00', 235.00, 220.00, 26, 1, 26, 3, 'Confirmada');

-- Cliente 14 (Usuario 14: Claudia F.) - Compra 27 (Monto Total: 610.00) - Viajero 27 (Claudia Patricia)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-14', '10:00:00', 305.00, 290.00, 27, 1, 27, 2, 'Confirmada'),
(2, '2025-12-14', '10:05:00', 305.00, 290.00, 27, 1, 27, 1, 'Confirmada');

-- Cliente 14 (Usuario 14: Claudia F.) - Compra 28 (Monto Total: 230.00) - Viajero 28 (Karla Genesis)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-14', '10:00:00', 115.00, 110.00, 28, 1, 28, 7, 'Confirmada'),
(2, '2025-12-14', '10:05:00', 115.00, 110.00, 28, 1, 28, 3, 'Confirmada');

-- Cliente 15 (Usuario 15: Raul V.) - Compra 29 (Monto Total: 170.00) - Viajero 29 (Raul Enrique)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-15', '10:00:00', 85.00, 82.50, 29, 1, 29, 2, 'Confirmada'),
(2, '2025-12-15', '10:05:00', 85.00, 82.50, 29, 1, 29, 1, 'Confirmada');

-- Cliente 15 (Usuario 15: Raul V.) - Compra 30 (Monto Total: 460.00) - Viajero 30 (Sergio David)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-15', '10:00:00', 230.00, 217.50, 30, 1, 30, 7, 'Confirmada'),
(2, '2025-12-15', '10:05:00', 230.00, 217.50, 30, 1, 30, 3, 'Confirmada');

-- Cliente 16 (Usuario 16: Diana P.) - Compra 31 (Monto Total: 720.00) - Viajero 31 (Diana Carolina)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-16', '10:00:00', 360.00, 335.00, 31, 1, 31, 2, 'Confirmada'),
(2, '2025-12-16', '10:05:00', 360.00, 335.00, 31, 1, 31, 1, 'Confirmada');

-- Cliente 16 (Usuario 16: Diana P.) - Compra 32 (Monto Total: 210.00) - Viajero 32 (Viviana Alexandra)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-16', '10:00:00', 105.00, 102.50, 32, 1, 32, 7, 'Confirmada'),
(2, '2025-12-16', '10:05:00', 105.00, 102.50, 32, 1, 32, 3, 'Confirmada');

-- Cliente 17 (Usuario 17: Emilio S.) - Compra 33 (Monto Total: 340.00) - Viajero 33 (Emilio Rafael)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-17', '10:00:00', 170.00, 160.00, 33, 1, 33, 2, 'Confirmada'),
(2, '2025-12-17', '10:05:00', 170.00, 160.00, 33, 1, 33, 1, 'Confirmada');

-- Cliente 17 (Usuario 17: Emilio S.) - Compra 34 (Monto Total: 570.00) - Viajero 34 (Gregorio Jesus)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-17', '10:00:00', 285.00, 270.00, 34, 1, 34, 7, 'Confirmada'),
(2, '2025-12-17', '10:05:00', 285.00, 270.00, 34, 1, 34, 3, 'Confirmada');

-- Cliente 18 (Usuario 18: Isabel R.) - Compra 35 (Monto Total: 290.00) - Viajero 35 (Isabel Cristina)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-18', '10:00:00', 145.00, 140.00, 35, 1, 35, 2, 'Confirmada'),
(2, '2025-12-18', '10:05:00', 145.00, 140.00, 35, 1, 35, 1, 'Confirmada');

-- Cliente 18 (Usuario 18: Isabel R.) - Compra 36 (Monto Total: 430.00) - Viajero 36 (Lorena Fabiola)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-18', '10:00:00', 215.00, 205.00, 36, 1, 36, 7, 'Confirmada'),
(2, '2025-12-18', '10:05:00', 215.00, 205.00, 36, 1, 36, 3, 'Confirmada');

-- Cliente 19 (Usuario 19: Roberto D.) - Compra 37 (Monto Total: 180.00) - Viajero 37 (Roberto Antonio)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-19', '10:00:00', 90.00, 87.50, 37, 1, 37, 2, 'Confirmada'),
(2, '2025-12-19', '10:05:00', 90.00, 87.50, 37, 1, 37, 1, 'Confirmada');

-- Cliente 19 (Usuario 19: Roberto D.) - Compra 38 (Monto Total: 690.00) - Viajero 38 (Alfonso Simon)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-19', '10:00:00', 345.00, 325.00, 38, 1, 38, 7, 'Confirmada'),
(2, '2025-12-19', '10:05:00', 345.00, 325.00, 38, 1, 38, 3, 'Confirmada');

-- Cliente 20 (Usuario 20: Cecilia M.) - Compra 39 (Monto Total: 300.00) - Viajero 39 (Cecilia Gabriela)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-20', '10:00:00', 150.00, 145.00, 39, 1, 39, 2, 'Confirmada'),
(2, '2025-12-20', '10:05:00', 150.00, 145.00, 39, 1, 39, 1, 'Confirmada');

-- Cliente 20 (Usuario 20: Cecilia M.) - Compra 40 (Monto Total: 510.00) - Viajero 40 (Marta Liliana)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-20', '10:00:00', 255.00, 245.00, 40, 1, 40, 7, 'Confirmada'),
(2, '2025-12-20', '10:05:00', 255.00, 245.00, 40, 1, 40, 3, 'Confirmada');

-- Cliente 21 (Usuario 21: Ernesto S.) - Compra 41 (Monto Total: 260.00) - Viajero 41 (Ernesto Alejandro)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-21', '10:00:00', 130.00, 125.00, 41, 1, 41, 2, 'Confirmada'),
(2, '2025-12-21', '10:05:00', 130.00, 125.00, 41, 1, 41, 1, 'Confirmada');

-- Cliente 21 (Usuario 21: Ernesto S.) - Compra 42 (Monto Total: 370.00) - Viajero 42 (Ignacio Luis)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-21', '10:00:00', 185.00, 175.00, 42, 1, 42, 7, 'Confirmada'),
(2, '2025-12-21', '10:05:00', 185.00, 175.00, 42, 1, 42, 3, 'Confirmada');

-- Cliente 22 (Usuario 22: Paola C.) - Compra 43 (Monto Total: 490.00) - Viajero 43 (Paola Andreina)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-22', '10:00:00', 245.00, 230.00, 43, 1, 43, 2, 'Confirmada'),
(2, '2025-12-22', '10:05:00', 245.00, 230.00, 43, 1, 43, 1, 'Confirmada');

-- Cliente 22 (Usuario 22: Paola C.) - Compra 44 (Monto Total: 220.00) - Viajero 44 (Monica Estefania)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-22', '10:00:00', 110.00, 107.50, 44, 1, 44, 7, 'Confirmada'),
(2, '2025-12-22', '10:05:00', 110.00, 107.50, 44, 1, 44, 3, 'Confirmada');

-- Cliente 23 (Usuario 23: Javier M.) - Compra 45 (Monto Total: 350.00) - Viajero 45 (Javier Alfredo)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-23', '10:00:00', 175.00, 165.00, 45, 1, 45, 2, 'Confirmada'),
(2, '2025-12-23', '10:05:00', 175.00, 165.00, 45, 1, 45, 1, 'Confirmada');

-- Cliente 23 (Usuario 23: Javier M.) - Compra 46 (Monto Total: 480.00) - Viajero 46 (Oswaldo Manuel)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-23', '10:00:00', 240.00, 225.00, 46, 1, 46, 7, 'Confirmada'),
(2, '2025-12-23', '10:05:00', 240.00, 225.00, 46, 1, 46, 3, 'Confirmada');

-- Cliente 24 (Usuario 24: Valentina F.) - Compra 47 (Monto Total: 620.00) - Viajero 47 (Valentina Victoria)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-24', '10:00:00', 310.00, 295.00, 47, 1, 47, 2, 'Confirmada'),
(2, '2025-12-24', '10:05:00', 310.00, 295.00, 47, 1, 47, 1, 'Confirmada');

-- Cliente 24 (Usuario 24: Valentina F.) - Compra 48 (Monto Total: 240.00) - Viajero 48 (Eugenia Teresa)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-24', '10:00:00', 120.00, 115.00, 48, 1, 48, 7, 'Confirmada'),
(2, '2025-12-24', '10:05:00', 120.00, 115.00, 48, 1, 48, 3, 'Confirmada');

-- =========================================================
-- COMPRAS 49 - 96 (Viajeros 49 - 96)
-- Lógica: Vuelo/Comida (7 o 5) + Seguro/Alojamiento (4 o 9)
-- =========================================================

-- Cliente 25 (Usuario 25: Juan P.) - Compra 49 (Monto Total: 190.00) - Viajero 49 (Raul Camilo)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-25', '11:00:00', 95.00, 92.50, 49, 2, 49, 7, 'Confirmada'), -- Vuelo Interno Económico (7)
(2, '2025-12-25', '11:05:00', 95.00, 92.50, 49, 2, 49, 4, 'Confirmada'); -- Seguro Básico (4)

-- Cliente 25 (Usuario 25: Juan P.) - Compra 50 (Monto Total: 470.00) - Viajero 50 (Ana Luisa)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-25', '11:00:00', 235.00, 222.50, 50, 2, 50, 5, 'Confirmada'), -- Cena Gourmet (5)
(2, '2025-12-25', '11:05:00', 235.00, 222.50, 50, 2, 50, 9, 'Confirmada'); -- Noche Hotel Suite (9)

-- Cliente 26 (Usuario 26: Maria R.) - Compra 51 (Monto Total: 730.00) - Viajero 51 (Gustavo Adolfo)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-26', '11:00:00', 365.00, 340.00, 51, 2, 51, 7, 'Confirmada'),
(2, '2025-12-26', '11:05:00', 365.00, 340.00, 51, 2, 51, 4, 'Confirmada');

-- Cliente 26 (Usuario 26: Maria R.) - Compra 52 (Monto Total: 230.00) - Viajero 52 (Andrea Carolina)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-26', '11:00:00', 115.00, 112.50, 52, 2, 52, 5, 'Confirmada'),
(2, '2025-12-26', '11:05:00', 115.00, 112.50, 52, 2, 52, 9, 'Confirmada');

-- Cliente 27 (Usuario 27: Carlos G.) - Compra 53 (Monto Total: 360.00) - Viajero 53 (Jorge Ignacio)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-27', '11:00:00', 180.00, 170.00, 53, 2, 53, 7, 'Confirmada'),
(2, '2025-12-27', '11:05:00', 180.00, 170.00, 53, 2, 53, 4, 'Confirmada');

-- Cliente 27 (Usuario 27: Carlos G.) - Compra 54 (Monto Total: 580.00) - Viajero 54 (Mariana Estrella)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-27', '11:00:00', 290.00, 275.00, 54, 2, 54, 5, 'Confirmada'),
(2, '2025-12-27', '11:05:00', 290.00, 275.00, 54, 2, 54, 9, 'Confirmada');

-- Cliente 28 (Usuario 28: Ana L.) - Compra 55 (Monto Total: 300.00) - Viajero 55 (Pablo Jesus)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-28', '11:00:00', 150.00, 145.00, 55, 2, 55, 7, 'Confirmada'),
(2, '2025-12-28', '11:05:00', 150.00, 145.00, 55, 2, 55, 4, 'Confirmada');

-- Cliente 28 (Usuario 28: Ana L.) - Compra 56 (Monto Total: 440.00) - Viajero 56 (Laura Maria)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-28', '11:00:00', 220.00, 210.00, 56, 2, 56, 5, 'Confirmada'),
(2, '2025-12-28', '11:05:00', 220.00, 210.00, 56, 2, 56, 9, 'Confirmada');

-- Cliente 29 (Usuario 29: Javier S.) - Compra 57 (Monto Total: 200.00) - Viajero 57 (Francisco Javier)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-29', '11:00:00', 100.00, 97.50, 57, 2, 57, 7, 'Confirmada'),
(2, '2025-12-29', '11:05:00', 100.00, 97.50, 57, 2, 57, 4, 'Confirmada');

-- Cliente 29 (Usuario 29: Javier S.) - Compra 58 (Monto Total: 700.00) - Viajero 58 (Veronica Luz)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-29', '11:00:00', 350.00, 330.00, 58, 2, 58, 5, 'Confirmada'),
(2, '2025-12-29', '11:05:00', 350.00, 330.00, 58, 2, 58, 9, 'Confirmada');

-- Cliente 30 (Usuario 30: Rosa A.) - Compra 59 (Monto Total: 320.00) - Viajero 59 (Angel David)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-30', '11:00:00', 160.00, 155.00, 59, 2, 59, 7, 'Confirmada'),
(2, '2025-12-30', '11:05:00', 160.00, 155.00, 59, 2, 59, 4, 'Confirmada');

-- Cliente 30 (Usuario 30: Rosa A.) - Compra 60 (Monto Total: 530.00) - Viajero 60 (Silvia Corina)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-30', '11:00:00', 265.00, 255.00, 60, 2, 60, 5, 'Confirmada'),
(2, '2025-12-30', '11:05:00', 265.00, 255.00, 60, 2, 60, 9, 'Confirmada');

-- Cliente 31 (Usuario 31: Ricardo T.) - Compra 61 (Monto Total: 270.00) - Viajero 61 (Jesus Alberto)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-31', '11:00:00', 135.00, 130.00, 61, 2, 61, 7, 'Confirmada'),
(2, '2025-12-31', '11:05:00', 135.00, 130.00, 61, 2, 61, 4, 'Confirmada');

-- Cliente 31 (Usuario 31: Ricardo T.) - Compra 62 (Monto Total: 380.00) - Viajero 62 (Marcia Andreina)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2025-12-31', '11:00:00', 190.00, 180.00, 62, 2, 62, 5, 'Confirmada'),
(2, '2025-12-31', '11:05:00', 190.00, 180.00, 62, 2, 62, 9, 'Confirmada');

-- Cliente 32 (Usuario 32: Patricia S.) - Compra 63 (Monto Total: 500.00) - Viajero 63 (Luis Manuel)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-01', '11:00:00', 250.00, 235.00, 63, 2, 63, 7, 'Confirmada'),
(2, '2026-01-01', '11:05:00', 250.00, 235.00, 63, 2, 63, 4, 'Confirmada');

-- Cliente 32 (Usuario 32: Patricia S.) - Compra 64 (Monto Total: 230.00) - Viajero 64 (Cindy Vanessa)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-01', '11:00:00', 115.00, 112.50, 64, 2, 64, 5, 'Confirmada'),
(2, '2026-01-01', '11:05:00', 115.00, 112.50, 64, 2, 64, 9, 'Confirmada');

-- Cliente 33 (Usuario 33: Daniel H.) - Compra 65 (Monto Total: 370.00) - Viajero 65 (Manuel Ricardo)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-02', '11:00:00', 185.00, 175.00, 65, 2, 65, 7, 'Confirmada'),
(2, '2026-01-02', '11:05:00', 185.00, 175.00, 65, 2, 65, 4, 'Confirmada');

-- Cliente 33 (Usuario 33: Daniel H.) - Compra 66 (Monto Total: 490.00) - Viajero 66 (Daniela Carolina)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-02', '11:00:00', 245.00, 230.00, 66, 2, 66, 5, 'Confirmada'),
(2, '2026-01-02', '11:05:00', 245.00, 230.00, 66, 2, 66, 9, 'Confirmada');

-- Cliente 34 (Usuario 34: Natalia G.) - Compra 67 (Monto Total: 630.00) - Viajero 67 (Rafael Antonio)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-03', '11:00:00', 315.00, 300.00, 67, 2, 67, 7, 'Confirmada'),
(2, '2026-01-03', '11:05:00', 315.00, 300.00, 67, 2, 67, 4, 'Confirmada');

-- Cliente 34 (Usuario 34: Natalia G.) - Compra 68 (Monto Total: 250.00) - Viajero 68 (Erika Yusmary)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-03', '11:00:00', 125.00, 120.00, 68, 2, 68, 5, 'Confirmada'),
(2, '2026-01-03', '11:05:00', 125.00, 120.00, 68, 2, 68, 9, 'Confirmada');

-- Cliente 35 (Usuario 35: Miguel A.) - Compra 69 (Monto Total: 200.00) - Viajero 69 (Guillermo Enrique)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-04', '11:00:00', 100.00, 97.50, 69, 2, 69, 7, 'Confirmada'),
(2, '2026-01-04', '11:05:00', 100.00, 97.50, 69, 2, 69, 4, 'Confirmada');

-- Cliente 35 (Usuario 35: Miguel A.) - Compra 70 (Monto Total: 480.00) - Viajero 70 (Diana Lucia)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-04', '11:00:00', 240.00, 227.50, 70, 2, 70, 5, 'Confirmada'),
(2, '2026-01-04', '11:05:00', 240.00, 227.50, 70, 2, 70, 9, 'Confirmada');

-- Cliente 36 (Usuario 36: Veronica S.) - Compra 71 (Monto Total: 740.00) - Viajero 71 (Humberto Jose)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-05', '11:00:00', 370.00, 345.00, 71, 2, 71, 7, 'Confirmada'),
(2, '2026-01-05', '11:05:00', 370.00, 345.00, 71, 2, 71, 4, 'Confirmada');

-- Cliente 36 (Usuario 36: Veronica S.) - Compra 72 (Monto Total: 240.00) - Viajero 72 (Jenifer Karina)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-05', '11:00:00', 120.00, 117.50, 72, 2, 72, 5, 'Confirmada'),
(2, '2026-01-05', '11:05:00', 120.00, 117.50, 72, 2, 72, 9, 'Confirmada');

-- Cliente 37 (Usuario 37: Hector M.) - Compra 73 (Monto Total: 380.00) - Viajero 73 (Jonathan Daniel)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-06', '11:00:00', 190.00, 180.00, 73, 2, 73, 7, 'Confirmada'),
(2, '2026-01-06', '11:05:00', 190.00, 180.00, 73, 2, 73, 4, 'Confirmada');

-- Cliente 37 (Usuario 37: Hector M.) - Compra 74 (Monto Total: 590.00) - Viajero 74 (Valeria Sofia)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-06', '11:00:00', 295.00, 280.00, 74, 2, 74, 5, 'Confirmada'),
(2, '2026-01-06', '11:05:00', 295.00, 280.00, 74, 2, 74, 9, 'Confirmada');

-- Cliente 38 (Usuario 38: Patricia S.) - Compra 75 (Monto Total: 310.00) - Viajero 75 (Franklin Javier)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-07', '11:00:00', 155.00, 150.00, 75, 2, 75, 7, 'Confirmada'),
(2, '2026-01-07', '11:05:00', 155.00, 150.00, 75, 2, 75, 4, 'Confirmada');

-- Cliente 38 (Usuario 38: Patricia S.) - Compra 76 (Monto Total: 450.00) - Viajero 76 (Vanessa Paola)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-07', '11:00:00', 225.00, 215.00, 76, 2, 76, 5, 'Confirmada'),
(2, '2026-01-07', '11:05:00', 225.00, 215.00, 76, 2, 76, 9, 'Confirmada');

-- Cliente 39 (Usuario 39: Daniel H.) - Compra 77 (Monto Total: 210.00) - Viajero 77 (Simón Bolívar)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-08', '11:00:00', 105.00, 102.50, 77, 2, 77, 7, 'Confirmada'),
(2, '2026-01-08', '11:05:00', 105.00, 102.50, 77, 2, 77, 4, 'Confirmada');

-- Cliente 39 (Usuario 39: Daniel H.) - Compra 78 (Monto Total: 710.00) - Viajero 78 (Rebeca Milagros)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-08', '11:00:00', 355.00, 335.00, 78, 2, 78, 5, 'Confirmada'),
(2, '2026-01-08', '11:05:00', 355.00, 335.00, 78, 2, 78, 9, 'Confirmada');

-- Cliente 40 (Usuario 40: Cecilia M.) - Compra 79 (Monto Total: 330.00) - Viajero 79 (Alberto Jose)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-09', '11:00:00', 165.00, 160.00, 79, 2, 79, 7, 'Confirmada'),
(2, '2026-01-09', '11:05:00', 165.00, 160.00, 79, 2, 79, 4, 'Confirmada');

-- Cliente 40 (Usuario 40: Cecilia M.) - Compra 80 (Monto Total: 540.00) - Viajero 80 (Alejandra Maria)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-09', '11:00:00', 270.00, 260.00, 80, 2, 80, 5, 'Confirmada'),
(2, '2026-01-09', '11:05:00', 270.00, 260.00, 80, 2, 80, 9, 'Confirmada');

-- Cliente 41 (Usuario 41: Ernesto S.) - Compra 81 (Monto Total: 280.00) - Viajero 81 (Jairo Alfonso)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-10', '11:00:00', 140.00, 135.00, 81, 2, 81, 7, 'Confirmada'),
(2, '2026-01-10', '11:05:00', 140.00, 135.00, 81, 2, 81, 4, 'Confirmada');

-- Cliente 41 (Usuario 41: Ernesto S.) - Compra 82 (Monto Total: 390.00) - Viajero 82 (Yelitza Andreina)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-10', '11:00:00', 195.00, 185.00, 82, 2, 82, 5, 'Confirmada'),
(2, '2026-01-10', '11:05:00', 195.00, 185.00, 82, 2, 82, 9, 'Confirmada');

-- Cliente 42 (Usuario 42: Paola C.) - Compra 83 (Monto Total: 510.00) - Viajero 83 (Hilda Marina)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-11', '11:00:00', 255.00, 240.00, 83, 2, 83, 7, 'Confirmada'),
(2, '2026-01-11', '11:05:00', 255.00, 240.00, 83, 2, 83, 4, 'Confirmada');

-- Cliente 42 (Usuario 42: Paola C.) - Compra 84 (Monto Total: 240.00) - Viajero 84 (Samuel Elias)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-11', '11:00:00', 120.00, 117.50, 84, 2, 84, 5, 'Confirmada'),
(2, '2026-01-11', '11:05:00', 120.00, 117.50, 84, 2, 84, 9, 'Confirmada');

-- Cliente 43 (Usuario 43: Javier M.) - Compra 85 (Monto Total: 380.00) - Viajero 85 (Elias Jose)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-12', '11:00:00', 190.00, 180.00, 85, 2, 85, 7, 'Confirmada'),
(2, '2026-01-12', '11:05:00', 190.00, 180.00, 85, 2, 85, 4, 'Confirmada');

-- Cliente 43 (Usuario 43: Javier M.) - Compra 86 (Monto Total: 500.00) - Viajero 86 (Carmen Elena)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-12', '11:00:00', 250.00, 235.00, 86, 2, 86, 5, 'Confirmada'),
(2, '2026-01-12', '11:05:00', 250.00, 235.00, 86, 2, 86, 9, 'Confirmada');

-- Cliente 44 (Usuario 44: Valentina F.) - Compra 87 (Monto Total: 640.00) - Viajero 87 (Fanny Carolina)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-13', '11:00:00', 320.00, 305.00, 87, 2, 87, 7, 'Confirmada'),
(2, '2026-01-13', '11:05:00', 320.00, 305.00, 87, 2, 87, 4, 'Confirmada');

-- Cliente 44 (Usuario 44: Valentina F.) - Compra 88 (Monto Total: 260.00) - Viajero 88 (Hector Luis)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-13', '11:00:00', 130.00, 125.00, 88, 2, 88, 5, 'Confirmada'),
(2, '2026-01-13', '11:05:00', 130.00, 125.00, 88, 2, 88, 9, 'Confirmada');

-- Cliente 45 (Usuario 45: Juan P.) - Compra 89 (Monto Total: 210.00) - Viajero 89 (Victor Manuel)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-14', '11:00:00', 105.00, 102.50, 89, 2, 89, 7, 'Confirmada'),
(2, '2026-01-14', '11:05:00', 105.00, 102.50, 89, 2, 89, 4, 'Confirmada');

-- Cliente 45 (Usuario 45: Juan P.) - Compra 90 (Monto Total: 490.00) - Viajero 90 (Laura Cristina)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-14', '11:00:00', 245.00, 232.50, 90, 2, 90, 5, 'Confirmada'),
(2, '2026-01-14', '11:05:00', 245.00, 232.50, 90, 2, 90, 9, 'Confirmada');

-- Cliente 46 (Usuario 46: Veronica S.) - Compra 91 (Monto Total: 750.00) - Viajero 91 (Julio Cesar)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-15', '11:00:00', 375.00, 350.00, 91, 2, 91, 7, 'Confirmada'),
(2, '2026-01-15', '11:05:00', 375.00, 350.00, 91, 2, 91, 4, 'Confirmada');

-- Cliente 46 (Usuario 46: Veronica S.) - Compra 92 (Monto Total: 250.00) - Viajero 92 (Esther Sofia)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-15', '11:00:00', 125.00, 122.50, 92, 2, 92, 5, 'Confirmada'),
(2, '2026-01-15', '11:05:00', 125.00, 122.50, 92, 2, 92, 9, 'Confirmada');

-- Cliente 47 (Usuario 47: Hector M.) - Compra 93 (Monto Total: 390.00) - Viajero 93 (Carlos Eduardo)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-16', '11:00:00', 195.00, 185.00, 93, 2, 93, 7, 'Confirmada'),
(2, '2026-01-16', '11:05:00', 195.00, 185.00, 93, 2, 93, 4, 'Confirmada');

-- Cliente 47 (Usuario 47: Hector M.) - Compra 94 (Monto Total: 600.00) - Viajero 94 (Alicia Beatriz)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-16', '11:00:00', 300.00, 285.00, 94, 2, 94, 5, 'Confirmada'),
(2, '2026-01-16', '11:05:00', 300.00, 285.00, 94, 2, 94, 9, 'Confirmada');

-- Cliente 48 (Usuario 48: Valentina F.) - Compra 95 (Monto Total: 320.00) - Viajero 95 (Andrea Veronica)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-17', '11:00:00', 160.00, 155.00, 95, 2, 95, 7, 'Confirmada'),
(2, '2026-01-17', '11:05:00', 160.00, 155.00, 95, 2, 95, 4, 'Confirmada');

-- Cliente 48 (Usuario 48: Valentina F.) - Compra 96 (Monto Total: 460.00) - Viajero 96 (Reinaldo Jesus)
INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado) VALUES
(1, '2026-01-17', '11:00:00', 230.00, 220.00, 96, 2, 96, 5, 'Confirmada'),
(2, '2026-01-17', '11:05:00', 230.00, 220.00, 96, 2, 96, 9, 'Confirmada');

INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago)
SELECT
    c.com_monto_total,
    c.com_fecha::TIMESTAMP + '1 hour'::INTERVAL,
    'USD', -- La denominación de pago (asumimos que la compra se cotizó en USD)
    c.com_codigo,
    7, -- Usaremos la Tasa 7 (USD, 45.00) como referencia para todas las compras.
    CASE
        WHEN c.com_codigo % 10 = 1 THEN 1 -- Tarjeta de Crédito
        WHEN c.com_codigo % 10 = 2 THEN 2 -- Tarjeta de Débito
        WHEN c.com_codigo % 10 = 3 THEN 5 -- Transferencia Bancaria
        WHEN c.com_codigo % 10 = 4 THEN 8 -- Zelle
        WHEN c.com_codigo % 10 = 5 THEN 7 -- Criptomoneda
        WHEN c.com_codigo % 10 = 6 THEN 1 -- Tarjeta de Crédito
        WHEN c.com_codigo % 10 = 7 THEN 9 -- Efectivo
        WHEN c.com_codigo % 10 = 8 THEN 4 -- Depósito Bancario
        WHEN c.com_codigo % 10 = 9 THEN 10 -- Millas
        ELSE 6 -- Pago Móvil Interbancario
    END
FROM compra c;

-- 37. TARJETA_CREDITO (fk_metodo_pago = 1)
INSERT INTO tarjeta_credito (met_pago_codigo, tar_cre_numero, tar_cre_cvv, tar_cre_fecha_vencimiento, tar_cre_banco_emisor, tar_cre_nombre_titular) VALUES
(1, '456712340001', '123', '2028-10-30', 'Banco Global', 'Juan Perez'),
(6, '456712340006', '654', '2029-05-15', 'Banco Aventura', 'Maria Rojas');

-- 38. TARJETA_DEBITO (fk_metodo_pago = 2)
INSERT INTO tarjeta_debito (met_pago_codigo, tar_deb_numero, tar_deb_cvv, tar_deb_fecha_vencimiento, tar_deb_banco_emisor, tar_deb_nombre_titular) VALUES
(2, '543298760002', '321', '2027-12-31', 'Banco Nacional', 'Carlos Gomez');

-- 39. TRANSFERENCIA_BANCARIA (fk_metodo_pago = 5)
INSERT INTO transferencia_bancaria (met_pago_codigo, trans_ban_numero_referencia, trans_ban_fecha_hora, tras_ban_numero_cuenta_emisora) VALUES
(5, 555001, '2025-12-03 15:30:00', '0101-1234-5678');

-- 40. PAGO_MOVIL_INTERBANCARIO (fk_metodo_pago = 6)
INSERT INTO pago_movil_interbancario (met_pago_codigo, pag_movil_int_numero_referencia, pag_movil_int_fecha_hora) VALUES
(7, 'PM12345678', '2025-12-07 11:45:00');

-- 41. CRIPTOMONEDA (fk_metodo_pago = 7)
INSERT INTO criptomoneda (met_pago_codigo, cri_hash_transaccion, cri_direccion_billetera_emisora) VALUES
(4, '0xABC123DEF456', 'WALLET001ABC');

-- 42. ZELLE (fk_metodo_pago = 8)
INSERT INTO zelle (met_pago_codigo, zel_titular_cuenta, zel_correo_electronico, zel_codigo_transaccion) VALUES
(8, 'Pedro Diaz', 'pedro.diaz@mail.com', 'ZEL999888');

-- 43. EFECTIVO (fk_metodo_pago = 9)
INSERT INTO efectivo (met_pago_codigo, efe_moneda, efe_codigo) VALUES
(9, 'VEF', 'CASH001');

-- 44. MILLA_PAGO (fk_metodo_pago = 10)

-- 45. PLAN_FINANCIAMIENTO (10 registros, asociados a compras 1, 10, 20, 30, 40, 50, 60, 70, 80, 90)
INSERT INTO plan_financiamiento (plan_fin_tasa_interes, plan_fin_numero_cuotas, plan_fin_inicial, fk_compra) VALUES
(5.00, 3, 50.00, 1),
(8.00, 6, 100.00, 10),
(10.00, 12, 0.00, 20),
(6.50, 4, 80.00, 30),
(7.00, 3, 150.00, 40),
(9.00, 6, 0.00, 50),
(5.50, 12, 10.00, 60),
(7.50, 4, 60.00, 70),
(8.50, 3, 120.00, 80),
(6.00, 6, 90.00, 90);

-- 46. CUOTA (10 registros, asociados a los 3 primeros planes de financiamiento)
INSERT INTO cuota (cuo_monto, cuo_fecha_tope, fk_plan_financiamiento) VALUES
(66.67, '2026-02-01', 1), -- Plan 1, Cuota 1/3
(66.67, '2026-03-01', 1), -- Plan 1, Cuota 2/3
(66.66, '2026-04-01', 1), -- Plan 1, Cuota 3/3
(50.00, '2026-01-05', 2), -- Plan 2, Cuota 1/6
(50.00, '2026-02-05', 2),
(50.00, '2026-03-05', 2),
(33.33, '2026-01-20', 3), -- Plan 3, Cuota 1/12
(33.33, '2026-02-20', 3),
(33.33, '2026-03-20', 3),
(33.33, '2026-04-20', 3);

-- 47. COMPENSACION (10 registros, asociados a compras 2, 4, 6, 8, 10, 12, 14, 16, 18, 20)
INSERT INTO compensacion (com_co2_compensado, com_monto_agregado, fk_compra) VALUES
(2.00, 10.00, 2),
(1.50, 7.50, 4),
(3.00, 15.00, 6),
(2.50, 12.50, 8),
(3.50, 17.50, 10),
(1.00, 5.00, 12),
(4.00, 20.00, 14),
(3.20, 16.00, 16),
(5.00, 25.00, 18),
(4.50, 22.50, 20);

-- 48. RESENA (10 registros, asociados a los primeros 10 detalles de reserva)
-- fk_detalle_reserva (fk_compra: 1-5, det_res_codigo: 1-2)
INSERT INTO resena (res_calificacion_numerica, res_descripcion, res_fecha_hota_creacion, fk_detalle_reserva, fk_detalle_reserva_2) VALUES
(5, 'Excelente servicio de vuelo y hotel. Recomendado!', '2026-01-20 10:00:00', 1, 1),
(4, 'Buen tour, aunque el vuelo se retrasó 15 min.', '2026-01-21 11:00:00', 2, 1),
(5, 'Hotel muy cómodo, la habitación era perfecta.', '2026-01-22 12:00:00', 3, 1),
(3, 'El tour fue regular, pero el precio del vuelo estuvo bien.', '2026-01-23 13:00:00', 4, 1),
(5, 'Todo impecable. Viaje y estadía sin problemas.', '2026-01-24 14:00:00', 5, 1),
(4, 'La actividad cultural fue lo mejor del viaje.', '2026-01-25 15:00:00', 6, 1),
(5, 'Vuelo rápido y hotel céntrico.', '2026-01-26 16:00:00', 7, 1),
(4, 'La combinación de servicios funcionó bien.', '2026-01-27 17:00:00', 8, 1),
(5, 'Fantástica experiencia de principio a fin.', '2026-01-28 18:00:00', 9, 1),
(4, 'Cumplió con las expectativas.', '2026-01-29 19:00:00', 10, 1);

-- 49. RECLAMO (10 registros, asociados a detalles de reserva 2, 4, 6, 8, 10, 12, 14, 16, 18, 20)
INSERT INTO reclamo (rec_contenido, rec_fecha_hora, fk_detalle_reserva, fk_detalle_reserva_2) VALUES
('La habitación no tenía vista al mar como se prometió.', '2025-12-05 09:30:00', 3, 2),
('El guía del tour llegó tarde media hora.', '2025-12-07 10:45:00', 4, 2),
('Problemas con el check-in del hotel.', '2025-12-09 11:30:00', 5, 2),
('El costo final no coincidió con la cotización inicial.', '2025-12-11 12:40:00', 6, 2),
('La comida incluida en el paquete no fue satisfactoria.', '2025-12-13 13:50:00', 7, 2),
('El asiento del vuelo estaba defectuoso.', '2025-12-15 14:30:00', 8, 2),
('No se aplicó el descuento de la promoción.', '2025-12-17 15:15:00', 9, 2),
('La información del tour estaba desactualizada.', '2025-12-19 16:00:00', 10, 2),
('El hotel estaba muy ruidoso por la noche.', '2025-12-21 17:00:00', 11, 2),
('Reclamo por cobro doble en el seguro de viaje.', '2025-12-23 18:00:00', 12, 2);

-- 50. AUDITORIA (10 registros)
-- Usaremos Administrador (95) y Analista Finanzas (96).
INSERT INTO auditoria (aud_fecha_hora, fk_accion, fk_recurso, fk_usuario) VALUES
('2025-12-01 08:00:00', 5, 1, 95), -- Login Admin
('2025-12-01 10:00:00', 1, 3, 95), -- Crear Reserva
('2025-12-02 11:00:00', 7, 4, 96), -- Aprobar Pago
('2025-12-03 12:00:00', 2, 2, 95), -- Actualizar Servicio
('2025-12-04 13:00:00', 4, 7, 96), -- Consultar Viajero
('2025-12-05 14:00:00', 3, 3, 95), -- Eliminar Reserva
('2025-12-06 15:00:00', 6, 1, 95), -- Logout Admin
('2025-12-07 16:00:00', 9, 1, 95), -- Bloquear Usuario
('2025-12-08 17:00:00', 8, 3, 96), -- Cancelar Reserva
('2025-12-09 18:00:00', 10, 10, 96); -- Reembolsar

-- 51. PREFERENCIA (10 registros, asociados a usuarios clientes 1-10 y categorías 1-10)
INSERT INTO preferencia (fk_usuario, fk_categoria) VALUES
(1, 2), (2, 4), (3, 1), (4, 3), (5, 5),
(6, 7), (7, 6), (8, 9), (9, 8), (10, 10);

-- 52. LISTA_DESEOS (10 registros)
-- Combinaciones de Paquete (1), Servicio (2) y Traslado (1) con usuarios clientes (1-10)
INSERT INTO lista_deseos (fk_usuario, fk_paquete_turistico, fk_servicio, fk_traslado) VALUES
(1, 1, 2, 1),
(2, 2, 3, 2),
(3, 3, 4, 3),
(4, 4, 5, 4),
(5, 5, 6, 5),
(6, 6, 7, 6),
(7, 7, 8, 7),
(8, 8, 9, 8),
(9, 9, 10, 9),
(10, 10, 1, 10);

-- 53. CUO_EST (10 registros, asociados a las 10 cuotas)
INSERT INTO cuo_est (fk_cuo_codigo, fk_est_codigo, cuo_est_fecha, cuo_est_fecha_fin) VALUES
(1, 3, '2026-01-01 10:00:00', '2026-01-01 10:00:00'), -- Pagada
(2, 4, '2026-02-01 10:00:00', '2026-02-28 23:59:59'), -- Pendiente
(3, 4, '2026-03-01 10:00:00', '2026-03-31 23:59:59'), -- Pendiente
(4, 3, '2026-01-05 10:00:00', '2026-01-05 10:00:00'), -- Pagada
(5, 4, '2026-02-05 10:00:00', '2026-02-28 23:59:59'), -- Pendiente
(6, 4, '2026-03-05 10:00:00', '2026-03-31 23:59:59'), -- Pendiente
(7, 3, '2026-01-20 10:00:00', '2026-01-20 10:00:00'), -- Pagada
(8, 4, '2026-02-20 10:00:00', '2026-02-28 23:59:59'), -- Pendiente
(9, 4, '2026-03-20 10:00:00', '2026-03-31 23:59:59'), -- Pendiente
(10, 4, '2026-04-20 10:00:00', '2026-04-30 23:59:59'); -- Pendiente

-- 54. RES_EST (10 registros, asociados a los primeros 10 detalles de reserva)
-- Estado 5 (Confirmada), Estado 6 (Cancelada)
INSERT INTO res_est (res_est_fecha, fk_estado, fk_detalle_reserva_codigo, fk_detalle_reserva_2, res_est_fecha_fin) VALUES
('2025-12-01 10:06:00', 5, 1, 1, NULL),
('2025-12-01 10:06:00', 5, 2, 1, NULL),
('2025-12-02 10:06:00', 5, 3, 1, NULL),
('2025-12-02 10:06:00', 5, 4, 1, NULL),
('2025-12-03 10:06:00', 5, 5, 1, NULL),
('2025-12-03 10:06:00', 6, 6, 1, '2025-12-03 11:00:00'), -- Cancelada
('2025-12-04 10:06:00', 5, 7, 1, NULL),
('2025-12-04 10:06:00', 5, 8, 1, NULL),
('2025-12-05 10:06:00', 5, 9, 1, NULL),
('2025-12-05 10:06:00', 5, 10, 1, NULL);
