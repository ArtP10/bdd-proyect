CREATE OR REPLACE PROCEDURE sp_obtener_traslados_proveedor(
    IN i_usu_codigo INTEGER,
    INOUT o_cursor REFCURSOR DEFAULT NULL,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_prov_id INTEGER; -- Variable renombrada para consistencia
BEGIN
    -- A. Identificar Proveedor
    -- CORRECCIÓN: Usamos prov_codigo
    SELECT p.prov_codigo INTO v_prov_id
    FROM proveedor p JOIN usuario u ON p.fk_usu_codigo = u.usu_codigo
    WHERE u.usu_codigo = i_usu_codigo;

    -- B. Consulta Completa
    OPEN o_cursor FOR
    SELECT 
        t.tras_codigo,
        t.tras_fecha_hora_inicio,
        t.tras_fecha_hora_fin,
        t.tras_CO2_Emitido,
        
        -- Info Ruta
        (orig.ter_nombre || ' -> ' || dest.ter_nombre) AS ruta_nombre,
        
        -- Info Transporte
        mt.med_tra_descripcion AS transporte_nombre,
        mt.med_tra_capacidad,
        
        -- Estado Calculado
        CASE 
            WHEN CURRENT_TIMESTAMP BETWEEN t.tras_fecha_hora_inicio AND t.tras_fecha_hora_fin THEN 'En Curso'
            WHEN t.tras_fecha_hora_inicio > CURRENT_TIMESTAMP THEN 'Programado'
            ELSE 'Finalizado'
        END AS estado_traslado

    FROM traslado t
    JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
    JOIN terminal orig ON r.fk_terminal_origen = orig.ter_codigo
    JOIN terminal dest ON r.fk_terminal_destino = dest.ter_codigo
    JOIN medio_transporte mt ON t.fk_med_tra_codigo = mt.med_tra_codigo
    
    -- CORRECCIÓN: Filtramos usando fk_prov_codigo
    WHERE r.fk_prov_codigo = v_prov_id 
    ORDER BY t.tras_fecha_hora_inicio DESC;

    o_status_code := 200;
    o_mensaje := 'Traslados obtenidos.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;