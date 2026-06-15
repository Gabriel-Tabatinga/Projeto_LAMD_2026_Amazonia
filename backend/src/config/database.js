const sqlite3 = require('sqlite3').verbose();

const db = new sqlite3.Database('./amazonia.db', (err) => {
    if (err) {
        console.error('Erro ao conectar ao banco:', err.message);
    } else {
        console.log('📦 Conectado ao banco de dados SQLite.');
        
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

        // Criação da tabela de pedidos
        db.run(`CREATE TABLE IF NOT EXISTS pedidos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cliente_id INTEGER NOT NULL,
            produto_id INTEGER NOT NULL,
            status TEXT DEFAULT 'pendente', -- pendente, aceito, concluido, cancelado
            prestador_id INTEGER
        )`);
    }
});

module.exports = db;