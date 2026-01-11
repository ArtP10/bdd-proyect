const db = require('../config/db'); 

// 1. OBTENER la lista de deseos (para mostrarla en Wishlist.vue)
const getWishlist = async (req, res) => {
    const { userId } = req.params; // Viene de la URL /api/wishlist/:userId
    const { categoria } = req.query; // Viene de ?categoria=TODO

    try {
        // Llamamos al SP de consulta que devuelve precio, nombre, etc.
        const result = await db.query(
            'SELECT * FROM mostrar_wishlist_filtrada($1, $2)', 
            [userId, categoria || 'TODO']
        );

        res.status(200).json({
            success: true,
            items: result.rows // El front espera 'items'
        });
    } catch (err) {
        console.error("Error al obtener wishlist:", err);
        res.status(500).json({ success: false, message: 'Error al consultar lista.' });
    }
};

// 2. AGREGAR a la lista de deseos
const addToWishlist = async (req, res) => {
    console.log("Datos recibidos:", req.body);
    const { user_id, producto_id, tipo_producto } = req.body;

    try {
        // Llamada simple con 3 parámetros. Si falla, va al catch.
        await db.query('CALL sp_agregar_a_wishlist($1, $2, $3)', [
            user_id,
            producto_id,
            tipo_producto.toUpperCase()
        ]);
        
        res.json({ success: true, message: 'Agregado correctamente' });
    } catch (error) {
        // Aquí capturamos el "RAISE EXCEPTION" de Postgres
        console.error("Error BD:", error.message);
        // Enviamos el mensaje exacto (ej: "Ya existe", "Fecha pasada")
        res.status(400).json({ success: false, message: error.message });
    }
};

const removeFromWishlist = async (req, res) => {
    const { user_id, producto_id, tipo_producto } = req.body;

    try {
        await db.query(
            'SELECT sp_eliminar_de_wishlist($1, $2, $3)',
            [user_id, producto_id, tipo_producto]
        );
        res.json({ success: true, message: 'Eliminado correctamente' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: 'Error al eliminar' });
    }
};

module.exports = {
    getWishlist,
    addToWishlist,
    removeFromWishlist
};