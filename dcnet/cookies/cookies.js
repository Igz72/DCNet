const jwt = require('jsonwebtoken');

// Segredo que será utilizado para encriptar e desencriptar o token
const segredo = "dcnet token secret";

function tempoMaximo(multiplicador = 1) {
    return 3 * 24 * 60 * 60 * multiplicador; // Tempo em segundos
}

function criarToken(chave) {
    return jwt.sign({ chave }, segredo, {
        expiresIn: tempoMaximo() // Tempo em segundos
    });
};

module.exports.login = (res, chave) => {

    const token = criarToken(chave);

    res.cookie('jwt', token, {
        httpOnly: true,
        maxAge: tempoMaximo(1000) // Tempo em milisegundos
    });
};

module.exports.logout = (res) => {
    res.cookie('jwt', '', { maxAge: 1 });
};

module.exports.verificarLogin = async (req, res, next) => {

    const token = req.cookies.jwt;

    if (token) {
        jwt.verify(token, segredo, async (err, decodedToken) => {
            if (err) {
                console.error("Token invalido");
                res.redirect('/login');
            } else {
                res.locals.login = decodedToken.chave;
                next();
            }
        });
    } else {
        console.error("Token ausente");
        res.redirect('/login');
    }
};