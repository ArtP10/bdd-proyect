CREATE OR REPLACE PROCEDURE sp_agregar_documento_viajero(
    IN i_doc_fecha_emision DATE,
    IN i_doc_fecha_vencimiento DATE,
    IN i_doc_numero VARCHAR,
    IN i_doc_tipo VARCHAR,
    IN i_nac_nombre VARCHAR, -- CAMBIO: Recibe Varchar
    IN i_fk_via_codigo INTEGER,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_nac_id INTEGER;
BEGIN
    -- Buscamos el ID basado en el nombre
    SELECT nac_codigo INTO v_nac_id 
    FROM nacionalidad 
    WHERE nac_nombre = i_nac_nombre 
    LIMIT 1;

    -- Validamos si existe
    IF v_nac_id IS NULL THEN
        o_status_code := 404;
        o_mensaje := 'Error: La nacionalidad indicada no existe.';
        RETURN;
    END IF;

    -- Insertamos usando el ID encontrado
    INSERT INTO documento (doc_fecha_emision, doc_fecha_vencimiento, doc_numero_documento, doc_tipo, fk_nac_codigo, fk_via_codigo)
    VALUES (i_doc_fecha_emision, i_doc_fecha_vencimiento, i_doc_numero, i_doc_tipo, v_nac_id, i_fk_via_codigo);

    o_status_code := 201;
    o_mensaje := 'Documento agregado correctamente.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;