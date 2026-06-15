const express = require('express');
const router = express.Router();
const pedidoController = require('../controllers/pedidoController');

// === ROTAS DO CLIENTE ===
router.post('/order', pedidoController.criarPedido);
router.put('/order/:id', pedidoController.cancelarPedido);
router.get('/order/client/:clienteId', pedidoController.listarPedidosCliente);

// === ROTAS DO ENTREGADOR (PRESTADOR) ===
router.get('/request/supplier', pedidoController.listarPendentes);
router.post('/request/supplier/:idPedido/accept', pedidoController.aceitarPedido);
router.get('/request/supplier/:prestadorId/ongoing', pedidoController.listarEmAndamento);
router.put('/request/supplier/ongoing/:idPedido/status', pedidoController.concluirEntrega);
router.get('/request/supplier/:prestadorId/done', pedidoController.listarConcluidos);

module.exports = router;