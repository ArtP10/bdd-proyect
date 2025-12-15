const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

// --- IMPORTS DE RUTAS ---
const userRoutes = require('./routes/userRoutes');
const promocionRoutes = require('./routes/promocionRoutes');
const paqTurRoutes = require('./routes/paq_turRoutes'); 
const homRoutes = require('./routes/homeRoutes');
const cartRoutes = require('./routes/cartRoutes');
const paymentRoutes = require('./routes/routesPayment');

// 1. NUEVO: Importar rutas de roles
const rolRoutes = require('./routes/rolRoutes'); 

const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.json());

// --- REGISTRO DE RUTAS (ENDPOINTS) ---
app.use('/api/users', userRoutes);
app.use('/api/promociones', promocionRoutes);
app.use('/api/home', homRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/payments', paymentRoutes);

// Rutas de paquetes (actualmente montadas en la raíz /api)
app.use('/api', paqTurRoutes); 

// 2. NUEVO: Registrar endpoint de roles
app.use('/api/roles', rolRoutes);

app.listen(port, () => {
  console.log(`Backend running on http://localhost:${port}`);
});