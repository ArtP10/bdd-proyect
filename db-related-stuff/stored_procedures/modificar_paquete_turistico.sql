CREATE OR REPLACE PROCEDURE sp_modificar_paquete_turistico(
    IN p_paq_tur_codigo INTEGER,
    IN p_nombre VARCHAR(50),
    IN p_monto_total NUMERIC(10,2),
    IN p_monto_subtotal NUMERIC(10,2),
    IN p_costo_millas INTEGER,
    OUT o_status_code INTEGER,
    OUT o_mensaje VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificamos si existe el paquete
    IF NOT EXISTS (SELECT 1 FROM paquete_turistico WHERE paq_tur_codigo = p_paq_tur_codigo) THEN
        o_status_code := 404;
        o_mensaje := 'El paquete turístico no existe';
        RETURN;
    END IF;

    -- Realizamos la actualización
    UPDATE paquete_turistico
    SET 
        paq_tur_nombre = p_nombre,
        paq_tur_monto_total = p_monto_total,
        paq_tur_monto_subtotal = p_monto_subtotal,
        paq_tur_costo_en_millas = p_costo_millas
    WHERE paq_tur_codigo = p_paq_tur_codigo;

    o_status_code := 200;
    o_mensaje := 'Paquete turístico actualizado exitosamente';

EXCEPTION
    WHEN OTHERS THEN
        o_status_code := 500;
        o_mensaje := 'Error al actualizar el paquete: ' || SQLERRM;
END;
$$;