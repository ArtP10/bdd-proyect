

-- 1
--En este archivo se manejan los create de las talas necesarias para loggear usuarios y distitntos perfiles
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