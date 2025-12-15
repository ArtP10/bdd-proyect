-- Store Procedure: quitar_promocion_elemento
CREATE OR REPLACE PROCEDURE quitar_promocion_elemento(
    p_promocion_codigo BIGINT,
    p_elemento_codigo BIGINT,
    p_tipo_elemento VARCHAR -- 'traslado', 'servicio', 'habitacion', 'restaurante'
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_tipo_elemento = 'traslado' THEN
        DELETE FROM Promocion_Traslado 
        WHERE prom_codigo = p_promocion_codigo AND trasl_codigo = p_elemento_codigo;
    
    ELSIF p_tipo_elemento = 'servicio' THEN
        DELETE FROM Promocion_Servicio 
        WHERE prom_codigo = p_promocion_codigo AND serv_codigo = p_elemento_codigo;
    
    ELSIF p_tipo_elemento = 'habitacion' THEN
        DELETE FROM Promocion_Habitacion 
        WHERE prom_codigo = p_promocion_codigo AND hab_codigo = p_elemento_codigo;

    ELSIF p_tipo_elemento = 'restaurante' THEN
        DELETE FROM Promocion_Restaurante 
        WHERE prom_codigo = p_promocion_codigo AND rest_codigo = p_elemento_codigo;
    
    ELSE
        RAISE EXCEPTION 'Tipo de elemento no válido: %', p_tipo_elemento;
    END IF;
END;
$$;