const db = require('../config/database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const registrar = (req, res) => {
    const { email, senha, tipo } = req.body;

    // Validação básica dos campos obrigatórios
    if (!email || !senha || !tipo) {
        return res.status(400).json({ error: 'Todos os campos (email, senha, tipo) são obrigatórios.' });
    }

    // Garante que o tipo seja apenas um dos dois aceitos pelo sistema
    if (tipo !== 'cliente' && tipo !== 'entregador') {
        return res.status(400).json({ error: "O tipo de usuário deve ser 'cliente' ou 'entregador'." });
    }

    // Criptografa a senha antes de salvar no banco
    const saltRounds = 10;
    const senhaHash = bcrypt.hashSync(senha, saltRounds);

    const sql = `INSERT INTO usuarios (email, senha, tipo) VALUES (?, ?, ?)`;
    
    db.run(sql, [email, senhaHash, tipo], function(err) {
        if (err) {
            if (err.message.includes('UNIQUE constraint failed')) {
                return res.status(400).json({ error: 'Este e-mail já está cadastrado.' });
            }
            return res.status(500).json({ error: err.message });
        }

        res.status(201).json({ 
            mensagem: 'Usuário cadastrado com sucesso!', 
            usuario_id: this.lastID 
        });
    });
};

const login = (req, res) => {
    const { email, senha } = req.body;

    db.get(`SELECT * FROM usuarios WHERE email = ?`, [email], (err, usuario) => {
        if (err) return res.status(500).json({ error: err.message });
        if (!usuario) return res.status(404).json({ error: 'Usuário não encontrado.' });

        const senhaValida = bcrypt.compareSync(senha, usuario.senha);
        if (!senhaValida) return res.status(401).json({ error: 'Senha incorreta.' });

        const token = jwt.sign(
            { id: usuario.id, tipo: usuario.tipo }, 
            process.env.JWT_SECRET, 
            { expiresIn: '8h' }
        );

        res.json({ 
            mensagem: 'Login realizado com sucesso!', 
            token, 
            usuario: { id: usuario.id, email: usuario.email, tipo: usuario.tipo } 
        });
    });
};

module.exports = { registrar, login };