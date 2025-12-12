const pool = require('../config/db');

const loginUser = async (req, res) => {
  const { p_search_name, p_search_pass, p_search_type } = req.body;

  try {

    const query = `
      CALL sp_login_usuario($1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
    `;
    const values = [p_search_name, p_search_pass, p_search_type];
    
    const result = await pool.query(query, values);
    
    const dbResponse = result.rows[0];

 
    if (dbResponse.o_status_code === 200) {
      
      res.status(200).json({
        success: true,
        message: dbResponse.o_mensaje,
        data: {
          user_id: dbResponse.o_usu_codigo,
          user_name: dbResponse.o_usu_nombre,
          user_role: dbResponse.o_usu_rol,
          user_correo: dbResponse.o_usu_correo,
          privileges: dbResponse.o_rol_privilegios || [] // Array de privilegios
        }
      });

    } else {
      
      res.status(dbResponse.o_status_code).json({
        success: false,
        message: dbResponse.o_mensaje
      });

    }

  } catch (err) {
    console.error('Login Error:', err);
    res.status(500).json({ 
      success: false, 
      message: 'Error interno del servidor' 
    });
  }
};

const registerClient = async (req, res) => {
  // Estos keys deben coincidir con lo que envías en el body desde Vue
  const { username, password, email } = req.body;

  try {
    /* Llamada al SP: sp_registrar_usuario_cliente
      Inputs (3): nombre, contraseña, correo
      Outputs (5): status, mensaje, id_usuario, nombre_usuario, correo_usuario
      Total placeholders: 8
    */
    const query = `
      CALL sp_registrar_usuario_cliente($1, $2, $3, NULL, NULL, NULL, NULL, NULL)
    `;
    const values = [username, password, email];

    const result = await pool.query(query, values);
    
    // Postgres devuelve los parámetros INOUT en la primera fila
    const dbResponse = result.rows[0];

    // Verificamos el código de estado que nos dio la base de datos (201 = Created)
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
      // Manejo de errores controlados (409 Conflict, 400 Bad Request, etc.)
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
    // admin_id viene de la sesión actual
    const { admin_id, pro_nombre, pro_anos, pro_tipo, fk_lugar, usu_nombre, usu_pass, usu_email } = req.body;
    
    try {
        /* Params: admin_id, nombre, anos, tipo, lugar, user, pass, email */
        const query = `CALL sp_registrar_proveedor($1, $2, $3, $4, $5, $6, $7, $8, NULL, NULL)`;
        const values = [admin_id, pro_nombre, pro_anos, pro_tipo, fk_lugar, usu_nombre, usu_pass, usu_email];
        
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
    createProvider
};