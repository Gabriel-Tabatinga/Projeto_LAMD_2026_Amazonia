const express = require('express');
const sqlite3 = require('sqlite3').verbose();
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

const db = new sqlite3.Database('./amazonia.db', (err) => {
    if (err) {
        console.error('Erro ao conectar ao banco:', err.message);
    } else {
        console.log('Conectado ao banco de dados SQLite.');
        
        db.run(`CREATE TABLE IF NOT EXISTS produtos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            preco REAL NOT NULL
        )`, (err) => {
            if (!err) {
                db.get(`SELECT COUNT(*) AS count FROM produtos`, (err, row) => {
                    if (row && row.count === 0) {
                        const insertSql = `INSERT INTO produtos (nome, preco) VALUES (?, ?)`;
                        db.run(insertSql, ['Smartphone Samsung Galaxy S24 256GB', 4999.00]);
                        db.run(insertSql, ['Notebook Dell Inspiron 15', 3599.00]);
                        db.run(insertSql, ['Livro - Arquitetura Limpa (Robert C. Martin)', 89.90]);
                        db.run(insertSql, ['Fone de Ouvido Bluetooth JBL Wave', 249.90]);
                        db.run(insertSql, ['Smart TV LG 55 polegadas 4K', 2799.00]);
                        console.log('Produtos iniciais pré-setados com sucesso!');
                    }
                });
            }
        });

        db.run(`CREATE TABLE IF NOT EXISTS pedidos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cliente_id INTEGER NOT NULL,
            produto_id INTEGER NOT NULL,
            status TEXT DEFAULT 'pendente', -- pendente, aceito, concluido, cancelado
            prestador_id INTEGER
        )`);
    }
});

const amqp = require('amqplib');

// CONFIGURAÇÃO DO RABBITMQ (MOM)
let canalRabbitMQ;

async function conectarRabbitMQ() {
    try {
        const urlMOM = process.env.CLOUDAMQP_URL || 'amqp://localhost'; //api.cloudamqp.com
        
        const conexao = await amqp.connect(urlMOM);
        canalRabbitMQ = await conexao.createChannel();
        
        // Declarando as filas
        await canalRabbitMQ.assertQueue('fila_novos_pedidos');
        await canalRabbitMQ.assertQueue('fila_atualizacao_status');
        
        console.log('Conectado ao RabbitMQ com sucesso!');

        // CONSUMIDORES
        canalRabbitMQ.consume('fila_novos_pedidos', (msg) => {
            if (msg !== null) {
                const dados = JSON.parse(msg.content.toString());
                console.log(`\n[MOM - Consumidor] 📦 Processando assincronamente o NOVO PEDIDO ID: ${dados.pedido_id}`);
                // Push Notification para os entregadores TODO
                canalRabbitMQ.ack(msg); // Confirma que a mensagem foi lida
            }
        });

        canalRabbitMQ.consume('fila_atualizacao_status', (msg) => {
            if (msg !== null) {
                const dados = JSON.parse(msg.content.toString());
                console.log(`\n[MOM - Consumidor] 🔄 Notificando cliente que o PEDIDO ID: ${dados.pedido_id} mudou para: ${dados.status}`);
                canalRabbitMQ.ack(msg);
            }
        });

    } catch (erro) {
        console.error('Erro ao conectar no RabbitMQ:', erro);
    }
}
conectarRabbitMQ();

// PRODUTOS

// Lista de produtos disponíveis
app.get('/produtos', (req, res) => {
    db.all(`SELECT * FROM produtos`, [], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

// Informações individuais de um produto
app.get('/produtos/:idItem', (req, res) => {
    const { idItem } = req.params;
    db.get(`SELECT * FROM produtos WHERE id = ?`, [idItem], (err, row) => {
        if (err) return res.status(500).json({ error: err.message });
        if (!row) return res.status(404).json({ error: 'Produto não encontrado' });
        res.json(row);
    });
});


// PEDIDO (CLIENTE)

// Criação do pedido
app.post('/order', (req, res) => {
    const { cliente_id, produto_id } = req.body;
    const sql = `INSERT INTO pedidos (cliente_id, produto_id) VALUES (?, ?)`;
    
    db.run(sql, [cliente_id, produto_id], function(err) {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json({ mensagem: 'Pedido criado!', pedido_id: this.lastID });
    });
});

// Cancelamento do pedido
app.put('/order/:id', (req, res) => {
    const { id } = req.params;
    const sql = `UPDATE pedidos SET status = 'cancelado' WHERE id = ? AND status = 'pendente'`;
    
    db.run(sql, [id], function(err) {
        if (err) return res.status(500).json({ error: err.message });
        if (this.changes === 0) return res.status(400).json({ error: 'Pedido não pode ser cancelado.' });
        res.json({ mensagem: 'Pedido cancelado com sucesso.' });
    });
});

// Get individual pedidos infos para o cliente
app.get('/order/client/:clienteId', (req, res) => {
    const { clienteId } = req.params;
    db.all(`SELECT * FROM pedidos WHERE cliente_id = ?`, [clienteId], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});


// SOLICITAÇÃO (PRESTADOR/ENTREGADOR)

// Get lista solicitações de pedidos ainda não aceitos para o prestador
app.get('/request/supplier', (req, res) => {
    db.all(`SELECT * FROM pedidos WHERE status = 'pendente'`, [], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

// Aceite do pedido pelo prestador, criando a solicitação
app.post('/request/supplier/:idPedido/accept', (req, res) => {
    const { idPedido } = req.params;
    const { prestador_id } = req.body; // Quem está aceitando

    const sql = `UPDATE pedidos SET status = 'aceito', prestador_id = ? WHERE id = ? AND status = 'pendente'`;
    db.run(sql, [prestador_id, idPedido], function(err) {
        if (err) return res.status(500).json({ error: err.message });
        if (this.changes === 0) return res.status(400).json({ error: 'Pedido indisponível para aceite.' });
        res.json({ mensagem: 'Pedido aceito com sucesso!' });
    });
});

// Get solicitações em andamento para o prestador
app.get('/request/supplier/:prestadorId/ongoing', (req, res) => {
    const { prestadorId } = req.params;
    db.all(`SELECT * FROM pedidos WHERE prestador_id = ? AND status = 'aceito'`, [prestadorId], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

// Atualizar status entrega concluida
app.put('/request/supplier/ongoing/:idPedido/status', (req, res) => {
    const { idPedido } = req.params;
    
    const sql = `UPDATE pedidos SET status = 'concluido' WHERE id = ? AND status = 'aceito'`;
    db.run(sql, [idPedido], function(err) {
        if (err) return res.status(500).json({ error: err.message });
        if (this.changes === 0) return res.status(400).json({ error: 'Não foi possível atualizar o status.' });
        res.json({ mensagem: 'Entrega concluída!' });
    });
});

// Get solicitações encerradas para o prestador
app.get('/request/supplier/:prestadorId/done', (req, res) => {
    const { prestadorId } = req.params;
    db.all(`SELECT * FROM pedidos WHERE prestador_id = ? AND status = 'concluido'`, [prestadorId], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

app.listen(port, () => {
  console.log(`🚀 Conexão backend funcionando na porta: ${port}`);
});