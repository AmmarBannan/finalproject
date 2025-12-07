require('dotenv').config();
const express = require('express');
const routes = require('./routes/exampleRoutes');
const app = express();
app.use(express.json());
app.use('/api', routes);
app.get('/health', (_,res)=>res.json({status:"healthy"}));
const port = process.env.PORT || 3000;
app.listen(port, ()=> console.log("Running on", port));
