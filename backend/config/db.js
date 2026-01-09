
const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'viajes_ucab_2v1',
  password: '1234',
  port: 5433,
});

module.exports = pool;