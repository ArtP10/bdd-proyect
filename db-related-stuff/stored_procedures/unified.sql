BEGIN;
CREATE OR REPLACE PROCEDURE sp_agregar_documento_viajero(
    IN i_doc_fecha_emision DATE,
    IN i_doc_fecha_vencimiento DATE,
    IN i_doc_numero VARCHAR,
    IN i_doc_tipo VARCHAR,
    IN i_nac_nombre VARCHAR, -- CAMBIO: Recibe Varchar
    IN i_fk_via_codigo INTEGER,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_nac_id INTEGER;
BEGIN
    -- Buscamos el ID basado en el nombre
    SELECT nac_codigo INTO v_nac_id 
    FROM nacionalidad 
    WHERE nac_nombre = i_nac_nombre 
    LIMIT 1;

    -- Validamos si existe
    IF v_nac_id IS NULL THEN
        o_status_code := 404;
        o_mensaje := 'Error: La nacionalidad indicada no existe.';
        RETURN;
    END IF;

    -- Insertamos usando el ID encontrado
    INSERT INTO documento (doc_fecha_emision, doc_fecha_vencimiento, doc_numero_documento, doc_tipo, fk_nac_codigo, fk_via_codigo)
    VALUES (i_doc_fecha_emision, i_doc_fecha_vencimiento, i_doc_numero, i_doc_tipo, v_nac_id, i_fk_via_codigo);

    o_status_code := 201;
    o_mensaje := 'Documento agregado correctamente.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;




CREATE OR REPLACE PROCEDURE sp_actualizar_estado_civil(
    IN i_fk_via_codigo INTEGER,
    IN i_fk_edo_codigo INTEGER,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Paso A: "Cerrar" el estado civil anterior si existe uno activo (fecha fin null)
    UPDATE via_edo 
    SET via_edo_fecha_fin = CURRENT_DATE 
    WHERE fk_via_codigo = i_fk_via_codigo AND via_edo_fecha_fin IS NULL;

    -- Paso B: Insertar nuevo estado
    INSERT INTO via_edo (fk_via_codigo, fk_edo_codigo, via_edo_fecha_inicio, via_edo_fecha_fin)
    VALUES (i_fk_via_codigo, i_fk_edo_codigo, CURRENT_DATE, NULL);

    o_status_code := 200;
    o_mensaje := 'Estado civil actualizado.';
EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_actualizar_estado_civil(
    IN i_fk_via_codigo INTEGER,
    IN i_fk_edo_codigo INTEGER,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Paso A: "Cerrar" el estado civil anterior si existe uno activo (fecha fin null)
    UPDATE via_edo 
    SET via_edo_fecha_fin = CURRENT_DATE 
    WHERE fk_via_codigo = i_fk_via_codigo AND via_edo_fecha_fin IS NULL;

    -- Paso B: Insertar nuevo estado
    INSERT INTO via_edo (fk_via_codigo, fk_edo_codigo, via_edo_fecha_inicio, via_edo_fecha_fin)
    VALUES (i_fk_via_codigo, i_fk_edo_codigo, CURRENT_DATE, NULL);

    o_status_code := 200;
    o_mensaje := 'Estado civil actualizado.';
EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;


CREATE OR REPLACE PROCEDURE sp_eliminar_avion(
    IN i_usu_codigo INTEGER,
    IN i_med_tra_codigo INTEGER,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    
    IF NOT EXISTS (
        SELECT 1 FROM usuario u
        JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'eliminar_recursos'
    ) THEN
        o_status_code := 403;
        o_mensaje := 'No tiene privilegios para eliminar recursos.';
        RETURN;
    END IF;


    IF EXISTS (SELECT 1 FROM traslado WHERE fk_med_tra_codigo = i_med_tra_codigo) THEN
        o_status_code := 409; -- Conflict
        o_mensaje := 'No se puede eliminar: El avión tiene vuelos registrados (históricos o futuros).';
        RETURN;
    END IF;

    -- 3. Eliminar (Los puestos se eliminan solos si pusiste ON DELETE CASCADE en la tabla Puesto)
    -- Si no tienes ON DELETE CASCADE, descomenta la siguiente línea:
    DELETE FROM puesto WHERE fk_med_tra_codigo = i_med_tra_codigo;
    
    DELETE FROM medio_transporte WHERE med_tra_codigo = i_med_tra_codigo;

    o_status_code := 200;
    o_mensaje := 'Avión eliminado correctamente.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;


CREATE OR REPLACE PROCEDURE sp_eliminar_documento(
    IN i_doc_codigo INTEGER,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM documento WHERE doc_codigo = i_doc_codigo;
    
    IF FOUND THEN
        o_status_code := 200;
        o_mensaje := 'Documento eliminado correctamente.';
    ELSE
        o_status_code := 404;
        o_mensaje := 'El documento no existe.';
    END IF;

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_eliminar_historial_civil(
    IN i_via_codigo INTEGER,
    IN i_edo_codigo INTEGER,
    IN i_fecha_inicio DATE,
    INOUT o_status_code INTEGER DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM via_edo 
    WHERE fk_via_codigo = i_via_codigo 
    AND fk_edo_codigo = i_edo_codigo 
    AND via_edo_fecha_inicio = i_fecha_inicio;
    o_status_code := 200;
END; $$;

CREATE OR REPLACE PROCEDURE sp_eliminar_ruta(
    IN i_usu_codigo INTEGER,
    IN i_rut_codigo INTEGER,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_prov_id INTEGER;
    v_rut_prov_id INTEGER;
BEGIN
    -- Validar Permisos
    IF NOT EXISTS (
        SELECT 1 FROM usuario u JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'eliminar_recursos'
    ) THEN
        o_status_code := 403; o_mensaje := 'No tiene permisos para eliminar rutas.'; RETURN;
    END IF;

    -- Validar Propiedad
    SELECT prov_codigo INTO v_prov_id FROM proveedor WHERE fk_usu_codigo = i_usu_codigo;
    SELECT fk_prov_codigo INTO v_rut_prov_id FROM ruta WHERE rut_codigo = i_rut_codigo;

    IF v_prov_id <> v_rut_prov_id OR v_rut_prov_id IS NULL THEN
        o_status_code := 403; o_mensaje := 'No puede eliminar una ruta que no le pertenece.'; RETURN;
    END IF;

    -- Validar Dependencias (Traslados)
    IF EXISTS (SELECT 1 FROM traslado WHERE fk_rut_codigo = i_rut_codigo) THEN
        o_status_code := 409; o_mensaje := 'No se puede eliminar: Existen vuelos asociados a esta ruta.'; RETURN;
    END IF;

    -- Eliminar
    DELETE FROM ruta WHERE rut_codigo = i_rut_codigo;

    o_status_code := 200; o_mensaje := 'Ruta eliminada correctamente.';
EXCEPTION WHEN OTHERS THEN
    o_status_code := 500; o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;


CREATE OR REPLACE PROCEDURE sp_login_usuario(
    IN i_busqueda_nombre varchar,
    IN i_busqueda_contrasena varchar,
    IN i_busqueda_tipo varchar,
    INOUT o_usu_codigo integer DEFAULT NULL,
    INOUT o_usu_nombre varchar DEFAULT NULL,
    INOUT o_usu_rol varchar DEFAULT NULL,
    INOUT o_status_code integer DEFAULT NULL,
    INOUT o_mensaje varchar DEFAULT NULL,
    INOUT o_rol_privilegios TEXT[] DEFAULT NULL,
    INOUT o_usu_correo varchar DEFAULT NULL -- Se eliminó la coma aquí
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_contrasena_guardada varchar;
    v_rol_nombre varchar;
    v_rol_codigo Integer;
BEGIN
    -- 1. Buscar Usuario y Rol
    -- Corregido: u.usu_email en vez de u.o_usu_correo
    -- Corregido: r.rol_codigo en vez de r.rol_codigom
    SELECT u.usu_codigo, u.usu_nombre_usuario, u.usu_contrasena, r.rol_nombre, r.rol_codigo, u.usu_email
    INTO o_usu_codigo, o_usu_nombre, v_contrasena_guardada, v_rol_nombre, v_rol_codigo, o_usu_correo
    FROM usuario u
    JOIN rol r ON u.fk_rol_codigo = r.rol_codigo
    WHERE u.usu_nombre_usuario = i_busqueda_nombre;

    -- 2. Validaciones
    
    -- Caso 404: Usuario no existe
    IF o_usu_codigo IS NULL THEN
        o_status_code := 404;
        o_mensaje := 'Nombre de usuario no encontrado';
        RETURN;
    END IF;

    -- Caso 401: Contraseña incorrecta
    IF v_contrasena_guardada <> i_busqueda_contrasena THEN
        o_status_code := 401;
        o_mensaje := 'Contraseña incorrecta';
        o_usu_codigo := NULL;
        o_usu_nombre := NULL;
        o_usu_correo := NULL; -- Limpiamos el correo también por seguridad
        RETURN;
    END IF;

    -- Caso 403: Rol incorrecto
    IF v_rol_nombre <> i_busqueda_tipo THEN
        o_status_code := 403;
        o_mensaje := 'No tiene permisos para este rol';
        o_usu_codigo := NULL;
        o_usu_nombre := NULL;
        o_usu_correo := NULL;
        RETURN;
    END IF;

    -- 3. Éxito (200)
    o_usu_rol := v_rol_nombre;
    o_status_code := 200;
    o_mensaje := 'Sesion iniciada correctamente';

    -- 4. Obtener Privilegios
    SELECT COALESCE(ARRAY_AGG(p.pri_nombre), '{}')
    INTO o_rol_privilegios
    FROM privilegio p
    JOIN rol_privilegio rp ON rp.fk_pri_codigo = p.pri_codigo
    WHERE rp.fk_rol_codigo = v_rol_codigo;

END;
$$;


CREATE OR REPLACE PROCEDURE sp_modificar_avion(
    IN i_usu_codigo INTEGER,
    IN i_med_tra_codigo INTEGER,
    IN i_nueva_capacidad INTEGER,
    IN i_nueva_descripcion TEXT,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_capacidad_anterior INTEGER;
BEGIN
    -- 1. Validar Privilegio 'modificar_recursos'
    IF NOT EXISTS (
        SELECT 1 FROM usuario u
        JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'modificar_recursos'
    ) THEN
        o_status_code := 403;
        o_mensaje := 'No tiene privilegios para modificar recursos.';
        RETURN;
    END IF;

    -- 2. Obtener capacidad anterior para comparar
    SELECT med_tra_capacidad INTO v_capacidad_anterior 
    FROM medio_transporte WHERE med_tra_codigo = i_med_tra_codigo;

    IF v_capacidad_anterior IS NULL THEN
        o_status_code := 404;
        o_mensaje := 'Avión no encontrado.';
        RETURN;
    END IF;

    -- 3. Actualizar datos base
    UPDATE medio_transporte
    SET med_tra_capacidad = i_nueva_capacidad,
        med_tra_descripcion = i_nueva_descripcion
    WHERE med_tra_codigo = i_med_tra_codigo;

    -- 4. Lógica de Puestos
    IF i_nueva_capacidad > v_capacidad_anterior THEN
        -- CASO A: Aumentó capacidad -> Agregar nuevos puestos
        INSERT INTO puesto (fk_med_tra_codigo, pue_codigo, pue_descripcion, pue_costo_agregado)
        SELECT 
            i_med_tra_codigo, 
            s.num, 
            'Asiento Estándar ' || s.num, 
            0
        FROM generate_series(v_capacidad_anterior + 1, i_nueva_capacidad) AS s(num);
        
    ELSIF i_nueva_capacidad < v_capacidad_anterior THEN
        -- CASO B: Disminuyó capacidad -> Eliminar los puestos sobrantes (los últimos números)
        DELETE FROM puesto
        WHERE fk_med_tra_codigo = i_med_tra_codigo
        AND pue_codigo > i_nueva_capacidad;
    END IF;

    o_status_code := 200;
    o_mensaje := 'Avión actualizado correctamente.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;


CREATE OR REPLACE PROCEDURE sp_modificar_ruta(
    IN i_usu_codigo INTEGER,
    IN i_rut_codigo INTEGER,
    IN i_nuevo_costo NUMERIC,
    IN i_nuevas_millas INTEGER,
    IN i_nueva_descripcion VARCHAR, -- Nuevo parámetro
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_prov_id INTEGER;
    v_rut_prov_id INTEGER;
BEGIN
    -- Validaciones (igual que antes)
    IF NOT EXISTS (
        SELECT 1 FROM usuario u JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'modificar_recursos'
    ) THEN
        o_status_code := 403; o_mensaje := 'No tiene permisos para modificar rutas.'; RETURN;
    END IF;

    SELECT prov_codigo INTO v_prov_id FROM proveedor WHERE fk_usu_codigo = i_usu_codigo;
    SELECT fk_prov_codigo INTO v_rut_prov_id FROM ruta WHERE rut_codigo = i_rut_codigo;

    IF v_prov_id <> v_rut_prov_id OR v_rut_prov_id IS NULL THEN
        o_status_code := 403; o_mensaje := 'No puede modificar una ruta que no le pertenece.'; RETURN;
    END IF;

    -- Actualizar
    UPDATE ruta
    SET rut_costo = i_nuevo_costo,
        rut_millas_otorgadas = i_nuevas_millas,
        rut_descripcion = i_nueva_descripcion -- Actualizamos descripción
    WHERE rut_codigo = i_rut_codigo;

    o_status_code := 200; o_mensaje := 'Ruta actualizada correctamente.';
EXCEPTION WHEN OTHERS THEN
    o_status_code := 500; o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;

CREATE OR REPLACE PROCEDURE sp_modificar_traslado(
    IN i_usu_codigo INTEGER,
    IN i_tras_codigo INTEGER,
    IN i_nueva_fecha_inicio TIMESTAMP,
    IN i_nueva_fecha_fin TIMESTAMP,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_prov_id INTEGER;
    v_rut_prov_id INTEGER;
    v_med_tra_id INTEGER;
BEGIN
    -- Validar Permisos
    IF NOT EXISTS (
        SELECT 1 FROM usuario u JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'modificar_recursos'
    ) THEN
        o_status_code := 403; o_mensaje := 'No tiene permisos.'; RETURN;
    END IF;

    -- Validaciones Fecha
    IF i_nueva_fecha_inicio < CURRENT_TIMESTAMP THEN
        o_status_code := 400; o_mensaje := 'No puede reprogramar al pasado.'; RETURN;
    END IF;
    IF i_nueva_fecha_fin <= i_nueva_fecha_inicio THEN
        o_status_code := 400; o_mensaje := 'Fecha fin inválida.'; RETURN;
    END IF;

    -- Obtener IDs y Validar Propiedad (CORRECCIÓN: prov_codigo y fk_prov_codigo)
    SELECT p.prov_codigo INTO v_prov_id
    FROM proveedor p JOIN usuario u ON p.fk_usu_codigo = u.usu_codigo
    WHERE u.usu_codigo = i_usu_codigo;

    SELECT r.fk_prov_codigo, t.fk_med_tra_codigo INTO v_rut_prov_id, v_med_tra_id
    FROM traslado t JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
    WHERE t.tras_codigo = i_tras_codigo;

    IF v_prov_id <> v_rut_prov_id OR v_rut_prov_id IS NULL THEN
        o_status_code := 403; o_mensaje := 'No le pertenece este traslado.'; RETURN;
    END IF;

    -- Validar Solapamiento (Excluyendo el propio vuelo)
    IF EXISTS (
        SELECT 1 FROM traslado 
        WHERE fk_med_tra_codigo = v_med_tra_id
        AND tras_codigo <> i_tras_codigo
        AND (
            (tras_fecha_hora_inicio BETWEEN i_nueva_fecha_inicio AND i_nueva_fecha_fin) OR
            (tras_fecha_hora_fin BETWEEN i_nueva_fecha_inicio AND i_nueva_fecha_fin) OR
            (i_nueva_fecha_inicio BETWEEN tras_fecha_hora_inicio AND tras_fecha_hora_fin)
        )
    ) THEN
        o_status_code := 409; o_mensaje := 'Conflicto de horario con otro vuelo.'; RETURN;
    END IF;

    -- Actualizar
    UPDATE traslado
    SET tras_fecha_hora_inicio = i_nueva_fecha_inicio,
        tras_fecha_hora_fin = i_nueva_fecha_fin
    WHERE tras_codigo = i_tras_codigo;

    o_status_code := 200; o_mensaje := 'Horario actualizado.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500; o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;


CREATE OR REPLACE PROCEDURE sp_obtener_detalle_viajero(
    IN i_via_codigo INTEGER,
    INOUT o_json_documentos JSON DEFAULT '[]',
    INOUT o_json_historial JSON DEFAULT '[]',
    INOUT o_status_code INTEGER DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Obtener Documentos
    SELECT COALESCE(json_agg(row_to_json(d)), '[]') INTO o_json_documentos
    FROM (
        SELECT doc.*, n.nac_nombre 
        FROM documento doc 
        JOIN nacionalidad n ON doc.fk_nac_codigo = n.nac_codigo
        WHERE fk_via_codigo = i_via_codigo
    ) d;

    -- Obtener Historial Estado Civil
    SELECT COALESCE(json_agg(row_to_json(h)), '[]') INTO o_json_historial
    FROM (
        SELECT ve.*, ec.edo_civ_nombre 
        FROM via_edo ve
        JOIN estado_civil ec ON ve.fk_edo_codigo = ec.edo_civ_codigo
        WHERE fk_via_codigo = i_via_codigo
        ORDER BY via_edo_fecha_inicio DESC
    ) h;

    o_status_code := 200;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_obtener_estados_civiles(
    INOUT o_cursor REFCURSOR DEFAULT NULL,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    OPEN o_cursor FOR SELECT * FROM estado_civil ORDER BY edo_civ_codigo ASC;
    o_status_code := 200;
END; $$;

CREATE OR REPLACE PROCEDURE sp_obtener_flota_proveedor(
    IN i_prov_codigo INTEGER, -- CAMBIO: Nombre del parámetro actualizado
    INOUT o_cursor REFCURSOR DEFAULT NULL,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    OPEN o_cursor FOR
    SELECT 
        mt.med_tra_codigo,
        mt.med_tra_capacidad,
        mt.med_tra_descripcion,
        mt.med_tra_tipo,
        -- Lógica de Estado
        CASE 
            -- En Vuelo
            WHEN EXISTS (
                SELECT 1 FROM traslado t 
                WHERE t.fk_med_tra_codigo = mt.med_tra_codigo 
                AND CURRENT_TIMESTAMP BETWEEN t.tras_fecha_hora_inicio AND t.tras_fecha_hora_fin
            ) THEN 'En Vuelo'
            
            -- En Espera
            WHEN EXISTS (
                SELECT 1 FROM traslado t 
                WHERE t.fk_med_tra_codigo = mt.med_tra_codigo 
                AND t.tras_fecha_hora_inicio > CURRENT_TIMESTAMP
            ) THEN 'En Espera'
            
            -- Inactivo
            ELSE 'Inactivo'
        END AS estado_actual
    FROM medio_transporte mt
    -- CORRECCIÓN AQUÍ: Usamos fk_prov_codigo
    WHERE mt.fk_prov_codigo = i_prov_codigo 
    ORDER BY mt.med_tra_codigo DESC;

    o_status_code := 200;
    o_mensaje := 'Flota obtenida.';
EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;


CREATE OR REPLACE PROCEDURE sp_obtener_lugares_operacion(
    INOUT o_cursor REFCURSOR DEFAULT NULL,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    OPEN o_cursor FOR 
    SELECT 
        est.lug_codigo,
        -- Concatenamos: "NombreEstado, NombrePais"
        (est.lug_nombre || ', ' || pai.lug_nombre) AS lug_nombre,
        est.lug_tipo
    FROM lugar est
    -- Unimos con su padre (El País)
    JOIN lugar pai ON est.fk_lugar = pai.lug_codigo
    -- Filtramos ÚNICAMENTE los Estados
    WHERE est.lug_tipo = 'Estado'
    ORDER BY pai.lug_nombre ASC, est.lug_nombre ASC;

    o_status_code := 200;
    o_mensaje := 'Lista de Estados obtenida correctamente.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;


CREATE OR REPLACE PROCEDURE sp_obtener_nacionalidades(
    INOUT o_cursor REFCURSOR DEFAULT NULL,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN o_cursor FOR
    SELECT nac_codigo, nac_nombre FROM nacionalidad ORDER BY nac_nombre ASC;

    o_status_code := 200;
    o_mensaje := 'Lista de nacionalidades obtenida.';
EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;


CREATE OR REPLACE PROCEDURE sp_obtener_proveedores(
    INOUT o_cursor REFCURSOR DEFAULT NULL,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    OPEN o_cursor FOR 
    SELECT 
        p.prov_codigo, 
        p.prov_nombre, 
        p.prov_tipo, 
        p.prov_fecha_creacion,
        -- Cálculo dinámico de antigüedad
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.prov_fecha_creacion))::INTEGER AS anos_antiguedad,
        l.lug_nombre, 
        u.usu_nombre_usuario 
    FROM proveedor p
    JOIN lugar l ON p.fk_lugar = l.lug_codigo
    JOIN usuario u ON p.fk_usu_codigo = u.usu_codigo
    ORDER BY p.prov_codigo DESC;

    o_status_code := 200;
    o_mensaje := 'Lista obtenida.';
END; $$;


-- Actualizamos el SP para que devuelva 'rut_descripcion'
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
        r.rut_descripcion, -- <--- AGREGADO AQUÍ
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


CREATE OR REPLACE FUNCTION sp_buscar_home(
    _origen VARCHAR, 
    _destino VARCHAR, 
    _fecha DATE, 
    _tipo_filtro VARCHAR -- 'Traslados', 'Servicios', 'Ambos'
)
RETURNS TABLE (
    id INTEGER,
    categoria VARCHAR,
    titulo VARCHAR,
    subtipo VARCHAR,
    fecha_inicio TIMESTAMP,
    detalle_lugar VARCHAR,
    precio NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE 
    -- 1. CTE RECURSIVO PARA ORIGEN
    -- Encuentra el ID del lugar escrito (ej: 'Venezuela') y baja recursivamente a sus hijos (Estados, Ciudades)
    lugares_origen AS (
        SELECT lug_codigo FROM lugar 
        WHERE _origen IS NOT NULL AND _origen <> '' AND lug_nombre ILIKE '%' || _origen || '%'
        UNION ALL
        SELECT l.lug_codigo FROM lugar l
        INNER JOIN lugares_origen lo ON l.fk_lugar = lo.lug_codigo
    ),
    
    -- 2. CTE RECURSIVO PARA DESTINO
    lugares_destino AS (
        SELECT lug_codigo FROM lugar 
        WHERE _destino IS NOT NULL AND _destino <> '' AND lug_nombre ILIKE '%' || _destino || '%'
        UNION ALL
        SELECT l.lug_codigo FROM lugar l
        INNER JOIN lugares_destino ld ON l.fk_lugar = ld.lug_codigo
    ),

    -- 3. CONSULTA PRINCIPAL
    resultados AS (
        -- =============================================
        -- A) BUSCAR TRASLADOS
        -- =============================================
        SELECT 
            t.tras_codigo as res_id,
            'Traslado'::VARCHAR as res_cat,
            (lo.lug_nombre || ' -> ' || ld.lug_nombre)::VARCHAR as res_tit,
            r.rut_tipo::VARCHAR as res_sub,
            t.tras_fecha_hora_inicio as res_fec,
            ('Salida: ' || to_.ter_nombre || ' (' || lo.lug_nombre || ')')::VARCHAR as res_det,
            r.rut_costo as res_pre
        FROM traslado t
        JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
        JOIN terminal to_ ON r.fk_terminal_origen = to_.ter_codigo
        JOIN lugar lo ON to_.fk_lugar = lo.lug_codigo -- Lugar del terminal de origen
        JOIN terminal td ON r.fk_terminal_destino = td.ter_codigo
        JOIN lugar ld ON td.fk_lugar = ld.lug_codigo -- Lugar del terminal de destino
        WHERE (_tipo_filtro IN ('Traslados', 'Ambos'))
          AND t.tras_fecha_hora_inicio > NOW() -- Solo futuros
          
          -- VALIDACIÓN DE ORIGEN (Recursiva)
          -- Si el usuario escribió algo, el terminal de origen debe estar en esa jerarquía geográfica
          AND (
              _origen IS NULL OR _origen = '' 
              OR to_.fk_lugar IN (SELECT lug_codigo FROM lugares_origen)
          )
          
          -- VALIDACIÓN DE DESTINO (Recursiva)
          -- El terminal de destino debe estar en la jerarquía geográfica buscada
          AND (
              _destino IS NULL OR _destino = '' 
              OR td.fk_lugar IN (SELECT lug_codigo FROM lugares_destino)
          )
          
          -- VALIDACIÓN DE FECHA (Opcional)
          AND (_fecha IS NULL OR DATE(t.tras_fecha_hora_inicio) = _fecha)

        UNION ALL

        -- =============================================
        -- B) BUSCAR SERVICIOS
        -- =============================================
        SELECT 
            s.ser_codigo,
            'Servicio'::VARCHAR,
            s.ser_nombre::VARCHAR,
            'Servicio'::VARCHAR,
            s.ser_fecha_hora_inicio,
            (l.lug_nombre || ' - ' || COALESCE(s.ser_descripcion, ''))::VARCHAR,
            s.ser_costo
        FROM servicio s
        JOIN proveedor p ON s.fk_prov_codigo = p.prov_codigo
        JOIN lugar l ON p.fk_lugar = l.lug_codigo
        WHERE (_tipo_filtro IN ('Servicios', 'Ambos'))
          AND s.ser_fecha_hora_inicio > NOW()
          
          -- LÓGICA DE SERVICIOS:
          -- Los servicios no "viajan", ocurren en un lugar. 
          -- Por tanto, filtramos su ubicación solo contra el campo DESTINO del buscador.
          -- Si el usuario busca "Origen: Caracas" y "Destino: Vacío", no mostramos servicios (porque no es un viaje).
          
          AND (_origen IS NULL OR _origen = '') 
          
          AND (
              _destino IS NULL OR _destino = '' 
              OR l.lug_codigo IN (SELECT lug_codigo FROM lugares_destino)
          )
          
          AND (_fecha IS NULL OR DATE(s.ser_fecha_hora_inicio) = _fecha)
    )
    SELECT * FROM resultados ORDER BY res_fec ASC;
END;
$$ LANGUAGE plpgsql;



-- 1. TOP TRASLADOS
CREATE OR REPLACE FUNCTION sp_get_top_traslados()
RETURNS TABLE (
    id INTEGER,
    titulo VARCHAR,
    descripcion VARCHAR,
    fecha_inicio TIMESTAMP,
    tipo VARCHAR,
    origen VARCHAR,
    destino VARCHAR,
    precio NUMERIC,
    total_ventas BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.tras_codigo,
        (lug_o.lug_nombre || ' - ' || lug_d.lug_nombre)::VARCHAR,
        mt.med_tra_descripcion::VARCHAR,
        t.tras_fecha_hora_inicio,
        r.rut_tipo::VARCHAR,
        lug_o.lug_nombre::VARCHAR,
        lug_d.lug_nombre::VARCHAR,
        r.rut_costo,
        COUNT(dr.fk_compra) as ventas
    FROM traslado t
    JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
    JOIN terminal ter_o ON r.fk_terminal_origen = ter_o.ter_codigo
    JOIN lugar lug_o ON ter_o.fk_lugar = lug_o.lug_codigo
    JOIN terminal ter_d ON r.fk_terminal_destino = ter_d.ter_codigo
    JOIN lugar lug_d ON ter_d.fk_lugar = lug_d.lug_codigo
    JOIN medio_transporte mt ON t.fk_med_tra_codigo = mt.med_tra_codigo
    JOIN pue_tras pt ON pt.fk_tras_codigo = t.tras_codigo
    LEFT JOIN detalle_reserva dr ON (dr.fk_pue_tras = pt.pue_tras_codigo OR dr.fk_pue_tras1 = pt.pue_tras_codigo OR dr.fk_pue_tras2 = pt.pue_tras_codigo)
    WHERE t.tras_fecha_hora_fin > NOW()
    GROUP BY 
        t.tras_codigo, 
        lug_o.lug_nombre, 
        lug_d.lug_nombre, 
        mt.med_tra_descripcion, 
        t.tras_fecha_hora_inicio, 
        r.rut_tipo, 
        r.rut_costo
    ORDER BY ventas DESC
    LIMIT 10;
END;
$$ LANGUAGE plpgsql;

-- 2. TOP SERVICIOS
CREATE OR REPLACE FUNCTION sp_get_top_servicios()
RETURNS TABLE (
    id INTEGER,
    titulo VARCHAR,
    descripcion VARCHAR,
    fecha_inicio TIMESTAMP,
    tipo VARCHAR,
    subtipo VARCHAR,
    lugar VARCHAR,
    precio NUMERIC,
    total_ventas BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.ser_codigo,
        s.ser_nombre::VARCHAR,
        s.ser_descripcion::VARCHAR,
        s.ser_fecha_hora_inicio,
        'Servicio'::VARCHAR,
        s.ser_tipo::VARCHAR,
        l.lug_nombre::VARCHAR,
        s.ser_costo,
        COUNT(dr.fk_compra) as ventas
    FROM servicio s
    JOIN proveedor p ON s.fk_prov_codigo = p.prov_codigo
    JOIN lugar l ON p.fk_lugar = l.lug_codigo
    LEFT JOIN detalle_reserva dr ON dr.fk_servicio = s.ser_codigo
    WHERE s.ser_fecha_hora_fin > NOW()
    GROUP BY 
        s.ser_codigo, 
        s.ser_nombre, 
        s.ser_descripcion, 
        s.ser_fecha_hora_inicio, 
        s.ser_tipo, 
        l.lug_nombre, 
        s.ser_costo
    ORDER BY ventas DESC
    LIMIT 10;
END;
$$ LANGUAGE plpgsql;

-- 3. PROXIMOS (MIX)
CREATE OR REPLACE FUNCTION sp_get_proximos()
RETURNS TABLE (
    id INTEGER,
    tipo_recurso VARCHAR,
    titulo VARCHAR,
    subtipo VARCHAR,
    fecha_inicio TIMESTAMP,
    ubicacion VARCHAR,
    precio NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM (
        -- TRASLADOS
        SELECT 
            t.tras_codigo as id,
            'Traslado'::VARCHAR as tipo_recurso,
            (lo.lug_nombre || ' -> ' || ld.lug_nombre)::VARCHAR as titulo,
            r.rut_tipo::VARCHAR as subtipo,
            t.tras_fecha_hora_inicio AS fecha_inicio, 
            ld.lug_nombre::VARCHAR as ubicacion,
            r.rut_costo AS precio 
        FROM traslado t
        JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
        JOIN terminal to_ ON r.fk_terminal_origen = to_.ter_codigo
        JOIN lugar lo ON to_.fk_lugar = lo.lug_codigo
        JOIN terminal td ON r.fk_terminal_destino = td.ter_codigo
        JOIN lugar ld ON td.fk_lugar = ld.lug_codigo
        WHERE t.tras_fecha_hora_inicio > NOW()

        UNION ALL

        -- SERVICIOS
        SELECT 
            s.ser_codigo as id,
            'Servicio'::VARCHAR as tipo_recurso,
            s.ser_nombre::VARCHAR as titulo,
            'Servicio'::VARCHAR as subtipo,
            s.ser_fecha_hora_inicio AS fecha_inicio, 
            l.lug_nombre::VARCHAR as ubicacion,
            s.ser_costo AS precio 
        FROM servicio s
        JOIN proveedor p ON s.fk_prov_codigo = p.prov_codigo
        JOIN lugar l ON p.fk_lugar = l.lug_codigo
        WHERE s.ser_fecha_hora_inicio > NOW()
    ) AS unificado
    ORDER BY fecha_inicio ASC
    LIMIT 10;
END;
$$ LANGUAGE plpgsql;

















































































CREATE OR REPLACE PROCEDURE sp_obtener_traslados_proveedor(
    IN i_usu_codigo INTEGER,
    INOUT o_cursor REFCURSOR DEFAULT NULL,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_prov_id INTEGER; -- Variable renombrada para consistencia
BEGIN
    -- A. Identificar Proveedor
    -- CORRECCIÓN: Usamos prov_codigo
    SELECT p.prov_codigo INTO v_prov_id
    FROM proveedor p JOIN usuario u ON p.fk_usu_codigo = u.usu_codigo
    WHERE u.usu_codigo = i_usu_codigo;

    -- B. Consulta Completa
    OPEN o_cursor FOR
    SELECT 
        t.tras_codigo,
        t.tras_fecha_hora_inicio,
        t.tras_fecha_hora_fin,
        t.tras_CO2_Emitido,
        
        -- Info Ruta
        (orig.ter_nombre || ' -> ' || dest.ter_nombre) AS ruta_nombre,
        
        -- Info Transporte
        mt.med_tra_descripcion AS transporte_nombre,
        mt.med_tra_capacidad,
        
        -- Estado Calculado
        CASE 
            WHEN CURRENT_TIMESTAMP BETWEEN t.tras_fecha_hora_inicio AND t.tras_fecha_hora_fin THEN 'En Curso'
            WHEN t.tras_fecha_hora_inicio > CURRENT_TIMESTAMP THEN 'Programado'
            ELSE 'Finalizado'
        END AS estado_traslado

    FROM traslado t
    JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
    JOIN terminal orig ON r.fk_terminal_origen = orig.ter_codigo
    JOIN terminal dest ON r.fk_terminal_destino = dest.ter_codigo
    JOIN medio_transporte mt ON t.fk_med_tra_codigo = mt.med_tra_codigo
    
    -- CORRECCIÓN: Filtramos usando fk_prov_codigo
    WHERE r.fk_prov_codigo = v_prov_id 
    ORDER BY t.tras_fecha_hora_inicio DESC;

    o_status_code := 200;
    o_mensaje := 'Traslados obtenidos.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;

CREATE OR REPLACE PROCEDURE sp_obtener_viajeros_usuario(
    IN i_usu_codigo INTEGER,
    INOUT o_cursor REFCURSOR DEFAULT NULL, -- Usamos cursor para devolver tablas en procedimientos
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validación de privilegio
    IF NOT EXISTS (
        SELECT 1 FROM rol_privilegio rp 
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo 
        JOIN usuario u ON u.fk_rol_codigo = rp.fk_rol_codigo 
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'manipular_viajeros'
    ) THEN
        o_status_code := 403;
        o_mensaje := 'No tiene privilegios.';
        RETURN;
    END IF;

    OPEN o_cursor FOR
    SELECT * FROM viajero WHERE fk_usu_codigo = i_usu_codigo ORDER BY via_codigo DESC;

    o_status_code := 200;
    o_mensaje := 'Lista obtenida.';
END;
$$;

/*
CREATE OR REPLACE PROCEDURE sp_registrar_avion(
    IN i_usu_codigo INTEGER,       
    IN i_prov_codigo INTEGER,      
    IN i_capacidad INTEGER,
    IN i_descripcion TEXT,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_nuevo_cod INTEGER;
BEGIN
    -- 1. Validar Privilegio 'crear_recursos'
    IF NOT EXISTS (
        SELECT 1 FROM usuario u
        JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'crear_recursos'
    ) THEN
        o_status_code := 403;
        o_mensaje := 'No tiene privilegios para crear recursos.';
        RETURN;
    END IF;

    -- 2. Insertar el Medio de Transporte
    -- CORRECCIÓN: Cambiado fk_pro_codigo a fk_prov_codigo para coincidir con tu create.sql
    INSERT INTO medio_transporte (med_tra_capacidad, med_tra_descripcion, med_tra_tipo, fk_prov_codigo)
    VALUES (i_capacidad, i_descripcion, 'Avion', i_prov_codigo) 
    RETURNING med_tra_codigo INTO v_nuevo_cod;

    -- 3. Generar los Puestos automáticamente
    INSERT INTO puesto (fk_med_tra_codigo, pue_codigo, pue_descripcion, pue_costo_agregado)
    SELECT 
        v_nuevo_cod, 
        s.num, 
        'Asiento Estándar ' || s.num, 
        0
    FROM generate_series(1, i_capacidad) AS s(num);

    o_status_code := 201;
    o_mensaje := 'Avión registrado con ' || i_capacidad || ' puestos.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;*/
CREATE OR REPLACE PROCEDURE sp_registrar_avion(
    IN i_usu_codigo INTEGER,       
    IN i_prov_codigo INTEGER,      
    IN i_capacidad INTEGER,
    IN i_descripcion TEXT,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    -- 1. Validar Privilegio 'crear_recursos'
    IF NOT EXISTS (
        SELECT 1 FROM usuario u
        JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'crear_recursos'
    ) THEN
        o_status_code := 403;
        o_mensaje := 'No tiene privilegios para crear recursos.';
        RETURN;
    END IF;

    -- 2. Insertar el Medio de Transporte
    -- ALERTA: El Trigger 'trg_llenar_puestos_automaticamente' se disparará aquí
    -- y creará los puestos por ti. No hace falta más lógica.
    INSERT INTO medio_transporte (med_tra_capacidad, med_tra_descripcion, med_tra_tipo, fk_prov_codigo)
    VALUES (i_capacidad, i_descripcion, 'Avion', i_prov_codigo);

    o_status_code := 201;
    o_mensaje := 'Avión registrado y puestos generados automáticamente.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;


CREATE OR REPLACE PROCEDURE sp_registrar_proveedor(
    IN i_admin_id INTEGER,
    IN i_prov_nombre VARCHAR,
    IN i_prov_fecha_creacion DATE, -- Nuevo parámetro DATE
    IN i_prov_tipo VARCHAR,
    IN i_fk_lugar INTEGER,
    IN i_usu_nombre VARCHAR,
    IN i_usu_contrasena VARCHAR,
    IN i_usu_email VARCHAR,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_rol_prov_id INTEGER;
    v_nuevo_usu_id INTEGER;
BEGIN
    -- Validar Privilegio 'crear_usuarios'
    IF NOT EXISTS (
        SELECT 1 FROM usuario u 
        JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo 
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo 
        WHERE u.usu_codigo = i_admin_id AND p.pri_nombre = 'crear_usuarios'
    ) THEN
        o_status_code := 403; o_mensaje := 'No tiene privilegios para crear proveedores.'; RETURN;
    END IF;

    -- Obtener Rol 'Proveedor'
    SELECT rol_codigo INTO v_rol_prov_id FROM rol WHERE rol_nombre = 'Proveedor';
    
    -- Crear Usuario (asociado al lugar)
    INSERT INTO usuario (usu_nombre_usuario, usu_contrasena, fk_rol_codigo, usu_total_millas, usu_email, fk_lugar)
    VALUES (i_usu_nombre, i_usu_contrasena, v_rol_prov_id, 0, i_usu_email, i_fk_lugar)
    RETURNING usu_codigo INTO v_nuevo_usu_id;

    -- Crear Proveedor (Usando prov_fecha_creacion)
    INSERT INTO proveedor (prov_nombre, prov_fecha_creacion, prov_tipo, fk_lugar, fk_usu_codigo)
    VALUES (i_prov_nombre, i_prov_fecha_creacion, i_prov_tipo, i_fk_lugar, v_nuevo_usu_id);

    o_status_code := 201;
    o_mensaje := 'Proveedor registrado exitosamente.';

EXCEPTION 
    WHEN unique_violation THEN
        o_status_code := 409; o_mensaje := 'El usuario o correo ya existe.';
    WHEN OTHERS THEN
        o_status_code := 500; o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;

CREATE OR REPLACE PROCEDURE sp_registrar_ruta(
    IN i_usu_codigo INTEGER,
    IN i_costo NUMERIC,
    IN i_millas INTEGER,
    IN i_rut_tipo VARCHAR, 
    IN i_rut_descripcion VARCHAR, -- NUEVO PARÁMETRO
    IN i_fk_origen INTEGER,
    IN i_fk_destino INTEGER,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_prov_id INTEGER;
    v_prov_tipo VARCHAR;
    v_tipo_origen VARCHAR;
    v_tipo_destino VARCHAR;
BEGIN
    -- A. Validar Permisos
    IF NOT EXISTS (
        SELECT 1 FROM usuario u JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'crear_recursos'
    ) THEN
        o_status_code := 403; o_mensaje := 'No tiene permisos para crear rutas.'; RETURN;
    END IF;

    -- B. Obtener Proveedor
    SELECT prov_codigo, prov_tipo INTO v_prov_id, v_prov_tipo
    FROM proveedor WHERE fk_usu_codigo = i_usu_codigo;

    -- C. Validar Origen != Destino
    IF i_fk_origen = i_fk_destino THEN
        o_status_code := 400; o_mensaje := 'El origen y el destino no pueden ser iguales.'; RETURN;
    END IF;

    -- D. Obtener Tipos de Terminal
    SELECT ter_tipo INTO v_tipo_origen FROM terminal WHERE ter_codigo = i_fk_origen;
    SELECT ter_tipo INTO v_tipo_destino FROM terminal WHERE ter_codigo = i_fk_destino;

    -- E. Validaciones de Consistencia
    IF v_prov_tipo = 'Aerolinea' AND (v_tipo_origen <> 'Aeropuerto' OR v_tipo_destino <> 'Aeropuerto') THEN
        o_status_code := 409; o_mensaje := 'Aerolíneas solo pueden usar Aeropuertos.'; RETURN;
    END IF;

    IF v_prov_tipo = 'Maritimo' AND (v_tipo_origen <> 'Puerto' OR v_tipo_destino <> 'Puerto') THEN
        o_status_code := 409; o_mensaje := 'Un proveedor Marítimo solo opera entre Puertos.'; RETURN;
    END IF;

    IF v_prov_tipo = 'Terrestre' AND (v_tipo_origen NOT IN ('Terminal Terrestre', 'Estacion') OR v_tipo_destino NOT IN ('Terminal Terrestre', 'Estacion')) THEN
        o_status_code := 409; o_mensaje := 'Proveedor Terrestre solo opera en Terminales o Estaciones.'; RETURN;
    END IF;

    -- F. Insertar (Ahora incluye rut_descripcion)
    INSERT INTO ruta (rut_costo, rut_millas_otorgadas, rut_tipo, rut_descripcion, fk_terminal_origen, fk_terminal_destino, fk_prov_codigo)
    VALUES (i_costo, i_millas, i_rut_tipo, i_rut_descripcion, i_fk_origen, i_fk_destino, v_prov_id);

    o_status_code := 201;
    o_mensaje := 'Ruta creada exitosamente.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500; o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;

CREATE OR REPLACE PROCEDURE sp_registrar_traslado(
    IN i_usu_codigo INTEGER,
    IN i_rut_codigo INTEGER,
    IN i_med_tra_codigo INTEGER,
    IN i_fecha_inicio TIMESTAMP,
    IN i_fecha_fin TIMESTAMP,
    IN i_co2 NUMERIC,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_prov_id INTEGER;
BEGIN
    -- A. Validar Permisos
    IF NOT EXISTS (
        SELECT 1 FROM usuario u JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'crear_recursos'
    ) THEN
        o_status_code := 403; o_mensaje := 'No tiene permisos para crear traslados.'; RETURN;
    END IF;

    -- B. Validaciones de Fecha
    IF i_fecha_inicio < CURRENT_TIMESTAMP THEN
        o_status_code := 400; o_mensaje := 'Error: La fecha de salida no puede ser en el pasado.'; RETURN;
    END IF;
    IF i_fecha_fin <= i_fecha_inicio THEN
        o_status_code := 400; o_mensaje := 'Error: La fecha de llegada debe ser posterior a la salida.'; RETURN;
    END IF;

    -- C. Obtener ID Proveedor (CORRECCIÓN AQUÍ: prov_codigo)
    SELECT p.prov_codigo INTO v_prov_id
    FROM proveedor p JOIN usuario u ON p.fk_usu_codigo = u.usu_codigo
    WHERE u.usu_codigo = i_usu_codigo;

    IF v_prov_id IS NULL THEN
        o_status_code := 404; o_mensaje := 'Usuario no es proveedor.'; RETURN;
    END IF;

    -- D. Validar Propiedad de RUTA (CORRECCIÓN AQUÍ: fk_prov_codigo)
    IF NOT EXISTS (SELECT 1 FROM ruta WHERE rut_codigo = i_rut_codigo AND fk_prov_codigo = v_prov_id) THEN
        o_status_code := 409; o_mensaje := 'Error: La ruta seleccionada no pertenece a su organización.'; RETURN;
    END IF;

    -- E. Validar Propiedad de TRANSPORTE (CORRECCIÓN AQUÍ: fk_prov_codigo)
    IF NOT EXISTS (SELECT 1 FROM medio_transporte WHERE med_tra_codigo = i_med_tra_codigo AND fk_prov_codigo = v_prov_id) THEN
        o_status_code := 409; o_mensaje := 'Error: El transporte seleccionado no pertenece a su flota.'; RETURN;
    END IF;

    -- F. Validar Disponibilidad (Solapamiento)
    IF EXISTS (
        SELECT 1 FROM traslado 
        WHERE fk_med_tra_codigo = i_med_tra_codigo
        AND (
            (tras_fecha_hora_inicio BETWEEN i_fecha_inicio AND i_fecha_fin) OR
            (tras_fecha_hora_fin BETWEEN i_fecha_inicio AND i_fecha_fin) OR
            (i_fecha_inicio BETWEEN tras_fecha_hora_inicio AND tras_fecha_hora_fin)
        )
    ) THEN
        o_status_code := 409; o_mensaje := 'El avión ya tiene un viaje programado en ese horario.'; RETURN;
    END IF;

    -- G. Insertar
    INSERT INTO traslado (tras_fecha_hora_inicio, tras_fecha_hora_fin, tras_CO2_Emitido, fk_rut_codigo, fk_med_tra_codigo)
    VALUES (i_fecha_inicio, i_fecha_fin, i_co2, i_rut_codigo, i_med_tra_codigo);

    o_status_code := 201; o_mensaje := 'Traslado programado exitosamente.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500; o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;

CREATE OR REPLACE PROCEDURE sp_registrar_usuario_cliente(
    IN i_nombre_usuario VARCHAR,
    IN i_contrasena VARCHAR,
    IN i_correo VARCHAR,
    IN i_fk_lugar INTEGER, -- NUEVO PARÁMETRO
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL,
    INOUT o_usu_codigo INTEGER DEFAULT NULL,
    INOUT o_usu_nombre VARCHAR DEFAULT NULL,
    INOUT o_usu_correo VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_rol_cliente_id INTEGER;
BEGIN
    -- 1. Validar que el rol 'Cliente' exista
    SELECT rol_codigo INTO v_rol_cliente_id FROM rol WHERE rol_nombre = 'Cliente';
    
    IF v_rol_cliente_id IS NULL THEN
        o_status_code := 500;
        o_mensaje := 'Error: El rol Cliente no está configurado en la base de datos.';
        RETURN;
    END IF;

    -- 2. Validar que el Lugar sea un ESTADO válido
    IF NOT EXISTS (SELECT 1 FROM lugar WHERE lug_codigo = i_fk_lugar AND lug_tipo = 'Estado') THEN
        o_status_code := 400;
        o_mensaje := 'Error: Debe seleccionar un Estado válido para el domicilio.';
        RETURN;
    END IF;

    -- 3. Validar si el usuario ya existe
    IF EXISTS (SELECT 1 FROM usuario WHERE usu_nombre_usuario = i_nombre_usuario) THEN
        o_status_code := 409; -- Conflict
        o_mensaje := 'El nombre de usuario ya está en uso.';
        RETURN;
    END IF;

    -- 4. Validar si el correo ya existe
    IF EXISTS (SELECT 1 FROM usuario WHERE usu_email = i_correo) THEN
        o_status_code := 409;
        o_mensaje := 'El correo electrónico ya está registrado.';
        RETURN;
    END IF;

    -- 5. Insertar el Usuario (Con fk_lugar)
    INSERT INTO usuario (
        usu_nombre_usuario, 
        usu_contrasena, 
        fk_rol_codigo, 
        usu_total_millas, 
        usu_email,
        fk_lugar -- NUEVO CAMPO
    )
    VALUES (
        i_nombre_usuario, 
        i_contrasena, 
        v_rol_cliente_id, 
        0, 
        i_correo,
        i_fk_lugar -- NUEVO VALOR
    )
    RETURNING usu_codigo INTO o_usu_codigo;

    -- 6. Retornar éxito
    o_status_code := 201; -- Created
    o_mensaje := 'Usuario registrado exitosamente.';
    o_usu_nombre := i_nombre_usuario;
    o_usu_correo := i_correo;

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error interno del servidor: ' || SQLERRM;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_crear_viajero(
    IN i_usu_codigo INTEGER,         -- ID del usuario que hace la petición
    IN i_via_prim_nombre VARCHAR,
    IN i_via_seg_nombre VARCHAR,
    IN i_via_prim_apellido VARCHAR,
    IN i_via_seg_apellido VARCHAR,
    IN i_via_fecha_nacimiento DATE,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL,
    INOUT o_via_codigo INTEGER DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validación de privilegio
    IF NOT EXISTS (
        SELECT 1 FROM rol_privilegio rp 
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo 
        JOIN usuario u ON u.fk_rol_codigo = rp.fk_rol_codigo 
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'manipular_viajeros'
    ) THEN
        o_status_code := 403;
        o_mensaje := 'No tiene privilegios para manipular viajeros.';
        RETURN;
    END IF;

    INSERT INTO viajero (via_prim_nombre, via_seg_nombre, via_prim_apellido, via_seg_apellido, via_fecha_nacimiento, fk_usu_codigo)
    VALUES (i_via_prim_nombre, i_via_seg_nombre, i_via_prim_apellido, i_via_seg_apellido, i_via_fecha_nacimiento, i_usu_codigo)
    RETURNING via_codigo INTO o_via_codigo;

    o_status_code := 201;
    o_mensaje := 'Viajero registrado exitosamente.';
EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;

CREATE OR REPLACE FUNCTION public.sp_listar_servicios_genericos(
	)
    RETURNS TABLE(id integer, nombre character varying, descripcion character varying, fecha_inicio timestamp without time zone, costo numeric) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY 
    SELECT 
        ser_codigo, 
        ser_nombre, 
        ser_descripcion, 
        ser_fecha_hora_inicio,
        ser_costo 
    FROM servicio 
    WHERE ser_tipo NOT IN ('Alojamiento', 'Hotel', 'Comida', 'Restaurante');
END;
$BODY$;

CREATE OR REPLACE PROCEDURE public.sp_asignar_servicio_generico(
	IN _id_paquete integer,
	IN _id_servicio integer,
	IN _cantidad integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    INSERT INTO paq_ser (fk_paq_tur_codigo, fk_ser_codigo, cantidad)
    VALUES (_id_paquete, _id_servicio, _cantidad)
    ON CONFLICT (fk_paq_tur_codigo, fk_ser_codigo) 
    DO UPDATE SET cantidad = paq_ser.cantidad + _cantidad;
END;
$BODY$;



CREATE OR REPLACE FUNCTION sp_listar_servicios_disponibles()
RETURNS TABLE (
    id INT,
    nombre VARCHAR,
    tipo VARCHAR,
    costo NUMERIC
) AS $$
BEGIN
    RETURN QUERY 
    SELECT ser_codigo, ser_nombre, ser_tipo, ser_costo 
    FROM servicio 
    WHERE ser_tipo IN ('Alojamiento', 'Comida', 'Restaurante', 'Hotel'); 
END;
$$ LANGUAGE plpgsql;

-- 2. OBTENER TRASLADOS (Con información legible de la ruta)
-- 1. ACTUALIZAR: Listar traslados incluyendo fecha y hora
CREATE OR REPLACE FUNCTION sp_listar_traslados_disponibles()
RETURNS TABLE (
    id INT,
    descripcion TEXT,
    fecha TEXT, -- Nuevo campo
    costo NUMERIC
) AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        t.tras_codigo, 
        (mt.med_tra_tipo || ' - ' || term_o.ter_nombre || ' -> ' || term_d.ter_nombre)::TEXT,
        TO_CHAR(t.tras_fecha_hora_inicio, 'DD/MM/YYYY HH24:MI'), -- Formato legible
        r.rut_costo
    FROM traslado t
    JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
    JOIN terminal term_o ON r.fk_terminal_origen = term_o.ter_codigo
    JOIN terminal term_d ON r.fk_terminal_destino = term_d.ter_codigo
    JOIN medio_transporte mt ON t.fk_med_tra_codigo = mt.med_tra_codigo
    WHERE t.tras_fecha_hora_inicio > NOW(); -- Solo futuros
END;
$$ LANGUAGE plpgsql;

-- 2. NUEVO: Eliminar elemento del paquete
CREATE OR REPLACE PROCEDURE sp_eliminar_elemento_paquete(
    IN _tipo VARCHAR,               -- 'servicio', 'traslado', 'regla', 'habitacion', 'restaurante'
    IN _id_paquete INTEGER,         -- ID del Paquete
    IN _id_elemento INTEGER,        -- ID Principal (ser_codigo, tras_codigo, reg_codigo, hab_num, res_codigo)
    IN _fecha_inicio TIMESTAMP DEFAULT NULL, -- Requerido para Habitacion/Restaurante
    IN _extra_id INTEGER DEFAULT NULL        -- Requerido para Restaurante (num_mesa)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Eliminar Servicio
    IF _tipo = 'servicio' THEN
        DELETE FROM paq_ser 
        WHERE fk_paq_tur_codigo = _id_paquete AND fk_ser_codigo = _id_elemento;

    -- 2. Eliminar Traslado
    ELSIF _tipo = 'traslado' THEN
        DELETE FROM paq_tras 
        WHERE fk_paq_tur_codigo = _id_paquete AND fk_tras_codigo = _id_elemento;

    -- 3. Eliminar Regla
    ELSIF _tipo = 'regla' THEN
        DELETE FROM reg_paq_paq 
        WHERE fk_paq_tur_codigo = _id_paquete AND fk_reg_paq_codigo = _id_elemento;

    -- 4. Eliminar Reserva de Habitación (Requiere ID Habitación + Fecha Inicio)
    ELSIF _tipo = 'habitacion' THEN
        IF _fecha_inicio IS NULL THEN
            RAISE EXCEPTION 'Para eliminar habitación se requiere fecha de inicio';
        END IF;
        
        DELETE FROM reserva_de_habitacion 
        WHERE fk_paquete_turistico = _id_paquete 
          AND fk_habitacion = _id_elemento
          AND res_hab_fecha_hora_inicio = _fecha_inicio;

    -- 5. Eliminar Reserva de Restaurante (Requiere ID Rest + Fecha + Num Mesa)
    ELSIF _tipo = 'restaurante' THEN
        IF _fecha_inicio IS NULL OR _extra_id IS NULL THEN
            RAISE EXCEPTION 'Para eliminar restaurante se requiere fecha y número de mesa';
        END IF;

        DELETE FROM reserva_restaurante 
        WHERE fk_paquete_turistico = _id_paquete 
          AND fk_restaurante = _id_elemento
          AND res_rest_fecha_hora = _fecha_inicio
          AND res_rest_num_mesa = _extra_id;
    
    ELSE
        RAISE EXCEPTION 'Tipo de elemento no válido: %', _tipo;
    END IF;
END;
$$;
-- 3. ASIGNAR SERVICIO A PAQUETE (Hoteles, Restaurantes, etc.)
CREATE OR REPLACE PROCEDURE sp_asignar_servicio_paquete(
    _id_paquete INT,
    _id_servicio INT,
    _cantidad INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insertar si no existe (upsert simple)
    INSERT INTO paq_ser (fk_paq_tur_codigo, fk_ser_codigo, cantidad)
    VALUES (_id_paquete, _id_servicio, _cantidad)
    ON CONFLICT (fk_paq_tur_codigo, fk_ser_codigo) 
    DO UPDATE SET cantidad = paq_ser.cantidad + _cantidad;
END;
$$;

-- 4. ASIGNAR TRASLADO A PAQUETE
CREATE OR REPLACE PROCEDURE sp_asignar_traslado_paquete(
    _id_paquete INT,
    _id_traslado INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO paq_tras (fk_paq_tur_codigo, fk_tras_codigo)
    VALUES (_id_paquete, _id_traslado)
    ON CONFLICT (fk_paq_tur_codigo, fk_tras_codigo) DO NOTHING;
END;
$$;


-- 2. OBTENER REGLAS (Con Cursor)
-- Coincide con: CALL sp_obtener_reglas_paquete(NULL, NULL, NULL)
CREATE OR REPLACE PROCEDURE sp_obtener_reglas_paquete(
    INOUT o_cursor REFCURSOR DEFAULT NULL,
    INOUT o_status_code INT DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    o_cursor := 'cur_reglas'; -- Nombre del cursor
    
    OPEN o_cursor FOR
        SELECT * FROM regla_paquete ORDER BY reg_paq_codigo DESC;

    o_status_code := 200;
    o_mensaje := 'Reglas obtenidas correctamente';
EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error al listar reglas: ' || SQLERRM;
END;
$$;

-- 3. ASIGNAR REGLA A PAQUETE
-- Coincide con: CALL sp_asignar_regla_paquete($1, $2, NULL, NULL)
CREATE OR REPLACE PROCEDURE sp_asignar_regla_paquete(
    IN _fk_paquete INT,
    IN _fk_regla INT,
    INOUT o_status_code INT DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificamos si ya existe la asignación para no duplicar
    IF EXISTS (SELECT 1 FROM reg_paq_paq WHERE fk_paq_tur_codigo = _fk_paquete AND fk_reg_paq_codigo = _fk_regla) THEN
        o_status_code := 409; -- Conflict
        o_mensaje := 'Esta regla ya está asignada al paquete';
        RETURN;
    END IF;

    INSERT INTO reg_paq_paq (fk_paq_tur_codigo, fk_reg_paq_codigo)
    VALUES (_fk_paquete, _fk_regla);

    o_status_code := 201;
    o_mensaje := 'Regla asignada correctamente';
EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error al asignar regla: ' || SQLERRM;
END;
$$;


CREATE OR REPLACE PROCEDURE sp_obtener_paquetes_turisticos(
    OUT o_cursor REFCURSOR,
    OUT o_status_code INTEGER,
    OUT o_mensaje VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Abrimos el cursor con todos los datos
    OPEN o_cursor FOR
        SELECT 
            paq_tur_codigo,
            paq_tur_nombre,
            paq_tur_monto_total,
            paq_tur_monto_subtotal,
            paq_tur_costo_en_millas
        FROM paquete_turistico
        ORDER BY paq_tur_codigo DESC; -- Ordenados del más nuevo al más viejo

    o_status_code := 200;
    o_mensaje := 'Paquetes obtenidos exitosamente';

EXCEPTION
    WHEN OTHERS THEN
        o_status_code := 500;
        o_mensaje := 'Error al obtener paquetes: ' || SQLERRM;
        o_cursor := NULL;
END;
$$;


CREATE OR REPLACE FUNCTION public.sp_listar_habitaciones_info(
	)
    RETURNS TABLE(id integer, info_hotel text, info_habitacion text, costo numeric) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY 
    SELECT 
        h.hab_num_hab, 
        hot.hot_nombre::TEXT,
        (h.hab_descripcion || ' - Capacidad: ' || h.hab_capacidad)::TEXT,
        h.hab_costo_noche
    FROM habitacion h
    JOIN hotel hot ON h.fk_hotel = hot.hot_codigo;
END;
$BODY$;

CREATE OR REPLACE PROCEDURE public.sp_agregar_reserva_habitacion_paquete(
	IN _id_paquete integer,
	IN _id_habitacion integer,
	IN _fecha_inicio timestamp without time zone,
	IN _fecha_fin timestamp without time zone,
	IN _costo numeric)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    INSERT INTO reserva_de_habitacion (
        res_hab_fecha_hora_inicio, 
        res_hab_fecha_hora_fin, 
        res_hab_costo_unitario, 
        fk_habitacion, 
        fk_paquete_turistico,
        fk_detalle_reserva,   -- Permitimos NULL
        fk_detalle_reserva_2  -- Permitimos NULL
    )
    VALUES (
        _fecha_inicio, 
        _fecha_fin, 
        _costo, 
        _id_habitacion, 
        _id_paquete,
        NULL, NULL
    );
END;
$BODY$;

CREATE OR REPLACE FUNCTION public.sp_listar_restaurantes_info(
	)
    RETURNS TABLE(id integer, nombre character varying, descripcion character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY 
    SELECT res_codigo, res_nombre, res_descripcion FROM restaurante;
END;
$BODY$;


CREATE OR REPLACE PROCEDURE public.sp_agregar_reserva_restaurante_paquete(
	IN _id_paquete integer,
	IN _id_restaurante integer,
	IN _fecha timestamp without time zone,
	IN _num_mesa integer,
	IN _tamano_mesa integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    INSERT INTO reserva_restaurante (
        res_rest_fecha_hora, 
        res_rest_num_mesa, 
        res_rest_tamano_mesa, 
        fk_restaurante, 
        fk_paquete_turistico,
        fk_detalle_reserva,
        fk_detalle_reserva_2
    )
    VALUES (
        _fecha, 
        _num_mesa, 
        _tamano_mesa, 
        _id_restaurante, 
        _id_paquete,
        NULL, NULL
    );
END;
$BODY$;


CREATE OR REPLACE PROCEDURE public.sp_asignar_traslado_paquete(
	IN _id_paquete integer,
	IN _id_traslado integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    INSERT INTO paq_tras (fk_paq_tur_codigo, fk_tras_codigo)
    VALUES (_id_paquete, _id_traslado)
    ON CONFLICT (fk_paq_tur_codigo, fk_tras_codigo) DO NOTHING;
END;
$BODY$;

-- 1. DETALLE SERVICIOS (Agregamos cod_servicio)
CREATE OR REPLACE FUNCTION public.sp_det_paq_servicios(_id integer)
    RETURNS TABLE(cod_servicio integer, nombre character varying, tipo character varying, cantidad integer) 
LANGUAGE 'plpgsql'
AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        ser.ser_codigo, -- ID NECESARIO
        ser.ser_nombre::VARCHAR,
        ser.ser_tipo::VARCHAR,
        ps.cantidad
    FROM paq_ser ps
    JOIN servicio ser ON ps.fk_ser_codigo = ser.ser_codigo
    WHERE ps.fk_paq_tur_codigo = _id;
END;
$$;

-- 2. DETALLE TRASLADOS (Agregamos cod_traslado)
CREATE OR REPLACE FUNCTION public.sp_det_paq_traslados(_id integer)
    RETURNS TABLE(cod_traslado integer, origen character varying, destino character varying, tipo character varying) 
LANGUAGE 'plpgsql'
AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        tr.tras_codigo, -- ID NECESARIO
        ter_o.ter_nombre::VARCHAR, 
        ter_d.ter_nombre::VARCHAR, 
        mt.med_tra_tipo::VARCHAR
    FROM paq_tras pt
    JOIN traslado tr ON pt.fk_tras_codigo = tr.tras_codigo
    JOIN ruta r ON tr.fk_rut_codigo = r.rut_codigo
    JOIN terminal ter_o ON r.fk_terminal_origen = ter_o.ter_codigo
    JOIN terminal ter_d ON r.fk_terminal_destino = ter_d.ter_codigo
    JOIN medio_transporte mt ON tr.fk_med_tra_codigo = mt.med_tra_codigo
    WHERE pt.fk_paq_tur_codigo = _id;
END;
$$;

-- 3. DETALLE REGLAS (Agregamos cod_regla)
CREATE OR REPLACE FUNCTION public.sp_det_paq_reglas(_id integer)
    RETURNS TABLE(cod_regla integer, atributo character varying, operador character varying, valor character varying) 
LANGUAGE 'plpgsql'
AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        rp.reg_paq_codigo, -- ID NECESARIO
        rp.reg_paq_atributo, 
        rp.reg_paq_operador, 
        rp.reg_paq_valor
    FROM reg_paq_paq rpp
    JOIN regla_paquete rp ON rpp.fk_reg_paq_codigo = rp.reg_paq_codigo
    WHERE rpp.fk_paq_tur_codigo = _id;
END;
$$;

-- 4. DETALLE ALOJAMIENTOS (Agregamos fecha_inicio para poder borrar la reserva exacta)
CREATE OR REPLACE FUNCTION public.sp_det_paq_alojamientos(_id integer)
    RETURNS TABLE(num_habitacion integer, fecha_inicio timestamp, nombre_hotel character varying, habitacion character varying, entrada text, salida text) 
LANGUAGE 'plpgsql'
AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        rh.fk_habitacion, 
        rh.res_hab_fecha_hora_inicio, -- NECESARIO PARA BORRAR
        hot.hot_nombre::VARCHAR,
        hab.hab_descripcion::VARCHAR,
        TO_CHAR(rh.res_hab_fecha_hora_inicio, 'DD/MM/YYYY HH24:MI'),
        TO_CHAR(rh.res_hab_fecha_hora_fin, 'DD/MM/YYYY HH24:MI')
    FROM reserva_de_habitacion rh
    JOIN habitacion hab ON rh.fk_habitacion = hab.hab_num_hab
    JOIN hotel hot ON hab.fk_hotel = hot.hot_codigo
    WHERE rh.fk_paquete_turistico = _id;
END;
$$;

-- 5. DETALLE RESTAURANTES (Agregamos datos clave para borrar)
CREATE OR REPLACE FUNCTION public.sp_det_paq_restaurantes(_id integer)
    RETURNS TABLE(cod_restaurante integer, fecha_reserva timestamp, num_mesa_id integer, nombre_restaurante character varying, mesa integer, personas integer, fecha text) 
LANGUAGE 'plpgsql'
AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        res.res_codigo,
        rr.res_rest_fecha_hora,
        rr.res_rest_num_mesa,
        res.res_nombre::VARCHAR,
        rr.res_rest_num_mesa,
        rr.res_rest_tamano_mesa,
        TO_CHAR(rr.res_rest_fecha_hora, 'DD/MM/YYYY HH24:MI')
    FROM reserva_restaurante rr
    JOIN restaurante res ON rr.fk_restaurante = res.res_codigo
    WHERE rr.fk_paquete_turistico = _id;
END;
$$;
COMMIT;









BEGIN;

-- ==============================================================================
-- 1. MODIFICACIONES ESTRUCTURALES (ALTERS)
-- ==============================================================================

-- Agregamos columna de control de disponibilidad a los asientos (pue_tras)
ALTER TABLE pue_tras ADD COLUMN disponible BOOLEAN DEFAULT TRUE;

-- ==============================================================================
-- 2. FUNCIONES AUXILIARES Y TRIGGERS
-- ==============================================================================

-- A. Trigger para bloquear asiento al reservar
CREATE OR REPLACE FUNCTION fn_actualizar_disponibilidad_asiento()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fk_pue_tras IS NOT NULL THEN
        UPDATE pue_tras 
        SET disponible = FALSE 
        WHERE pue_tras_codigo = NEW.fk_pue_tras;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_bloquear_asiento
AFTER INSERT ON detalle_reserva
FOR EACH ROW
EXECUTE FUNCTION fn_actualizar_disponibilidad_asiento();

-- B. Función para evaluar reglas de paquete dinámicamente
CREATE OR REPLACE FUNCTION fn_evaluar_regla(
    val_real NUMERIC, 
    operador VARCHAR, 
    val_ref NUMERIC
) RETURNS BOOLEAN AS $$
BEGIN
    IF operador = '=' THEN RETURN val_real = val_ref;
    ELSIF operador = '>' THEN RETURN val_real > val_ref;
    ELSIF operador = '<' THEN RETURN val_real < val_ref;
    ELSIF operador = '>=' THEN RETURN val_real >= val_ref;
    ELSIF operador = '<=' THEN RETURN val_real <= val_ref;
    ELSIF operador = '<>' THEN RETURN val_real <> val_ref;
    ELSE RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- C. Trigger para otorgar Millas automáticamente
CREATE OR REPLACE FUNCTION fn_otorgar_millas_compra()
RETURNS TRIGGER AS $$
DECLARE
    v_millas_ganadas INTEGER := 0;
    v_millas_ruta INTEGER;
    v_millas_servicio INTEGER;
    v_millas_paquete INTEGER;
BEGIN
    -- 1. Calcular millas si es Traslado
    IF NEW.fk_pue_tras IS NOT NULL THEN
        SELECT r.rut_millas_otorgadas INTO v_millas_ruta
        FROM pue_tras pt
        JOIN traslado t ON pt.fk_tras_codigo = t.tras_codigo
        JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
        WHERE pt.pue_tras_codigo = NEW.fk_pue_tras;
        v_millas_ganadas := COALESCE(v_millas_ruta, 0);
    
    -- 2. Calcular millas si es Servicio
    ELSIF NEW.fk_servicio IS NOT NULL THEN
        SELECT ser_millas_otorgadas INTO v_millas_servicio
        FROM servicio WHERE ser_codigo = NEW.fk_servicio;
        v_millas_ganadas := COALESCE(v_millas_servicio, 0);

    -- 3. Calcular millas si es Paquete
    ELSIF NEW.fk_paquete_turistico IS NOT NULL THEN
        SELECT paq_tur_costo_en_millas INTO v_millas_paquete -- Asumimos que costo en millas tb sirve como ganancia o tienes una columna 'otorgadas' separada. Usaré esta por ahora.
        FROM paquete_turistico WHERE paq_tur_codigo = NEW.fk_paquete_turistico;
        v_millas_ganadas := COALESCE(v_millas_paquete, 0);
    END IF;

    -- 4. Actualizar Usuario y Registrar Historial
    IF v_millas_ganadas > 0 THEN
        UPDATE usuario 
        SET usu_total_millas = usu_total_millas + v_millas_ganadas
        WHERE usu_codigo = (SELECT fk_usuario FROM compra WHERE com_codigo = NEW.fk_compra);

        INSERT INTO milla (mil_valor_obtenido, mil_fecha_inicio, fk_compra, fk_pago)
        VALUES (v_millas_ganadas, CURRENT_DATE, NEW.fk_compra, NULL); -- FK_PAGO se llenaría al pagar, aquí lo simplificamos a la compra
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_otorgar_millas
AFTER INSERT ON detalle_reserva
FOR EACH ROW
EXECUTE FUNCTION fn_otorgar_millas_compra();

-- ==============================================================================
-- 3. STORED PROCEDURE MAESTRO: PROCESAR COMPRA (Checkout)
-- ==============================================================================
CREATE OR REPLACE PROCEDURE sp_procesar_compra(
    IN i_usuario_id INTEGER,
    IN i_json_viajeros JSON,
    IN i_json_items JSON,
    IN i_json_pago JSON,
    INOUT o_status INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL,
    INOUT o_compra_id INTEGER DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_total NUMERIC := 0;
    v_item RECORD;
    v_viajero_id INTEGER;
    v_viajero_json JSON;
    v_pue_tras_libre INTEGER;
    v_metodo_pago_id INTEGER;
    v_pago_id INTEGER;
    v_tasa_id INTEGER;
    v_monto_inicial NUMERIC;
    v_monto_restante NUMERIC;
    v_cuota_monto NUMERIC;
    v_costo_unitario NUMERIC;
    v_es_financiado BOOLEAN;
    v_cant_viajeros INTEGER;
    
    -- Variables nuevas para depuración paquete
    v_paq_tras RECORD;
BEGIN
    -- A. Obtener Tasa
    SELECT tas_cam_codigo INTO v_tasa_id FROM tasa_de_cambio WHERE tas_cam_moneda = 'USD' AND tas_cam_fecha_hora_fin IS NULL LIMIT 1;
    IF v_tasa_id IS NULL THEN 
        -- Fallback si no hay tasa, usar la ultima registrada o crear una dummy para no romper pruebas
        SELECT tas_cam_codigo INTO v_tasa_id FROM tasa_de_cambio ORDER BY tas_cam_codigo DESC LIMIT 1;
        IF v_tasa_id IS NULL THEN o_status:=500; o_mensaje:='Error Crítico: No hay tasa de cambio configurada.'; RETURN; END IF;
    END IF;

    -- B. Insertar Compra (Header)
    INSERT INTO compra (com_monto_total, com_monto_subtotal, com_fecha, fk_usuario, fk_plan_financiamiento)
    VALUES (0, 0, CURRENT_DATE, i_usuario_id, NULL)
    RETURNING com_codigo INTO o_compra_id;

    -- C. Procesar Items por cada Viajero
    FOR v_viajero_json IN SELECT * FROM json_array_elements(i_json_viajeros) LOOP
        v_viajero_id := (v_viajero_json::text)::integer;

        FOR v_item IN SELECT * FROM json_to_recordset(i_json_items) AS x(tipo text, id int) LOOP
            
            -- === CASO 1: SERVICIO ===
            IF v_item.tipo = 'servicio' THEN
                SELECT ser_costo INTO v_costo_unitario FROM servicio WHERE ser_codigo = v_item.id;
                
                INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado)
                VALUES ((SELECT COALESCE(MAX(det_res_codigo),0)+1 FROM detalle_reserva), CURRENT_DATE, CURRENT_TIME, COALESCE(v_costo_unitario, 0), 0, v_viajero_id, 1, o_compra_id, v_item.id, 'Confirmada');
                
                v_total := v_total + COALESCE(v_costo_unitario, 0);

            -- === CASO 2: TRASLADO INDIVIDUAL ===
            ELSIF v_item.tipo = 'traslado' THEN
                SELECT pt.pue_tras_codigo, r.rut_costo INTO v_pue_tras_libre, v_costo_unitario
                FROM pue_tras pt
                JOIN traslado t ON pt.fk_tras_codigo = t.tras_codigo
                JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
                WHERE t.tras_codigo = v_item.id AND pt.disponible = TRUE
                LIMIT 1;

                IF v_pue_tras_libre IS NULL THEN RAISE EXCEPTION 'Sin asientos para traslado %', v_item.id; END IF;

                INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_pue_tras, det_res_estado)
                VALUES ((SELECT COALESCE(MAX(det_res_codigo),0)+1 FROM detalle_reserva), CURRENT_DATE, CURRENT_TIME, v_costo_unitario, 0, v_viajero_id, 1, o_compra_id, v_pue_tras_libre, 'Confirmada');
                
                v_total := v_total + v_costo_unitario;

            -- === CASO 3: PAQUETE (Lógica Reforzada) ===
            ELSIF v_item.tipo = 'paquete' THEN
                -- 1. Insertar el PAQUETE (Esto es lo vital para que aparezca el ticket maestro)
                SELECT paq_tur_monto_total INTO v_costo_unitario FROM paquete_turistico WHERE paq_tur_codigo = v_item.id;
                
                INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_paquete_turistico, det_res_estado)
                VALUES ((SELECT COALESCE(MAX(det_res_codigo),0)+1 FROM detalle_reserva), CURRENT_DATE, CURRENT_TIME, COALESCE(v_costo_unitario, 0), 0, v_viajero_id, 1, o_compra_id, v_item.id, 'Confirmada');
                
                v_total := v_total + COALESCE(v_costo_unitario, 0);

                -- 2. Intentar reservar asientos internos (Best Effort)
                -- Iteramos sobre los traslados definidos en el paquete
                FOR v_paq_tras IN SELECT fk_tras_codigo FROM paq_tras WHERE fk_paq_tur_codigo = v_item.id LOOP
                    v_pue_tras_libre := NULL;
                    
                    -- Buscar asiento
                    SELECT pt.pue_tras_codigo INTO v_pue_tras_libre
                    FROM pue_tras pt
                    WHERE pt.fk_tras_codigo = v_paq_tras.fk_tras_codigo AND pt.disponible = TRUE
                    LIMIT 1;

                    -- Si hay asiento, lo reservamos asociado al paquete
                    IF v_pue_tras_libre IS NOT NULL THEN
                        INSERT INTO detalle_reserva (
                            det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, 
                            det_res_monto_total, det_res_sub_total, 
                            fk_viajero_codigo, fk_viajero_numero, fk_compra, 
                            fk_pue_tras, fk_paquete_turistico, det_res_estado -- Notar: fk_paquete_turistico NO es null aquí para vincularlo
                        ) VALUES (
                            (SELECT COALESCE(MAX(det_res_codigo),0)+1 FROM detalle_reserva), 
                            CURRENT_DATE, CURRENT_TIME, 0, 0, 
                            v_viajero_id, 1, o_compra_id, 
                            v_pue_tras_libre, v_item.id, 'Confirmada'
                        );
                    END IF;
                    -- Si no hay asiento, NO fallamos la transacción, solo omitimos el asiento específico.
                    -- El usuario tendrá el ticket del paquete general.
                END LOOP;
                
                -- 3. Los servicios internos del paquete no requieren reserva individual en detalle_reserva 
                -- ya que sp_obtener_tickets_cliente los expande dinámicamente.
            END IF;

        END LOOP;
    END LOOP;

    -- D. Actualizar Totales y Pago
    UPDATE compra SET com_monto_total = v_total, com_monto_subtotal = v_total WHERE com_codigo = o_compra_id;
    
    INSERT INTO metodo_pago (met_pag_descripcion) VALUES ('Pago Compra #' || o_compra_id) RETURNING met_pag_codigo INTO v_metodo_pago_id;
    INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago)
    VALUES (v_total, NOW(), 'USD', o_compra_id, v_tasa_id, v_metodo_pago_id);

    o_status := 200; o_mensaje := 'Compra procesada exitosamente.';

EXCEPTION WHEN OTHERS THEN
    o_status := 500; o_mensaje := 'Error SP: ' || SQLERRM;
END;
$$;

-- ==============================================================================
-- 4. SP PARA OBTENER TICKETS (MIS SERVICIOS)
-- ==============================================================================
CREATE OR REPLACE FUNCTION sp_obtener_tickets_cliente(_usu_id INTEGER)
RETURNS TABLE (
    ticket_id VARCHAR,
    tipo VARCHAR,
    titulo VARCHAR,
    subtitulo VARCHAR,
    detalle_extra VARCHAR,
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    ubicacion VARCHAR,
    viajero_nombre VARCHAR,
    qr_data VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM (
        -- =========================================================
        -- 1. TRASLADOS INDIVIDUALES
        -- =========================================================
        SELECT 
            ('TRS-' || dr.det_res_codigo)::VARCHAR,
            'Traslado'::VARCHAR,
            (orig.ter_nombre || ' ➝ ' || dest.ter_nombre)::VARCHAR,
            (mt.med_tra_descripcion || ' (' || mt.med_tra_tipo || ')')::VARCHAR,
            ('Asiento: ' || p.pue_descripcion)::VARCHAR,
            t.tras_fecha_hora_inicio,
            t.tras_fecha_hora_fin,
            ld.lug_nombre::VARCHAR,
            (v.via_prim_nombre || ' ' || v.via_prim_apellido)::VARCHAR,
            ('TICKET:TRS:' || dr.det_res_codigo || ':' || COALESCE(doc.doc_numero_documento, 'NO-DOC'))::VARCHAR
        FROM detalle_reserva dr
        JOIN compra c ON dr.fk_compra = c.com_codigo
        JOIN pue_tras pt ON dr.fk_pue_tras = pt.pue_tras_codigo
        JOIN puesto p ON pt.fk_pue_codigo = p.pue_codigo AND pt.fk_med_tra_codigo = p.fk_med_tra_codigo
        JOIN traslado t ON pt.fk_tras_codigo = t.tras_codigo
        JOIN medio_transporte mt ON t.fk_med_tra_codigo = mt.med_tra_codigo
        JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
        JOIN terminal orig ON r.fk_terminal_origen = orig.ter_codigo
        JOIN terminal dest ON r.fk_terminal_destino = dest.ter_codigo
        JOIN lugar ld ON dest.fk_lugar = ld.lug_codigo
        JOIN viajero v ON dr.fk_viajero_codigo = v.via_codigo
        LEFT JOIN LATERAL (SELECT d.doc_numero_documento FROM documento d WHERE d.fk_via_codigo = v.via_codigo ORDER BY d.doc_fecha_vencimiento DESC LIMIT 1) doc ON TRUE
        WHERE c.fk_usuario = _usu_id 
          AND dr.det_res_estado = 'Confirmada'
          AND v.fk_usu_codigo = _usu_id -- <--- FILTRO DE PROPIEDAD DEL VIAJERO
          AND NOT EXISTS (SELECT 1 FROM pago p JOIN reembolso r ON p.pag_codigo = r.fk_pago WHERE p.fk_compra = c.com_codigo)

        UNION ALL

        -- =========================================================
        -- 2. SERVICIOS INDIVIDUALES
        -- =========================================================
        SELECT 
            ('SRV-' || dr.det_res_codigo)::VARCHAR,
            'Servicio'::VARCHAR,
            s.ser_nombre::VARCHAR,
            p.prov_nombre::VARCHAR,
            ('Tipo: ' || s.ser_tipo)::VARCHAR,
            s.ser_fecha_hora_inicio,
            s.ser_fecha_hora_fin,
            l.lug_nombre::VARCHAR,
            (v.via_prim_nombre || ' ' || v.via_prim_apellido)::VARCHAR,
            ('TICKET:SRV:' || dr.det_res_codigo || ':' || s.ser_codigo)::VARCHAR
        FROM detalle_reserva dr
        JOIN compra c ON dr.fk_compra = c.com_codigo
        JOIN servicio s ON dr.fk_servicio = s.ser_codigo
        JOIN proveedor p ON s.fk_prov_codigo = p.prov_codigo
        JOIN lugar l ON p.fk_lugar = l.lug_codigo
        JOIN viajero v ON dr.fk_viajero_codigo = v.via_codigo
        WHERE c.fk_usuario = _usu_id 
          AND dr.det_res_estado = 'Confirmada'
          AND v.fk_usu_codigo = _usu_id -- <--- FILTRO DE PROPIEDAD DEL VIAJERO
          AND NOT EXISTS (SELECT 1 FROM pago p JOIN reembolso r ON p.pag_codigo = r.fk_pago WHERE p.fk_compra = c.com_codigo)

        UNION ALL

        -- =========================================================
        -- 3. PAQUETES: TRASLADOS INCLUIDOS
        -- =========================================================
        SELECT 
            ('PAQ-TRS-' || dr.det_res_codigo || '-' || t.tras_codigo)::VARCHAR,
            'Traslado (Paquete)'::VARCHAR,
            (orig.ter_nombre || ' ➝ ' || dest.ter_nombre)::VARCHAR,
            (pq.paq_tur_nombre)::VARCHAR,
            ('Incluido en Paquete')::VARCHAR,
            t.tras_fecha_hora_inicio,
            t.tras_fecha_hora_fin,
            ld.lug_nombre::VARCHAR,
            (v.via_prim_nombre || ' ' || v.via_prim_apellido)::VARCHAR,
            ('TICKET:PAQ:' || dr.det_res_codigo || ':' || pq.paq_tur_codigo)::VARCHAR
        FROM detalle_reserva dr
        JOIN compra c ON dr.fk_compra = c.com_codigo
        JOIN paquete_turistico pq ON dr.fk_paquete_turistico = pq.paq_tur_codigo
        JOIN paq_tras pt ON pq.paq_tur_codigo = pt.fk_paq_tur_codigo
        JOIN traslado t ON pt.fk_tras_codigo = t.tras_codigo
        JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
        JOIN terminal orig ON r.fk_terminal_origen = orig.ter_codigo
        JOIN terminal dest ON r.fk_terminal_destino = dest.ter_codigo
        JOIN lugar ld ON dest.fk_lugar = ld.lug_codigo
        JOIN viajero v ON dr.fk_viajero_codigo = v.via_codigo
        WHERE c.fk_usuario = _usu_id 
          AND dr.det_res_estado = 'Confirmada'
          AND v.fk_usu_codigo = _usu_id -- <--- FILTRO DE PROPIEDAD DEL VIAJERO
          AND NOT EXISTS (SELECT 1 FROM pago p JOIN reembolso r ON p.pag_codigo = r.fk_pago WHERE p.fk_compra = c.com_codigo)

        UNION ALL

        -- =========================================================
        -- 4. PAQUETES: SERVICIOS INCLUIDOS
        -- =========================================================
        SELECT 
            ('PAQ-SRV-' || dr.det_res_codigo || '-' || s.ser_codigo)::VARCHAR,
            'Servicio (Paquete)'::VARCHAR,
            s.ser_nombre::VARCHAR,
            (pq.paq_tur_nombre)::VARCHAR,
            ('Cantidad: ' || ps.cantidad)::VARCHAR,
            s.ser_fecha_hora_inicio,
            s.ser_fecha_hora_fin,
            l.lug_nombre::VARCHAR,
            (v.via_prim_nombre || ' ' || v.via_prim_apellido)::VARCHAR,
            ('TICKET:PAQ-SRV:' || dr.det_res_codigo || ':' || s.ser_codigo)::VARCHAR
        FROM detalle_reserva dr
        JOIN compra c ON dr.fk_compra = c.com_codigo
        JOIN paquete_turistico pq ON dr.fk_paquete_turistico = pq.paq_tur_codigo
        JOIN paq_ser ps ON pq.paq_tur_codigo = ps.fk_paq_tur_codigo
        JOIN servicio s ON ps.fk_ser_codigo = s.ser_codigo
        JOIN proveedor p ON s.fk_prov_codigo = p.prov_codigo
        JOIN lugar l ON p.fk_lugar = l.lug_codigo
        JOIN viajero v ON dr.fk_viajero_codigo = v.via_codigo
        WHERE c.fk_usuario = _usu_id 
          AND dr.det_res_estado = 'Confirmada'
          AND v.fk_usu_codigo = _usu_id -- <--- FILTRO DE PROPIEDAD DEL VIAJERO
          AND NOT EXISTS (SELECT 1 FROM pago p JOIN reembolso r ON p.pag_codigo = r.fk_pago WHERE p.fk_compra = c.com_codigo)

        UNION ALL

        -- =========================================================
        -- 5. PAQUETES: HOTELES INCLUIDOS
        -- =========================================================
        SELECT 
            ('PAQ-HTL-' || dr.det_res_codigo || '-' || rh.fk_habitacion)::VARCHAR,
            'Alojamiento (Paquete)'::VARCHAR,
            hot.hot_nombre::VARCHAR,
            (pq.paq_tur_nombre)::VARCHAR,
            ('Habitación: ' || hab.hab_descripcion)::VARCHAR,
            rh.res_hab_fecha_hora_inicio,
            rh.res_hab_fecha_hora_fin,
            l.lug_nombre::VARCHAR,
            (v.via_prim_nombre || ' ' || v.via_prim_apellido)::VARCHAR,
            ('TICKET:PAQ-HTL:' || dr.det_res_codigo || ':' || hot.hot_codigo)::VARCHAR
        FROM detalle_reserva dr
        JOIN compra c ON dr.fk_compra = c.com_codigo
        JOIN paquete_turistico pq ON dr.fk_paquete_turistico = pq.paq_tur_codigo
        JOIN reserva_de_habitacion rh ON rh.fk_paquete_turistico = pq.paq_tur_codigo AND rh.fk_detalle_reserva IS NULL
        JOIN habitacion hab ON rh.fk_habitacion = hab.hab_num_hab
        JOIN hotel hot ON hab.fk_hotel = hot.hot_codigo
        JOIN lugar l ON hot.fk_lugar = l.lug_codigo
        JOIN viajero v ON dr.fk_viajero_codigo = v.via_codigo
        WHERE c.fk_usuario = _usu_id 
          AND dr.det_res_estado = 'Confirmada'
          AND v.fk_usu_codigo = _usu_id -- <--- FILTRO DE PROPIEDAD DEL VIAJERO
          AND NOT EXISTS (SELECT 1 FROM pago p JOIN reembolso r ON p.pag_codigo = r.fk_pago WHERE p.fk_compra = c.com_codigo)

        UNION ALL

        -- =========================================================
        -- 6. TICKET MAESTRO DE PAQUETE
        -- =========================================================
        SELECT 
            ('PAQ-MAIN-' || dr.det_res_codigo)::VARCHAR,
            'Paquete Turístico'::VARCHAR,
            pq.paq_tur_nombre::VARCHAR,
            'Resumen del Paquete'::VARCHAR,
            'Ver detalles completos en agencia'::VARCHAR,
            c.com_fecha::TIMESTAMP, 
            NULL::TIMESTAMP,
            'Multi-Destino'::VARCHAR,
            (v.via_prim_nombre || ' ' || v.via_prim_apellido)::VARCHAR,
            ('TICKET:MASTER:' || dr.det_res_codigo || ':' || pq.paq_tur_codigo)::VARCHAR
        FROM detalle_reserva dr
        JOIN compra c ON dr.fk_compra = c.com_codigo
        JOIN paquete_turistico pq ON dr.fk_paquete_turistico = pq.paq_tur_codigo
        JOIN viajero v ON dr.fk_viajero_codigo = v.via_codigo
        WHERE c.fk_usuario = _usu_id 
          AND dr.det_res_estado = 'Confirmada'
          AND v.fk_usu_codigo = _usu_id -- <--- FILTRO DE PROPIEDAD DEL VIAJERO
          AND NOT EXISTS (SELECT 1 FROM pago p JOIN reembolso r ON p.pag_codigo = r.fk_pago WHERE p.fk_compra = c.com_codigo)

    ) AS tickets_unificados
    ORDER BY fecha_inicio DESC NULLS LAST;
END;
$$ LANGUAGE plpgsql;



BEGIN;

-- 1. OBTENER CUOTAS PENDIENTES (Lógica Financiera Inteligente)
-- Devuelve las cuotas y calcula si están "Pagadas" o "Pendientes" basándose en el saldo total abonado.
CREATE OR REPLACE FUNCTION sp_obtener_cuotas_cliente(_usu_id INTEGER)
RETURNS TABLE (
    cuota_id INTEGER,
    compra_id INTEGER,
    concepto VARCHAR,
    fecha_vencimiento DATE,
    monto NUMERIC,
    estado VARCHAR -- 'Pagada', 'Pendiente', 'Vencida'
) AS $$
BEGIN
    RETURN QUERY
    WITH pagos_por_compra AS (
        SELECT fk_compra, SUM(pag_monto) as total_pagado
        FROM pago
        GROUP BY fk_compra
    ),
    cuotas_calculadas AS (
        SELECT 
            c.cuo_codigo,
            co.com_codigo,
            ('Cuota #' || ROW_NUMBER() OVER (PARTITION BY co.com_codigo ORDER BY c.cuo_fecha_tope))::VARCHAR as nro_cuota,
            c.cuo_fecha_tope,
            c.cuo_monto,
            pf.plan_fin_inicial,
            -- Calculamos el acumulado que se DEBERÍA haber pagado para cubrir hasta esta cuota
            pf.plan_fin_inicial + SUM(c.cuo_monto) OVER (PARTITION BY co.com_codigo ORDER BY c.cuo_fecha_tope) as meta_acumulada,
            COALESCE(ppc.total_pagado, 0) as pagado_real
        FROM cuota c
        JOIN plan_financiamiento pf ON c.fk_plan_financiamiento = pf.plan_fin_codigo
        JOIN compra co ON pf.fk_compra = co.com_codigo
        LEFT JOIN pagos_por_compra ppc ON co.com_codigo = ppc.fk_compra
        WHERE co.fk_usuario = _usu_id
    )
    SELECT 
        cc.cuo_codigo,
        cc.com_codigo,
        cc.nro_cuota,
        cc.cuo_fecha_tope,
        cc.cuo_monto,
        CASE 
            WHEN cc.pagado_real >= (cc.meta_acumulada - 0.01) THEN 'Pagada'::VARCHAR
            WHEN cc.cuo_fecha_tope < CURRENT_DATE THEN 'Vencida'::VARCHAR
            ELSE 'Pendiente'::VARCHAR
        END as estado
    FROM cuotas_calculadas cc
    ORDER BY cc.cuo_fecha_tope ASC;
END;
$$ LANGUAGE plpgsql;

-- 2. OBTENER HISTORIAL DE PAGOS
CREATE OR REPLACE FUNCTION sp_obtener_historial_pagos(_usu_id INTEGER)
RETURNS TABLE (
    pago_id INTEGER,
    fecha TIMESTAMP,
    monto NUMERIC,
    metodo VARCHAR,
    referencia VARCHAR,
    compra_id INTEGER,
    estado_reembolso VARCHAR -- 'N/A', 'Solicitado', 'Reembolsado'
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.pag_codigo,
        p.pag_fecha_hora,
        p.pag_monto,
        CASE 
            WHEN z.met_pago_codigo IS NOT NULL THEN 'Zelle'
            WHEN tc.met_pago_codigo IS NOT NULL THEN 'Tarjeta Crédito'
            ELSE 'Otro'
        END::VARCHAR,
        COALESCE(z.zel_codigo_transaccion, tc.tar_cre_numero, 'N/A')::VARCHAR,
        p.fk_compra,
        CASE 
            WHEN r.rem_codigo IS NOT NULL THEN 'Reembolsado'
            -- Aquí podrías agregar lógica si tienes una tabla de 'solicitud_reembolso' intermedia
            ELSE 'Disponible' 
        END::VARCHAR
    FROM pago p
    JOIN compra c ON p.fk_compra = c.com_codigo
    JOIN metodo_pago mp ON p.fk_metodo_pago = mp.met_pag_codigo
    LEFT JOIN zelle z ON mp.met_pag_codigo = z.met_pago_codigo
    LEFT JOIN tarjeta_credito tc ON mp.met_pag_codigo = tc.met_pago_codigo
    LEFT JOIN reembolso r ON p.pag_codigo = r.fk_pago
    WHERE c.fk_usuario = _usu_id
    ORDER BY p.pag_fecha_hora DESC;
END;
$$ LANGUAGE plpgsql;

-- 3. REGISTRAR PAGO DE CUOTA
CREATE OR REPLACE PROCEDURE sp_pagar_cuota(
    IN i_cuota_id INTEGER,
    IN i_json_pago JSON,
    INOUT o_status INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_compra_id INTEGER;
    v_monto_cuota NUMERIC;
    v_tasa_id INTEGER;
    v_metodo_pago_id INTEGER;
BEGIN
    -- 1. Obtener datos de la cuota
    SELECT pf.fk_compra, c.cuo_monto 
    INTO v_compra_id, v_monto_cuota
    FROM cuota c
    JOIN plan_financiamiento pf ON c.fk_plan_financiamiento = pf.plan_fin_codigo
    WHERE c.cuo_codigo = i_cuota_id;

    IF v_compra_id IS NULL THEN o_status:=404; o_mensaje:='Cuota no encontrada'; RETURN; END IF;

    -- 2. Tasa de cambio (Fallback safety)
    SELECT tas_cam_codigo INTO v_tasa_id FROM tasa_de_cambio WHERE tas_cam_moneda = 'USD' LIMIT 1;

    -- 3. Registrar Método de Pago (Opción B Herencia)
    INSERT INTO metodo_pago (met_pag_descripcion) VALUES ('Pago Cuota #' || i_cuota_id) RETURNING met_pag_codigo INTO v_metodo_pago_id;

    IF (i_json_pago->>'metodo') = 'zelle' THEN
        INSERT INTO zelle (met_pago_codigo, zel_titular_cuenta, zel_correo_electronico, zel_codigo_transaccion)
        VALUES (v_metodo_pago_id, i_json_pago->'datos'->>'titular', i_json_pago->'datos'->>'correo', i_json_pago->'datos'->>'referencia');
    ELSIF (i_json_pago->>'metodo') = 'tarjeta' THEN
        INSERT INTO tarjeta_credito (met_pago_codigo, tar_cre_numero, tar_cre_cvv, tar_cre_fecha_vencimiento, tar_cre_banco_emisor, tar_cre_nombre_titular)
        VALUES (v_metodo_pago_id, i_json_pago->'datos'->>'numero', i_json_pago->'datos'->>'cvv', (i_json_pago->'datos'->>'vencimiento')::DATE, 'Banco X', i_json_pago->'datos'->>'titular');
    END IF;

    -- 4. Registrar el Pago vinculado a la COMPRA (Esto "saldará" la cuota en el cálculo)
    INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago)
    VALUES (v_monto_cuota, NOW(), 'USD', v_compra_id, v_tasa_id, v_metodo_pago_id);

    o_status := 200; o_mensaje := 'Pago de cuota registrado exitosamente.';

EXCEPTION WHEN OTHERS THEN
    o_status := 500; o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;

-- 4. SOLICITAR REEMBOLSO
CREATE OR REPLACE PROCEDURE sp_solicitar_reembolso(
    IN i_pago_id INTEGER,
    INOUT o_status INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_monto_original NUMERIC;
    v_fecha_pago TIMESTAMP;
BEGIN
    SELECT pag_monto, pag_fecha_hora INTO v_monto_original, v_fecha_pago 
    FROM pago WHERE pag_codigo = i_pago_id;

    IF v_monto_original IS NULL THEN o_status:=404; o_mensaje:='Pago no existe'; RETURN; END IF;

    -- Validación simple: No reembolsar si ya existe reembolso
    IF EXISTS (SELECT 1 FROM reembolso WHERE fk_pago = i_pago_id) THEN
        o_status:=400; o_mensaje:='Este pago ya fue reembolsado.'; RETURN;
    END IF;

    -- Insertar Reembolso (Reteniendo 10% por gastos administrativos, ejemplo de regla)
    INSERT INTO reembolso (rem_monto_reembolsado, rem_monto_retenido, rem_fecha, fk_pago)
    VALUES (v_monto_original * 0.90, v_monto_original * 0.10, CURRENT_DATE, i_pago_id);

    o_status := 200; o_mensaje := 'Reembolso procesado (Se aplicó retención del 10%).';

EXCEPTION WHEN OTHERS THEN
    o_status := 500; o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;

COMMIT;

COMMIT;


