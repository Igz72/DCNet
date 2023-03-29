-- ------------------ TABELAS -----------------------

CREATE TABLE usuario (
	login VARCHAR(30),
	senha VARCHAR(30) NOT NULL,
	descricao_do_perfil VARCHAR(280),
	rua VARCHAR(40),
	numero INTEGER,
	bairro VARCHAR(40),
	cidade VARCHAR(40),
	estado VARCHAR(40),
	pais VARCHAR(40),
	primeiro_nome VARCHAR(20) NOT NULL,
	sobrenome VARCHAR(30),
	email VARCHAR(40) NOT NULL,
	data_de_nascimento DATE,
	genero VARCHAR(20),
	CONSTRAINT usuario_pk PRIMARY KEY(login)
);

CREATE TABLE preferencias (
	preferencias VARCHAR(100),
	usuario VARCHAR(30) NOT NULL,
	CONSTRAINT preferencias_pk PRIMARY KEY(preferencias, usuario),
	CONSTRAINT preferencias_fk_usuario FOREIGN KEY (usuario) REFERENCES usuario(login)
);

CREATE TABLE canal (
	id_canal SERIAL,
	CONSTRAINT canal_pk PRIMARY KEY(id_canal)
);

CREATE TABLE coletivo (
	id_coletivo SERIAL,
	nome VARCHAR(30),
	proprietario VARCHAR(30),
	canal INTEGER NOT NULL,
	CONSTRAINT coletivo_pk PRIMARY KEY(id_coletivo),
	CONSTRAINT coletivo_uq UNIQUE(nome, proprietario),
	CONSTRAINT coletivo_fk_proprietario FOREIGN KEY (proprietario) REFERENCES usuario(login),
	CONSTRAINT coletivo_fk_canal FOREIGN KEY (canal) REFERENCES canal(id_canal)
);

CREATE TABLE grupo (
	coletivo INTEGER,
	CONSTRAINT grupo_pk PRIMARY KEY(coletivo),
	CONSTRAINT grupo_fk_coletivo FOREIGN KEY (coletivo) REFERENCES coletivo(id_coletivo)
);

CREATE TABLE lista (
	coletivo INTEGER,
	CONSTRAINT lista_pk PRIMARY KEY(coletivo),
	CONSTRAINT lista_fk_coletivo FOREIGN KEY (coletivo) REFERENCES coletivo(id_coletivo)
);

CREATE TABLE excecao (
	grupo INTEGER,
	visibilidade_da_excecao VARCHAR(7),
	CONSTRAINT excecao_pk PRIMARY KEY(grupo),
	CONSTRAINT excecao_fk_grupo FOREIGN KEY (grupo) REFERENCES grupo(coletivo),
	CONSTRAINT excecao_check_visibilidade CHECK (visibilidade_da_excecao IN ('VISIVEL', 'OCULTO'))
);

CREATE TABLE publicacao (
	id_publicacao SERIAL,
	data TIMESTAMP,
	usuario VARCHAR(30),
	canal INTEGER,
	texto VARCHAR(280),
	visibilidade VARCHAR(10),
	CONSTRAINT publicação_pk PRIMARY KEY(id_publicacao),
	CONSTRAINT publicação_uq UNIQUE(data, usuario, canal),
	CONSTRAINT publicacao_fk_usuario FOREIGN KEY (usuario) REFERENCES usuario(login),
	CONSTRAINT publicacao_fk_canal FOREIGN KEY (canal) REFERENCES canal(id_canal),
	CONSTRAINT publicacao_check_visibilidade CHECK (visibilidade IN ('PUBLICO', 'RESTRITO'))
);

CREATE TABLE imagem (
	id_imagem SERIAL,
	nome_da_imagem VARCHAR(30),
	publicacao INTEGER,
	arquivo_de_imagem VARCHAR(30),
	CONSTRAINT imagem_pk PRIMARY KEY(id_imagem),
	CONSTRAINT imagem_uq UNIQUE(nome_da_imagem, publicacao),
	CONSTRAINT imagem_fk_publicacao FOREIGN KEY (publicacao) REFERENCES publicacao(id_publicacao)
);

CREATE TABLE video (
	nome_do_video VARCHAR(30),
	publicacao INTEGER,
	arquivo_de_video VARCHAR(30),
	CONSTRAINT video_pk PRIMARY KEY(nome_do_video, publicacao),
	CONSTRAINT video_fk_publicacao FOREIGN KEY (publicacao) REFERENCES publicacao(id_publicacao)
);

CREATE TABLE solicita_amizade (
	id_solicita_amizade SERIAL,
	proprietario VARCHAR(30),
	amigo VARCHAR(30),
	status VARCHAR(10),
	CONSTRAINT solicita_amizade_pk PRIMARY KEY(id_solicita_amizade),
	CONSTRAINT solicita_amizade_uq UNIQUE(proprietario, amigo),
	CONSTRAINT solicita_amizade_fk_proprietario FOREIGN KEY (proprietario) REFERENCES usuario(login),
	CONSTRAINT solicita_amizade_fk_amigo FOREIGN KEY (amigo) REFERENCES usuario(login),
	CONSTRAINT solicita_amizade_check_status CHECK (status IN ('ACEITO', 'RECUSADO', 'PENDENTE'))
);

CREATE TABLE amigo (
	amizade INTEGER,
	CONSTRAINT amigo_pk PRIMARY KEY(amizade),
	CONSTRAINT amizade_fk_amizade FOREIGN KEY (amizade) REFERENCES solicita_amizade(id_solicita_amizade)
);

CREATE TABLE solicita_participacao (
	grupo INTEGER,
	usuario VARCHAR(30),
	status VARCHAR(10),
	CONSTRAINT solicita_participacao_pk PRIMARY KEY(grupo, usuario),
	CONSTRAINT solicita_participacao_fk_grupo FOREIGN KEY (grupo) REFERENCES grupo(coletivo),
	CONSTRAINT solicita_participacao_fk_usuario FOREIGN KEY (usuario) REFERENCES usuario(login),
	CONSTRAINT status_check CHECK (status IN ('ACEITO', 'RECUSADO', 'PENDENTE'))
);

CREATE TABLE adiciona (
	lista INTEGER,
	amigo INTEGER,
	CONSTRAINT adiciona_pk PRIMARY KEY(lista, amigo),
	CONSTRAINT adiciona_fk_lista FOREIGN KEY (lista) REFERENCES lista(coletivo),
	CONSTRAINT adiciona_fk_amigo FOREIGN KEY (amigo) REFERENCES amigo(amizade)
);

CREATE TABLE marca (
	usuario VARCHAR(30),
	imagem INTEGER,
	amigo INTEGER,
	CONSTRAINT marca_pk PRIMARY KEY(usuario, imagem, amigo),
	CONSTRAINT marca_fk_usuario FOREIGN KEY (usuario) REFERENCES usuario(login),
	CONSTRAINT marca_fk_imagem FOREIGN KEY (imagem) REFERENCES imagem(id_imagem),
	CONSTRAINT marca_fk_amigo FOREIGN KEY (amigo) REFERENCES amigo(amizade)
);


-- -------------------- VIEWS --------------------

CREATE OR REPLACE VIEW login_view AS
SELECT login, senha
FROM usuario;


CREATE OR REPLACE VIEW cadastro_view AS
SELECT login, senha, primeiro_nome, sobrenome, email, data_de_nascimento, genero
FROM usuario;


CREATE OR REPLACE VIEW perfil_view AS
SELECT login, descricao_do_perfil, rua, numero, bairro, cidade, estado, pais
FROM usuario;


CREATE OR REPLACE VIEW amigo_view AS
SELECT login, primeiro_nome, sobrenome
FROM usuario;


CREATE OR REPLACE VIEW grupo_view AS
SELECT coletivo.nome, coletivo.proprietario, excecao.visibilidade_da_excecao
FROM coletivo, excecao WHERE coletivo.id_coletivo = excecao.grupo;


CREATE OR REPLACE VIEW lista_view AS
SELECT coletivo.nome, coletivo.proprietario
FROM coletivo, lista WHERE coletivo.id_coletivo = lista.coletivo;


-- -------------------- PROCEDURES --------------------

CREATE OR REPLACE PROCEDURE cadastrar_usuario(_login VARCHAR, _senha VARCHAR, _nome VARCHAR, _sobrenome VARCHAR, _email VARCHAR, _nascimento DATE, _genero VARCHAR) AS
$$
BEGIN
	INSERT INTO cadastro_view VALUES (_login, _senha, _nome, _sobrenome, _email, _nascimento, _genero);
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE atualizar_perfil(_login VARCHAR, _descricao_do_perfil VARCHAR, _rua VARCHAR, _numero INTEGER, _bairro VARCHAR, _cidade VARCHAR, _estado VARCHAR, _pais VARCHAR, _preferencias VARCHAR[]) AS
$$
DECLARE
	preferencia VARCHAR;
BEGIN
	UPDATE perfil_view SET
	descricao_do_perfil	= _descricao_do_perfil,
	rua = _rua,
	numero = _numero,
	bairro = _bairro,
	cidade = _cidade,
	estado = _estado,
	pais = _pais
	WHERE login = _login;
	
	DELETE FROM preferencias WHERE usuario = _login;
	
	FOREACH preferencia IN ARRAY _preferencias
	LOOP
		INSERT INTO preferencias VALUES (preferencia, _login);
	END LOOP;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE solicitar_amizade(_login VARCHAR, _amigo VARCHAR) AS
$$
BEGIN
	INSERT INTO solicita_amizade (proprietario, amigo, status) VALUES (_login, _amigo, 'PENDENTE');
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE aceitar_amizade(_login VARCHAR, _amigo VARCHAR) AS
$$
BEGIN
	UPDATE solicita_amizade SET
	status = 'ACEITO'
	WHERE proprietario = _amigo AND amigo = _login;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE recusar_amizade(_login VARCHAR, _amigo VARCHAR) AS
$$
BEGIN
	UPDATE solicita_amizade SET
	status = 'RECUSADO'
	WHERE proprietario = _amigo AND amigo = _login;
END;
$$
LANGUAGE plpgsql;


-- -------------------- FUNCTIONS --------------------

CREATE OR REPLACE FUNCTION recuperar_senha(_login VARCHAR) RETURNS VARCHAR AS
$$
DECLARE
	resultado VARCHAR(30);
BEGIN
	SELECT senha FROM login_view WHERE login = _login INTO resultado;
	IF NOT FOUND THEN
		raise exception 'Usuário não encontrado';
	ELSE
		RETURN resultado;
	END IF;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION recuperar_perfil(_login VARCHAR) RETURNS SETOF perfil_view AS
$$
BEGIN
	RETURN QUERY SELECT * FROM perfil_view WHERE login = _login;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION recuperar_preferencias(_login VARCHAR) RETURNS SETOF preferencias AS
$$
BEGIN
	RETURN QUERY SELECT * FROM preferencias WHERE usuario = _login;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION procurar_amigos(_string VARCHAR, deslocamento INTEGER, quantidade INTEGER) RETURNS SETOF amigo_view AS
$$
DECLARE
	amigo_cursor CURSOR FOR SELECT * FROM amigo_view WHERE LOWER(primeiro_nome) LIKE LOWER(CONCAT('%', _string, '%')) OR LOWER(sobrenome) LIKE LOWER(CONCAT('%', _string, '%'));
	amigo_login VARCHAR(30);
	amigo_nome VARCHAR(20);
	amigo_sobrenome VARCHAR(30);
BEGIN
	CREATE TEMPORARY TABLE lista_amigos_temp(
		login VARCHAR(30),
		primeiro_nome VARCHAR(20),
		sobrenome VARCHAR(30)
	);
	
	OPEN amigo_cursor;
	MOVE FORWARD deslocamento FROM amigo_cursor;
	FOR i IN 1..quantidade LOOP
		FETCH amigo_cursor INTO amigo_login, amigo_nome, amigo_sobrenome;
		IF NOT FOUND THEN
			EXIT;
		END IF;
		INSERT INTO lista_amigos_temp VALUES(amigo_login, amigo_nome, amigo_sobrenome);
	END LOOP;
	CLOSE amigo_cursor;
	
	RETURN QUERY SELECT * FROM lista_amigos_temp;
	DROP TABLE lista_amigos_temp;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION atualizar_amizade() RETURNS TRIGGER AS
$$
BEGIN
	IF NEW.status = 'ACEITO' THEN
		PERFORM amizade FROM amigo, solicita_amizade
			WHERE solicita_amizade.proprietario=NEW.proprietario AND
		   	solicita_amizade.amigo=NEW.amigo AND
		 	amigo.amizade=solicita_amizade.id_solicita_amizade;
	 	IF NOT FOUND THEN
			INSERT INTO amigo VALUES (NEW.id_solicita_amizade);
		END IF;
	ELSE
		DELETE FROM amigo WHERE amizade = NEW.id_solicita_amizade;
	END IF;
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION criar_grupo() RETURNS TRIGGER AS
$$
DECLARE
	novo_id_canal INTEGER;
	novo_id_coletivo INTEGER;
BEGIN
	INSERT INTO canal VALUES(DEFAULT)
	RETURNING id_canal INTO novo_id_canal;

	INSERT INTO coletivo VALUES(DEFAULT, NEW.nome, NEW.proprietario, novo_id_canal)
	RETURNING id_coletivo INTO novo_id_coletivo;
	
	INSERT INTO grupo VALUES(novo_id_coletivo);
	INSERT INTO excecao VALUES(novo_id_coletivo, NEW.visibilidade_da_excecao);
	
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION criar_lista() RETURNS TRIGGER AS
$$
DECLARE
	novo_id_canal INTEGER;
	novo_id_coletivo INTEGER;
BEGIN
	INSERT INTO canal VALUES(DEFAULT)
	RETURNING id_canal INTO novo_id_canal;

	INSERT INTO coletivo VALUES(DEFAULT, NEW.nome, NEW.proprietario, novo_id_canal)
	RETURNING id_coletivo INTO novo_id_coletivo;
	
	INSERT INTO lista VALUES(novo_id_coletivo);
	
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;


-- -------------------- TRIGGERS --------------------

CREATE TRIGGER atualizar_amizade_trigger
AFTER UPDATE ON solicita_amizade
FOR EACH ROW
EXECUTE FUNCTION atualizar_amizade();


CREATE TRIGGER criar_grupo_trigger
INSTEAD OF INSERT ON grupo_view
FOR EACH ROW
EXECUTE FUNCTION criar_grupo();


CREATE TRIGGER criar_lista_trigger
INSTEAD OF INSERT ON lista_view
FOR EACH ROW
EXECUTE FUNCTION criar_lista();
