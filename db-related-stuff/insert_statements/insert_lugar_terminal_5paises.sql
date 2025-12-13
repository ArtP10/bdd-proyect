BEGIN;

-- =================================================================
-- 1. NORTEAMÉRICA (Estados Unidos -> Florida -> Aeropuerto Miami)
-- =================================================================
DO $$
DECLARE
    v_pais_id INTEGER;
    v_estado_id INTEGER;
BEGIN
    -- 1. Insertar País
    INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) 
    VALUES ('Pais', 'Estados Unidos', NULL) 
    RETURNING lug_codigo INTO v_pais_id;

    -- 2. Insertar Estado
    INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) 
    VALUES ('Estado', 'Florida', v_pais_id) 
    RETURNING lug_codigo INTO v_estado_id;

    -- 3. Insertar Terminal
    INSERT INTO terminal (ter_nombre, ter_descripcion, ter_tipo, fk_lug_codigo)
    VALUES ('Miami International Airport', 'Principal puerta de enlace entre EE.UU. y América Latina', 'Aeropuerto', v_estado_id);
END $$;

-- =================================================================
-- 2. EUROPA (España -> Madrid -> Barajas)
-- =================================================================
DO $$
DECLARE
    v_pais_id INTEGER;
    v_estado_id INTEGER;
BEGIN
    INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) 
    VALUES ('Pais', 'España', NULL) 
    RETURNING lug_codigo INTO v_pais_id;

    INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) 
    VALUES ('Estado', 'Madrid', v_pais_id) 
    RETURNING lug_codigo INTO v_estado_id;

    INSERT INTO terminal (ter_nombre, ter_descripcion, ter_tipo, fk_lug_codigo)
    VALUES ('Adolfo Suárez Madrid-Barajas', 'Aeropuerto principal de España', 'Aeropuerto', v_estado_id);
END $$;

-- =================================================================
-- 3. ASIA (Japón -> Tokio -> Narita)
-- =================================================================
DO $$
DECLARE
    v_pais_id INTEGER;
    v_estado_id INTEGER;
BEGIN
    INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) 
    VALUES ('Pais', 'Japón', NULL) 
    RETURNING lug_codigo INTO v_pais_id;

    INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) 
    VALUES ('Estado', 'Tokio', v_pais_id) 
    RETURNING lug_codigo INTO v_estado_id;

    INSERT INTO terminal (ter_nombre, ter_descripcion, ter_tipo, fk_lug_codigo)
    VALUES ('Narita International Airport', 'Principal aeropuerto internacional de Tokio', 'Aeropuerto', v_estado_id);
END $$;

-- =================================================================
-- 4. ÁFRICA (Sudáfrica -> Gauteng -> O.R. Tambo)
-- =================================================================
DO $$
DECLARE
    v_pais_id INTEGER;
    v_estado_id INTEGER;
BEGIN
    INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) 
    VALUES ('Pais', 'Sudáfrica', NULL) 
    RETURNING lug_codigo INTO v_pais_id;

    INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) 
    VALUES ('Estado', 'Gauteng', v_pais_id) 
    RETURNING lug_codigo INTO v_estado_id;

    INSERT INTO terminal (ter_nombre, ter_descripcion, ter_tipo, fk_lug_codigo)
    VALUES ('O.R. Tambo International Airport', 'Aeropuerto más grande de África, cerca de Johannesburgo', 'Aeropuerto', v_estado_id);
END $$;

-- =================================================================
-- 5. OCEANÍA (Australia -> Nueva Gales del Sur -> Sídney)
-- =================================================================
DO $$
DECLARE
    v_pais_id INTEGER;
    v_estado_id INTEGER;
BEGIN
    INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) 
    VALUES ('Pais', 'Australia', NULL) 
    RETURNING lug_codigo INTO v_pais_id;

    INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) 
    VALUES ('Estado', 'Nueva Gales del Sur', v_pais_id) 
    RETURNING lug_codigo INTO v_estado_id;

    INSERT INTO terminal (ter_nombre, ter_descripcion, ter_tipo, fk_lug_codigo)
    VALUES ('Sydney Kingsford Smith Airport', 'Aeropuerto principal de Sídney', 'Aeropuerto', v_estado_id);
END $$;

COMMIT;