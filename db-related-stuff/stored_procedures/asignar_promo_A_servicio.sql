-- B) Asignar a Servicio
CREATE OR REPLACE PROCEDURE asignar_promo_servicio(
    IN p_servicio_id INT,
    IN p_promo_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO ser_prom (fk_ser_codigo, fk_prom_codigo)
    VALUES (p_servicio_id, p_promo_id)
    ON CONFLICT DO NOTHING;
END;
$$;