const pool = require('../config/db');

const getRoles = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM sp_listar_roles()');
        res.status(200).json({ success: true, data: result.rows });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: error.message });
    }
};

const createRol = async (req, res) => {
    const { nombre, descripcion } = req.body;
    try {
        await pool.query('CALL sp_crear_rol($1, $2)', [nombre, descripcion]);
        res.status(201).json({ success: true, message: 'Rol creado exitosamente' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: error.message });
    }
};

const updateRol = async (req, res) => {
    const { id } = req.params;
    const { nombre, descripcion } = req.body;
    try {
        await pool.query('CALL sp_modificar_rol($1, $2, $3)', [id, nombre, descripcion]);
        res.status(200).json({ success: true, message: 'Rol actualizado correctamente' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: error.message });
    }
};

const deleteRol = async (req, res) => {
    const { id } = req.params;
    try {
        await pool.query('CALL sp_eliminar_rol($1)', [id]);
        res.status(200).json({ success: true, message: 'Rol eliminado correctamente' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: error.message });
    }
};

module.exports = { getRoles, createRol, updateRol, deleteRol };