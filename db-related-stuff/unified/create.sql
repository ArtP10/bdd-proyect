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

