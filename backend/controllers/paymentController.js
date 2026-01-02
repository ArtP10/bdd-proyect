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


const previewRefund = async (req, res) => {
    const { compra_id } = req.body;
    try {
        const result = await pool.query('SELECT * FROM sp_previsualizar_reembolso($1)', [compra_id]);
        res.json({ success: true, data: result.rows[0] });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};
// No olvides exportarlo y agregarlo a las rutas

// Pagar (Cuota o Compra Completa)
const payQuota = async (req, res) => {
    // AHORA RECIBIMOS 'origen' DESDE EL FRONTEND ('compra' o 'cuota')
    const { quota_id, pago, origen, monto } = req.body; 
    
    // quota_id: Es el ID de la Cuota O el ID de la Compra (dependiendo del origen)
    // origen: 'compra' (Contado) o 'cuota' (Crédito)

    try {
        let montoReal = 0;

        // 1. VALIDACIÓN DE MONTO SEGÚN EL TIPO
        if (origen === 'compra') {
            // Si es contado, validamos contra la tabla COMPRA
            const resCompra = await pool.query('SELECT com_monto_total FROM compra WHERE com_codigo = $1', [quota_id]);
            if(resCompra.rows.length === 0) return res.status(404).json({success:false, message: 'Compra no encontrada'});
            montoReal = resCompra.rows[0].com_monto_total;
        } else {
            // Si es crédito, validamos contra la tabla CUOTA (Lógica original)
            const resCuota = await pool.query('SELECT cuo_monto FROM cuota WHERE cuo_codigo = $1', [quota_id]);
            if(resCuota.rows.length === 0) return res.status(404).json({success:false, message: 'Cuota no encontrada'});
            montoReal = resCuota.rows[0].cuo_monto;
        }

        // Opcional: Validar que el monto enviado coincida con el real (seguridad)
        // if (Math.abs(monto - montoReal) > 0.1) ...

        // 2. LLAMADA AL SP (Pasamos el origen correcto)
        const query = `CALL sp_procesar_pago($1, $2, $3, $4, $5, $6, NULL, NULL)`;
        const values = [
            origen || 'cuota', // Default a cuota si no viene
            quota_id,          // ID
            montoReal,         // Monto Base de Datos
            pago.moneda || 'USD',
            pago.metodo,
            JSON.stringify(pago.datos)
        ];

        const result = await pool.query(query, values);
        const resp = result.rows[0];
        
        if(resp.o_status === 200) {
            res.json({ success: true, message: resp.o_mensaje });
        } else {
            res.status(400).json({ success: false, message: resp.o_mensaje });
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error procesando pago: ' + err.message });
    }
};

const requestRefund = async (req, res) => {
    const { compra_id } = req.body;

    try {
        // Llamada al SP que calcula la penalización y genera el "Pago Negativo"
        const query = `CALL sp_solicitar_reembolso($1, NULL, NULL, NULL)`;
        const values = [compra_id];

        const result = await pool.query(query, values);
        const resp = result.rows[0];

        if(resp.o_status === 200) {
            res.json({ success: true, message: resp.o_mensaje });
        } else {
            res.status(400).json({ success: false, message: resp.o_mensaje });
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error procesando reembolso: ' + err.message });
    }
};

const getRefundsList = async (req, res) => {
    const { user_id } = req.body;
    try {
        const result = await pool.query('SELECT * FROM sp_obtener_reembolsos_cliente($1)', [user_id]);
        res.json({ success: true, data: result.rows });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

const getPurchaseItems = async (req, res) => {
    const { compra_id } = req.body;
    try {
        // Llamada al nuevo SP que creamos
        const result = await pool.query('SELECT * FROM sp_obtener_items_compra($1)', [compra_id]);
        res.json({ success: true, data: result.rows });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: err.message });
    }
};

module.exports = { getPendingQuotas, getPaymentHistory, payQuota, requestRefund, previewRefund, getRefundsList, getPurchaseItems };