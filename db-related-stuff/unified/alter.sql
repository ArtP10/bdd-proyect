/* =========================================================
   SECCIÓN 1: USUARIOS, ROLES Y PRIVILEGIOS
   ========================================================= */
ALTER TABLE usuario ADD CONSTRAINT fk_rol_usuario FOREIGN KEY (fk_rol_codigo) REFERENCES rol(rol_codigo);
ALTER TABLE usuario ADD CONSTRAINT fk_usu_lugar FOREIGN KEY (fk_lugar) REFERENCES lugar(lug_codigo);

ALTER TABLE rol_privilegio ADD CONSTRAINT fk_rol_privilegio_rol FOREIGN KEY (fk_rol_codigo) REFERENCES rol(rol_codigo);
ALTER TABLE rol_privilegio ADD CONSTRAINT fk_rol_privilegio_privilegio FOREIGN KEY (fk_pri_codigo) REFERENCES privilegio(pri_codigo);

/* =========================================================
   SECCIÓN 2: UBICACIÓN Y LUGARES (Recursiva)
   ========================================================= */
ALTER TABLE lugar ADD CONSTRAINT fk_ubica_lugar FOREIGN KEY (fk_lugar) REFERENCES lugar(lug_codigo) ON DELETE CASCADE;

/* =========================================================
   SECCIÓN 3: PROVEEDORES Y CONTACTO
   ========================================================= */
ALTER TABLE proveedor ADD CONSTRAINT fk_lugar_proveedor FOREIGN KEY (fk_lugar) REFERENCES lugar(lug_codigo);
ALTER TABLE proveedor ADD CONSTRAINT fk_usu_codigo_proveedor FOREIGN KEY (fk_usu_codigo) REFERENCES usuario(usu_codigo);

ALTER TABLE hotel ADD CONSTRAINT fk_lugar_hotel FOREIGN KEY (fk_lugar) REFERENCES lugar(lug_codigo);
ALTER TABLE restaurante ADD CONSTRAINT fk_lugar_restaurante FOREIGN KEY (fk_lugar) REFERENCES lugar(lug_codigo);
alter table restaurante add constraint fk_prom_restaurante foreign key (fk_promocion) references promocion(prom_codigo);
alter table restaurante add constraint fk_tel_restaurante foreign key (fk_telefono) references telefono(tel_codigo);

ALTER TABLE telefono ADD CONSTRAINT fk_tel_proveedor FOREIGN KEY (fk_prov_codigo) REFERENCES proveedor(prov_codigo) ON DELETE CASCADE;
ALTER TABLE telefono ADD CONSTRAINT fk_tel_hotel FOREIGN KEY (fk_hotel) REFERENCES hotel(hot_codigo) ON DELETE CASCADE;
ALTER TABLE telefono ADD CONSTRAINT fk_tel_restaurante FOREIGN KEY (fk_restaurante) REFERENCES restaurante(res_codigo) ON DELETE CASCADE;

ALTER TABLE telefono ADD CONSTRAINT chk_telefono_origen CHECK (
        (fk_prov_codigo IS NOT NULL AND fk_hotel IS NULL AND fk_restaurante IS NULL) OR
        (fk_prov_codigo IS NULL AND fk_hotel IS NOT NULL AND fk_restaurante IS NULL) OR
        (fk_prov_codigo IS NULL AND fk_hotel IS NULL AND fk_restaurante IS NOT NULL)
    );

/* =========================================================
   SECCIÓN 4: VIAJEROS Y DOCUMENTACIÓN
   ========================================================= */
ALTER TABLE viajero ADD CONSTRAINT fk_usu_codigo_viajero FOREIGN KEY(fk_usu_codigo) REFERENCES usuario(usu_codigo);

ALTER TABLE documento ADD CONSTRAINT fk_nac_codigo_documento FOREIGN KEY(fk_nac_codigo) REFERENCES nacionalidad(nac_codigo);
ALTER TABLE documento ADD CONSTRAINT fk_via_codigo_documento FOREIGN KEY(fk_via_codigo) REFERENCES viajero(via_codigo);

ALTER TABLE via_edo ADD CONSTRAINT fk_via_codigo_via_edo FOREIGN KEY(fk_via_codigo) REFERENCES viajero(via_codigo);
ALTER TABLE via_edo ADD CONSTRAINT fk_edo_codigo_via_edo FOREIGN KEY(fk_edo_codigo) REFERENCES estado_civil(edo_civ_codigo);

/* =========================================================
   SECCIÓN 5: SERVICIOS Y PRODUCTOS
   ========================================================= */
ALTER TABLE plato ADD CONSTRAINT fk_plato_restaurante FOREIGN KEY (fk_restaurante) REFERENCES restaurante(res_codigo);

ALTER TABLE habitacion ADD CONSTRAINT fk_habitacion_hotel FOREIGN KEY (fk_hotel) REFERENCES hotel(hot_codigo);
ALTER TABLE habitacion ADD CONSTRAINT fk_habitacion_promocion FOREIGN KEY (fk_promocion) REFERENCES promocion(prom_codigo);

ALTER TABLE servicio ADD CONSTRAINT fk_ser_proveedor FOREIGN KEY (fk_prov_codigo) REFERENCES proveedor(prov_codigo);
ALTER TABLE servicio ADD CONSTRAINT check_ser_tipo CHECK (ser_tipo IN ('Alojamiento', 'Actividad', 'Seguro', 'Aerolinea', 'Terrestre', 'Maritimo', 'Transporte', 'Tour', 'Comida', 'Vuelo', 'Otros'));

ALTER TABLE ser_prom ADD CONSTRAINT fk_sp_servicio FOREIGN KEY (fk_ser_codigo) REFERENCES servicio(ser_codigo);
ALTER TABLE ser_prom ADD CONSTRAINT fk_sp_promocion FOREIGN KEY (fk_prom_codigo) REFERENCES promocion(prom_codigo);

ALTER TABLE paq_prom ADD CONSTRAINT fk_pp_paquete FOREIGN KEY (fk_paq_tur_codigo) REFERENCES paquete_turistico(paq_tur_codigo);
ALTER TABLE paq_prom ADD CONSTRAINT fk_pp_promocion FOREIGN KEY (fk_prom_codigo) REFERENCES promocion(prom_codigo);

ALTER TABLE tras_prom ADD CONSTRAINT fk_tp_traslado FOREIGN KEY (fk_tras_codigo) REFERENCES traslado(tras_codigo);
ALTER TABLE tras_prom ADD CONSTRAINT fk_tp_promocion FOREIGN KEY (fk_prom_codigo) REFERENCES promocion(prom_codigo);

ALTER TABLE reg_paq_paq ADD CONSTRAINT fk_rpp_regla FOREIGN KEY (fk_reg_paq_codigo) REFERENCES regla_paquete(reg_paq_codigo);
ALTER TABLE reg_paq_paq ADD CONSTRAINT fk_rpp_paquete FOREIGN KEY (fk_paq_tur_codigo) REFERENCES paquete_turistico(paq_tur_codigo);

ALTER TABLE paq_ser ADD CONSTRAINT fk_ps_paquete FOREIGN KEY (fk_paq_tur_codigo) REFERENCES paquete_turistico(paq_tur_codigo);
ALTER TABLE paq_ser ADD CONSTRAINT fk_ps_servicio FOREIGN KEY (fk_ser_codigo) REFERENCES servicio(ser_codigo);

ALTER TABLE paq_tras ADD CONSTRAINT fk_pt_paquete FOREIGN KEY (fk_paq_tur_codigo) REFERENCES paquete_turistico(paq_tur_codigo);
ALTER TABLE paq_tras ADD CONSTRAINT fk_pt_traslado FOREIGN KEY (fk_tras_codigo) REFERENCES traslado(tras_codigo);

/* =========================================================
   SECCIÓN 6: TRANSPORTE Y RUTAS
   ========================================================= */
ALTER TABLE terminal ADD CONSTRAINT fk_ter_lugar FOREIGN KEY (fk_lugar) REFERENCES lugar(lug_codigo);

ALTER TABLE medio_transporte ADD CONSTRAINT fk_mt_proveedor FOREIGN KEY (fk_prov_codigo) REFERENCES proveedor(prov_codigo);

ALTER TABLE puesto ADD CONSTRAINT fk_pue_medio FOREIGN KEY (fk_med_tra_codigo) REFERENCES medio_transporte(med_tra_codigo) ON DELETE CASCADE;

ALTER TABLE ruta ADD CONSTRAINT fk_rut_origen FOREIGN KEY (fk_terminal_origen) REFERENCES terminal(ter_codigo);
ALTER TABLE ruta ADD CONSTRAINT fk_rut_destino FOREIGN KEY (fk_terminal_destino) REFERENCES terminal(ter_codigo);
ALTER TABLE ruta ADD CONSTRAINT fk_rut_proveedor FOREIGN KEY (fk_prov_codigo) REFERENCES proveedor(prov_codigo);

ALTER TABLE traslado ADD CONSTRAINT fk_tras_ruta FOREIGN KEY (fk_rut_codigo) REFERENCES ruta(rut_codigo);
ALTER TABLE traslado ADD CONSTRAINT fk_tras_medio FOREIGN KEY (fk_med_tra_codigo) REFERENCES medio_transporte(med_tra_codigo);

/* =========================================================
   SECCIÓN 7: RESERVAS, COMPRAS Y PAGOS
   ========================================================= */
ALTER TABLE detalle_reserva ADD CONSTRAINT fk_det_res_viajero FOREIGN KEY (fk_viajero_codigo) REFERENCES viajero(via_codigo);
ALTER TABLE detalle_reserva ADD CONSTRAINT fk_det_res_compra FOREIGN KEY (fk_compra) REFERENCES compra(com_codigo);
ALTER TABLE detalle_reserva ADD CONSTRAINT fk_det_res_servicio FOREIGN KEY (fk_servicio) REFERENCES servicio(ser_codigo);
ALTER TABLE detalle_reserva ADD CONSTRAINT fk_det_res_paquete FOREIGN KEY (fk_paquete_turistico) REFERENCES paquete_turistico(paq_tur_codigo);

ALTER TABLE pue_tras ADD CONSTRAINT fk_pt_traslado FOREIGN KEY (fk_tras_codigo) REFERENCES traslado(tras_codigo);
ALTER TABLE pue_tras ADD CONSTRAINT fk_pt_puesto FOREIGN KEY (fk_med_tra_codigo, fk_pue_codigo) REFERENCES puesto(fk_med_tra_codigo, pue_codigo);
ALTER TABLE pue_tras ADD CONSTRAINT fk_pt_paquete FOREIGN KEY (fk_paq_tur_codigo) REFERENCES paquete_turistico(paq_tur_codigo);
ALTER TABLE pue_tras ADD CONSTRAINT un_asiento_por_vuelo UNIQUE (fk_tras_codigo, fk_pue_codigo, fk_med_tra_codigo);

ALTER TABLE reserva_de_habitacion ADD CONSTRAINT fk_res_hab_habitacion FOREIGN KEY (fk_habitacion) REFERENCES habitacion(hab_num_hab);
ALTER TABLE reserva_restaurante ADD CONSTRAINT fk_res_rest_restaurante FOREIGN KEY (fk_restaurante) REFERENCES restaurante(res_codigo);

-- Paquete / Detalle References (CRITICAL: Don't leave these out!)
ALTER TABLE reserva_de_habitacion ADD CONSTRAINT fk_res_hab_detalle FOREIGN KEY (fk_detalle_reserva, fk_detalle_reserva_2) REFERENCES detalle_reserva(fk_compra, det_res_codigo);
ALTER TABLE reserva_de_habitacion ADD CONSTRAINT fk_res_hab_paquete FOREIGN KEY (fk_paquete_turistico) REFERENCES paquete_turistico(paq_tur_codigo);

ALTER TABLE reserva_restaurante ADD CONSTRAINT fk_res_rest_detalle FOREIGN KEY (fk_detalle_reserva, fk_detalle_reserva_2) REFERENCES detalle_reserva(fk_compra, det_res_codigo);
ALTER TABLE reserva_restaurante ADD CONSTRAINT fk_res_rest_paquete FOREIGN KEY (fk_paquete_turistico) REFERENCES paquete_turistico(paq_tur_codigo);


ALTER TABLE reserva_de_habitacion
ADD CONSTRAINT chk_res_hab_exclusivity
CHECK (
    (
        -- es un fkn paquete
        fk_paquete_turistico IS NOT NULL 
        AND fk_detalle_reserva IS NULL 
        AND fk_detalle_reserva_2 IS NULL
    )
    OR
    (
        -- es una fkn reserva
        fk_paquete_turistico IS NULL 
        AND fk_detalle_reserva IS NOT NULL 
        AND fk_detalle_reserva_2 IS NOT NULL
    )
);

ALTER TABLE reserva_restaurante
ADD CONSTRAINT chk_res_rest_exclusivity
CHECK (
    (
        --lo mismo
        fk_paquete_turistico IS NOT NULL 
        AND fk_detalle_reserva IS NULL 
        AND fk_detalle_reserva_2 IS NULL
    )
    OR
    (
        fk_paquete_turistico IS NULL 
        AND fk_detalle_reserva IS NOT NULL 
        AND fk_detalle_reserva_2 IS NOT NULL
    )
);

ALTER TABLE compra ADD CONSTRAINT fk_compra_usuario FOREIGN KEY (fk_usuario) REFERENCES usuario(usu_codigo);
ALTER TABLE compra ADD CONSTRAINT fk_compra_plan FOREIGN KEY (fk_plan_financiamiento) REFERENCES plan_financiamiento(plan_fin_codigo);

ALTER TABLE plan_financiamiento ADD CONSTRAINT fk_plan_compra FOREIGN KEY (fk_compra) REFERENCES compra(com_codigo);
ALTER TABLE cuota ADD CONSTRAINT fk_cuota_plan FOREIGN KEY (fk_plan_financiamiento) REFERENCES plan_financiamiento(plan_fin_codigo);
ALTER TABLE compensacion ADD CONSTRAINT fk_compensacion_compra FOREIGN KEY (fk_compra) REFERENCES compra(com_codigo);

ALTER TABLE pago ADD CONSTRAINT fk_pago_compra FOREIGN KEY (fk_compra) REFERENCES compra(com_codigo);
ALTER TABLE pago ADD CONSTRAINT fk_pago_tasa FOREIGN KEY (fk_tasa_de_cambio) REFERENCES tasa_de_cambio(tas_cam_codigo);
ALTER TABLE pago ADD CONSTRAINT fk_pago_metodo FOREIGN KEY (fk_metodo_pago) REFERENCES metodo_pago(met_pag_codigo);

ALTER TABLE reembolso ADD CONSTRAINT fk_reembolso_pago FOREIGN KEY (fk_pago) REFERENCES pago(pag_codigo);

-- Métodos de pago específicos
ALTER TABLE tarjeta_credito ADD CONSTRAINT fk_metodo_pago_tc FOREIGN KEY (met_pago_codigo) REFERENCES metodo_pago(met_pag_codigo);
ALTER TABLE tarjeta_debito ADD CONSTRAINT fk_metodo_pago_td FOREIGN KEY (met_pago_codigo) REFERENCES metodo_pago(met_pag_codigo);
ALTER TABLE cheque ADD CONSTRAINT fk_metodo_pago_ch FOREIGN KEY (met_pago_codigo) REFERENCES metodo_pago(met_pag_codigo);
ALTER TABLE deposito_bancario ADD CONSTRAINT fk_metodo_pago_dep FOREIGN KEY (met_pago_codigo) REFERENCES metodo_pago(met_pag_codigo);
ALTER TABLE transferencia_bancaria ADD CONSTRAINT fk_metodo_pago_tr FOREIGN KEY (met_pago_codigo) REFERENCES metodo_pago(met_pag_codigo);
ALTER TABLE pago_movil_interbancario ADD CONSTRAINT fk_metodo_pago_pm FOREIGN KEY (met_pago_codigo) REFERENCES metodo_pago(met_pag_codigo);
ALTER TABLE criptomoneda ADD CONSTRAINT fk_metodo_pago_cr FOREIGN KEY (met_pago_codigo) REFERENCES metodo_pago(met_pag_codigo);
ALTER TABLE zelle ADD CONSTRAINT fk_metodo_pago_ze FOREIGN KEY (met_pago_codigo) REFERENCES metodo_pago(met_pag_codigo);
ALTER TABLE efectivo ADD CONSTRAINT fk_metodo_pago_ef FOREIGN KEY (met_pago_codigo) REFERENCES metodo_pago(met_pag_codigo);
ALTER TABLE milla_pago ADD CONSTRAINT fk_metodo_pago_mi FOREIGN KEY (met_pag_codigo) REFERENCES metodo_pago(met_pag_codigo);

/* =========================================================
   SECCIÓN 8: OTROS
   ========================================================= */
ALTER TABLE milla ADD CONSTRAINT fk_milla_compra FOREIGN KEY (fk_compra) REFERENCES compra(com_codigo);
ALTER TABLE milla ADD CONSTRAINT fk_milla_pago FOREIGN KEY (fk_pago) REFERENCES pago(pag_codigo);
ALTER TABLE milla_pago ADD CONSTRAINT fk_mil_pag_milla FOREIGN KEY (mil_codigo) REFERENCES milla(mil_codigo);

ALTER TABLE cuo_est ADD CONSTRAINT fk_cuo_est_cuota FOREIGN KEY (fk_cuo_codigo) REFERENCES cuota(cuo_codigo);
ALTER TABLE cuo_est ADD CONSTRAINT fk_cuo_est_estado FOREIGN KEY (fk_est_codigo) REFERENCES estado(est_codigo);

ALTER TABLE res_est ADD CONSTRAINT fk_res_est_estado FOREIGN KEY (fk_estado) REFERENCES estado(est_codigo);
ALTER TABLE res_est ADD CONSTRAINT fk_res_est_detalle FOREIGN KEY (fk_detalle_reserva_codigo, fk_detalle_reserva_2) REFERENCES detalle_reserva(fk_compra, det_res_codigo);

ALTER TABLE resena ADD CONSTRAINT fk_resena_detalle FOREIGN KEY (fk_detalle_reserva, fk_detalle_reserva_2) REFERENCES detalle_reserva(fk_compra, det_res_codigo);
ALTER TABLE reclamo ADD CONSTRAINT fk_reclamo_detalle FOREIGN KEY (fk_detalle_reserva, fk_detalle_reserva_2) REFERENCES detalle_reserva(fk_compra, det_res_codigo);

ALTER TABLE auditoria ADD CONSTRAINT fk_auditoria_accion FOREIGN KEY (fk_accion) REFERENCES accion(acc_codigo);
ALTER TABLE auditoria ADD CONSTRAINT fk_auditoria_recurso FOREIGN KEY (fk_recurso) REFERENCES recurso(recu_codigo);
ALTER TABLE auditoria ADD CONSTRAINT fk_auditoria_usuario FOREIGN KEY (fk_usuario) REFERENCES usuario(usu_codigo);

ALTER TABLE preferencia ADD CONSTRAINT fk_pref_usuario FOREIGN KEY (fk_usuario) REFERENCES usuario(usu_codigo);
ALTER TABLE preferencia ADD CONSTRAINT fk_pref_categoria FOREIGN KEY (fk_categoria) REFERENCES categoria(cat_codigo);

ALTER TABLE lista_deseos ADD CONSTRAINT fk_deseo_usuario FOREIGN KEY (fk_usuario) REFERENCES usuario(usu_codigo);
ALTER TABLE lista_deseos ADD CONSTRAINT fk_deseo_paquete FOREIGN KEY (fk_paquete_turistico) REFERENCES paquete_turistico(paq_tur_codigo);
ALTER TABLE lista_deseos ADD CONSTRAINT fk_deseo_servicio FOREIGN KEY (fk_servicio) REFERENCES servicio(ser_codigo);
ALTER TABLE lista_deseos ADD CONSTRAINT fk_deseo_traslado FOREIGN KEY (fk_traslado) REFERENCES traslado(tras_codigo);