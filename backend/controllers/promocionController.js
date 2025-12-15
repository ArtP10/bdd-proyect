const pool = require('../config/db');

// =====================================================================
// 1. CRUD BÁSICO (TODO CON STORED PROCEDURES)
// =====================================================================

// Obtener todas las promociones
const obtenerPromociones = async (req, res) => {
    try {
        // CAMBIO: Ahora llama a la función SQL en lugar de hacer SELECT a la tabla
        const result = await pool.query('SELECT * FROM sp_obtener_promociones()');
        res.status(200).json({ success: true, data: result.rows });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// Registrar nueva promoción
const crearPromocion = async (req, res) => {
    const { nombre, descripcion, fecha_vencimiento, descuento } = req.body;
    try {
        await pool.query('CALL registrar_promocion($1, $2, $3, $4)', 
            [nombre, descripcion, fecha_vencimiento, descuento]);
        res.status(201).json({ success: true, message: 'Promoción creada exitosamente' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// Editar promoción existente
const actualizarPromocion = async (req, res) => {
    const { id } = req.params;
    const { nombre, descripcion, fecha_vencimiento, descuento } = req.body;
    try {
        await pool.query('CALL editar_promocion($1, $2, $3, $4, $5)', 
            [id, nombre, descripcion, fecha_vencimiento, descuento]);
        res.status(200).json({ success: true, message: 'Promoción actualizada' });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Eliminar promoción (Llama al SP que limpia referencias antes de borrar)
const eliminarPromocion = async (req, res) => {
    const { id } = req.params;
    try {
        await pool.query('CALL eliminar_promocion($1)', [id]);
        res.status(200).json({ success: true, message: 'Promoción eliminada' });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// =====================================================================
// 2. LÓGICA DEL CONSTRUCTOR (BUILDER Y ASIGNACIÓN)
// =====================================================================

// Obtener datos de una promoción específica (Para el título del modal)
const getPromocionData = async (req, res) => {
    const { prom_codigo } = req.params;
    try {
        // Nota: Si quieres ser 100% purista, puedes crear un SP 'sp_obtener_promocion_por_id'
        // pero esta consulta simple de lectura suele dejarse así. 
        // Si prefieres SP, avísame y te paso el SQL extra.
        const promo = await pool.query('SELECT * FROM promocion WHERE prom_codigo = $1', [prom_codigo]);
        
        if (promo.rows.length === 0) {
            return res.status(404).json({ success: false, message: 'Promoción no encontrada' });
        }
        res.json({ success: true, promocion: promo.rows[0] });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: 'Error cargando datos' });
    }
};

// Buscar elementos globales (Servicios, Hoteles, Restaurantes, etc.)
const buscarElementos = async (req, res) => {
    const { tipo } = req.query; 
    try {
        // Llama a la función SQL de búsqueda global
        const result = await pool.query('SELECT * FROM get_elementos_busqueda($1)', [tipo]);
        
        // Agregamos flag para el frontend
        const data = result.rows.map(item => ({ ...item, asignado: false })); 
        res.json({ success: true, data });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// Buscar Habitaciones de un Hotel específico (Drill-down)
const buscarHabitacionesHotel = async (req, res) => {
    const { hotelId } = req.params;
    try {
        // Llama a la función SQL específica para habitaciones
        const result = await pool.query('SELECT * FROM get_habitaciones_por_hotel($1)', [hotelId]);
        const data = result.rows.map(item => ({ ...item, asignado: false }));
        res.json({ success: true, data });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// Asignar o Remover promoción (UPDATE para 1:N, INSERT para N:M)
const gestionarAsignacion = async (req, res) => {
    const { prom_codigo } = req.params;
    const { elementoId, tipoElemento, accion } = req.body; 

    try {
        await pool.query('CALL gestionar_asignacion_promocion($1, $2, $3, $4)', 
            [prom_codigo, elementoId, tipoElemento, accion]);
        
        res.json({ success: true, message: `Acción realizada: ${accion}` });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// =====================================================================
// 3. DETALLE DE ASIGNACIONES (MODAL OJO)
// =====================================================================

const getDetalleAsignaciones = async (req, res) => {
    const { id } = req.params;
    try {
        // Llama a la función SQL que devuelve el JSON completo
        const result = await pool.query('SELECT * FROM sp_obtener_detalle_promocion($1)', [id]);
        
        if (result.rows.length > 0) {
            res.status(200).json({ success: true, data: result.rows[0].detalle });
        } else {
            res.status(404).json({ success: false, message: 'No se encontraron detalles' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: error.message });
    }
};

module.exports = {
    obtenerPromociones,
    crearPromocion,
    actualizarPromocion,
    eliminarPromocion,
    getPromocionData,
    buscarElementos,
    buscarHabitacionesHotel,
    gestionarAsignacion,
    getDetalleAsignaciones
};