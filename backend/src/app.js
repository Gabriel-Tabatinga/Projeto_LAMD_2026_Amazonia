const express = require('express');
const cors = require('cors');
const pedidoRoutes = require('./routes/pedidoRoutes');
const produtoRoutes = require('./routes/produtoRoutes');
const authRoutes = require('./routes/authRoutes');
const verificarToken = require('./middlewares/authMiddleware');

const app = express();

app.use(cors());
app.use(express.json());

// Injeção de todas as rotas da aplicação
app.use('/auth', authRoutes);
app.use('/produtos', produtoRoutes);

app.use('/', verificarToken, pedidoRoutes);


module.exports = app;