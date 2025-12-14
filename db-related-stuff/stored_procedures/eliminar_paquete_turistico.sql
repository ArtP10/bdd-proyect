CREATE OR REPLACE PROCEDURE sp_eliminar_paquete_turistico(
    IN p_paq_tur_codigo INTEGER,
    OUT o_status_code INTEGER,
    OUT o_mensaje VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificamos si existe
    IF NOT EXISTS (SELECT 1 FROM paquete_turistico WHERE paq_tur_codigo = p_paq_tur_codigo) THEN
        o_status_code := 404;
        o_mensaje := 'El paquete turístico no existe';
        RETURN;
    END IF;

    -- Intentamos eliminar
    DELETE FROM paquete_turistico
    WHERE paq_tur_codigo = p_paq_tur_codigo;

    o_status_code := 200;
    o_mensaje := 'Paquete turístico eliminado exitosamente';

EXCEPTION
    -- Captura errores de llave foránea (ej: código 23503)
    WHEN foreign_key_violation THEN
        o_status_code := 409; -- Conflict
        o_mensaje := 'No se puede eliminar el paquete porque está en uso (tiene reglas o reservas asociadas)';
    
    WHEN OTHERS THEN
        o_status_code := 500;
        o_mensaje := 'Error al eliminar el paquete: ' || SQLERRM;
END;
$$;