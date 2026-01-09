-- =========================================================
-- SCRIPT DE LIMPIEZA TOTAL (DROP) - ORDEN CORREGIDO
-- =========================================================

-- 1. Tablas finales de dependencias (Hijos profundos)
DROP TABLE IF EXISTS milla_pago CASCADE;
DROP TABLE IF EXISTS milla CASCADE; -- Mover aquí arriba porque depende de Pago y Compra
DROP TABLE IF EXISTS reembolso CASCADE;

-- 2. Detalles de Métodos de Pago
DROP TABLE IF EXISTS efectivo CASCADE;
DROP TABLE IF EXISTS zelle CASCADE;
DROP TABLE IF EXISTS criptomoneda CASCADE;
DROP TABLE IF EXISTS pago_movil_interbancario CASCADE;
DROP TABLE IF EXISTS transferencia_bancaria CASCADE;
DROP TABLE IF EXISTS deposito_bancario CASCADE;
DROP TABLE IF EXISTS cheque CASCADE;
DROP TABLE IF EXISTS tarjeta_debito CASCADE;
DROP TABLE IF EXISTS tarjeta_credito CASCADE;

-- 3. Pagos y Financiamiento
DROP TABLE IF EXISTS pago CASCADE; -- Ahora sí se puede borrar, milla y reembolso ya no existen
DROP TABLE IF EXISTS metodo_pago CASCADE;
DROP TABLE IF EXISTS tipo_metodo_pago CASCADE; -- Agregado recientemente
DROP TABLE IF EXISTS cuo_est CASCADE;
DROP TABLE IF EXISTS cuota CASCADE;
DROP TABLE IF EXISTS plan_financiamiento CASCADE;
DROP TABLE IF EXISTS compensacion CASCADE;

-- 4. Gestión de Reservas y Opiniones
DROP TABLE IF EXISTS resena CASCADE;
DROP TABLE IF EXISTS reclamo CASCADE;
DROP TABLE IF EXISTS res_est CASCADE;
DROP TABLE IF EXISTS reserva_restaurante CASCADE;
DROP TABLE IF EXISTS reserva_de_habitacion CASCADE;
DROP TABLE IF EXISTS detalle_reserva CASCADE;

-- 5. Compras y Preferencias
DROP TABLE IF EXISTS lista_deseos CASCADE; -- Borrar antes que los productos
DROP TABLE IF EXISTS preferencia CASCADE;
DROP TABLE IF EXISTS compra CASCADE; -- Borrar aquí, ya no tiene hijos vivos

-- 6. Tablas Intermedias de Productos
DROP TABLE IF EXISTS reg_paq_paq CASCADE;
DROP TABLE IF EXISTS paq_ser CASCADE;
DROP TABLE IF EXISTS paq_tras CASCADE;
DROP TABLE IF EXISTS paq_prom CASCADE;
DROP TABLE IF EXISTS ser_prom CASCADE;
DROP TABLE IF EXISTS tras_prom CASCADE;
DROP TABLE IF EXISTS pue_tras CASCADE;

-- 7. Productos y Servicios Base
DROP TABLE IF EXISTS paquete_turistico CASCADE;
DROP TABLE IF EXISTS servicio CASCADE;
DROP TABLE IF EXISTS traslado CASCADE;
DROP TABLE IF EXISTS ruta CASCADE;
DROP TABLE IF EXISTS puesto CASCADE;
DROP TABLE IF EXISTS habitacion CASCADE;
DROP TABLE IF EXISTS plato CASCADE;
DROP TABLE IF EXISTS promocion CASCADE;
DROP TABLE IF EXISTS regla_paquete CASCADE;

-- 8. Proveedores e Infraestructura
DROP TABLE IF EXISTS restaurante CASCADE;
DROP TABLE IF EXISTS hotel CASCADE;
DROP TABLE IF EXISTS telefono CASCADE;
DROP TABLE IF EXISTS medio_transporte CASCADE;
DROP TABLE IF EXISTS terminal CASCADE;
DROP TABLE IF EXISTS proveedor CASCADE;

-- 9. Usuarios y Actores
DROP TABLE IF EXISTS documento CASCADE;
DROP TABLE IF EXISTS via_edo CASCADE;
DROP TABLE IF EXISTS viajero CASCADE;
DROP TABLE IF EXISTS auditoria CASCADE;
DROP TABLE IF EXISTS usuario CASCADE;

-- 10. Catálogos y Configuraciones (Tablas Padre absolutas)
DROP TABLE IF EXISTS rol_privilegio CASCADE;
DROP TABLE IF EXISTS privilegio CASCADE;
DROP TABLE IF EXISTS rol CASCADE;
DROP TABLE IF EXISTS nacionalidad CASCADE;
DROP TABLE IF EXISTS estado_civil CASCADE;
DROP TABLE IF EXISTS lugar CASCADE;
DROP TABLE IF EXISTS tasa_de_cambio CASCADE;
DROP TABLE IF EXISTS estado CASCADE;
DROP TABLE IF EXISTS accion CASCADE;
DROP TABLE IF EXISTS recurso CASCADE;
DROP TABLE IF EXISTS categoria CASCADE;