--1

Create table rol(
    rol_codigo serial primary key,
    rol_nombre varchar(30) not null unique,
    rol_descripcion text
) --

create table privilegio(
    pri_codigo serial primary key,
    pri_nombre varchar(30) not null unique,
    pri_descripcion text
)

create table rol_privilegio(
    fk_pri_codigo integer not null,
    fk_rol_codigo integer not null,
    primary key(fk_pri_codigo, fk_rol_codigo)
)

create table usuario(
    usu_codigo serial primary key,
    usu_contrasena varchar(100) not null,
    usu_nombre_usuario varchar(30) not null unique,
    usu_total_millas integer not null default 0,
    fk_rol_codigo integer not null,
    usu_email varchar(100) not null unique
)

-- 3
create table lugar (
    lug_codigo serial primary key,
    lug_tipo varchar(50) not null,
    lug_nombre varchar(100) not null,
    fk_lugar integer,
    CONSTRAINT check_lug_tipo CHECK (lug_tipo IN ('Pais', 'Estado', 'Ciudad', 'Municipio', 'Parroquia'))
)


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

CREATE TABLE proveedor(
    pro_codigo SERIAL PRIMARY KEY,
    pro_nombre VARCHAR(100) NOT NULL,
    pro_anos_servicio INTEGER NOT NULL DEFAULT 0,
    pro_tipo VARCHAR(30) NOT NULL,
    
    -- Claves foráneas (solo definición de columnas por ahora)
    fk_lugar INTEGER NOT NULL,
    fk_usu_codigo INTEGER NOT NULL UNIQUE, -- Agregado para el Login

    -- Constraints internos
    CONSTRAINT check_tipo_proveedor CHECK(pro_tipo IN('Aerolinea', 'Terrestre', 'Maritimo', 'Otros'))
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

/*

create table servicio(
    ser_codigo serial primary key,
    ser_nombre varchar(100) not null,
    ser_descripcion text,
    ser_costo float not null,
    ser_fecha_hora_inicio TIMESTAMP NOT NULL,
    ser_fecha_hora_fin TIMESTAMP NOT NULL,
    ser_millas_otorgadas float default 0,
    ser_tipo varchar(30) not null default 'Otros',
    fk_pro_codigo integer not null,
    CONSTRAINT check_fecha_servicio_valida CHECK (ser_fecha_hora_fin >= ser_fecha_hora_inicio)
    CONSTRAINT check_ser_tipo CHECK (ser_tipo IN('Aereolinea', 'Terrestre', 'Maritimo', 'Otros'))
    --tenemos que ver que cdlm van a ser los tipos
);
*/
--crear detalle reserva despues

/*
create table promocion(
    pro_codigo serial primary key,
    pro_fecha_hora_vencimiento TIMESTAMP not null,
    pro_descuento float not null,
    pro_nombre varchar(50) not null,
    pro_descripcion text,
)
*/


/*
create table ser_prom(
    ser_prom_codigo serial primary key,
    fk_ser_codigo integer not null,
    fk_pro_codigo integer not null,
    foreign key (fk_ser_codigo) references servicio(ser_codigo),
    foreign key (fk_pro_codigo) references promocion(pro_codigo),
    CONSTRAINT un_ser_unico UNIQUE (fk_ser_codigo)
)
*/

/*
create table paquete_turistico(
    paq_tur_codigo serial primary key,
    paq_tur_nombre varchar(40) not null,
    paq_tur_monto_total float not null,
    paq_tur_monto_subtotal float,
    paq_tur_costo_en_millas float not null,
)
*/

/*
create table regla_paquete(
    reg_paq_codigo serial primary key,
    reg_paq_atributo varchar(30) not null,
    reg_paq_operador varchar(5),
    reg_paq_valor varchar(30)
)
*/

/*
create table reg_paq_paq(
    fk_reg_paq_codigo integer not null,
    fk_paq_codigo integer not null
    primary key (fk_reg_paq_codigo, fk_paq_codigo)
);
*/

/*
create table paq_prom(
    paq_prom_codigo serial primary key,
    fk_paq_tur_codigo integer not null,
    fk_pro_codigo integer not null,

    foreign key (fk_paq_tur_codigo) references paquete_turistico(paq_tur_codigo),
    foreign key (fk_pro_codigo) references promocion(pro_codigo),
    CONSTRAINT un_paq_tur_unico UNIQUE(fk_paq_tur_codigo)
); */

/*
create table terminal(
    ter_codigo serial primary key,
    ter_nombre varchar(50) not null,
    ter_descripcion text, 
    ter_tipo varchar(30),
    fk_lug_codigo integer not null,

    CONSTRAINT check_ter_tipo CHECK(ter_tipo IN('Aereolinea', 'Terrestre', 'Maritimo'))
)
create table medio_transporte(
    med_tra_codigo serial primary key,
    med_tra_capacidad integer not null,
    med_tra_descripcion text,
    med_tra_tipo varchar(30) not null,
    fk_pro_codigo integer not null,

    CONSTRAINT check_med_tra_tipo CHECK(med_tra_tipo IN('Aereolinea', 'Terrestre', 'Maritimo'))
);

create table puesto(
    pue_codigo SERIAL primary key, 
    pue_descripcion varchar(100) NOT NULL,
    pue_costo_agregado float,

    fk_med_tra_codigo integer not null,
);

create table ruta(
    rut_codigo serial primary key,
    rut_costo float not null,
    rut_millas_otorgadas float,
    fk_terminal_origen integer not null,
    fk_terminal_destino integer not null,

    fk_pro_codigo integer not null
)

create table traslado(
    tras_codigo serial primary key,
    tras_fecha_hora_inicio TIMESTAMP not null,
    tras_fecha_hora_fin TIMESTAMP not null,
    tras_CO2_Emitido float not null

    fk_rut_codigo integer not null,
    fk_med_tra_codigo integer not null,
)

create table tras_prom(
    tras_prom_codigo serial primary key,
    fk_paq_tur_codigo integer not null,
    fk_pro_codigo integer not null,

    foreign key (fk_paq_tur_codigo) references paquete_turistico(paq_tur_codigo),
    foreign key (fk_pro_codigo) references promocion(pro_codigo),
    CONSTRAINT un_paq_tur_unico UNIQUE(fk_paq_tur_codigo)
)
*/


CREATE TABLE servicio(
    ser_codigo SERIAL PRIMARY KEY,
    ser_nombre VARCHAR(100) NOT NULL,
    ser_descripcion TEXT,
    ser_costo NUMERIC(10,2) NOT NULL,
    ser_fecha_hora_inicio TIMESTAMP NOT NULL,
    ser_fecha_hora_fin TIMESTAMP NOT NULL,
    ser_millas_otorgadas NUMERIC(10,2) DEFAULT 0,
    ser_tipo VARCHAR(30) NOT NULL DEFAULT 'Otros',
    fk_pro_codigo INTEGER NOT NULL
);

-- 1.3 Promoción
CREATE TABLE promocion(
    pro_codigo SERIAL PRIMARY KEY,
    pro_nombre VARCHAR(50) NOT NULL,
    pro_descripcion TEXT,
    pro_fecha_hora_vencimiento TIMESTAMP NOT NULL,
    pro_descuento NUMERIC(5,2) NOT NULL
);

-- 1.4 Servicio - Promoción
CREATE TABLE ser_prom(
    ser_prom_codigo SERIAL PRIMARY KEY,
    fk_ser_codigo INTEGER NOT NULL,
    fk_pro_codigo INTEGER NOT NULL
);

-- 1.5 Paquete Turístico
CREATE TABLE paquete_turistico(
    paq_tur_codigo SERIAL PRIMARY KEY,
    paq_tur_nombre VARCHAR(40) NOT NULL,
    paq_tur_monto_total NUMERIC(10,2) NOT NULL,
    paq_tur_monto_subtotal NUMERIC(10,2),
    paq_tur_costo_en_millas INTEGER NOT NULL
);

-- 1.6 Paquete - Promoción
CREATE TABLE paq_prom(
    paq_prom_codigo SERIAL PRIMARY KEY,
    fk_paq_tur_codigo INTEGER NOT NULL,
    fk_pro_codigo INTEGER NOT NULL
);

-- 1.7 Reglas de Paquete
CREATE TABLE regla_paquete(
    reg_paq_codigo SERIAL PRIMARY KEY,
    reg_paq_atributo VARCHAR(30) NOT NULL,
    reg_paq_operador VARCHAR(5),
    reg_paq_valor VARCHAR(30)
);

CREATE TABLE reg_paq_paq(
    fk_reg_paq_codigo INTEGER NOT NULL,
    fk_paq_codigo INTEGER NOT NULL
);

-- 1.8 Terminal
CREATE TABLE terminal(
    ter_codigo SERIAL PRIMARY KEY,
    ter_nombre VARCHAR(50) NOT NULL,
    ter_descripcion TEXT, 
    ter_tipo VARCHAR(30),
    fk_lug_codigo INTEGER NOT NULL
);

-- 1.9 Medio de Transporte
CREATE TABLE medio_transporte(
    med_tra_codigo SERIAL PRIMARY KEY,
    med_tra_capacidad INTEGER NOT NULL,
    med_tra_descripcion TEXT,
    med_tra_tipo VARCHAR(30) NOT NULL,
    fk_pro_codigo INTEGER NOT NULL
);

-- 1.10 Puesto
CREATE TABLE puesto (

    fk_med_tra_codigo INTEGER NOT NULL,
    pue_codigo INTEGER NOT NULL, 
    pue_descripcion VARCHAR(100) NOT NULL,
    pue_costo_agregado NUMERIC(10,2) DEFAULT 0,
    CONSTRAINT pk_puesto PRIMARY KEY (fk_med_tra_codigo, pue_codigo),
    CONSTRAINT fk_pue_medio FOREIGN KEY (fk_med_tra_codigo) 
        REFERENCES medio_transporte(med_tra_codigo) ON DELETE CASCADE
);

-- 1.11 Ruta
CREATE TABLE ruta(
    rut_codigo SERIAL PRIMARY KEY,
    rut_costo NUMERIC(10,2) NOT NULL,
    rut_millas_otorgadas NUMERIC(10,2),
    fk_terminal_origen INTEGER NOT NULL,
    fk_terminal_destino INTEGER NOT NULL,
    fk_pro_codigo INTEGER NOT NULL
);

-- 1.12 Traslado
CREATE TABLE traslado(
    tras_codigo SERIAL PRIMARY KEY,
    tras_fecha_hora_inicio TIMESTAMP NOT NULL,
    tras_fecha_hora_fin TIMESTAMP NOT NULL,
    tras_CO2_Emitido NUMERIC(10,2) NOT NULL DEFAULT 0,
    fk_rut_codigo INTEGER NOT NULL,
    fk_med_tra_codigo INTEGER NOT NULL
);

-- 1.13 Traslado - Promoción
CREATE TABLE tras_prom(
    tras_prom_codigo SERIAL PRIMARY KEY,
    fk_tras_codigo INTEGER NOT NULL,
    fk_pro_codigo INTEGER NOT NULL
);

-- 1.14 Contenido del Paquete (Nuevas tablas necesarias)
CREATE TABLE paq_ser(
    fk_paq_tur_codigo INTEGER NOT NULL,
    fk_ser_codigo INTEGER NOT NULL,
    cantidad INTEGER DEFAULT 1
);

CREATE TABLE paq_tras(
    fk_paq_tur_codigo INTEGER NOT NULL,
    fk_tras_codigo INTEGER NOT NULL
);

CREATE TABLE pue_tras (
    pue_tras_codigo SERIAL PRIMARY KEY,
    
    fk_tras_codigo INTEGER NOT NULL,
 
    fk_pue_codigo INTEGER NOT NULL,
    fk_med_tra_codigo INTEGER NOT NULL, 
    

    fk_paq_tur_codigo INTEGER
);

--Revisar si se hace una restriccion con las promociones apra evitar conflictos con paquetes con promociones que tambien incluyen productos con promociones
