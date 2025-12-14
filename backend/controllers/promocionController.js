// 1. CORRECCIÓN IMPORTANTE:
// Asegúrate de que la ruta sea '../db' (donde creamos el index.js)
// Y llámalo 'db' para que coincida con el resto de tu código.
const db = require('../config/db');

const crearPromocion = async (req, res) => {
  // 1. Desestructuramos los datos
  const { nombre, descripcion, fecha_vencimiento, descuento } = req.body;

  try {
    // 2. Ejecutamos el Stored Procedure
    // Ahora sí funcionará porque 'db' está definido arriba
    await db.query(
      `CALL registrar_promocion($1, $2, $3, $4)`,
      [nombre, descripcion, fecha_vencimiento, descuento]
    );

    // 3. Respuesta exitosa
    res.status(201).json({
      success: true,
      message: 'Promoción registrada exitosamente'
    });

  } catch (error) {
    console.error("Error SQL Detallado:", error); // Esto te ayuda a ver errores en la terminal
    res.status(500).json({
      success: false,
      error: 'Error al guardar en base de datos: ' + error.message
    });
  }
};

const obtenerPromociones = async (req, res) => {
  try {
    // Simplemente traemos todo y lo enviamos
    const result = await db.query('SELECT * FROM promocion ORDER BY prom_codigo DESC');
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error al obtener:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

const actualizarPromocion = async (req, res) => {
  // El ID viene en la URL (ej: /api/promociones/5)
  const { id } = req.params;
  // Los datos vienen en el cuerpo
  const { nombre, descripcion, fecha_vencimiento, descuento } = req.body;

  try {
    await db.query(
      `CALL editar_promocion($1, $2, $3, $4, $5)`,
      [id, nombre, descripcion, fecha_vencimiento, descuento]
    );

    res.status(200).json({
      success: true,
      message: 'Promoción actualizada correctamente'
    });

  } catch (error) {
    console.error("Error al actualizar:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

const eliminarPromocion = async (req, res) => {
  const { id } = req.params; // El ID viene de la URL
  try {
    await db.query(
      `CALL eliminar_promocion($1)`,
      [id]
    );

    res.status(200).json({
      success: true,
      message: 'Promoción eliminada correctamente'
    });

  } catch (error) {
    console.error("Error al eliminar:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// Obtener listas para los select (Paquetes, Servicios, etc.)
const obtenerListasAsignacion = async (req, res) => {
  try {
    const paquetes = await db.query('SELECT paq_tur_codigo AS id, paq_tur_nombre AS nombre FROM paquete_turistico');
    const servicios = await db.query('SELECT ser_codigo AS id, ser_nombre AS nombre, ser_tipo FROM servicio');
    const traslados = await db.query('SELECT tras_codigo AS id, tras_fecha_hora_inicio AS nombre FROM traslado');
    // Para traslados concatenamos fecha como nombre identificador
    const habitaciones = await db.query(`
            SELECT h.hab_num_hab AS id, hot.hot_nombre || ' - ' || h.hab_descripcion AS nombre 
            FROM habitacion h 
            JOIN hotel hot ON h.fk_hotel = hot.hot_codigo
        `);

    res.json({
      paquetes: paquetes.rows,
      servicios: servicios.rows,
      traslados: traslados.rows,
      habitaciones: habitaciones.rows
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
};

// Función para asignar promoción según el tipo
const asignarPromocion = async (req, res) => {
  // Recibimos: { tipo: 'paquete'|'servicio'|'traslado'|'habitacion', idItem: 1, idPromocion: 5 }
  const { tipo, idItem, idPromocion } = req.body;

  let query = '';
  let params = [idItem, idPromocion];

  try {
    switch (tipo) {
      case 'paquete':
        query = 'CALL asignar_promo_paquete($1, $2)';
        break;
      case 'servicio':
        query = 'CALL asignar_promo_servicio($1, $2)';
        break;
      case 'traslado':
        query = 'CALL asignar_promo_traslado($1, $2)';
        break;
      case 'habitacion':
        query = 'CALL asignar_promo_habitacion($1, $2)';
        break;
      default:
        return res.status(400).json({ success: false, message: 'Tipo de asignación no válido' });
    }

    await db.query(query, params);
    res.json({ success: true, message: 'Asignación realizada con éxito' });

  } catch (error) {
    console.error("Error al asignar:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};


// const db = require('../config/db'); // Asume que tienes un pool de conexión
// const { pool } = require('../config/db'); // Ejemplo de pg-pool


const getPromocionData = async (req, res) => {
    try {
        const { prom_codigo } = req.params;
        const promoRes = await pool.query('SELECT * FROM Promocion WHERE prom_codigo = $1', [prom_codigo]);

        if (promoRes.rows.length === 0) {
            return res.status(404).json({ error: 'Promoción no encontrada' });
        }
        
        // Asume que tienes una tabla de Lugares para obtener los estados
        const estadosRes = await pool.query("SELECT lugar_nombre FROM Lugar WHERE lugar_codigo_padre IS NULL"); // O la lógica para obtener solo Estados/Regiones

        res.json({
            promocion: promoRes.rows[0],
            estados: estadosRes.rows.map(row => row.lugar_nombre)
        });

    } catch (error) {
        console.error('Error al obtener datos de la promoción:', error);
        res.status(500).json({ error: 'Error interno del servidor.' });
    }
};

const buscarElementos = async (req, res) => {
    const { prom_codigo } = req.params;
    const { estado, tipo } = req.query; // estado='Miranda', tipo='traslado_aereo'

    if (!estado || !tipo) {
        return res.status(400).json({ error: 'Faltan parámetros de búsqueda (estado o tipo).' });
    }

    try {
        // Llama al SP de búsqueda (usando SELECT * FROM para un SP/Function que retorna tabla)
        const sql = `SELECT * FROM get_elementos_busqueda($1, $2, $3)`;
        const result = await pool.query(sql, [estado, tipo, prom_codigo]);
        
        res.json(result.rows);

    } catch (error) {
        console.error('Error al ejecutar la búsqueda de elementos:', error);
        res.status(500).json({ error: 'Error interno del servidor al buscar.' });
    }
};

const gestionarAsignacion = async (req, res) => {
    const { prom_codigo } = req.params;
    const { elementoId, tipoElemento, accion } = req.body; // accion='aplicar' o 'remover'

    if (!elementoId || !tipoElemento || !accion) {
        return res.status(400).json({ error: 'Faltan parámetros (elementoId, tipoElemento, o accion).' });
    }

    // Normaliza el tipo de elemento para el SP (quitando el detalle de aéreo, etc.)
    const tipoNormalizado = tipoElemento.startsWith('traslado') ? 'traslado' : tipoElemento;
    
    try {
        if (accion === 'aplicar') {
            await pool.query('CALL asignar_promocion_elemento($1, $2, $3)', 
                [prom_codigo, elementoId, tipoNormalizado]);
            return res.status(200).json({ mensaje: 'Promoción aplicada con éxito.' });
        } else if (accion === 'remover') {
            await pool.query('CALL quitar_promocion_elemento($1, $2, $3)', 
                [prom_codigo, elementoId, tipoNormalizado]);
            return res.status(200).json({ mensaje: 'Promoción removida con éxito.' });
        } else {
            return res.status(400).json({ error: 'Acción no válida.' });
        }

    } catch (error) {
        console.error('Error al gestionar la asignación/desvinculación:', error);
        res.status(500).json({ error: 'Error al procesar la solicitud.' });
    }
};

// ... otros métodos de edición si son necesarios ...

module.exports = {
    getPromocionData,
    buscarElementos,
    gestionarAsignacion,
};

module.exports = {
  crearPromocion,
  obtenerPromociones,
  actualizarPromocion,
  eliminarPromocion,
  obtenerListasAsignacion,
  asignarPromocion,
  getPromocionData,
    buscarElementos,
    gestionarAsignacion,
};;