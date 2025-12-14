-- Store Procedure: asignar_promocion_elemento
CREATE OR REPLACE PROCEDURE asignar_promocion_elemento(
    p_promocion_codigo BIGINT,
    p_elemento_codigo BIGINT,
    p_tipo_elemento VARCHAR -- 'traslado', 'servicio', 'habitacion', 'restaurante'
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_tipo_elemento = 'traslado' THEN
        INSERT INTO Promocion_Traslado (prom_codigo, trasl_codigo) 
        VALUES (p_promocion_codigo, p_elemento_codigo) 
        ON CONFLICT (prom_codigo, trasl_codigo) DO NOTHING; -- Evita duplicados
    
    ELSIF p_tipo_elemento = 'servicio' THEN
        INSERT INTO Promocion_Servicio (prom_codigo, serv_codigo) 
        VALUES (p_promocion_codigo, p_elemento_codigo) 
        ON CONFLICT (prom_codigo, serv_codigo) DO NOTHING;
    
    ELSIF p_tipo_elemento = 'habitacion' THEN
        INSERT INTO Promocion_Habitacion (prom_codigo, hab_codigo) 
        VALUES (p_promocion_codigo, p_elemento_codigo) 
        ON CONFLICT (prom_codigo, hab_codigo) DO NOTHING;

    ELSIF p_tipo_elemento = 'restaurante' THEN
        INSERT INTO Promocion_Restaurante (prom_codigo, rest_codigo) 
        VALUES (p_promocion_codigo, p_elemento_codigo) 
        ON CONFLICT (prom_codigo, rest_codigo) DO NOTHING;
    
    ELSE
        RAISE EXCEPTION 'Tipo de elemento no válido: %', p_tipo_elemento;
    END IF;
END;
$$;