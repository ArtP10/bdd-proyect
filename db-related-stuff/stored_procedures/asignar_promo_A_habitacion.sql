-- D) Asignar a Habitación (OJO: Esto es un UPDATE porque la FK está en la tabla habitacion)
CREATE OR REPLACE PROCEDURE asignar_promo_habitacion(
    IN p_habitacion_id INT,
    IN p_promo_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE habitacion
    SET fk_promocion = p_promo_id
    WHERE hab_num_hab = p_habitacion_id;
END;
$$;