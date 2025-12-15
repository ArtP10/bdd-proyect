Begin;

-- =============================================
-- 1. PROCEDIMIENTO: CREAR VIAJERO
-- =============================================
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

-- =============================================
-- 2. PROCEDIMIENTO: CREAR/ACTUALIZAR ESTADO CIVIL
-- =============================================
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

-- =============================================
-- 3. PROCEDIMIENTO: ELIMINAR HISTORIAL CIVIL
-- =============================================
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

-- =============================================
-- 4. PROCEDIMIENTO: LOGIN DE USUARIO
-- =============================================
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
    INOUT o_usu_correo varchar DEFAULT NULL 
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_contrasena_guardada varchar;
    v_rol_nombre varchar;
    v_rol_codigo Integer;
BEGIN
    -- 1. Buscar Usuario y Rol
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

-- =============================================
-- 5. PROCEDIMIENTO: ELIMINAR PAQUETE TURÍSTICO
-- =============================================
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

-- =============================================
-- 6. PROCEDIMIENTO: AGREGAR DOCUMENTO VIAJERO
-- =============================================
CREATE OR REPLACE PROCEDURE sp_agregar_documento_viajero(
    IN i_doc_fecha_emision DATE,
    IN i_doc_fecha_vencimiento DATE,
    IN i_doc_numero VARCHAR,
    IN i_doc_tipo VARCHAR,
    IN i_nac_nombre VARCHAR, 
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

-- =============================================
-- 7. PROCEDIMIENTO: CREAR PAQUETE TURÍSTICO
-- =============================================
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

-- =============================================
-- 8. PROCEDIMIENTO: ELIMINAR AVIÓN
-- =============================================
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

-- =============================================
-- 9. PROCEDIMIENTO: ELIMINAR RUTA
-- =============================================
CREATE OR REPLACE PROCEDURE sp_eliminar_ruta(
    IN i_usu_codigo INTEGER,
    IN i_rut_codigo INTEGER,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    -- 1. Validar Permisos
    IF NOT EXISTS (
        SELECT 1 FROM usuario u JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'eliminar_recursos'
    ) THEN
        o_status_code := 403; o_mensaje := 'No tiene permisos para eliminar rutas.'; RETURN;
    END IF;

    -- 2. Validar Traslados Activos o Futuros
    IF EXISTS (
        SELECT 1 FROM traslado 
        WHERE fk_rut_codigo = i_rut_codigo 
        AND tras_fecha_hora_fin >= CURRENT_TIMESTAMP
    ) THEN
        o_status_code := 409; -- Conflict
        o_mensaje := 'No se puede eliminar: Hay vuelos activos o programados en esta ruta.';
        RETURN;
    END IF;

    -- 3. Eliminar (Si hay historial antiguo se puede bloquear o hacer soft-delete, aqui haremos hard delete si no hay activos)
    
    IF EXISTS (SELECT 1 FROM traslado WHERE fk_rut_codigo = i_rut_codigo) THEN
         o_status_code := 409; 
         o_mensaje := 'No se puede eliminar: Esta ruta tiene historial de vuelos. Contacte soporte.';
         RETURN;
    END IF;

    DELETE FROM ruta WHERE rut_codigo = i_rut_codigo;
    
    o_status_code := 200;
    o_mensaje := 'Ruta eliminada correctamente.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500; o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;

-- =============================================
-- 10. PROCEDIMIENTO: ELIMINAR DOCUMENTO
-- =============================================
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


-- =============================================
-- 11. PROCEDIMIENTO: MODIFICAR PAQUETE TURÍSTICO
-- =============================================
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

-- =============================================
-- 12. PROCEDIMIENTO: OBTENER PROVEEDORES
-- =============================================
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

-- =============================================
-- 13. PROCEDIMIENTO: OBTENER ESTADOS CIVILES
-- =============================================
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

-- =============================================
-- 14. PROCEDIMIENTO: OBTENER LUGARES DE OPERACIÓN
-- =============================================
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

-- =============================================
-- 15. PROCEDIMIENTO: MODIFICAR TRASLADO
-- =============================================
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
    v_pro_id INTEGER;
    v_rut_pro_id INTEGER;
    v_med_tra_id INTEGER;
BEGIN
    -- A. Validar Privilegio
    IF NOT EXISTS (
        SELECT 1 FROM usuario u JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'modificar_recursos'
    ) THEN
        o_status_code := 403; o_mensaje := 'No tiene permisos para modificar traslados.'; RETURN;
    END IF;

    -- B. VALIDACIONES DE FECHA (NUEVO)
    -- 1. No se puede reprogramar al pasado
    IF i_nueva_fecha_inicio < CURRENT_TIMESTAMP THEN
        o_status_code := 400; 
        o_mensaje := 'Error: No se puede reprogramar un vuelo a una fecha pasada.';
        RETURN;
    END IF;

    -- 2. Coherencia
    IF i_nueva_fecha_fin <= i_nueva_fecha_inicio THEN
        o_status_code := 400; 
        o_mensaje := 'Error: La fecha de llegada debe ser posterior a la salida.';
        RETURN;
    END IF;

    -- C. Validar Propiedad
    SELECT p.pro_codigo INTO v_pro_id
    FROM proveedor p JOIN usuario u ON p.fk_usu_codigo = u.usu_codigo
    WHERE u.usu_codigo = i_usu_codigo;

    SELECT r.fk_pro_codigo, t.fk_med_tra_codigo INTO v_rut_pro_id, v_med_tra_id
    FROM traslado t JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
    WHERE t.tras_codigo = i_tras_codigo;

    IF v_pro_id <> v_rut_pro_id OR v_rut_pro_id IS NULL THEN
        o_status_code := 403; o_mensaje := 'No puede modificar un traslado que no le pertenece.'; RETURN;
    END IF;

    -- D. Validar Disponibilidad (Solapamiento al reprogramar)
    -- Debemos excluir el MISMO traslado que estamos editando (AND tras_codigo <> i_tras_codigo)
    IF EXISTS (
        SELECT 1 FROM traslado 
        WHERE fk_med_tra_codigo = v_med_tra_id
        AND tras_codigo <> i_tras_codigo -- ¡Importante! No chocar consigo mismo
        AND (
            (tras_fecha_hora_inicio BETWEEN i_nueva_fecha_inicio AND i_nueva_fecha_fin) OR
            (tras_fecha_hora_fin BETWEEN i_nueva_fecha_inicio AND i_nueva_fecha_fin) OR
            (i_nueva_fecha_inicio BETWEEN tras_fecha_hora_inicio AND tras_fecha_hora_fin)
        )
    ) THEN
        o_status_code := 409; 
        o_mensaje := 'El nuevo horario entra en conflicto con otro vuelo de este avión.'; 
        RETURN;
    END IF;

    -- E. Actualizar
    UPDATE traslado
    SET tras_fecha_hora_inicio = i_nueva_fecha_inicio,
        tras_fecha_hora_fin = i_nueva_fecha_fin
    WHERE tras_codigo = i_tras_codigo;

    o_status_code := 200;
    o_mensaje := 'Horario del traslado actualizado.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500; o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;

-- =============================================
-- 16. PROCEDIMIENTO: OBTENER DETALLE VIAJERO
-- =============================================
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

-- =============================================
-- 17. PROCEDIMIENTO: OBTENER RUTAS PROVEEDOR
-- =============================================
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
    -- 1. Obtener ID del proveedor
    SELECT prov_codigo INTO v_prov_id 
    FROM proveedor 
    WHERE fk_usu_codigo = i_usu_codigo;

    -- 2. Abrir Cursor con la consulta corregida
    OPEN o_cursor FOR
    SELECT 
        r.rut_codigo,
        r.rut_costo,
        r.rut_millas_otorgadas,
        r.rut_tipo,          -- Agregado (Necesario para el icono del Front)
        r.rut_descripcion,   -- Agregado (Necesario para el badge del Front)
        
        -- Concatenación de nombres para mostrar "Maiquetía (La Guaira)"
        (to1.ter_nombre || ' (' || l1.lug_nombre || ')') as origen_nombre,
        (td1.ter_nombre || ' (' || l2.lug_nombre || ')') as destino_nombre
        
    FROM ruta r
    JOIN terminal to1 ON r.fk_terminal_origen = to1.ter_codigo
    JOIN terminal td1 ON r.fk_terminal_destino = td1.ter_codigo
    
    -- CORRECCIÓN AQUÍ: En tu tabla terminal la FK se llama 'fk_lugar', no 'fk_lug_codigo'
    JOIN lugar l1 ON to1.fk_lugar = l1.lug_codigo 
    JOIN lugar l2 ON td1.fk_lugar = l2.lug_codigo 
    
    WHERE r.fk_prov_codigo = v_prov_id
    ORDER BY r.rut_codigo DESC;

    o_status_code := 200; 
    o_mensaje := 'Rutas obtenidas correctamente.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500; 
    o_mensaje := 'Error BD: ' || SQLERRM;
END; 
$$;

-- =============================================
-- 18. PROCEDIMIENTO: OBTENER NACIONALIDADES
-- =============================================
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

-- =============================================
-- 19. PROCEDIMIENTO: MODIFICAR AVIÓN
-- =============================================
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

-- =============================================
-- 20. PROCEDIMIENTO: OBTENER FLOTA PROVEEDOR
-- =============================================
CREATE OR REPLACE PROCEDURE sp_obtener_flota_proveedor(
    IN i_prov_codigo INTEGER, 
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
    WHERE mt.fk_prov_codigo = i_prov_codigo 
    ORDER BY mt.med_tra_codigo DESC;

    o_status_code := 200;
    o_mensaje := 'Flota obtenida.';
EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END;
$$;


-- =============================================
-- 21. PROCEDIMIENTO: REGISTRAR AVIÓN
-- =============================================
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
$$;

-- =============================================
-- 22. PROCEDIMIENTO: REGISTRAR RUTA
-- =============================================
CREATE OR REPLACE PROCEDURE sp_registrar_ruta(
    IN i_usu_codigo INTEGER,
    IN i_costo NUMERIC,
    IN i_millas NUMERIC,
    IN i_fk_origen INTEGER,
    IN i_fk_destino INTEGER,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_pro_id INTEGER;
    v_pro_tipo VARCHAR;
    v_tipo_origen VARCHAR;
    v_tipo_destino VARCHAR;
BEGIN
    -- A. Validar Privilegio 'crear_recursos'
    IF NOT EXISTS (
        SELECT 1 FROM usuario u JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'crear_recursos'
    ) THEN
        o_status_code := 403; o_mensaje := 'No tiene permisos para crear rutas.'; RETURN;
    END IF;

    -- B. Obtener Datos del Proveedor
    SELECT pro_codigo, pro_tipo INTO v_pro_id, v_pro_tipo
    FROM proveedor WHERE fk_usu_codigo = i_usu_codigo;

    -- C. Validar Origen != Destino
    IF i_fk_origen = i_fk_destino THEN
        o_status_code := 400; o_mensaje := 'El origen y el destino no pueden ser iguales.'; RETURN;
    END IF;

    -- D. Obtener Tipos de las Terminales seleccionadas
    SELECT ter_tipo INTO v_tipo_origen FROM terminal WHERE ter_codigo = i_fk_origen;
    SELECT ter_tipo INTO v_tipo_destino FROM terminal WHERE ter_codigo = i_fk_destino;

    -- E. VALIDACIÓN DE CONSISTENCIA (El Constraint Lógico)
    IF v_pro_tipo = 'Aerolinea' AND (v_tipo_origen <> 'Aeropuerto' OR v_tipo_destino <> 'Aeropuerto') THEN
        o_status_code := 409; o_mensaje := 'Una Aerolínea solo puede crear rutas entre Aeropuertos.'; RETURN;
    END IF;

    IF v_pro_tipo = 'Maritimo' AND (v_tipo_origen <> 'Puerto' OR v_tipo_destino <> 'Puerto') THEN
        o_status_code := 409; o_mensaje := 'Un proveedor Marítimo solo opera entre Puertos.'; RETURN;
    END IF;

    IF v_pro_tipo = 'Terrestre' AND (v_tipo_origen NOT IN ('Terminal Terrestre', 'Estacion') OR v_tipo_destino NOT IN ('Terminal Terrestre', 'Estacion')) THEN
        o_status_code := 409; o_mensaje := 'Proveedor Terrestre solo opera en Terminales o Estaciones.'; RETURN;
    END IF;

    -- F. Insertar
    INSERT INTO ruta (rut_costo, rut_millas_otorgadas, fk_terminal_origen, fk_terminal_destino, fk_pro_codigo)
    VALUES (i_costo, i_millas, i_fk_origen, i_fk_destino, v_pro_id);

    o_status_code := 201;
    o_mensaje := 'Ruta creada exitosamente.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500; o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;

-- =============================================
-- 23. PROCEDIMIENTO: REGISTRAR PROVEEDOR
-- =============================================
CREATE OR REPLACE PROCEDURE sp_registrar_proveedor(
    IN i_admin_id INTEGER,
    IN i_prov_nombre VARCHAR,
    IN i_prov_fecha_creacion DATE, 
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

-- =============================================
-- 24. PROCEDIMIENTO: REGISTRAR TRASLADO
-- =============================================
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
    v_pro_id INTEGER;
BEGIN
    -- A. Validar Privilegio
    IF NOT EXISTS (
        SELECT 1 FROM usuario u JOIN rol_privilegio rp ON u.fk_rol_codigo = rp.fk_rol_codigo
        JOIN privilegio p ON rp.fk_pri_codigo = p.pri_codigo
        WHERE u.usu_codigo = i_usu_codigo AND p.pri_nombre = 'crear_recursos'
    ) THEN
        o_status_code := 403; o_mensaje := 'No tiene permisos para crear traslados.'; RETURN;
    END IF;

    -- B. VALIDACIONES DE FECHA (NUEVO)
    -- 1. No se puede viajar al pasado
    IF i_fecha_inicio < CURRENT_TIMESTAMP THEN
        o_status_code := 400; -- Bad Request
        o_mensaje := 'Error: La fecha de salida no puede ser en el pasado.';
        RETURN;
    END IF;

    -- 2. Coherencia temporal
    IF i_fecha_fin <= i_fecha_inicio THEN
        o_status_code := 400; 
        o_mensaje := 'Error: La fecha de llegada debe ser posterior a la salida.';
        RETURN;
    END IF;

    -- C. Obtener ID del Proveedor
    SELECT p.pro_codigo INTO v_pro_id
    FROM proveedor p JOIN usuario u ON p.fk_usu_codigo = u.usu_codigo
    WHERE u.usu_codigo = i_usu_codigo;

    IF v_pro_id IS NULL THEN
        o_status_code := 404; o_mensaje := 'Usuario no es proveedor.'; RETURN;
    END IF;

    -- D. Validar Propiedad (Ruta y Transporte)
    IF NOT EXISTS (SELECT 1 FROM ruta WHERE rut_codigo = i_rut_codigo AND fk_pro_codigo = v_pro_id) THEN
        o_status_code := 409; o_mensaje := 'Error: La ruta no pertenece a su organización.'; RETURN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM medio_transporte WHERE med_tra_codigo = i_med_tra_codigo AND fk_pro_codigo = v_pro_id) THEN
        o_status_code := 409; o_mensaje := 'Error: El transporte no pertenece a su flota.'; RETURN;
    END IF;

    -- E. Validar Disponibilidad (Solapamiento)
    IF EXISTS (
        SELECT 1 FROM traslado 
        WHERE fk_med_tra_codigo = i_med_tra_codigo
        AND (
            (tras_fecha_hora_inicio BETWEEN i_fecha_inicio AND i_fecha_fin) OR
            (tras_fecha_hora_fin BETWEEN i_fecha_inicio AND i_fecha_fin) OR
            (i_fecha_inicio BETWEEN tras_fecha_hora_inicio AND tras_fecha_hora_fin)
        )
    ) THEN
        o_status_code := 409; 
        o_mensaje := 'El avión ya tiene un viaje programado que choca con este horario.'; 
        RETURN;
    END IF;

    -- F. Insertar
    INSERT INTO traslado (tras_fecha_hora_inicio, tras_fecha_hora_fin, tras_CO2_Emitido, fk_rut_codigo, fk_med_tra_codigo)
    VALUES (i_fecha_inicio, i_fecha_fin, i_co2, i_rut_codigo, i_med_tra_codigo);

    o_status_code := 201;
    o_mensaje := 'Traslado programado exitosamente.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500; o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;

-- =============================================
-- 25. PROCEDIMIENTO: OBTENER VIAJEROS DE UN USUARIO
-- =============================================
CREATE OR REPLACE PROCEDURE sp_obtener_viajeros_usuario(
    IN i_usu_codigo INTEGER,
    INOUT o_cursor REFCURSOR DEFAULT NULL,
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

-- =============================================
-- 26. PROCEDIMIENTO: OBTENER TRASLADOS DE UN PROVEEDOR
-- =============================================
CREATE OR REPLACE PROCEDURE sp_obtener_traslados_proveedor(
    IN i_usu_codigo INTEGER,
    INOUT o_cursor REFCURSOR DEFAULT NULL,
    INOUT o_status_code INTEGER DEFAULT NULL,
    INOUT o_mensaje VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_prov_id INTEGER;
BEGIN
    -- A. Identificar Proveedor
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
    
    -- Filtramos usando fk_prov_codigo
    WHERE r.fk_prov_codigo = v_prov_id 
    ORDER BY t.tras_fecha_hora_inicio DESC;

    o_status_code := 200;
    o_mensaje := 'Traslados obtenidos.';

EXCEPTION WHEN OTHERS THEN
    o_status_code := 500;
    o_mensaje := 'Error BD: ' || SQLERRM;
END; $$;

-- =============================================
-- 27. PROCEDIMIENTO: OBTENER TERMINALES COMPATIBLES
-- =============================================
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
    -- Usar prov_tipo y prov_codigo
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

-- =============================================
-- 28. PROCEDIMIENTO: REGISTRAR USUARIO CLIENTE
-- =============================================
CREATE OR REPLACE PROCEDURE sp_registrar_usuario_cliente(
    IN i_nombre_usuario VARCHAR,
    IN i_contrasena VARCHAR,
    IN i_correo VARCHAR,
    IN i_fk_lugar INTEGER, 
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
        fk_lugar
    )
    VALUES (
        i_nombre_usuario, 
        i_contrasena, 
        v_rol_cliente_id, 
        0, 
        i_correo,
        i_fk_lugar
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

COMMIT;