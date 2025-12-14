CREATE OR REPLACE PROCEDURE sp_obtener_rutas_proveedor(
    IN i_usu_codigo INTEGER,
    INOUT o_cursor REFCURSOR DEFAULT NULL,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_prov_id INTEGER;
BEGIN
    SELECT prov_codigo INTO v_prov_id FROM proveedor WHERE fk_usu_codigo = i_usu_codigo;

    OPEN o_cursor FOR
    SELECT 
        r.rut_codigo,
        r.rut_costo,
        r.rut_millas_otorgadas,
        r.rut_tipo,
        (to1.ter_nombre || ' (' || l1.lug_nombre || ')') as origen_nombre,
        (td1.ter_nombre || ' (' || l2.lug_nombre || ')') as destino_nombre
    FROM ruta r
    JOIN terminal to1 ON r.fk_terminal_origen = to1.ter_codigo
    JOIN terminal td1 ON r.fk_terminal_destino = td1.ter_codigo
    JOIN lugar l1 ON to1.fk_lugar = l1.lug_codigo 
    JOIN lugar l2 ON td1.fk_lugar = l2.lug_codigo 
    WHERE r.fk_prov_codigo = v_prov_id
    ORDER BY r.rut_codigo DESC;

    o_status_code := 200; o_mensaje := 'Rutas obtenidas.';
END; $$;