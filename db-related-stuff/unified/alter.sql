/* =========================================================
   SECCIÓN 1: USUARIOS, ROLES Y PRIVILEGIOS
   ========================================================= */

-- Relación Usuario -> Rol
ALTER TABLE usuario
ADD CONSTRAINT fk_rol_usuario
FOREIGN KEY (fk_rol_codigo) REFERENCES rol(rol_codigo);

-- Relación Rol_Privilegio
ALTER TABLE rol_privilegio
ADD CONSTRAINT fk_rol_privilegio_rol
FOREIGN KEY (fk_rol_codigo) REFERENCES rol(rol_codigo),
ADD CONSTRAINT fk_rol_privilegio_privilegio
FOREIGN KEY (fk_pri_codigo) REFERENCES privilegio(pri_codigo);

/* =========================================================
   SECCIÓN 2: UBICACIÓN Y LUGARES
   ========================================================= */

-- Relación recursiva de Lugar
ALTER TABLE lugar 
ADD CONSTRAINT fk_ubica_lugar FOREIGN KEY (fk_lugar) REFERENCES lugar(lug_codigo)
ON DELETE CASCADE;

-- Asignar Lugar a las entidades principales
ALTER TABLE restaurante
ADD CONSTRAINT fk_lugar_restaurante FOREIGN KEY (fk_lugar) REFERENCES lugar(lug_codigo);

ALTER TABLE hotel
ADD CONSTRAINT fk_lugar_hotel FOREIGN KEY (fk_lugar) REFERENCES lugar(lug_codigo);

ALTER TABLE proveedor
ADD CONSTRAINT fk_lugar_proveedor FOREIGN KEY (fk_lugar) REFERENCES lugar(lug_codigo);

ALTER TABLE terminal
ADD CONSTRAINT fk_ter_lugar FOREIGN KEY (fk_lugar) REFERENCES lugar(lug_codigo);

ALTER TABLE usuario
ADD CONSTRAINT fk_usu_lugar FOREIGN KEY (fk_lugar) REFERENCES lugar(lug_codigo);

/* =========================================================
   SECCIÓN 3: PROVEEDORES Y CONTACTO
   ========================================================= */

-- Relación Proveedor -> Usuario
ALTER TABLE proveedor
ADD CONSTRAINT fk_usu_codigo_proveedor FOREIGN KEY (fk_usu_codigo) REFERENCES usuario(usu_codigo);

-- Relaciones de Teléfono (Arco exclusivo)
ALTER TABLE telefono
    ADD CONSTRAINT fk_tel_proveedor FOREIGN KEY (fk_prov_codigo) REFERENCES proveedor(prov_codigo) ON DELETE CASCADE,
    ADD CONSTRAINT fk_tel_hotel FOREIGN KEY (fk_hotel) REFERENCES hotel(hot_codigo) ON DELETE CASCADE,
    ADD CONSTRAINT fk_tel_restaurante FOREIGN KEY (fk_restaurante) REFERENCES restaurante(res_codigo) ON DELETE CASCADE;

ALTER TABLE telefono
    ADD CONSTRAINT chk_telefono_origen 
    CHECK (
        (fk_prov_codigo IS NOT NULL AND fk_hotel IS NULL AND fk_restaurante IS NULL) OR
        (fk_prov_codigo IS NULL AND fk_hotel IS NOT NULL AND fk_restaurante IS NULL) OR
        (fk_prov_codigo IS NULL AND fk_hotel IS NULL AND fk_restaurante IS NOT NULL)
    );

/* =========================================================
   SECCIÓN 4: VIAJEROS Y DOCUMENTACIÓN
   ========================================================= */

ALTER TABLE viajero
ADD CONSTRAINT fk_usu_codigo_viajero FOREIGN KEY(fk_usu_codigo) REFERENCES usuario(usu_codigo);

ALTER TABLE documento
ADD CONSTRAINT fk_nac_codigo_documento FOREIGN KEY(fk_nac_codigo) REFERENCES nacionalidad(nac_codigo),
ADD CONSTRAINT fk_via_codigo_documento FOREIGN KEY(fk_via_codigo) REFERENCES viajero(via_codigo);

ALTER TABLE via_edo
ADD CONSTRAINT fk_via_codigo_via_edo FOREIGN KEY(fk_via_codigo) REFERENCES viajero(via_codigo),
ADD CONSTRAINT fk_edo_codigo_via_edo FOREIGN KEY(fk_edo_codigo) REFERENCES estado_civil(edo_civ_codigo);

/* =========================================================
   SECCIÓN 5: SERVICIOS, PRODUCTOS Y PAQUETES
   ========================================================= */

-- Platos y Habitaciones
ALTER TABLE plato
ADD CONSTRAINT fk_plato_restaurante FOREIGN KEY (fk_restaurante) REFERENCES restaurante(res_codigo);

ALTER TABLE habitacion
ADD CONSTRAINT fk_habitacion_hotel FOREIGN KEY (fk_hotel) REFERENCES hotel(hot_codigo),
ADD CONSTRAINT fk_habitacion_promocion FOREIGN KEY (fk_promocion) REFERENCES promocion(prom_codigo);

-- Servicio General
ALTER TABLE servicio
    ADD CONSTRAINT fk_ser_proveedor FOREIGN KEY (fk_prov_codigo) REFERENCES proveedor(prov_codigo),
    ADD CONSTRAINT check_ser_tipo CHECK (ser_tipo IN ('Alojamiento', 'Actividad', 'Seguro', 'Aerolinea', 'Terrestre', 'Maritimo', 'Otros'));

-- Relaciones con Promociones
ALTER TABLE ser_prom
    ADD CONSTRAINT fk_sp_servicio FOREIGN KEY (fk_ser_codigo) REFERENCES servicio(ser_codigo),
    ADD CONSTRAINT fk_sp_promocion FOREIGN KEY (fk_prom_codigo) REFERENCES promocion(prom_codigo);

ALTER TABLE paq_prom
    ADD CONSTRAINT fk_pp_paquete FOREIGN KEY (fk_paq_tur_codigo) REFERENCES paquete_turistico(paq_tur_codigo),
    ADD CONSTRAINT fk_pp_promocion FOREIGN KEY (fk_prom_codigo) REFERENCES promocion(prom_codigo);

ALTER TABLE tras_prom
    ADD CONSTRAINT fk_tp_traslado FOREIGN KEY (fk_tras_codigo) REFERENCES traslado(tras_codigo),
    ADD CONSTRAINT fk_tp_promocion FOREIGN KEY (fk_prom_codigo) REFERENCES promocion(prom_codigo);

-- Configuración de Paquetes
ALTER TABLE reg_paq_paq
    ADD CONSTRAINT fk_rpp_regla FOREIGN KEY (fk_reg_paq_codigo) REFERENCES regla_paquete(reg_paq_codigo),
    ADD CONSTRAINT fk_rpp_paquete FOREIGN KEY (fk_paq_tur_codigo) REFERENCES paquete_turistico(paq_tur_codigo);

ALTER TABLE paq_ser
    ADD CONSTRAINT fk_ps_paquete FOREIGN KEY (fk_paq_tur_codigo) REFERENCES paquete_turistico(paq_tur_codigo),
    ADD CONSTRAINT fk_ps_servicio FOREIGN KEY (fk_ser_codigo) REFERENCES servicio(ser_codigo);

ALTER TABLE paq_tras
    ADD CONSTRAINT fk_pt_paquete FOREIGN KEY (fk_paq_tur_codigo) REFERENCES paquete_turistico(paq_tur_codigo),
    ADD CONSTRAINT fk_pt_traslado FOREIGN KEY (fk_tras_codigo) REFERENCES traslado(tras_codigo);

/* =========================================================
   SECCIÓN 6: TRANSPORTE Y RUTAS
   ========================================================= */
-- NOTA: Se eliminó ALTER TABLE PUESTO porque ya estaba en el CREATE

ALTER TABLE terminal
    ADD CONSTRAINT check_ter_tipo CHECK(ter_tipo IN ('Aeropuerto', 'Terminal Terrestre', 'Puerto', 'Estacion'));

ALTER TABLE medio_transporte
    ADD CONSTRAINT fk_mt_proveedor FOREIGN KEY (fk_prov_codigo) REFERENCES proveedor(prov_codigo),
    ADD CONSTRAINT check_med_tra_tipo CHECK(med_tra_tipo IN ('Avion', 'Autobus', 'Barco', 'Ferry', 'Tren', 'Van'));

ALTER TABLE ruta
    ADD CONSTRAINT fk_rut_origen FOREIGN KEY (fk_terminal_origen) REFERENCES terminal(ter_codigo),
    ADD CONSTRAINT fk_rut_destino FOREIGN KEY (fk_terminal_destino) REFERENCES terminal(ter_codigo),
    ADD CONSTRAINT fk_rut_proveedor FOREIGN KEY (fk_prov_codigo) REFERENCES proveedor(prov_codigo);

ALTER TABLE traslado
    ADD CONSTRAINT fk_tras_ruta FOREIGN KEY (fk_rut_codigo) REFERENCES ruta(rut_codigo),
    ADD CONSTRAINT fk_tras_medio FOREIGN KEY (fk_med_tra_codigo) REFERENCES medio_transporte(med_tra_codigo);

/* =========================================================
   SECCIÓN 7: RESERVAS Y TRANSACCIONES (NÚCLEO)
   ========================================================= */

-- Detalle de Reserva
ALTER TABLE detalle_reserva
    ADD CONSTRAINT fk_det_res_viajero FOREIGN KEY (fk_viajero_codigo) REFERENCES viajero(via_codigo),
    ADD CONSTRAINT fk_det_res_compra FOREIGN KEY (fk_compra) REFERENCES compra(com_codigo),
    ADD CONSTRAINT fk_det_res_servicio FOREIGN KEY (fk_servicio) REFERENCES servicio(ser_codigo),
    ADD CONSTRAINT fk_det_res_paquete FOREIGN KEY (fk_paquete_turistico) REFERENCES paquete_turistico(paq_tur_codigo);

-- Tabla Pue_Tras
ALTER TABLE pue_tras
    ADD CONSTRAINT fk_pt_traslado FOREIGN KEY (fk_tra_codigo) REFERENCES traslado(tras_codigo),
    ADD CONSTRAINT fk_pt_puesto FOREIGN KEY (fk_puesto_2, fk_puesto_codigo) REFERENCES puesto(fk_med_tra_codigo, pue_codigo), 
    ADD CONSTRAINT fk_pt_detalle FOREIGN KEY (fk_detalle_reserva, fk_detalle_reserva_2) REFERENCES detalle_reserva(fk_compra, det_res_codigo); 

-- Reservas Específicas
ALTER TABLE reserva_de_habitacion
    ADD CONSTRAINT fk_res_hab_habitacion FOREIGN KEY (fk_habitacion) REFERENCES habitacion(hab_num_hab),
    ADD CONSTRAINT fk_res_hab_detalle FOREIGN KEY (fk_detalle_reserva, fk_detalle_reserva_2) REFERENCES detalle_reserva(fk_compra, det_res_codigo),
    ADD CONSTRAINT fk_res_hab_paquete FOREIGN KEY (fk_paquete_turistico) REFERENCES paquete_turistico(paq_tur_codigo);

ALTER TABLE reserva_restaurante
    ADD CONSTRAINT fk_res_rest_restaurante FOREIGN KEY (fk_restaurante) REFERENCES restaurante(res_codigo),
    ADD CONSTRAINT fk_res_rest_detalle FOREIGN KEY (fk_detalle_reserva, fk_detalle_reserva_2) REFERENCES detalle_reserva(fk_compra, det_res_codigo),
    ADD CONSTRAINT fk_res_rest_paquete FOREIGN KEY (fk_paquete_turistico) REFERENCES paquete_turistico(paq_tur_codigo);

/* =========================================================
   SECCIÓN 8: COMPRA, FINANCIAMIENTO Y PAGOS
   ========================================================= */

ALTER TABLE compra
    ADD CONSTRAINT fk_compra_usuario FOREIGN KEY (fk_usuario) REFERENCES usuario(usu_codigo),
    ADD CONSTRAINT fk_compra_plan FOREIGN KEY (fk_plan_financiamiento) REFERENCES plan_financiamiento(plan_fin_codigo);

ALTER TABLE plan_financiamiento
    ADD CONSTRAINT fk_plan_compra FOREIGN KEY (fk_compra) REFERENCES compra(com_codigo);

ALTER TABLE cuota
    ADD CONSTRAINT fk_cuota_plan FOREIGN KEY (fk_plan_financiamiento) REFERENCES plan_financiamiento(plan_fin_codigo);

ALTER TABLE compensacion
    ADD CONSTRAINT fk_compensacion_compra FOREIGN KEY (fk_compra) REFERENCES compra(com_codigo);

-- Pagos
-- (Se eliminaron los ALTER de tarjetas, cheque, zelle, etc. porque ya estaban en el CREATE)
ALTER TABLE pago
    ADD CONSTRAINT fk_pago_compra FOREIGN KEY (fk_compra) REFERENCES compra(com_codigo),
    ADD CONSTRAINT fk_pago_tasa FOREIGN KEY (fk_tasa_de_cambio) REFERENCES tasa_de_cambio(tas_cam_codigo),
    ADD CONSTRAINT fk_pago_metodo FOREIGN KEY (fk_metodo_pago) REFERENCES metodo_pago(met_pag_codigo);

ALTER TABLE reembolso
    ADD CONSTRAINT fk_reembolso_pago FOREIGN KEY (fk_pago) REFERENCES pago(pag_codigo);

-- Millas
ALTER TABLE milla
    ADD CONSTRAINT fk_milla_compra FOREIGN KEY (fk_compra) REFERENCES compra(com_codigo),
    ADD CONSTRAINT fk_milla_pago FOREIGN KEY (fk_pago) REFERENCES pago(pag_codigo);

ALTER TABLE milla_pago
    ADD CONSTRAINT fk_mil_pag_milla FOREIGN KEY (mil_codigo) REFERENCES milla(mil_codigo);

/* =========================================================
   SECCIÓN 9: FEEDBACK, HISTORIAL Y AUDITORÍA
   ========================================================= */

-- Historial de Estados
ALTER TABLE cuo_est
    ADD CONSTRAINT fk_cuo_est_cuota FOREIGN KEY (fk_cuo_codigo) REFERENCES cuota(cuo_codigo),
    ADD CONSTRAINT fk_cuo_est_estado FOREIGN KEY (fk_est_codigo) REFERENCES estado(est_codigo);

ALTER TABLE res_est
    ADD CONSTRAINT fk_res_est_estado FOREIGN KEY (fk_estado) REFERENCES estado(est_codigo),
    ADD CONSTRAINT fk_res_est_detalle FOREIGN KEY (fk_detalle_reserva_codigo, fk_detalle_reserva_2) REFERENCES detalle_reserva(fk_compra, det_res_codigo);

-- Reseñas y Reclamos
ALTER TABLE resena
    ADD CONSTRAINT fk_resena_detalle FOREIGN KEY (fk_detalle_reserva, fk_detalle_reserva_2) REFERENCES detalle_reserva(fk_compra, det_res_codigo);

ALTER TABLE reclamo
    ADD CONSTRAINT fk_reclamo_detalle FOREIGN KEY (fk_detalle_reserva, fk_detalle_reserva_2) REFERENCES detalle_reserva(fk_compra, det_res_codigo);

-- Auditoría
ALTER TABLE auditoria
    ADD CONSTRAINT fk_auditoria_accion FOREIGN KEY (fk_accion) REFERENCES accion(acc_codigo),
    ADD CONSTRAINT fk_auditoria_recurso FOREIGN KEY (fk_recurso) REFERENCES recurso(recu_codigo),
    ADD CONSTRAINT fk_auditoria_usuario FOREIGN KEY (fk_usuario) REFERENCES usuario(usu_codigo);

-- Preferencias y Lista de Deseos
ALTER TABLE preferencia
    ADD CONSTRAINT fk_pref_usuario FOREIGN KEY (fk_usuario) REFERENCES usuario(usu_codigo),
    ADD CONSTRAINT fk_pref_categoria FOREIGN KEY (fk_categoria) REFERENCES categoria(cat_codigo);

ALTER TABLE lista_deseos
    ADD CONSTRAINT fk_deseo_usuario FOREIGN KEY (fk_usuario) REFERENCES usuario(usu_codigo),
    ADD CONSTRAINT fk_deseo_paquete FOREIGN KEY (fk_paquete_turistico) REFERENCES paquete_turistico(paq_tur_codigo),
    ADD CONSTRAINT fk_deseo_servicio FOREIGN KEY (fk_servicio) REFERENCES servicio(ser_codigo),
    ADD CONSTRAINT fk_deseo_traslado FOREIGN KEY (fk_traslado) REFERENCES traslado(tras_codigo);