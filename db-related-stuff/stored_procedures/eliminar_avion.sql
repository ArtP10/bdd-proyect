CREATE OR REPLACE PROCEDURE sp_eliminar_avion(
    IN i_usu_codigo INTEGER,
    IN i_med_tra_codigo INTEGER,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    
    IF NOT EXISTS (
        SELECT 1 FROM usuario u
        JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'eliminar_recursos'
    ) THEN
        o_status_code := 403;
        o_mensaje := 'No tiene privilegios para eliminar recursos.';
        RETURN;
    END IF;


    IF EXISTS (SELECT 1 FROM traslado WHERE fk_med_tra_codigo = i_med_tra_codigo) THEN
        o_status_code := 409; -- Conflict
        o_mensaje := 'No se puede eliminar: El avión tiene vuelos registrados (históricos o futuros).';
        RETURN;
    END IF;

    -- 3. Eliminar (Los puestos se eliminan solos si pusiste ON DELETE CASCADE en la tabla Puesto)
    -- Si no tienes ON DELETE CASCADE, descomenta la siguiente línea:
    DELETE FROM puesto WHERE fk_med_tra_codigo = i_med_tra_codigo;
    
    DELETE FROM medio_transporte WHERE med_tra_codigo = i_med_tra_codigo;

    o_status_code := 200;
    o_mensaje := 'Avión eliminado correctamente.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;