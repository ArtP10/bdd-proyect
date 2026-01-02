const pool = require('../config/db');

// Procesa el checkout
const processCheckout = async (req, res) => {
    const { user_id, viajeros, items, pago } = req.body;

    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        let planFinanciamiento = {};
        let totalCompra = 0;
        
        items.forEach(i => {
            const precio = parseFloat(i.precio || i.costo || i.paq_tur_monto_total || 0);
            totalCompra += precio * viajeros.length;
        });

        // Configurar Plan
        if (pago.plan === 'contado') {
            planFinanciamiento = { tipo: 'contado' };
        } else {
            const meses = pago.meses || (pago.plan === '3_meses' ? 3 : 12); 
            const inicial = totalCompra * 0.5;
            planFinanciamiento = { 
                tipo: 'credito', 
                meses: meses, 
                inicial: inicial 
            };
        }

        // Llamada al SP (8 parámetros)
        const queryCompra = `CALL sp_registrar_compra($1, $2, $3, $4, NULL, NULL, NULL, NULL)`;
        const valuesCompra = [
            user_id, 
            JSON.stringify(viajeros), 
            JSON.stringify(items), 
            JSON.stringify(planFinanciamiento)
        ];

        const resCompra = await client.query(queryCompra, valuesCompra);
        const dbCompra = resCompra.rows[0];

        if (dbCompra.o_status !== 200) {
            throw new Error(dbCompra.o_mensaje);
        }

        const compraId = dbCompra.o_compra_id;

        // --- IDENTIFICAR EL PAGO INICIAL ---
        let montoAPagar = 0;
        let origenTipo = '';
        let origenId = 0;

        if (pago.plan === 'contado') {
            montoAPagar = parseFloat(dbCompra.o_total);
            origenTipo = 'compra';
            origenId = compraId;
        } else {
            // SI ES CRÉDITO: Buscamos la PRIMERA CUOTA por fecha (La inicial)
            const resCuota = await client.query(
                `SELECT cuo_codigo, cuo_monto FROM cuota 
                 JOIN plan_financiamiento pf ON cuota.fk_plan_financiamiento = pf.plan_fin_codigo
                 WHERE pf.fk_compra = $1 
                 ORDER BY cuo_fecha_tope ASC 
                 LIMIT 1`, 
                [compraId]
            );
            
            if (resCuota.rows.length > 0) {
                montoAPagar = parseFloat(resCuota.rows[0].cuo_monto);
                origenTipo = 'cuota';
                origenId = resCuota.rows[0].cuo_codigo;
            } else {
                throw new Error("Error interno: No se generaron cuotas.");
            }
        }

        await client.query('COMMIT');

        res.status(200).json({ 
            success: true, 
            message: 'Reserva creada exitosamente. Proceda al pago.',
            data: {
                compra_id: compraId,
                monto_pagar: montoAPagar,
                origen_tipo: origenTipo,
                origen_id: origenId
            }
        });

    } catch (err) {
        await client.query('ROLLBACK');
        console.error("Error Registrar Compra:", err);
        res.status(400).json({ success: false, message: err.message });
    } finally {
        client.release();
    }
};

const getMyTickets = async (req, res) => {
    const { user_id } = req.body;
    try {
        const result = await pool.query('SELECT * FROM sp_obtener_tickets_cliente($1)', [user_id]);
        res.json({ success: true, data: result.rows });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};


const markTicketUsed = async (req, res) => {
    const { ticket_id } = req.body;
    try {
        const query = `CALL sp_marcar_ticket_usado($1, NULL, NULL)`;
        const result = await pool.query(query, [ticket_id]);
        const resp = result.rows[0];

        if (resp.o_status === 200) {
            res.json({ success: true, message: resp.o_mensaje });
        } else {
            res.status(400).json({ success: false, message: resp.o_mensaje });
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: err.message });
    }
};

module.exports = { processCheckout, getMyTickets, markTicketUsed };