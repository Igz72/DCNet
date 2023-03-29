const express = require('express');
const cookieParser = require('cookie-parser');
const postgres = require('./models/postgres');
const routes = require('./routes/routes');

const app = express();

// Ativação dos middlewares
app.use(express.static('public'));
app.use(express.json());
app.use(cookieParser());

// Definição do template engine
app.set('view engine', 'ejs');

// Conexão com o Postgres e ativação do servidor
postgres.cliente.connect()
    .then(() => {
        console.log("Conectado ao Postgres")
        app.listen(3000)
        console.log("Servidor disponível na porta 3000. Acesse em: localhost:3000")
    })
    .catch((err) => {
        console.log(err)
    });

// Mapeamento das rotas
app.use(routes);