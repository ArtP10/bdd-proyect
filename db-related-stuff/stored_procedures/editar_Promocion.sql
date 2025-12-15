CREATE OR REPLACE PROCEDURE editar_promocion(
    IN p_codigo INT,
    IN p_nombre VARCHAR(50),
    IN p_descripcion VARCHAR(100),
    IN p_fecha_vencimiento TIMESTAMP,
    IN p_descuento NUMERIC(5,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE promocion
    SET 
        prom_nombre = p_nombre,
        prom_descripcion = p_descripcion,
        prom_fecha_hora_vencimiento = p_fecha_vencimiento,
        prom_descuento = p_descuento
    WHERE prom_codigo = p_codigo;
END;
$$;