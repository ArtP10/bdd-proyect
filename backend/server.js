const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

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