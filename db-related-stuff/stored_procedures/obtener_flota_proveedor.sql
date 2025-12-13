CREATE OR REPLACE PROCEDURE sp_obtener_flota_proveedor(
    IN i_prov_codigo INTEGER, -- CAMBIO: Nombre del parámetro actualizado
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
            -- En Vuelo
            WHEN EXISTS (
                SELECT 1 FROM traslado t 
                WHERE t.fk_med_tra_codigo = mt.med_tra_codigo 
                AND CURRENT_TIMESTAMP BETWEEN t.tras_fecha_hora_inicio AND t.tras_fecha_hora_fin
            ) THEN 'En Vuelo'
            
            -- En Espera
            WHEN EXISTS (
                SELECT 1 FROM traslado t 
                WHERE t.fk_med_tra_codigo = mt.med_tra_codigo 
                AND t.tras_fecha_hora_inicio > CURRENT_TIMESTAMP
            ) THEN 'En Espera'
            
            -- Inactivo
            ELSE 'Inactivo'
        END AS estado_actual
    FROM medio_transporte mt
    -- CORRECCIÓN AQUÍ: Usamos fk_prov_codigo
    WHERE mt.fk_prov_codigo = i_prov_codigo 
    ORDER BY mt.med_tra_codigo DESC;

    o_status_code := 200;
    o_mensaje := 'Flota obtenida.';
EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;