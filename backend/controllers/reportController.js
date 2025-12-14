const pool = require('../config/db');
const fs = require('fs');
const path = require('path');
const reportConfig = require('../config/reports.json');

const getReport = async (req, res) => {
    const { reportName } = req.params;
    const { fecha_inicio, fecha_fin } = req.query; // For filtering if needed

    // 1. Validate Report Name
    const templateFileName = reportConfig[reportName];
    if (!templateFileName) {
        return res.status(404).json({ success: false, message: 'Reporte no encontrado' });
    }

    // 2. Read Template
    const templatePath = path.join(__dirname, '../reports', templateFileName);
    let templateContent;
    try {
        templateContent = fs.readFileSync(templatePath, 'utf8');
    } catch (err) {
        console.error('Error reading template:', err);
        return res.status(500).json({ success: false, message: 'Error leyendo plantilla del reporte' });
    }

    // 3. Execute Query based on reportName
    let query = '';
    let values = [];

    try {
        switch (reportName) {
            case 'paquetes_vendidos':
                // Default date range if not provided
                const start = fecha_inicio || '2020-01-01';
                const end = fecha_fin || new Date().toISOString().split('T')[0];
                values = [start, end];
                query = `
                    WITH ResumenServicios AS (
                        SELECT 
                            ps.fk_paq_tur_codigo,
                            STRING_AGG(ps.cantidad || ' ' || s.ser_tipo || ' (' || s.ser_nombre || ')', ' + ') AS txt_servicios
                        FROM paq_ser ps
                        JOIN servicio s ON ps.fk_ser_codigo = s.ser_codigo
                        GROUP BY ps.fk_paq_tur_codigo
                    ),
                    ResumenTraslados AS (
                        SELECT 
                            pt.fk_paq_tur_codigo,
                            STRING_AGG('Traslado ' || r.rut_tipo, ' + ') AS txt_traslados
                        FROM paq_tras pt
                        JOIN traslado t ON pt.fk_tras_codigo = t.tras_codigo
                        JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
                        GROUP BY pt.fk_paq_tur_codigo
                    )
                    SELECT 
                        c.com_fecha AS fecha_venta,
                        p.paq_tur_nombre AS nombre_paquete,
                        CONCAT_WS(' + ', rt.txt_traslados, rs.txt_servicios) AS componentes_incluidos,
                        p.paq_tur_monto_total AS costo_total
                    FROM compra c
                    JOIN detalle_reserva dr ON c.com_codigo = dr.fk_compra
                    JOIN paquete_turistico p ON dr.fk_paquete_turistico = p.paq_tur_codigo
                    LEFT JOIN ResumenServicios rs ON p.paq_tur_codigo = rs.fk_paq_tur_codigo
                    LEFT JOIN ResumenTraslados rt ON p.paq_tur_codigo = rt.fk_paq_tur_codigo
                    WHERE c.com_fecha BETWEEN $1 AND $2
                      AND dr.det_res_estado = 'Confirmada'
                    ORDER BY c.com_fecha DESC
                `;
                break;

            case 'reembolsos':
                query = `
                    SELECT 
                        r.rem_codigo,
                        r.rem_monto_reembolsado,
                        r.rem_monto_retenido,
                        (r.rem_monto_reembolsado + r.rem_monto_retenido) as monto_original,
                        c.com_fecha,
                        CASE 
                            WHEN r.rem_monto_retenido = 0.10 * (r.rem_monto_reembolsado + r.rem_monto_retenido) THEN 'CORRECTO (10%)' 
                            ELSE 'INCORRECTO' 
                        END as validacion_regla
                    FROM reembolso r
                    JOIN pago pg ON r.fk_pago = pg.pag_codigo
                    JOIN compra c ON pg.fk_compra = c.com_codigo
                    JOIN detalle_reserva dr ON dr.fk_compra = c.com_codigo
                    WHERE r.rem_monto_retenido > 0 
                    GROUP BY r.rem_codigo, c.com_fecha, pg.pag_codigo
                `;
                break;

            case 'preferencias_vs_compras':
                query = `
                    SELECT 
                        u.usu_nombre_usuario,
                        cat.cat_nombre as preferencia_declarada,
                        COUNT(CASE WHEN p.paq_tur_descripcion = cat.cat_nombre THEN 1 END) as coincidencias_paquetes,
                        COUNT(CASE WHEN s.ser_descripcion = cat.cat_nombre THEN 1 END) as coincidencias_servicios,
                        COUNT(CASE WHEN rut.rut_descripcion = cat.cat_nombre THEN 1 END) as coincidencias_rutas
                    FROM usuario u
                    JOIN preferencia pref ON pref.fk_usuario = u.usu_codigo
                    JOIN categoria cat ON pref.fk_categoria = cat.cat_codigo
                    LEFT JOIN compra c ON c.fk_usuario = u.usu_codigo
                    LEFT JOIN detalle_reserva dr ON dr.fk_compra = c.com_codigo
                    LEFT JOIN paquete_turistico p ON dr.fk_paquete_turistico = p.paq_tur_codigo
                    LEFT JOIN servicio s ON dr.fk_servicio = s.ser_codigo
                    LEFT JOIN reserva_de_habitacion rh ON rh.fk_detalle_reserva = dr.det_res_codigo
                    LEFT JOIN paq_tras pt ON pt.fk_paq_tur_codigo = p.paq_tur_codigo
                    LEFT JOIN traslado t ON pt.fk_tras_codigo = t.tras_codigo
                    LEFT JOIN ruta rut ON t.fk_rut_codigo = rut.rut_codigo
                    GROUP BY u.usu_nombre_usuario, cat.cat_nombre
                `;
                break;

            case 'canje_millas':
                query = `
                    SELECT 
                        p.paq_tur_nombre,
                        p.paq_tur_costo_en_millas,
                        c.com_fecha,
                        (
                            SELECT STRING_AGG(s.ser_nombre, ', ')
                            FROM paq_ser ps
                            JOIN servicio s ON ps.fk_ser_codigo = s.ser_codigo
                            WHERE ps.fk_paq_tur_codigo = p.paq_tur_codigo
                        ) as servicios,
                        (
                            SELECT STRING_AGG(CONCAT(rut.rut_descripcion, ' (', t_tras.tras_fecha_hora_inicio, ')'), ', ')
                            FROM paq_tras pt
                            JOIN traslado t_tras ON pt.fk_tras_codigo = t_tras.tras_codigo
                            JOIN ruta rut ON t_tras.fk_rut_codigo = rut.rut_codigo
                            WHERE pt.fk_paq_tur_codigo = p.paq_tur_codigo
                        ) as traslados,
                        (
                            SELECT STRING_AGG(CONCAT(h.hot_nombre, ' - ', hab.hab_descripcion), ', ')
                            FROM reserva_de_habitacion rh
                            JOIN habitacion hab ON rh.fk_habitacion = hab.hab_num_hab
                            JOIN hotel h ON hab.fk_hotel = h.hot_codigo
                            WHERE rh.fk_paquete_turistico = p.paq_tur_codigo
                            AND rh.fk_detalle_reserva = dr.det_res_codigo
                        ) as reservas_hoteles,
                        (
                            SELECT STRING_AGG(CONCAT(res.res_nombre, ' (Mesa ', rr.res_rest_num_mesa, ')'), ', ')
                            FROM reserva_restaurante rr
                            JOIN restaurante res ON rr.fk_restaurante = res.res_codigo
                            WHERE rr.fk_paquete_turistico = p.paq_tur_codigo
                            AND rr.fk_detalle_reserva = dr.det_res_codigo
                        ) as reservas_restaurantes
                    FROM compra c
                    JOIN pago pg ON pg.fk_compra = c.com_codigo
                    JOIN metodo_pago mp ON pg.fk_metodo_pago = mp.met_pag_codigo
                    JOIN detalle_reserva dr ON dr.fk_compra = c.com_codigo
                    JOIN paquete_turistico p ON dr.fk_paquete_turistico = p.paq_tur_codigo
                    WHERE mp.met_pag_descripcion ILIKE '%Millas%'
                      AND c.com_fecha >= NOW() - INTERVAL '6 months'
                    ORDER BY p.paq_tur_costo_en_millas DESC
                    LIMIT 5
                `;
                break;

            case 'clientes_millas':
                query = `
                    SELECT 
                        u.usu_nombre_usuario,
                        u.usu_total_millas
                    FROM usuario u
                    WHERE NOT EXISTS (
                        SELECT 1 FROM compra c
                        JOIN pago pg ON pg.fk_compra = c.com_codigo
                        JOIN metodo_pago mp ON pg.fk_metodo_pago = mp.met_pag_codigo
                        WHERE c.fk_usuario = u.usu_codigo
                        AND mp.met_pag_descripcion ILIKE '%Millas%'
                    )
                    ORDER BY u.usu_total_millas DESC
                    LIMIT 20
                `;
                break;
            
            default:
                return res.status(400).json({ success: false, message: 'Reporte no implementado' });
        }

        const dbResult = await pool.query(query, values);

        // 4. Send to JSReport
        // Assuming JSReport is running on localhost:5488 (default)
        // Adjust URL as needed or use env var
        const jsreportUrl = process.env.JSREPORT_URL || 'http://localhost:5488/api/report';

        const body = {
            template: {
                content: templateContent,
                engine: 'handlebars',
                recipe: 'chrome-pdf'
            },
            data: {
                reportData: dbResult.rows,
                now: new Date().toLocaleString()
            }
        };

        const response = await fetch(jsreportUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(body)
        });

        if (!response.ok) {
            const errText = await response.text();
            console.error('JSReport Error:', errText);
            return res.status(500).json({ success: false, message: 'Error generando PDF en jsreport' });
        }

        // 5. Pipe PDF to response
        const pdfBuffer = await response.arrayBuffer();
        res.setHeader('Content-Type', 'application/pdf');
        res.setHeader('Content-Disposition', `attachment; filename=${reportName}.pdf`);
        res.send(Buffer.from(pdfBuffer));

    } catch (err) {
        console.error('Error in getReport:', err);
        res.status(500).json({ success: false, message: 'Error interno del servidor' });
    }
};

module.exports = {
    getReport
};
