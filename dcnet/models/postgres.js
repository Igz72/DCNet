const pg = require('pg');

const cliente = new pg.Client({
    user: "postgres",
    password: "asd",
    host: "localhost",
    port: 5432,
    database: "postgres"
});

async function recuperar_senha (login) {
    const consulta = "SELECT recuperar_senha($1)";
    const valores = [login];

    try {
        const resultado = await cliente.query(consulta, valores);
        const senha = resultado.rows[0].recuperar_senha;

        if (senha) {
            return senha;
        } else {
            throw Error("Usuário não encontrado");
        }

    } catch (err) {
        console.log(err.message);
        throw Error("Erro ao recuperar a senha");
    }
}

async function cadastrar_usuario (login, senha, nome, sobrenome, email, nascimento, genero) {
    const consulta = "CALL cadastrar_usuario($1, $2, $3, $4, $5, $6, $7)";
    const valores = [login, senha, nome, sobrenome, email, nascimento, genero];

    try {
        await cliente.query(consulta, valores);
    } catch (err) {
        console.log(err.message);
        throw Error("Erro ao cadastrar o usuário");
    }
}

async function atualizar_perfil (login, descricao, rua, numero, bairro, cidade, estado, pais, preferencias) {
    const consulta = "CALL atualizar_perfil($1, $2, $3, $4, $5, $6, $7, $8, $9)";
    const valores = [login, descricao, rua, numero, bairro, cidade, estado, pais, preferencias];

    try {
        await cliente.query(consulta, valores);
    } catch (err) {
        console.log(err.message);
        throw Error("Erro ao atualizar o perfil do usuário");
    }
}

async function recuperar_perfil (login) {
    const consulta = "SELECT * FROM recuperar_perfil($1)";
    const valores = [login];

    try {
        const resultado = await cliente.query(consulta, valores);
        return resultado.rows[0];
    } catch (err) {
        console.log(err.message);
        throw Error("Erro ao recuperar o perfil do usuário");
    }
}

async function recuperar_preferencias (login) {
    const consulta = "SELECT * FROM recuperar_preferencias($1)";
    const valores = [login];

    try {
        const resultado = await cliente.query(consulta, valores);

        var resultadoArray = [];

        for (var i = 0; i < resultado.rowCount; i++) {
            resultadoArray.push(resultado.rows[i].preferencias);
        }

        return resultadoArray;

    } catch (err) {
        console.log(err.message);
        throw Error("Erro ao recuperar as preferências do usuário");
    }
}

async function procurar_amigos (string, deslocamento, quantidade) {
    const consulta = "SELECT * FROM procurar_amigos($1, $2, $3)";
    const valores = [string, deslocamento, quantidade];

    try {
        const resultado = await cliente.query(consulta, valores);

        return resultado.rows;

    } catch (err) {
        console.log(err.message);
        throw Error("Erro ao recuperar as preferências do usuário");
    }
}

async function solicitar_amizade (login, amigo) {
    const consulta = "CALL solicitar_amizade($1, $2)";
    const valores = [login, amigo];

    try {
        await cliente.query(consulta, valores);

    } catch (err) {
        console.log(err.message);
        throw Error("Erro ao solicitar amizade");
    }
}

module.exports = {
    cliente,
    recuperar_senha,
    cadastrar_usuario,
    atualizar_perfil,
    recuperar_perfil,
    recuperar_preferencias,
    procurar_amigos,
    solicitar_amizade
};