const pool = require('../config/db');

const loginUser = async (req, res) => {
  const { p_search_name, p_search_pass, p_search_type } = req.body;

  try {

    const query = `
      CALL sp_login_usuario($1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL)
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

module.exports = {
  loginUser,
  registerClient // ¡No olvides exportarlo!
};