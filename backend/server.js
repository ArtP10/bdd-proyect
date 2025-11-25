
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');


const userRoutes = require('./routes/userRoutes');
//Aqui agregaremos el resto de rutas que corresponden al resto de controladores
//Puede haber un controlador para aerolineas, cruceros, paquetes, servicios, etc

const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.json());

//Esto lo hacemos con cada ruta que creemos para que el backend lo use
app.use('/api/users', userRoutes);

app.listen(port, () => {
  console.log(`Backend running on http://localhost:${port}`);
});