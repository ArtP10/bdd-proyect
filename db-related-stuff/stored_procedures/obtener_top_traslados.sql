CREATE OR REPLACE FUNCTION sp_get_top_traslados()
RETURNS TABLE (
    id INTEGER,
    titulo VARCHAR,
    descripcion VARCHAR,
    fecha_inicio TIMESTAMP,
    tipo VARCHAR,
    origen VARCHAR,
    destino VARCHAR,
    precio NUMERIC,
    total_ventas BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.tras_codigo,
        (lug_o.lug_nombre || ' - ' || lug_d.lug_nombre)::VARCHAR,
        mt.med_tra_descripcion::VARCHAR,
        t.tras_fecha_hora_inicio,
        r.rut_tipo::VARCHAR,
        lug_o.lug_nombre::VARCHAR,
        lug_d.lug_nombre::VARCHAR,
        r.rut_costo,
        COUNT(dr.fk_compra) as ventas
    FROM traslado t
    JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
    JOIN terminal ter_o ON r.fk_terminal_origen = ter_o.ter_codigo
    JOIN lugar lug_o ON ter_o.fk_lugar = lug_o.lug_codigo
    JOIN terminal ter_d ON r.fk_terminal_destino = ter_d.ter_codigo
    JOIN lugar lug_d ON ter_d.fk_lugar = lug_d.lug_codigo
    JOIN medio_transporte mt ON t.fk_med_tra_codigo = mt.med_tra_codigo
    JOIN pue_tras pt ON pt.fk_tras_codigo = t.tras_codigo
    LEFT JOIN detalle_reserva dr ON (dr.fk_pue_tras = pt.pue_tras_codigo OR dr.fk_pue_tras1 = pt.pue_tras_codigo OR dr.fk_pue_tras2 = pt.pue_tras_codigo)
    WHERE t.tras_fecha_hora_fin > NOW()
    GROUP BY 
        t.tras_codigo, 
        lug_o.lug_nombre, 
        lug_d.lug_nombre, 
        mt.med_tra_descripcion, 
        t.tras_fecha_hora_inicio, 
        r.rut_tipo, 
        r.rut_costo
    ORDER BY ventas DESC
    LIMIT 10;
END;
$$ LANGUAGE plpgsql;