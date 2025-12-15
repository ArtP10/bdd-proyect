CREATE OR REPLACE PROCEDURE asignar_promo_paquete(
    IN p_paquete_id INT,
    IN p_promo_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO paq_prom (fk_paq_tur_codigo, fk_prom_codigo)
    VALUES (p_paquete_id, p_promo_id)
    ON CONFLICT DO NOTHING;
END;
$$;