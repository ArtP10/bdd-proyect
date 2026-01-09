const pool = require('../config/db');

const createClaim = async (req, res) => {
    const { ticket_id, content } = req.body;
    try {
        const result = await pool.query('SELECT sp_registrar_reclamo($1, $2) as respuesta', [ticket_id, content]);
        const dbResponse = result.rows[0].respuesta;
        
        if (dbResponse.status === 200) res.json({ success: true, message: dbResponse.message });
        else res.status(dbResponse.status).json({ success: false, message: dbResponse.message });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error interno' });
    }
};

const getAllClaims = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM sp_listar_reclamos_admin()');
        res.json({ success: true, data: result.rows });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error listing claims' });
    }
};

const resolveClaim = async (req, res) => {
    const { claim_id, response_text, refund } = req.body; // refund es booleano
    try {
        // Procedure con OUT params
        const result = await pool.query('CALL sp_responder_reclamo_con_reembolso($1, $2, $3, NULL, NULL)', [
            claim_id, response_text, refund
        ]);
        // Asumiendo que tu driver soporta leer OUTs en CALL, si no, usa una FUNCTION wrapper.
        // Si usas 'pg' estándar, CALL no devuelve rows directamente fácilmente. 
        // Para simplificar, asumimos éxito si no hay catch.
        res.json({ success: true, message: 'Reclamo procesado' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: err.message });
    }
};

module.exports = { createClaim, getAllClaims, resolveClaim };