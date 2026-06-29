# Projeto_LAMD_2026_Amazonia

**PROJETO INTEGRADOR DA DISCIPLINA Desenvolvimento de Sistema Distribuído com Aplicativo Móvel**

**Autor:** Gabriel Pimentel Tabatinga  
**Curso:** Engenharia de Software - PUC Minas  

---

## Sobre o Projeto
O ecossistema **Amazonia.com** é uma plataforma distribuída orientada a eventos. O sistema atua como intermediador logístico, permitindo que clientes realizem pedidos e prestadores de serviço (entregadores) capturem e finalizem essas demandas de forma assíncrona.

O projeto foi desenvolvido aplicando os princípios de **Clean Architecture**, **Separação de Responsabilidades (SoC)** e comunicação assíncrona baseada em publicações/consumo de eventos em filas.

## Arquitetura do Sistema
O projeto está dividido em quatro componentes principais:
1. **Backend API RESTful (Node.js/Express):** Atua como o cérebro do sistema, gerenciando regras de negócio, persistência no banco e autenticação.
2. **Aplicativo do Cliente (Flutter):** Interface para o usuário final solicitar entregas, acompanhar o status e cancelar pedidos pendentes.
3. **Aplicativo do Entregador (Flutter):** Interface para o prestador capturar pedidos pendentes e concluir entregas em andamento.
4. **Middleware Orientado a Mensagens - MOM (RabbitMQ):** Filas geridas via CloudAMQP garantindo comunicação assíncrona e resiliência entre a criação de pedidos e as notificações de status.

*(O diagrama detalhado da arquitetura, `Diagrama_Arquitetura.png`, está disponível na raiz deste repositório).*

## Tecnologias Utilizadas
* **Backend:** Node.js, Express
* **Banco de Dados:** SQLite (Relacional)
* **Mensageria / MOM:** RabbitMQ (via CloudAMQP)
* **Frontend Mobile:** Flutter / Dart
* **Segurança:** Autenticação JWT (JSON Web Token) e Hashing com Bcrypt
* **Persistência Local:** SharedPreferences (Flutter)

---

## Como Executar o Projeto

### Pré-requisitos
Certifique-se de ter instalado em sua máquina:
* [Node.js](https://nodejs.org/)
* [Flutter SDK](https://flutter.dev/docs/get-started/install)
* Instância do RabbitMQ rodando localmente ou URL do [CloudAMQP](https://www.cloudamqp.com/)

### 1. Rodando o Backend
Abra o terminal, navegue até a pasta `backend` e siga os passos:

```bash
# Entre na pasta
cd backend

# Instale as dependências
npm install

# Crie um arquivo .env na raiz da pasta backend e adicione suas credenciais:
# PORT=3000
# CLOUDAMQP_URL=amqps://usuario:senha@servidor.rmq.cloudamqp.com/vhost
# JWT_SECRET=sua_chave_secreta_aqui

# Inicie o servidor
npm start
```
*A API estará rodando em `http://localhost:3000`.*

### 2. Rodando o Aplicativo do Cliente
Abra um novo terminal e navegue até a pasta `amazonia_cliente`:

```bash
cd amazonia_cliente

# Baixe as dependências do Flutter
flutter pub get

# Execute o aplicativo (recomendado no Emulador Android)
flutter run --no-enable-impeller
```

### 3. Rodando o Aplicativo do Entregador (Prestador)
Para testar o sistema de ponta a ponta simultaneamente, abra um terceiro terminal e rode o app do prestador no Chrome para evitar conflito com o emulador do Android:

```bash
cd amazonia_prestador

# Baixe as dependências do Flutter
flutter pub get

# Execute o aplicativo web especificando a porta
flutter run -d chrome --web-port 8080
```

---

## Testando a Autenticação
O banco de dados SQLite é gerado automaticamente na primeira execução do backend com os seguintes usuários de teste inseridos para facilitar a validação:
* **Cliente:** `cliente@amazonia.com` | Senha: `123456`
* **Entregador:** `entregador@amazonia.com` | Senha: `123456`

*(Você também pode criar novos usuários diretamente pelas telas de cadastro de ambos os aplicativos).*

## 📚 Referências
* MARTIN, Robert C. *Arquitetura limpa: o guia do artesão para estrutura e design de software.* Rio de Janeiro: Alta Books, 2019.
* HOHPE, Gregor; WOOLF, Bobby. *Enterprise Integration Patterns: designing, building, and deploying messaging solutions.* Boston: Addison-Wesley, 2003.
