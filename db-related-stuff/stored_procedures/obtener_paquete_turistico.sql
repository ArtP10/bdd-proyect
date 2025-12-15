CREATE OR REPLACE PROCEDURE sp_obtener_paquetes_turisticos(
    OUT o_cursor REFCURSOR,
    OUT o_status_code INTEGER,
    OUT o_mensaje VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Abrimos el cursor con todos los datos
    OPEN o_cursor FOR
        SELECT 
            paq_tur_codigo,
            paq_tur_nombre,
            paq_tur_monto_total,
            paq_tur_monto_subtotal,
            paq_tur_costo_en_millas
        FROM paquete_turistico
        ORDER BY paq_tur_codigo DESC; -- Ordenados del más nuevo al más viejo

    o_status_code := 200;
    o_mensaje := 'Paquetes obtenidos exitosamente';

EXCEPTION
    WHEN OTHERS THEN
        o_status_code := 500;
        o_mensaje := 'Error al obtener paquetes: ' || SQLERRM;
        o_cursor := NULL;
END;
$$;