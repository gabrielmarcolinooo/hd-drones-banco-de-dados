-- ============================================================
-- SCRIPT DE CRIAÇÃO E CARGA DO BANCO DE DADOS: HD DRONES (v2.0)
-- Entrega 2 - Banco de Dados Relacional (MySQL 8 / InnoDB)
-- ============================================================

DROP DATABASE IF EXISTS hd_drones;
CREATE DATABASE hd_drones CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hd_drones;

-- ------------------------------------------------------------
-- 1. TABELAS CADASTRAIS BASE
-- ------------------------------------------------------------

CREATE TABLE Clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome_razao VARCHAR(150) NOT NULL,
    cpf_cnpj VARCHAR(20) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    endereco VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE Fornecedores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    razao_social VARCHAR(150) NOT NULL,
    cnpj VARCHAR(20) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE Funcionario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    percentual_comissao DECIMAL(4, 2) DEFAULT 0.00
) ENGINE=InnoDB;

CREATE TABLE Produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    categoria ENUM('Drones', 'Baterias', 'Acessórios', 'Peças') NOT NULL,
    preco_venda DECIMAL(10, 2) NOT NULL,
    preco_custo DECIMAL(10, 2) NOT NULL,
    quantidade_estoque INT NOT NULL DEFAULT 0
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 2. VENDAS DE BALCÃO (PDV)
-- ------------------------------------------------------------

CREATE TABLE Vendas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    valor_total DECIMAL(10, 2) DEFAULT 0.00,
    lucro_total DECIMAL(10, 2) DEFAULT 0.00,
    valor_comissao DECIMAL(10, 2) DEFAULT 0.00,
    forma_pagamento ENUM('Pix', 'Dinheiro', 'Cartão de Crédito', 'Cartão de Débito') NOT NULL,
    id_cliente INT NULL, -- Opcional na venda de balcão (RN03)
    id_funcionario INT NOT NULL,
    CONSTRAINT fk_vendas_clientes FOREIGN KEY (id_cliente) REFERENCES Clientes(id) ON DELETE RESTRICT,
    CONSTRAINT fk_vendas_funcionario FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE Compoe_Venda (
    id_venda INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    preco_unitario_aplicado DECIMAL(10, 2) NOT NULL,
    preco_custo_aplicado DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (id_venda, id_produto),
    CONSTRAINT fk_compoev_venda FOREIGN KEY (id_venda) REFERENCES Vendas(id) ON DELETE CASCADE,
    CONSTRAINT fk_compoev_produto FOREIGN KEY (id_produto) REFERENCES Produtos(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 3. ASSISTÊNCIA TÉCNICA E ORDENS DE SERVIÇO (OS)
-- ------------------------------------------------------------

CREATE TABLE Ordem_Servico (
    id INT AUTO_INCREMENT PRIMARY KEY,
    aparelho_drone VARCHAR(100) NOT NULL,
    defeito_relatado TEXT NOT NULL,
    status ENUM('Orçamento', 'Aprovado', 'Em Manutenção', 'Concluído', 'Entregue com Garantia', 'Cancelado') DEFAULT 'Orçamento',
    valor_mao_obra DECIMAL(10, 2) DEFAULT 0.00,
    valor_pecas DECIMAL(10, 2) DEFAULT 0.00,
    valor_total DECIMAL(10, 2) DEFAULT 0.00,
    data_abertura DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_conclusao DATETIME NULL,
    prazo_garantia_dias INT DEFAULT 90, -- CDC Exigência Legal
    id_cliente INT NOT NULL, -- OBRIGATÓRIO: Toda OS pertence a um cliente
    id_tecnico INT NOT NULL,
    CONSTRAINT fk_os_cliente FOREIGN KEY (id_cliente) REFERENCES Clientes(id) ON DELETE RESTRICT,
    CONSTRAINT fk_os_tecnico FOREIGN KEY (id_tecnico) REFERENCES Funcionario(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE Pecas_OS (
    id_os INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    preco_unitario_aplicado DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (id_os, id_produto),
    CONSTRAINT fk_pecasos_os FOREIGN KEY (id_os) REFERENCES Ordem_Servico(id) ON DELETE CASCADE,
    CONSTRAINT fk_pecasos_produto FOREIGN KEY (id_produto) REFERENCES Produtos(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 4. HISTÓRICO E MOVIMENTAÇÃO DE ESTOQUE
-- ------------------------------------------------------------

CREATE TABLE Movimentacoes_Estoque (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT NOT NULL,
    id_funcionario INT NOT NULL,
    id_fornecedor INT NULL,
    quantidade_mov INT NOT NULL,
    tipo_movimentacao ENUM('Entrada Compra', 'Saída Venda', 'Uso em OS', 'Ajuste Inventário', 'Perda') NOT NULL,
    data_movimentacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    observacao VARCHAR(255),
    CONSTRAINT fk_mov_produto FOREIGN KEY (id_produto) REFERENCES Produtos(id) ON DELETE CASCADE,
    CONSTRAINT fk_mov_funcionario FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id) ON DELETE RESTRICT,
    CONSTRAINT fk_mov_fornecedor FOREIGN KEY (id_fornecedor) REFERENCES Fornecedores(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 5. CARGA DE DADOS FICTÍCIOS (DML)
-- ------------------------------------------------------------

INSERT INTO Fornecedores (razao_social, cnpj, telefone, email) VALUES
('DJI Brasil Importadora LTDA', '00.111.222/0001-33', '(11) 3333-0000', 'compras@djibrasil.com'),
('Peças e Acessórios Eletrônicos SP', '44.555.666/0001-77', '(11) 2222-1111', 'vendas@pecaseletronicas.com');

INSERT INTO Funcionario (nome, cargo, percentual_comissao) VALUES
('Carlos Vendedor', 'Vendedor', 2.50),
('Mariana Técnica', 'Técnica de Manutenção', 5.00),
('Roberto Gerente', 'Gerente', 0.00);

INSERT INTO Clientes (nome_razao, cpf_cnpj, telefone, email, endereco) VALUES
('João da Silva', '111.222.333-44', '(11) 98888-1111', 'joao@email.com', 'Rua das Flores, 123 - SP'),
('Empresa Fly Film LTDA', '12.345.678/0001-90', '(11) 97777-2222', 'contato@flyfilm.com', 'Av. Paulista, 1000 - SP');

INSERT INTO Produtos (nome, categoria, preco_venda, preco_custo, quantidade_estoque) VALUES
('Drone DJI Mini 3 Pro', 'Drones', 5000.00, 3500.00, 5),
('Bateria Inteligente DJI Mini 3', 'Baterias', 600.00, 380.00, 10),
('Cabo Flat Gimbal Mavic 2', 'Peças', 150.00, 45.00, 8);

INSERT INTO Vendas (valor_total, lucro_total, valor_comissao, forma_pagamento, id_cliente, id_funcionario) VALUES
(5600.00, 1720.00, 140.00, 'Pix', 1, 1);

INSERT INTO Compoe_Venda (id_venda, id_produto, quantidade, preco_unitario_aplicado, preco_custo_aplicado) VALUES
(1, 1, 1, 5000.00, 3500.00),
(1, 2, 1, 600.00, 380.00);

INSERT INTO Ordem_Servico (aparelho_drone, defeito_relatado, status, valor_mao_obra, valor_pecas, valor_total, id_cliente, id_tecnico) VALUES
('DJI Mavic 2 Pro', 'Queda de altitude e cabo flat partido', 'Concluído', 300.00, 150.00, 450.00, 2, 2);

INSERT INTO Pecas_OS (id_os, id_produto, quantidade, preco_unitario_aplicado) VALUES
(1, 3, 1, 150.00);

-- ------------------------------------------------------------
-- 6. CONSULTAS GERENCIAIS & AUDITORIA (KPIs)
-- ------------------------------------------------------------

-- G01: Apuração de Comissões por Funcionário no Mês
SELECT 
    f.nome AS Funcionario,
    f.cargo,
    COUNT(v.id) AS Total_Vendas,
    SUM(v.valor_total) AS Faturamento_Gerado,
    SUM(v.valor_comissao) AS Total_Comissao_Pagar
FROM Funcionario f
JOIN Vendas v ON f.id = v.id_funcionario
GROUP BY f.id;

-- G02: Relatório de Ordens de Serviço por Status e Faturamento
SELECT 
    status,
    COUNT(id) AS Qtd_OS,
    SUM(valor_mao_obra) AS Faturamento_Mao_Obra,
    SUM(valor_pecas) AS Faturamento_Pecas,
    SUM(valor_total) AS Faturamento_Total_OS
FROM Ordem_Servico
GROUP BY status;

-- A01: Auditoria - Garantir que nenhuma OS exista sem Cliente associado
SELECT id, aparelho_drone, status FROM Ordem_Servico WHERE id_cliente IS NULL;
