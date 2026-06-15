const db = require('../config/database');

const listarProdutos = (req, res) => {
    db.all(`SELECT * FROM produtos`, [], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
};

const obterProduto = (req, res) => {
    const { idItem } = req.params;
    db.get(`SELECT * FROM produtos WHERE id = ?`, [idItem], (err, row) => {
        if (err) return res.status(500).json({ error: err.message });
        if (!row) return res.status(404).json({ error: 'Produto não encontrado' });
        res.json(row);
    });
};

module.exports = { listarProdutos, obterProduto };