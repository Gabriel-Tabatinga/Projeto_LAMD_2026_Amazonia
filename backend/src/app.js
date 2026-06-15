const express = require('express');
const cors = require('cors');
const pedidoRoutes = require('./routes/pedidoRoutes');
const produtoRoutes = require('./routes/produtoRoutes'); // Nova importação

const app = express();

app.use(cors());
app.use(express.json());

// Injeção de todas as rotas da aplicação
app.use('/', pedidoRoutes); 
app.use('/produtos', produtoRoutes);

module.exports = app;