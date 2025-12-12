CREATE OR REPLACE PROCEDURE sp_obtener_traslados_proveedor(
    IN i_usu_codigo INTEGER,
    INOUT o_cursor REFCURSOR DEFAULT NULL,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_pro_id INTEGER;
BEGIN
    -- A. Identificar Proveedor
    SELECT p.pro_codigo INTO v_pro_id
    FROM proveedor p JOIN usuario u ON p.fk_usu_codigo = u.usu_codigo
    WHERE u.usu_codigo = i_usu_codigo;

    -- B. Consulta Completa
    -- Hacemos JOIN con Ruta, Terminales y Transporte para que el Front no vea solo IDs
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
        
        -- Estado Calculado (Similar al de flota)
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
    WHERE r.fk_pro_codigo = v_pro_id -- Filtro de seguridad: Solo mis traslados
    ORDER BY t.tras_fecha_hora_inicio DESC;

    o_status_code := 200;
    o_mensaje := 'Traslados obtenidos.';
END; $$;