const amqp = require('amqplib');

let canalRabbitMQ;

async function conectarRabbitMQ() {
    try {
        const urlMOM = process.env.CLOUDAMQP_URL;
        const conexao = await amqp.connect(urlMOM);
        canalRabbitMQ = await conexao.createChannel();
        
        await canalRabbitMQ.assertQueue('fila_novos_pedidos');
        await canalRabbitMQ.assertQueue('fila_atualizacao_status');
        
        console.log('🐇 Conectado ao RabbitMQ com sucesso!');

        // Consumidores
        canalRabbitMQ.consume('fila_novos_pedidos', (msg) => {
            if (msg) {
                const dados = JSON.parse(msg.content.toString());
                console.log(`\n[MOM] 📦 Processando NOVO PEDIDO ID: ${dados.pedido_id}`);
                canalRabbitMQ.ack(msg);
            }
        });

        canalRabbitMQ.consume('fila_atualizacao_status', (msg) => {
            if (msg) {
                const dados = JSON.parse(msg.content.toString());
                console.log(`\n[MOM] 🔄 PEDIDO ID: ${dados.pedido_id} mudou para: ${dados.status}`);
                canalRabbitMQ.ack(msg);
            }
        });

    } catch (erro) {
        console.error('Erro ao conectar no RabbitMQ:', erro);
    }
}

const getCanal = () => canalRabbitMQ;

module.exports = { conectarRabbitMQ, getCanal };