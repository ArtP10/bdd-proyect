CREATE OR REPLACE FUNCTION sp_get_top_servicios()
RETURNS TABLE (
    id INTEGER,
    titulo VARCHAR,
    descripcion VARCHAR,
    fecha_inicio TIMESTAMP,
    tipo VARCHAR,
    subtipo VARCHAR,
    lugar VARCHAR,
    precio NUMERIC,
    total_ventas BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.ser_codigo,
        s.ser_nombre::VARCHAR,
        s.ser_descripcion::VARCHAR,
        s.ser_fecha_hora_inicio,
        'Servicio'::VARCHAR as tipo,
        s.ser_tipo::VARCHAR as subtipo,
        l.lug_nombre::VARCHAR as lugar,
        s.ser_costo,
        COUNT(dr.fk_compra) as ventas
    FROM servicio s
    JOIN proveedor p ON s.fk_prov_codigo = p.prov_codigo
    JOIN lugar l ON p.fk_lugar = l.lug_codigo
    LEFT JOIN detalle_reserva dr ON dr.fk_servicio = s.ser_codigo
    WHERE s.ser_fecha_hora_fin > NOW()
    GROUP BY 
        s.ser_codigo, 
        s.ser_nombre, 
        s.ser_descripcion, 
        s.ser_fecha_hora_inicio, 
        s.ser_tipo, 
        l.lug_nombre, 
        s.ser_costo
    ORDER BY ventas DESC
    LIMIT 10;
END;
$$ LANGUAGE plpgsql;