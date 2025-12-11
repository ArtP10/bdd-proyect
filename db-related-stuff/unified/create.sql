--1

Create table rol(
    rol_codigo serial primary key,
    rol_nombre varchar(30) not null unique,
    rol_descripcion text
); --

create table privilegio(
    pri_codigo serial primary key,
    pri_nombre varchar(30) not null unique,
    pri_descripcion text
);

create table rol_privilegio(
    fk_pri_codigo integer not null,
    fk_rol_codigo integer not null,
    primary key(fk_pri_codigo, fk_rol_codigo)
);

create table usuario(
    usu_codigo serial primary key,
    usu_contrasena varchar(100) not null,
    usu_nombre_usuario varchar(30) not null unique,
    usu_total_millas integer not null default 0,
    fk_rol_codigo integer not null,
    usu_email varchar(100) not null unique
);

-- 3
create table lugar (
    lug_codigo serial primary key,
    lug_tipo varchar(50) not null,
    lug_nombre varchar(100) not null,
    fk_lugar integer,
    CONSTRAINT check_lug_tipo CHECK (lug_tipo IN ('Pais', 'Estado', 'Ciudad', 'Municipio', 'Parroquia'))
);


CREATE TABLE telefono (
    tel_codigo SERIAL PRIMARY KEY,
    tel_prefijo_pais VARCHAR(5) NOT NULL,    -- Ej: +58
    tel_prefijo_operador VARCHAR(5) NOT NULL, -- Ej: 0414
    tel_sufijo VARCHAR(15) NOT NULL, 
    
    fk_proveedor integer,
    fk_hotel integer,
    fk_restaurante integer         -- El resto del número
);

create table hotel(
    hot_codigo serial primary key,
    hot_nombre varchar(50) not null,
    hot_descripcion varchar(100) not null,
    hot_valoracion float not null default 0,
    hot_anos_servicio integer not null default 0,
    fk_lugar integer not null
);

create table restaurante(
    res_codigo serial primary key,
    res_nombre varchar(50) not null,
    res_descripcion varchar(100) not null,
    res_anos_servicio integer not null default 0,
    res_valoracion float not null default 0,
    fk_lugar integer not null

);

create table proveedor(
    pro_codigo serial primary key,
    pro_nombre varchar(100) not null,
    pro_anos_servicio integer not null default 0,
    pro_tipo varchar(50) not null,
    fk_lugar integer not null,

    CONSTRAINT check_tipo_proveedor CHECK(pro_tipo IN('Aereolinea', 'Terrestre', 'Maritimo', 'Otros'))
);

create table nacionalidad(
    nac_codigo serial primary key,
    nac_nombre varchar(30) unique not null,
    nac_descripcion varchar(100)
);

create table viajero(
    via_codigo serial primary key,
    via_prim_nombre varchar(30) not null,
    via_seg_nombre varchar(30),
    via_prim_apellido varchar(30) not null,
    via_seg_apellido varchar(30),
    via_fecha_nacimiento DATE,
    fk_usu_codigo integer not null
);

create table documento(
    doc_codigo serial primary key,
    doc_fecha_emision DATE not null,
    doc_fecha_vencimiento DATE not null,
    doc_numero_documento varchar(20) not null,
    doc_tipo varchar(20) not null,
    fk_nac_codigo integer not null,
    fk_via_codigo integer not null,

    constraint check_doc_tipo check(doc_tipo IN('Pasaporte', 'Visa', 'Cedula'))
);

create table estado_civil(
    edo_civ_codigo serial primary key,
    edo_civ_nombre varchar(20) not null,
    edo_civ_descripcion varchar(100)
);


create table via_edo(
    fk_via_codigo integer not null,
    fk_edo_codigo integer not null,
    via_edo_fecha_inicio DATE default CURRENT_DATE,
    via_edo_fecha_fin DATE,
    PRIMARY KEY (fk_via_codigo, fk_edo_codigo, via_edo_fecha_inicio),
    CONSTRAINT check_fechas_validas CHECK (via_edo_fecha_fin >= via_edo_fecha_inicio)
);

--Jesus

CREATE table servicio(
    ser_codigo serial primary key,
    ser_nombre varchar(50) not null,
    ser_descripcion varchar(100),
    ser_costo float not null,
    ser_fecha_hora_inicio TIMESTAMP not null,
    ser_fecha_hora_fin TIMESTAMP not null,
    fk_proveedor integer not null,
    fk_promocion integer,
    ser_millas_otrogadas integer default 0,
    sert_tipo varchar(30) not null,
    CONSTRAINT check_fechas_validas CHECK (ser_fecha_hora_fin >= ser_fecha_hora_inicio),
    constraint check_ser_tipo check(sert_tipo IN('Vuelo', 'Alojamiento', 'Transporte', 'Tour', 'Comida'))
);

create table promocion(
    pro_codigo serial primary key,
    pro_fecha_hora_vencimiento TIMESTAMP not null,
    pro_descuento float not null,
    pro_descripcion varchar(100),
);

create Table paquete_turistico(
    paq_tur_codigo serial primary key,
    paq_tur_nombre VARCHAR(50) not null,
    paq_tur_monto_total FLOAT not null,
    paq_tur_monto_subtotal FLOAT,
    paqu_tur_costo_en_millas INTEGER not NULL,
    fk_promocion INTEGER,
    constraint check_montos_positive CHECK (paq_tur_monto_total >= 0 AND paq_tur_monto_subtotal >= 0)

);

create table servicio_paquete(
    fk_paq_tur_codigo integer not null,
    fk_ser_codigo integer not null,
    primary key(fk_paq_tur_codigo, fk_ser_codigo)
);

create table regla_paquete(
    reg_codigo serial primary key,
    reg_atributo varchar(100) not null,
    reg_operador varchar(50) ,          --Duda con el operador
    reg_valor varchar(100) not null,
    constraint check_reg_tipo check(reg_atributo IN('Edad Minima', 'Edad Maxima', 'Maximo de Personas', 'Otros'))
);

CREATE table reg_paq_paq(
    fk_reg_codigo integer not null,
    fk_paq_tur_codigo integer not null,
    primary key(fk_reg_codigo, fk_paq_tur_codigo)
);

CREATE table ruta(
    rut_codigo serial primary key,
    rut_costo float not null,
    rut_millas_otorgadas integer not null,
    rut_tipo varchar(50) not null,
    fk_terminal_origen integer not null,
    fk_terminal_destino integer not null,
    fk_proveedor integer not null,
    constraint check_rut_tipo check(rut_tipo IN('Aerea', 'Terrestre', 'Maritima'))
);

create table terminal(
    ter_codigo serial primary key,
    ter_nombre varchar(50) not null,
    fk_lugar integer not null,
    ter_tipo varchar(50) not null,
    constraint check_ter_tipo check(ter_tipo IN('Aeropuerto', 'Estacion Terrestre', 'Puerto Maritimo'))
);

create table medio_transoporte(
    med_tra_codigo serial primary key,
    med_tra_capacidad integer not null,
    med_tra_descripcion varchar(100) not null,
    med_tra_tipo varchar(50) not null,
    fk_proveedor integer not null,
    constraint check_med_tra_tipo check(med_tra_tipo IN('Avion', 'Bus', 'Barco', 'Otros'))
);

create table traslado(
    tra_codigo serial primary key,
    tra_fecha_hora_salida TIMESTAMP not null,
    tra_fecha_hora_llegada TIMESTAMP not null,
    tras_Co2_emitido float not null, 
    fk_ruta integer not null,
    fk_promocion integer,
    fk_medio_transporte integer not null,
    constraint check_fechas_validas CHECK (tra_fecha_hora_llegada >= tra_fecha_hora_salida)
);

CREATE Table puesto(
    pue_codigo serial primary key,
    pue_descripcion varchar(100) not null,
    pue_costo_agregado float,
    fk_medio_transporte integer not null,
    PRIMARY KEY (fk_medio_transporte)

);

create table detalle_reserva(
    det_res_codigo serial primary key,
    det_res_fecha_creacion DATE not null,
    det_res_hora_creacion TIME not null,
    det_res_monto_total float not null,
    det_res_sub_total float not NULL,
    fk_viajero_codigo integer not null,
    fk_viajero_numero integer not null,
    fk_compra integer not null,
    fk_servicio integer,
    fk_pue_tras integer,
    fk_pue_tras1 integer,
    fk_pue_tras2 integer,
    fk_paquete_turistico integer,
    det_res_estado varchar(50) not null,
    constraint check_det_res_estado check(det_res_estado IN('Pendiente', 'Confirmada', 'Cancelada')),
    PRIMARY KEY (fk_compra)
);

create table pue_tras(
    fk_puesto_codigo integer not null,
    fk_puesto_2 integer not null,
    fk_tra_codigo integer not null,
    fk_detalle_reserva integer ,
    fk_detalle_reserva_2 integer,
    primary key(fk_puesto_codigo, fk_tra_codigo)
);

create table resena(
    res_codigo serial primary key,
    res_calificacion_numerica integer not null,
    res_descripcion varchar(200),
    res_fecha_hota_creacion TIMESTAMP not null,
    fk_detalle_reserva integer not null,
    fk_detalle_reserva_2 integer NOT NULL,
    constraint check_res_calificacion check(res_calificacion >= 1 AND res_calificacion <= 5)
);

create table reclamo(
    rec_codigo serial primary key,
    rec_contenido varchar(200) not null,
    rec_fecha_hora timestamp not null,
    fk_detalle_reserva integer not null,
    fk_detalle_reserva_2 integer NOT NULL
);

create table accion(
    acc_codigo serial PRIMARY KEY,
    acc_nombre varchar(50) not null,
    acc_descripcion varchar(200) not null
);

create table recurso(
    recu_codigo serial PRIMARY KEY,
    recu_nombre_tabla varchar(50) not null,
    recu_descripcion varchar(200) not null
);

create table auditoria(
    aud_codigo serial primary key,
    aud_fecha_hora timestamp not null,
    fk_accion integer not null,
    fk_recurso integer not null,
    fk_usuario integer not null,
);

create table milla(
    mil_codigo serial PRIMARY KEY,
    mil_valor_obtenido integer,
    mil_fecha_inicio DATE not null,
    mil_fecha_fin DATE,
    mil_valor_restado integer,
    fk_compra integer not null,
    fk_pago integer not null

)

create table compra(
    com_codigo serial primary key,
    com_monto_total float not null,
    com_monto_subtotal float ,
    com_fecha date not null,
    fk_usuario integer not null,
    fk_plan_financiamiento integer
);

create table lista_deseos(
    fk_usuario integer not null,
    fk_paquete_turistico integer not null,
    fk_servicio integer not null,
    fk_traslado INTEGER not null,
    primary key(fk_usuario, fk_paquete_turistico, fk_servicio, fk_traslado)
);

create table compensacion(
    com_codigo serial primary key,
    com_co2_compensado float not null,
    com_monto_agregado float not null,
    fk_compra integer not null
);

create table plan_financiamiento(
    plan_fin_codigo serial primary key,
    plan_fin_tasa_interes float not null,
    plan_fin_numero_cuotas integer not null,
    plan_fin_inicial float not null,
    fk_compra integer
);

create table cuota(
    cuo_codigo serial primary key,
    cuo_monto float not null,
    cuo_fecha_tope date not null,
    cuo_fecha_fin date,
    fk_plan_financiamiento integer not null
);

create table estado(
    est_codigo serial primary key,
    est_nombre varchar(50) not null,
    est_descripcion varchar(200)
);

create table cuo_est(
    fk_cuo_codigo integer not null,
    fk_est_codigo integer not null,
    cuo_est_fecha timestamp not null,
    cuo_est_fecha_fin timestamp not null,
    primary key(fk_cuo_codigo, fk_est_codigo)
)

create table res_est(
    res_est_fecha timestamp not null,
    fk_estado integer not null,
    fk_detalle_reserva_codigo integer not null,
    fk_detalle_reserva_2 integer not null,
    res_est_fecha_fin timestamp ,
    primary key(fk_detalle_reserva_codigo, fk_estado, fk_detalle_reserva_2)
)