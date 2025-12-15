const pool = require('../config/db');

// Obtener Cuotas
const getPendingQuotas = async (req, res) => {
    const { user_id } = req.body;
    try {
        const result = await pool.query('SELECT * FROM sp_obtener_cuotas_cliente($1)', [user_id]);
        res.json({ success: true, data: result.rows });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

// Obtener Historial
const getPaymentHistory = async (req, res) => {
    const { user_id } = req.body;
    try {
        const result = await pool.query('SELECT * FROM sp_obtener_historial_pagos($1)', [user_id]);
        res.json({ success: true, data: result.rows });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

// Pagar Cuota
const payQuota = async (req, res) => {
    const { quota_id, pago } = req.body; // pago es el objeto JSON {metodo, datos...}
    try {
        const query = `CALL sp_pagar_cuota($1, $2, NULL, NULL)`;
        const result = await pool.query(query, [quota_id, JSON.stringify(pago)]);
        const resp = result.rows[0];
        
        if(resp.o_status === 200) {
            res.json({ success: true, message: resp.o_mensaje });
        } else {
            res.status(400).json({ success: false, message: resp.o_mensaje });
        }
    } catch (err) {
        res.status(500).json({ success: false, message: 'Error procesando pago' });
    }
};

// Solicitar Reembolso
const requestRefund = async (req, res) => {
    const { payment_id } = req.body;
    try {
        const query = `CALL sp_solicitar_reembolso($1, NULL, NULL)`;
        const result = await pool.query(query, [payment_id]);
        const resp = result.rows[0];
        
        if(resp.o_status === 200) {
            res.json({ success: true, message: resp.o_mensaje });
        } else {
            res.status(400).json({ success: false, message: resp.o_mensaje });
        }
    } catch (err) {
        res.status(500).json({ success: false, message: 'Error solicitando reembolso' });
    }
};

module.exports = { getPendingQuotas, getPaymentHistory, payQuota, requestRefund };