# DCNet

## Sistema e tecnologias utilizadas

- Ubuntu 20.04.3 LTS
- PostgreSQL 12.9 - SGBD relacional
- pgAdmin 4 6.4 - Software de administração para o PostgreSQL com interface gráfica
- Node.js 6.14.0 - Plataforma que permite executar código JavaScript fora de navegadores
- npm 8.3.1 - Gerenciador de pacotes JavaScript
- node-postgres 8.7.3 - Coleção de módulos para o Node.js realizar conexões com o PostgreSQL
- Express 4.17.3 - Framework para desenvolvimento de servidores web
- ejs 3.1.6 - View engine para renderizar páginas web
- cookie-parser 1.4.6 - Middleware que permite capturar os cookies enviados por uma página web
- jsonwebtoken 8.5.1 - Pacote para a manipulação de JSON Web Tokens

## Front-end com React
- Em desenvolvimento :warning:

## Execução

- Entrar no diretório "dcnet"
- Para instalar as dependências, executar no terminal: "npm install"
- Antes de iniciar o servidor, configurar o Postgres com as seguintes informações:
  - user: "postgres"
  - password: "asd",
  - host: "localhost"
  - port: 5432
  - database: "postgres"
  - Executar o arquivo projeto_fisico.sql
- Para iniciar o servidor, executar no terminal: "node app.js"
- Para acessar o site, acessar o endereço: "localhost:3000/"
