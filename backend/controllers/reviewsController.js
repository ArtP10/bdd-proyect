const pool = require('../config/db');

const createReview = async (req, res) => {
    const { ticket_id, rating, comment } = req.body;
    
    try {
        // Llamamos a la FUNCTION con SELECT
        const result = await pool.query(
            'SELECT sp_registrar_resena($1, $2, $3) as respuesta', 
            [ticket_id, rating, comment]
        );
        
        // Extraemos el JSON retornado
        const dbResponse = result.rows[0].respuesta;

        if (dbResponse.status === 200) {
            res.json({ success: true, message: dbResponse.message });
        } else {
            // Si es 400, 409 o 500, enviamos error al frontend
            console.error("Error lógico en BD:", dbResponse.message);
            res.status(dbResponse.status).json({ success: false, message: dbResponse.message });
        }

    } catch (err) {
        console.error("Error de conexión/servidor:", err);
        res.status(500).json({ success: false, message: 'Error interno del servidor' });
    }
};

const getProductReviews = async (req, res) => {
    const { id, type } = req.params; // /api/reviews/product/:type/:id
    try {
        const result = await pool.query('SELECT * FROM sp_obtener_resenas_producto($1, $2)', [id, type]);
        res.json({ success: true, data: result.rows });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error obteniendo reseñas' });
    }
};

const getUserReviews = async (req, res) => {
    const { userId } = req.params;
    try {
        const result = await pool.query('SELECT * FROM sp_obtener_mis_resenas($1)', [userId]);
        res.json({ success: true, data: result.rows });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error obteniendo historial' });
    }
};

module.exports = { createReview, getProductReviews, getUserReviews };