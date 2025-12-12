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
    ADD CONSTRAINT fk_tel_proveedor FOREIGN KEY (fk_proveedor) REFERENCES proveedor(pro_codigo) ON DELETE CASCADE
,
ADD CONSTRAINT fk_tel_hotel FOREIGN KEY
(fk_hotel) REFERENCES hotel
(hot_codigo) ON
DELETE CASCADE,
ADD CONSTRAINT fk_tel_restaurante FOREIGN KEY
(fk_restaurante) REFERENCES restaurante
(res_codigo) ON
DELETE CASCADE;


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
add constraint fk_usu_codigo_proveedor foreign key
(fk_usu_codigo) references usuario
(usu_codigo);


ALTER TABLE documento
add constraint fk_nac_codigo_documento foreign key(fk_nac_codigo) references nacionalidad(nac_codigo),
add constraint fk_via_codigo_documento foreign key(fk_via_codigo) references viajero(via_codigo);

ALter table via_edo
add constraint fk_via_codigo_via_edo foreign key(fk_via_codigo) references viajero(via_codigo)
,
add constraint fk_edo_codigo_via_edo foreign key
(fk_edo_codigo) references estado_civil
(edo_civ_codigo);

Alter table viajero
add constraint fk_usu_codigo_viajero foreign key(fk_usu_codigo) references usuario(usu_codigo);


/* ==========================================================================
   1. SEGURIDAD Y USUARIOS (Incluye rol_privilegio)
   ========================================================================== */
ALTER TABLE rol_privilegio ADD CONSTRAINT fk_rp_privilegio FOREIGN KEY (fk_pri_codigo) REFERENCES privilegio(pri_codigo);
ALTER TABLE rol_privilegio ADD CONSTRAINT fk_rp_rol FOREIGN KEY (fk_rol_codigo) REFERENCES rol(rol_codigo);

ALTER TABLE usuario ADD CONSTRAINT fk_usu_rol FOREIGN KEY (fk_rol_codigo) REFERENCES rol(rol_codigo);
ALTER TABLE usuario ADD CONSTRAINT fk_usu_lugar FOREIGN KEY (fk_lugar) REFERENCES lugar(lug_codigo);

ALTER TABLE via_edo ADD CONSTRAINT fk_ve_viajero FOREIGN KEY (fk_via_codigo) REFERENCES viajero(via_codigo);
ALTER TABLE via_edo ADD CONSTRAINT fk_ve_estado FOREIGN KEY (fk_edo_codigo) REFERENCES estado_civil(edo_civ_codigo);

/* ==========================================================================
   2. GEOGRAFÍA Y DOCUMENTACIÓN
   ========================================================================== */
ALTER TABLE lugar ADD CONSTRAINT fk_lug_padre FOREIGN KEY (fk_lugar) REFERENCES lugar(lug_codigo);

ALTER TABLE documento ADD CONSTRAINT fk_doc_nac FOREIGN KEY (fk_nac_codigo) REFERENCES nacionalidad(nac_codigo);
ALTER TABLE documento ADD CONSTRAINT fk_doc_viajero FOREIGN KEY (fk_via_codigo) REFERENCES viajero(via_codigo);
ALTER TABLE viajero ADD CONSTRAINT fk_via_usuario FOREIGN KEY (fk_usu_codigo) REFERENCES usuario(usu_codigo);

/* ==========================================================================
   3. PROVEEDORES, SERVICIOS Y PAQUETES
   ========================================================================== */
ALTER TABLE hotel ADD CONSTRAINT fk_hot_lugar FOREIGN KEY (fk_lugar) REFERENCES lugar(lug_codigo);
ALTER TABLE restaurante ADD CONSTRAINT fk_res_lugar FOREIGN KEY (fk_lugar) REFERENCES lugar(lug_codigo);
ALTER TABLE proveedor ADD CONSTRAINT fk_pro_lugar FOREIGN KEY (fk_lugar) REFERENCES lugar(lug_codigo);
ALTER TABLE terminal ADD CONSTRAINT fk_ter_lugar FOREIGN KEY (fk_lugar) REFERENCES lugar(lug_codigo);

ALTER TABLE plato ADD CONSTRAINT fk_pla_restaurante FOREIGN KEY (fk_restaurante) REFERENCES restaurante(res_codigo);

ALTER TABLE servicio ADD CONSTRAINT fk_ser_proveedor FOREIGN KEY (fk_proveedor) REFERENCES proveedor(pro_codigo);
ALTER TABLE servicio ADD CONSTRAINT fk_ser_promocion FOREIGN KEY (fk_promocion) REFERENCES promocion(pro_codigo);

ALTER TABLE paquete_turistico ADD CONSTRAINT fk_paq_promocion FOREIGN KEY (fk_promocion) REFERENCES promocion(pro_codigo);

ALTER TABLE servicio_paquete ADD CONSTRAINT fk_sp_paquete FOREIGN KEY (fk_paq_tur_codigo) REFERENCES paquete_turistico(paq_tur_codigo);
ALTER TABLE servicio_paquete ADD CONSTRAINT fk_sp_servicio FOREIGN KEY (fk_ser_codigo) REFERENCES servicio(ser_codigo);

ALTER TABLE reg_paq_paq ADD CONSTRAINT fk_rpp_regla FOREIGN KEY (fk_reg_codigo) REFERENCES regla_paquete(reg_codigo);
ALTER TABLE reg_paq_paq ADD CONSTRAINT fk_rpp_paquete FOREIGN KEY (fk_paq_tur_codigo) REFERENCES paquete_turistico(paq_tur_codigo);

/* ==========================================================================
   4. TRANSPORTE Y RUTAS (Incluye pue_tras complejo)
   ========================================================================== */
ALTER TABLE ruta ADD CONSTRAINT fk_rut_origen FOREIGN KEY (fk_terminal_origen) REFERENCES terminal(ter_codigo);
ALTER TABLE ruta ADD CONSTRAINT fk_rut_destino FOREIGN KEY (fk_terminal_destino) REFERENCES terminal(ter_codigo);
ALTER TABLE ruta ADD CONSTRAINT fk_rut_proveedor FOREIGN KEY (fk_proveedor) REFERENCES proveedor(pro_codigo);

ALTER TABLE medio_transoporte ADD CONSTRAINT fk_mt_proveedor FOREIGN KEY (fk_proveedor) REFERENCES proveedor(pro_codigo);
ALTER TABLE puesto ADD CONSTRAINT fk_pue_medio FOREIGN KEY (fk_medio_transporte) REFERENCES medio_transoporte(med_tra_codigo);

ALTER TABLE traslado ADD CONSTRAINT fk_tra_ruta FOREIGN KEY (fk_ruta) REFERENCES ruta(rut_codigo);
ALTER TABLE traslado ADD CONSTRAINT fk_tra_medio FOREIGN KEY (fk_medio_transporte) REFERENCES medio_transoporte(med_tra_codigo);
ALTER TABLE traslado ADD CONSTRAINT fk_tra_promocion FOREIGN KEY (fk_promocion) REFERENCES promocion(pro_codigo);

-- RELACION COMPLEJA: Puesto-Traslado
-- Conecta con la PK compuesta de Puesto (fk_medio_transporte, pue_codigo)
-- Asumimos que fk_puesto_2 es el medio de transporte y fk_puesto_codigo es el codigo del puesto
ALTER TABLE pue_tras ADD CONSTRAINT fk_pt_puesto FOREIGN KEY (fk_puesto_2, fk_puesto_codigo) REFERENCES puesto(fk_medio_transporte, pue_codigo);
ALTER TABLE pue_tras ADD CONSTRAINT fk_pt_traslado FOREIGN KEY (fk_tra_codigo) REFERENCES traslado(tra_codigo);

/* ==========================================================================
   5. COMPRAS, PAGOS Y FINANZAS (Incluye cuo_est)
   ========================================================================== */
ALTER TABLE compra ADD CONSTRAINT fk_com_usuario FOREIGN KEY (fk_usuario) REFERENCES usuario(usu_codigo);
ALTER TABLE compra ADD CONSTRAINT fk_com_plan FOREIGN KEY (fk_plan_financiamiento) REFERENCES plan_financiamiento(plan_fin_codigo);

ALTER TABLE plan_financiamiento ADD CONSTRAINT fk_pf_compra FOREIGN KEY (fk_compra) REFERENCES compra(com_codigo);
ALTER TABLE cuota ADD CONSTRAINT fk_cuo_plan FOREIGN KEY (fk_plan_financiamiento) REFERENCES plan_financiamiento(plan_fin_codigo);

-- Tabla intermedia Cuota-Estado
ALTER TABLE cuo_est ADD CONSTRAINT fk_ce_cuota FOREIGN KEY (fk_cuo_codigo) REFERENCES cuota(cuo_codigo);
ALTER TABLE cuo_est ADD CONSTRAINT fk_ce_estado FOREIGN KEY (fk_est_codigo) REFERENCES estado(est_codigo);

ALTER TABLE compensacion ADD CONSTRAINT fk_comp_compra FOREIGN KEY (fk_compra) REFERENCES compra(com_codigo);

ALTER TABLE pago ADD CONSTRAINT fk_pag_compra FOREIGN KEY (fk_compra) REFERENCES compra(com_codigo);
ALTER TABLE pago ADD CONSTRAINT fk_pag_tasa FOREIGN KEY (fk_tasa_de_cambio) REFERENCES tasa_de_cambio(tas_cam_codigo);
ALTER TABLE pago ADD CONSTRAINT fk_pag_metodo FOREIGN KEY (fk_metodo_pago) REFERENCES metodo_pago(met_pag_codigo);

ALTER TABLE reembolso ADD CONSTRAINT fk_rem_pago FOREIGN KEY (fk_pago) REFERENCES pago(pag_codigo);
ALTER TABLE milla ADD CONSTRAINT fk_mil_compra FOREIGN KEY (fk_compra) REFERENCES compra(com_codigo);
ALTER TABLE milla ADD CONSTRAINT fk_mil_pago FOREIGN KEY (fk_pago) REFERENCES pago(pag_codigo);

/* ==========================================================================
   6. RESERVAS Y DETALLES (Relaciones Compuestas Complejas)
   ========================================================================== */
ALTER TABLE habitacion ADD CONSTRAINT fk_hab_hotel FOREIGN KEY (fk_hotel) REFERENCES hotel(hot_codigo);
ALTER TABLE habitacion ADD CONSTRAINT fk_hab_promocion FOREIGN KEY (fk_promocion) REFERENCES promocion(pro_codigo);

-- Detalle Reserva (Centro de todo)
ALTER TABLE detalle_reserva ADD CONSTRAINT fk_dr_compra FOREIGN KEY (fk_compra) REFERENCES compra(com_codigo);
ALTER TABLE detalle_reserva ADD CONSTRAINT fk_dr_viajero FOREIGN KEY (fk_viajero_codigo) REFERENCES viajero(via_codigo);
ALTER TABLE detalle_reserva ADD CONSTRAINT fk_dr_servicio FOREIGN KEY (fk_servicio) REFERENCES servicio(ser_codigo);
ALTER TABLE detalle_reserva ADD CONSTRAINT fk_dr_paquete FOREIGN KEY (fk_paquete_turistico) REFERENCES paquete_turistico(paq_tur_codigo);

-- Reseña (Conecta con la PK compuesta de detalle_reserva: fk_compra, det_res_codigo)
ALTER TABLE resena ADD CONSTRAINT fk_resena_detalle 
    FOREIGN KEY (fk_detalle_reserva, fk_detalle_reserva_2) 
    REFERENCES detalle_reserva(fk_compra, det_res_codigo);

-- Reclamo (Igual que reseña)
ALTER TABLE reclamo ADD CONSTRAINT fk_reclamo_detalle 
    FOREIGN KEY (fk_detalle_reserva, fk_detalle_reserva_2) 
    REFERENCES detalle_reserva(fk_compra, det_res_codigo);

-- Histórico de Estados de Reserva (res_est)
ALTER TABLE res_est ADD CONSTRAINT fk_re_estado FOREIGN KEY (fk_estado) REFERENCES estado(est_codigo);
ALTER TABLE res_est ADD CONSTRAINT fk_re_detalle 
    FOREIGN KEY (fk_detalle_reserva_codigo, fk_detalle_reserva_2) 
    REFERENCES detalle_reserva(fk_compra, det_res_codigo);

-- Reservas Específicas (Habitación y Restaurante)
ALTER TABLE reserva_de_habitacion ADD CONSTRAINT fk_rh_habitacion FOREIGN KEY (fk_habitacion) REFERENCES habitacion(hab_num_hab);
ALTER TABLE reserva_de_habitacion ADD CONSTRAINT fk_rh_detalle 
    FOREIGN KEY (fk_detalle_reserva, fk_detalle_reserva_2) 
    REFERENCES detalle_reserva(fk_compra, det_res_codigo);

ALTER TABLE reserva_restaurante ADD CONSTRAINT fk_rr_restaurante FOREIGN KEY (fk_restaurante) REFERENCES restaurante(res_codigo);
ALTER TABLE reserva_restaurante ADD CONSTRAINT fk_rr_detalle 
    FOREIGN KEY (fk_detalle_reserva, fk_detalle_reserva_2) 
    REFERENCES detalle_reserva(fk_compra, det_res_codigo);

/* ==========================================================================
   7. LISTA DE DESEOS Y AUDITORÍA
   ========================================================================== */
ALTER TABLE lista_deseos ADD CONSTRAINT fk_ld_usuario FOREIGN KEY (fk_usuario) REFERENCES usuario(usu_codigo);
ALTER TABLE lista_deseos ADD CONSTRAINT fk_ld_paquete FOREIGN KEY (fk_paquete_turistico) REFERENCES paquete_turistico(paq_tur_codigo);
ALTER TABLE lista_deseos ADD CONSTRAINT fk_ld_servicio FOREIGN KEY (fk_servicio) REFERENCES servicio(ser_codigo);
ALTER TABLE lista_deseos ADD CONSTRAINT fk_ld_traslado FOREIGN KEY (fk_traslado) REFERENCES traslado(tra_codigo);

ALTER TABLE preferencia ADD CONSTRAINT fk_pref_usuario FOREIGN KEY (fk_usuario) REFERENCES usuario(usu_codigo);
ALTER TABLE preferencia ADD CONSTRAINT fk_pref_categoria FOREIGN KEY (fk_categoria) REFERENCES categoria(cat_codigo);

ALTER TABLE auditoria ADD CONSTRAINT fk_aud_accion FOREIGN KEY (fk_accion) REFERENCES accion(acc_codigo);
ALTER TABLE auditoria ADD CONSTRAINT fk_aud_recurso FOREIGN KEY (fk_recurso) REFERENCES recurso(recu_codigo);
ALTER TABLE auditoria ADD CONSTRAINT fk_aud_usuario FOREIGN KEY (fk_usuario) REFERENCES usuario(usu_codigo);

/* ==========================================================================
   8. ARCO EXCLUSIVO (TELEFONO) - REPETIDO PARA QUE NO FALTE
   ========================================================================== */
ALTER TABLE telefono ADD CONSTRAINT fk_tel_proveedor FOREIGN KEY (fk_proveedor) REFERENCES proveedor(pro_codigo);
ALTER TABLE telefono ADD CONSTRAINT fk_tel_hotel FOREIGN KEY (fk_hotel) REFERENCES hotel(hot_codigo);
ALTER TABLE telefono ADD CONSTRAINT fk_tel_restaurante FOREIGN KEY (fk_restaurante) REFERENCES restaurante(res_codigo);

ALTER TABLE telefono ADD CONSTRAINT check_arco_exclusivo_telefono 
CHECK (
    (
        (fk_proveedor IS NOT NULL)::integer + 
        (fk_hotel IS NOT NULL)::integer + 
        (fk_restaurante IS NOT NULL)::integer
    ) = 1
);