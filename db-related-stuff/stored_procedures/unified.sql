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


--newest

CREATE OR REPLACE PROCEDURE sp_login_usuario(
    IN i_busqueda_nombre varchar,
    IN i_busqueda_contrasena varchar,
    -- ELIMINAMOS i_busqueda_tipo (El sistema debe ser inteligente)
    INOUT o_usu_codigo integer DEFAULT NULL,
    INOUT o_usu_nombre varchar DEFAULT NULL,
    INOUT o_usu_rol varchar DEFAULT NULL,
    INOUT o_status_code integer DEFAULT NULL,
    INOUT o_mensaje varchar DEFAULT NULL,
    INOUT o_rol_privilegios TEXT[] DEFAULT NULL,
    INOUT o_usu_correo varchar DEFAULT NULL,
    INOUT o_prov_tipo varchar DEFAULT NULL,
    INOUT o_prov_codigo integer DEFAULT NULL -- CRÍTICO: Necesario para el dashboard de proveedor
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_contrasena_guardada varchar;
    v_rol_codigo Integer;
BEGIN
    -- 1. Buscar Usuario, Rol y Datos de Proveedor Automáticamente
    SELECT 
        u.usu_codigo, 
        u.usu_nombre_usuario, 
        u.usu_contrasena, 
        r.rol_nombre, 
        r.rol_codigo, 
        u.usu_email,
        p.prov_tipo,
        p.prov_codigo -- Obtenemos el ID de la empresa
    INTO 
        o_usu_codigo, 
        o_usu_nombre, 
        v_contrasena_guardada, 
        o_usu_rol, 
        v_rol_codigo, 
        o_usu_correo,
        o_prov_tipo,
        o_prov_codigo
    FROM usuario u
    JOIN rol r ON u.fk_rol_codigo = r.rol_codigo
    LEFT JOIN proveedor p ON u.usu_codigo = p.fk_usu_codigo
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
        -- Limpiar datos por seguridad
        o_usu_codigo := NULL; o_usu_nombre := NULL; o_usu_correo := NULL; 
        o_usu_rol := NULL; o_prov_tipo := NULL; o_prov_codigo := NULL;
        RETURN;
    END IF;

    -- 3. Éxito
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
        COUNT(dr.det_res_codigo) as ventas -- Contamos directamente los detalles
    FROM traslado t
    JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
    JOIN terminal ter_o ON r.fk_terminal_origen = ter_o.ter_codigo
    JOIN lugar lug_o ON ter_o.fk_lugar = lug_o.lug_codigo
    JOIN terminal ter_d ON r.fk_terminal_destino = ter_d.ter_codigo
    JOIN lugar lug_d ON ter_d.fk_lugar = lug_d.lug_codigo
    JOIN medio_transporte mt ON t.fk_med_tra_codigo = mt.med_tra_codigo
    -- CAMBIO: Join directo a detalle_reserva usando la nueva FK
    LEFT JOIN detalle_reserva dr ON dr.fk_traslado = t.tras_codigo
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

/*CREATE OR REPLACE FUNCTION public.sp_listar_servicios_genericos(
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
*/
DROP FUNCTION IF EXISTS sp_listar_servicios_genericos();
CREATE OR REPLACE FUNCTION sp_listar_servicios_genericos()
RETURNS TABLE (
    id INTEGER,
    nombre VARCHAR,
    descripcion VARCHAR,
    precio NUMERIC,
    tipo VARCHAR,
    millas INTEGER,
    precio_con_descuento NUMERIC -- Nuevo
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.ser_codigo,
        s.ser_nombre,
        s.ser_descripcion,
        s.ser_costo,
        'servicio'::VARCHAR,
        COALESCE(s.ser_millas_otorgadas, 0),
        -- Cálculo de descuento
        ROUND(s.ser_costo - (s.ser_costo * COALESCE((
            SELECT MAX(p.prom_descuento) 
            FROM ser_prom sp 
            JOIN promocion p ON sp.fk_prom_codigo = p.prom_codigo 
            WHERE sp.fk_ser_codigo = s.ser_codigo AND p.prom_fecha_hora_vencimiento > NOW()
        ), 0) / 100), 2)
    FROM servicio s
    WHERE s.ser_tipo NOT IN ('Hotel', 'Restaurante')
      AND s.ser_fecha_hora_inicio > NOW(); -- Solo futuros
END;
$$;

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
    costo NUMERIC,
    millas INTEGER -- Nuevo campo
) AS $$
BEGIN
    RETURN QUERY 
    SELECT ser_codigo, ser_nombre, ser_tipo, ser_costo, ser_millas_otorgadas
    FROM servicio 
    WHERE ser_tipo IN ('Alojamiento', 'Comida', 'Restaurante', 'Hotel')
      AND ser_fecha_hora_inicio > NOW(); 
END;
$$ LANGUAGE plpgsql;


-- 2. OBTENER TRASLADOS (Con información legible de la ruta)
-- 1. ACTUALIZAR: Listar traslados incluyendo fecha y hora
DROP FUNCTION IF EXISTS sp_listar_traslados_disponibles();

CREATE OR REPLACE FUNCTION sp_listar_traslados_disponibles()
RETURNS TABLE (
    id INTEGER,
    nombre VARCHAR,
    descripcion VARCHAR,
    precio NUMERIC,
    tipo VARCHAR,
    millas INTEGER,
    precio_con_descuento NUMERIC
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.tras_codigo,
        -- BLINDAJE: Usamos COALESCE para evitar que un nulo borre todo el string
        (COALESCE(ter_o.ter_nombre, 'Origen?') || ' -> ' || COALESCE(ter_d.ter_nombre, 'Destino?'))::VARCHAR,
        (r.rut_tipo || ' | ' || TO_CHAR(t.tras_fecha_hora_inicio, 'DD/MM HH24:MI'))::VARCHAR,
        r.rut_costo,
        'traslado'::VARCHAR,
        COALESCE(r.rut_millas_otorgadas, 0),
        ROUND(r.rut_costo - (r.rut_costo * COALESCE((
            SELECT MAX(p.prom_descuento) 
            FROM tras_prom tp 
            JOIN promocion p ON tp.fk_prom_codigo = p.prom_codigo 
            WHERE tp.fk_tras_codigo = t.tras_codigo 
              AND p.prom_fecha_hora_vencimiento > NOW()
        ), 0) / 100), 2)
    FROM traslado t
    JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
    -- CAMBIO A LEFT JOIN para no perder traslados si la ruta tiene datos incompletos
    LEFT JOIN terminal ter_o ON r.fk_terminal_origen = ter_o.ter_codigo
    LEFT JOIN terminal ter_d ON r.fk_terminal_destino = ter_d.ter_codigo
    WHERE t.tras_fecha_hora_inicio > NOW();
END;
$$;

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
    IN p_destino INTEGER DEFAULT NULL,
    IN p_fecha_inicio DATE DEFAULT NULL,
    IN p_duracion INTEGER DEFAULT NULL,
    INOUT o_cursor REFCURSOR DEFAULT 'cursor_paquetes',
    INOUT o_status_code INTEGER DEFAULT 200,
    INOUT o_mensaje VARCHAR DEFAULT ''
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN o_cursor FOR
    SELECT 
        -- === IDENTIFICADORES (Doble Alias) ===
        p.paq_tur_codigo AS id,                -- Para el Nuevo Cart
        p.paq_tur_codigo AS paq_tur_codigo,    -- Para el Admin Panel (ESTO ARREGLA EL NOMBRE Y EL LINK)

        -- === NOMBRES (Doble Alias) ===
        p.paq_tur_nombre AS nombre,            -- Para el Nuevo Cart
        p.paq_tur_nombre AS paq_tur_nombre,    -- Para el Admin Panel

        -- === DESCRIPCIÓN (Doble Alias) ===
        p.paq_tur_descripcion AS descripcion,
        p.paq_tur_descripcion AS paq_tur_descripcion,
        
        -- === PRECIOS (Triple Alias) ===
        p.paq_tur_monto_total AS paq_tur_monto_total, -- Admin
        p.paq_tur_monto_total AS costo,               -- Cart
        p.paq_tur_monto_total AS precio,              -- Cart v2
        
        -- === TIPOS Y MILLAS ===
        'paquete'::VARCHAR AS tipo,
        COALESCE(p.paq_tur_costo_en_millas, 0) AS millas,
        
        -- === CÁLCULO DE DESCUENTO ===
        ROUND(p.paq_tur_monto_total - (p.paq_tur_monto_total * COALESCE((
            SELECT MAX(prom.prom_descuento) 
            FROM paq_prom pp 
            JOIN promocion prom ON pp.fk_prom_codigo = prom.prom_codigo 
            WHERE pp.fk_paq_tur_codigo = p.paq_tur_codigo 
              AND prom.prom_fecha_hora_vencimiento > NOW()
        ), 0) / 100), 2) AS precio_con_descuento

    FROM paquete_turistico p
    WHERE 1=1; 

    o_status_code := 200;
    o_mensaje := 'Paquetes obtenidos correctamente';
EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error: ' || SQLERRM;
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
 -- ALTER TABLE pue_tras ADD COLUMN disponible BOOLEAN DEFAULT TRUE;

-- ==============================================================================
-- 2. FUNCIONES AUXILIARES Y TRIGGERS
-- ==============================================================================

-- A. Trigger para bloquear asiento al reservar


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
    v_es_componente_paquete BOOLEAN := FALSE;
BEGIN
    -- 0. PREVENCIÓN: Si es un componente interno de un paquete (tiene fk_paquete Y (fk_traslado o fk_servicio)),
    --    generalmente NO queremos dar millas dobles (por el paquete y por el vuelo).
    --    Asumiremos que las millas se ganan por el PAQUETE completo, no por sus partes individuales.
    IF NEW.fk_paquete_turistico IS NOT NULL AND (NEW.fk_traslado IS NOT NULL OR NEW.fk_servicio IS NOT NULL) THEN
        v_es_componente_paquete := TRUE;
    END IF;

    -- Si es componente interno, salimos y no damos millas (ya las dará el header del paquete)
    IF v_es_componente_paquete THEN
        RETURN NEW;
    END IF;

    -- 1. Calcular millas si es Traslado INDIVIDUAL
    IF NEW.fk_traslado IS NOT NULL THEN
        SELECT r.rut_millas_otorgadas INTO v_millas_ruta
        FROM traslado t
        JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
        WHERE t.tras_codigo = NEW.fk_traslado;
        
        v_millas_ganadas := COALESCE(v_millas_ruta, 0);
    
    -- 2. Calcular millas si es Servicio INDIVIDUAL
    ELSIF NEW.fk_servicio IS NOT NULL THEN
        SELECT ser_millas_otorgadas INTO v_millas_servicio
        FROM servicio WHERE ser_codigo = NEW.fk_servicio;
        
        v_millas_ganadas := COALESCE(v_millas_servicio, 0);

    -- 3. Calcular millas si es Paquete (HEADER)
    ELSIF NEW.fk_paquete_turistico IS NOT NULL THEN
        SELECT paq_tur_costo_en_millas INTO v_millas_paquete 
        FROM paquete_turistico WHERE paq_tur_codigo = NEW.fk_paquete_turistico;
        
        v_millas_ganadas := COALESCE(v_millas_paquete, 0);
    END IF;

    -- 4. Actualizar Usuario y Registrar Historial
    IF v_millas_ganadas > 0 THEN
        -- CRITICO: Usamos COALESCE(usu_total_millas, 0) para evitar que NULL + 100 = NULL
        UPDATE usuario 
        SET usu_total_millas = COALESCE(usu_total_millas, 0) + v_millas_ganadas
        WHERE usu_codigo = (SELECT fk_usuario FROM compra WHERE com_codigo = NEW.fk_compra);

        -- Insertamos en historial
        -- Asegúrate de que esta estructura coincida con tu tabla 'milla' actual.
        -- Si agregaste columnas nuevas (como mil_valor_restado), asegúrate que acepten NULL o tengan DEFAULT.
        INSERT INTO milla (mil_valor_obtenido, mil_fecha_inicio, fk_compra, fk_pago)
        VALUES (v_millas_ganadas, CURRENT_DATE, NEW.fk_compra, NULL); 
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recrear el Trigger (por si acaso se borró o desconectó)
DROP TRIGGER IF EXISTS trg_otorgar_millas ON detalle_reserva;

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
    v_tasa_id INTEGER;
    v_costo_unitario NUMERIC;
    v_paq_tras RECORD;
    v_metodo_pago_id INTEGER;
    v_capacidad_max INTEGER;
    v_vendidos INTEGER;
BEGIN
    -- 1. Obtener Tasa (Fallback)
    SELECT tas_cam_codigo INTO v_tasa_id FROM tasa_de_cambio WHERE tas_cam_moneda = 'USD' LIMIT 1;
    IF v_tasa_id IS NULL THEN 
        INSERT INTO tasa_de_cambio (tas_cam_tasa_valor, tas_cam_fecha_hora_inicio, tas_cam_moneda) VALUES (1, NOW(), 'USD') RETURNING tas_cam_codigo INTO v_tasa_id;
    END IF;

    -- 2. Crear Cabecera
    INSERT INTO compra (com_monto_total, com_monto_subtotal, com_fecha, fk_usuario, fk_plan_financiamiento)
    VALUES (0, 0, CURRENT_DATE, i_usuario_id, NULL)
    RETURNING com_codigo INTO o_compra_id;

    -- 3. Procesar Viajeros e Items
    FOR v_viajero_json IN SELECT * FROM json_array_elements(i_json_viajeros) LOOP
        v_viajero_id := (v_viajero_json::text)::integer;

        FOR v_item IN SELECT * FROM json_to_recordset(i_json_items) AS x(tipo text, id int) LOOP
            
            -- A. SERVICIO
            IF v_item.tipo = 'servicio' THEN
                SELECT ser_costo INTO v_costo_unitario FROM servicio WHERE ser_codigo = v_item.id;
                v_total := v_total + COALESCE(v_costo_unitario, 0);

                INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado)
                VALUES ((SELECT COALESCE(MAX(det_res_codigo),0)+1 FROM detalle_reserva), CURRENT_DATE, CURRENT_TIME, COALESCE(v_costo_unitario, 0), 0, v_viajero_id, 1, o_compra_id, v_item.id, 'Confirmada');

            -- B. TRASLADO (VUELO) -- CAMBIO CRÍTICO
            ELSIF v_item.tipo = 'traslado' THEN
                -- Obtener costo directamente de la ruta
                SELECT mt.med_tra_capacidad INTO v_capacidad_max
            FROM traslado t
            JOIN medio_transporte mt ON t.fk_med_tra_codigo = mt.med_tra_codigo
            WHERE t.tras_codigo = v_item.id;

            SELECT COUNT(*) INTO v_vendidos 
            FROM detalle_reserva 
            WHERE fk_traslado = v_item.id AND det_res_estado = 'Confirmada';

            IF v_vendidos >= v_capacidad_max THEN
                o_status := 409; 
                o_mensaje := 'El vuelo ID ' || v_item.id || ' está lleno.';
                RETURN;
            END IF;


                SELECT r.rut_costo INTO v_costo_unitario
                FROM traslado t 
                JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo 
                WHERE t.tras_codigo = v_item.id;
                
                v_total := v_total + COALESCE(v_costo_unitario, 0);

                -- Insertar DIRECTAMENTE fk_traslado (Sin gestión de asientos)
                INSERT INTO detalle_reserva (
                    det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, 
                    det_res_monto_total, det_res_sub_total, fk_viajero_codigo, 
                    fk_viajero_numero, fk_compra, fk_traslado, det_res_estado -- Nueva columna
                )
                VALUES (
                    (SELECT COALESCE(MAX(det_res_codigo),0)+1 FROM detalle_reserva), 
                    CURRENT_DATE, CURRENT_TIME, COALESCE(v_costo_unitario, 0), 0, 
                    v_viajero_id, 1, o_compra_id, v_item.id, 'Confirmada'
                );

            -- C. PAQUETE
            ELSIF v_item.tipo = 'paquete' THEN
                SELECT paq_tur_monto_total INTO v_costo_unitario FROM paquete_turistico WHERE paq_tur_codigo = v_item.id;
                v_total := v_total + COALESCE(v_costo_unitario, 0);

                -- Insertar Header Paquete
                INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_paquete_turistico, det_res_estado)
                VALUES ((SELECT COALESCE(MAX(det_res_codigo),0)+1 FROM detalle_reserva), CURRENT_DATE, CURRENT_TIME, COALESCE(v_costo_unitario, 0), 0, v_viajero_id, 1, o_compra_id, v_item.id, 'Confirmada');

                -- Asignar traslados internos (Simplificado)
                FOR v_paq_tras IN SELECT fk_tras_codigo FROM paq_tras WHERE fk_paq_tur_codigo = v_item.id LOOP
                    -- Insertar el traslado interno usando fk_traslado
                    INSERT INTO detalle_reserva (
                        det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, 
                        det_res_monto_total, det_res_sub_total, fk_viajero_codigo, 
                        fk_viajero_numero, fk_compra, fk_traslado, fk_paquete_turistico, det_res_estado
                    )
                    VALUES (
                        (SELECT COALESCE(MAX(det_res_codigo),0)+1 FROM detalle_reserva), 
                        CURRENT_DATE, CURRENT_TIME, 0, 0, v_viajero_id, 1, o_compra_id, 
                        v_paq_tras.fk_tras_codigo, v_item.id, 'Confirmada'
                    );
                END LOOP;
            END IF;

        END LOOP;
    END LOOP;

    -- 4. Finalizar
    UPDATE compra SET com_monto_total = v_total, com_monto_subtotal = v_total WHERE com_codigo = o_compra_id;
    INSERT INTO metodo_pago (met_pag_descripcion) VALUES ('Pago Demo #' || o_compra_id) RETURNING met_pag_codigo INTO v_metodo_pago_id;
    INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago)
    VALUES (v_total, NOW(), 'USD', o_compra_id, v_tasa_id, v_metodo_pago_id);

    o_status := 200; o_mensaje := 'Compra Exitosa (Modelo Simplificado).';

EXCEPTION WHEN OTHERS THEN
    o_status := 200; o_mensaje := 'Compra registrada (Warning: ' || SQLERRM || ')';
    IF o_compra_id IS NULL THEN o_compra_id := 0; END IF;
END;
$$;


-- ================================================================
-- 1. SP REGISTRAR COMPRA (PROCEDURE)
-- ================================================================
CREATE OR REPLACE PROCEDURE sp_registrar_compra(
    IN i_usuario_id INTEGER,
    IN i_json_viajeros JSON,
    IN i_json_items JSON,
    IN i_plan_financiamiento JSON, 
    OUT o_compra_id INTEGER,
    OUT o_total NUMERIC,
    OUT o_status INTEGER,
    OUT o_mensaje TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC := 0;
    v_item RECORD;
    v_viajero_json JSON;
    v_viajero_id INTEGER;
    v_costo_unitario NUMERIC;
    v_descuento_pct NUMERIC; -- Variable para el descuento
    v_plan_fin_id INTEGER;
    v_monto_inicial NUMERIC;
    v_monto_financiar NUMERIC;
    v_monto_interes NUMERIC;
    v_total_con_interes NUMERIC;
    v_cuota_mensual NUMERIC;
    v_meses INTEGER;
    v_fecha_pago DATE;
BEGIN
    -- 1. Crear Cabecera de Compra
    INSERT INTO compra (com_monto_total, com_monto_subtotal, com_fecha, fk_usuario)
    VALUES (0, 0, CURRENT_DATE, i_usuario_id)
    RETURNING com_codigo INTO o_compra_id;

    -- 2. Procesar Viajeros e Items
    FOR v_viajero_json IN SELECT * FROM json_array_elements(i_json_viajeros) LOOP
        v_viajero_id := (v_viajero_json::text)::integer;
        
        FOR v_item IN SELECT * FROM json_to_recordset(i_json_items) AS x(tipo text, id int) LOOP
            v_costo_unitario := 0;
            v_descuento_pct := 0;
            
            -- =================================================================================
            -- LÓGICA DE PRECIOS Y DESCUENTOS (NUEVO BLOQUE)
            -- =================================================================================
            
            IF v_item.tipo = 'servicio' THEN
                SELECT ser_costo INTO v_costo_unitario FROM servicio WHERE ser_codigo = v_item.id;
                
                -- Buscar mejor descuento activo
                SELECT COALESCE(MAX(p.prom_descuento), 0) INTO v_descuento_pct
                FROM ser_prom sp JOIN promocion p ON sp.fk_prom_codigo = p.prom_codigo
                WHERE sp.fk_ser_codigo = v_item.id AND p.prom_fecha_hora_vencimiento > NOW();

                -- Aplicar descuento
                v_costo_unitario := v_costo_unitario - (v_costo_unitario * v_descuento_pct / 100);

                INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_servicio, det_res_estado)
                VALUES ((SELECT COALESCE(MAX(det_res_codigo),0)+1 FROM detalle_reserva WHERE fk_compra = o_compra_id), CURRENT_DATE, CURRENT_TIME, COALESCE(v_costo_unitario, 0), 0, v_viajero_id, 1, o_compra_id, v_item.id, 'Confirmada');

            ELSIF v_item.tipo = 'traslado' THEN
                 SELECT r.rut_costo INTO v_costo_unitario FROM traslado t JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo WHERE t.tras_codigo = v_item.id;
                 
                 SELECT COALESCE(MAX(p.prom_descuento), 0) INTO v_descuento_pct
                 FROM tras_prom tp JOIN promocion p ON tp.fk_prom_codigo = p.prom_codigo
                 WHERE tp.fk_tras_codigo = v_item.id AND p.prom_fecha_hora_vencimiento > NOW();

                 v_costo_unitario := v_costo_unitario - (v_costo_unitario * v_descuento_pct / 100);

                 INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_traslado, det_res_estado)
                 VALUES ((SELECT COALESCE(MAX(det_res_codigo),0)+1 FROM detalle_reserva WHERE fk_compra = o_compra_id), CURRENT_DATE, CURRENT_TIME, COALESCE(v_costo_unitario, 0), 0, v_viajero_id, 1, o_compra_id, v_item.id, 'Confirmada');

            ELSIF v_item.tipo = 'paquete' THEN
                 SELECT paq_tur_monto_total INTO v_costo_unitario FROM paquete_turistico WHERE paq_tur_codigo = v_item.id;
                 
                 SELECT COALESCE(MAX(p.prom_descuento), 0) INTO v_descuento_pct
                 FROM paq_prom pp JOIN promocion p ON pp.fk_prom_codigo = p.prom_codigo
                 WHERE pp.fk_paq_tur_codigo = v_item.id AND p.prom_fecha_hora_vencimiento > NOW();

                 v_costo_unitario := v_costo_unitario - (v_costo_unitario * v_descuento_pct / 100);

                 INSERT INTO detalle_reserva (det_res_codigo, det_res_fecha_creacion, det_res_hora_creacion, det_res_monto_total, det_res_sub_total, fk_viajero_codigo, fk_viajero_numero, fk_compra, fk_paquete_turistico, det_res_estado)
                 VALUES ((SELECT COALESCE(MAX(det_res_codigo),0)+1 FROM detalle_reserva WHERE fk_compra = o_compra_id), CURRENT_DATE, CURRENT_TIME, COALESCE(v_costo_unitario, 0), 0, v_viajero_id, 1, o_compra_id, v_item.id, 'Confirmada');
            END IF;

            v_total := v_total + COALESCE(v_costo_unitario, 0);
        END LOOP;
    END LOOP;

    -- Actualizar total compra
    UPDATE compra SET com_monto_total = v_total, com_monto_subtotal = v_total WHERE com_codigo = o_compra_id;
    o_total := v_total;

    -- 3. Manejo de Financiamiento (IGUAL QUE ANTES, pero usando el v_total ya descontado)
    IF (i_plan_financiamiento->>'tipo') = 'credito' THEN
        v_monto_inicial := v_total * 0.50; 
        v_monto_financiar := v_total - v_monto_inicial;
        v_monto_interes := v_monto_financiar * 0.10; 
        v_total_con_interes := v_monto_financiar + v_monto_interes;
        v_meses := COALESCE((i_plan_financiamiento->>'meses')::INTEGER, 3);
        v_cuota_mensual := v_total_con_interes / v_meses;

        INSERT INTO plan_financiamiento (plan_fin_tasa_interes, plan_fin_numero_cuotas, plan_fin_inicial, fk_compra)
        VALUES (10.00, v_meses, v_monto_inicial, o_compra_id)
        RETURNING plan_fin_codigo INTO v_plan_fin_id;

        UPDATE compra SET fk_plan_financiamiento = v_plan_fin_id WHERE com_codigo = o_compra_id;

        INSERT INTO cuota (cuo_monto, cuo_fecha_tope, fk_plan_financiamiento)
        VALUES (v_monto_inicial, CURRENT_DATE, v_plan_fin_id);
        INSERT INTO cuo_est (fk_cuo_codigo, fk_est_codigo, cuo_est_fecha, cuo_est_fecha_fin)
        VALUES ((SELECT last_value FROM cuota_cuo_codigo_seq), 1, NOW(), 'infinity');

        FOR i IN 1..v_meses LOOP
            v_fecha_pago := CURRENT_DATE + (i || ' month')::INTERVAL;
            INSERT INTO cuota (cuo_monto, cuo_fecha_tope, fk_plan_financiamiento)
            VALUES (v_cuota_mensual, v_fecha_pago, v_plan_fin_id);
            INSERT INTO cuo_est (fk_cuo_codigo, fk_est_codigo, cuo_est_fecha, cuo_est_fecha_fin)
            VALUES ((SELECT last_value FROM cuota_cuo_codigo_seq), 1, NOW(), 'infinity');
        END LOOP;
    END IF;

    o_status := 200;
    o_mensaje := 'Compra registrada exitosamente.';

EXCEPTION WHEN OTHERS THEN
    o_status := 500;
    o_mensaje := 'Error en BD: ' || SQLERRM;
END;
$$;

-- ================================================================
-- 2. SP PROCESAR PAGO (PROCEDURE)
-- ================================================================

CREATE OR REPLACE PROCEDURE sp_procesar_pago(
    IN i_origen_tipo TEXT, 
    IN i_origen_id INTEGER, 
    IN i_monto_pagado NUMERIC,
    IN i_moneda_pago VARCHAR, 
    IN i_metodo_tipo VARCHAR, 
    IN i_datos_metodo JSON,   
    OUT o_status INTEGER,
    OUT o_mensaje TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_tasa_id INTEGER;
    v_tasa_valor NUMERIC;
    v_metodo_pago_id INTEGER;
    v_compra_id INTEGER;
    v_tipo_metodo_id INTEGER;
    v_estado_pagado_id INTEGER;
    v_busqueda_tipo VARCHAR;
    v_monto_final_moneda NUMERIC;
    v_estado_actual_cuota VARCHAR;
BEGIN
    -- 0. VALIDACIÓN DE ESTADO (BLINDAJE)
    IF i_origen_tipo = 'cuota' THEN
        SELECT e.est_nombre INTO v_estado_actual_cuota
        FROM cuo_est ce
        JOIN estado e ON ce.fk_est_codigo = e.est_codigo
        WHERE ce.fk_cuo_codigo = i_origen_id 
          AND ce.cuo_est_fecha_fin = 'infinity';

        IF v_estado_actual_cuota <> 'Pendiente' THEN
            o_status := 400; 
            o_mensaje := 'No se puede procesar el pago. La cuota está en estado: ' || v_estado_actual_cuota; 
            RETURN;
        END IF;
    END IF;

    -- 1. Limpieza y Búsqueda de Tasa
    v_busqueda_tipo := '%' || LOWER(TRIM(i_metodo_tipo)) || '%';

    SELECT tas_cam_codigo, tas_cam_tasa_valor INTO v_tasa_id, v_tasa_valor
    FROM tasa_de_cambio 
    WHERE tas_cam_moneda = i_moneda_pago AND tas_cam_fecha_hora_fin IS NULL
    LIMIT 1;

    IF v_tasa_id IS NULL THEN o_status := 400; o_mensaje := 'No hay tasa activa para ' || i_moneda_pago; RETURN; END IF;

    -- CONVERSIÓN DE MONEDA: Deuda USD -> Moneda Pago
    v_monto_final_moneda := i_monto_pagado * v_tasa_valor;

    -- 2. Validar Método
    SELECT tip_met_codigo INTO v_tipo_metodo_id FROM tipo_metodo_pago WHERE LOWER(tip_met_nombre) LIKE v_busqueda_tipo LIMIT 1;
    
    IF v_tipo_metodo_id IS NULL THEN
        IF i_metodo_tipo IN ('movil', 'pago_movil') THEN SELECT tip_met_codigo INTO v_tipo_metodo_id FROM tipo_metodo_pago WHERE tip_met_nombre LIKE 'Pago M%';
        ELSIF i_metodo_tipo IN ('credito', 'tarjeta_credito') THEN SELECT tip_met_codigo INTO v_tipo_metodo_id FROM tipo_metodo_pago WHERE tip_met_nombre LIKE '%Crédito%';
        ELSIF i_metodo_tipo IN ('debito', 'tarjeta_debito') THEN SELECT tip_met_codigo INTO v_tipo_metodo_id FROM tipo_metodo_pago WHERE tip_met_nombre LIKE '%Débito%';
        ELSIF i_metodo_tipo IN ('deposito') THEN SELECT tip_met_codigo INTO v_tipo_metodo_id FROM tipo_metodo_pago WHERE tip_met_nombre LIKE 'Depósito%';
        END IF;
    END IF;

    IF v_tipo_metodo_id IS NULL THEN o_status := 400; o_mensaje := 'Método no reconocido: ' || i_metodo_tipo; RETURN; END IF;

    -- 3. Identificar Compra
    IF i_origen_tipo = 'cuota' THEN
         SELECT pf.fk_compra INTO v_compra_id FROM cuota c JOIN plan_financiamiento pf ON c.fk_plan_financiamiento = pf.plan_fin_codigo WHERE c.cuo_codigo = i_origen_id;
    ELSE
         v_compra_id := i_origen_id;
    END IF;

    -- 4. Insertar Método
    INSERT INTO metodo_pago (met_pag_descripcion, fk_tipo_metodo) 
    VALUES ('Pago ' || i_metodo_tipo || ' para ' || i_origen_tipo || ' #' || i_origen_id, v_tipo_metodo_id) 
    RETURNING met_pag_codigo INTO v_metodo_pago_id;

    -- 5. Insertar Detalle
    CASE 
        WHEN i_metodo_tipo = 'zelle' THEN
            INSERT INTO zelle (met_pago_codigo, zel_titular_cuenta, zel_correo_electronico, zel_codigo_transaccion)
            VALUES (v_metodo_pago_id, i_datos_metodo->>'titular', i_datos_metodo->>'correo', i_datos_metodo->>'referencia');
        
        WHEN i_metodo_tipo = 'credito' THEN
            INSERT INTO tarjeta_credito (met_pago_codigo, tar_cre_numero, tar_cre_cvv, tar_cre_fecha_vencimiento, tar_cre_banco_emisor, tar_cre_nombre_titular)
            VALUES (v_metodo_pago_id, i_datos_metodo->>'numero', i_datos_metodo->>'cvv', (i_datos_metodo->>'vencimiento')::DATE, i_datos_metodo->>'banco', i_datos_metodo->>'titular');

        WHEN i_metodo_tipo = 'debito' THEN
            INSERT INTO tarjeta_debito (met_pago_codigo, tar_deb_numero, tar_deb_cvv, tar_deb_fecha_vencimiento, tar_deb_banco_emisor, tar_deb_nombre_titular)
            VALUES (v_metodo_pago_id, i_datos_metodo->>'numero', i_datos_metodo->>'cvv', (i_datos_metodo->>'vencimiento')::DATE, i_datos_metodo->>'banco', i_datos_metodo->>'titular');

        WHEN i_metodo_tipo = 'movil' THEN
            INSERT INTO pago_movil_interbancario (met_pago_codigo, pag_movil_int_numero_referencia, pag_movil_int_fecha_hora)
            VALUES (v_metodo_pago_id, i_datos_metodo->>'referencia', NOW());

        WHEN i_metodo_tipo = 'transferencia' THEN
            INSERT INTO transferencia_bancaria (met_pago_codigo, trans_ban_numero_referencia, trans_ban_fecha_hora, tras_ban_numero_cuenta_emisora)
            VALUES (v_metodo_pago_id, (i_datos_metodo->>'referencia')::BIGINT, NOW(), i_datos_metodo->>'cuenta');

        WHEN i_metodo_tipo = 'cheque' THEN
            INSERT INTO cheque (met_pago_codigo, che_codigo_cuenta_cliente, che_numero, che_nombre_titular, che_banco_emisor, cheque_fecha_emision)
            VALUES (v_metodo_pago_id, i_datos_metodo->>'cuenta', i_datos_metodo->>'numero_cheque', i_datos_metodo->>'titular', i_datos_metodo->>'banco', (i_datos_metodo->>'fecha_emision')::DATE);

        WHEN i_metodo_tipo = 'deposito' THEN
            INSERT INTO deposito_bancario (met_pago_codigo, dep_ban_numero_cuenta, dep_ban_banco_emisor, dep_ban_numero_referencia, dep_fecha_transaccion)
            VALUES (v_metodo_pago_id, i_datos_metodo->>'cuenta', i_datos_metodo->>'banco', i_datos_metodo->>'referencia', NOW());

        WHEN i_metodo_tipo = 'cripto' THEN
            INSERT INTO criptomoneda (met_pago_codigo, cri_hash_transaccion, cri_direccion_billetera_emisora)
            VALUES (v_metodo_pago_id, i_datos_metodo->>'hash', i_datos_metodo->>'billetera');

        WHEN i_metodo_tipo = 'efectivo' THEN
            INSERT INTO efectivo (met_pago_codigo, efe_moneda, efe_codigo)
            VALUES (v_metodo_pago_id, i_moneda_pago, 'TAQ-' || v_metodo_pago_id);
    END CASE;

    -- 6. Insertar Pago (CON MONTO CONVERTIDO)
    INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago)
    VALUES (v_monto_final_moneda, NOW(), i_moneda_pago, v_compra_id, v_tasa_id, v_metodo_pago_id);

    -- 7. Cerrar Cuota
    IF i_origen_tipo = 'cuota' THEN
        SELECT est_codigo INTO v_estado_pagado_id FROM estado WHERE est_nombre = 'Pagado';
        IF v_estado_pagado_id IS NULL THEN v_estado_pagado_id := 8; END IF;

        UPDATE cuo_est SET cuo_est_fecha_fin = NOW() WHERE fk_cuo_codigo = i_origen_id AND cuo_est_fecha_fin = 'infinity'::TIMESTAMP;
        INSERT INTO cuo_est (fk_cuo_codigo, fk_est_codigo, cuo_est_fecha, cuo_est_fecha_fin) VALUES (i_origen_id, v_estado_pagado_id, NOW(), 'infinity'::TIMESTAMP);
    END IF;

    o_status := 200; o_mensaje := 'Pago registrado correctamente';

EXCEPTION WHEN OTHERS THEN
    o_status := 500; o_mensaje := 'Error BD: ' || SQLERRM;
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
    qr_data VARCHAR,
    estado VARCHAR,
    fk_compra INTEGER,
    det_res_codigo INTEGER,
    reclamo_estado VARCHAR,    -- NUEVO
    reclamo_respuesta VARCHAR  -- NUEVO
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM (
        -- 1. TRASLADOS
        SELECT 
            ('TRS-' || dr.fk_compra || '-' || dr.det_res_codigo)::VARCHAR,
            'Traslado'::VARCHAR,
            (COALESCE(orig.ter_nombre, 'N/A') || ' ➝ ' || COALESCE(dest.ter_nombre, 'N/A'))::VARCHAR,
            (COALESCE(mt.med_tra_descripcion, 'Transporte') || ' (' || COALESCE(mt.med_tra_tipo, '-') || ')')::VARCHAR,
            'Asiento: General'::VARCHAR,
            t.tras_fecha_hora_inicio,
            t.tras_fecha_hora_fin,
            COALESCE(ld.lug_nombre, 'N/A')::VARCHAR,
            (v.via_prim_nombre || ' ' || v.via_prim_apellido)::VARCHAR,
            ('TICKET:TRS:' || dr.fk_compra || ':' || dr.det_res_codigo)::VARCHAR,
            dr.det_res_estado::VARCHAR,
            dr.fk_compra,
            dr.det_res_codigo,
            rec.rec_estado,     -- Join con Reclamo
            rec.rec_respuesta
        FROM detalle_reserva dr
        JOIN compra c ON dr.fk_compra = c.com_codigo
        JOIN traslado t ON dr.fk_traslado = t.tras_codigo
        LEFT JOIN medio_transporte mt ON t.fk_med_tra_codigo = mt.med_tra_codigo
        LEFT JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
        LEFT JOIN terminal orig ON r.fk_terminal_origen = orig.ter_codigo
        LEFT JOIN terminal dest ON r.fk_terminal_destino = dest.ter_codigo
        LEFT JOIN lugar ld ON dest.fk_lugar = ld.lug_codigo
        JOIN viajero v ON dr.fk_viajero_codigo = v.via_codigo
        LEFT JOIN reclamo rec ON rec.fk_detalle_reserva = dr.fk_compra AND rec.fk_detalle_reserva_2 = dr.det_res_codigo
        WHERE c.fk_usuario = _usu_id 
          AND dr.fk_paquete_turistico IS NULL 
          AND dr.det_res_estado IN ('Confirmada', 'Completada', 'Cancelada')

        UNION ALL

        -- 2. SERVICIOS
        SELECT 
            ('SRV-' || dr.fk_compra || '-' || dr.det_res_codigo)::VARCHAR,
            'Servicio'::VARCHAR,
            s.ser_nombre::VARCHAR,
            p.prov_nombre::VARCHAR,
            ('Tipo: ' || s.ser_tipo)::VARCHAR,
            s.ser_fecha_hora_inicio,
            s.ser_fecha_hora_fin,
            l.lug_nombre::VARCHAR,
            (v.via_prim_nombre || ' ' || v.via_prim_apellido)::VARCHAR,
            ('TICKET:SRV:' || dr.fk_compra || ':' || dr.det_res_codigo)::VARCHAR,
            dr.det_res_estado::VARCHAR,
            dr.fk_compra,
            dr.det_res_codigo,
            rec.rec_estado,
            rec.rec_respuesta
        FROM detalle_reserva dr
        JOIN compra c ON dr.fk_compra = c.com_codigo
        JOIN servicio s ON dr.fk_servicio = s.ser_codigo
        JOIN proveedor p ON s.fk_prov_codigo = p.prov_codigo
        JOIN lugar l ON p.fk_lugar = l.lug_codigo
        JOIN viajero v ON dr.fk_viajero_codigo = v.via_codigo
        LEFT JOIN reclamo rec ON rec.fk_detalle_reserva = dr.fk_compra AND rec.fk_detalle_reserva_2 = dr.det_res_codigo
        WHERE c.fk_usuario = _usu_id 
          AND dr.fk_paquete_turistico IS NULL
          AND dr.det_res_estado IN ('Confirmada', 'Completada', 'Cancelada')

        UNION ALL

        -- 3. PAQUETES
        SELECT 
            ('PAQ-' || dr.fk_compra || '-' || dr.det_res_codigo)::VARCHAR,
            'Paquete Turístico'::VARCHAR,
            pq.paq_tur_nombre::VARCHAR,
            'Resumen del Paquete'::VARCHAR,
            'Ver detalles completos'::VARCHAR,
            COALESCE(
                (SELECT MIN(ser_fecha_hora_inicio) FROM servicio s JOIN paq_ser ps ON s.ser_codigo = ps.fk_ser_codigo WHERE ps.fk_paq_tur_codigo = pq.paq_tur_codigo),
                (SELECT MIN(tras_fecha_hora_inicio) FROM traslado tr JOIN paq_tras pt ON tr.tras_codigo = pt.fk_tras_codigo WHERE pt.fk_paq_tur_codigo = pq.paq_tur_codigo),
                c.com_fecha::TIMESTAMP
            ) as fecha_inicio,
            NULL::TIMESTAMP,
            'Multi-Destino'::VARCHAR,
            (v.via_prim_nombre || ' ' || v.via_prim_apellido)::VARCHAR,
            ('TICKET:PAQ:' || dr.fk_compra || ':' || dr.det_res_codigo)::VARCHAR,
            dr.det_res_estado::VARCHAR,
            dr.fk_compra,
            dr.det_res_codigo,
            rec.rec_estado,
            rec.rec_respuesta
        FROM detalle_reserva dr
        JOIN compra c ON dr.fk_compra = c.com_codigo
        JOIN paquete_turistico pq ON dr.fk_paquete_turistico = pq.paq_tur_codigo
        JOIN viajero v ON dr.fk_viajero_codigo = v.via_codigo
        LEFT JOIN reclamo rec ON rec.fk_detalle_reserva = dr.fk_compra AND rec.fk_detalle_reserva_2 = dr.det_res_codigo
        WHERE c.fk_usuario = _usu_id 
          AND dr.fk_servicio IS NULL AND dr.fk_traslado IS NULL
          AND dr.det_res_estado IN ('Confirmada', 'Completada', 'Cancelada')

    ) AS tickets_unificados
    ORDER BY fecha_inicio DESC NULLS LAST;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION sp_registrar_reclamo(
    p_ticket_id VARCHAR,
    p_contenido VARCHAR
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    v_compra_id INTEGER;
    v_detalle_id INTEGER;
    v_estado_reserva VARCHAR;
    v_existe BOOLEAN;
BEGIN
    -- 1. Validar ID
    IF SPLIT_PART(p_ticket_id, '-', 3) = '' THEN
        RETURN json_build_object('status', 400, 'message', 'ID de ticket inválido');
    END IF;

    v_compra_id := SPLIT_PART(p_ticket_id, '-', 2)::INTEGER;
    v_detalle_id := SPLIT_PART(p_ticket_id, '-', 3)::INTEGER;

    -- 2. Validar Ticket
    SELECT det_res_estado INTO v_estado_reserva
    FROM detalle_reserva 
    WHERE fk_compra = v_compra_id AND det_res_codigo = v_detalle_id;

    IF v_estado_reserva IS NULL THEN
        RETURN json_build_object('status', 404, 'message', 'Ticket no encontrado');
    END IF;

    IF v_estado_reserva <> 'Completada' THEN
        RETURN json_build_object('status', 400, 'message', 'Solo puedes reclamar tickets usados (Completados).');
    END IF;

    -- 3. Evitar duplicados
    SELECT EXISTS(SELECT 1 FROM reclamo WHERE fk_detalle_reserva = v_compra_id AND fk_detalle_reserva_2 = v_detalle_id) INTO v_existe;
    IF v_existe THEN
        RETURN json_build_object('status', 409, 'message', 'Ya tienes un reclamo abierto para este ticket.');
    END IF;

    -- 4. Insertar
    INSERT INTO reclamo (rec_contenido, rec_fecha_hora, fk_detalle_reserva, fk_detalle_reserva_2, rec_estado)
    VALUES (p_contenido, NOW(), v_compra_id, v_detalle_id, 'Abierto');

    RETURN json_build_object('status', 200, 'message', 'Reclamo registrado. Un agente lo revisará pronto.');
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('status', 500, 'message', 'Error BD: ' || SQLERRM);
END;
$$;


CREATE OR REPLACE FUNCTION sp_listar_reclamos_admin()
RETURNS TABLE (
    id_reclamo INTEGER,
    fecha TIMESTAMP,
    estado VARCHAR,
    cliente VARCHAR,
    producto VARCHAR,
    contenido VARCHAR,
    respuesta VARCHAR,
    ticket_ref VARCHAR,
    precio_ticket NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.rec_codigo,
        r.rec_fecha_hora,
        r.rec_estado,
        u.usu_nombre_usuario::VARCHAR,
        COALESCE(s.ser_nombre, t_orig.ter_nombre || '->' || t_dest.ter_nombre, pq.paq_tur_nombre)::VARCHAR,
        r.rec_contenido,
        r.rec_respuesta,
        (CASE 
            WHEN dr.fk_servicio IS NOT NULL THEN 'SRV'
            WHEN dr.fk_traslado IS NOT NULL THEN 'TRS'
            ELSE 'PAQ' 
         END || '-' || dr.fk_compra || '-' || dr.det_res_codigo)::VARCHAR,
         dr.det_res_monto_total
    FROM reclamo r
    JOIN detalle_reserva dr ON r.fk_detalle_reserva = dr.fk_compra AND r.fk_detalle_reserva_2 = dr.det_res_codigo
    JOIN compra c ON dr.fk_compra = c.com_codigo
    JOIN usuario u ON c.fk_usuario = u.usu_codigo
    -- Joins para nombres
    LEFT JOIN servicio s ON dr.fk_servicio = s.ser_codigo
    LEFT JOIN paquete_turistico pq ON dr.fk_paquete_turistico = pq.paq_tur_codigo
    LEFT JOIN traslado tr ON dr.fk_traslado = tr.tras_codigo
    LEFT JOIN ruta rut ON tr.fk_rut_codigo = rut.rut_codigo
    LEFT JOIN terminal t_orig ON rut.fk_terminal_origen = t_orig.ter_codigo
    LEFT JOIN terminal t_dest ON rut.fk_terminal_destino = t_dest.ter_codigo
    ORDER BY r.rec_fecha_hora DESC;
END;
$$;


CREATE OR REPLACE PROCEDURE sp_responder_reclamo_con_reembolso(
    IN i_reclamo_id INTEGER,
    IN i_respuesta TEXT,
    IN i_aplicar_reembolso BOOLEAN,
    OUT o_status INTEGER,
    OUT o_mensaje TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_compra_id INTEGER;
    v_detalle_id INTEGER;
    v_monto_ticket_usd NUMERIC;
    v_monto_a_devolver_usd NUMERIC;
    v_penalizacion_usd NUMERIC;
    
    -- Variables de Pago
    v_last_pago RECORD;
    v_nuevo_pago_id INTEGER;
    v_nuevo_metodo_id INTEGER;
    v_tasa_valor NUMERIC;
    v_monto_final_local NUMERIC;
    v_retencion_final_local NUMERIC;
    v_estado_actual VARCHAR;
BEGIN
    -- 1. Obtener datos del reclamo
    SELECT fk_detalle_reserva, fk_detalle_reserva_2, rec_estado 
    INTO v_compra_id, v_detalle_id, v_estado_actual
    FROM reclamo WHERE rec_codigo = i_reclamo_id;

    IF v_compra_id IS NULL THEN o_status := 404; o_mensaje := 'Reclamo no encontrado'; RETURN; END IF;
    IF v_estado_actual = 'Cerrado' THEN o_status := 400; o_mensaje := 'El reclamo ya está cerrado'; RETURN; END IF;

    -- 2. Si hay reembolso, calcular montos
    IF i_aplicar_reembolso THEN
        -- Obtener costo del ticket específico
        SELECT det_res_monto_total INTO v_monto_ticket_usd
        FROM detalle_reserva 
        WHERE fk_compra = v_compra_id AND det_res_codigo = v_detalle_id;

        -- Regla de Negocio: 10% Penalización, 90% Devolución
        v_penalizacion_usd := v_monto_ticket_usd * 0.10;
        v_monto_a_devolver_usd := v_monto_ticket_usd - v_penalizacion_usd;

        -- Buscar último pago para obtener método y tasa
        SELECT * INTO v_last_pago FROM pago WHERE fk_compra = v_compra_id ORDER BY pag_fecha_hora DESC LIMIT 1;

        IF v_last_pago IS NULL THEN
            o_status := 400; o_mensaje := 'No se puede reembolsar: No hay pagos registrados en la compra origen.'; RETURN;
        END IF;

        -- Conversión a moneda del pago original
        SELECT tas_cam_tasa_valor INTO v_tasa_valor FROM tasa_de_cambio WHERE tas_cam_codigo = v_last_pago.fk_tasa_de_cambio;
        
        v_monto_final_local := v_monto_a_devolver_usd * v_tasa_valor;
        v_retencion_final_local := v_penalizacion_usd * v_tasa_valor;

        -- Registrar Pago Negativo (Salida de dinero)
        INSERT INTO metodo_pago (met_pag_descripcion, fk_tipo_metodo)
        SELECT 'Reembolso por Reclamo #' || i_reclamo_id, fk_tipo_metodo FROM metodo_pago WHERE met_pag_codigo = v_last_pago.fk_metodo_pago
        RETURNING met_pag_codigo INTO v_nuevo_metodo_id;

        INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago)
        VALUES ((v_monto_final_local * -1), NOW(), v_last_pago.pag_denominacion, v_compra_id, v_last_pago.fk_tasa_de_cambio, v_nuevo_metodo_id)
        RETURNING pag_codigo INTO v_nuevo_pago_id;

        INSERT INTO reembolso (rem_monto_reembolsado, rem_monto_retenido, rem_fecha, fk_pago)
        VALUES (v_monto_final_local, v_retencion_final_local, CURRENT_DATE, v_nuevo_pago_id);
    END IF;

    -- 3. Cerrar Reclamo
    UPDATE reclamo 
    SET rec_respuesta = i_respuesta, 
        rec_estado = 'Cerrado' 
    WHERE rec_codigo = i_reclamo_id;

    o_status := 200; 
    IF i_aplicar_reembolso THEN
        o_mensaje := 'Reclamo cerrado y reembolso de $' || ROUND(v_monto_a_devolver_usd, 2) || ' generado.';
    ELSE
        o_mensaje := 'Reclamo cerrado exitosamente.';
    END IF;

EXCEPTION WHEN OTHERS THEN
    o_status := 500; o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;





--AAA
CREATE OR REPLACE PROCEDURE sp_marcar_ticket_usado(
    IN i_ticket_id VARCHAR, -- Nuevo Formato: 'TIPO-COMPRA-DETALLE' (Ej: 'SRV-105-1')
    OUT o_status INTEGER,
    OUT o_mensaje TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_compra_id INTEGER;
    v_detalle_id INTEGER;
    v_estado_actual VARCHAR;
BEGIN
    -- 1. Validar formato mínimo
    IF SPLIT_PART(i_ticket_id, '-', 3) = '' THEN
        o_status := 400; 
        o_mensaje := 'Formato de ticket inválido. Se requiere TIPO-COMPRA-DETALLE'; 
        RETURN;
    END IF;

    -- 2. Extraer IDs (Ahora necesitamos dos partes)
    -- Parte 2: ID de la Compra
    v_compra_id := SPLIT_PART(i_ticket_id, '-', 2)::INTEGER;
    -- Parte 3: ID del Detalle
    v_detalle_id := SPLIT_PART(i_ticket_id, '-', 3)::INTEGER;

    -- 3. Verificar estado actual (Usando AMBAS llaves)
    SELECT det_res_estado INTO v_estado_actual 
    FROM detalle_reserva 
    WHERE fk_compra = v_compra_id 
      AND det_res_codigo = v_detalle_id;

    -- Validaciones
    IF v_estado_actual IS NULL THEN
        o_status := 404; o_mensaje := 'Ticket no encontrado en el sistema.'; RETURN;
    END IF;

    IF v_estado_actual = 'Cancelada' THEN
        o_status := 400; o_mensaje := 'Ticket inválido (La reserva fue cancelada).'; RETURN;
    END IF;

    IF v_estado_actual = 'Completada' THEN
        o_status := 200; o_mensaje := 'Este ticket ya fue utilizado anteriormente.'; RETURN;
    END IF;

    -- 4. Actualizar (Usando AMBAS llaves para ser quirúrgico)
    UPDATE detalle_reserva 
    SET det_res_estado = 'Completada' 
    WHERE fk_compra = v_compra_id 
      AND det_res_codigo = v_detalle_id;

    o_status := 200;
    o_mensaje := 'Ticket validado exitosamente. ¡Disfrute su viaje!';

EXCEPTION WHEN OTHERS THEN
    o_status := 500; 
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;



BEGIN;

-- 1. OBTENER CUOTAS PENDIENTES (Lógica Financiera Inteligente)
-- Devuelve las cuotas y calcula si están "Pagadas" o "Pendientes" basándose en el saldo total abonado.
CREATE OR REPLACE FUNCTION sp_obtener_cuotas_cliente(i_usuario_id INTEGER)
RETURNS TABLE (
    cuota_id INTEGER,
    concepto TEXT,
    monto NUMERIC,
    fecha_vencimiento DATE,
    compra_id INTEGER,
    estado VARCHAR
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.cuo_codigo,
        ('Cuota ' || TO_CHAR(c.cuo_fecha_tope, 'Mon-YYYY') || ' (Compra #' || pf.fk_compra || ')')::TEXT,
        c.cuo_monto,
        c.cuo_fecha_tope,
        pf.fk_compra,
        e.est_nombre::VARCHAR
    FROM cuota c
    JOIN plan_financiamiento pf ON c.fk_plan_financiamiento = pf.plan_fin_codigo
    JOIN compra com ON pf.fk_compra = com.com_codigo
    JOIN cuo_est ce ON c.cuo_codigo = ce.fk_cuo_codigo
    JOIN estado e ON ce.fk_est_codigo = e.est_codigo
    WHERE com.fk_usuario = i_usuario_id
      AND ce.cuo_est_fecha_fin = 'infinity' -- Estado actual
      AND e.est_nombre = 'Pendiente'        -- SOLO PENDIENTES (Ni canceladas ni pagadas)
    ORDER BY c.cuo_fecha_tope ASC;
END;
$$;
-- 2. OBTENER HISTORIAL DE PAGOS
CREATE OR REPLACE FUNCTION sp_obtener_historial_pagos(_usu_id INTEGER)
RETURNS TABLE (
    pago_id INTEGER,
    fecha TIMESTAMP,
    monto_original NUMERIC,
    moneda_original VARCHAR,
    tasa_aplicada NUMERIC,
    monto_usd NUMERIC,
    metodo VARCHAR,
    referencia VARCHAR,
    compra_id INTEGER,
    estado_reembolso VARCHAR,
    es_reembolsable BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    WITH PagosOrdenados AS (
        SELECT 
            p.pag_codigo,
            ROW_NUMBER() OVER(PARTITION BY p.fk_compra ORDER BY p.pag_fecha_hora ASC) as numero_pago
        FROM pago p
        JOIN compra c ON p.fk_compra = c.com_codigo
        WHERE c.fk_usuario = _usu_id AND p.pag_monto > 0 
    ),
    -- CTE para saber si una compra YA tiene un reembolso activo (cualquiera)
    ComprasReembolsadas AS (
        SELECT DISTINCT p.fk_compra
        FROM reembolso r
        JOIN pago p ON r.fk_pago = p.pag_codigo
    )
    SELECT 
        p.pag_codigo,
        p.pag_fecha_hora,
        p.pag_monto,
        p.pag_denominacion::VARCHAR,
        tc.tas_cam_tasa_valor,
        ROUND(p.pag_monto / NULLIF(tc.tas_cam_tasa_valor, 0), 2),
        mp.met_pag_descripcion::VARCHAR,
        COALESCE(z.zel_codigo_transaccion, tc_card.tar_cre_numero, pm.pag_movil_int_numero_referencia, 'N/A')::VARCHAR,
        p.fk_compra,
        -- Estado Visual
        CASE 
            WHEN cr.fk_compra IS NOT NULL THEN 'Reembolsado' -- Si la compra tiene reembolso, todo está reembolsado
            ELSE 'Completado' 
        END::VARCHAR,
        -- Lógica del Botón
        CASE 
            WHEN po.numero_pago = 1          -- Es el primer pago
                 AND p.pag_monto > 0         -- Es positivo
                 AND cr.fk_compra IS NULL    -- Y la compra NO ha sido reembolsada aún
            THEN TRUE 
            ELSE FALSE 
        END as es_reembolsable
    FROM pago p
    JOIN compra c ON p.fk_compra = c.com_codigo
    JOIN tasa_de_cambio tc ON p.fk_tasa_de_cambio = tc.tas_cam_codigo
    JOIN metodo_pago mp ON p.fk_metodo_pago = mp.met_pag_codigo
    LEFT JOIN PagosOrdenados po ON p.pag_codigo = po.pag_codigo
    LEFT JOIN ComprasReembolsadas cr ON p.fk_compra = cr.fk_compra -- Join contra la CTE de compras canceladas
    LEFT JOIN zelle z ON mp.met_pag_codigo = z.met_pago_codigo
    LEFT JOIN tarjeta_credito tc_card ON mp.met_pag_codigo = tc_card.met_pago_codigo
    LEFT JOIN pago_movil_interbancario pm ON mp.met_pag_codigo = pm.met_pago_codigo
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
    IN i_compra_id INTEGER,
    OUT o_monto_reembolsado NUMERIC,
    OUT o_status INTEGER,
    OUT o_mensaje TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    -- Variables Financieras
    v_total_viaje_usd NUMERIC;
    v_total_pagado_usd NUMERIC;
    v_penalizacion_usd NUMERIC;
    v_a_devolver_usd NUMERIC;
    
    -- Variables de Pago
    v_last_pago RECORD;
    v_nuevo_pago_id INTEGER;
    v_nuevo_metodo_id INTEGER;
    v_metodo_descripcion TEXT;
    
    -- Variables de Control
    v_estado_cancelado_id INTEGER;
    v_ya_paso BOOLEAN;
    v_paquete_iniciado BOOLEAN;
    
    -- Variables de Conversión
    v_tasa_valor NUMERIC;
    v_monto_final_registro NUMERIC; 
    v_retencion_final_registro NUMERIC;
    
    -- VARIABLES PARA MILLAS
    v_millas_ganadas INTEGER;
    v_saldo_actual INTEGER;
    v_usuario_id INTEGER;
BEGIN
    -- 1. OBTENER ID USUARIO (Necesario para validaciones)
    SELECT fk_usuario INTO v_usuario_id FROM compra WHERE com_codigo = i_compra_id;
    IF v_usuario_id IS NULL THEN o_status := 404; o_mensaje := 'Compra no encontrada'; RETURN; END IF;

    -- =================================================================================
    -- VALIDACIONES PREVIAS (Bloquean el proceso antes de calcular dinero)
    -- =================================================================================

    -- A. Ticket Usado
    SELECT EXISTS (SELECT 1 FROM detalle_reserva WHERE fk_compra = i_compra_id AND det_res_estado = 'Completada') INTO v_ya_paso;
    IF v_ya_paso THEN o_status := 400; o_mensaje := 'No reembolsable: Tickets ya utilizados.'; RETURN; END IF;

    -- B. Fechas Vencidas (Servicios/Traslados)
    SELECT EXISTS (
        SELECT 1 FROM detalle_reserva dr
        LEFT JOIN servicio s ON dr.fk_servicio = s.ser_codigo
        LEFT JOIN traslado t ON dr.fk_traslado = t.tras_codigo
        WHERE dr.fk_compra = i_compra_id 
          AND (s.ser_fecha_hora_inicio < NOW() OR t.tras_fecha_hora_inicio < NOW())
    ) INTO v_ya_paso;
    IF v_ya_paso THEN o_status := 400; o_mensaje := 'No reembolsable: Viaje ya iniciado.'; RETURN; END IF;

    -- C. Fechas Vencidas (Paquetes)
    SELECT EXISTS (
        SELECT 1 FROM detalle_reserva dr JOIN paquete_turistico pq ON dr.fk_paquete_turistico = pq.paq_tur_codigo
        WHERE dr.fk_compra = i_compra_id
          AND (
              EXISTS (SELECT 1 FROM paq_ser ps JOIN servicio s ON ps.fk_ser_codigo = s.ser_codigo WHERE ps.fk_paq_tur_codigo = pq.paq_tur_codigo AND s.ser_fecha_hora_inicio < NOW())
              OR
              EXISTS (SELECT 1 FROM paq_tras pt JOIN traslado t ON pt.fk_tras_codigo = t.tras_codigo WHERE pt.fk_paq_tur_codigo = pq.paq_tur_codigo AND t.tras_fecha_hora_inicio < NOW())
          )
    ) INTO v_paquete_iniciado;
    IF v_paquete_iniciado THEN o_status := 400; o_mensaje := 'No reembolsable: Paquete ya iniciado.'; RETURN; END IF;

    -- D. VALIDAR SALDO DE MILLAS (NUEVO)
    -- Verificamos si el usuario tiene suficientes millas para "devolver" las que ganó
    SELECT COALESCE(SUM(mil_valor_obtenido), 0) INTO v_millas_ganadas
    FROM milla 
    WHERE fk_compra = i_compra_id; -- Sumamos lo que ganó originalmente con esta compra

    IF v_millas_ganadas > 0 THEN
        SELECT usu_total_millas INTO v_saldo_actual FROM usuario WHERE usu_codigo = v_usuario_id;
        
        IF v_saldo_actual < v_millas_ganadas THEN
            o_status := 400; 
            o_mensaje := 'No reembolsable: Ya has utilizado las millas ('|| v_millas_ganadas ||') generadas por esta compra.'; 
            RETURN; -- Bloqueamos el reembolso aquí
        END IF;
    END IF;

    -- =================================================================================
    -- 2. CÁLCULOS FINANCIEROS
    -- =================================================================================
    SELECT com_monto_total INTO v_total_viaje_usd FROM compra WHERE com_codigo = i_compra_id;
    
    SELECT COALESCE(SUM(p.pag_monto / tc.tas_cam_tasa_valor), 0) 
    INTO v_total_pagado_usd 
    FROM pago p
    JOIN tasa_de_cambio tc ON p.fk_tasa_de_cambio = tc.tas_cam_codigo
    WHERE p.fk_compra = i_compra_id;

    v_penalizacion_usd := v_total_viaje_usd * 0.10;
    v_a_devolver_usd := v_total_pagado_usd - v_penalizacion_usd;

    IF v_a_devolver_usd < 0 THEN v_a_devolver_usd := 0; END IF;

    -- 3. OBTENER DATOS PARA REBOTE
    SELECT * INTO v_last_pago FROM pago WHERE fk_compra = i_compra_id ORDER BY pag_fecha_hora DESC LIMIT 1;
    
    IF v_last_pago IS NULL THEN 
        -- Cancelación simple si no hubo pagos (Millas igual se reversan abajo si hubiese)
        UPDATE detalle_reserva SET det_res_estado = 'Cancelada' WHERE fk_compra = i_compra_id;
        v_nuevo_pago_id := NULL; -- No hay pago negativo
    ELSE
        -- 4. CONVERSIÓN A MONEDA LOCAL
        SELECT tas_cam_tasa_valor INTO v_tasa_valor FROM tasa_de_cambio WHERE tas_cam_codigo = v_last_pago.fk_tasa_de_cambio;
        v_monto_final_registro := v_a_devolver_usd * v_tasa_valor;
        v_retencion_final_registro := v_penalizacion_usd * v_tasa_valor;

        -- 5. REGISTRAR PAGO NEGATIVO
        IF v_monto_final_registro > 0 THEN
            SELECT ('Reembolso ref. Pago #' || v_last_pago.pag_codigo) INTO v_metodo_descripcion;
            
            INSERT INTO metodo_pago (met_pag_descripcion, fk_tipo_metodo)
            SELECT v_metodo_descripcion, fk_tipo_metodo FROM metodo_pago WHERE met_pag_codigo = v_last_pago.fk_metodo_pago
            RETURNING met_pag_codigo INTO v_nuevo_metodo_id;

            INSERT INTO pago (pag_monto, pag_fecha_hora, pag_denominacion, fk_compra, fk_tasa_de_cambio, fk_metodo_pago)
            VALUES ((v_monto_final_registro * -1), NOW(), v_last_pago.pag_denominacion, i_compra_id, v_last_pago.fk_tasa_de_cambio, v_nuevo_metodo_id)
            RETURNING pag_codigo INTO v_nuevo_pago_id;

            INSERT INTO reembolso (rem_monto_reembolsado, rem_monto_retenido, rem_fecha, fk_pago)
            VALUES (v_monto_final_registro, v_retencion_final_registro, CURRENT_DATE, v_nuevo_pago_id);
        END IF;
    END IF;

    -- 6. GESTIÓN DE ESTADOS (CANCELACIÓN)
    UPDATE detalle_reserva SET det_res_estado = 'Cancelada' WHERE fk_compra = i_compra_id;

    UPDATE cuo_est ce SET cuo_est_fecha_fin = NOW()
    FROM cuota c JOIN plan_financiamiento pf ON c.fk_plan_financiamiento = pf.plan_fin_codigo
    WHERE c.cuo_codigo = ce.fk_cuo_codigo AND pf.fk_compra = i_compra_id AND ce.cuo_est_fecha_fin = 'infinity'::TIMESTAMP;

    SELECT est_codigo INTO v_estado_cancelado_id FROM estado WHERE est_nombre = 'Cancelado';
    
    INSERT INTO cuo_est (fk_cuo_codigo, fk_est_codigo, cuo_est_fecha, cuo_est_fecha_fin)
    SELECT c.cuo_codigo, v_estado_cancelado_id, NOW(), 'infinity'::TIMESTAMP
    FROM cuota c JOIN plan_financiamiento pf ON c.fk_plan_financiamiento = pf.plan_fin_codigo
    WHERE pf.fk_compra = i_compra_id
      AND NOT EXISTS (SELECT 1 FROM cuo_est x JOIN estado e ON x.fk_est_codigo = e.est_codigo WHERE x.fk_cuo_codigo = c.cuo_codigo AND e.est_nombre = 'Pagado');

    -- =================================================================================
    -- 7. REVERSIÓN DE MILLAS (EJECUCIÓN)
    -- =================================================================================
    IF v_millas_ganadas > 0 THEN
        -- A. Restar del saldo del usuario
        UPDATE usuario 
        SET usu_total_millas = usu_total_millas - v_millas_ganadas
        WHERE usu_codigo = v_usuario_id;

        -- B. Registrar Egreso en tabla 'milla' con la nueva estructura
        INSERT INTO milla (
            mil_valor_obtenido, 
            mil_fecha_inicio, 
            mil_fecha_fin,
            mil_valor_restado,  -- Columna correcta para egresos
            fk_compra,          -- NULO según requerimiento
            fk_pago             -- Vinculado al pago de reembolso (si existe)
        )
        VALUES (
            NULL, 
            CURRENT_DATE, 
            NULL,
            v_millas_ganadas, 
            NULL, 
            v_nuevo_pago_id
        );
    END IF;

    o_monto_reembolsado := v_monto_final_registro;
    o_status := 200;
    o_mensaje := 'Reembolso procesado. Millas descontadas: ' || COALESCE(v_millas_ganadas, 0);

EXCEPTION WHEN OTHERS THEN
    o_status := 500; o_mensaje := 'Error CRITICO: ' || SQLERRM;
END;
$$;













COMMIT;

CREATE OR REPLACE FUNCTION sp_obtener_reembolsos_cliente(_usu_id INTEGER)
RETURNS TABLE (
    reembolso_id INTEGER,
    fecha DATE,
    compra_id INTEGER,
    total_viaje NUMERIC,
    monto_reembolsado NUMERIC,
    monto_retenido NUMERIC,
    moneda_original VARCHAR,
    tasa_valor NUMERIC,       -- NUEVA COLUMNA
    tipo_resolucion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.rem_codigo,
        r.rem_fecha,
        c.com_codigo,
        c.com_monto_total, -- Total del viaje en USD
        r.rem_monto_reembolsado, -- Ya está en moneda local
        r.rem_monto_retenido,    -- Ya está en moneda local (gracias al SP corregido)
        p.pag_denominacion::VARCHAR,
        tc.tas_cam_tasa_valor,   -- Tasa usada
        CASE 
            WHEN r.rem_monto_reembolsado > 0 THEN 'Devolución Monetaria'::VARCHAR
            ELSE 'Cancelación de Deuda'::VARCHAR
        END
    FROM reembolso r
    JOIN pago p ON r.fk_pago = p.pag_codigo
    JOIN tasa_de_cambio tc ON p.fk_tasa_de_cambio = tc.tas_cam_codigo
    JOIN compra c ON p.fk_compra = c.com_codigo
    WHERE c.fk_usuario = _usu_id
    ORDER BY r.rem_fecha DESC;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE asignar_privilegio_rol(
    IN p_rol_codigo INT,
    IN p_pri_codigo INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO rol_privilegio(fk_rol_codigo, fk_pri_codigo)
    VALUES (p_rol_codigo, p_pri_codigo)
    ON CONFLICT (fk_pri_codigo, fk_rol_codigo) DO NOTHING;
END;
$$;




CREATE OR REPLACE PROCEDURE editar_rol(
    IN p_codigo INT,
    IN p_nombre VARCHAR(30),
    IN p_descripcion TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE rol
    SET 
        rol_nombre = p_nombre,
        rol_descripcion = p_descripcion
    WHERE rol_codigo = p_codigo;
END;
$$;


CREATE OR REPLACE PROCEDURE eliminar_rol(
    IN p_codigo INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM rol 
    WHERE rol_codigo = p_codigo;
END;
$$;


CREATE OR REPLACE PROCEDURE gestionar_asignacion_promocion(
    _prom_id INT, _elem_id INT, _tipo VARCHAR, _accion VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    -- ACCIÓN: APLICAR
    IF _accion = 'aplicar' THEN
        IF _tipo = 'servicio' THEN INSERT INTO ser_prom (fk_ser_codigo, fk_prom_codigo) VALUES (_elem_id, _prom_id) ON CONFLICT DO NOTHING;
        
        -- Casos 1:N (UPDATE)
        ELSIF _tipo = 'habitacion' THEN UPDATE habitacion SET fk_promocion = _prom_id WHERE hab_num_hab = _elem_id;
        ELSIF _tipo = 'restaurante' THEN UPDATE restaurante SET fk_promocion = _prom_id WHERE res_codigo = _elem_id;
        
        -- Casos N:M (INSERT)
        ELSIF _tipo = 'traslado' THEN INSERT INTO tras_prom (fk_tras_codigo, fk_prom_codigo) VALUES (_elem_id, _prom_id) ON CONFLICT DO NOTHING;
        ELSIF _tipo = 'paquete' THEN INSERT INTO paq_prom (fk_paq_tur_codigo, fk_prom_codigo) VALUES (_elem_id, _prom_id) ON CONFLICT DO NOTHING;
        END IF;

    -- ACCIÓN: REMOVER
    ELSIF _accion = 'remover' THEN
        IF _tipo = 'servicio' THEN DELETE FROM ser_prom WHERE fk_ser_codigo = _elem_id AND fk_prom_codigo = _prom_id;
        
        -- Casos 1:N (NULLIFY)
        ELSIF _tipo = 'habitacion' THEN UPDATE habitacion SET fk_promocion = NULL WHERE hab_num_hab = _elem_id AND fk_promocion = _prom_id;
        ELSIF _tipo = 'restaurante' THEN UPDATE restaurante SET fk_promocion = NULL WHERE res_codigo = _elem_id AND fk_promocion = _prom_id;
        
        -- Casos N:M (DELETE)
        ELSIF _tipo = 'traslado' THEN DELETE FROM tras_prom WHERE fk_tras_codigo = _elem_id AND fk_prom_codigo = _prom_id;
        ELSIF _tipo = 'paquete' THEN DELETE FROM paq_prom WHERE fk_paq_tur_codigo = _elem_id AND fk_prom_codigo = _prom_id;
        END IF;
    END IF;
END; $$;


CREATE OR REPLACE PROCEDURE listar_todos_privilegios(
    INOUT p_cursor REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_cursor FOR
    SELECT pri_codigo, pri_nombre, pri_descripcion 
    FROM privilegio
    ORDER BY pri_codigo;
END;
$$;


CREATE OR REPLACE PROCEDURE obtener_privilegios_rol(
    IN p_rol_codigo INT,
    INOUT p_cursor REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_cursor FOR
    SELECT fk_pri_codigo 
    FROM rol_privilegio
    WHERE fk_rol_codigo = p_rol_codigo;
END;
$$;

CREATE OR REPLACE PROCEDURE registrar_promocion(
    _nombre VARCHAR, _descripcion VARCHAR, _fecha TIMESTAMP, _descuento NUMERIC
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO promocion (prom_nombre, prom_descripcion, prom_fecha_hora_vencimiento, prom_descuento)
    VALUES (_nombre, _descripcion, _fecha, _descuento);
END; $$;


CREATE OR REPLACE PROCEDURE registrar_rol(
    IN p_nombre VARCHAR(30),
    IN p_descripcion TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO rol(rol_nombre, rol_descripcion)
    VALUES (p_nombre, p_descripcion);
END;
$$;


CREATE OR REPLACE PROCEDURE revocar_privilegio_rol(
    IN p_rol_codigo INT,
    IN p_pri_codigo INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM rol_privilegio
    WHERE fk_rol_codigo = p_rol_codigo AND fk_pri_codigo = p_pri_codigo;
END;
$$;


CREATE OR REPLACE PROCEDURE sp_crear_paquete_turistico(
    IN p_nombre VARCHAR(50),
    IN p_monto_total NUMERIC(10,2),
    IN p_monto_subtotal NUMERIC(10,2),
    IN p_costo_millas INTEGER,
    OUT o_status_code INTEGER,
    OUT o_mensaje VARCHAR,
    OUT o_paq_tur_codigo INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insertamos el nuevo registro
    INSERT INTO paquete_turistico (
        paq_tur_nombre, 
        paq_tur_monto_total, 
        paq_tur_monto_subtotal, 
        paq_tur_costo_en_millas
    )
    VALUES (
        p_nombre, 
        p_monto_total, 
        p_monto_subtotal, 
        p_costo_millas
    )
    RETURNING paq_tur_codigo INTO o_paq_tur_codigo;

    -- Respuesta exitosa
    o_status_code := 201;
    o_mensaje := 'Paquete turístico creado exitosamente';

EXCEPTION
    WHEN OTHERS THEN
        o_status_code := 500;
        o_mensaje := 'Error al crear el paquete: ' || SQLERRM;
        o_paq_tur_codigo := NULL;
END;
$$;



CREATE OR REPLACE PROCEDURE sp_editar_proveedor(
    IN i_admin_id INTEGER,
    IN i_prov_codigo INTEGER,
    IN i_prov_nombre VARCHAR, -- Se recomienda usar VARCHAR sin longitud en parámetros
    IN i_prov_fecha_creacion DATE,
    IN i_prov_tipo VARCHAR,
    IN i_fk_lugar INTEGER,
    IN i_usu_nombre VARCHAR,
    IN i_usu_email VARCHAR,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje TEXT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_usu_id INTEGER;
BEGIN
    -- 1. Validar Permisos
    IF NOT EXISTS (
        SELECT 1 FROM usuario u 
        JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo 
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo 
        WHERE u.usu_codigo = i_admin_id AND p.pri_nombre = 'crear_usuarios'
    ) THEN
        o_status_code := 403; 
        o_mensaje := 'No tiene privilegios para editar proveedores.'; 
        RETURN;
    END IF;

    -- 2. Obtener el ID del usuario asociado al proveedor
    SELECT fk_usu_codigo INTO v_usu_id FROM proveedor WHERE prov_codigo = i_prov_codigo;

    IF v_usu_id IS NULL THEN
        o_status_code := 404; 
        o_mensaje := 'Proveedor no encontrado.'; 
        RETURN;
    END IF;

    -- 3. Actualizar tabla USUARIO
    UPDATE usuario 
    SET usu_nombre_usuario = i_usu_nombre,
        usu_email = i_usu_email,
        fk_lugar = i_fk_lugar
    WHERE usu_codigo = v_usu_id;

    -- 4. Actualizar tabla PROVEEDOR
    UPDATE proveedor
    SET prov_nombre = i_prov_nombre,
        prov_fecha_creacion = i_prov_fecha_creacion,
        prov_tipo = i_prov_tipo,
        fk_lugar = i_fk_lugar
    WHERE prov_codigo = i_prov_codigo;

    o_status_code := 200;
    o_mensaje := 'Proveedor actualizado exitosamente.';

EXCEPTION 
    WHEN unique_violation THEN
        o_status_code := 409; 
        o_mensaje := 'El nombre de usuario o correo ya está en uso.';
    WHEN OTHERS THEN
        o_status_code := 500; 
        o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;


CREATE OR REPLACE PROCEDURE sp_eliminar_paquete_turistico(
    IN p_paq_tur_codigo INTEGER,
    OUT o_status_code INTEGER,
    OUT o_mensaje VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificamos si existe
    IF NOT EXISTS (SELECT 1 FROM paquete_turistico WHERE paq_tur_codigo = p_paq_tur_codigo) THEN
        o_status_code := 404;
        o_mensaje := 'El paquete turístico no existe';
        RETURN;
    END IF;

    -- Intentamos eliminar
    DELETE FROM paquete_turistico
    WHERE paq_tur_codigo = p_paq_tur_codigo;

    o_status_code := 200;
    o_mensaje := 'Paquete turístico eliminado exitosamente';

EXCEPTION
    -- Captura errores de llave foránea (ej: código 23503)
    WHEN foreign_key_violation THEN
        o_status_code := 409; -- Conflict
        o_mensaje := 'No se puede eliminar el paquete porque está en uso (tiene reglas o reservas asociadas)';
    
    WHEN OTHERS THEN
        o_status_code := 500;
        o_mensaje := 'Error al eliminar el paquete: ' || SQLERRM;
END;
$$;


CREATE OR REPLACE PROCEDURE sp_eliminar_proveedor(
    IN i_usuario_codigo INTEGER,
    IN i_prov_codigo INTEGER,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje TEXT DEFAULT NULL -- CAMBIO: TEXT para evitar errores de longitud
)
LANGUAGE plpgsql
AS $$
DECLARE 
    v_usu_id INTEGER;
BEGIN
    -- 1. Validar Permisos
    IF NOT EXISTS (
        SELECT 1 FROM usuario u
        JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usuario_codigo AND p.pri_nombre = 'eliminar_usuarios'
    ) THEN 
        o_status_code := 403; 
        o_mensaje := 'No tiene privilegios para esta acción.'; -- Faltaba punto y coma
        RETURN; -- CRÍTICO: Detener ejecución si no hay permiso
    END IF;

    -- 2. Obtener ID del usuario asociado
    SELECT fk_usu_codigo INTO v_usu_id FROM proveedor WHERE prov_codigo = i_prov_codigo;

    IF v_usu_id IS NULL THEN
        o_status_code := 404; 
        o_mensaje := 'Proveedor no encontrado.';
        RETURN; -- CRÍTICO: Detener ejecución si no existe
    END IF;

    -- 3. Eliminar Proveedor (Datos de negocio)
    DELETE FROM proveedor WHERE prov_codigo = i_prov_codigo;

    -- 4. Eliminar Usuario (Credenciales de acceso)
    -- Nota: Esto fallará si el usuario tiene registros en 'auditoria' o 'compra'
    DELETE FROM usuario WHERE usu_codigo = v_usu_id;
    
    o_status_code := 200;
    o_mensaje := 'Proveedor eliminado exitosamente.';

EXCEPTION 
    WHEN foreign_key_violation THEN
        -- Rollback automático ocurre aquí
        o_status_code := 409; 
        o_mensaje := 'No se puede eliminar: El proveedor tiene rutas activas o historial de auditoría.';
    WHEN OTHERS THEN
        o_status_code := 500; 
        o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;


CREATE OR REPLACE PROCEDURE sp_modificar_paquete_turistico(
    IN p_paq_tur_codigo INTEGER,
    IN p_nombre VARCHAR(50),
    IN p_monto_total NUMERIC(10,2),
    IN p_monto_subtotal NUMERIC(10,2),
    IN p_costo_millas INTEGER,
    OUT o_status_code INTEGER,
    OUT o_mensaje VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificamos si existe el paquete
    IF NOT EXISTS (SELECT 1 FROM paquete_turistico WHERE paq_tur_codigo = p_paq_tur_codigo) THEN
        o_status_code := 404;
        o_mensaje := 'El paquete turístico no existe';
        RETURN;
    END IF;

    -- Realizamos la actualización
    UPDATE paquete_turistico
    SET 
        paq_tur_nombre = p_nombre,
        paq_tur_monto_total = p_monto_total,
        paq_tur_monto_subtotal = p_monto_subtotal,
        paq_tur_costo_en_millas = p_costo_millas
    WHERE paq_tur_codigo = p_paq_tur_codigo;

    o_status_code := 200;
    o_mensaje := 'Paquete turístico actualizado exitosamente';

EXCEPTION
    WHEN OTHERS THEN
        o_status_code := 500;
        o_mensaje := 'Error al actualizar el paquete: ' || SQLERRM;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_obtener_terminales_compatibles(
    IN i_usu_codigo INTEGER,
    INOUT o_cursor REFCURSOR DEFAULT NULL,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_pro_tipo VARCHAR;
    v_prov_codigo INTEGER;
BEGIN
    -- CORRECCIÓN: Usar prov_tipo y prov_codigo
    SELECT p.prov_tipo, p.prov_codigo INTO v_pro_tipo, v_prov_codigo
    FROM proveedor p
    JOIN usuario u ON p.fk_usu_codigo = u.usu_codigo
    WHERE u.usu_codigo = i_usu_codigo;

    IF v_pro_tipo IS NULL THEN
        o_status_code := 404;
        o_mensaje := 'Usuario no es proveedor.';
        RETURN;
    END IF;

    OPEN o_cursor FOR
    SELECT 
        t.ter_codigo, 
        (t.ter_nombre || ' - ' || l.lug_nombre || ', ' || p.lug_nombre) AS ter_nombre_completo,
        t.ter_tipo
    FROM terminal t
    JOIN lugar l ON t.fk_lugar = l.lug_codigo
    JOIN lugar p ON l.fk_lugar = p.lug_codigo
    WHERE 
        (v_pro_tipo = 'Aerolinea' AND t.ter_tipo = 'Aeropuerto') OR
        (v_pro_tipo = 'Maritimo' AND t.ter_tipo = 'Puerto') OR
        (v_pro_tipo = 'Terrestre' AND t.ter_tipo IN ('Terminal Terrestre', 'Estacion')) OR
        (v_pro_tipo = 'Otros') 
    ORDER BY p.lug_nombre, l.lug_nombre;

    o_status_code := 200;
    o_mensaje := 'Terminales obtenidas.';
END; $$;


CREATE OR REPLACE FUNCTION sp_listar_proveedores()
RETURNS TABLE (
    prov_codigo INTEGER,
    prov_nombre VARCHAR,
    prov_tipo VARCHAR,
    prov_fecha_creacion DATE,
    anos_antiguedad INTEGER,
    lug_nombre VARCHAR,
    fk_lugar INTEGER,
    usu_nombre_usuario VARCHAR,
    usu_email VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        p.prov_codigo,
        p.prov_nombre,
        p.prov_tipo,
        p.prov_fecha_creacion,
        -- Calculamos la antigüedad en años dinámicamente
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.prov_fecha_creacion))::INTEGER,
        
        -- Datos del Lugar (JOIN)
        l.lug_nombre,
        p.fk_lugar, -- Necesario para que el Select del Modal de edición funcione
        
        -- Datos del Usuario Admin (JOIN)
        u.usu_nombre_usuario,
        u.usu_email -- Necesario para llenar el campo email en el Modal de edición
    FROM proveedor p
    JOIN lugar l ON p.fk_lugar = l.lug_codigo
    JOIN usuario u ON p.fk_usu_codigo = u.usu_codigo
    ORDER BY p.prov_codigo DESC;
END;
$$;




-- ================================================================
-- 0. LIMPIEZA TOTAL (Evita conflictos de parámetros)
-- ================================================================
-- Borramos las funciones viejas para crearlas de cero limpias
DROP PROCEDURE IF EXISTS registrar_promocion CASCADE;
DROP PROCEDURE IF EXISTS editar_promocion CASCADE;
DROP PROCEDURE IF EXISTS eliminar_promocion CASCADE;
DROP PROCEDURE IF EXISTS gestionar_asignacion_promocion CASCADE;
DROP FUNCTION IF EXISTS get_elementos_busqueda CASCADE;
DROP FUNCTION IF EXISTS get_habitaciones_por_hotel CASCADE;
DROP FUNCTION IF EXISTS sp_obtener_detalle_promocion CASCADE;
DROP FUNCTION IF EXISTS fn_listar_promociones CASCADE;

-- ================================================================
-- 1. AJUSTES DE TABLA (Solo si no lo has hecho)
-- ================================================================
-- Asegura que Restaurante tenga la columna para la promoción (1:N)
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='restaurante' AND column_name='fk_promocion') THEN
        ALTER TABLE restaurante ADD COLUMN fk_promocion INTEGER REFERENCES promocion(prom_codigo);
    END IF;
END $$;

-- ================================================================
-- 2. CRUD BÁSICO (Registrar, Editar, Eliminar)
-- ================================================================

-- A. Registrar
CREATE OR REPLACE PROCEDURE registrar_promocion(
    _nombre VARCHAR, _descripcion VARCHAR, _fecha TIMESTAMP, _descuento NUMERIC
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO promocion (prom_nombre, prom_descripcion, prom_fecha_hora_vencimiento, prom_descuento)
    VALUES (_nombre, _descripcion, _fecha, _descuento);
END; $$;

-- B. Editar
CREATE OR REPLACE PROCEDURE editar_promocion(
    _id INT, _nombre VARCHAR, _descripcion VARCHAR, _fecha TIMESTAMP, _descuento NUMERIC
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE promocion SET 
        prom_nombre = _nombre, prom_descripcion = _descripcion,
        prom_fecha_hora_vencimiento = _fecha, prom_descuento = _descuento
    WHERE prom_codigo = _id;
END; $$;

-- C. Eliminar (Con limpieza de referencias para evitar error 500)
CREATE OR REPLACE PROCEDURE eliminar_promocion(_id INT) 
LANGUAGE plpgsql AS $$
BEGIN
    -- 1. Limpiar Tablas Intermedias (N:M)
    DELETE FROM ser_prom WHERE fk_prom_codigo = _id;  
    DELETE FROM tras_prom WHERE fk_prom_codigo = _id;
    DELETE FROM paq_prom WHERE fk_prom_codigo = _id;
    
    -- 2. Limpiar Tablas con FK directa (1:N)
    UPDATE habitacion SET fk_promocion = NULL WHERE fk_promocion = _id; 
    UPDATE restaurante SET fk_promocion = NULL WHERE fk_promocion = _id; -- ¡Importante!
    
    -- 3. Borrar la promoción
    DELETE FROM promocion WHERE prom_codigo = _id;
END; $$;


-- ================================================================
-- 3. MOTOR DE BÚSQUEDA Y BUILDER
-- ================================================================

-- A. Buscador Global (Sin filtro de estado)
CREATE OR REPLACE FUNCTION get_elementos_busqueda(_tipo VARCHAR)
RETURNS TABLE (
    elemento_id INT,
    nombre_elemento VARCHAR,
    tipo_detallado VARCHAR,
    costo NUMERIC,
    info_basica TEXT
) AS $$
BEGIN
    -- SERVICIOS
    IF _tipo = 'servicio' THEN
        RETURN QUERY SELECT s.ser_codigo, s.ser_nombre::VARCHAR, s.ser_tipo::VARCHAR, s.ser_costo, s.ser_descripcion::TEXT
        FROM servicio s;
        
    -- HOTELES (Devuelve Hoteles, no habitaciones)
    ELSIF _tipo = 'hotel' THEN
        RETURN QUERY 
        SELECT h.hot_codigo, h.hot_nombre::VARCHAR, 'Hotel'::VARCHAR, 0::NUMERIC, (h.hot_descripcion || ' (' || l.lug_nombre || ')')::TEXT
        FROM hotel h JOIN lugar l ON h.fk_lugar = l.lug_codigo;

    -- RESTAURANTES
    ELSIF _tipo = 'restaurante' THEN
        RETURN QUERY SELECT r.res_codigo, r.res_nombre::VARCHAR, 'Restaurante'::VARCHAR, 0::NUMERIC, r.res_descripcion::TEXT
        FROM restaurante r;

    -- TRASLADOS
    ELSIF _tipo = 'traslado' THEN
        RETURN QUERY SELECT t.tras_codigo, 
               (mt.med_tra_tipo || ': ' || ter_o.ter_nombre || ' -> ' || ter_d.ter_nombre)::VARCHAR, 
               r.rut_tipo::VARCHAR, r.rut_costo, TO_CHAR(t.tras_fecha_hora_inicio, 'DD/MM/YYYY HH24:MI')::TEXT
        FROM traslado t JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo JOIN terminal ter_o ON r.fk_terminal_origen = ter_o.ter_codigo JOIN terminal ter_d ON r.fk_terminal_destino = ter_d.ter_codigo JOIN medio_transporte mt ON t.fk_med_tra_codigo = mt.med_tra_codigo;

    -- PAQUETES
    ELSIF _tipo = 'paquete' THEN
        RETURN QUERY SELECT p.paq_tur_codigo, p.paq_tur_nombre::VARCHAR, 'Paquete'::VARCHAR, p.paq_tur_monto_total, ('Millas: ' || p.paq_tur_costo_en_millas)::TEXT FROM paquete_turistico p;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- B. Buscador de Habitaciones por Hotel (Drill-down)
CREATE OR REPLACE FUNCTION get_habitaciones_por_hotel(_hotel_id INT)
RETURNS TABLE (
    elemento_id INT,
    nombre_elemento VARCHAR,
    tipo_detallado VARCHAR,
    costo NUMERIC,
    info_basica TEXT
) AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        h.hab_num_hab, 
        ('Habitación ' || h.hab_descripcion)::VARCHAR, 
        'Habitación'::VARCHAR, 
        h.hab_costo_noche, 
        ('Capacidad: ' || h.hab_capacidad || ' pers.')::TEXT
    FROM habitacion h
    WHERE h.fk_hotel = _hotel_id;
END;
$$ LANGUAGE plpgsql;


-- ================================================================
-- 4. GESTOR DE ASIGNACIÓN (Logica Mixta UPDATE/INSERT)
-- ================================================================

CREATE OR REPLACE PROCEDURE gestionar_asignacion_promocion(
    _prom_id INT, _elem_id INT, _tipo VARCHAR, _accion VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    -- ACCIÓN: APLICAR
    IF _accion = 'aplicar' THEN
        IF _tipo = 'servicio' THEN INSERT INTO ser_prom (fk_ser_codigo, fk_prom_codigo) VALUES (_elem_id, _prom_id) ON CONFLICT DO NOTHING;
        
        -- Casos 1:N (UPDATE)
        ELSIF _tipo = 'habitacion' THEN UPDATE habitacion SET fk_promocion = _prom_id WHERE hab_num_hab = _elem_id;
        ELSIF _tipo = 'restaurante' THEN UPDATE restaurante SET fk_promocion = _prom_id WHERE res_codigo = _elem_id;
        
        -- Casos N:M (INSERT)
        ELSIF _tipo = 'traslado' THEN INSERT INTO tras_prom (fk_tras_codigo, fk_prom_codigo) VALUES (_elem_id, _prom_id) ON CONFLICT DO NOTHING;
        ELSIF _tipo = 'paquete' THEN INSERT INTO paq_prom (fk_paq_tur_codigo, fk_prom_codigo) VALUES (_elem_id, _prom_id) ON CONFLICT DO NOTHING;
        END IF;

    -- ACCIÓN: REMOVER
    ELSIF _accion = 'remover' THEN
        IF _tipo = 'servicio' THEN DELETE FROM ser_prom WHERE fk_ser_codigo = _elem_id AND fk_prom_codigo = _prom_id;
        
        -- Casos 1:N (NULLIFY)
        ELSIF _tipo = 'habitacion' THEN UPDATE habitacion SET fk_promocion = NULL WHERE hab_num_hab = _elem_id AND fk_promocion = _prom_id;
        ELSIF _tipo = 'restaurante' THEN UPDATE restaurante SET fk_promocion = NULL WHERE res_codigo = _elem_id AND fk_promocion = _prom_id;
        
        -- Casos N:M (DELETE)
        ELSIF _tipo = 'traslado' THEN DELETE FROM tras_prom WHERE fk_tras_codigo = _elem_id AND fk_prom_codigo = _prom_id;
        ELSIF _tipo = 'paquete' THEN DELETE FROM paq_prom WHERE fk_paq_tur_codigo = _elem_id AND fk_prom_codigo = _prom_id;
        END IF;
    END IF;
END; $$;


-- ================================================================
-- 5. VISUALIZADOR DE DETALLES (Botón Ojo)
-- ================================================================

CREATE OR REPLACE FUNCTION sp_obtener_detalle_promocion(_id INT)
RETURNS TABLE (detalle JSON) AS $$
BEGIN
    RETURN QUERY
    SELECT json_build_object(
        'info', (SELECT row_to_json(p) FROM (SELECT prom_nombre, prom_descuento FROM promocion WHERE prom_codigo = _id) p),
        
        'servicios', (
            SELECT COALESCE(json_agg(row_to_json(s)), '[]') FROM (
                SELECT ser.ser_nombre, ser.ser_tipo
                FROM ser_prom sp JOIN servicio ser ON sp.fk_ser_codigo = ser.ser_codigo
                WHERE sp.fk_prom_codigo = _id
            ) s
        ),
        
        'habitaciones', (
            SELECT COALESCE(json_agg(row_to_json(h)), '[]') FROM (
                SELECT hot.hot_nombre, hab.hab_descripcion, hab.hab_costo_noche
                FROM habitacion hab JOIN hotel hot ON hab.fk_hotel = hot.hot_codigo
                WHERE hab.fk_promocion = _id
            ) h
        ),

        'restaurantes', (
            SELECT COALESCE(json_agg(row_to_json(r)), '[]') FROM (
                SELECT res_nombre, res_descripcion
                FROM restaurante
                WHERE fk_promocion = _id
            ) r
        ),
        
        'traslados', (
            SELECT COALESCE(json_agg(row_to_json(t)), '[]') FROM (
                SELECT mt.med_tra_tipo, ter_o.ter_nombre as origen, ter_d.ter_nombre as destino
                FROM tras_prom tp
                JOIN traslado tr ON tp.fk_tras_codigo = tr.tras_codigo
                JOIN ruta r ON tr.fk_rut_codigo = r.rut_codigo
                JOIN terminal ter_o ON r.fk_terminal_origen = ter_o.ter_codigo
                JOIN terminal ter_d ON r.fk_terminal_destino = ter_d.ter_codigo
                JOIN medio_transporte mt ON tr.fk_med_tra_codigo = mt.med_tra_codigo
                WHERE tp.fk_prom_codigo = _id
            ) t
        ),

        'paquetes', (
            SELECT COALESCE(json_agg(row_to_json(pq)), '[]') FROM (
                SELECT p.paq_tur_nombre, p.paq_tur_monto_total
                FROM paq_prom pp JOIN paquete_turistico p ON pp.fk_paq_tur_codigo = p.paq_tur_codigo
                WHERE pp.fk_prom_codigo = _id
            ) pq
        )
    );
END;
$$ LANGUAGE plpgsql;


-- ================================================================
-- D. Obtener todas las promociones
-- ===============================================================
-- Creación de la función con NOMBRE NUEVO para evitar conflictos
CREATE OR REPLACE FUNCTION fn_listar_promociones()
RETURNS TABLE (
    prom_codigo INT,
    prom_nombre VARCHAR,
    prom_descripcion VARCHAR,
    prom_fecha_hora_vencimiento TIMESTAMP,
    prom_descuento NUMERIC
) AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        p.prom_codigo, 
        p.prom_nombre::VARCHAR, 
        p.prom_descripcion::VARCHAR, 
        p.prom_fecha_hora_vencimiento, 
        p.prom_descuento
    FROM promocion p
    ORDER BY p.prom_codigo DESC;
END;
$$ LANGUAGE plpgsql;


-- ================================================================
-- 1. FUNCIÓN: OBTENER CUOTAS PENDIENTES DEL CLIENTE
-- ================================================================


COMMIT;


CREATE OR REPLACE PROCEDURE sp_aplicar_mora_diaria(
    OUT o_cantidad_afectada INTEGER,
    OUT o_mensaje TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Actualizar cuotas vencidas que esten PENDIENTES y NO tengan mora aun
    WITH cuotas_vencidas AS (
        SELECT c.cuo_codigo
        FROM cuota c
        JOIN cuo_est ce ON c.cuo_codigo = ce.fk_cuo_codigo
        JOIN estado e ON ce.fk_est_codigo = e.est_codigo
        WHERE c.cuo_fecha_tope < CURRENT_DATE  -- Ya pasó la fecha
          AND c.cuo_tiene_mora = FALSE         -- No se le ha aplicado mora
          AND e.est_nombre = 'Pendiente'       -- Sigue pendiente
          AND ce.cuo_est_fecha_fin = 'infinity'::TIMESTAMP -- Es el estado actual
    )
    UPDATE cuota
    SET 
        cuo_monto = cuo_monto * 1.05, -- Sumar 5%
        cuo_tiene_mora = TRUE
    WHERE cuo_codigo IN (SELECT cuo_codigo FROM cuotas_vencidas);

    GET DIAGNOSTICS o_cantidad_afectada = ROW_COUNT;
    o_mensaje := 'Mora aplicada exitosamente a ' || o_cantidad_afectada || ' cuotas.';
END;
$$;


CREATE OR REPLACE FUNCTION sp_previsualizar_reembolso(i_compra_id INTEGER)
RETURNS TABLE (
    total_compra NUMERIC,
    total_pagado NUMERIC,
    penalizacion NUMERIC,
    monto_a_devolver NUMERIC,
    moneda_retorno VARCHAR,
    tasa_retorno NUMERIC,
    items_afectados JSON
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_compra NUMERIC;
    v_total_pagado NUMERIC;
    v_penalizacion NUMERIC;
    v_devolucion NUMERIC;
    v_items JSON;
    v_last_moneda VARCHAR;
    v_last_tasa NUMERIC;
BEGIN
    -- 1. Calcular Total Compra (Asumimos base USD)
    SELECT com_monto_total INTO v_total_compra FROM compra WHERE com_codigo = i_compra_id;
    
    -- 2. Calcular Total Pagado (NORMALIZADO A USD)
    -- Dividimos el monto pagado por la tasa histórica para llevar todo a Dólares
    SELECT COALESCE(SUM(p.pag_monto / tc.tas_cam_tasa_valor), 0) 
    INTO v_total_pagado 
    FROM pago p
    JOIN tasa_de_cambio tc ON p.fk_tasa_de_cambio = tc.tas_cam_codigo
    WHERE p.fk_compra = i_compra_id;

    -- 3. Obtener datos del ÚLTIMO PAGO (Para definir moneda de devolución)
    SELECT p.pag_denominacion, tc.tas_cam_tasa_valor
    INTO v_last_moneda, v_last_tasa
    FROM pago p
    JOIN tasa_de_cambio tc ON p.fk_tasa_de_cambio = tc.tas_cam_codigo
    WHERE p.fk_compra = i_compra_id 
    ORDER BY p.pag_fecha_hora DESC 
    LIMIT 1;

    -- Defaults si no hay pagos
    IF v_last_moneda IS NULL THEN 
        v_last_moneda := 'USD'; 
        v_last_tasa := 1; 
    END IF;

    -- 4. Aplicar Regla del 10% (Cálculos en USD)
    v_penalizacion := v_total_compra * 0.10;
    v_devolucion := v_total_pagado - v_penalizacion;
    
    IF v_devolucion < 0 THEN v_devolucion := 0; END IF;

    -- 5. Convertir montos visuales a la moneda de retorno para el Front
    v_total_compra := v_total_compra * v_last_tasa;
    v_total_pagado := v_total_pagado * v_last_tasa;
    v_penalizacion := v_penalizacion * v_last_tasa;
    v_devolucion   := v_devolucion   * v_last_tasa;

    -- 6. Recopilar Items
    SELECT JSON_AGG(t) INTO v_items FROM (
        SELECT 'Servicio' AS tipo, s.ser_nombre AS nombre, to_char(s.ser_fecha_hora_inicio, 'DD/MM/YYYY') AS fecha
        FROM detalle_reserva dr JOIN servicio s ON dr.fk_servicio = s.ser_codigo WHERE dr.fk_compra = i_compra_id
        UNION ALL
        SELECT 'Traslado' AS tipo, (origen.ter_nombre || ' -> ' || destino.ter_nombre), to_char(tr.tras_fecha_hora_inicio, 'DD/MM/YYYY')
        FROM detalle_reserva dr JOIN traslado tr ON dr.fk_traslado = tr.tras_codigo JOIN ruta r ON tr.fk_rut_codigo = r.rut_codigo JOIN terminal origen ON r.fk_terminal_origen = origen.ter_codigo JOIN terminal destino ON r.fk_terminal_destino = destino.ter_codigo WHERE dr.fk_compra = i_compra_id
        UNION ALL
        SELECT 'Paquete', pq.paq_tur_nombre, 'N/A' FROM detalle_reserva dr JOIN paquete_turistico pq ON dr.fk_paquete_turistico = pq.paq_tur_codigo WHERE dr.fk_compra = i_compra_id AND dr.fk_servicio IS NULL
    ) t;

    RETURN QUERY SELECT v_total_compra, v_total_pagado, v_penalizacion, v_devolucion, v_last_moneda, v_last_tasa, v_items;
END;
$$;

CREATE OR REPLACE FUNCTION sp_obtener_items_compra(_compra_id INTEGER)
RETURNS TABLE (
    tipo VARCHAR,
    nombre VARCHAR,
    fecha VARCHAR,
    detalle VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    -- 1. Servicios
    SELECT 
        'Servicio'::VARCHAR, 
        s.ser_nombre::VARCHAR, 
        TO_CHAR(s.ser_fecha_hora_inicio, 'DD/MM/YYYY HH12:MI AM')::VARCHAR,
        ('Tipo: ' || s.ser_tipo)::VARCHAR
    FROM detalle_reserva dr 
    JOIN servicio s ON dr.fk_servicio = s.ser_codigo 
    WHERE dr.fk_compra = _compra_id
    
    UNION ALL
    
    -- 2. Traslados
    SELECT 
        'Traslado'::VARCHAR, 
        (orig.ter_nombre || ' -> ' || dest.ter_nombre)::VARCHAR,
        TO_CHAR(tr.tras_fecha_hora_inicio, 'DD/MM/YYYY HH12:MI AM')::VARCHAR,
        ('Transporte: ' || mt.med_tra_tipo)::VARCHAR
    FROM detalle_reserva dr 
    JOIN traslado tr ON dr.fk_traslado = tr.tras_codigo 
    JOIN ruta r ON tr.fk_rut_codigo = r.rut_codigo 
    JOIN terminal orig ON r.fk_terminal_origen = orig.ter_codigo 
    JOIN terminal dest ON r.fk_terminal_destino = dest.ter_codigo
    JOIN medio_transporte mt ON tr.fk_med_tra_codigo = mt.med_tra_codigo
    WHERE dr.fk_compra = _compra_id
    
    UNION ALL
    
    -- 3. Paquetes
    SELECT 
        'Paquete'::VARCHAR, 
        pq.paq_tur_nombre::VARCHAR, 
        'N/A'::VARCHAR,
        ('Costo Millas: ' || pq.paq_tur_costo_en_millas)::VARCHAR
    FROM detalle_reserva dr 
    JOIN paquete_turistico pq ON dr.fk_paquete_turistico = pq.paq_tur_codigo 
    WHERE dr.fk_compra = _compra_id AND dr.fk_servicio IS NULL;
END;
$$ LANGUAGE plpgsql;


--STORE PROCEDURE PARA MOSTRAR LA WISHLIST FILTRADA POR TIPO DE PRODUCTO O TODOS BY MELANIE
CREATE OR REPLACE FUNCTION mostrar_wishlist_filtrada(p_usu_codigo INTEGER, p_filtro TEXT)
RETURNS TABLE (
    tipo_producto TEXT,
    codigo_producto INTEGER,
    nombre_producto TEXT,
    descripcion_producto TEXT,
    precio_original NUMERIC,
    fecha_inicio TIMESTAMP,
    porcentaje_descuento NUMERIC,
    precio_final NUMERIC,
    millas INTEGER -- <--- NUEVA COLUMNA
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        res.tipo_producto,
        res.codigo_producto,
        res.nombre_producto,
        res.descripcion_producto,
        res.precio_original,
        res.fecha_inicio,
        res.porcentaje_descuento,
        ROUND(res.precio_original - (res.precio_original * res.porcentaje_descuento / 100), 2) AS precio_final,
        res.millas -- <--- Retornamos las millas
    FROM (
        -- Bloque PAQUETES
        SELECT 
            'PAQUETE'::TEXT AS tipo_producto, 
            p.paq_tur_codigo AS codigo_producto, 
            p.paq_tur_nombre::TEXT AS nombre_producto, 
            COALESCE(p.paq_tur_descripcion, 'Sin descripción')::TEXT AS descripcion_producto, 
            COALESCE(p.paq_tur_monto_total, 0)::NUMERIC AS precio_original,
            -- Fecha
            (SELECT MIN(inicio) FROM (
                SELECT s.ser_fecha_hora_inicio AS inicio FROM paq_ser ps JOIN servicio s ON ps.fk_ser_codigo = s.ser_codigo WHERE ps.fk_paq_tur_codigo = p.paq_tur_codigo
                UNION ALL
                SELECT t.tras_fecha_hora_inicio AS inicio FROM paq_tras pt JOIN traslado t ON pt.fk_tras_codigo = t.tras_codigo WHERE pt.fk_paq_tur_codigo = p.paq_tur_codigo
            ) as fechas) AS fecha_inicio,
            -- Descuento
            COALESCE((SELECT MAX(prom.prom_descuento) FROM paq_prom pp JOIN promocion prom ON pp.fk_prom_codigo = prom.prom_codigo WHERE pp.fk_paq_tur_codigo = p.paq_tur_codigo AND prom.prom_fecha_hora_vencimiento > NOW()), 0)::NUMERIC AS porcentaje_descuento,
            -- Millas
            COALESCE(p.paq_tur_costo_en_millas, 0) AS millas 
        FROM lista_deseos ld
        JOIN paquete_turistico p ON ld.fk_paquete_turistico = p.paq_tur_codigo
        WHERE ld.fk_usuario = p_usu_codigo

        UNION ALL

        -- Bloque SERVICIOS
        SELECT 
            'SERVICIO'::TEXT, 
            s.ser_codigo, 
            s.ser_nombre::TEXT, 
            COALESCE(s.ser_descripcion, 'Sin descripción')::TEXT, 
            COALESCE(s.ser_costo, 0)::NUMERIC,
            s.ser_fecha_hora_inicio,
            COALESCE((SELECT MAX(prom.prom_descuento) FROM ser_prom sp JOIN promocion prom ON sp.fk_prom_codigo = prom.prom_codigo WHERE sp.fk_ser_codigo = s.ser_codigo AND prom.prom_fecha_hora_vencimiento > NOW()), 0)::NUMERIC,
            -- Millas
            COALESCE(s.ser_millas_otorgadas, 0)
        FROM lista_deseos ld
        JOIN servicio s ON ld.fk_servicio = s.ser_codigo
        WHERE ld.fk_usuario = p_usu_codigo

        UNION ALL

        -- Bloque TRASLADOS
        SELECT 
            'TRASLADO'::TEXT, 
            t.tras_codigo, 
            (COALESCE(ter_o.ter_nombre, 'Origen') || ' -> ' || COALESCE(ter_d.ter_nombre, 'Destino'))::TEXT, 
            (COALESCE(r.rut_tipo, 'Transporte') || ' | ' || TO_CHAR(t.tras_fecha_hora_inicio, 'DD/MM HH24:MI'))::TEXT,
            COALESCE(r.rut_costo, 0)::NUMERIC,
            t.tras_fecha_hora_inicio,
            COALESCE((SELECT MAX(prom.prom_descuento) FROM tras_prom tp JOIN promocion prom ON tp.fk_prom_codigo = prom.prom_codigo WHERE tp.fk_tras_codigo = t.tras_codigo AND prom.prom_fecha_hora_vencimiento > NOW()), 0)::NUMERIC,
            -- Millas (Vienen de la RUTA)
            COALESCE(r.rut_millas_otorgadas, 0)
        FROM lista_deseos ld
        JOIN traslado t ON ld.fk_traslado = t.tras_codigo
        LEFT JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
        LEFT JOIN terminal ter_o ON r.fk_terminal_origen = ter_o.ter_codigo
        LEFT JOIN terminal ter_d ON r.fk_terminal_destino = ter_d.ter_codigo
        WHERE ld.fk_usuario = p_usu_codigo
    ) AS res
    WHERE UPPER(TRIM(p_filtro)) = 'TODO' OR UPPER(TRIM(res.tipo_producto)) = UPPER(TRIM(p_filtro));
END;
$$;

--STORE PROCEDURE PARA ELIMINAR DE WISHLIST BY MELANIE
CREATE OR REPLACE FUNCTION sp_eliminar_de_wishlist(
    p_usuario_id INTEGER,
    p_producto_id INTEGER,
    p_tipo_producto VARCHAR
)
RETURNS VOID AS $$
BEGIN
    IF p_tipo_producto = 'SERVICIO' THEN
        DELETE FROM lista_deseos 
        WHERE fk_usuario = p_usuario_id AND fk_servicio = p_producto_id;

    ELSIF p_tipo_producto = 'TRASLADO' THEN
        DELETE FROM lista_deseos 
        WHERE fk_usuario = p_usuario_id AND fk_traslado = p_producto_id;

    ELSIF p_tipo_producto = 'PAQUETE' THEN
        DELETE FROM lista_deseos 
        WHERE fk_usuario = p_usuario_id AND fk_paquete_turistico = p_producto_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

--STORE PROCEDURE PARA AGREGAR A WISHLIST BY MELANIE
CREATE OR REPLACE PROCEDURE sp_agregar_a_wishlist(
    p_usu_codigo INTEGER,
    p_producto_id INTEGER,
    p_tipo_producto VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_existe BOOLEAN;
    v_fecha_inicio TIMESTAMP;
BEGIN
    -- 1. VALIDAR DUPLICADOS
    SELECT EXISTS (
        SELECT 1 FROM lista_deseos ld
        WHERE ld.fk_usuario = p_usu_codigo
        AND (
            (UPPER(p_tipo_producto) = 'SERVICIO' AND ld.fk_servicio = p_producto_id) OR
            (UPPER(p_tipo_producto) = 'TRASLADO' AND ld.fk_traslado = p_producto_id) OR
            (UPPER(p_tipo_producto) = 'PAQUETE' AND ld.fk_paquete_turistico = p_producto_id)
        )
    ) INTO v_existe;

    IF v_existe THEN
        -- Usamos RAISE EXCEPTION para que Node.js capture el error correctamente
        RAISE EXCEPTION 'Este elemento ya se encuentra en tu lista de deseos.';
    END IF;

    -- 2. VALIDAR FECHAS
    v_fecha_inicio := NULL;

    IF UPPER(p_tipo_producto) = 'SERVICIO' THEN
        SELECT ser_fecha_hora_inicio INTO v_fecha_inicio FROM servicio WHERE ser_codigo = p_producto_id;
    ELSIF UPPER(p_tipo_producto) = 'TRASLADO' THEN
        SELECT tras_fecha_hora_inicio INTO v_fecha_inicio FROM traslado WHERE tras_codigo = p_producto_id;
    ELSIF UPPER(p_tipo_producto) = 'PAQUETE' THEN
        SELECT MIN(fecha_inicio) INTO v_fecha_inicio
        FROM (
            SELECT s.ser_fecha_hora_inicio AS fecha_inicio FROM paq_ser ps JOIN servicio s ON ps.fk_ser_codigo = s.ser_codigo WHERE ps.fk_paq_tur_codigo = p_producto_id
            UNION ALL
            SELECT t.tras_fecha_hora_inicio AS fecha_inicio FROM paq_tras pt JOIN traslado t ON pt.fk_tras_codigo = t.tras_codigo WHERE pt.fk_paq_tur_codigo = p_producto_id
        ) as comp;
    END IF;

    IF v_fecha_inicio IS NOT NULL AND v_fecha_inicio < NOW() THEN
        RAISE EXCEPTION 'No puedes agregar actividades cuya fecha ya ha pasado.';
    END IF;

    -- 3. INSERTAR CON NULOS EXPLÍCITOS
    IF UPPER(p_tipo_producto) = 'SERVICIO' THEN
        INSERT INTO lista_deseos (fk_usuario, fk_servicio, fk_paquete_turistico, fk_traslado) 
        VALUES (p_usu_codigo, p_producto_id, NULL, NULL);
        
    ELSIF UPPER(p_tipo_producto) = 'TRASLADO' THEN
        INSERT INTO lista_deseos (fk_usuario, fk_traslado, fk_servicio, fk_paquete_turistico) 
        VALUES (p_usu_codigo, p_producto_id, NULL, NULL);
        
    ELSIF UPPER(p_tipo_producto) = 'PAQUETE' THEN
        INSERT INTO lista_deseos (fk_usuario, fk_paquete_turistico, fk_servicio, fk_traslado) 
        VALUES (p_usu_codigo, p_producto_id, NULL, NULL);
    ELSE
        RAISE EXCEPTION 'Tipo de producto no válido: %', p_tipo_producto;
    END IF;
    
    -- Si llegamos aquí, todo salió bien. No necesitamos retornar variables OUT, 
    -- el commit implícito del driver se encargará.
END;
$$;

-- 1. REGISTRAR RESEÑA (Usa el ID compuesto del ticket)
DROP PROCEDURE IF EXISTS sp_registrar_resena; -- Borramos el viejo para evitar confusiones

CREATE OR REPLACE FUNCTION sp_registrar_resena(
    p_ticket_id VARCHAR, 
    p_calificacion INTEGER,
    p_descripcion VARCHAR
)
RETURNS JSON -- Retornamos un objeto JSON directo
LANGUAGE plpgsql
AS $$
DECLARE
    v_compra_id INTEGER;
    v_detalle_id INTEGER;
    v_estado_actual VARCHAR;
    v_existe BOOLEAN;
BEGIN
    -- 1. Validar formato
    IF p_ticket_id IS NULL OR SPLIT_PART(p_ticket_id, '-', 3) = '' THEN
        RETURN json_build_object('status', 400, 'message', 'ID de ticket inválido (Formato incorrecto)');
    END IF;

    -- 2. Desarmar ID
    BEGIN
        v_compra_id := SPLIT_PART(p_ticket_id, '-', 2)::INTEGER;
        v_detalle_id := SPLIT_PART(p_ticket_id, '-', 3)::INTEGER;
    EXCEPTION WHEN OTHERS THEN
        RETURN json_build_object('status', 400, 'message', 'Error al procesar ID del ticket');
    END;

    -- 3. Validar Estado del Ticket
    SELECT det_res_estado INTO v_estado_actual
    FROM detalle_reserva
    WHERE fk_compra = v_compra_id AND det_res_codigo = v_detalle_id;

    IF v_estado_actual IS NULL THEN
        RETURN json_build_object('status', 404, 'message', 'Ticket no encontrado en BD');
    END IF;

    IF v_estado_actual != 'Completada' THEN
        RETURN json_build_object('status', 400, 'message', 'El ticket no está marcado como Completado');
    END IF;

    -- 4. Validar Duplicados
    SELECT EXISTS (
        SELECT 1 FROM resena 
        WHERE fk_detalle_reserva = v_compra_id 
          AND fk_detalle_reserva_2 = v_detalle_id
    ) INTO v_existe;

    IF v_existe THEN
        RETURN json_build_object('status', 409, 'message', 'Ya existe una reseña para este ticket');
    END IF;

    -- 5. Insertar
    -- NOTA IMPORTANTE: Verifica si tu columna en la BD se llama 'res_fecha_hora_creacion' (con T) 
    -- o 'res_fecha_hora_creacion' (con R). Aquí uso la versión con 'T' según tu create.sql previo.
    INSERT INTO resena (
        res_calificacion_numerica, 
        res_descripcion, 
        res_fecha_hora_creacion, -- <--- CAMBIA ESTO SI CORREGISTE EL TYPO EN LA TABLA
        fk_detalle_reserva,      
        fk_detalle_reserva_2     
    ) VALUES (
        p_calificacion,
        p_descripcion,
        NOW(),
        v_compra_id,
        v_detalle_id
    );

    RETURN json_build_object('status', 200, 'message', 'Reseña guardada exitosamente');

EXCEPTION WHEN OTHERS THEN
    -- Aquí capturamos el error real de SQL y lo enviamos al front
    RETURN json_build_object('status', 500, 'message', 'Error SQL: ' || SQLERRM);
END;
$$;

-- 2. VER RESEÑAS DE UN PRODUCTO (Público)
-- Sirve para Servicios, Traslados y Paquetes
CREATE OR REPLACE FUNCTION sp_obtener_resenas_producto(
    p_producto_id INTEGER,
    p_tipo_producto VARCHAR -- 'SERVICIO', 'TRASLADO', 'PAQUETE'
)
RETURNS TABLE (
    calificacion INTEGER,
    comentario VARCHAR,
    fecha TIMESTAMP,
    autor VARCHAR,
    viajero_nombre VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.res_calificacion_numerica,
        r.res_descripcion,
        r.res_fecha_hora_creacion,
        u.usu_nombre_usuario::VARCHAR, -- Autor (quien compró)
        (v.via_prim_nombre || ' ' || v.via_prim_apellido)::VARCHAR -- Viajero (quien usó el servicio)
    FROM resena r
    JOIN detalle_reserva dr ON r.fk_detalle_reserva = dr.fk_compra AND r.fk_detalle_reserva_2 = dr.det_res_codigo
    JOIN compra c ON dr.fk_compra = c.com_codigo
    JOIN usuario u ON c.fk_usuario = u.usu_codigo
    JOIN viajero v ON dr.fk_viajero_codigo = v.via_codigo
    WHERE 
        (UPPER(p_tipo_producto) = 'SERVICIO' AND dr.fk_servicio = p_producto_id) OR
        (UPPER(p_tipo_producto) = 'TRASLADO' AND dr.fk_traslado = p_producto_id) OR
        (UPPER(p_tipo_producto) = 'PAQUETE' AND dr.fk_paquete_turistico = p_producto_id)
    ORDER BY r.res_fecha_hora_creacion DESC;
END;
$$;

-- 3. VER MIS RESEÑAS (Dashboard Cliente)
CREATE OR REPLACE FUNCTION sp_obtener_mis_resenas(p_usuario_id INTEGER)
RETURNS TABLE (
    res_id INTEGER,
    calificacion INTEGER,
    comentario VARCHAR,
    fecha TIMESTAMP,
    producto_nombre VARCHAR,
    tipo_producto VARCHAR,
    viajero VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.res_codigo,
        r.res_calificacion_numerica,
        r.res_descripcion,
        r.res_fecha_hora_creacion,
        -- Determinar nombre del producto
        COALESCE(s.ser_nombre, pq.paq_tur_nombre, (t_orig.ter_nombre || ' -> ' || t_dest.ter_nombre))::VARCHAR,
        -- Determinar tipo
        CASE 
            WHEN dr.fk_servicio IS NOT NULL THEN 'Servicio'
            WHEN dr.fk_paquete_turistico IS NOT NULL THEN 'Paquete'
            ELSE 'Traslado'
        END::VARCHAR,
        (v.via_prim_nombre || ' ' || v.via_prim_apellido)::VARCHAR
    FROM resena r
    JOIN detalle_reserva dr ON r.fk_detalle_reserva = dr.fk_compra AND r.fk_detalle_reserva_2 = dr.det_res_codigo
    JOIN compra c ON dr.fk_compra = c.com_codigo
    JOIN viajero v ON dr.fk_viajero_codigo = v.via_codigo
    -- Joins para nombres
    LEFT JOIN servicio s ON dr.fk_servicio = s.ser_codigo
    LEFT JOIN paquete_turistico pq ON dr.fk_paquete_turistico = pq.paq_tur_codigo
    LEFT JOIN traslado tr ON dr.fk_traslado = tr.tras_codigo
    LEFT JOIN ruta rut ON tr.fk_rut_codigo = rut.rut_codigo
    LEFT JOIN terminal t_orig ON rut.fk_terminal_origen = t_orig.ter_codigo
    LEFT JOIN terminal t_dest ON rut.fk_terminal_destino = t_dest.ter_codigo
    
    WHERE c.fk_usuario = p_usuario_id
    ORDER BY r.res_fecha_hora_creacion DESC;
END;
$$;

CREATE OR REPLACE FUNCTION sp_obtener_resenas_producto(
    p_producto_id INTEGER,
    p_tipo_producto VARCHAR -- 'SERVICIO', 'TRASLADO', 'PAQUETE'
)
RETURNS TABLE (
    calificacion INTEGER,
    comentario VARCHAR,
    fecha TIMESTAMP,
    autor VARCHAR,
    viajero_nombre VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.res_calificacion_numerica,
        r.res_descripcion,
        r.res_fecha_hora_creacion,
        u.usu_nombre_usuario::VARCHAR, -- Autor (quien compró)
        (v.via_prim_nombre || ' ' || v.via_prim_apellido)::VARCHAR -- Viajero (quien usó el servicio)
    FROM resena r
    JOIN detalle_reserva dr ON r.fk_detalle_reserva = dr.fk_compra AND r.fk_detalle_reserva_2 = dr.det_res_codigo
    JOIN compra c ON dr.fk_compra = c.com_codigo
    JOIN usuario u ON c.fk_usuario = u.usu_codigo
    JOIN viajero v ON dr.fk_viajero_codigo = v.via_codigo
    WHERE 
        (UPPER(p_tipo_producto) = 'SERVICIO' AND dr.fk_servicio = p_producto_id) OR
        (UPPER(p_tipo_producto) = 'TRASLADO' AND dr.fk_traslado = p_producto_id) OR
        (UPPER(p_tipo_producto) = 'PAQUETE' AND dr.fk_paquete_turistico = p_producto_id)
    ORDER BY r.res_fecha_hora_creacion DESC;
END;
$$;

-- 3. VER MIS RESEÑAS (Dashboard Cliente)
CREATE OR REPLACE FUNCTION sp_obtener_mis_resenas(p_usuario_id INTEGER)
RETURNS TABLE (
    res_id INTEGER,
    calificacion INTEGER,
    comentario VARCHAR,
    fecha TIMESTAMP,
    producto_nombre VARCHAR,
    tipo_producto VARCHAR,
    viajero VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.res_codigo,
        r.res_calificacion_numerica,
        r.res_descripcion,
        r.res_fecha_hora_creacion,
        -- Determinar nombre del producto
        COALESCE(s.ser_nombre, pq.paq_tur_nombre, (t_orig.ter_nombre || ' -> ' || t_dest.ter_nombre))::VARCHAR,
        -- Determinar tipo
        CASE 
            WHEN dr.fk_servicio IS NOT NULL THEN 'Servicio'
            WHEN dr.fk_paquete_turistico IS NOT NULL THEN 'Paquete'
            ELSE 'Traslado'
        END::VARCHAR,
        (v.via_prim_nombre || ' ' || v.via_prim_apellido)::VARCHAR
    FROM resena r
    JOIN detalle_reserva dr ON r.fk_detalle_reserva = dr.fk_compra AND r.fk_detalle_reserva_2 = dr.det_res_codigo
    JOIN compra c ON dr.fk_compra = c.com_codigo
    JOIN viajero v ON dr.fk_viajero_codigo = v.via_codigo
    -- Joins para nombres
    LEFT JOIN servicio s ON dr.fk_servicio = s.ser_codigo
    LEFT JOIN paquete_turistico pq ON dr.fk_paquete_turistico = pq.paq_tur_codigo
    LEFT JOIN traslado tr ON dr.fk_traslado = tr.tras_codigo
    LEFT JOIN ruta rut ON tr.fk_rut_codigo = rut.rut_codigo
    LEFT JOIN terminal t_orig ON rut.fk_terminal_origen = t_orig.ter_codigo
    LEFT JOIN terminal t_dest ON rut.fk_terminal_destino = t_dest.ter_codigo
    
    WHERE c.fk_usuario = p_usuario_id
    ORDER BY r.res_fecha_hora_creacion DESC;
END;
$$;
