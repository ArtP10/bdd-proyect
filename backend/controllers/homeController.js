const db = require('../config/db'); // Tu configuración de conexión pg

const getHomeData = async (req, res) => {
    try {
        // Ejecutamos las 3 consultas en paralelo para eficiencia
        const [topTraslados, topServicios, proximos] = await Promise.all([
            db.query('SELECT * FROM sp_get_top_traslados()'),
            db.query('SELECT * FROM sp_get_top_servicios()'),
            db.query('SELECT * FROM sp_get_proximos()')
        ]);

        res.json({
            success: true,
            data: {
                topTraslados: topTraslados.rows,
                topServicios: topServicios.rows,
                proximos: proximos.rows
            }
        });
    } catch (error) {
        console.error('Error fetching home data:', error);
        res.status(500).json({ success: false, message: 'Error al cargar datos del home' });
    }
};

const searchResources = async (req, res) => {
    try {
        // Obtenemos los datos del body (POST) o query (GET) dependiendo de cómo lo mandes.
        // Como vamos a usar una vista nueva, es común enviar datos por POST para buscar.
        const { origen, destino, fecha, tipo } = req.body;
        
        const results = await db.query(
            'SELECT * FROM sp_buscar_home($1, $2, $3, $4)',
            [origen || null, destino || null, fecha || null, tipo]
        );

        // Formateamos un poco si es necesario, pero el SQL ya devuelve lo importante
        res.json({ success: true, results: results.rows });
    } catch (error) {
        console.error('Error searching:', error);
        res.status(500).json({ success: false, message: 'Error en la búsqueda' });
    }
};

module.exports = { getHomeData, searchResources };