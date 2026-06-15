require('dotenv').config();
const app = require('./src/app');
const { conectarRabbitMQ } = require('./src/config/rabbitmq');

const PORT = process.env.PORT || 3000;

conectarRabbitMQ().then(() => {
    app.listen(PORT, () => {
        console.log(`🚀 Conexão backend funcionando na porta: ${PORT}`);
    });
});