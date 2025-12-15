// backend/controllers/reportController.js

// Importaciones necesarias
const jsreport = require('@jsreport/jsreport-core')();
const pool = require('../config/db');

// Inicializar jsreport con los plugins
jsreport.use(require('@jsreport/jsreport-handlebars')());
jsreport.use(require('@jsreport/jsreport-chrome-pdf')());

const initPromise = jsreport.init();
const generarReportePaquetes = async (req, res) => {
    try {
        // ---------------------------------------------------------
        // 1. LA CONSULTA SQL (Extraída de tu archivo Jasper XML)
        // ---------------------------------------------------------

        await initPromise;
        const query = `
            SELECT 
                c.com_fecha AS fecha_venta,
                u.usu_nombre_usuario AS cliente,
                p.paq_tur_nombre AS nombre_paquete,
                
                -- 1. SERVICIOS TOTALES
                CONCAT_WS(' + ', 
                    NULLIF(STRING_AGG(DISTINCT 
                        ps.cantidad || ' ' || s.ser_nombre || ' (' || s.ser_tipo || ')', 
                        ' + '
                    ), ''),
                    NULLIF(STRING_AGG(DISTINCT 
                        'Reserva Hotel: ' || h.hot_nombre || ' - ' || hab.hab_descripcion, 
                        ' + '
                    ), ''),
                    NULLIF(STRING_AGG(DISTINCT 
                        'Reserva Restaurante: ' || res.res_nombre || ' (Mesa para ' || rr.res_rest_tamano_mesa || ')', 
                        ' + '
                    ), '')
                ) AS servicios_y_reservas_incluidos,

                -- 2. TRASLADOS
                STRING_AGG(DISTINCT 
                    'Traslado ' || r.rut_tipo || ': ' || tor.ter_nombre || ' -> ' || tde.ter_nombre, 
                    ' + '
                ) AS traslados_incluidos,

                -- Costo total
                p.paq_tur_monto_total AS costo_total

            FROM compra c
            INNER JOIN usuario u ON c.fk_usuario = u.usu_codigo
            INNER JOIN detalle_reserva dr ON c.com_codigo = dr.fk_compra
            INNER JOIN paquete_turistico p ON dr.fk_paquete_turistico = p.paq_tur_codigo
            INNER JOIN paq_ser ps ON p.paq_tur_codigo = ps.fk_paq_tur_codigo
            INNER JOIN servicio s ON ps.fk_ser_codigo = s.ser_codigo
            INNER JOIN paq_tras pt ON p.paq_tur_codigo = pt.fk_paq_tur_codigo
            INNER JOIN traslado t ON pt.fk_tras_codigo = t.tras_codigo
            INNER JOIN ruta r ON t.fk_rut_codigo = r.rut_codigo
            INNER JOIN terminal tor ON r.fk_terminal_origen = tor.ter_codigo
            INNER JOIN terminal tde ON r.fk_terminal_destino = tde.ter_codigo
            LEFT JOIN reserva_de_habitacion rh ON dr.fk_compra = rh.fk_detalle_reserva AND dr.det_res_codigo = rh.fk_detalle_reserva_2
            LEFT JOIN habitacion hab ON rh.fk_habitacion = hab.hab_num_hab
            LEFT JOIN hotel h ON hab.fk_hotel = h.hot_codigo
            LEFT JOIN reserva_restaurante rr ON dr.fk_compra = rr.fk_detalle_reserva AND dr.det_res_codigo = rr.fk_detalle_reserva_2
            LEFT JOIN restaurante res ON rr.fk_restaurante = res.res_codigo

            -- Filtro de fecha (Ejemplo año 2025 como estaba en tu XML)
            WHERE c.com_fecha BETWEEN '2025-01-01' AND '2025-12-31'

            GROUP BY 
                c.com_codigo, 
                c.com_fecha, 
                u.usu_nombre_usuario, 
                p.paq_tur_nombre, 
                p.paq_tur_monto_total

            ORDER BY c.com_fecha ASC;
        `;

        const response = await pool.query(query);
        
        // Formateamos la fecha para que se vea bonita (DD/MM/YYYY) antes de enviarla al HTML
        const datosFormateados = response.rows.map(row => ({
            ...row,
            fecha_venta: new Date(row.fecha_venta).toLocaleDateString('es-ES'),
            // Nos aseguramos que si es null, salga vacío
            servicios_y_reservas_incluidos: row.servicios_y_reservas_incluidos || '-',
            traslados_incluidos: row.traslados_incluidos || '-'
        }));

        // ---------------------------------------------------------
        // 2. LA PLANTILLA HTML (Diseñada para parecerse a tu Jasper)
        // ---------------------------------------------------------
        const htmlTemplate = `
            <html>
            <head>
                <style>
                    body { font-family: 'Segoe UI', Arial, sans-serif; margin: 0; padding: 20px; }
                    
                    /* Encabezado Azul */
                    .header-bg { background-color: #0056B3; color: white; padding: 20px; margin-bottom: 20px; border-radius: 5px; }
                    .header-title { font-size: 26px; font-weight: bold; margin: 0; }
                    .header-subtitle { font-size: 14px; margin-top: 5px; }
                    .header-date { float: right; font-size: 12px; margin-top: -40px; }

                    /* Tabla */
                    table { width: 100%; border-collapse: collapse; font-size: 11px; }
                    
                    /* Encabezados de Columna (Estilo Jasper: Azul sobre Gris) */
                    th { 
                        background-color: #E9ECEF; 
                        color: #0056B3; 
                        font-weight: bold; 
                        text-align: left; 
                        padding: 10px;
                        border-bottom: 2px solid #0056B3;
                    }
                    
                    td { padding: 8px 10px; border-bottom: 1px solid #E0E0E0; vertical-align: top; }
                    
                    /* Filas alternadas */
                    tr:nth-child(even) { background-color: #F8F9FA; }

                    /* Footer */
                    .footer { margin-top: 30px; font-size: 10px; color: #6C757D; border-top: 1px solid #E9ECEF; padding-top: 10px; }
                    .text-right { text-align: right; }
                    .text-center { text-align: center; }
                </style>
            </head>
            <body>
                <div class="header-bg">
                    <div class="header-title">Viajes UCAB</div>
                    <div class="header-subtitle">Listado General de Paquetes Turísticos</div>
                    <div class="header-date">Generado: {{fechaGeneracion}}</div>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th width="10%">Fecha</th>
                            <th width="12%">Cliente</th>
                            <th width="15%">Paquete</th>
                            <th width="30%">Servicios y Reservas</th>
                            <th width="23%">Traslados</th>
                            <th width="10%" class="text-right">Monto Total</th>
                        </tr>
                    </thead>
                    <tbody>
                        {{#each datos}}
                        <tr>
                            <td class="text-center">{{fecha_venta}}</td>
                            <td>{{cliente}}</td>
                            <td>{{nombre_paquete}}</td>
                            <td>{{servicios_y_reservas_incluidos}}</td>
                            <td>{{traslados_incluidos}}</td>
                            <td class="text-right">{{costo_total}} $</td>
                        </tr>
                        {{/each}}
                    </tbody>
                </table>

                <div class="footer">
                    Generado por Sistema CerebroUCAB
                </div>
            </body>
            </html>
        `;

        // ---------------------------------------------------------
        // 3. GENERAR PDF
        // ---------------------------------------------------------

        
        const result = await jsreport.render({
            template: {
                content: htmlTemplate,
                engine: 'handlebars',
                recipe: 'chrome-pdf',
                chrome: {
                    format: 'A4',
                    landscape: true, // Ponemos horizontal como en tu XML
                    margin: { top: '20px', bottom: '20px', left: '20px', right: '20px' }
                }
            },
            data: {
                datos: datosFormateados,
                fechaGeneracion: new Date().toLocaleDateString('es-ES')
            }
        });

        res.setHeader('Content-Type', 'application/pdf');
        res.setHeader('Content-Disposition', 'attachment; filename=ReportePaquetesModerno.pdf');
        result.stream.pipe(res);

    } catch (error) {
        console.error("Error generando reporte:", error);
        res.status(500).json({ error: "Error al generar el PDF: " + error.message });
    }
};
// backend/controllers/reportController.js

// ... (El resto de tus imports y la función generarReportePaquetes siguen igual arriba) ...

const generarReporteTopMillas = async (req, res) => {
    try {
        await initPromise;
        // 1. LA CONSULTA SQL (Extraída de tu XML)
        const query = `
            SELECT 
                pt.paq_tur_nombre AS nombre_paquete,
                pt.paq_tur_costo_en_millas AS costo_en_millas,
                COUNT(dr.det_res_codigo) AS cantidad_canjes,
                MAX(c.com_fecha) AS fecha_ultimo_canje
            FROM paquete_turistico pt
            JOIN detalle_reserva dr ON pt.paq_tur_codigo = dr.fk_paquete_turistico
            JOIN compra c ON dr.fk_compra = c.com_codigo
            JOIN pago pg ON c.com_codigo = pg.fk_compra
            JOIN metodo_pago mp ON pg.fk_metodo_pago = mp.met_pag_codigo
            WHERE 
                (mp.met_pag_codigo = 10 OR mp.met_pag_descripcion ILIKE '%millas%')
                AND c.com_fecha >= CURRENT_DATE - INTERVAL '6 months'
            GROUP BY 
                pt.paq_tur_codigo, 
                pt.paq_tur_nombre, 
                pt.paq_tur_costo_en_millas
            ORDER BY 
                pt.paq_tur_costo_en_millas DESC
            LIMIT 5;
        `;

        const response = await pool.query(query);

        // Formateo de datos para la vista
        const datosFormateados = response.rows.map(row => ({
            nombre_paquete: row.nombre_paquete,
            // Formatear números (ej: 1.500)
            costo_en_millas: Number(row.costo_en_millas).toLocaleString('es-ES'), 
            cantidad_canjes: row.cantidad_canjes,
            fecha_ultimo_canje: new Date(row.fecha_ultimo_canje).toLocaleDateString('es-ES')
        }));

        // 2. PLANTILLA HTML (Diseño Vertical)
        const htmlTemplate = `
            <html>
            <head>
                <style>
                    body { font-family: 'Segoe UI', Arial, sans-serif; margin: 0; padding: 20px; }
                    
                    /* Encabezado Azul */
                    .header-bg { background-color: #0056B3; color: white; padding: 20px; margin-bottom: 20px; border-radius: 5px; }
                    .header-title { font-size: 22px; font-weight: bold; margin: 0; }
                    .header-subtitle { font-size: 12px; margin-top: 5px; }
                    .header-date { float: right; font-size: 11px; margin-top: -35px; }

                    /* Tabla */
                    table { width: 100%; border-collapse: collapse; font-size: 10px; }
                    
                    th { 
                        background-color: #E9ECEF; 
                        color: #0056B3; 
                        font-weight: bold; 
                        text-align: left; 
                        padding: 10px;
                        border-bottom: 2px solid #0056B3;
                    }
                    
                    td { padding: 8px 10px; border-bottom: 1px solid #E0E0E0; vertical-align: middle; }
                    tr:nth-child(even) { background-color: #F8F9FA; }

                    /* Alineaciones específicas */
                    .text-right { text-align: right; }
                    .text-center { text-align: center; }
                    .bold { font-weight: bold; }

                    .footer { margin-top: 30px; font-size: 9px; color: #6C757D; border-top: 1px solid #E9ECEF; padding-top: 10px; }
                </style>
            </head>
            <body>
                <div class="header-bg">
                    <div class="header-title">Viajes UCAB</div>
                    <div class="header-subtitle">Top 5 Paquetes Canjeados por Millas (Ultimo Semestre)</div>
                    <div class="header-date">{{fechaGeneracion}}</div>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th width="40%">Paquete Turístico</th>
                            <th width="20%" class="text-right">Costo (Millas)</th>
                            <th width="20%" class="text-center">Total Canjes</th>
                            <th width="20%" class="text-center">Último Canje</th>
                        </tr>
                    </thead>
                    <tbody>
                        {{#each datos}}
                        <tr>
                            <td>{{nombre_paquete}}</td>
                            <td class="text-right bold">{{costo_en_millas}}</td>
                            <td class="text-center">{{cantidad_canjes}}</td>
                            <td class="text-center">{{fecha_ultimo_canje}}</td>
                        </tr>
                        {{/each}}
                    </tbody>
                </table>

                <div class="footer">
                    Generado por Sistema UCAB
                </div>
            </body>
            </html>
        `;

        // 3. GENERAR PDF
        
        const result = await jsreport.render({
            template: {
                content: htmlTemplate,
                engine: 'handlebars',
                recipe: 'chrome-pdf',
                chrome: {
                    format: 'A4',
                    landscape: false, // Este reporte es Vertical (Portrait) según el XML
                    margin: { top: '20px', bottom: '20px', left: '20px', right: '20px' }
                }
            },
            data: {
                datos: datosFormateados,
                fechaGeneracion: new Date().toLocaleDateString('es-ES')
            }
        });

        res.setHeader('Content-Type', 'application/pdf');
        res.setHeader('Content-Disposition', 'attachment; filename=Top5_Millas.pdf');
        result.stream.pipe(res);

    } catch (error) {
        console.error("Error generando reporte:", error);
        res.status(500).json({ error: "Error al generar el PDF" });
    }
};
// backend/controllers/reportController.js

// ... (Tus otras funciones generarReportePaquetes y generarReporteTopMillas siguen arriba) ...

const generarReporteAuditoria = async (req, res) => {
    try {
        // 1. CONSULTA SQL (Traducida de tu XML)
        await initPromise;
        const query = `
            SELECT 
                u.usu_nombre_usuario AS cliente,
                c.com_fecha AS fecha_cancelacion,
                p_orig.pag_monto AS monto_pagado_original,
                (p_orig.pag_monto * 0.10) AS penalizacion_10_porciento,
                (p_orig.pag_monto * 0.90) AS reembolso_esperado_90,
                p_reemb.pag_monto AS reembolso_real_ejecutado,
                CASE 
                    WHEN p_reemb.pag_monto = (p_orig.pag_monto * 0.90) THEN 'CORRECTO'
                    ELSE 'ERROR EN CALCULO'
                END AS estado_auditoria
            FROM compra c
            JOIN usuario u ON c.fk_usuario = u.usu_codigo
            JOIN detalle_reserva dr ON c.com_codigo = dr.fk_compra
            JOIN pago p_orig ON c.com_codigo = p_orig.fk_compra 
                AND p_orig.pag_codigo = (SELECT MIN(pag_codigo) FROM pago WHERE fk_compra = c.com_codigo)
            JOIN pago p_reemb ON c.com_codigo = p_reemb.fk_compra 
                AND p_reemb.pag_codigo = (SELECT MAX(pag_codigo) FROM pago WHERE fk_compra = c.com_codigo)
            WHERE dr.det_res_estado = 'Cancelada'
            AND p_orig.pag_codigo <> p_reemb.pag_codigo
            ORDER BY c.com_fecha DESC;
        `;

        const response = await pool.query(query);

        // Formateo de datos
        const datosFormateados = response.rows.map(row => {
            // Lógica para color: Si es CORRECTO -> Verde, si no -> Rojo
            const isError = row.estado_auditoria !== 'CORRECTO';
            
            return {
                cliente: row.cliente,
                fecha_cancelacion: new Date(row.fecha_cancelacion).toLocaleDateString('es-ES'),
                
                // Formato de moneda
                monto_pagado_original: Number(row.monto_pagado_original).toLocaleString('es-ES', { minimumFractionDigits: 2 }),
                penalizacion_10_porciento: Number(row.penalizacion_10_porciento).toLocaleString('es-ES', { minimumFractionDigits: 2 }),
                reembolso_esperado_90: Number(row.reembolso_esperado_90).toLocaleString('es-ES', { minimumFractionDigits: 2 }),
                reembolso_real_ejecutado: Number(row.reembolso_real_ejecutado).toLocaleString('es-ES', { minimumFractionDigits: 2 }),
                
                estado_auditoria: row.estado_auditoria,
                // Clase CSS para la plantilla
                colorClass: isError ? 'text-danger' : 'text-success'
            };
        });

        // 2. PLANTILLA HTML
        const htmlTemplate = `
            <html>
            <head>
                <style>
                    body { font-family: 'Segoe UI', Arial, sans-serif; margin: 0; padding: 20px; }
                    
                    .header-bg { background-color: #0056B3; color: white; padding: 20px; margin-bottom: 20px; border-radius: 5px; }
                    .header-title { font-size: 22px; font-weight: bold; margin: 0; }
                    .header-subtitle { font-size: 12px; margin-top: 5px; }
                    .header-date { float: right; font-size: 11px; margin-top: -35px; }

                    table { width: 100%; border-collapse: collapse; font-size: 10px; }
                    
                    th { 
                        background-color: #E9ECEF; color: #0056B3; 
                        font-weight: bold; text-align: left; padding: 10px;
                        border-bottom: 2px solid #0056B3;
                    }
                    
                    td { padding: 8px 10px; border-bottom: 1px solid #E0E0E0; vertical-align: middle; }
                    tr:nth-child(even) { background-color: #F8F9FA; }

                    .text-right { text-align: right; }
                    .text-center { text-align: center; }
                    
                    /* Estilos Condicionales */
                    .text-danger { color: #DC3545; font-weight: bold; }
                    .text-success { color: #28A745; font-weight: bold; }
                    .penalty { color: #DC3545; }

                    .footer { margin-top: 30px; font-size: 9px; color: #6C757D; border-top: 1px solid #E9ECEF; padding-top: 10px; }
                </style>
            </head>
            <body>
                <div class="header-bg">
                    <div class="header-title">Auditoría: Reembolsos Automáticos</div>
                    <div class="header-subtitle">Verificación de Regla de Negocio: Retención del 10%</div>
                    <div class="header-date">{{fechaGeneracion}}</div>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th width="20%">Cliente</th>
                            <th width="15%" class="text-right">Monto Orig.</th>
                            <th width="15%" class="text-right">Multa (10%)</th>
                            <th width="15%" class="text-right">Esperado (90%)</th>
                            <th width="15%" class="text-right">Real Ejecutado</th>
                            <th width="20%" class="text-center">Validación</th>
                        </tr>
                    </thead>
                    <tbody>
                        {{#each datos}}
                        <tr>
                            <td>{{cliente}}</td>
                            <td class="text-right">{{monto_pagado_original}} $</td>
                            <td class="text-right penalty">{{penalizacion_10_porciento}} $</td>
                            <td class="text-right">{{reembolso_esperado_90}} $</td>
                            <td class="text-right bold">{{reembolso_real_ejecutado}} $</td>
                            <td class="text-center {{colorClass}}">{{estado_auditoria}}</td>
                        </tr>
                        {{/each}}
                    </tbody>
                </table>

                <div class="footer">
                    Generado por Sistema UCAB
                </div>
            </body>
            </html>
        `;

        // 3. GENERAR PDF
        
        const result = await jsreport.render({
            template: {
                content: htmlTemplate,
                engine: 'handlebars',
                recipe: 'chrome-pdf',
                chrome: {
                    format: 'A4',
                    landscape: false, 
                    margin: { top: '20px', bottom: '20px', left: '20px', right: '20px' }
                }
            },
            data: {
                datos: datosFormateados,
                fechaGeneracion: new Date().toLocaleDateString('es-ES')
            }
        });

        res.setHeader('Content-Type', 'application/pdf');
        res.setHeader('Content-Disposition', 'attachment; filename=Auditoria_Reembolsos.pdf');
        result.stream.pipe(res);

    } catch (error) {
        console.error("Error generando reporte:", error);
        res.status(500).json({ error: "Error al generar el PDF" });
    }
};
// backend/controllers/reportController.js

// ... (tus otras funciones aquí) ...

const generarReportePreferencias = async (req, res) => {
    try {
        // 1. CONSULTA SQL (Extraída de tu Jasper XML)
        await initPromise;
        const query = `
            SELECT 
                u.usu_nombre_usuario AS cliente,
                -- 1. Preferencias Declaradas
                COALESCE(
                    STRING_AGG(DISTINCT cat.cat_nombre, ', '), 
                    'Sin preferencias'
                ) AS preferencias_declaradas,
                -- 2. Realidad (Paquete + Descripción)
                STRING_AGG(DISTINCT 
                    pt.paq_tur_nombre || ' (' || COALESCE(pt.paq_tur_descripcion, 'Sin Cat.') || ')', 
                    E'\n'
                ) AS compras_y_categorias_reales
            FROM usuario u
            -- Joins para Preferencias
            LEFT JOIN preferencia pref ON u.usu_codigo = pref.fk_usuario
            LEFT JOIN categoria cat ON pref.fk_categoria = cat.cat_codigo
            -- Joins para Compras Reales
            JOIN compra c ON u.usu_codigo = c.fk_usuario
            JOIN detalle_reserva dr ON c.com_codigo = dr.fk_compra
            JOIN paquete_turistico pt ON dr.fk_paquete_turistico = pt.paq_tur_codigo
            WHERE u.fk_rol_codigo = 3 -- Solo Clientes
            GROUP BY u.usu_codigo, u.usu_nombre_usuario
            ORDER BY u.usu_nombre_usuario;
        `;

        const response = await pool.query(query);

        // Formateo de datos
        // Convertimos los saltos de línea de postgres (E'\n') a <br> HTML si fuera necesario, 
        // pero jsreport suele manejar bien los saltos en celdas si usamos CSS white-space.
        const datosFormateados = response.rows.map(row => ({
            cliente: row.cliente,
            preferencias_declaradas: row.preferencias_declaradas,
            compras_y_categorias_reales: row.compras_y_categorias_reales
        }));

        // 2. PLANTILLA HTML
        const htmlTemplate = `
            <html>
            <head>
                <style>
                    body { font-family: 'Segoe UI', Arial, sans-serif; margin: 0; padding: 20px; }
                    .header-bg { background-color: #0056B3; color: white; padding: 20px; margin-bottom: 20px; border-radius: 5px; }
                    .header-title { font-size: 22px; font-weight: bold; margin: 0; }
                    .header-subtitle { font-size: 12px; margin-top: 5px; }
                    .header-date { float: right; font-size: 11px; margin-top: -35px; }

                    table { width: 100%; border-collapse: collapse; font-size: 10px; }
                    th { 
                        background-color: #E9ECEF; color: #0056B3; 
                        font-weight: bold; text-align: left; padding: 10px;
                        border-bottom: 2px solid #0056B3;
                    }
                    td { 
                        padding: 8px 10px; 
                        border-bottom: 1px solid #E0E0E0; 
                        vertical-align: middle; 
                        white-space: pre-wrap; /* Permite saltos de línea */
                    }
                    tr:nth-child(even) { background-color: #F8F9FA; }
                    
                    /* Estilo itálico para preferencias */
                    .italic { font-style: italic; color: #555; }
                    
                    .footer { margin-top: 30px; font-size: 9px; color: #6C757D; border-top: 1px solid #E9ECEF; padding-top: 10px; }
                </style>
            </head>
            <body>
                <div class="header-bg">
                    <div class="header-title">Análisis: Preferencias vs Realidad</div>
                    <div class="header-subtitle">Comparativa: Perfil Declarado vs Categoría de Compra Real</div>
                    <div class="header-date">{{fechaGeneracion}}</div>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th width="25%">Cliente</th>
                            <th width="35%">Categorías que Prefiere</th>
                            <th width="40%">Paquetes Comprados (Categoría)</th>
                        </tr>
                    </thead>
                    <tbody>
                        {{#each datos}}
                        <tr>
                            <td>{{cliente}}</td>
                            <td class="italic">{{preferencias_declaradas}}</td>
                            <td>{{compras_y_categorias_reales}}</td>
                        </tr>
                        {{/each}}
                    </tbody>
                </table>

                <div class="footer">Generado por Sistema UCAB</div>
            </body>
            </html>
        `;

        // 3. GENERAR PDF
        
        const result = await jsreport.render({
            template: {
                content: htmlTemplate,
                engine: 'handlebars',
                recipe: 'chrome-pdf',
                chrome: {
                    format: 'A4',
                    landscape: false, 
                    margin: { top: '20px', bottom: '20px', left: '20px', right: '20px' }
                }
            },
            data: {
                datos: datosFormateados,
                fechaGeneracion: new Date().toLocaleDateString('es-ES')
            }
        });

        res.setHeader('Content-Type', 'application/pdf');
        res.setHeader('Content-Disposition', 'attachment; filename=Preferencias_Vs_Realidad.pdf');
        result.stream.pipe(res);

    } catch (error) {
        console.error("Error Preferencias:", error);
        res.status(500).json({ error: error.message });
    }
};
// backend/controllers/reportController.js

// ... (Tus otras funciones anteriores) ...

const generarReporteClientesMillas = async (req, res) => {
    try {
        // 1. CONSULTA SQL (Tal cual tu XML)
        await initPromise;
        const query = `
            SELECT 
                u.usu_nombre_usuario AS cliente,
                u.usu_email AS correo,
                u.usu_total_millas AS saldo_actual_millas,
                est.lug_nombre AS estado_cliente
            FROM usuario u
            JOIN rol r ON u.fk_rol_codigo = r.rol_codigo
            JOIN lugar mun ON u.fk_lugar = mun.lug_codigo
            JOIN lugar est ON mun.fk_lugar = est.lug_codigo
            WHERE r.rol_nombre = 'Cliente'
            AND est.lug_tipo = 'Estado'
            AND NOT EXISTS (
                SELECT 1 
                FROM milla m
                JOIN compra c ON m.fk_compra = c.com_codigo
                WHERE c.fk_usuario = u.usu_codigo
                AND m.mil_valor_restado > 0 
            )
            ORDER BY u.usu_total_millas DESC
            LIMIT 20;
        `;

        const response = await pool.query(query);

        // Formateo de datos
        const datosFormateados = response.rows.map(row => ({
            cliente: row.cliente,
            correo: row.correo,
            saldo_actual_millas: Number(row.saldo_actual_millas).toLocaleString('es-ES'),
            estado_cliente: row.estado_cliente
        }));

        // 2. PLANTILLA HTML (Diseño Vertical)
        const htmlTemplate = `
            <html>
            <head>
                <style>
                    body { font-family: 'Segoe UI', Arial, sans-serif; margin: 0; padding: 20px; }
                    .header-bg { background-color: #0056B3; color: white; padding: 20px; margin-bottom: 20px; border-radius: 5px; }
                    .header-title { font-size: 22px; font-weight: bold; margin: 0; }
                    .header-subtitle { font-size: 12px; margin-top: 5px; }
                    .header-date { float: right; font-size: 11px; margin-top: -35px; }

                    table { width: 100%; border-collapse: collapse; font-size: 10px; }
                    th { 
                        background-color: #E9ECEF; color: #0056B3; 
                        font-weight: bold; text-align: left; padding: 10px;
                        border-bottom: 2px solid #0056B3;
                    }
                    td { padding: 8px 10px; border-bottom: 1px solid #E0E0E0; vertical-align: middle; }
                    tr:nth-child(even) { background-color: #F8F9FA; }
                    
                    .text-center { text-align: center; }
                    .bold { font-weight: bold; }
                    .footer { margin-top: 30px; font-size: 9px; color: #6C757D; border-top: 1px solid #E9ECEF; padding-top: 10px; }
                </style>
            </head>
            <body>
                <div class="header-bg">
                    <div class="header-title">Viajes UCAB</div>
                    <div class="header-subtitle">Top 20 Clientes con Millas sin Canjear</div>
                    <div class="header-date">{{fechaGeneracion}}</div>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th width="25%">Cliente</th>
                            <th width="35%">Correo Electrónico</th>
                            <th width="20%" class="text-center">Saldo Millas</th>
                            <th width="20%">Estado</th>
                        </tr>
                    </thead>
                    <tbody>
                        {{#each datos}}
                        <tr>
                            <td>{{cliente}}</td>
                            <td>{{correo}}</td>
                            <td class="text-center bold">{{saldo_actual_millas}}</td>
                            <td>{{estado_cliente}}</td>
                        </tr>
                        {{/each}}
                    </tbody>
                </table>

                <div class="footer">Generado por Sistema CerebroUCAB</div>
            </body>
            </html>
        `;

        const result = await jsreport.render({
            template: {
                content: htmlTemplate,
                engine: 'handlebars',
                recipe: 'chrome-pdf',
                chrome: { format: 'A4', landscape: false } // Vertical
            },
            data: {
                datos: datosFormateados,
                fechaGeneracion: new Date().toLocaleDateString('es-ES')
            }
        });

        res.setHeader('Content-Type', 'application/pdf');
        res.setHeader('Content-Disposition', 'attachment; filename=Clientes_Millas_Top20.pdf');
        result.stream.pipe(res);

    } catch (error) {
        console.error("Error Clientes Millas:", error);
        res.status(500).json({ error: error.message });
    }
};

module.exports = { 
    generarReportePaquetes, 
    generarReporteTopMillas, 
    generarReporteAuditoria,
    generarReportePreferencias,
    generarReporteClientesMillas 
};