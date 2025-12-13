
CREATE OR REPLACE FUNCTION fn_calcular_puesto_id()
RETURNS TRIGGER AS $$
BEGIN

    NEW.pue_codigo := (
        SELECT COALESCE(MAX(pue_codigo), 0) + 1
        FROM puesto
        WHERE fk_med_tra_codigo = NEW.fk_med_tra_codigo
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auto_puesto_id
BEFORE INSERT ON puesto
FOR EACH ROW
EXECUTE FUNCTION fn_calcular_puesto_id();



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