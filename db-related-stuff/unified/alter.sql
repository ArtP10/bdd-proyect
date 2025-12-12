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
--
ALTER TABLE servicio
    ADD CONSTRAINT fk_ser_proveedor FOREIGN KEY (fk_pro_codigo) REFERENCES proveedor(pro_codigo),
    ADD CONSTRAINT check_fecha_servicio_valida CHECK (ser_fecha_hora_fin >= ser_fecha_hora_inicio),
    ADD CONSTRAINT check_ser_tipo CHECK (ser_tipo IN ('Alojamiento', 'Actividad', 'Seguro', 'Aerolinea', 'Terrestre', 'Maritimo', 'Otros'));

-- 2.3 Ser_Prom (Servicio - Promoción)
ALTER TABLE ser_prom
    ADD CONSTRAINT fk_sp_servicio FOREIGN KEY (fk_ser_codigo) REFERENCES servicio(ser_codigo),
    ADD CONSTRAINT fk_sp_promocion FOREIGN KEY (fk_pro_codigo) REFERENCES promocion(pro_codigo),
    ADD CONSTRAINT un_ser_prom_unico UNIQUE (fk_ser_codigo); -- Un servicio solo una promo activa

-- 2.4 Paq_Prom (Paquete - Promoción)
ALTER TABLE paq_prom
    ADD CONSTRAINT fk_pp_paquete FOREIGN KEY (fk_paq_tur_codigo) REFERENCES paquete_turistico(paq_tur_codigo),
    ADD CONSTRAINT fk_pp_promocion FOREIGN KEY (fk_pro_codigo) REFERENCES promocion(pro_codigo),
    ADD CONSTRAINT un_paq_prom_unico UNIQUE(fk_paq_tur_codigo);

-- 2.5 Reg_Paq_Paq (Reglas - Paquete)
ALTER TABLE reg_paq_paq
    ADD CONSTRAINT pk_reg_paq_paq PRIMARY KEY (fk_reg_paq_codigo, fk_paq_codigo), -- PK Compuesta
    ADD CONSTRAINT fk_rpp_regla FOREIGN KEY (fk_reg_paq_codigo) REFERENCES regla_paquete(reg_paq_codigo),
    ADD CONSTRAINT fk_rpp_paquete FOREIGN KEY (fk_paq_codigo) REFERENCES paquete_turistico(paq_tur_codigo);

-- 2.6 Terminal
ALTER TABLE terminal
    ADD CONSTRAINT fk_ter_lugar FOREIGN KEY (fk_lug_codigo) REFERENCES lugar(lug_codigo),
    ADD CONSTRAINT check_ter_tipo CHECK(ter_tipo IN ('Aeropuerto', 'Terminal Terrestre', 'Puerto', 'Estacion'));

-- 2.7 Medio de Transporte
ALTER TABLE medio_transporte
    ADD CONSTRAINT fk_mt_proveedor FOREIGN KEY (fk_pro_codigo) REFERENCES proveedor(pro_codigo),
    ADD CONSTRAINT check_med_tra_tipo CHECK(med_tra_tipo IN ('Avion', 'Autobus', 'Barco', 'Ferry', 'Tren', 'Van'));

-- 2.8 Puesto
ALTER TABLE puesto
    ADD CONSTRAINT fk_pue_medio FOREIGN KEY (fk_med_tra_codigo) REFERENCES medio_transporte(med_tra_codigo);

-- 2.9 Ruta
ALTER TABLE ruta
    ADD CONSTRAINT fk_rut_origen FOREIGN KEY (fk_terminal_origen) REFERENCES terminal(ter_codigo),
    ADD CONSTRAINT fk_rut_destino FOREIGN KEY (fk_terminal_destino) REFERENCES terminal(ter_codigo),
    ADD CONSTRAINT fk_rut_proveedor FOREIGN KEY (fk_pro_codigo) REFERENCES proveedor(pro_codigo);

-- 2.10 Traslado
ALTER TABLE traslado
    ADD CONSTRAINT fk_tras_ruta FOREIGN KEY (fk_rut_codigo) REFERENCES ruta(rut_codigo),
    ADD CONSTRAINT fk_tras_medio FOREIGN KEY (fk_med_tra_codigo) REFERENCES medio_transporte(med_tra_codigo),
    ADD CONSTRAINT check_fechas_traslado CHECK (tras_fecha_hora_fin >= tras_fecha_hora_inicio);

-- 2.11 Tras_Prom (Traslado - Promoción)
ALTER TABLE tras_prom
    ADD CONSTRAINT fk_tp_traslado FOREIGN KEY (fk_tras_codigo) REFERENCES traslado(tras_codigo),
    ADD CONSTRAINT fk_tp_promocion FOREIGN KEY (fk_pro_codigo) REFERENCES promocion(pro_codigo),
    ADD CONSTRAINT un_tras_prom_unico UNIQUE(fk_tras_codigo);

-- 2.12 Paq_Ser (Paquete contiene Servicios)
ALTER TABLE paq_ser
    ADD CONSTRAINT pk_paq_ser PRIMARY KEY (fk_paq_tur_codigo, fk_ser_codigo), -- PK Compuesta
    ADD CONSTRAINT fk_ps_paquete FOREIGN KEY (fk_paq_tur_codigo) REFERENCES paquete_turistico(paq_tur_codigo),
    ADD CONSTRAINT fk_ps_servicio FOREIGN KEY (fk_ser_codigo) REFERENCES servicio(ser_codigo);

-- 2.13 Paq_Tras (Paquete contiene Traslados)
ALTER TABLE paq_tras
    ADD CONSTRAINT pk_paq_tras PRIMARY KEY (fk_paq_tur_codigo, fk_tras_codigo), -- PK Compuesta
    ADD CONSTRAINT fk_pt_paquete FOREIGN KEY (fk_paq_tur_codigo) REFERENCES paquete_turistico(paq_tur_codigo),
    ADD CONSTRAINT fk_pt_traslado FOREIGN KEY (fk_tras_codigo) REFERENCES traslado(tras_codigo);