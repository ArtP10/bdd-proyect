CREATE OR REPLACE PROCEDURE sp_obtener_detalle_viajero(
    IN i_via_codigo INTEGER,
    INOUT o_json_documentos JSON DEFAULT '[]',
    INOUT o_json_historial JSON DEFAULT '[]',
    INOUT o_status_code INTEGER DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Obtener Documentos
    SELECT COALESCE(json_agg(row_to_json(d)), '[]') INTO o_json_documentos
    FROM (
        SELECT doc.*, n.nac_nombre 
        FROM documento doc 
        JOIN nacionalidad n ON doc.fk_nac_codigo = n.nac_codigo
        WHERE fk_via_codigo = i_via_codigo
    ) d;

    -- Obtener Historial Estado Civil
    SELECT COALESCE(json_agg(row_to_json(h)), '[]') INTO o_json_historial
    FROM (
        SELECT ve.*, ec.edo_civ_nombre 
        FROM via_edo ve
        JOIN estado_civil ec ON ve.fk_edo_codigo = ec.edo_civ_codigo
        WHERE fk_via_codigo = i_via_codigo
        ORDER BY via_edo_fecha_inicio DESC
    ) h;

    o_status_code := 200;
END;
$$;