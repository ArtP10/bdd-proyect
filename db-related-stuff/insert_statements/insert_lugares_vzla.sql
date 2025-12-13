-- 1. Insertar el País (Venezuela)
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar) 
VALUES ('Pais', 'Venezuela', NULL);

-- 2. Insertar los Estados (Buscando el ID de Venezuela automáticamente)
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Estado', nombre_estado, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Venezuela' AND lug_tipo = 'Pais')
FROM (VALUES 
    ('Amazonas'), ('Anzoátegui'), ('Apure'), ('Aragua'), ('Barinas'),
    ('Bolívar'), ('Carabobo'), ('Cojedes'), ('Delta Amacuro'), ('Distrito Capital'),
    ('Falcón'), ('Guárico'), ('Lara'), ('La Guaira'), ('Mérida'),
    ('Miranda'), ('Monagas'), ('Nueva Esparta'), ('Portuguesa'), ('Sucre'),
    ('Táchira'), ('Trujillo'), ('Yaracuy'), ('Zulia')
) AS estados(nombre_estado);


BEGIN;

-- ==========================================
-- REGIÓN CENTRAL Y CAPITAL
-- ==========================================

-- ARAGUA
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', m.nombre, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Aragua' AND lug_tipo = 'Estado' LIMIT 1)
FROM (VALUES 
    ('Bolívar'), ('Camatagua'), ('Francisco Linares Alcántara'), ('Girardot'), 
    ('José Ángel Lamas'), ('José Félix Ribas'), ('José Rafael Revenga'), ('Libertador'), 
    ('Mario Briceño Iragorry'), ('Ocumare de la Costa de Oro'), ('San Casimiro'), 
    ('San Sebastián'), ('Santiago Mariño'), ('Santos Michelena'), ('Sucre'), 
    ('Tovar'), ('Urdaneta'), ('Zamora')
) AS m(nombre);

-- CARABOBO
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', m.nombre, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Carabobo' AND lug_tipo = 'Estado' LIMIT 1)
FROM (VALUES 
    ('Bejuma'), ('Carlos Arvelo'), ('Diego Ibarra'), ('Guacara'), ('Juan José Mora'), 
    ('Libertador'), ('Los Guayos'), ('Miranda'), ('Montalbán'), ('Naguanagua'), 
    ('Puerto Cabello'), ('San Diego'), ('San Joaquín'), ('Valencia')
) AS m(nombre)
WHERE NOT EXISTS (SELECT 1 FROM lugar l2 WHERE l2.lug_nombre = m.nombre AND l2.fk_lugar = (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Carabobo' AND lug_tipo = 'Estado'));

-- LA GUAIRA
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', 'Vargas', (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'La Guaira' AND lug_tipo = 'Estado' LIMIT 1);

-- ==========================================
-- REGIÓN OCCIDENTAL
-- ==========================================

-- FALCÓN
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', m.nombre, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Falcón' AND lug_tipo = 'Estado' LIMIT 1)
FROM (VALUES 
    ('Acosta'), ('Bolívar'), ('Buchivacoa'), ('Cacique Manaure'), ('Carirubana'), 
    ('Colina'), ('Dabajuro'), ('Democracia'), ('Falcón'), ('Federación'), ('Jacura'), 
    ('Los Taques'), ('Mauroa'), ('Miranda'), ('Monseñor Iturriza'), ('Palmasola'), 
    ('Petit'), ('Píritu'), ('San Francisco'), ('Silva'), ('Sucre'), ('Tocópero'), 
    ('Unión'), ('Urumaco'), ('Zamora')
) AS m(nombre);

-- LARA
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', m.nombre, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Lara' AND lug_tipo = 'Estado' LIMIT 1)
FROM (VALUES 
    ('Andrés Eloy Blanco'), ('Crespo'), ('Iribarren'), ('Jiménez'), ('Morán'), 
    ('Palavecino'), ('Simón Planas'), ('Torres'), ('Urdaneta')
) AS m(nombre);

-- YARACUY
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', m.nombre, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Yaracuy' AND lug_tipo = 'Estado' LIMIT 1)
FROM (VALUES 
    ('Arístides Bastidas'), ('Bolívar'), ('Bruzual'), ('Cocorote'), ('Independencia'), 
    ('José Antonio Páez'), ('La Trinidad'), ('Manuel Monge'), ('Nirgua'), ('Peña'), 
    ('San Felipe'), ('Sucre'), ('Urachiche'), ('Veroes')
) AS m(nombre);

-- ZULIA
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', m.nombre, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Zulia' AND lug_tipo = 'Estado' LIMIT 1)
FROM (VALUES 
    ('Almirante Padilla'), ('Baralt'), ('Cabimas'), ('Catatumbo'), ('Colón'), 
    ('Francisco Javier Pulgar'), ('Guajira'), ('Jesús Enrique Lossada'), 
    ('Jesús María Semprún'), ('La Cañada de Urdaneta'), ('Lagunillas'), 
    ('Machiques de Perijá'), ('Mara'), ('Maracaibo'), ('Miranda'), ('Rosario de Perijá'), 
    ('San Francisco'), ('Santa Rita'), ('Simón Bolívar'), ('Sucre'), ('Valmore Rodríguez')
) AS m(nombre)
WHERE NOT EXISTS (SELECT 1 FROM lugar l2 WHERE l2.lug_nombre = m.nombre AND l2.fk_lugar = (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Zulia' AND lug_tipo = 'Estado'));

-- ==========================================
-- REGIÓN DE LOS ANDES
-- ==========================================

-- MÉRIDA
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', m.nombre, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Mérida' AND lug_tipo = 'Estado' LIMIT 1)
FROM (VALUES 
    ('Alberto Adriani'), ('Andrés Bello'), ('Antonio Pinto Salinas'), ('Aricagua'), 
    ('Arzobispo Chacón'), ('Campo Elías'), ('Caracciolo Parra Olmedo'), 
    ('Cardenal Quintero'), ('Guaraque'), ('Julio César Salas'), ('Justo Briceño'), 
    ('Libertador'), ('Miranda'), ('Obispo Ramos de Lora'), ('Padre Noguera'), 
    ('Pueblo Llano'), ('Rangel'), ('Rivas Dávila'), ('Santos Marquina'), ('Sucre'), 
    ('Tovar'), ('Tulio Febres Cordero'), ('Zea')
) AS m(nombre);

-- TÁCHIRA
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', m.nombre, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Táchira' AND lug_tipo = 'Estado' LIMIT 1)
FROM (VALUES 
    ('Andrés Bello'), ('Antonio Rómulo Costa'), ('Ayacucho'), ('Bolívar'), ('Cárdenas'), 
    ('Córdoba'), ('Fernández Feo'), ('Francisco de Miranda'), ('García de Hevia'), 
    ('Guásimos'), ('Independencia'), ('Jáuregui'), ('José María Vargas'), ('Junín'), 
    ('Libertad'), ('Libertador'), ('Lobatera'), ('Michelena'), ('Panamericano'), 
    ('Pedro María Ureña'), ('Rafael Urdaneta'), ('Samuel Darío Maldonado'), 
    ('San Cristóbal'), ('San Judas Tadeo'), ('Seboruco'), ('Simón Rodríguez'), 
    ('Sucre'), ('Torbes'), ('Uribante')
) AS m(nombre);

-- TRUJILLO
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', m.nombre, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Trujillo' AND lug_tipo = 'Estado' LIMIT 1)
FROM (VALUES 
    ('Andrés Bello'), ('Boconó'), ('Bolívar'), ('Candelaria'), ('Carache'), ('Escuque'), 
    ('José Felipe Márquez Cañizales'), ('Juan Vicente Campo Elías'), ('La Ceiba'), 
    ('Miranda'), ('Monte Carmelo'), ('Motatán'), ('Pampán'), ('Pampanito'), 
    ('Rafael Rangel'), ('San Rafael de Carvajal'), ('Sucre'), ('Trujillo'), 
    ('Urdaneta'), ('Valera')
) AS m(nombre);

-- ==========================================
-- REGIÓN ORIENTAL E INSULAR
-- ==========================================

-- ANZOÁTEGUI
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', m.nombre, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Anzoátegui' AND lug_tipo = 'Estado' LIMIT 1)
FROM (VALUES 
    ('Anaco'), ('Aragua'), ('Bolívar'), ('Bruzual'), ('Cajigal'), ('Carvajal'), 
    ('Diego Bautista Urbaneja'), ('Freites'), ('Guanipa'), ('Guanta'), ('Independencia'), 
    ('Libertad'), ('McGregor'), ('Miranda'), ('Monagas'), ('Peñalver'), ('Píritu'), 
    ('San Juan de Capistrano'), ('Santa Ana'), ('Simón Bolívar'), ('Simón Rodríguez'), 
    ('Sotillo')
) AS m(nombre);

-- MONAGAS
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', m.nombre, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Monagas' AND lug_tipo = 'Estado' LIMIT 1)
FROM (VALUES 
    ('Acosta'), ('Aguasay'), ('Bolívar'), ('Caripe'), ('Cedeño'), ('Ezequiel Zamora'), 
    ('Libertador'), ('Maturín'), ('Piar'), ('Punceres'), ('Santa Bárbara'), 
    ('Sotillo'), ('Uracoa')
) AS m(nombre);

-- NUEVA ESPARTA
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', m.nombre, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Nueva Esparta' AND lug_tipo = 'Estado' LIMIT 1)
FROM (VALUES 
    ('Antolín del Campo'), ('Arismendi'), ('Díaz'), ('García'), ('Gómez'), ('Maneiro'), 
    ('Marcano'), ('Mariño'), ('Península de Macanao'), ('Tubores'), ('Villalba')
) AS m(nombre);

-- SUCRE
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', m.nombre, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Sucre' AND lug_tipo = 'Estado' LIMIT 1)
FROM (VALUES 
    ('Andrés Eloy Blanco'), ('Andrés Mata'), ('Arismendi'), ('Benítez'), ('Bermúdez'), 
    ('Bolívar'), ('Cajigal'), ('Cruz Salmerón Acosta'), ('Libertador'), ('Mariño'), 
    ('Mejía'), ('Montes'), ('Ribero'), ('Sucre'), ('Valdez')
) AS m(nombre);

-- ==========================================
-- REGIÓN DE LOS LLANOS
-- ==========================================

-- APURE
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', m.nombre, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Apure' AND lug_tipo = 'Estado' LIMIT 1)
FROM (VALUES 
    ('Achaguas'), ('Biruaca'), ('Muñoz'), ('Páez'), ('Pedro Camejo'), 
    ('Rómulo Gallegos'), ('San Fernando')
) AS m(nombre);

-- BARINAS
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', m.nombre, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Barinas' AND lug_tipo = 'Estado' LIMIT 1)
FROM (VALUES 
    ('Alberto Arvelo Torrealba'), ('Andrés Eloy Blanco'), ('Antonio José de Sucre'), 
    ('Arismendi'), ('Barinas'), ('Bolívar'), ('Cruz Paredes'), ('Ezequiel Zamora'), 
    ('Obispos'), ('Pedraza'), ('Rojas'), ('Sosa')
) AS m(nombre);

-- COJEDES
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', m.nombre, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Cojedes' AND lug_tipo = 'Estado' LIMIT 1)
FROM (VALUES 
    ('Anzoátegui'), ('Falcón'), ('Girardot'), ('Lima Blanco'), ('Pao de San Juan Bautista'), 
    ('Ricaurte'), ('Rómulo Gallegos'), ('San Carlos'), ('Tinaco')
) AS m(nombre);

-- GUÁRICO
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', m.nombre, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Guárico' AND lug_tipo = 'Estado' LIMIT 1)
FROM (VALUES 
    ('Camaguán'), ('Chaguaramas'), ('El Socorro'), ('Francisco de Miranda'), 
    ('José Félix Ribas'), ('José Tadeo Monagas'), ('Juan Germán Roscio'), 
    ('Julián Mellado'), ('Las Mercedes'), ('Leonardo Infante'), ('Ortiz'), 
    ('Pedro Zaraza'), ('San Gerónimo de Guayabal'), ('San José de Guaribe'), 
    ('Santa María de Ipire')
) AS m(nombre);

-- PORTUGUESA
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', m.nombre, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Portuguesa' AND lug_tipo = 'Estado' LIMIT 1)
FROM (VALUES 
    ('Agua Blanca'), ('Araure'), ('Esteller'), ('Guanare'), ('Guanarito'), 
    ('Monseñor José Vicente de Unda'), ('Ospino'), ('Páez'), ('Papelón'), 
    ('San Genaro de Boconoíto'), ('San Rafael de Onoto'), ('Santa Rosalía'), 
    ('Sucre'), ('Turén')
) AS m(nombre);

-- ==========================================
-- REGIÓN GUAYANA
-- ==========================================

-- AMAZONAS
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', m.nombre, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Amazonas' AND lug_tipo = 'Estado' LIMIT 1)
FROM (VALUES 
    ('Alto Orinoco'), ('Atabapo'), ('Atures'), ('Autana'), ('Manapiare'), 
    ('Maroa'), ('Río Negro')
) AS m(nombre);

-- BOLÍVAR
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', m.nombre, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Bolívar' AND lug_tipo = 'Estado' LIMIT 1)
FROM (VALUES 
    ('Angostura'), ('Caroní'), ('Cedeño'), ('El Callao'), ('Gran Sabana'), 
    ('Heres'), ('Padre Pedro Chien'), ('Piar'), ('Roscio'), ('Sifontes'), ('Sucre')
) AS m(nombre);

-- DELTA AMACURO
INSERT INTO lugar (lug_tipo, lug_nombre, fk_lugar)
SELECT 'Municipio', m.nombre, (SELECT lug_codigo FROM lugar WHERE lug_nombre = 'Delta Amacuro' AND lug_tipo = 'Estado' LIMIT 1)
FROM (VALUES 
    ('Antonio Díaz'), ('Casacoima'), ('Pedernales'), ('Tucupita')
) AS m(nombre);

COMMIT;



--Para obtener municipios de los estados de venezuela
SELECT 
    m.lug_nombre AS Municipio, 
    e.lug_nombre AS Pertenece_Al_Estado
FROM lugar m
JOIN lugar e ON m.fk_lugar = e.lug_codigo
WHERE m.lug_nombre IN ('Miranda', 'Sucre', 'Libertador', 'Bolívar')
AND m.lug_tipo = 'Municipio'
ORDER BY m.lug_nombre, e.lug_nombre;
--si se quieren mas estados, agregar al IN ('');

