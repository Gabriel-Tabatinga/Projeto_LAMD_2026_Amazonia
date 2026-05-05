const express = require('express');
require('dotenv').config()
const app = express();
const port = process.env.PORT;

app.listen(port, () => {
  console.log(`Conexão backend funcionando na porta: ${port}`);
});

//Pedido

//Criação do pedido
app.post('/order', (req, res) => {
});

//Cancelamento do pedido
app.put('/order', (req, res) => {
});

//Get individual pedidos infos para o cliente
app.get('/order/client', (req, res) => {
});


//Solicitação

//Get lista solicitações de pedidos ainda não aceitos para o prestador
app.get('/request/supplier', (req, res) => {
});

//Aceite do pedido pelo prestador, criando a solicitação
app.post('/request/supplier', (req, res) => {
});

//Get solicitações em andamento para o prestador
app.get('/request/supplier/ongoing', (req, res) => {
});

//Atualizar status entrega concluida
app.put('/request/supplier/ongoing/status', (req, res) => {
});

//Get solicitações encerradas para o prestador
app.get('/request/supplier/done', (req, res) => {
});

