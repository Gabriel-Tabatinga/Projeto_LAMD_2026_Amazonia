const db = require('../config/database');
const { getCanal } = require('../config/rabbitmq');

const criarPedido = (req, res) => {
    const { cliente_id, produto_id } = req.body;
    const sql = `INSERT INTO pedidos (cliente_id, produto_id) VALUES (?, ?)`;
    
    db.run(sql, [cliente_id, produto_id], function(err) {
        if (err) return res.status(500).json({ error: err.message });
        
        // Produtor MOM
        const evento = JSON.stringify({ evento: 'pedido_criado', pedido_id: this.lastID, cliente_id, produto_id });
        const canal = getCanal();
        if (canal) canal.sendToQueue('fila_novos_pedidos', Buffer.from(evento));

        res.status(201).json({ mensagem: 'Pedido criado!', pedido_id: this.lastID });
    });
};

const listarPendentes = (req, res) => {
    db.all(`SELECT * FROM pedidos WHERE status = 'pendente'`, [], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
};

const aceitarPedido = (req, res) => {
    const { idPedido } = req.params;
    const { prestador_id } = req.body;

    const sql = `UPDATE pedidos SET status = 'aceito', prestador_id = ? WHERE id = ? AND status = 'pendente'`;
    db.run(sql, [prestador_id, idPedido], function(err) {
        if (err) return res.status(500).json({ error: err.message });
        if (this.changes === 0) return res.status(400).json({ error: 'Pedido indisponível.' });
        
        // Produtor MOM
        const evento = JSON.stringify({ evento: 'pedido_aceito', pedido_id: idPedido, status: 'aceito' });
        const canal = getCanal();
        if (canal) canal.sendToQueue('fila_atualizacao_status', Buffer.from(evento));

        res.json({ mensagem: 'Pedido aceito com sucesso!' });
    });
};

const cancelarPedido = (req, res) => {
    const { id } = req.params;
    const sql = `UPDATE pedidos SET status = 'cancelado' WHERE id = ? AND status = 'pendente'`;
    
    db.run(sql, [id], function(err) {
        if (err) return res.status(500).json({ error: err.message });
        if (this.changes === 0) return res.status(400).json({ error: 'Pedido não pode ser cancelado.' });
        
        // Produtor MOM: Avisa a nuvem sobre o cancelamento
        const evento = JSON.stringify({ evento: 'pedido_cancelado', pedido_id: id, status: 'cancelado' });
        const canal = getCanal();
        if (canal) canal.sendToQueue('fila_atualizacao_status', Buffer.from(evento));

        res.json({ mensagem: 'Pedido cancelado com sucesso.' });
    });
};

const listarPedidosCliente = (req, res) => {
    const { clienteId } = req.params;
    db.all(`SELECT * FROM pedidos WHERE cliente_id = ?`, [clienteId], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
};

const listarEmAndamento = (req, res) => {
    const { prestadorId } = req.params;
    db.all(`SELECT * FROM pedidos WHERE prestador_id = ? AND status = 'aceito'`, [prestadorId], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
};

const concluirEntrega = (req, res) => {
    const { idPedido } = req.params;
    const sql = `UPDATE pedidos SET status = 'concluido' WHERE id = ? AND status = 'aceito'`;
    
    db.run(sql, [idPedido], function(err) {
        if (err) return res.status(500).json({ error: err.message });
        if (this.changes === 0) return res.status(400).json({ error: 'Não foi possível atualizar o status.' });
        
        // Produtor MOM: Avisa a nuvem sobre a conclusão
        const evento = JSON.stringify({ evento: 'pedido_concluido', pedido_id: idPedido, status: 'concluido' });
        const canal = getCanal();
        if (canal) canal.sendToQueue('fila_atualizacao_status', Buffer.from(evento));

        res.json({ mensagem: 'Entrega concluída!' });
    });
};

const listarConcluidos = (req, res) => {
    const { prestadorId } = req.params;
    db.all(`SELECT * FROM pedidos WHERE prestador_id = ? AND status = 'concluido'`, [prestadorId], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
};

module.exports = { 
    criarPedido, 
    listarPendentes, 
    aceitarPedido,
    cancelarPedido, 
    listarPedidosCliente, 
    listarEmAndamento, 
    concluirEntrega, 
    listarConcluidos
};