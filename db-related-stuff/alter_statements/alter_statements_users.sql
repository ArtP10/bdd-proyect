-- 2

alter table usuario
add constraint fk_rol_usuario
foreign key (fk_rol_codigo) references rol(rol_codigo)

alter table rol_privilegio
add constraint fk_rol_privilegio_rol
foreign key (fk_rol_codigo) references rol(rol_codigo)

alter table rol_privilegio
add constraint fk_rol_privilegio_privilegio
foreign key (fk_pri_codigo) references privilegio(pri_codigo)