const pool = require('../config/db');

// userController.js (o el nombre que tenga tu archivo)

const loginUser = async (req, res) => {
    // 1. Ya no extraemos 'user_type' o 'role' del body
    const { username, password } = req.body;

    try {
        // 2. Actualizamos la llamada SQL
        // IMPORTANTE:
        // - Quitamos el 3er parámetro de entrada (el rol).
        // - Aseguramos tener los placeholders (null) para los parámetros INOUT nuevos.
        
        // Estructura del nuevo SP (10 parámetros en total):
        // 1. IN nombre
        // 2. IN contraseña
        // 3. INOUT codigo (null)
        // 4. INOUT nombre (null)
        // 5. INOUT rol (null)
        // 6. INOUT status (null)
        // 7. INOUT mensaje (null)
        // 8. INOUT privilegios (null)
        // 9. INOUT correo (null)
        // 10. INOUT prov_tipo (null) <-- NUEVO

        const response = await pool.query(
            `CALL sp_login_usuario($1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)`,
            [username, password]
        );

        // Al usar 'CALL' con pg, los parámetros INOUT suelen devolverse en response.rows[0]
        // NOTA: Dependiendo de tu configuración de pg, esto puede variar. 
        // Si usas una versión reciente, devuelve un objeto con las columnas INOUT.
        
        const dbResult = response.rows[0];

        // Mapeamos la respuesta según los nombres de salida del SP
        const statusCode = dbResult.o_status_code;
        const message = dbResult.o_mensaje;

        if (statusCode === 200) {
            return res.status(200).json({
                success: true,
                message: message,
                user: {
                    id: dbResult.o_usu_codigo,
                    name: dbResult.o_usu_nombre,
                    email: dbResult.o_usu_correo,
                    role: dbResult.o_usu_rol,          // El rol real que vino de la BD
                    privileges: dbResult.o_rol_privilegios,
                    provider_type: dbResult.o_prov_tipo // <--- IMPORTANTE: Enviarlo al front
                }
            });
        } else {
            // Manejo de errores (401, 404, etc)
            return res.status(statusCode || 400).json({
                success: false,
                message: message
            });
        }

    } catch (error) {
        console.error('Error en login:', error);
        return res.status(500).json({
            success: false,
            message: 'Error interno del servidor'
        });
    }
};




const registerClient = async (req, res) => {
  // 1. Extraemos fk_lugar del body
  const { username, password, email, fk_lugar } = req.body;

  try {
    /* Llamada al SP: sp_registrar_usuario_cliente
      Inputs (4): nombre, contraseña, correo, fk_lugar
      Outputs (5): status, mensaje, id_usuario, nombre_usuario, correo_usuario
      Total placeholders: 9
    */
    const query = `
      CALL sp_registrar_usuario_cliente($1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL)
    `;
    
    // 2. Agregamos fk_lugar al array de valores
    const values = [username, password, email, fk_lugar];

    const result = await pool.query(query, values);
    
    const dbResponse = result.rows[0];

    if (dbResponse.o_status_code === 201) {
      res.status(201).json({
        success: true,
        message: dbResponse.o_mensaje,
        data: {
          usu_codigo: dbResponse.o_usu_codigo,
          usu_nombre: dbResponse.o_usu_nombre,
          usu_correo: dbResponse.o_usu_correo
        }
      });
    } else {
      res.status(dbResponse.o_status_code || 400).json({
        success: false,
        message: dbResponse.o_mensaje
      });
    }

  } catch (err) {
    console.error('Register Error:', err);
    res.status(500).json({ 
      success: false, 
      message: 'Error interno del servidor al registrar usuario' 
    });
  }
};

const getTravelers = async (req, res) => {
    const { user_id } = req.body; // Enviado desde el front
    try {
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            const query = 'CALL sp_obtener_viajeros_usuario($1, NULL, NULL, NULL)';
            const result = await client.query(query, [user_id]);
            const response = result.rows[0];
            
            if (response.o_status_code === 200) {
                // Fetch del cursor
                const cursorName = response.o_cursor;
                const cursorResult = await client.query(`FETCH ALL IN "${cursorName}"`);
                await client.query('COMMIT');
                
                res.status(200).json({ success: true, data: cursorResult.rows });
            } else {
                await client.query('ROLLBACK');
                res.status(response.o_status_code).json({ success: false, message: response.o_mensaje });
            }
        } catch (e) {
            await client.query('ROLLBACK');
            throw e;
        } finally {
            client.release();
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error server' });
    }
};

const createTraveler = async (req, res) => {
    const { user_id, prim_nombre, seg_nombre, prim_apellido, seg_apellido, fecha_nac } = req.body;
    try {
        const query = `CALL sp_crear_viajero($1, $2, $3, $4, $5, $6, NULL, NULL, NULL)`;
        const result = await pool.query(query, [user_id, prim_nombre, seg_nombre, prim_apellido, seg_apellido, fecha_nac]);
        const resp = result.rows[0];
        
        if (resp.o_status_code === 201) {
            res.status(201).json({ success: true, message: resp.o_mensaje, via_codigo: resp.o_via_codigo });
        } else {
            res.status(resp.o_status_code).json({ success: false, message: resp.o_mensaje });
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error server' });
    }
};

const getNationalities = async (req, res) => {
    try {
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            // Llamamos al SP. Cursor + Status + Mensaje
            const query = 'CALL sp_obtener_nacionalidades(NULL, NULL, NULL)';
            const result = await client.query(query);
            const response = result.rows[0];
            
            if (response.o_status_code === 200) {
                const cursorName = response.o_cursor;
                const cursorResult = await client.query(`FETCH ALL IN "${cursorName}"`);
                await client.query('COMMIT');
                
                res.status(200).json({ success: true, data: cursorResult.rows });
            } else {
                await client.query('ROLLBACK');
                res.status(response.o_status_code).json({ success: false, message: response.o_mensaje });
            }
        } catch (e) {
            await client.query('ROLLBACK');
            throw e;
        } finally {
            client.release();
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error al obtener nacionalidades' });
    }
};

// ACTUALIZADO: Agregar Documento (Ahora recibe nac_nombre)
const addDocument = async (req, res) => {
    // CAMBIO: Ahora extraemos nac_nombre en lugar de nac_codigo
    const { fecha_emision, fecha_venc, numero, tipo, nac_nombre, via_codigo } = req.body;
    
    try {
        // CAMBIO: Ajustamos los parámetros del query
        const query = `CALL sp_agregar_documento_viajero($1, $2, $3, $4, $5, $6, NULL, NULL)`;
        const values = [fecha_emision, fecha_venc, numero, tipo, nac_nombre, via_codigo];
        
        const result = await pool.query(query, values);
        const resp = result.rows[0];
        
        res.status(resp.o_status_code || 200).json({ 
            success: resp.o_status_code === 201, 
            message: resp.o_mensaje 
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error server' });
    }
};

const updateCivilStatus = async (req, res) => {
    const { via_codigo, edo_codigo } = req.body;
    try {
        const query = `CALL sp_actualizar_estado_civil($1, $2, NULL, NULL)`;
        const result = await pool.query(query, [via_codigo, edo_codigo]);
        const resp = result.rows[0];
        res.status(resp.o_status_code).json({ success: resp.o_status_code === 200, message: resp.o_mensaje });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error server' });
    }
};

const getTravelerDetails = async (req, res) => {
    const { via_codigo } = req.body;
    try {
        const query = `CALL sp_obtener_detalle_viajero($1, NULL, NULL, NULL)`;
        const result = await pool.query(query, [via_codigo]);
        const resp = result.rows[0];
        
        res.status(200).json({ 
            success: true, 
            documentos: resp.o_json_documentos, 
            historial: resp.o_json_historial 
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error server' });
    }
};

const getCivilStatuses = async (req, res) => {
    try {
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            const query = 'CALL sp_obtener_estados_civiles(NULL, NULL, NULL)';
            const result = await client.query(query);
            const response = result.rows[0];
            
            if (response.o_status_code === 200) {
                const cursorName = response.o_cursor;
                const cursorResult = await client.query(`FETCH ALL IN "${cursorName}"`);
                await client.query('COMMIT');
                
                res.status(200).json({ success: true, data: cursorResult.rows });
            } else {
                await client.query('ROLLBACK');
                res.status(response.o_status_code).json({ success: false, message: response.o_mensaje });
            }
        } catch (e) {
            await client.query('ROLLBACK');
            throw e;
        } finally {
            client.release();
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error al obtener estados civiles' });
    }
};

const deleteDocument = async (req, res) => {
    const { doc_codigo } = req.body;
    try {
        const query = `CALL sp_eliminar_documento($1, NULL, NULL)`;
        const result = await pool.query(query, [doc_codigo]);
        const resp = result.rows[0];
        
        res.status(resp.o_status_code).json({ 
            success: resp.o_status_code === 200, 
            message: resp.o_mensaje 
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error server' });
    }
};

const getLocations = async (req, res) => {
    try {
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            const query = 'CALL sp_obtener_lugares_operacion(NULL, NULL, NULL)';
            const result = await client.query(query);
            const response = result.rows[0];
            
            if (response.o_status_code === 200) {
                const cursorResult = await client.query(`FETCH ALL IN "${response.o_cursor}"`);
                await client.query('COMMIT');
                res.status(200).json({ success: true, data: cursorResult.rows });
            } else {
                await client.query('ROLLBACK');
                res.status(response.o_status_code).json({ success: false, message: response.o_mensaje });
            }
        } finally { client.release(); }
    } catch (err) { console.error(err); res.status(500).json({ success: false, message: 'Error server' }); }
};


const getProviders = async (req, res) => {
    try {
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            const query = 'CALL sp_obtener_proveedores(NULL, NULL, NULL)';
            const result = await client.query(query);
            const response = result.rows[0];
            
            if (response.o_status_code === 200) {
                const cursorResult = await client.query(`FETCH ALL IN "${response.o_cursor}"`);
                await client.query('COMMIT');
                res.status(200).json({ success: true, data: cursorResult.rows });
            } else {
                await client.query('ROLLBACK');
                res.status(response.o_status_code).json({ success: false, message: response.o_mensaje });
            }
        } finally { client.release(); }
    } catch (err) { console.error(err); res.status(500).json({ success: false, message: 'Error server' }); }
};

const createProvider = async (req, res) => {
    // Recibimos 'prov_fecha_creacion'
    const { admin_id, pro_nombre, prov_fecha_creacion, pro_tipo, fk_lugar, usu_nombre, usu_pass, usu_email } = req.body;
    
    try {
        const query = `CALL sp_registrar_proveedor($1, $2, $3, $4, $5, $6, $7, $8, NULL, NULL)`;
        const values = [admin_id, pro_nombre, prov_fecha_creacion, pro_tipo, fk_lugar, usu_nombre, usu_pass, usu_email];
        
        const result = await pool.query(query, values);
        const resp = result.rows[0];
        
        res.status(resp.o_status_code).json({ 
            success: resp.o_status_code === 201, 
            message: resp.o_mensaje 
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error server' });
    }
};



// 1. OBTENER FLOTA
const getFleet = async (req, res) => {
    const { user_id } = req.body;
    try {
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            
            // Obtenemos el ID del proveedor asociado a este usuario
            const pro_codigo = await _getProviderId(client, user_id);

            const query = 'CALL sp_obtener_flota_proveedor($1, NULL, NULL, NULL)';
            const result = await client.query(query, [pro_codigo]);
            const response = result.rows[0];
            
            if (response.o_status_code === 200) {
                const cursorResult = await client.query(`FETCH ALL IN "${response.o_cursor}"`);
                await client.query('COMMIT');
                res.status(200).json({ success: true, data: cursorResult.rows });
            } else {
                await client.query('ROLLBACK');
                res.status(response.o_status_code).json({ success: false, message: response.o_mensaje });
            }
        } catch (e) {
            await client.query('ROLLBACK');
            throw e;
        } finally { client.release(); }
    } catch (err) { console.error(err); res.status(500).json({ success: false, message: 'Error server' }); }
};

// 2. REGISTRAR AVIÓN
const _getProviderId = async (client, userId) => {
    // Usamos 'prov_codigo' (no pro_codigo)
    const res = await client.query('SELECT prov_codigo FROM proveedor WHERE fk_usu_codigo = $1', [userId]);
    if (res.rows.length === 0) throw new Error('Usuario no es proveedor');
    return res.rows[0].prov_codigo;
};

// Actualiza también createPlane para que use nombres coherentes (opcional pero recomendado)
const createPlane = async (req, res) => {
    const { user_id, capacidad, descripcion } = req.body;
    try {
        const client = await pool.connect(); 
        
        // 1. Obtener el prov_codigo a partir del user_id
        // Asegúrate de que _getProviderId busque 'prov_codigo' y no 'pro_codigo'
        const prov_codigo = await _getProviderId(client, user_id); 
        client.release();

        // 2. Llamar al SP
        const query = `CALL sp_registrar_avion($1, $2, $3, $4, NULL, NULL)`;
        const values = [user_id, prov_codigo, capacidad, descripcion];
        
        const result = await pool.query(query, values);;
        const resp = result.rows[0];
        
        res.status(resp.o_status_code).json({ success: resp.o_status_code === 201, message: resp.o_mensaje });
    } catch (err) { console.error(err); res.status(500).json({ success: false, message: 'Error server' }); }
};
// 3. MODIFICAR AVIÓN
const updatePlane = async (req, res) => {
    const { user_id, med_tra_codigo, capacidad, descripcion } = req.body;
    try {
        const query = `CALL sp_modificar_avion($1, $2, $3, $4, NULL, NULL)`;
        const result = await pool.query(query, [user_id, med_tra_codigo, capacidad, descripcion]);
        const resp = result.rows[0];
        
        res.status(resp.o_status_code).json({ success: resp.o_status_code === 200, message: resp.o_mensaje });
    } catch (err) { console.error(err); res.status(500).json({ success: false, message: 'Error server' }); }
};

// 4. ELIMINAR AVIÓN
const deletePlane = async (req, res) => {
    const { user_id, med_tra_codigo } = req.body;
    try {
        const query = `CALL sp_eliminar_avion($1, $2, NULL, NULL)`;
        const result = await pool.query(query, [user_id, med_tra_codigo]);
        const resp = result.rows[0];
        
        res.status(resp.o_status_code).json({ success: resp.o_status_code === 200, message: resp.o_mensaje });
    } catch (err) { console.error(err); res.status(500).json({ success: false, message: 'Error server' }); }
};

const getCompatibleTerminals = async (req, res) => {
    const { user_id } = req.body;
    try {
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            const query = 'CALL sp_obtener_terminales_compatibles($1, NULL, NULL, NULL)';
            const result = await client.query(query, [user_id]);
            const response = result.rows[0];
            
            if (response.o_status_code === 200) {
                const cursorResult = await client.query(`FETCH ALL IN "${response.o_cursor}"`);
                await client.query('COMMIT');
                res.status(200).json({ success: true, data: cursorResult.rows });
            } else {
                await client.query('ROLLBACK');
                res.status(response.o_status_code).json({ success: false, message: response.o_mensaje });
            }
        } finally { client.release(); }
    } catch (err) { console.error(err); res.status(500).json({ success: false, message: 'Error server' }); }
};

// 2. Obtener Rutas del Proveedor

// 3. Crear Ruta
const createRoute = async (req, res) => {
    // Recibimos rut_descripcion
    const { user_id, costo, millas, rut_tipo, rut_descripcion, fk_origen, fk_destino } = req.body;
    try {
        // Ajustamos la llamada al SP para incluir el nuevo parámetro (ahora son 9 argumentos contando los INOUT)
        const query = `CALL sp_registrar_ruta($1, $2, $3, $4, $5, $6, $7, NULL, NULL)`;
        const values = [user_id, costo, millas, rut_tipo, rut_descripcion, fk_origen, fk_destino];
        
        const result = await pool.query(query, values);
        const resp = result.rows[0];
        res.status(resp.o_status_code).json({ success: resp.o_status_code === 201, message: resp.o_mensaje });
    } catch (err) { console.error(err); res.status(500).json({ success: false, message: 'Error server' }); }
};

// READ
const getRoutes = async (req, res) => {
    const { user_id } = req.body;
    try {
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            const query = 'CALL sp_obtener_rutas_proveedor($1, NULL, NULL, NULL)';
            const result = await client.query(query, [user_id]);
            const response = result.rows[0];
            
            if (response.o_status_code === 200) {
                const cursorResult = await client.query(`FETCH ALL IN "${response.o_cursor}"`);
                await client.query('COMMIT');
                res.status(200).json({ success: true, data: cursorResult.rows });
            } else {
                await client.query('ROLLBACK');
                res.status(response.o_status_code).json({ success: false, message: response.o_mensaje });
            }
        } finally { client.release(); }
    } catch (err) { console.error(err); res.status(500).json({ success: false, message: 'Error server' }); }
};

const updateRoute = async (req, res) => {
    // Recibir rut_descripcion
    const { user_id, rut_codigo, costo, millas, rut_descripcion } = req.body;
    try {
        // Ajustar llamada al SP (ahora recibe descripción)
        const query = `CALL sp_modificar_ruta($1, $2, $3, $4, $5, NULL, NULL)`;
        const result = await pool.query(query, [user_id, rut_codigo, costo, millas, rut_descripcion]);
        const resp = result.rows[0];
        res.status(resp.o_status_code).json({ success: resp.o_status_code === 200, message: resp.o_mensaje });
    } catch (err) { console.error(err); res.status(500).json({ success: false, message: 'Error server' }); }
};;

// DELETE (Nuevo)
const deleteRoute = async (req, res) => {
    const { user_id, rut_codigo } = req.body;
    try {
        const query = `CALL sp_eliminar_ruta($1, $2, NULL, NULL)`;
        const result = await pool.query(query, [user_id, rut_codigo]);
        const resp = result.rows[0];
        res.status(resp.o_status_code).json({ success: resp.o_status_code === 200, message: resp.o_mensaje });
    } catch (err) { console.error(err); res.status(500).json({ success: false, message: 'Error server' }); }
};

const getTravels = async (req, res) => {
    const { user_id } = req.body;
    try {
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            const query = 'CALL sp_obtener_traslados_proveedor($1, NULL, NULL, NULL)';
            const result = await client.query(query, [user_id]);
            const response = result.rows[0];
            
            if (response.o_status_code === 200) {
                const cursorResult = await client.query(`FETCH ALL IN "${response.o_cursor}"`);
                await client.query('COMMIT');
                res.status(200).json({ success: true, data: cursorResult.rows });
            } else {
                await client.query('ROLLBACK');
                res.status(response.o_status_code).json({ success: false, message: response.o_mensaje });
            }
        } finally { client.release(); }
    } catch (err) { console.error(err); res.status(500).json({ success: false, message: 'Error server' }); }
};

// 2. CREAR TRASLADO
const createTravel = async (req, res) => {
    const { user_id, rut_codigo, med_tra_codigo, fecha_inicio, fecha_fin, co2 } = req.body;
    try {
        const query = `CALL sp_registrar_traslado($1, $2, $3, $4, $5, $6, NULL, NULL)`;
        // Importante: El orden de los parámetros debe coincidir con el SP
        const values = [user_id, rut_codigo, med_tra_codigo, fecha_inicio, fecha_fin, co2];
        
        const result = await pool.query(query, values);
        const resp = result.rows[0];
        
        res.status(resp.o_status_code).json({ success: resp.o_status_code === 201, message: resp.o_mensaje });
    } catch (err) { console.error(err); res.status(500).json({ success: false, message: 'Error server' }); }
};

// 3. EDITAR TRASLADO (Solo fechas)
const updateTravel = async (req, res) => {
    const { user_id, tras_codigo, fecha_inicio, fecha_fin } = req.body;
    try {
        const query = `CALL sp_modificar_traslado($1, $2, $3, $4, NULL, NULL)`;
        const result = await pool.query(query, [user_id, tras_codigo, fecha_inicio, fecha_fin]);
        const resp = result.rows[0];
        
        res.status(resp.o_status_code).json({ success: resp.o_status_code === 200, message: resp.o_mensaje });
    } catch (err) { console.error(err); res.status(500).json({ success: false, message: 'Error server' }); }
};



const getMyTickets = async (req, res) => {
    const { user_id } = req.body;
    
    try {
        const client = await pool.connect();
        try {
            // Llamamos a la función que devuelve la tabla de tickets
            const query = 'SELECT * FROM sp_obtener_tickets_cliente($1)';
            const result = await client.query(query, [user_id]);
            
            res.status(200).json({ 
                success: true, 
                data: result.rows 
            });
        } finally {
            client.release();
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error al obtener tickets' });
    }
};


module.exports = {
    loginUser,
    registerClient,
    getTravelers,
    createTraveler,
    addDocument,
    updateCivilStatus,
    getTravelerDetails,
    getNationalities,
    getCivilStatuses,
    deleteDocument,
    getLocations,
    getProviders,
    createProvider,
    deletePlane,
    createPlane,
    getFleet,
    updatePlane,
    deleteRoute,
    createRoute,
    getRoutes,
    getCompatibleTerminals,
    getTravels,
    createTravel,
    updateTravel,
    updateRoute,
    getMyTickets
};