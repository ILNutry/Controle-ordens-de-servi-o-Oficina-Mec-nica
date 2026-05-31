CREATE DATABASE oficina;
USE oficina;
--- Script DDL
CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100),
    cpf VARCHAR(14) UNIQUE,
    telefone VARCHAR(20),
    email VARCHAR(100)
);


CREATE TABLE veiculo (
    id_veiculo INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(10) UNIQUE,
    modelo VARCHAR(50),
    marca VARCHAR(50),
    ano INT,
    id_cliente INT,
    FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente)
);

CREATE TABLE mecanico (
    id_mecanico INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100),
    especialidade VARCHAR(100),
    salario DECIMAL(10,2)
);

CREATE TABLE equipe (
    id_equipe INT AUTO_INCREMENT PRIMARY KEY,
    nome_equipe VARCHAR(100)
);

CREATE TABLE equipe_mecanico (
    id_equipe INT,
    id_mecanico INT,
    PRIMARY KEY(id_equipe,id_mecanico),
    FOREIGN KEY(id_equipe) REFERENCES equipe(id_equipe),
    FOREIGN KEY(id_mecanico) REFERENCES mecanico(id_mecanico)
);

CREATE TABLE ordem_servico (
    id_os INT AUTO_INCREMENT PRIMARY KEY,
    data_abertura DATE,
    data_fechamento DATE,
    status_os VARCHAR(30),
    valor_total DECIMAL(10,2),
    id_veiculo INT,
    id_equipe INT,
    FOREIGN KEY(id_veiculo) REFERENCES veiculo(id_veiculo),
    FOREIGN KEY(id_equipe) REFERENCES equipe(id_equipe)
);

CREATE TABLE servico (
    id_servico INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(100),
    valor DECIMAL(10,2)
);

CREATE TABLE os_servico (
    id_os INT,
    id_servico INT,
    PRIMARY KEY(id_os,id_servico),
    FOREIGN KEY(id_os) REFERENCES ordem_servico(id_os),
    FOREIGN KEY(id_servico) REFERENCES servico(id_servico)
);

CREATE TABLE peca (
    id_peca INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(100),
    valor_unitario DECIMAL(10,2),
    estoque INT
);

CREATE TABLE os_peca (
    id_os INT,
    id_peca INT,
    quantidade INT,
    PRIMARY KEY(id_os,id_peca),
    FOREIGN KEY(id_os) REFERENCES ordem_servico(id_os),
    FOREIGN KEY(id_peca) REFERENCES peca(id_peca)
);

CREATE TABLE pagamento (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_os INT UNIQUE,
    forma_pagamento VARCHAR(50),
    valor_pago DECIMAL(10,2),
    data_pagamento DATE,
    FOREIGN KEY(id_os) REFERENCES ordem_servico(id_os)
);

--- Script DML

INSERT INTO cliente(nome,cpf,telefone,email)
VALUES
('João Silva','111.111.111-11','41999999999','joao@gmail.com'),
('Maria Souza','222.222.222-22','41988888888','maria@gmail.com');

INSERT INTO veiculo(placa,modelo,marca,ano,id_cliente)
VALUES
('ABC1234','Gol','Volkswagen',2020,1),
('DEF5678','Onix','Chevrolet',2022,2);

INSERT INTO mecanico(nome,especialidade,salario)
VALUES
('Carlos','Motor',4500),
('Pedro','Suspensão',4200);

INSERT INTO equipe(nome_equipe)
VALUES
('Equipe A'),
('Equipe B');

INSERT INTO equipe_mecanico
VALUES
(1,1),
(1,2);

INSERT INTO servico(descricao,valor)
VALUES
('Troca de óleo',150),
('Alinhamento',120);

INSERT INTO peca(descricao,valor_unitario,estoque)
VALUES
('Filtro de óleo',50,30),
('Pastilha de freio',180,15);

INSERT INTO ordem_servico
(data_abertura,data_fechamento,status_os,valor_total,id_veiculo,id_equipe)
VALUES
('2026-05-01','2026-05-02','Concluída',320,1,1),
('2026-05-05',NULL,'Em andamento',180,2,1);

INSERT INTO os_servico
VALUES
(1,1),
(1,2),
(2,2);

INSERT INTO os_peca
VALUES
(1,1,1),
(2,2,1);

INSERT INTO pagamento
(id_os,forma_pagamento,valor_pago,data_pagamento)
VALUES
(1,'Cartão',320,'2026-05-02');

--- consultas
SELECT *
FROM cliente;

SELECT *
FROM ordem_servico
WHERE status_os = 'Concluída';

--- Atributo Derivado
SELECT
id_os,
quantidade,
valor_unitario,
(quantidade * valor_unitario) AS valor_total_peca
FROM os_peca op
JOIN peca p
ON op.id_peca = p.id_peca;

--- GROUP BY e HAVING
SELECT
c.nome,
COUNT(v.id_veiculo) AS total_veiculos
FROM cliente c
JOIN veiculo v
ON c.id_cliente = v.id_cliente
GROUP BY c.nome
HAVING COUNT(v.id_veiculo) > 1;

--- Order By

SELECT *
FROM ordem_servico
ORDER BY valor_total DESC;
--- jOIN Complexo

--- Listar OS, cliente e veículo
SELECT
os.id_os,
c.nome AS cliente,
v.modelo,
v.placa,
os.status_os,
os.valor_total
FROM ordem_servico os
JOIN veiculo v
ON os.id_veiculo = v.id_veiculo
JOIN cliente c
ON v.id_cliente = c.id_cliente;

--- Valor faturado por forma de pagamento
SELECT
forma_pagamento,
SUM(valor_pago) AS faturamento
FROM pagamento
GROUP BY forma_pagamento;

--- Mecânicos por equipe
SELECT
e.nome_equipe,
m.nome
FROM equipe e
JOIN equipe_mecanico em
ON e.id_equipe = em.id_equipe
JOIN mecanico m
ON em.id_mecanico = m.id_mecanico
ORDER BY e.nome_equipe;

--- total de serviços executados
SELECT
os.id_os,
s.descricao,
s.valor
FROM ordem_servico os
JOIN os_servico oss
ON os.id_os = oss.id_os
JOIN servico s
ON oss.id_servico = s.id_servico;

--- Banco de dados
use oficina;

SELECT
    os.id_os,
    os.data_abertura,
    os.data_fechamento,
    os.status_os,
    os.valor_total,

    c.id_cliente,
    c.nome AS cliente,
    c.cpf,
    c.telefone,
    c.email,

    v.id_veiculo,
    v.placa,
    v.marca,
    v.modelo,
    v.ano,

    e.id_equipe,
    e.nome_equipe,

    m.id_mecanico,
    m.nome AS mecanico,
    m.especialidade,

    s.id_servico,
    s.descricao AS servico,
    s.valor AS valor_servico,

    p.id_peca,
    p.descricao AS peca,
    p.valor_unitario,
    op.quantidade,

    pg.id_pagamento,
    pg.forma_pagamento,
    pg.valor_pago,
    pg.data_pagamento

FROM ordem_servico os

INNER JOIN veiculo v
    ON os.id_veiculo = v.id_veiculo

INNER JOIN cliente c
    ON v.id_cliente = c.id_cliente

LEFT JOIN equipe e
    ON os.id_equipe = e.id_equipe

LEFT JOIN equipe_mecanico em
    ON e.id_equipe = em.id_equipe

LEFT JOIN mecanico m
    ON em.id_mecanico = m.id_mecanico

LEFT JOIN os_servico oss
    ON os.id_os = oss.id_os

LEFT JOIN servico s
    ON oss.id_servico = s.id_servico

LEFT JOIN os_peca op
    ON os.id_os = op.id_os

LEFT JOIN peca p
    ON op.id_peca = p.id_peca

LEFT JOIN pagamento pg
    ON os.id_os = pg.id_os

ORDER BY os.id_os;






