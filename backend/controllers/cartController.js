const pool = require('../config/db');

// Procesa el checkout (Validación + Compra)
const processCheckout = async (req, res) => {
    const { user_id, viajeros, items, pago } = req.body;
    
    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        // PASO 1: VALIDACIÓN DE REGLAS (Igual que antes)
        const validQuery = `CALL sp_validar_reglas_compra($1, $2, $3, NULL, NULL)`;
        const validValues = [
            user_id,
            JSON.stringify(items),
            JSON.stringify(viajeros)
        ];

        const validResult = await client.query(validQuery, validValues);
        const validResp = validResult.rows[0]; 

        if (validResp.o_valido === false) {
            await client.query('ROLLBACK');
            return res.status(409).json({ 
                success: false, 
                message: validResp.o_mensaje 
            });
        }

        // PASO 2: REGISTRO DE COMPRA
        let planFinanciamiento = {};
        let totalCompra = 0;
        
        items.forEach(i => {
            const precio = parseFloat(i.precio || i.costo || i.paq_tur_monto_total || 0);
            totalCompra += precio * viajeros.length;
        });

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

        const queryCompra = `CALL sp_registrar_compra($1, $2, $3, $4, NULL, NULL, NULL, NULL)`;
        const valuesCompra = [
            user_id, 
            JSON.stringify(viajeros), 
            JSON.stringify(items), 
            JSON.stringify(planFinanciamiento)
        ];

        const resultCompra = await client.query(queryCompra, valuesCompra);
        const respCompra = resultCompra.rows[0];

        if (respCompra.o_status === 200) {
            
            // ========================================================================
            // CORRECCIÓN APLICADA AQUÍ
            // ========================================================================
            const compraId = respCompra.o_compra_id;
            let montoAPagar = 0;
            let origenTipo = '';
            let origenId = 0;

            if (pago.plan === 'contado') {
                // Si es contado, se paga el total devuelto por el SP
                montoAPagar = parseFloat(respCompra.o_total);
                origenTipo = 'compra';
                origenId = compraId;
            } else {
                // Si es crédito, NO USAMOS o_total. Buscamos la primera cuota generada.
                // Esta consulta existía en tu versión "Working" y es necesaria.
                const resCuota = await client.query(
                    `SELECT cuo_codigo, cuo_monto FROM cuota 
                     JOIN plan_financiamiento pf ON cuota.fk_plan_financiamiento = pf.plan_fin_codigo
                     WHERE pf.fk_compra = $1 
                     ORDER BY cuo_fecha_tope ASC 
                     LIMIT 1`, 
                    [compraId]
                );
                
                if (resCuota.rows.length > 0) {
                    montoAPagar = parseFloat(resCuota.rows[0].cuo_monto); // Esto será el 50% exacto
                    origenTipo = 'cuota';
                    origenId = resCuota.rows[0].cuo_codigo; // Obtenemos el ID real
                } else {
                    throw new Error("Error interno: Se registró la compra crédito pero no se generaron cuotas.");
                }
            }
            // ========================================================================

            await client.query('COMMIT');

            res.status(200).json({ 
                success: true, 
                message: respCompra.o_mensaje,
                data: {
                    compra_id: compraId,
                    monto_pagar: montoAPagar, // Ahora sí lleva el monto correcto (50% o 100%)
                    origen_tipo: origenTipo,
                    origen_id: origenId       // Ahora sí lleva el ID correcto
                }
            });
        } else {
            throw new Error(respCompra.o_mensaje);
        }

    } catch (err) {
        await client.query('ROLLBACK');
        console.error("Error Checkout:", err);
        res.status(400).json({ success: false, message: err.message });
    } finally {
        client.release();
    }
};;

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
        res.status(500).json({ success: false, message: err.message });
    }
};

const getWishlistItemsForCart = async (req, res) => {
    const { user_id } = req.body; 

    try {
        const result = await pool.query(
            'SELECT * FROM mostrar_wishlist_filtrada($1, $2)', 
            [user_id, 'TODO']
        );

        const items = result.rows.map(row => ({
            id_original: row.codigo_producto,
            nombre: row.nombre_producto,
            precio: row.precio_final, 
            tipo: row.tipo_producto.toLowerCase(),
            fecha_inicio: row.fecha_inicio,
            millas: row.millas || 0 
        }));

        res.json({ success: true, data: items });
    } catch (err) {
        console.error("Error fetching wishlist for cart:", err);
        res.status(500).json({ success: false, message: err.message });
    }
};

module.exports = { 
    processCheckout, 
    getMyTickets, 
    markTicketUsed, 
    getWishlistItemsForCart 
};
