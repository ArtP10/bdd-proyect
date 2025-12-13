DO $$
DECLARE
    v_ruta_id INTEGER;
    v_avion_volador INTEGER;
    v_avion_futuro INTEGER;
    -- Variable para el ID del proveedor (Cámbialo aquí si el 1 no es aerolínea)
    v_proveedor_id INTEGER := 1; 
BEGIN
    -- =================================================================
    -- 1. Crear 3 Aviones para el Proveedor
    -- =================================================================
    
    -- Avión 1: El que estará volando
    INSERT INTO medio_transporte (med_tra_capacidad, med_tra_descripcion, med_tra_tipo, fk_pro_codigo) 
    VALUES (150, 'Boeing 737 - El Volador (ACTIVO AHORA)', 'Avion', v_proveedor_id) 
    RETURNING med_tra_codigo INTO v_avion_volador;
    
    -- Avión 2: El que estará esperando
    INSERT INTO medio_transporte (med_tra_capacidad, med_tra_descripcion, med_tra_tipo, fk_pro_codigo) 
    VALUES (200, 'Airbus A320 - El Futuro (EN ESPERA)', 'Avion', v_proveedor_id) 
    RETURNING med_tra_codigo INTO v_avion_futuro;
    
    -- Avión 3: El que no tendrá actividad
    INSERT INTO medio_transporte (med_tra_capacidad, med_tra_descripcion, med_tra_tipo, fk_pro_codigo) 
    VALUES (100, 'Embraer 190 - El Viejo (INACTIVO)', 'Avion', v_proveedor_id);
    -- No necesitamos guardar el ID del viejo porque no le haremos traslado.

    -- =================================================================
    -- 2. Crear Ruta: Miami (ID 3) -> Madrid (ID 4)
    -- =================================================================
    INSERT INTO ruta (rut_costo, rut_millas_otorgadas, fk_terminal_origen, fk_terminal_destino, fk_pro_codigo)
    VALUES (
        650.00,  -- Costo
        3500,    -- Millas
        3,       -- Origen: Miami International Airport
        4,       -- Destino: Adolfo Suárez Madrid-Barajas
        v_proveedor_id
    )
    RETURNING rut_codigo INTO v_ruta_id;

    -- =================================================================
    -- 3. Crear Traslados para forzar los estados
    -- =================================================================
    
    -- A. ESTADO: EN VUELO
    -- Empezó hace 2 horas, termina en 6 horas (vuelo de 8 horas)
    INSERT INTO traslado (tras_fecha_hora_inicio, tras_fecha_hora_fin, tras_CO2_Emitido, fk_rut_codigo, fk_med_tra_codigo)
    VALUES (
        NOW() - INTERVAL '2 hours', 
        NOW() + INTERVAL '6 hours', 
        450.50, 
        v_ruta_id, 
        v_avion_volador
    );

    -- B. ESTADO: EN ESPERA
    -- Empieza mañana a esta misma hora
    INSERT INTO traslado (tras_fecha_hora_inicio, tras_fecha_hora_fin, tras_CO2_Emitido, fk_rut_codigo, fk_med_tra_codigo)
    VALUES (
        NOW() + INTERVAL '1 day', 
        NOW() + INTERVAL '1 day 8 hours', 
        450.50, 
        v_ruta_id, 
        v_avion_futuro
    );

    -- C. ESTADO: INACTIVO
    -- Simplemente no insertamos nada para el 'Embraer 190 - El Viejo'

END $$;