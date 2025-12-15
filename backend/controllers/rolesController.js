const db = require('../config/db');

// --- CRUD DE ROLES EXISTENTE ---

// Crear Rol
const crearRol = async (req, res) => {
    const { nombre, descripcion } = req.body;
    try {
        await db.query(`CALL registrar_rol($1, $2)`, [nombre, descripcion]);
        res.status(201).json({ success: true, message: 'Rol registrado exitosamente' });
    } catch (error) {
        console.error("Error al registrar rol:", error);
        res.status(500).json({ success: false, error: 'Error al registrar rol: ' + error.message });
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
        await db.query(`CALL editar_rol($1, $2, $3)`, [id, nombre, descripcion]);
        res.status(200).json({ success: true, message: 'Rol actualizado correctamente' });
    } catch (error) {
        console.error("Error al actualizar rol:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};

// Eliminar Rol
const eliminarRol = async (req, res) => {
    const { id } = req.params;
    try {
        await db.query(`CALL eliminar_rol($1)`, [id]);
        res.status(200).json({ success: true, message: 'Rol eliminado correctamente' });
    } catch (error) {
        console.error("Error al eliminar rol:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};

// --- NUEVAS FUNCIONES PARA PRIVILEGIOS ---

// 1. Listar todos los privilegios disponibles (Requiere Transacción para Cursor)
const obtenerTodosLosPrivilegios = async (req, res) => {
    const client = await db.connect(); // Obtenemos cliente exclusivo
    try {
        await client.query('BEGIN');
        // Llamamos al SP pasando un nombre para el cursor
        await client.query("CALL listar_todos_privilegios('cursor_privilegios')");
        // Hacemos FETCH del cursor
        const result = await client.query('FETCH ALL IN "cursor_privilegios"');
        await client.query('COMMIT');
        
        res.status(200).json(result.rows);
    } catch (error) {
        await client.query('ROLLBACK');
        console.error("Error al obtener privilegios:", error);
        res.status(500).json({ success: false, error: error.message });
    } finally {
        client.release(); // Liberamos el cliente
    }
};

// 2. Obtener privilegios de un rol específico (Requiere Transacción para Cursor)
const obtenerPrivilegiosDeRol = async (req, res) => {
    const { id } = req.params; // ID del rol
    const client = await db.connect();
    try {
        await client.query('BEGIN');
        await client.query("CALL obtener_privilegios_rol($1, 'cursor_rol_privs')", [id]);
        const result = await client.query('FETCH ALL IN "cursor_rol_privs"');
        await client.query('COMMIT');

        // result.rows será un array tipo: [{ fk_pri_codigo: 1 }, { fk_pri_codigo: 5 }]
        res.status(200).json(result.rows); 
    } catch (error) {
        await client.query('ROLLBACK');
        console.error("Error al obtener privilegios del rol:", error);
        res.status(500).json({ success: false, error: error.message });
    } finally {
        client.release();
    }
};

// 3. Asignar un privilegio (Insertar en tabla intermedia)
const asignarPrivilegio = async (req, res) => {
    const { rol_codigo, pri_codigo } = req.body;
    try {
        await db.query('CALL asignar_privilegio_rol($1, $2)', [rol_codigo, pri_codigo]);
        res.status(200).json({ success: true, message: 'Privilegio asignado correctamente' });
    } catch (error) {
        console.error("Error al asignar privilegio:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};

// 4. Revocar un privilegio (Eliminar de tabla intermedia)
const revocarPrivilegio = async (req, res) => {
    const { rol_codigo, pri_codigo } = req.body;
    try {
        await db.query('CALL revocar_privilegio_rol($1, $2)', [rol_codigo, pri_codigo]);
        res.status(200).json({ success: true, message: 'Privilegio revocado correctamente' });
    } catch (error) {
        console.error("Error al revocar privilegio:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};

module.exports = {
    crearRol,
    obtenerRoles,
    actualizarRol,
    eliminarRol,
    obtenerTodosLosPrivilegios,
    obtenerPrivilegiosDeRol,
    asignarPrivilegio,
    revocarPrivilegio
};