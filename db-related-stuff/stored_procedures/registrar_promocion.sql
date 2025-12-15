CREATE OR REPLACE PROCEDURE sp_obtener_promociones(
    INOUT o_cursor REFCURSOR DEFAULT NULL,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    OPEN o_cursor FOR 
    SELECT 
        p.prom_codigo, 
        p.prom_nombre, 
        p.prom_descripcion, 
        p.prom_descuento,
        p.prom_fecha_hora_vencimiento,
        
        -- Cálculo 1: Determinar si está Activa o Vencida
        CASE 
            WHEN p.prom_fecha_hora_vencimiento > CURRENT_TIMESTAMP THEN 'Activa'
            ELSE 'Vencida'
        END AS estado_actual,

        -- Cálculo 2: Días restantes (si ya venció, muestra 0)
        CASE 
            WHEN p.prom_fecha_hora_vencimiento > CURRENT_TIMESTAMP 
            THEN EXTRACT(DAY FROM (p.prom_fecha_hora_vencimiento - CURRENT_TIMESTAMP))::INTEGER
            ELSE 0 
        END AS dias_restantes

    FROM promocion p
    ORDER BY p.prom_codigo DESC;

    o_status_code := 200;
    o_mensaje := 'Lista de promociones obtenida correctamente.';
END; $$;