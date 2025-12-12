CREATE OR REPLACE PROCEDURE sp_modificar_avion(
    IN i_usu_codigo INTEGER,
    IN i_med_tra_codigo INTEGER,
    IN i_nueva_capacidad INTEGER,
    IN i_nueva_descripcion TEXT,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_capacidad_anterior INTEGER;
BEGIN
    -- 1. Validar Privilegio 'modificar_recursos'
    IF NOT EXISTS (
        SELECT 1 FROM usuario u
        JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'modificar_recursos'
    ) THEN
        o_status_code := 403;
        o_mensaje := 'No tiene privilegios para modificar recursos.';
        RETURN;
    END IF;

    -- 2. Obtener capacidad anterior para comparar
    SELECT med_tra_capacidad INTO v_capacidad_anterior 
    FROM medio_transporte WHERE med_tra_codigo = i_med_tra_codigo;

    IF v_capacidad_anterior IS NULL THEN
        o_status_code := 404;
        o_mensaje := 'Avión no encontrado.';
        RETURN;
    END IF;

    -- 3. Actualizar datos base
    UPDATE medio_transporte
    SET med_tra_capacidad = i_nueva_capacidad,
        med_tra_descripcion = i_nueva_descripcion
    WHERE med_tra_codigo = i_med_tra_codigo;

    -- 4. Lógica de Puestos
    IF i_nueva_capacidad > v_capacidad_anterior THEN
        -- CASO A: Aumentó capacidad -> Agregar nuevos puestos
        INSERT INTO puesto (fk_med_tra_codigo, pue_codigo, pue_descripcion, pue_costo_agregado)
        SELECT 
            i_med_tra_codigo, 
            s.num, 
            'Asiento Estándar ' || s.num, 
            0
        FROM generate_series(v_capacidad_anterior + 1, i_nueva_capacidad) AS s(num);
        
    ELSIF i_nueva_capacidad < v_capacidad_anterior THEN
        -- CASO B: Disminuyó capacidad -> Eliminar los puestos sobrantes (los últimos números)
        DELETE FROM puesto
        WHERE fk_med_tra_codigo = i_med_tra_codigo
        AND pue_codigo > i_nueva_capacidad;
    END IF;

    o_status_code := 200;
    o_mensaje := 'Avión actualizado correctamente.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;