-- Store Procedure: get_elementos_busqueda
CREATE OR REPLACE FUNCTION get_elementos_busqueda(
    p_estado_nombre VARCHAR,
    p_tipo_elemento VARCHAR, -- 'traslado_aereo', 'traslado_maritimo', 'traslado_terrestre', 'servicio', 'habitacion', 'restaurante'
    p_promocion_codigo BIGINT
)
RETURNS TABLE (
    elemento_id BIGINT,
    nombre_elemento VARCHAR,
    tipo_detallado VARCHAR,
    info_basica VARCHAR,
    costo DECIMAL,
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    capacidad INTEGER, -- Para Habitaciones
    rating INTEGER, -- Para Hoteles/Restaurantes
    asignado BOOLEAN -- Indica si ya tiene esta promoción
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- TRASLADOS (Aéreo, Marítimo, Terrestre)
    IF p_tipo_elemento LIKE 'traslado%' THEN
        RETURN QUERY
        SELECT
            T.trasl_codigo AS elemento_id,
            'Traslado ' || T.trasl_codigo AS nombre_elemento,
            TM.medtr_nombre AS tipo_detallado,
            TM.medtr_nombre || ' - ' || T.trasl_fecha_salida || ' a ' || T.trasl_fecha_llegada AS info_basica,
            T.trasl_costo AS costo,
            T.trasl_fecha_salida AS fecha_inicio,
            T.trasl_fecha_llegada AS fecha_fin,
            NULL::INTEGER AS capacidad,
            NULL::INTEGER AS rating,
            EXISTS (
                SELECT 1 FROM Promocion_Traslado PT
                WHERE PT.trasl_codigo = T.trasl_codigo AND PT.prom_codigo = p_promocion_codigo
            ) AS asignado
        FROM
            Traslado T
        JOIN
            Medio_Transporte TM ON T.medtr_codigo = TM.medtr_codigo
        JOIN
            Ruta R ON T.ruta_codigo = R.ruta_codigo
        JOIN
            Terminal TE_O ON R.termi_codigo_origen = TE_O.termi_codigo
        JOIN
            Lugar L_O ON TE_O.lugar_codigo = L_O.lugar_codigo
        JOIN
            Lugar L_E ON L_O.lugar_codigo_padre = L_E.lugar_codigo -- Asume que el padre es el Estado
        WHERE
            L_E.lugar_nombre = p_estado_nombre
            AND CASE 
                WHEN p_tipo_elemento = 'traslado_aereo' THEN TM.medtr_tipo = 'A'
                WHEN p_tipo_elemento = 'traslado_maritimo' THEN TM.medtr_tipo = 'M'
                WHEN p_tipo_elemento = 'traslado_terrestre' THEN TM.medtr_tipo = 'T'
                ELSE TRUE
            END;

    -- SERVICIOS
    ELSIF p_tipo_elemento = 'servicio' THEN
        RETURN QUERY
        SELECT
            S.serv_codigo AS elemento_id,
            S.serv_nombre AS nombre_elemento,
            PR.prov_nombre AS tipo_detallado,
            'Proveedor: ' || PR.prov_nombre AS info_basica,
            S.serv_costo AS costo,
            S.serv_fecha_hora_inicio AS fecha_inicio,
            S.serv_fecha_hora_fin AS fecha_fin,
            NULL::INTEGER AS capacidad,
            NULL::INTEGER AS rating,
            EXISTS (
                SELECT 1 FROM Promocion_Servicio PS
                WHERE PS.serv_codigo = S.serv_codigo AND PS.prom_codigo = p_promocion_codigo
            ) AS asignado
        FROM
            Servicio S
        JOIN
            Proveedor PR ON S.prov_codigo = PR.prov_codigo
        JOIN
            Lugar L ON PR.lugar_codigo = L.lugar_codigo
        JOIN
            Lugar L_E ON L.lugar_codigo_padre = L_E.lugar_codigo
        WHERE
            L_E.lugar_nombre = p_estado_nombre;

    -- HABITACIONES (de Hotel)
    ELSIF p_tipo_elemento = 'habitacion' THEN
        RETURN QUERY
        SELECT
            H.hab_codigo AS elemento_id,
            'Habitación ' || H.hab_codigo || ' (' || HD.tipohab_nombre || ')' AS nombre_elemento,
            HT.hot_nombre AS tipo_detallado,
            'Hotel: ' || HT.hot_nombre || ', Rating: ' || HT.hot_valoracion AS info_basica,
            HD.tipohab_precio_por_noche AS costo,
            NULL::TIMESTAMP AS fecha_inicio, -- No aplica fecha para la HABITACIÓN, solo para la reserva
            NULL::TIMESTAMP AS fecha_fin,
            HD.tipohab_capacidad AS capacidad,
            HT.hot_valoracion AS rating,
            EXISTS (
                SELECT 1 FROM Promocion_Habitacion PH
                WHERE PH.hab_codigo = H.hab_codigo AND PH.prom_codigo = p_promocion_codigo
            ) AS asignado
        FROM
            Habitacion H
        JOIN
            Hotel HT ON H.hot_codigo = HT.hot_codigo
        JOIN
            Tipo_Habitacion HD ON H.tipohab_codigo = HD.tipohab_codigo
        JOIN
            Lugar L ON HT.lugar_codigo = L.lugar_codigo
        JOIN
            Lugar L_E ON L.lugar_codigo_padre = L_E.lugar_codigo
        WHERE
            L_E.lugar_nombre = p_estado_nombre;

    -- RESTAURANTES
    ELSIF p_tipo_elemento = 'restaurante' THEN
        RETURN QUERY
        SELECT
            R.rest_codigo AS elemento_id,
            R.rest_nombre AS nombre_elemento,
            R.rest_descripcion AS tipo_detallado,
            'Rating: ' || R.rest_valoracion AS info_basica,
            NULL::DECIMAL AS costo, -- No aplica costo fijo, solo para la reserva
            NULL::TIMESTAMP AS fecha_inicio,
            NULL::TIMESTAMP AS fecha_fin,
            NULL::INTEGER AS capacidad,
            R.rest_valoracion AS rating,
            EXISTS (
                SELECT 1 FROM Promocion_Restaurante PR
                WHERE PR.rest_codigo = R.rest_codigo AND PR.prom_codigo = p_promocion_codigo
            ) AS asignado
        FROM
            Restaurante R
        JOIN
            Lugar L ON R.lugar_codigo = L.lugar_codigo
        JOIN
            Lugar L_E ON L.lugar_codigo_padre = L_E.lugar_codigo
        WHERE
            L_E.lugar_nombre = p_estado_nombre;
            
    END IF;
END;
$$;