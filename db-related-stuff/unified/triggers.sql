




CREATE OR REPLACE FUNCTION tf_validar_puesto_traslado()
RETURNS TRIGGER AS $$
DECLARE
    v_avion_del_vuelo INTEGER;
BEGIN
    -- Obtenemos qué avión está asignado al traslado
    SELECT fk_med_tra_codigo INTO v_avion_del_vuelo
    FROM traslado
    WHERE tras_codigo = NEW.fk_tras_codigo;

    -- Verificamos si coincide con el avión del asiento
    IF v_avion_del_vuelo <> NEW.fk_med_tra_codigo THEN
        RAISE EXCEPTION 'Inconsistencia: El asiento pertenece al transporte % pero el traslado usa el transporte %.', 
        NEW.fk_med_tra_codigo, v_avion_del_vuelo;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar Trigger
DROP TRIGGER IF EXISTS tg_check_puesto_traslado ON pue_tras;

CREATE TRIGGER tg_check_puesto_traslado
BEFORE INSERT OR UPDATE ON pue_tras
FOR EACH ROW
EXECUTE FUNCTION tf_validar_puesto_traslado();




---Profe, si esta leyendo esto, tuvimos un error en la relacion de paquete con traslado y bueno, asi lo arreglamos xd
-- FUNCIÓN DEL TRIGGER
CREATE OR REPLACE FUNCTION fn_asignar_traslados_automaticos()
RETURNS TRIGGER AS $$
DECLARE
    rec_traslado RECORD;
    v_pue_tras_id INTEGER;
    v_asiento_descripcion VARCHAR;
    v_costo_traslado NUMERIC;
BEGIN
    -- 1. Verificar si la reserva es de un PAQUETE
    IF NEW.fk_paquete_turistico IS NOT NULL THEN
        
        -- 2. Iterar sobre todos los traslados asociados a ese paquete
        FOR rec_traslado IN 
            SELECT fk_tras_codigo 
            FROM paq_tras 
            WHERE fk_paq_tur_codigo = NEW.fk_paquete_turistico
        LOOP
            -- 3. Buscar UN asiento disponible para ese traslado
            -- Disponible = Existe en pue_tras pero NO está en detalle_reserva asociado a una compra válida
            SELECT pt.pue_tras_codigo, p.pue_descripcion, r.rut_costo
            INTO v_pue_tras_id, v_asiento_descripcion, v_costo_traslado
            FROM pue_tras pt
            JOIN traslado t ON pt.fk_tras_codigo = t.tras_codigo
            JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
            JOIN puesto p ON pt.fk_med_tra_codigo = p.fk_med_tra_codigo AND pt.fk_pue_codigo = p.pue_codigo
            LEFT JOIN detalle_reserva dr ON pt.pue_tras_codigo = dr.fk_pue_tras
            WHERE pt.fk_tras_codigo = rec_traslado.fk_tras_codigo
              AND dr.det_res_codigo IS NULL -- Que nadie lo haya reservado
            LIMIT 1;

            -- 4. Si encontramos asiento, creamos el boleto
            IF v_pue_tras_id IS NOT NULL THEN
                INSERT INTO detalle_reserva (
                    det_res_codigo, -- Asumiendo que generas este ID o usas SERIAL en tu backend, aquí uso random para ejemplo si no es serial
                    det_res_fecha_creacion,
                    det_res_hora_creacion,
                    det_res_monto_total,
                    det_res_sub_total,
                    fk_viajero_codigo,
                    fk_viajero_numero,
                    fk_compra,
                    fk_servicio,
                    fk_paquete_turistico,
                    fk_pue_tras,
                    det_res_estado
                ) VALUES (
                    (SELECT COALESCE(MAX(det_res_codigo), 0) + 1 FROM detalle_reserva), -- Simulación de autoincrement
                    CURRENT_DATE,
                    CURRENT_TIME,
                    0, -- El costo ya está incluido en el paquete, ponemos 0 o referencial
                    0, 
                    NEW.fk_viajero_codigo, -- El mismo viajero del paquete
                    NEW.fk_viajero_numero,
                    NEW.fk_compra,         -- La misma compra
                    NULL,
                    NULL, -- No es un paquete, es el asiento individual derivado
                    v_pue_tras_id, -- El asiento encontrado
                    'Confirmada'
                );
            ELSE
                RAISE NOTICE 'No se encontraron asientos disponibles para el traslado % del paquete', rec_traslado.fk_tras_codigo;
                -- Opcional: Podrías hacer RAISE EXCEPTION si es obligatorio tener asiento
            END IF;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- CREACIÓN DEL TRIGGER
DROP TRIGGER IF EXISTS trg_auto_asignar_traslado ON detalle_reserva;

CREATE TRIGGER trg_auto_asignar_traslado
AFTER INSERT ON detalle_reserva
FOR EACH ROW
EXECUTE FUNCTION fn_asignar_traslados_automaticos();



-- Función de validación
CREATE OR REPLACE FUNCTION fn_validar_fecha_servicio_paquete()
RETURNS TRIGGER AS $$
DECLARE
    v_fecha_inicio TIMESTAMP;
BEGIN
    -- Obtenemos la fecha del servicio que intentan asociar
    SELECT ser_fecha_hora_inicio INTO v_fecha_inicio
    FROM servicio
    WHERE ser_codigo = NEW.fk_ser_codigo;

    -- Validamos: Si la fecha es menor o igual a HOY (ya pasó o es hoy), lanzamos error.
    IF v_fecha_inicio::DATE <= CURRENT_DATE THEN
        RAISE EXCEPTION 'Error de Negocio: No se puede agregar el servicio "%" (ID: %) al paquete porque su fecha de inicio (%) ya transcurrió o es hoy.', 
        NEW.fk_ser_codigo, NEW.fk_ser_codigo, v_fecha_inicio;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger asociado
DROP TRIGGER IF EXISTS trg_chk_fecha_servicio_paquete ON paq_ser;
CREATE TRIGGER trg_chk_fecha_servicio_paquete
BEFORE INSERT OR UPDATE ON paq_ser
FOR EACH ROW
EXECUTE FUNCTION fn_validar_fecha_servicio_paquete();



-- Función de validación
CREATE OR REPLACE FUNCTION fn_validar_fecha_traslado_paquete()
RETURNS TRIGGER AS $$
DECLARE
    v_fecha_inicio TIMESTAMP;
BEGIN
    -- Obtenemos la fecha del traslado
    SELECT tras_fecha_hora_inicio INTO v_fecha_inicio
    FROM traslado
    WHERE tras_codigo = NEW.fk_tras_codigo;

    -- Validamos
    IF v_fecha_inicio::DATE <= CURRENT_DATE THEN
        RAISE EXCEPTION 'Error de Negocio: No se puede agregar el traslado (ID: %) al paquete porque su fecha de salida (%) ya transcurrió o es hoy.', 
        NEW.fk_tras_codigo, v_fecha_inicio;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger asociado
DROP TRIGGER IF EXISTS trg_chk_fecha_traslado_paquete ON paq_tras;
CREATE TRIGGER trg_chk_fecha_traslado_paquete
BEFORE INSERT OR UPDATE ON paq_tras
FOR EACH ROW
EXECUTE FUNCTION fn_validar_fecha_traslado_paquete();


-- Función de validación compleja
CREATE OR REPLACE FUNCTION fn_validar_fechas_reserva()
RETURNS TRIGGER AS $$
DECLARE
    v_fecha_servicio TIMESTAMP;
    v_fecha_traslado TIMESTAMP;
BEGIN
    -- CASO A: Si la reserva incluye un SERVICIO
    IF NEW.fk_servicio IS NOT NULL THEN
        SELECT ser_fecha_hora_inicio INTO v_fecha_servicio
        FROM servicio
        WHERE ser_codigo = NEW.fk_servicio;

        IF v_fecha_servicio::DATE <= CURRENT_DATE THEN
            RAISE EXCEPTION 'Reserva Inválida: El servicio seleccionado (ID: %) tiene fecha % que ya pasó o es hoy.', 
            NEW.fk_servicio, v_fecha_servicio;
        END IF;
    END IF;

    -- CASO B: Si la reserva incluye un ASIENTO DE TRASLADO (pue_tras)
    IF NEW.fk_pue_tras IS NOT NULL THEN
        -- Tenemos que hacer JOIN con traslado porque pue_tras no tiene la fecha directa
        SELECT t.tras_fecha_hora_inicio INTO v_fecha_traslado
        FROM pue_tras pt
        JOIN traslado t ON pt.fk_tras_codigo = t.tras_codigo
        WHERE pt.pue_tras_codigo = NEW.fk_pue_tras;

        IF v_fecha_traslado::DATE <= CURRENT_DATE THEN
            RAISE EXCEPTION 'Reserva Inválida: El traslado seleccionado (Asiento ID: %) tiene fecha de salida % que ya pasó o es hoy.', 
            NEW.fk_pue_tras, v_fecha_traslado;
        END IF;
    END IF;

    -- Nota: No validamos fk_paquete_turistico aquí porque se asume que
    -- si el paquete se creó, sus elementos internos ya pasaron por los triggers 1 y 2.
    -- Pero si quisieras validarlo al momento de la compra también, dímelo.

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger asociado
DROP TRIGGER IF EXISTS trg_chk_fechas_reserva ON detalle_reserva;
CREATE TRIGGER trg_chk_fechas_reserva
BEFORE INSERT OR UPDATE ON detalle_reserva
FOR EACH ROW
EXECUTE FUNCTION fn_validar_fechas_reserva();



-- Función del Trigger
CREATE OR REPLACE FUNCTION fn_procesar_millas_reserva()
RETURNS TRIGGER AS $$
DECLARE
    v_millas_ganadas INTEGER := 0;
    v_usuario_id INTEGER;
    v_pago_id INTEGER;
BEGIN
    -- 1. Calcular Millas según el tipo de producto
    -- A. Si es Traslado (Asiento de avión/bus)
    IF NEW.fk_pue_tras IS NOT NULL THEN
        SELECT r.rut_millas_otorgadas INTO v_millas_ganadas
        FROM pue_tras pt
        JOIN traslado t ON pt.fk_tras_codigo = t.tras_codigo
        JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
        WHERE pt.pue_tras_codigo = NEW.fk_pue_tras;
    
    -- B. Si es Servicio Genérico
    ELSIF NEW.fk_servicio IS NOT NULL THEN
        SELECT ser_millas_otorgadas INTO v_millas_ganadas
        FROM servicio WHERE ser_codigo = NEW.fk_servicio;

    -- C. Si es Paquete Turístico
    ELSIF NEW.fk_paquete_turistico IS NOT NULL THEN
        SELECT paq_tur_costo_en_millas INTO v_millas_ganadas -- Usamos el costo como referencia de ganancia (o ajusta si tienes columna 'ganancia')
        FROM paquete_turistico WHERE paq_tur_codigo = NEW.fk_paquete_turistico;
    END IF;

    -- 2. Si hay millas que otorgar, procedemos
    IF v_millas_ganadas > 0 THEN
        
        -- Obtener ID del Usuario dueño de la compra
        SELECT fk_usuario INTO v_usuario_id 
        FROM compra WHERE com_codigo = NEW.fk_compra;

        -- Actualizar saldo del usuario
        UPDATE usuario 
        SET usu_total_millas = usu_total_millas + v_millas_ganadas
        WHERE usu_codigo = v_usuario_id;

        -- Intentar obtener el pago asociado a esta compra (para la FK obligatoria)
        -- Tomamos el primer pago registrado para esta compra (ej: la inicial o pago total)
        SELECT pag_codigo INTO v_pago_id 
        FROM pago WHERE fk_compra = NEW.fk_compra LIMIT 1;

        -- Si no hay pago aun (ej: inserción en misma transacción), este insert podría fallar por FK.
        -- SOLUCIÓN: Si tu lógica de negocio inserta Pago DESPUÉS de Detalle, este trigger debería ser AFTER INSERT ON pago, no detalle.
        -- Pero como pediste trigger al relacionar detalle, asumiremos que existe un pago o manejaremos la excepción.
        
        IF v_pago_id IS NOT NULL THEN
            INSERT INTO milla (
                mil_valor_obtenido, 
                mil_fecha_inicio, 
                mil_fecha_fin, 
                mil_valor_restado, 
                fk_compra, 
                fk_pago
            ) VALUES (
                v_millas_ganadas, 
                CURRENT_DATE, 
                CURRENT_DATE + INTERVAL '1 year', -- Vencen en 1 año
                0, 
                NEW.fk_compra, 
                v_pago_id
            );
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Creación del Trigger
DROP TRIGGER IF EXISTS trg_calcular_millas ON detalle_reserva;

CREATE TRIGGER trg_calcular_millas
AFTER INSERT ON detalle_reserva
FOR EACH ROW
EXECUTE FUNCTION fn_procesar_millas_reserva();


BEGIN;

-- 1. ELIMINAR EL TRIGGER ERRÓNEO (El que se dispara en detalle_reserva)
DROP TRIGGER IF EXISTS trg_otorgar_millas ON detalle_reserva;
DROP FUNCTION IF EXISTS fn_otorgar_millas_compra();

-- 2. CREAR NUEVA FUNCIÓN PARA CALCULAR MILLAS AL PAGAR
CREATE OR REPLACE FUNCTION fn_otorgar_millas_al_pagar()
RETURNS TRIGGER AS $$
DECLARE
    v_millas_totales INTEGER := 0;
    v_usuario_id INTEGER;
BEGIN
    -- A. Sumar todas las millas acumuladas por los detalles de ESTA compra
    SELECT COALESCE(SUM(
        CASE
            -- Si es Traslado
            WHEN dr.fk_pue_tras IS NOT NULL THEN (
                SELECT r.rut_millas_otorgadas 
                FROM pue_tras pt 
                JOIN traslado t ON pt.fk_tras_codigo = t.tras_codigo 
                JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo 
                WHERE pt.pue_tras_codigo = dr.fk_pue_tras
            )
            -- Si es Servicio
            WHEN dr.fk_servicio IS NOT NULL THEN (
                SELECT ser_millas_otorgadas 
                FROM servicio 
                WHERE ser_codigo = dr.fk_servicio
            )
            -- Si es Paquete
            WHEN dr.fk_paquete_turistico IS NOT NULL THEN (
                SELECT paq_tur_costo_en_millas 
                FROM paquete_turistico 
                WHERE paq_tur_codigo = dr.fk_paquete_turistico
            )
            ELSE 0
        END
    ), 0) INTO v_millas_totales
    FROM detalle_reserva dr
    WHERE dr.fk_compra = NEW.fk_compra;

    -- B. Si ganó millas, procesarlas
    IF v_millas_totales > 0 THEN
        -- Obtener usuario dueño de la compra
        SELECT fk_usuario INTO v_usuario_id FROM compra WHERE com_codigo = NEW.fk_compra;

        -- 1. Actualizar saldo del usuario
        UPDATE usuario 
        SET usu_total_millas = usu_total_millas + v_millas_totales
        WHERE usu_codigo = v_usuario_id;

        -- 2. Insertar historial en tabla 'milla'
        -- AHORA SÍ TENEMOS NEW.pag_codigo PORQUE EL DISPARADOR ES LA TABLA PAGO
        INSERT INTO milla (
            mil_valor_obtenido, 
            mil_fecha_inicio, 
            mil_fecha_fin, 
            mil_valor_restado, 
            fk_compra, 
            fk_pago
        ) VALUES (
            v_millas_totales, 
            CURRENT_DATE, 
            CURRENT_DATE + INTERVAL '1 year', -- Vencen en 1 año
            0, 
            NEW.fk_compra, 
            NEW.pag_codigo -- <--- ¡Aquí está la solución!
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. ASOCIAR EL TRIGGER A LA TABLA PAGO (AFTER INSERT)
DROP TRIGGER IF EXISTS trg_millas_al_pagar ON pago;

CREATE TRIGGER trg_millas_al_pagar
AFTER INSERT ON pago
FOR EACH ROW
EXECUTE FUNCTION fn_otorgar_millas_al_pagar();

COMMIT;

BEGIN;

-- 1. Función del Trigger
CREATE OR REPLACE FUNCTION fn_generar_asientos_traslado()
RETURNS TRIGGER AS $$
BEGIN
    -- Insertar automáticamente en el inventario (pue_tras)
    -- copiando la configuración de puestos del avión (medio_transporte)
    INSERT INTO pue_tras (fk_tras_codigo, fk_pue_codigo, fk_med_tra_codigo, disponible)
    SELECT 
        NEW.tras_codigo,        -- ID del nuevo vuelo
        pue_codigo,             -- ID del asiento (1, 2, 3...)
        NEW.fk_med_tra_codigo,  -- ID del avión
        TRUE                    -- Disponible por defecto
    FROM puesto
    WHERE fk_med_tra_codigo = NEW.fk_med_tra_codigo;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Creación del Trigger
DROP TRIGGER IF EXISTS trg_generar_inventario_vuelo ON traslado;

CREATE TRIGGER trg_generar_inventario_vuelo
AFTER INSERT ON traslado
FOR EACH ROW
EXECUTE FUNCTION fn_generar_asientos_traslado();

COMMIT;