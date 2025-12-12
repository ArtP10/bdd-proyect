CREATE OR REPLACE PROCEDURE sp_eliminar_documento(
    IN i_doc_codigo INTEGER,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM documento WHERE doc_codigo = i_doc_codigo;
    
    IF FOUND THEN
        o_status_code := 200;
        o_mensaje := 'Documento eliminado correctamente.';
    ELSE
        o_status_code := 404;
        o_mensaje := 'El documento no existe.';
    END IF;

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;