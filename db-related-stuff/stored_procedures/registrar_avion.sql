CREATE OR REPLACE PROCEDURE sp_registrar_avion(
    IN i_usu_codigo INTEGER,       
    IN i_prov_codigo INTEGER,      
    IN i_capacidad INTEGER,
    IN i_descripcion TEXT,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_nuevo_cod INTEGER;
BEGIN
    -- 1. Validar Privilegio 'crear_recursos'
    IF NOT EXISTS (
        SELECT 1 FROM usuario u
        JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'crear_recursos'
    ) THEN
        o_status_code := 403;
        o_mensaje := 'No tiene privilegios para crear recursos.';
        RETURN;
    END IF;

    -- 2. Insertar el Medio de Transporte
    -- CORRECCIÓN: Cambiado fk_pro_codigo a fk_prov_codigo para coincidir con tu create.sql
    INSERT INTO medio_transporte (med_tra_capacidad, med_tra_descripcion, med_tra_tipo, fk_prov_codigo)
    VALUES (i_capacidad, i_descripcion, 'Avion', i_prov_codigo) 
    RETURNING med_tra_codigo INTO v_nuevo_cod;

    -- 3. Generar los Puestos automáticamente
    INSERT INTO puesto (fk_med_tra_codigo, pue_codigo, pue_descripcion, pue_costo_agregado)
    SELECT 
        v_nuevo_cod, 
        s.num, 
        'Asiento Estándar ' || s.num, 
        0
    FROM generate_series(1, i_capacidad) AS s(num);

    o_status_code := 201;
    o_mensaje := 'Avión registrado con ' || i_capacidad || ' puestos.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;