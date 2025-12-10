CREATE OR REPLACE FUNCTION validar_rol_proveedor()
RETURNS TRIGGER AS $$
DECLARE
    v_rol VARCHAR;
BEGIN
    -- Buscamos el rol del usuario que intentan vincular
    SELECT usu_rol INTO v_rol FROM usuario WHERE usuario_codigo = NEW.fk_usu_codigo;
    
    -- Si no es Proveedor, bloqueamos la operación
    IF v_rol <> 'Proveedor' THEN
        RAISE EXCEPTION 'Integridad referencial violada: El usuario ID % no tiene el rol de Proveedor (Rol actual: %)', NEW.fk_usu_codigo, v_rol;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_check_proveedor_role
BEFORE INSERT OR UPDATE ON proveedor
FOR EACH ROW
EXECUTE FUNCTION validar_rol_proveedor();