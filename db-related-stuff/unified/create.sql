-- 1. SEGURIDAD Y USUARIOS
CREATE TABLE rol(
    rol_codigo SERIAL PRIMARY KEY,
    rol_nombre VARCHAR(30) NOT NULL UNIQUE,
    rol_descripcion TEXT
);

CREATE TABLE privilegio(
    pri_codigo SERIAL PRIMARY KEY,
    pri_nombre VARCHAR(30) NOT NULL UNIQUE,
    pri_descripcion TEXT
);

CREATE TABLE rol_privilegio(
    fk_pri_codigo INTEGER NOT NULL,
    fk_rol_codigo INTEGER NOT NULL,
    PRIMARY KEY(fk_pri_codigo, fk_rol_codigo)
);

CREATE TABLE usuario(
    usu_codigo SERIAL PRIMARY KEY,
    usu_contrasena VARCHAR(100) NOT NULL,
    usu_nombre_usuario VARCHAR(30) NOT NULL UNIQUE,
    usu_total_millas INTEGER NOT NULL DEFAULT 0,
    fk_rol_codigo INTEGER NOT NULL,
    usu_email VARCHAR(100) NOT NULL UNIQUE,
    fk_lugar INTEGER NOT NULL
);

-- 2. UBICACIÓN
CREATE TABLE lugar (
    lug_codigo SERIAL PRIMARY KEY,
    lug_tipo VARCHAR(50) NOT NULL,
    lug_nombre VARCHAR(100) NOT NULL,
    fk_lugar INTEGER,
    CONSTRAINT check_lug_tipo CHECK (lug_tipo IN ('Pais', 'Estado', 'Ciudad', 'Municipio', 'Parroquia'))
);

-- 3. PROVEEDORES Y ESTABLECIMIENTOS
CREATE TABLE proveedor(
    prov_codigo SERIAL PRIMARY KEY,
    prov_nombre VARCHAR(100) NOT NULL UNIQUE,
    prov_fecha_creacion DATE NOT NULL DEFAULT CURRENT_DATE, -- Corregido DEFAULT
    prov_tipo VARCHAR(50) NOT NULL,
    fk_lugar INTEGER NOT NULL,
    fk_usu_codigo INTEGER NOT NULL UNIQUE,
    CONSTRAINT check_tipo_proveedor CHECK(prov_tipo IN('Aerolinea', 'Terrestre', 'Maritimo', 'Otros'))
);

CREATE TABLE hotel(
    hot_codigo SERIAL PRIMARY KEY,
    hot_nombre VARCHAR(50) NOT NULL,
    hot_descripcion VARCHAR(100) NOT NULL,
    hot_valoracion NUMERIC(10,2) NOT NULL DEFAULT 0,
    hot_anos_servicio INTEGER NOT NULL DEFAULT 0,
    fk_lugar INTEGER NOT NULL
);

CREATE TABLE restaurante(
    res_codigo SERIAL PRIMARY KEY,
    res_nombre VARCHAR(50) NOT NULL,
    res_descripcion VARCHAR(100) NOT NULL,
    res_anos_servicio INTEGER NOT NULL DEFAULT 0,
    res_valoracion NUMERIC(10,2) NOT NULL DEFAULT 0,
    fk_lugar INTEGER NOT NULL
);

CREATE TABLE telefono (
    tel_codigo SERIAL PRIMARY KEY,
    tel_prefijo_pais VARCHAR(5) NOT NULL,
    tel_prefijo_operador VARCHAR(5) NOT NULL,
    tel_sufijo VARCHAR(15) NOT NULL,
    fk_prov_codigo INTEGER, -- Corregido nombre
    fk_hotel INTEGER,
    fk_restaurante INTEGER
);

CREATE TABLE plato(
    pla_codigo INTEGER NOT NULL,
    pla_nombre VARCHAR(50) NOT NULL,
    pla_descripcion VARCHAR(100),
    pla_costo NUMERIC(10,2) NOT NULL,
    fk_restaurante INTEGER NOT NULL,
    CONSTRAINT check_pla_costo_positive CHECK (pla_costo >= 0),
    PRIMARY KEY (pla_codigo, fk_restaurante)
);

CREATE TABLE habitacion(
    hab_num_hab SERIAL PRIMARY KEY,
    hab_capacidad INTEGER NOT NULL,
    hab_descripcion VARCHAR(100) NOT NULL,
    hab_costo_noche NUMERIC(10,2) NOT NULL,
    fk_hotel INTEGER NOT NULL,
    fk_promocion INTEGER
);

-- 4. VIAJEROS
CREATE TABLE nacionalidad(
    nac_codigo SERIAL PRIMARY KEY,
    nac_nombre VARCHAR(30) UNIQUE NOT NULL,
    nac_descripcion VARCHAR(100)
);

CREATE TABLE viajero(
    via_codigo SERIAL PRIMARY KEY,
    via_prim_nombre VARCHAR(30) NOT NULL,
    via_seg_nombre VARCHAR(30),
    via_prim_apellido VARCHAR(30) NOT NULL,
    via_seg_apellido VARCHAR(30),
    via_fecha_nacimiento DATE,
    fk_usu_codigo INTEGER NOT NULL
);

CREATE TABLE documento(
    doc_codigo SERIAL PRIMARY KEY,
    doc_fecha_emision DATE NOT NULL,
    doc_fecha_vencimiento DATE NOT NULL,
    doc_numero_documento VARCHAR(20) NOT NULL,
    doc_tipo VARCHAR(20) NOT NULL,
    fk_nac_codigo INTEGER NOT NULL,
    fk_via_codigo INTEGER NOT NULL,
    CONSTRAINT check_doc_tipo CHECK(doc_tipo IN('Pasaporte', 'Visa', 'Cedula'))
);

CREATE TABLE estado_civil(
    edo_civ_codigo SERIAL PRIMARY KEY,
    edo_civ_nombre VARCHAR(20) NOT NULL,
    edo_civ_descripcion VARCHAR(100)
);

CREATE TABLE via_edo(
    fk_via_codigo INTEGER NOT NULL,
    fk_edo_codigo INTEGER NOT NULL,
    via_edo_fecha_inicio DATE DEFAULT CURRENT_DATE,
    via_edo_fecha_fin DATE,
    PRIMARY KEY (fk_via_codigo, fk_edo_codigo, via_edo_fecha_inicio),
    CONSTRAINT check_fechas_validas CHECK (via_edo_fecha_fin >= via_edo_fecha_inicio)
);

-- 5. SERVICIOS Y PRODUCTOS
CREATE TABLE servicio(
    ser_codigo SERIAL PRIMARY KEY,
    ser_nombre VARCHAR(50) NOT NULL,
    ser_descripcion VARCHAR(100),
    ser_costo NUMERIC(10,2) NOT NULL,
    ser_fecha_hora_inicio TIMESTAMP NOT NULL,
    ser_fecha_hora_fin TIMESTAMP NOT NULL,
    ser_millas_otorgadas INTEGER DEFAULT 0,
    ser_tipo VARCHAR(30) NOT NULL,
    fk_prov_codigo INTEGER NOT NULL, -- Corregido nombre
    CONSTRAINT check_fechas_servicio CHECK (ser_fecha_hora_fin >= ser_fecha_hora_inicio)
);

CREATE TABLE promocion(
    prom_codigo SERIAL PRIMARY KEY,
    prom_nombre VARCHAR(50) NOT NULL,
    prom_descripcion VARCHAR(100),
    prom_fecha_hora_vencimiento TIMESTAMP NOT NULL,
    prom_descuento NUMERIC(5,2) NOT NULL
);

CREATE TABLE paquete_turistico(
    paq_tur_codigo SERIAL PRIMARY KEY,
    paq_tur_nombre VARCHAR(50) NOT NULL,
    paq_tur_monto_total NUMERIC(10,2) NOT NULL,
    paq_tur_monto_subtotal NUMERIC(10,2),
    paq_tur_costo_en_millas INTEGER NOT NULL,
    CONSTRAINT check_montos_positive CHECK (paq_tur_monto_total >= 0 AND paq_tur_monto_subtotal >= 0)
);

-- Tablas intermedias Paquete/Servicio/Promoción
CREATE TABLE ser_prom(
    fk_ser_codigo INTEGER NOT NULL,
    fk_prom_codigo INTEGER NOT NULL,
    PRIMARY KEY (fk_ser_codigo, fk_prom_codigo)
);

CREATE TABLE paq_prom(
    fk_paq_tur_codigo INTEGER NOT NULL,
    fk_prom_codigo INTEGER NOT NULL,
    PRIMARY KEY(fk_paq_tur_codigo, fk_prom_codigo)
);

CREATE TABLE tras_prom(
    fk_tras_codigo INTEGER NOT NULL,
    fk_prom_codigo INTEGER NOT NULL,
    PRIMARY KEY(fk_tras_codigo, fk_prom_codigo)
);

CREATE TABLE paq_ser(
    fk_paq_tur_codigo INTEGER NOT NULL,
    fk_ser_codigo INTEGER NOT NULL,
    cantidad INTEGER DEFAULT 1,
    PRIMARY KEY(fk_paq_tur_codigo, fk_ser_codigo)
);

CREATE TABLE paq_tras(
    fk_paq_tur_codigo INTEGER NOT NULL,
    fk_tras_codigo INTEGER NOT NULL,
    PRIMARY KEY(fk_paq_tur_codigo, fk_tras_codigo)
);

CREATE TABLE regla_paquete(
    reg_paq_codigo SERIAL PRIMARY KEY,
    reg_paq_atributo VARCHAR(100) NOT NULL,
    reg_paq_operador VARCHAR(50),
    reg_paq_valor VARCHAR(100) NOT NULL
);

CREATE TABLE reg_paq_paq(
    fk_reg_paq_codigo INTEGER NOT NULL,
    fk_paq_tur_codigo INTEGER NOT NULL,
    PRIMARY KEY(fk_reg_paq_codigo, fk_paq_tur_codigo)
);

-- 6. TRANSPORTE
CREATE TABLE terminal(
    ter_codigo SERIAL PRIMARY KEY,
    ter_nombre VARCHAR(50) NOT NULL,
    fk_lugar INTEGER NOT NULL,
    ter_tipo VARCHAR(50) NOT NULL
);

CREATE TABLE medio_transporte(
    med_tra_codigo SERIAL PRIMARY KEY,
    med_tra_capacidad INTEGER NOT NULL,
    med_tra_descripcion VARCHAR(100) NOT NULL,
    med_tra_tipo VARCHAR(50) NOT NULL,
    fk_prov_codigo INTEGER NOT NULL -- Corregido nombre
);

CREATE TABLE puesto(
    pue_codigo INTEGER NOT NULL,
    pue_descripcion VARCHAR(100) NOT NULL,
    pue_costo_agregado NUMERIC(10,2) DEFAULT 0,
    fk_med_tra_codigo INTEGER NOT NULL,
    CONSTRAINT pk_puesto PRIMARY KEY (fk_med_tra_codigo, pue_codigo)
);

CREATE TABLE ruta(
    rut_codigo SERIAL PRIMARY KEY,
    rut_costo NUMERIC(10,2) NOT NULL,
    rut_millas_otorgadas INTEGER NOT NULL,
    rut_tipo VARCHAR(50) NOT NULL,
    fk_terminal_origen INTEGER NOT NULL,
    fk_terminal_destino INTEGER NOT NULL,
    fk_prov_codigo INTEGER NOT NULL, -- Corregido nombre
    CONSTRAINT check_rut_tipo CHECK(rut_tipo IN('Aerea', 'Terrestre', 'Maritima'))
);

CREATE TABLE traslado(
    tras_codigo SERIAL PRIMARY KEY,
    tras_fecha_hora_inicio TIMESTAMP NOT NULL,
    tras_fecha_hora_fin TIMESTAMP NOT NULL,
    tras_Co2_emitido NUMERIC(10,2) NOT NULL, 
    fk_rut_codigo INTEGER NOT NULL,
    fk_med_tra_codigo INTEGER NOT NULL,
    CONSTRAINT check_fechas_traslado CHECK (tras_fecha_hora_fin >= tras_fecha_hora_inicio)
);

-- 7. RESERVAS Y PAGOS
CREATE TABLE detalle_reserva(
    det_res_codigo INTEGER NOT NULL,
    det_res_fecha_creacion DATE NOT NULL,
    det_res_hora_creacion TIME NOT NULL,
    det_res_monto_total NUMERIC(10,2) NOT NULL,
    det_res_sub_total NUMERIC(10,2) NOT NULL,
    fk_viajero_codigo INTEGER NOT NULL,
    fk_viajero_numero INTEGER NOT NULL, -- ? Validar uso
    fk_compra INTEGER NOT NULL,
    fk_servicio INTEGER,
    fk_paquete_turistico INTEGER,
    fk_pue_tras INTEGER,
    fk_pue_tras1 INTEGER,
    fk_pue_tras2 INTEGER,
    det_res_estado VARCHAR(50) NOT NULL,
    CONSTRAINT check_det_res_estado CHECK(det_res_estado IN('Pendiente', 'Confirmada', 'Cancelada')),
    PRIMARY KEY (fk_compra, det_res_codigo)
);

CREATE TABLE pue_tras(
    pue_tras_codigo SERIAL PRIMARY KEY, -- Simplificado PK
    fk_tras_codigo INTEGER NOT NULL,
    fk_pue_codigo INTEGER NOT NULL,
    fk_med_tra_codigo INTEGER NOT NULL,
    fk_paq_tur_codigo INTEGER -- Nullable (Venta individual)
);

CREATE TABLE compra(
    com_codigo SERIAL PRIMARY KEY,
    com_monto_total NUMERIC(10,2) NOT NULL,
    com_monto_subtotal NUMERIC(10,2),
    com_fecha DATE NOT NULL,
    fk_usuario INTEGER NOT NULL,
    fk_plan_financiamiento INTEGER
);

CREATE TABLE metodo_pago(
    met_pag_codigo SERIAL PRIMARY KEY,
    met_pag_descripcion VARCHAR(200)
);

CREATE TABLE tasa_de_cambio(
    tas_cam_codigo SERIAL PRIMARY KEY,
    tas_cam_tasa_valor NUMERIC(10,2) NOT NULL,
    tas_cam_fecha_hora_inicio TIMESTAMP NOT NULL,
    tas_cam_fecha_hora_fin TIMESTAMP,
    tas_cam_moneda VARCHAR(50) NOT NULL   
);

CREATE TABLE pago(
    pag_codigo SERIAL PRIMARY KEY,
    pag_monto NUMERIC(10,2) NOT NULL,
    pag_fecha_hora TIMESTAMP NOT NULL,
    pag_denominacion VARCHAR(50) NOT NULL,
    fk_compra INTEGER NOT NULL,
    fk_tasa_de_cambio INTEGER NOT NULL,
    fk_metodo_pago INTEGER NOT NULL
);

CREATE TABLE reembolso(
    rem_codigo SERIAL PRIMARY KEY,
    rem_monto_reembolsado NUMERIC(10,2) NOT NULL,
    rem_monto_retenido NUMERIC(10,2) NOT NULL,
    rem_fecha DATE NOT NULL,
    fk_pago INTEGER NOT NULL
);

-- Tablas de detalle de pago (Herencia lógica)
CREATE TABLE tarjeta_credito(
    met_pago_codigo SERIAL PRIMARY KEY,
    tar_cre_numero VARCHAR(20) NOT NULL,
    tar_cre_cvv VARCHAR(10) NOT NULL,
    tar_cre_fecha_vencimiento DATE NOT NULL,
    tar_cre_banco_emisor VARCHAR(100) NOT NULL,
    tar_cre_nombre_titular VARCHAR(100) NOT NULL,
    CONSTRAINT validar_fecha_venc_tc CHECK (tar_cre_fecha_vencimiento > CURRENT_DATE)
);

CREATE TABLE tarjeta_debito(
    met_pago_codigo SERIAL PRIMARY KEY,
    tar_deb_numero VARCHAR(20) NOT NULL,
    tar_deb_cvv VARCHAR(10) NOT NULL,
    tar_deb_fecha_vencimiento DATE NOT NULL,
    tar_deb_banco_emisor VARCHAR(100) NOT NULL,
    tar_deb_nombre_titular VARCHAR(100) NOT NULL,
    CONSTRAINT validar_fecha_venc_td CHECK (tar_deb_fecha_vencimiento > CURRENT_DATE)
);

CREATE TABLE cheque(
    met_pago_codigo SERIAL PRIMARY KEY,
    che_codigo_cuenta_cliente VARCHAR(30) NOT NULL,
    che_numero VARCHAR(30) NOT NULL,
    che_nombre_titular VARCHAR(100) NOT NULL,
    che_banco_emisor VARCHAR(100) NOT NULL,
    cheque_fecha_emision DATE NOT NULL
);

CREATE TABLE deposito_bancario(
    met_pago_codigo SERIAL PRIMARY KEY,
    dep_ban_numero_cuenta VARCHAR(30) NOT NULL,
    dep_ban_banco_emisor VARCHAR(100) NOT NULL,
    dep_ban_numero_referencia VARCHAR(30),
    dep_fecha_transaccion DATE
);

CREATE TABLE transferencia_bancaria(
    met_pago_codigo SERIAL PRIMARY KEY,
    trans_ban_numero_referencia INTEGER,
    trans_ban_fecha_hora TIMESTAMP,
    tras_ban_numero_cuenta_emisora VARCHAR(30) NOT NULL
);

CREATE TABLE pago_movil_interbancario(
    met_pago_codigo SERIAL PRIMARY KEY,
    pag_movil_int_numero_referencia VARCHAR(15),
    pag_movil_int_fecha_hora TIMESTAMP
);

CREATE TABLE criptomoneda(
    met_pago_codigo SERIAL PRIMARY KEY,
    cri_hash_transaccion VARCHAR(50),
    cri_direccion_billetera_emisora VARCHAR(100) NOT NULL
);

CREATE TABLE zelle(
    met_pago_codigo SERIAL PRIMARY KEY,
    zel_titular_cuenta VARCHAR(15) NOT NULL,
    zel_correo_electronico VARCHAR(100) NOT NULL,
    zel_codigo_transaccion VARCHAR(50) UNIQUE
);

CREATE TABLE efectivo(
    met_pago_codigo SERIAL PRIMARY KEY,
    efe_moneda VARCHAR(30),
    efe_codigo VARCHAR(100)
);

CREATE TABLE milla_pago(
    met_pag_codigo SERIAL PRIMARY KEY,
    mil_codigo INTEGER UNIQUE,
    mil_cantidad_utilizada INTEGER
);

-- 8. GESTIÓN Y VARIOS
CREATE TABLE resena(
    res_codigo SERIAL PRIMARY KEY,
    res_calificacion_numerica INTEGER NOT NULL,
    res_descripcion VARCHAR(200),
    res_fecha_hota_creacion TIMESTAMP NOT NULL,
    fk_detalle_reserva INTEGER NOT NULL,
    fk_detalle_reserva_2 INTEGER NOT NULL,
    CONSTRAINT check_res_calificacion CHECK(res_calificacion_numerica >= 1 AND res_calificacion_numerica <= 5)
);

CREATE TABLE reclamo(
    rec_codigo SERIAL PRIMARY KEY,
    rec_contenido VARCHAR(200) NOT NULL,
    rec_fecha_hora TIMESTAMP NOT NULL,
    fk_detalle_reserva INTEGER NOT NULL,
    fk_detalle_reserva_2 INTEGER NOT NULL
);

CREATE TABLE accion(
    acc_codigo SERIAL PRIMARY KEY,
    acc_nombre VARCHAR(50) NOT NULL,
    acc_descripcion VARCHAR(200) NOT NULL
);

CREATE TABLE recurso(
    recu_codigo SERIAL PRIMARY KEY,
    recu_nombre_tabla VARCHAR(50) NOT NULL,
    recu_descripcion VARCHAR(200) NOT NULL
);

CREATE TABLE auditoria(
    aud_codigo SERIAL PRIMARY KEY,
    aud_fecha_hora TIMESTAMP NOT NULL,
    fk_accion INTEGER NOT NULL,
    fk_recurso INTEGER NOT NULL,
    fk_usuario INTEGER NOT NULL
);

CREATE TABLE milla(
    mil_codigo SERIAL PRIMARY KEY,
    mil_valor_obtenido INTEGER,
    mil_fecha_inicio DATE NOT NULL,
    mil_fecha_fin DATE,
    mil_valor_restado INTEGER,
    fk_compra INTEGER NOT NULL,
    fk_pago INTEGER NOT NULL
);

CREATE TABLE lista_deseos(
    fk_usuario INTEGER NOT NULL,
    fk_paquete_turistico INTEGER NOT NULL,
    fk_servicio INTEGER NOT NULL,
    fk_traslado INTEGER NOT NULL,
    PRIMARY KEY(fk_usuario, fk_paquete_turistico, fk_servicio, fk_traslado)
);

CREATE TABLE categoria(
    cat_codigo SERIAL PRIMARY KEY,
    cat_nombre VARCHAR(50) NOT NULL,
    cat_descripcion VARCHAR(200)
);

CREATE TABLE preferencia(
    fk_usuario INTEGER NOT NULL,
    fk_categoria INTEGER NOT NULL,
    PRIMARY KEY(fk_usuario, fk_categoria)
);

CREATE TABLE compensacion(
    com_codigo SERIAL PRIMARY KEY,
    com_co2_compensado NUMERIC(10,2) NOT NULL,
    com_monto_agregado NUMERIC(10,2) NOT NULL,
    fk_compra INTEGER NOT NULL
);

CREATE TABLE plan_financiamiento(
    plan_fin_codigo SERIAL PRIMARY KEY,
    plan_fin_tasa_interes NUMERIC(10,2) NOT NULL,
    plan_fin_numero_cuotas INTEGER NOT NULL,
    plan_fin_inicial NUMERIC(10,2) NOT NULL,
    fk_compra INTEGER
);

CREATE TABLE cuota(
    cuo_codigo SERIAL PRIMARY KEY,
    cuo_monto NUMERIC(10,2) NOT NULL,
    cuo_fecha_tope DATE NOT NULL,
    cuo_fecha_fin DATE,
    fk_plan_financiamiento INTEGER NOT NULL
);

CREATE TABLE estado(
    est_codigo SERIAL PRIMARY KEY,
    est_nombre VARCHAR(50) NOT NULL,
    est_descripcion VARCHAR(200)
);

CREATE TABLE cuo_est(
    fk_cuo_codigo INTEGER NOT NULL,
    fk_est_codigo INTEGER NOT NULL,
    cuo_est_fecha TIMESTAMP NOT NULL,
    cuo_est_fecha_fin TIMESTAMP NOT NULL,
    PRIMARY KEY(fk_cuo_codigo, fk_est_codigo)
);

CREATE TABLE res_est(
    res_est_fecha TIMESTAMP NOT NULL,
    fk_estado INTEGER NOT NULL,
    fk_detalle_reserva_codigo INTEGER NOT NULL,
    fk_detalle_reserva_2 INTEGER NOT NULL,
    res_est_fecha_fin TIMESTAMP,
    PRIMARY KEY(fk_detalle_reserva_codigo, fk_estado, fk_detalle_reserva_2)
);

CREATE TABLE reserva_de_habitacion(
    res_hab_fecha_hora_inicio TIMESTAMP NOT NULL,
    res_hab_fecha_hora_fin TIMESTAMP NOT NULL,
    res_hab_costo_unitario NUMERIC(10,2) NOT NULL,
    fk_habitacion INTEGER NOT NULL,
    fk_detalle_reserva INTEGER NOT NULL,
    fk_detalle_reserva_2 INTEGER NOT NULL,
    fk_paquete_turistico INTEGER,
    PRIMARY KEY(res_hab_fecha_hora_inicio, fk_habitacion, res_hab_fecha_hora_fin)
);

CREATE TABLE reserva_restaurante(
    res_rest_fecha_hora TIMESTAMP NOT NULL,
    res_rest_num_mesa INTEGER NOT NULL,
    res_rest_tamano_mesa INTEGER NOT NULL,
    fk_restaurante INTEGER NOT NULL,
    fk_detalle_reserva INTEGER NOT NULL,
    fk_detalle_reserva_2 INTEGER NOT NULL,
    fk_paquete_turistico INTEGER,
    PRIMARY KEY(res_rest_fecha_hora, fk_restaurante, res_rest_num_mesa)
);