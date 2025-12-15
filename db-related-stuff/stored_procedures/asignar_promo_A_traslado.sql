-- C) Asignar a Traslado
CREATE OR REPLACE PROCEDURE asignar_promo_traslado(
    IN p_traslado_id INT,
    IN p_promo_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO tras_prom (fk_tras_codigo, fk_prom_codigo)
    VALUES (p_traslado_id, p_promo_id)
    ON CONFLICT DO NOTHING;
END;
$$;