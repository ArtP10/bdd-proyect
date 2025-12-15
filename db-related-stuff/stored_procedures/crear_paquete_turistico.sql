CREATE OR REPLACE PROCEDURE sp_crear_paquete_turistico(
    IN p_nombre VARCHAR(50),
    IN p_monto_total NUMERIC(10,2),
    IN p_monto_subtotal NUMERIC(10,2),
    IN p_costo_millas INTEGER,
    OUT o_status_code INTEGER,
    OUT o_mensaje VARCHAR,
    OUT o_paq_tur_codigo INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insertamos el nuevo registro
    INSERT INTO paquete_turistico (
        paq_tur_nombre, 
        paq_tur_monto_total, 
        paq_tur_monto_subtotal, 
        paq_tur_costo_en_millas
    )
    VALUES (
        p_nombre, 
        p_monto_total, 
        p_monto_subtotal, 
        p_costo_millas
    )
    RETURNING paq_tur_codigo INTO o_paq_tur_codigo;

    -- Respuesta exitosa
    o_status_code := 201;
    o_mensaje := 'Paquete turístico creado exitosamente';

EXCEPTION
    WHEN OTHERS THEN
        o_status_code := 500;
        o_mensaje := 'Error al crear el paquete: ' || SQLERRM;
        o_paq_tur_codigo := NULL;
END;
$$;