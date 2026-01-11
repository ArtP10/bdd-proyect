-- 1. MODIFICAR REGLA (Definición)
CREATE OR REPLACE PROCEDURE sp_modificar_regla_generica(
    IN _id_regla INT,
    IN _atributo VARCHAR,
    IN _operador VARCHAR,
    IN _valor VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE regla_paquete
    SET 
        reg_paq_atributo = _atributo,
        reg_paq_operador = _operador,
        reg_paq_valor = _valor
    WHERE reg_paq_codigo = _id_regla;
END;
$$;

-- 2. ELIMINAR REGLA (Definición)
-- Nota: Esto fallará si la regla ya está asignada a un paquete (FK constraint).
-- El usuario primero debe desvincularla de los paquetes o usamos CASCADE si prefieres.
-- Por seguridad, dejaremos que falle si está en uso.
CREATE OR REPLACE PROCEDURE sp_eliminar_regla_generica(
    IN _id_regla INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Primero borramos las referencias en la tabla intermedia (Desvinculamos de paquetes)
    DELETE FROM reg_paq_paq WHERE fk_reg_paq_codigo = _id_regla;

    -- 2. Ahora sí borramos la definición de la regla
    DELETE FROM regla_paquete WHERE reg_paq_codigo = _id_regla;
END;
$$;


CREATE OR REPLACE PROCEDURE sp_crear_regla_paquete(
    IN _atributo VARCHAR,
    IN _operador VARCHAR,
    IN _valor VARCHAR,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL,
    INOUT o_new_id INTEGER DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insertamos la regla
    INSERT INTO regla_paquete (reg_paq_atributo, reg_paq_operador, reg_paq_valor)
    VALUES (_atributo, _operador, _valor)
    RETURNING reg_paq_codigo INTO o_new_id;

    -- Devolvemos éxito
    o_status_code := 201;
    o_mensaje := 'Regla creada exitosamente';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error al crear regla: ' || SQLERRM;
END;
$$;