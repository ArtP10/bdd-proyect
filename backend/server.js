const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const userRoutes = require('./routes/userRoutes');
// --- NUEVA LÍNEA: Importar rutas de paquetes ---
const paqTurRoutes = require('./routes/paq_turRoutes'); 

const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.json());

app.use('/api/users', userRoutes);

// --- NUEVA LÍNEA: Usar rutas de paquetes ---
// Los endpoints quedarán tipo: http://localhost:3000/api/packages/create
app.use('/api', paqTurRoutes); 

app.listen(port, () => {
  console.log(`Backend running on http://localhost:${port}`);
}); 