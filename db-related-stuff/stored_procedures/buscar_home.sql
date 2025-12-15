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