CREATE OR REPLACE FUNCTION sp_get_proximos()
RETURNS TABLE (
    id INTEGER,
    tipo_recurso VARCHAR,
    titulo VARCHAR,
    subtipo VARCHAR,
    fecha_inicio TIMESTAMP,
    ubicacion VARCHAR,
    precio NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM (
        -- TRASLADOS
        SELECT 
            t.tras_codigo as id,
            'Traslado'::VARCHAR as tipo_recurso,
            (lo.lug_nombre || ' -> ' || ld.lug_nombre)::VARCHAR as titulo,
            r.rut_tipo::VARCHAR as subtipo,
            t.tras_fecha_hora_inicio AS fecha_inicio, -- ALIAS IMPORTANTE
            ld.lug_nombre::VARCHAR as ubicacion,
            r.rut_costo AS precio -- ALIAS IMPORTANTE
        FROM traslado t
        JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
        JOIN terminal to_ ON r.fk_terminal_origen = to_.ter_codigo
        JOIN lugar lo ON to_.fk_lugar = lo.lug_codigo
        JOIN terminal td ON r.fk_terminal_destino = td.ter_codigo
        JOIN lugar ld ON td.fk_lugar = ld.lug_codigo
        WHERE t.tras_fecha_hora_inicio > NOW()

        UNION ALL

        -- SERVICIOS
        SELECT 
            s.ser_codigo as id,
            'Servicio'::VARCHAR as tipo_recurso,
            s.ser_nombre::VARCHAR as titulo,
            'Servicio'::VARCHAR as subtipo,
            s.ser_fecha_hora_inicio AS fecha_inicio, -- ALIAS IMPORTANTE
            l.lug_nombre::VARCHAR as ubicacion,
            s.ser_costo AS precio -- ALIAS IMPORTANTE
        FROM servicio s
        JOIN proveedor p ON s.fk_prov_codigo = p.prov_codigo
        JOIN lugar l ON p.fk_lugar = l.lug_codigo
        WHERE s.ser_fecha_hora_inicio > NOW()
    ) AS unificado
    ORDER BY fecha_inicio ASC
    LIMIT 10;
END;
$$ LANGUAGE plpgsql;