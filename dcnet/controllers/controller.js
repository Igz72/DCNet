const postgres = require('../models/postgres');
const cookies = require('../cookies/cookies');

module.exports.login_get = (req, res) => {
    res.render('login');
}

module.exports.login_post = async (req, res) => {

    const { login, senha } = req.body;

    try {
        const senhaRecuperada = await postgres.recuperar_senha(login);

        if (senha == senhaRecuperada) {
            cookies.login(res, login);
            res.status(200).json({ login });
        }
        else {
            res.status(400).json({ erro: "Senha incorreta" });
        }
    }
    catch (err) {
        res.status(400).json({ erro: err.message });
    }
}

module.exports.logout_get = (req, res) => {
    cookies.logout(res);
    res.redirect('/login');
}

module.exports.cadastro_get = (req, res) => {
    res.render('cadastro');
}

module.exports.cadastro_post = async (req, res) => {

    const { login, senha, nome, sobrenome, email, nascimento, genero } = req.body;

    try {
        postgres.cadastrar_usuario(login, senha, nome, sobrenome, email, nascimento, genero);
        res.status(200).json({ login });
    } catch (err) {
        res.status(400).json({ erro: err.message });
    }
}

module.exports.adicionar_nome = (req, res, next) => {
    res.locals.nome = res.locals.login;
    next();
}

module.exports.inicio_get = (req, res) => {
    res.render('inicio');
}

module.exports.perfil_get = async (req, res) => {

    const login = res.locals.login;

    try {
        res.locals.perfil = await postgres.recuperar_perfil(login);
        
        const preferenciasArray = await postgres.recuperar_preferencias(login);

        var preferencias = "";

        for (var i = 0; i < preferenciasArray.length; i++) {
            preferencias = preferencias.concat(preferenciasArray[i]);

            if (i < preferenciasArray.length - 1) {
                preferencias = preferencias.concat(", ");
            }
        }

        res.locals.preferencias = preferencias;

    } catch (err) {
        console.error(err.message);
    }

    res.render('perfil');
}

module.exports.perfil_post = (req, res) => {

    const login = res.locals.login;

    var { descricao, rua, numero, bairro, cidade, estado, pais, preferencias } = req.body;

    if (numero == '') {
        numero = null;
    } else {
        numero = parseInt(numero);
    }

    const preferenciasArray = preferencias.split(/\s*,\s*/);

    try {
        postgres.atualizar_perfil(login, descricao, rua, numero, bairro, cidade, estado, pais, preferenciasArray);
        res.status(200).json({ login });
    } catch (err) {
        res.status(400).json({ erro: err.message });
    }
}

module.exports.amigos_get = (req, res) => {
    res.render('amigos');
}

module.exports.amigos_post = async (req, res) => {

    const login = res.locals.login;
    
    const { pesquisar, quantidade, amigo } = req.body;

    if (amigo) {
        try {
            postgres.solicitar_amizade(login, amigo)
        } catch (err) {
            res.status(400).json({ erro: err.message });
        }

    } else if (pesquisar) {
        try {
            const amigos = await postgres.procurar_amigos(pesquisar, 0, quantidade);
            res.status(200).json({ amigos, pesquisar, quantidade });
        } catch (err) {
            res.status(400).json({ erro: err.message });
        }
    }
}

module.exports.redirecionar_inicio = (req, res) => {
    res.redirect('/inicio');
}