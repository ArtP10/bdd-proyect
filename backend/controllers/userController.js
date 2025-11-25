
const pool = require('../config/db');


const loginUser = async (req, res) => {
  const { p_search_name, p_search_pass, p_search_type } = req.body;

  try {
    const query = `
      CALL sp_login_user($1, $2, $3, NULL, NULL, NULL, NULL, NULL)
    `;
    const values = [p_search_name, p_search_pass, p_search_type];
    
    const result = await pool.query(query, values);
    const userRow = result.rows[0];

    if (userRow && userRow.o_user_id) {
      res.json(userRow);
    } else {
      res.status(401).json({ message: 'Credenciales inválidas' });
    }
  } catch (err) {
    console.error('Login Error:', err);
    res.status(500).json({ message: 'Error del servidor' });
  }
};


module.exports = {
  loginUser
};