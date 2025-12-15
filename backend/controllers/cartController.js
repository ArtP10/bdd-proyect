const pool = require('../config/db');

// Procesa el checkout completo
const processCheckout = async (req, res) => {
    const { user_id, viajeros, items, pago } = req.body;

    try {
        const jsonViajeros = JSON.stringify(viajeros);
        const jsonItems = JSON.stringify(items);
        const jsonPago = JSON.stringify(pago);

        // NOTA: Postgres devuelve los valores INOUT en result.rows[0]
        const query = `CALL sp_procesar_compra($1, $2, $3, $4, NULL, NULL, NULL)`;
        const values = [user_id, jsonViajeros, jsonItems, jsonPago];

        const client = await pool.connect();
        try {
            const result = await client.query(query, values);
            const dbResponse = result.rows[0]; // Aquí recibimos o_status y o_mensaje

            // Validamos lo que dijo la base de datos
            if (dbResponse.o_status === 200) {
                res.status(200).json({ 
                    success: true, 
                    message: dbResponse.o_mensaje,
                    compra_id: dbResponse.o_compra_id
                });
            } else {
                // Si el SP devolvió error (400 o 500)
                console.error("Error lógico en BD:", dbResponse.o_mensaje);
                res.status(400).json({ 
                    success: false, 
                    message: dbResponse.o_mensaje // Este mensaje dirá EXACTAMENTE qué falló
                });
            }
        } finally {
            client.release();
        }
    } catch (err) {
        console.error("Error crítico checkout:", err);
        res.status(500).json({ success: false, message: 'Error de conexión o base de datos.' });
    }
};

// Obtener tickets para el dashboard
const getMyTickets = async (req, res) => {
    const { user_id } = req.body; // O req.params
    try {
        const result = await pool.query('SELECT * FROM sp_obtener_tickets_cliente($1)', [user_id]);
        res.json({ success: true, data: result.rows });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

module.exports = { processCheckout, getMyTickets };