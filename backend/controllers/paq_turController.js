const pool = require('../config/db');

// ==========================================
// SECCIÓN 1: PAQUETES TURÍSTICOS (CRUD)
// ==========================================

const createPackage = async (req, res) => {
    const { nombre, monto_total, monto_subtotal, costo_millas } = req.body;
    try {
        const query = `CALL sp_crear_paquete_turistico($1, $2, $3, $4, NULL, NULL, NULL)`;
        const values = [nombre, monto_total, monto_subtotal, costo_millas];
        const result = await pool.query(query, values);
        const resp = result.rows[0];
        
        if (resp.o_status_code === 201) {
            res.status(201).json({ success: true, message: resp.o_mensaje, paq_tur_codigo: resp.o_paq_tur_codigo });
        } else {
            res.status(resp.o_status_code).json({ success: false, message: resp.o_mensaje });
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error interno al crear paquete' });
    }
};

const getPackages = async (req, res) => {
    try {
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            
            // CORRECCIÓN: Enviamos 6 parámetros.
            // Los primeros 3 son los filtros (NULL por ahora)
            // Los últimos 3 son los de salida (cursor, status, mensaje)
            const query = 'CALL sp_obtener_paquetes_turisticos(NULL, NULL, NULL, NULL, NULL, NULL)';
            
            const result = await client.query(query);
            const response = result.rows[0];
            
            if (response.o_status_code === 200) {
                const cursorResult = await client.query(`FETCH ALL IN "${response.o_cursor}"`);
                await client.query('COMMIT');
                res.status(200).json({ success: true, data: cursorResult.rows });
            } else {
                await client.query('ROLLBACK');
                res.status(response.o_status_code).json({ success: false, message: response.o_mensaje });
            }
        } finally { client.release(); }
    } catch (err) { 
        console.error(err); 
        res.status(500).json({ success: false, message: 'Error al obtener paquetes' }); 
    }
};
const updatePackage = async (req, res) => {
    const { id } = req.params;
    const { nombre, monto_total, monto_subtotal, costo_millas } = req.body;
    try {
        const query = `CALL sp_modificar_paquete_turistico($1, $2, $3, $4, $5, NULL, NULL)`;
        const values = [id, nombre, monto_total, monto_subtotal, costo_millas];
        const result = await pool.query(query, values);
        const resp = result.rows[0];

        if (resp.o_status_code === 200) {
            res.status(200).json({ success: true, message: resp.o_mensaje });
        } else {
            res.status(resp.o_status_code).json({ success: false, message: resp.o_mensaje });
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error interno al modificar paquete' });
    }
};

const deletePackage = async (req, res) => {
    const { id } = req.params;
    try {
        const query = `CALL sp_eliminar_paquete_turistico($1, NULL, NULL)`;
        const result = await pool.query(query, [id]);
        const resp = result.rows[0];

        if (resp.o_status_code === 200) {
            res.status(200).json({ success: true, message: resp.o_mensaje });
        } else {
            res.status(resp.o_status_code).json({ success: false, message: resp.o_mensaje });
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error interno al eliminar paquete' });
    }
};

// ==========================================
// SECCIÓN 2: REGLAS DE NEGOCIO
// ==========================================

const createRule = async (req, res) => {
    const { atributo, operador, valor } = req.body;
    try {
        const query = `CALL sp_crear_regla_paquete($1, $2, $3, NULL, NULL, NULL)`;
        const result = await pool.query(query, [atributo, operador, valor]);
        const resp = result.rows[0];
        res.status(resp.o_status_code).json({ success: resp.o_status_code === 201, message: resp.o_mensaje });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error al crear regla' });
    }
};

const getRules = async (req, res) => {
    try {
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            const query = 'CALL sp_obtener_reglas_paquete(NULL, NULL, NULL)';
            const result = await client.query(query);
            const response = result.rows[0];
            if (response.o_status_code === 200) {
                const cursorResult = await client.query(`FETCH ALL IN "${response.o_cursor}"`);
                await client.query('COMMIT');
                res.status(200).json({ success: true, data: cursorResult.rows });
            } else {
                await client.query('ROLLBACK');
                res.status(response.o_status_code).json({ success: false, message: response.o_mensaje });
            }
        } finally { client.release(); }
    } catch (err) { console.error(err); res.status(500).json({ success: false, message: 'Error server' }); }
};

const assignRuleToPackage = async (req, res) => {
    const { fk_paq_tur_codigo, fk_reg_paq_codigo } = req.body;
    try {
        const query = `CALL sp_asignar_regla_paquete($1, $2, NULL, NULL)`;
        const result = await pool.query(query, [fk_paq_tur_codigo, fk_reg_paq_codigo]);
        const resp = result.rows[0];
        res.status(resp.o_status_code || 200).json({ success: resp.o_status_code === 201, message: resp.o_mensaje });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error al asignar regla' });
    }
};

// ==========================================
// SECCIÓN 3: GESTIÓN DE CONTENIDO (SEPARADO)
// ==========================================

// --- A. SERVICIOS GENÉRICOS (Tours, Seguros, etc.) ---
const getGenericServices = async (req, res) => {
    try {
        // Llama al SP que filtra NO hoteles NO restaurantes
        const result = await pool.query('SELECT * FROM sp_listar_servicios_genericos()');
        res.status(200).json({ success: true, data: result.rows });
    } catch (err) { console.error(err); res.status(500).json({ success: false }); }
};

const assignGenericService = async (req, res) => {
    const { id_paquete, id_servicio, cantidad } = req.body;
    try {
        // Tabla paq_ser
        await pool.query('CALL sp_asignar_servicio_generico($1, $2, $3)', [id_paquete, id_servicio, cantidad]);
        res.status(200).json({ success: true, message: 'Servicio asignado correctamente' });
    } catch (err) { console.error(err); res.status(500).json({ success: false, message: err.message }); }
};

// --- B. ALOJAMIENTO (Habitaciones) ---
const getRoomOptions = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM sp_listar_habitaciones_info()');
        res.status(200).json({ success: true, data: result.rows });
    } catch (err) { console.error(err); res.status(500).json({ success: false }); }
};

const addRoomReservation = async (req, res) => {
    const { id_paquete, id_habitacion, fecha_inicio, fecha_fin, costo } = req.body;
    try {
        // Tabla reserva_de_habitacion
        await pool.query('CALL sp_agregar_reserva_habitacion_paquete($1, $2, $3, $4, $5)', 
            [id_paquete, id_habitacion, fecha_inicio, fecha_fin, costo]);
        res.status(200).json({ success: true, message: 'Habitación reservada en el paquete' });
    } catch (err) { console.error(err); res.status(500).json({ success: false, message: err.message }); }
};

// --- C. RESTAURANTES ---
const getRestaurantOptions = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM sp_listar_restaurantes_info()');
        res.status(200).json({ success: true, data: result.rows });
    } catch (err) { console.error(err); res.status(500).json({ success: false }); }
};

const addRestaurantReservation = async (req, res) => {
    const { id_paquete, id_restaurante, fecha, num_mesa, tamano_mesa } = req.body;
    try {
        // Tabla reserva_restaurante
        await pool.query('CALL sp_agregar_reserva_restaurante_paquete($1, $2, $3, $4, $5)', 
            [id_paquete, id_restaurante, fecha, num_mesa, tamano_mesa]);
        res.status(200).json({ success: true, message: 'Mesa reservada en el paquete' });
    } catch (err) { console.error(err); res.status(500).json({ success: false, message: err.message }); }
};

// --- D. TRASLADOS ---
const getAvailableTransfers = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM sp_listar_traslados_disponibles()');
        res.status(200).json({ success: true, data: result.rows });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error listando traslados' });
    }
};

const assignTransfer = async (req, res) => {
    const { id_paquete, id_traslado } = req.body;
    try {
        // Tabla paq_tras
        await pool.query('CALL sp_asignar_traslado_paquete($1, $2)', [id_paquete, id_traslado]);
        res.status(200).json({ success: true, message: 'Traslado agregado al paquete' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error asignando traslado' });
    }
};

// ==========================================
// SECCIÓN 4: DETALLES VISUALES
// ==========================================

// ... tus otras funciones ...

// E. Obtener Detalle Completo (Usando SPs separados)
const getPackageDetails = async (req, res) => {
    const { id } = req.params;
    try {
        // Ejecutamos las consultas en paralelo para mayor velocidad
        const [infoRes, aloRes, restRes, servRes, trasRes, reglasRes] = await Promise.all([
            // 1. Info básica (query directa simple)
            pool.query('SELECT paq_tur_nombre, paq_tur_monto_total FROM paquete_turistico WHERE paq_tur_codigo = $1', [id]),
            // 2. SP Alojamientos
            pool.query('SELECT * FROM sp_det_paq_alojamientos($1)', [id]),
            // 3. SP Restaurantes
            pool.query('SELECT * FROM sp_det_paq_restaurantes($1)', [id]),
            // 4. SP Servicios
            pool.query('SELECT * FROM sp_det_paq_servicios($1)', [id]),
            // 5. SP Traslados
            pool.query('SELECT * FROM sp_det_paq_traslados($1)', [id]),
            // 6. SP Reglas
            pool.query('SELECT * FROM sp_det_paq_reglas($1)', [id])
        ]);
        
        // Construimos el objeto final
        if (infoRes.rows.length > 0) {
            const detalle = {
                info: infoRes.rows[0],
                alojamientos: aloRes.rows,
                restaurantes: restRes.rows,
                servicios_genericos: servRes.rows,
                traslados: trasRes.rows,
                reglas: reglasRes.rows
            };
            res.status(200).json({ success: true, data: detalle });
        } else {
            res.status(404).json({ success: false, message: 'Paquete no encontrado' });
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error obteniendo detalles' });
    }
};


const removePackageElement = async (req, res) => {
    // 1. Desestructuramos TODOS los parámetros posibles que envía el front
    const { tipo, id_paquete, id_elemento, fecha_inicio, extra_id } = req.body; 

    try {
        // 2. Llamada al SP con 5 placeholders ($1 ... $5)
        const query = `CALL sp_eliminar_elemento_paquete($1, $2, $3, $4, $5)`;
        
        // 3. Pasamos los valores. Usamos '|| null' por seguridad si vienen undefined
        const values = [
            tipo, 
            id_paquete, 
            id_elemento, 
            fecha_inicio || null, 
            extra_id || null
        ];

        await pool.query(query, values);
        
        res.json({ success: true, message: 'Elemento eliminado correctamente' });
    } catch (err) {
        console.error("Error eliminando elemento:", err);
        res.status(500).json({ success: false, message: 'Error interno al eliminar' });
    }
};

// ... module.exports ...

module.exports = {
    // CRUD
    createPackage,
    getPackages,
    updatePackage,
    deletePackage,
    getPackageDetails,
    removePackageElement,

    // Reglas
    createRule,
    getRules,
    assignRuleToPackage,

    // Servicios Genericos
    getGenericServices,
    assignGenericService,

    // Habitaciones
    getRoomOptions,
    addRoomReservation,

    // Restaurantes
    getRestaurantOptions,
    addRestaurantReservation,

    // Traslados
    getAvailableTransfers,
    assignTransfer
};