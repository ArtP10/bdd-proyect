CREATE OR REPLACE PROCEDURE sp_obtener_flota_proveedor(
    IN i_pro_codigo INTEGER,
    INOUT o_cursor REFCURSOR DEFAULT NULL,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    OPEN o_cursor FOR
    SELECT 
        mt.med_tra_codigo,
        mt.med_tra_capacidad,
        mt.med_tra_descripcion,
        mt.med_tra_tipo,
        -- Lógica de Estado
        CASE 
            -- Si existe un traslado ocurriendo AHORA MISMO
            WHEN EXISTS (
                SELECT 1 FROM traslado t 
                WHERE t.fk_med_tra_codigo = mt.med_tra_codigo 
                AND CURRENT_TIMESTAMP BETWEEN t.tras_fecha_hora_inicio AND t.tras_fecha_hora_fin
            ) THEN 'En Vuelo'
            
            -- Si existe un traslado EN EL FUTURO (y no está volando ahora)
            WHEN EXISTS (
                SELECT 1 FROM traslado t 
                WHERE t.fk_med_tra_codigo = mt.med_tra_codigo 
                AND t.tras_fecha_hora_inicio > CURRENT_TIMESTAMP
            ) THEN 'En Espera'
            
            -- Si no cumple ninguna, está inactivo
            ELSE 'Inactivo'
        END AS estado_actual
    FROM medio_transporte mt
    WHERE mt.fk_pro_codigo = i_pro_codigo
    ORDER BY mt.med_tra_codigo DESC;

    o_status_code := 200;
    o_mensaje := 'Flota obtenida.';
EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;