const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const cron = require('node-cron');

cron.schedule('0 0 * * *', async () => {
  console.log('⏳ Ejecutando proceso de Mora Diaria...');
  
  try {
    const client = await pool.connect();
    // Llamamos al SP que creamos
    const res = await client.query('CALL sp_aplicar_mora_diaria(NULL, NULL)'); 
    
    // Postgres devuelve los parámetros OUT en la primera fila
    const resultado = res.rows[0];
    console.log(`✅ Proceso de Mora finalizado: ${resultado.o_mensaje}`);
    
    client.release();
  } catch (err) {
    console.error('❌ Error aplicando mora automática:', err);
  }
});


const userRoutes = require('./routes/userRoutes');
const promocionRoutes = require('./routes/promocionRoutes');

//Aqui agregaremos el resto de rutas que corresponden al resto de controladores
//Puede haber un controlador para aerolineas, cruceros, paquetes, servicios, etc

const paqTurRoutes = require('./routes/paq_turRoutes'); 

const homRoutes = require('./routes/homeRoutes');

const cartRoutes = require('./routes/cartRoutes')

const paymentRoutes = require('./routes/routesPayment');

const reportRoutes = require('./routes/reportRoutes');
const rolesRoutes = require('./routes/rolesRoutes');





const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.json());
app.use('/api/report', reportRoutes);
app.use('/api/users', userRoutes);
app.use('/api/promociones', promocionRoutes);
app.use('/api', rolesRoutes);


app.use('/api/home',  homRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/payments', paymentRoutes);



// --- NUEVA LÍNEA: Usar rutas de paquetes ---
// Los endpoints quedarán tipo: http://localhost:3000/api/packages/create
app.use('/api', paqTurRoutes); 

app.listen(port, () => {
  console.log(`Backend running on http://localhost:${port}`);
}); 