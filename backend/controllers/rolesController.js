const db = require('../config/db');

// Crear Rol
const crearRol = async (req, res) => {
    const { nombre, descripcion } = req.body;

    try {
        await db.query(
            `CALL registrar_rol($1, $2)`,
            [nombre, descripcion]
        );

        res.status(201).json({
            success: true,
            message: 'Rol registrado exitosamente'
        });

    } catch (error) {
        console.error("Error al registrar rol:", error);
        res.status(500).json({
            success: false,
            error: 'Error al registrar rol: ' + error.message
        });
    }
};

// Obtener Roles
const obtenerRoles = async (req, res) => {
    try {
        const result = await db.query('SELECT * FROM rol ORDER BY rol_codigo ASC');
        res.status(200).json(result.rows);
    } catch (error) {
        console.error("Error al obtener roles:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};

// Actualizar Rol
const actualizarRol = async (req, res) => {
    const { id } = req.params;
    const { nombre, descripcion } = req.body;

    try {
        await db.query(
            `CALL editar_rol($1, $2, $3)`,
            [id, nombre, descripcion]
        );

        res.status(200).json({
            success: true,
            message: 'Rol actualizado correctamente'
        });

    } catch (error) {
        console.error("Error al actualizar rol:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};

// Eliminar Rol
const eliminarRol = async (req, res) => {
    const { id } = req.params;
    try {
        await db.query(
            `CALL eliminar_rol($1)`,
            [id]
        );

        res.status(200).json({
            success: true,
            message: 'Rol eliminado correctamente'
        });

    } catch (error) {
        console.error("Error al eliminar rol:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};

module.exports = {
    crearRol,
    obtenerRoles,
    actualizarRol,
    eliminarRol
};
