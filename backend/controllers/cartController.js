const pool = require('../config/db');

// Procesa el checkout (Validación + Compra)
const processCheckout = async (req, res) => {
    const { user_id, viajeros, items, pago } = req.body;
    // viajeros: [1, 2, 3]
    // items: [{tipo: 'paquete', id: 1}, ...]
    
    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        // =================================================================
        // PASO 1: VALIDACIÓN DE REGLAS DE NEGOCIO (NUEVO)
        // =================================================================
        // Verificamos edad, millas, ubicación, etc. antes de procesar nada.
        
        const validQuery = `CALL sp_validar_reglas_compra($1, $2, $3, NULL, NULL)`;
        const validValues = [
            user_id,
            JSON.stringify(items),    // Enviamos items como JSON
            JSON.stringify(viajeros)  // Enviamos IDs viajeros como JSON
        ];

        const validResult = await client.query(validQuery, validValues);
        const validResp = validResult.rows[0]; // Postgres devuelve los OUT en rows[0]

        // Si la validación falla (o_valido = false), detenemos todo.
        if (validResp.o_valido === false) {
            await client.query('ROLLBACK');
            return res.status(409).json({ 
                success: false, 
                message: validResp.o_mensaje // Ej: "Error: El viajero Juan no tiene 18 años..."
            });
        }

        // =================================================================
        // PASO 2: CÁLCULO Y REGISTRO DE LA COMPRA (SI PASÓ LA VALIDACIÓN)
        // =================================================================

        let planFinanciamiento = {};
        let totalCompra = 0;
        
        // Calculamos el total aproximado (El SP final hará el cálculo real, pero esto sirve para el plan)
        items.forEach(i => {
            const precio = parseFloat(i.precio || i.costo || i.paq_tur_monto_total || 0);
            totalCompra += precio * viajeros.length;
        });

        // Configurar Plan de Financiamiento
        if (pago.plan === 'contado') {
            planFinanciamiento = { tipo: 'contado' };
        } else {
            const meses = pago.meses || (pago.plan === '3_meses' ? 3 : 12); 
            const inicial = totalCompra * 0.5; // Ejemplo: 50% de inicial
            planFinanciamiento = { 
                tipo: 'credito', 
                meses: meses, 
                inicial: inicial 
            };
        }

        // Llamada al SP de Registro de Compra (8 parámetros)
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
            await client.query('COMMIT');

            // Datos útiles para el modal de pago
            const compraId = respCompra.o_compra_id;
            const montoAPagar = parseFloat(respCompra.o_total);
            const origenTipo = (pago.plan === 'contado') ? 'compra' : 'cuota';
            const origenId = (pago.plan === 'contado') ? compraId : respCompra.o_primera_cuota_id; 

            res.status(200).json({ 
                success: true, 
                message: respCompra.o_mensaje,
                data: {
                    compra_id: compraId,
                    monto_pagar: montoAPagar,
                    origen_tipo: origenTipo,
                    origen_id: origenId
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
        res.status(500).json({ success: false, message: err.message });
    }
};

module.exports = {
    processCheckout,
    getMyTickets,
    markTicketUsed
};