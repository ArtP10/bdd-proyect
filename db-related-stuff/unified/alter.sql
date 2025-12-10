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

-- 4
ALTER TABLE lugar 
ADD CONSTRAINT fk_ubica_lugar FOREIGN KEY (fk_lugar) references lugar(lug_codigo)
ON DELETE CASCADE;

Alter table restaurante
add constraint fk_lugar_restaurante foreign key (fk_lugar) references lugar(lug_codigo);

alter table hotel
add constraint fk_lugar_hotel foreign key(fk_lugar) references lugar(lug_codigo);

alter table proveedor
add constraint fk_lugar_proveedor foreign key(fk_lugar) references lugar(lug_codigo);


ALTER TABLE telefono
    ADD CONSTRAINT fk_tel_proveedor FOREIGN KEY (fk_proveedor) REFERENCES proveedor(pro_codigo) ON DELETE CASCADE,
    ADD CONSTRAINT fk_tel_hotel FOREIGN KEY (fk_hotel) REFERENCES hotel(hot_codigo) ON DELETE CASCADE,
    ADD CONSTRAINT fk_tel_restaurante FOREIGN KEY (fk_restaurante) REFERENCES restaurante(res_codigo) ON DELETE CASCADE;


--para el arco de exclusividad
ALTER TABLE telefono
    ADD CONSTRAINT chk_telefono_origen 
    CHECK (
        (fk_proveedor IS NOT NULL AND fk_hotel IS NULL AND fk_restaurante IS NULL) OR
        (fk_proveedor IS NULL AND fk_hotel IS NOT NULL AND fk_restaurante IS NULL) OR
        (fk_proveedor IS NULL AND fk_hotel IS NULL AND fk_restaurante IS NOT NULL)
    );


ALTER TABLE proveedor
add column fk_usu_codigo integer not null unique,
add constraint fk_usu_codigo_proveedor foreign key (fk_usu_codigo) references usuario(usu_codigo);


ALTER TABLE documento
add constraint fk_nac_codigo_documento foreign key(fk_nac_codigo) references nacionalidad(nac_codigo),
add constraint fk_via_codigo_documento foreign key(fk_via_codigo) references viajero(via_codigo);

ALter table via_edo
add constraint fk_via_codigo_via_edo foreign key(fk_via_codigo) references viajero(via_codigo),
add constraint fk_edo_codigo_via_edo foreign key(fk_edo_codigo) references estado_civil(edo_civ_codigo);

Alter table viajero
add constraint fk_usu_codigo_viajero foreign key(fk_usu_codigo) references usuario(usu_codigo);