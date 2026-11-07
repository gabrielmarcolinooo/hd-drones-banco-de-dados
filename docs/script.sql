-- ============================================================
-- SCRIPT SQL COMPLETO E CONSOLIDADO — HD DRONES
-- SGBD: MySQL 8 (Mecanismo de Armazenamento: InnoDB)
-- ============================================================

DROP DATABASE IF EXISTS hd_drones;
CREATE DATABASE hd_drones;
USE hd_drones;

-- ------------------------------------------------------------
-- 1. ESTRUTURA DDL (CRIAR TABELAS E RESTRIÇÕES)
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
    cargo VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE Produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    preco_venda DECIMAL(10, 2) NOT NULL,
    categoria ENUM('Drones', 'Baterias', 'Acessórios', 'Peças') NOT NULL,
    quantidade_estoque INT NOT NULL DEFAULT 0,
    preco_custo DECIMAL(10, 2) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE Vendas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    valor_total DECIMAL(10, 2) DEFAULT 0.00,
    lucro_total DECIMAL(10, 2) DEFAULT 0.00,
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
    prazo_garantia_dias INT DEFAULT 90, -- CDC Exigência Legal (RN04)
    id_cliente INT NOT NULL, -- OBRIGATÓRIO: Toda OS pertence a um cliente (RN03)
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

CREATE TABLE Movimentacoes_Estoque (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT NOT NULL,
    id_funcionario INT NOT NULL,
    id_fornecedor INT NULL,
    quantidade_mov INT NOT NULL,
    observacao VARCHAR(255),
    data_movimentacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    tipo_movimentacao ENUM('Entrada Compra', 'Saída Venda', 'Uso em OS', 'Ajuste Inventário', 'Perda') NOT NULL,
    CONSTRAINT fk_mov_produto FOREIGN KEY (id_produto) REFERENCES Produtos(id) ON DELETE CASCADE,
    CONSTRAINT fk_mov_funcionario FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id) ON DELETE RESTRICT,
    CONSTRAINT fk_mov_fornecedor FOREIGN KEY (id_fornecedor) REFERENCES Fornecedores(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 2. CARGA DE MASSA DE DADOS FICTÍCIA (DML)
-- (15 a 25 atendimentos/dia, 150 a 300 itens em catálogo).
-- ------------------------------------------------------------
 
-- INSERT 01: Carga de Clientes
INSERT INTO Clientes (nome_razao, cpf_cnpj, telefone, email, endereco) VALUES
('João da Silva', '111.222.333-44', '(11) 98888-1111', 'joao@email.com', 'Rua das Flores, 123 - São Paulo/SP'),
('Empresa Fly Film LTDA', '12.345.678/0001-90', '(11) 97777-2222', 'contato@flyfilm.com', 'Av. Paulista, 1000 - São Paulo/SP'),
('AgroForte Mapeamento Agrícola S.A.', '45.890.123/0001-11', '(19) 3888-4444', 'suporte@agroforte.com.br', 'Rodovia SP-330, Km 140 - Campinas/SP'),
('Lucas Mendes de Oliveira', '222.333.444-55', '(11) 99123-4567', 'lucas.mendes@gmail.com', 'Rua Augusta, 450, Ap 32 - São Paulo/SP'),
('Beatriz Helena Santos', '333.444.555-66', '(11) 98111-2233', 'beatriz.santos@outlook.com', 'Av. Rebouças, 1200 - São Paulo/SP'),
('Topografia & Engenharia Conecta LTDA', '98.765.432/0001-88', '(11) 3099-8800', 'projetos@conectaeng.com.br', 'Rua Funchal, 200 - São Paulo/SP'),
('Gabriel Ribeiro Costa', '444.555.666-77', '(11) 97654-3210', 'gabriel.costa@yahoo.com.br', 'Rua Vergueiro, 890 - São Paulo/SP'),
('Imagens Aéreas Nordeste LTDA', '33.222.111/0001-55', '(81) 3456-7890', 'operacoes@ianordeste.com.br', 'Av. Boa Viagem, 500 - Recife/PE'),
('Camila Rodrigues Alves', '555.666.777-88', '(11) 98222-3344', 'camila.alves@hotmail.com', 'Rua Oscar Freire, 310 - São Paulo/SP'),
('Marcos Vinícius de Souza', '666.777.888-99', '(19) 99876-5432', 'marcos.souza@gmail.com', 'Av. Brasil, 1500 - Campinas/SP'),
('Juliana Prado de Toledo', '777.888.999-00', '(11) 97111-5544', 'juliana.toledo@gmail.com', 'Rua dos Pinheiros, 500 - São Paulo/SP'),
('DroneMaster Filmagens ME', '11.444.777/0001-12', '(21) 98822-3311', 'contato@dronemaster.com.br', 'Av. Atlântica, 1200 - Rio de Janeiro/RJ'),
('Rafael Barbosa Ferreira', '888.999.000-11', '(11) 96543-2109', 'rafael.ferreira@gmail.com', 'Rua Pamplona, 780 - São Paulo/SP'),
('Mariana Lima Duarte', '999.000.111-22', '(31) 99811-4433', 'mariana.duarte@hotmail.com', 'Av. Afonso Pena, 2500 - Belo Horizonte/MG'),
('Soluções em Mapeamento Aéreo LTDA', '22.333.444/0001-55', '(41) 3344-5566', 'contato@solucoesaereas.com.br', 'Rua XV de Novembro, 800 - Curitiba/PR'),
('Felipe Augusto Martins', '000.111.222-33', '(11) 97444-8899', 'felipe.martins@yahoo.com', 'Rua Haddock Lobo, 600 - São Paulo/SP'),
('Larissa Machado Vieira', '123.234.345-45', '(11) 98555-1122', 'larissa.vieira@outlook.com', 'Rua Bela Cintra, 950 - São Paulo/SP'),
('AgroVisão Geotecnologia EIRELI', '55.666.777/0001-88', '(62) 3211-9900', 'comercial@agrovisao.com.br', 'Av. T-63, 1100 - Goiânia/GO'),
('Thiago Henrique Nogueira', '234.345.456-56', '(19) 99111-7788', 'thiago.nogueira@gmail.com', 'Rua Barão de Jaguara, 400 - Campinas/SP'),
('Aline Cardoso Ramos', '345.456.567-67', '(11) 96333-2211', 'aline.ramos@gmail.com', 'Av. Brigadeiro Faria Lima, 2100 - São Paulo/SP'),
('Inspeções Técnicas por Drone LTDA', '77.888.999/0001-33', '(27) 3322-1100', 'contato@inspecoesdrone.com.br', 'Av. Nossa Senhora da Penha, 1500 - Vitória/ES'),
('Bruno Cesar Silveira', '456.567.678-78', '(11) 97888-9900', 'bruno.silveira@hotmail.com', 'Rua Domingos de Morais, 1300 - São Paulo/SP'),
('Fernanda Cristina Pires', '567.678.789-89', '(48) 99888-3322', 'fernanda.pires@gmail.com', 'Av. Beira Mar Norte, 800 - Florianópolis/SC'),
('GeoSoluções Engenharia & Drones LTDA', '88.999.111/0001-44', '(51) 3211-4455', 'projetos@geosolucoes.com.br', 'Av. Carlos Gomes, 400 - Porto Alegre/RS'),
('Rodrigo Fonseca Castro', '678.789.890-90', '(11) 99444-5566', 'rodrigo.castro@gmail.com', 'Rua Clélia, 750 - São Paulo/SP'),
('Patrícia Nunes de Oliveira', '789.890.901-01', '(31) 98777-6655', 'patricia.nunes@outlook.com', 'Rua da Bahia, 1100 - Belo Horizonte/MG'),
('EcoFly Monitoramento Ambiental LTDA', '44.555.666/0001-22', '(91) 3244-8899', 'ecofly@ecofly.com.br', 'Av. Almirante Barroso, 900 - Belém/PA'),
('Guilherme Augusto Matos', '890.901.012-12', '(11) 96111-9988', 'guilherme.matos@yahoo.com', 'Rua Teodoro Sampaio, 1800 - São Paulo/SP'),
('Vanessa Borges de Lima', '901.012.123-23', '(19) 99333-4455', 'vanessa.lima@gmail.com', 'Av. José de Souza Campos, 600 - Campinas/SP'),
('Kairós Cinema & Imagens Aéreas', '33.444.555/0001-66', '(11) 3088-7711', 'contato@kairoscinema.com.br', 'Rua Harmonia, 350 - São Paulo/SP'),
('Marcelo Antunes Teixeira', '012.123.234-34', '(11) 98999-0011', 'marcelo.teixeira@gmail.com', 'Rua Cardeal Arcoverde, 1400 - São Paulo/SP'),
('Danielle Siqueira Campos', '123.345.567-45', '(21) 99666-8877', 'danielle.campos@hotmail.com', 'Rua das Laranjeiras, 300 - Rio de Janeiro/RJ'),
('AgroDrone Pulverização Inteligente LTDA', '66.777.888/0001-99', '(67) 3344-1122', 'comercial@agrodronepulv.com.br', 'Av. Afonso Pena, 3500 - Campo Grande/MS'),
('Diego Roberto Guimarães', '234.456.678-56', '(11) 97222-3300', 'diego.guimaraes@gmail.com', 'Rua Voluntários da Pátria, 2100 - São Paulo/SP'),
('Renata Pacheco Soares', '345.567.789-67', '(11) 98333-4411', 'renata.soares@outlook.com', 'Av. Jabaquara, 1500 - São Paulo/SP'),
('Vanguarda Mídia & Vídeos Aéreos LTDA', '11.222.333/0001-77', '(11) 3255-9988', 'producao@vanguardamidia.com.br', 'Rua Consolação, 2300 - São Paulo/SP'),
('Leonardo Bastos Resende', '456.678.890-78', '(31) 99222-1144', 'leonardo.resende@gmail.com', 'Av. Amazonas, 1800 - Belo Horizonte/MG'),
('Isabela Mendes de Aragão', '567.789.901-89', '(11) 96444-7788', 'isabela.aragao@yahoo.com', 'Rua Heitor Penteado, 800 - São Paulo/SP'),
('TopGraf Mapeamento & Topografia LTDA', '99.000.111/0001-22', '(85) 3266-4433', 'contato@topgraf.com.br', 'Av. Dom Luís, 1200 - Fortaleza/CE'),
('Eduardo Felipe Peixoto', '678.890.012-90', '(19) 99777-8899', 'eduardo.peixoto@gmail.com', 'Rua Conceição, 500 - Campinas/SP'),
('Carolina Freitas Monteiro', '789.901.123-01', '(11) 98111-6655', 'carolina.monteiro@hotmail.com', 'Av. Ibirapuera, 2400 - São Paulo/SP'),
('Aerovisa Imagens Técnicas LTDA', '22.444.666/0001-88', '(41) 3011-2233', 'operacoes@aerovisa.com.br', 'Rua Sete de Setembro, 1500 - Curitiba/PR'),
('Vitor Hugo Camargo', '890.012.234-12', '(11) 97333-5566', 'vitor.camargo@gmail.com', 'Rua Pamplona, 1400 - São Paulo/SP'),
('Priscila Xavier de Moura', '901.123.345-23', '(21) 98777-1122', 'priscila.moura@outlook.com', 'Av. Copacabana, 800 - Rio de Janeiro/RJ'),
('Vertical Inspect Engenharia Aérea LTDA', '55.777.999/0001-11', '(11) 3100-4455', 'contato@verticalinspect.com.br', 'Rua Berrini, 1100 - São Paulo/SP'),
('Otávio Henrique de Souza', '012.234.456-34', '(11) 96222-8899', 'otavio.souza@gmail.com', 'Rua Vergueiro, 2500 - São Paulo/SP'),
('Tânia Maria de Andrade', '31.994.442/2110-00', '(31) 99444-2211', 'tania.andrade@yahoo.com', 'Rua dos Goitacazes, 400 - Belo Horizonte/MG'),
('AgroSky Tecnologia Agrícola LTDA', '88.111.333/0001-44', '(65) 3622-7788', 'suporte@agrosky.com.br', 'Av. Historiador Rubens de Mendonça, 2000 - Cuiabá/MT'),
('Caio Vinícius Faria', '234.456.678-67', '(19) 99555-6677', 'caio.faria@gmail.com', 'Rua General Osório, 900 - Campinas/SP'),
('Lorena Ribeiro Vasconcelos', '345.567.789-78', '(11) 98666-3344', 'lorena.vasconcelos@hotmail.com', 'Av. Rebouças, 2800 - São Paulo/SP'),
('SkyView Produtora Audiovisual LTDA', '44.666.888/0001-55', '(11) 3811-9900', 'atendimento@skyview.com.br', 'Rua Fradique Coutinho, 700 - São Paulo/SP'),
('Samuel Santos Figueiredo', '456.678.890-89', '(11) 97111-2233', 'samuel.figueiredo@gmail.com', 'Rua Lins de Vasconcelos, 1200 - São Paulo/SP'),
('Monique Kelly de Oliveira', '567.789.901-90', '(21) 99111-4455', 'monique.oliveira@outlook.com', 'Rua Visconde de Pirajá, 400 - Rio de Janeiro/RJ'),
('Agronomía & Drones do Brasil S.A.', '77.999.111/0001-66', '(16) 3322-8899', 'contato@agronomiadrones.com.br', 'Av. Sertãozinho, 1500 - Ribeirão Preto/SP'),
('Matheus Felipe Antunes', '678.890.012-01', '(11) 96888-5544', 'matheus.antunes@gmail.com', 'Rua Pedroso Alvarenga, 900 - São Paulo/SP'),
('Tatiane Aparecida Silva', '789.901.123-12', '(19) 99222-3311', 'tatiane.silva@yahoo.com', 'Rua Treze de Maio, 600 - Campinas/SP'),
('HighVision Inspeções Industriais LTDA', '11.333.555/0001-77', '(11) 3044-7788', 'gerencia@highvision.com.br', 'Av. Nações Unidas, 12900 - São Paulo/SP'),
('Igor Fernando Siqueira', '890.012.234-23', '(11) 98444-1122', 'igor.siqueira@gmail.com', 'Rua Joaquim Távora, 800 - São Paulo/SP'),
('Adriana Paes Leme', '901.123.345-34', '(31) 99888-7766', 'adriana.leme@hotmail.com', 'Rua Sergipe, 900 - Belo Horizonte/MG'),
('ProDrone Mapeamento Técnico LTDA', '33.555.777/0001-88', '(41) 3322-9900', 'comercial@prodrone.com.br', 'Av. Cândido de Abreu, 500 - Curitiba/PR'),
('Fabiano Henrique de Castro', '012.234.456-45', '(11) 97555-4433', 'fabiano.castro@gmail.com', 'Rua Haddock Lobo, 1300 - São Paulo/SP'),
('Sabrina Coutinho Prado', '123.345.567-67', '(11) 98222-9988', 'sabrina.prado@outlook.com', 'Av. Angélica, 1800 - São Paulo/SP'),
('DroneTech Engenharia Ambiental LTDA', '66.888.000/0001-99', '(27) 3200-5544', 'projetos@dronetech.com.br', 'Av. Américo Buaiz, 500 - Vitória/ES'),
('Alexandre Magno Godoy', '234.456.678-78', '(19) 99444-8899', 'alexandre.godoy@gmail.com', 'Rua Barão de Jaguara, 1200 - Campinas/SP'),
('Débora Regina Marques', '345.567.789-89', '(11) 96333-7711', 'debora.marques@yahoo.com', 'Rua Melo Alves, 400 - São Paulo/SP'),
('CineFly Produções Cinematográficas LTDA', '99.111.333/0001-11', '(11) 3814-2233', 'contato@cinefly.com.br', 'Rua Vila Madalena, 500 - São Paulo/SP'),
('Wagner José de Franco', '456.678.890-90', '(11) 97999-3322', 'wagner.franco@gmail.com', 'Rua Cubatão, 600 - São Paulo/SP'),
('Lilian Maria Alcantara', '567.789.901-01', '(21) 99333-5566', 'lilian.alcantara@hotmail.com', 'Av. Niemeyer, 300 - Rio de Janeiro/RJ'),
('PrecisionCrop Drones Agrícolas LTDA', '22.555.888/0001-22', '(16) 3600-9911', 'contato@precisioncrop.com.br', 'Av. Presidente Vargas, 2000 - Ribeirão Preto/SP'),
('Danilo Gabriel Santana', '678.890.012-12', '(11) 96111-4433', 'danilo.santana@gmail.com', 'Rua Domingos de Morais, 2200 - São Paulo/SP'),
('Eliane Cristina Macedo', '789.901.123-23', '(19) 99888-2211', 'eliane.macedo@outlook.com', 'Rua Coronel Quirino, 800 - Campinas/SP'),
('Horizonte Aéreo Fotografia ME', '44.777.000/0001-33', '(11) 3214-6655', 'contato@horizonteaereo.com.br', 'Rua Augusta, 1800 - São Paulo/SP'),
('Leandro Barros de Aguiar', '890.012.234-34', '(11) 97444-3322', 'leandro.aguiar@gmail.com', 'Rua da Consolação, 3100 - São Paulo/SP'),
('Gisele Ramos Nogueira', '901.123.345-45', '(31) 99111-8899', 'gisele.nogueira@yahoo.com', 'Rua Claudio Manoel, 700 - Belo Horizonte/MG'),
('MegaFly Topografia Computadorizada LTDA', '88.222.444/0001-55', '(41) 3240-8877', 'megafly@megafly.com.br', 'Rua Marechal Deodoro, 600 - Curitiba/PR'),
('Murilo César Galvão', '012.234.456-56', '(11) 98777-4455', 'murilo.galvao@gmail.com', 'Rua Bela Cintra, 1600 - São Paulo/SP'),
('Heloísa Beatriz Mendonça', '123.345.567-78', '(11) 96555-2233', 'heloisa.mendonca@hotmail.com', 'Av. Santo Amaro, 1900 - São Paulo/SP'),
('AgroMapping Geoprocessamento LTDA', '11.555.999/0001-66', '(62) 3511-2244', 'contato@agromapping.com.br', 'Av. 85, 1800 - Goiânia/GO'),
('Cristiano Ronaldo de Matos', '234.456.678-89', '(19) 99333-1122', 'cristiano.matos@gmail.com', 'Rua Culto à Ciência, 300 - Campinas/SP'),
('Érika Vanessa Farias', '345.567.789-90', '(11) 97222-8811', 'erika.farias@outlook.com', 'Rua Loefgren, 1100 - São Paulo/SP');

-- ============================================================================
-- 2. FORNECEDORES (6 registros)
-- ============================================================================
INSERT INTO Fornecedores (razao_social, cnpj, telefone, email) VALUES
('Grupo Multilaser S.A.', '59.717.553/0001-02', '(11) 3198-0004', 'central.solucoes@grupomultilaser.com.br')
-- ============================================================================
-- 3. FUNCIONÁRIOS (8 registros)
-- ============================================================================
INSERT INTO Funcionario (nome, cargo) VALUES
('Carlos Vendedor', 'Vendedor'),
('Mariana Técnica', 'Técnica de Manutenção'),
('Roberto Gerente', 'Gerente'),
('Fernanda Lima', 'Vendedora'),
('Eduardo Rocha', 'Técnico de Manutenção'),
('Patricia Mendes', 'Atendente de Balcão'),
('Lucas Gabriel Martins', 'Vendedor'),
('Aline Souza', 'Técnica de Manutenção');

-- ============================================================================
-- 4. PRODUTOS (20 registros)
-- ============================================================================
INSERT INTO Produtos (nome, categoria, preco_venda, quantidade_estoque, preco_custo) VALUES
('Drone DJI Mini 3 Pro', 'Drones', 5000.00, 15, 3500.00),
('Bateria Inteligente DJI Mini 3', 'Baterias', 600.00, 35, 380.00),
('Cabo Flat Gimbal Mavic 2', 'Peças', 150.00, 20, 45.00),
('Drone DJI Air 3 Fly More Combo', 'Drones', 11500.00, 8, 8900.00),
('Jogo de Hélices DJI Mini 3 Pro (Par)', 'Acessórios', 90.00, 60, 25.00),
('Motor Brushless 2207 para Drone FPV', 'Peças', 180.00, 40, 75.00),
('Carregador Múltiplo de Baterias Air 3', 'Acessórios', 450.00, 18, 220.00),
('Módulo de Câmera Gimbal DJI Mavic 3', 'Peças', 2200.00, 6, 1350.00),
('Drone Matrice 300 RTK (Agrícola/Inspeção)', 'Drones', 48000.00, 3, 36000.00),
('Bateria TB60 Matrice 300', 'Baterias', 3500.00, 12, 2400.00),
('Protetor de Hélices DJI Mini 3', 'Acessórios', 120.00, 25, 45.00),
('ESC Controller 4 em 1 60A FPV', 'Peças', 420.00, 15, 210.00),
('Antena OcuSync DJI RC Pro', 'Peças', 280.00, 10, 110.00),
('Mala de Transporte Rígida Impermeável Air 3', 'Acessórios', 650.00, 12, 320.00),
('Drone DJI Mavic 3 Enterprise Thermal', 'Drones', 36000.00, 4, 27500.00),
('Bateria Inteligente Mavic 3 Enterprise', 'Baterias', 1800.00, 16, 1200.00),
('Hélice Agrícola Dobrável Matrice 300', 'Acessórios', 250.00, 30, 110.00),
('Placa Mãe Principal DJI Air 2S', 'Peças', 1450.00, 5, 850.00),
('Filtro ND Set (ND8/16/64) Mavic 3', 'Acessórios', 580.00, 14, 280.00),
('Controle Remoto DJI RC 2 com Tela', 'Acessórios', 2900.00, 7, 1900.00);

-- ============================================================================
-- 5. VENDAS (35 registros de balcão e identificadas)
-- ============================================================================
INSERT INTO Vendas (data_hora, valor_total, lucro_total, forma_pagamento, id_cliente, id_funcionario) VALUES
('2026-08-01 09:15:00', 5600.00, 1720.00, 'Pix', 1, 1),
('2026-08-03 14:30:00', 180.00, 130.00, 'Cartão de Débito', NULL, 4),
('2026-08-05 16:45:00', 12700.00, 3160.00, 'Cartão de Crédito', 2, 1),
('2026-08-08 11:20:00', 1200.00, 440.00, 'Dinheiro', 5, 4),
('2026-08-10 09:40:00', 450.00, 230.00, 'Pix', NULL, 7),
('2026-08-12 15:10:00', 55000.00, 14200.00, 'Pix', 3, 4),
('2026-08-15 13:00:00', 5240.00, 1565.00, 'Cartão de Crédito', 7, 1),
('2026-08-18 17:50:00', 270.00, 195.00, 'Cartão de Débito', NULL, 4),
('2026-08-20 10:05:00', 12150.00, 2970.00, 'Pix', 8, 1),
('2026-08-22 11:30:00', 1200.00, 440.00, 'Dinheiro', 11, 7),
('2026-08-25 16:00:00', 36000.00, 8500.00, 'Pix', 18, 1),
('2026-08-28 14:20:00', 3600.00, 1200.00, 'Cartão de Crédito', 15, 4),
('2026-09-01 10:00:00', 2900.00, 1000.00, 'Pix', 12, 7),
('2026-09-03 12:45:00', 580.00, 300.00, 'Cartão de Débito', NULL, 1),
('2026-09-05 15:30:00', 11500.00, 2600.00, 'Pix', 21, 4),
('2026-09-08 11:15:00', 600.00, 220.00, 'Dinheiro', 22, 1),
('2026-09-10 09:30:00', 650.00, 330.00, 'Cartão de Débito', NULL, 7),
('2026-09-12 14:00:00', 48000.00, 12000.00, 'Pix', 33, 4),
('2026-09-15 16:20:00', 1800.00, 600.00, 'Cartão de Crédito', 24, 1),
('2026-09-18 10:10:00', 90.00, 65.00, 'Dinheiro', NULL, 7),
('2026-09-20 13:40:00', 5000.00, 1500.00, 'Pix', 27, 4),
('2026-09-22 17:15:00', 1200.00, 440.00, 'Cartão de Débito', 30, 1),
('2026-09-25 09:50:00', 7000.00, 2200.00, 'Pix', 36, 7),
('2026-09-28 15:00:00', 11500.00, 2600.00, 'Cartão de Crédito', 39, 4),
('2026-10-01 10:30:00', 450.00, 230.00, 'Pix', NULL, 1),
('2026-10-03 14:15:00', 36000.00, 8500.00, 'Pix', 42, 7),
('2026-10-05 16:00:00', 500.00, 220.00, 'Dinheiro', 45, 4),
('2026-10-08 11:45:00', 1800.00, 600.00, 'Cartão de Crédito', 48, 1),
('2026-10-10 13:20:00', 11500.00, 2600.00, 'Pix', 51, 7),
('2026-10-12 15:50:00', 270.00, 195.00, 'Cartão de Débito', NULL, 4),
('2026-10-15 10:10:00', 5000.00, 1500.00, 'Pix', 54, 1),
('2026-10-18 14:40:00', 580.00, 300.00, 'Cartão de Crédito', 57, 7),
('2026-10-20 16:30:00', 2900.00, 1000.00, 'Pix', 60, 4),
('2026-10-22 09:15:00', 600.00, 220.00, 'Dinheiro', 63, 1),
('2026-10-25 11:00:00', 48000.00, 12000.00, 'Pix', 69, 7);

-- ============================================================================
-- 6. COMPOE_VENDA (Itens das Vendas - ~50 registros)
-- ============================================================================
INSERT INTO Compoe_Venda (id_venda, id_produto, quantidade, preco_unitario_aplicado, preco_custo_aplicado) VALUES
(1, 1, 1, 5000.00, 3500.00), (1, 2, 1, 600.00, 380.00),
(2, 5, 2, 90.00, 25.00),
(3, 4, 1, 11500.00, 8900.00), (3, 2, 2, 600.00, 380.00),
(4, 2, 2, 600.00, 380.00),
(5, 7, 1, 450.00, 220.00),
(6, 9, 1, 48000.00, 36000.00), (6, 10, 2, 3500.00, 2400.00),
(7, 1, 1, 5000.00, 3500.00), (7, 11, 2, 120.00, 45.00),
(8, 5, 3, 90.00, 25.00),
(9, 4, 1, 11500.00, 8900.00), (9, 14, 1, 650.00, 320.00),
(10, 2, 2, 600.00, 380.00),
(11, 15, 1, 36000.00, 27500.00),
(12, 16, 2, 1800.00, 1200.00),
(13, 20, 1, 2900.00, 1900.00),
(14, 19, 1, 580.00, 280.00),
(15, 4, 1, 11500.00, 8900.00),
(16, 2, 1, 600.00, 380.00),
(17, 14, 1, 650.00, 320.00),
(18, 9, 1, 48000.00, 36000.00),
(19, 16, 1, 1800.00, 1200.00),
(20, 5, 1, 90.00, 25.00),
(21, 1, 1, 5000.00, 3500.00),
(22, 2, 2, 600.00, 380.00),
(23, 10, 2, 3500.00, 2400.00),
(24, 4, 1, 11500.00, 8900.00),
(25, 7, 1, 450.00, 220.00),
(26, 15, 1, 36000.00, 27500.00),
(27, 17, 2, 250.00, 110.00),
(28, 16, 1, 1800.00, 1200.00),
(29, 4, 1, 11500.00, 8900.00),
(30, 5, 3, 90.00, 25.00),
(31, 1, 1, 5000.00, 3500.00),
(32, 19, 1, 580.00, 280.00),
(33, 20, 1, 2900.00, 1900.00),
(34, 2, 1, 600.00, 380.00),
(35, 9, 1, 48000.00, 36000.00);

-- ============================================================================
-- 7. ORDEM_SERVICO (25 registros em múltiplos status)
-- ============================================================================
INSERT INTO Ordem_Servico (aparelho_drone, defeito_relatado, status, valor_mao_obra, valor_pecas, valor_total, data_abertura, data_conclusao, prazo_garantia_dias, id_cliente, id_tecnico) VALUES
('DJI Mavic 2 Pro', 'Queda de altitude e cabo flat partido', 'Concluído', 300.00, 150.00, 450.00, '2026-08-02 09:00:00', '2026-08-05 17:00:00', 90, 2, 2),
('DJI Mavic 3 Enterprise', 'Impacto na câmera frontal durante mapeamento', 'Em Manutenção', 800.00, 2200.00, 3000.00, '2026-08-06 10:30:00', NULL, 90, 3, 5),
('Drone FPV Custom', 'Falha no motor 3 após colisão em treino', 'Orçamento', 150.00, 180.00, 330.00, '2026-08-10 15:10:00', NULL, 90, 4, 2),
('DJI Air 2S', 'Substituição do módulo de hélices e calibração', 'Entregue com Garantia', 200.00, 180.00, 380.00, '2026-08-12 08:30:00', '2026-08-14 12:00:00', 90, 6, 5),
('Drone FPV Racing 5"', 'Erro na transmissão de vídeo e ESC queimado', 'Aprovado', 250.00, 420.00, 670.00, '2026-08-15 11:00:00', NULL, 90, 9, 8),
('DJI Phantom 4 Pro', 'Danos estruturais severos na carcaça e placa-mãe', 'Cancelado', 0.00, 0.00, 0.00, '2026-08-18 14:20:00', '2026-08-19 09:00:00', 90, 10, 5),
('DJI Mini 2', 'Perda de sinal de controle e antena avariada', 'Concluído', 180.00, 280.00, 460.00, '2026-08-20 16:00:00', '2026-08-22 11:30:00', 90, 1, 2),
('DJI Inspire 2', 'Falha no trem de pouso retrátil', 'Orçamento', 400.00, 0.00, 400.00, '2026-08-25 14:00:00', NULL, 90, 12, 8),
('DJI Air 2S', 'Queima da placa mãe em voo sobre água', 'Concluído', 450.00, 1450.00, 1900.00, '2026-09-01 09:30:00', '2026-09-04 16:00:00', 90, 13, 5),
('DJI Mini 3 Pro', 'Gimbal travado após impacto em árvore', 'Em Manutenção', 350.00, 0.00, 350.00, '2026-09-05 11:00:00', NULL, 90, 16, 2),
('Drone Matrice 300', 'Substituição de hélices danificadas', 'Entregue com Garantia', 300.00, 500.00, 800.00, '2026-09-08 13:15:00', '2026-09-09 17:00:00', 90, 17, 8),
('DJI Mavic 3 Enterprise', 'Erro no módulo de transmissão RTK', 'Aprovado', 600.00, 0.00, 600.00, '2026-09-12 10:00:00', NULL, 90, 20, 5),
('Drone FPV 7"', 'Motor aquecendo e descalibrado', 'Concluído', 200.00, 180.00, 380.00, '2026-09-15 15:45:00', '2026-09-17 11:00:00', 90, 23, 2),
('DJI Phantom 4 RTK', 'Calibração de bússola e IMU', 'Entregue com Garantia', 250.00, 0.00, 250.00, '2026-09-20 08:50:00', '2026-09-21 14:00:00', 90, 26, 8),
('DJI Mini 3', 'Carcaça trincada em queda simples', 'Concluído', 180.00, 90.00, 270.00, '2026-09-25 14:30:00', '2026-09-27 10:00:00', 90, 29, 5),
('DJI Air 3', 'Sensor anticolisão traseiro inoperante', 'Orçamento', 300.00, 0.00, 300.00, '2026-09-28 16:10:00', NULL, 90, 32, 2),
('DJI Mavic 2 Zoom', 'Zoom óptico travando no comando', 'Aprovado', 400.00, 150.00, 550.00, '2026-10-02 09:00:00', NULL, 90, 35, 8),
('Drone FPV Cinewhoop', 'ESC queimado após voo indoor', 'Concluído', 220.00, 420.00, 640.00, '2026-10-05 11:20:00', '2026-10-07 15:30:00', 90, 38, 5),
('DJI Spark', 'Bateria não trava no compartimento', 'Cancelado', 0.00, 0.00, 0.00, '2026-10-08 14:00:00', '2026-10-08 17:00:00', 90, 41, 2),
('DJI Mavic 3 Pro', 'Substituição da lente da câmera tele', 'Em Manutenção', 750.00, 2200.00, 2950.00, '2026-10-12 10:45:00', NULL, 90, 44, 8),
('DJI Inspire 2', 'Revisão geral e atualização de firmware', 'Entregue com Garantia', 500.00, 0.00, 500.00, '2026-10-15 13:30:00', '2026-10-17 12:00:00', 90, 47, 5),
('DJI Mini 2 SE', 'Cabo do controle quebrado', 'Concluído', 100.00, 150.00, 250.00, '2026-10-18 16:00:00', '2026-10-19 11:00:00', 90, 50, 2),
('Drone FPV 5"', 'Troca de 2 motores danificados', 'Concluído', 250.00, 360.00, 610.00, '2026-10-21 09:15:00', '2026-10-23 16:45:00', 90, 53, 8),
('DJI Air 2S', 'Troca da placa principal e gimbal', 'Em Manutenção', 500.00, 1450.00, 1950.00, '2026-10-24 11:30:00', NULL, 90, 56, 5),
('DJI Mavic Mini', 'Troca de hélices e teste de bancada', 'Concluído', 120.00, 90.00, 210.00, '2026-10-27 15:00:00', '2026-10-28 10:00:00', 90, 62, 2);

-- ============================================================================
-- 8. PECAS_OS (16 registros)
-- ============================================================================
INSERT INTO Pecas_OS (id_os, id_produto, quantidade, preco_unitario_aplicado) VALUES
(1, 3, 1, 150.00),
(2, 8, 1, 2200.00),
(3, 6, 1, 180.00),
(4, 5, 2, 90.00),
(5, 12, 1, 420.00),
(7, 13, 1, 280.00),
(9, 18, 1, 1450.00),
(11, 17, 2, 250.00),
(13, 6, 1, 180.00),
(15, 5, 1, 90.00),
(17, 3, 1, 150.00),
(18, 12, 1, 420.00),
(20, 8, 1, 2200.00),
(22, 3, 1, 150.00),
(23, 6, 2, 180.00),
(24, 18, 1, 1450.00);

-- ============================================================================
-- 9. MOVIMENTACOES_ESTOQUE (30 registros)
-- ============================================================================
INSERT INTO Movimentacoes_Estoque (id_produto, id_funcionario, id_fornecedor, quantidade_mov, observacao, data_movimentacao, tipo_movimentacao) VALUES
(2, 3, 1, 40, 'NF 45890 - Reposição de baterias DJI Mini 3', '2026-07-20 09:00:00', 'Entrada Compra'),
(5, 3, 2, 80, 'NF 12904 - Lote de hélices de reposição', '2026-07-25 11:15:00', 'Entrada Compra'),
(10, 3, 3, 15, 'NF 88310 - Baterias Matrice 300', '2026-08-01 10:30:00', 'Entrada Compra'),
(16, 3, 6, 20, 'NF 00219 - Baterias Mavic 3 Enterprise', '2026-08-10 14:00:00', 'Entrada Compra'),
(15, 3, 5, 5, 'NF 99120 - Drones Mavic 3 Enterprise', '2026-08-15 16:30:00', 'Entrada Compra'),
(1, 1, NULL, -1, 'Saída referente à Venda #1', '2026-08-01 09:15:00', 'Saída Venda'),
(2, 1, NULL, -1, 'Saída referente à Venda #1', '2026-08-01 09:15:00', 'Saída Venda'),
(5, 4, NULL, -2, 'Saída referente à Venda #2', '2026-08-03 14:30:00', 'Saída Venda'),
(4, 1, NULL, -1, 'Saída referente à Venda #3', '2026-08-05 16:45:00', 'Saída Venda'),
(9, 4, NULL, -1, 'Saída referente à Venda #6', '2026-08-12 15:10:00', 'Saída Venda'),
(15, 1, NULL, -1, 'Saída referente à Venda #11', '2026-08-25 16:00:00', 'Saída Venda'),
(20, 7, NULL, -1, 'Saída referente à Venda #13', '2026-09-01 10:00:00', 'Saída Venda'),
(9, 4, NULL, -1, 'Saída referente à Venda #18', '2026-09-12 14:00:00', 'Saída Venda'),
(3, 2, NULL, -1, 'Peça aplicada na OS #1', '2026-08-03 14:00:00', 'Uso em OS'),
(8, 5, NULL, -1, 'Peça aplicada na OS #2', '2026-08-07 11:30:00', 'Uso em OS'),
(6, 2, NULL, -1, 'Peça aplicada na OS #3', '2026-08-11 10:00:00', 'Uso em OS'),
(5, 5, NULL, -2, 'Peças aplicadas na OS #4', '2026-08-13 09:15:00', 'Uso em OS'),
(12, 8, NULL, -1, 'Peça aplicada na OS #5', '2026-08-16 14:20:00', 'Uso em OS'),
(13, 2, NULL, -1, 'Peça aplicada na OS #7', '2026-08-21 15:00:00', 'Uso em OS'),
(18, 5, NULL, -1, 'Peça aplicada na OS #9', '2026-09-03 11:00:00', 'Uso em OS'),
(17, 8, NULL, -2, 'Peças aplicadas na OS #11', '2026-09-09 14:30:00', 'Uso em OS'),
(12, 5, NULL, -1, 'Peça aplicada na OS #18', '2026-10-06 10:00:00', 'Uso em OS'),
(8, 8, NULL, -1, 'Peça aplicada na OS #20', '2026-10-13 16:00:00', 'Uso em OS'),
(18, 5, NULL, -1, 'Peça aplicada na OS #24', '2026-10-25 09:30:00', 'Uso em OS'),
(5, 3, NULL, -3, 'Hélices avariadas em teste de bancada', '2026-08-28 11:00:00', 'Perda'),
(2, 3, NULL, -1, 'Bateria com vício de fabricação descartada', '2026-09-14 16:00:00', 'Perda'),
(6, 3, NULL, 5, 'Ajuste de inventário - Contagem física superior', '2026-09-30 17:00:00', 'Ajuste Inventário'),
(11, 3, NULL, 4, 'Ajuste de inventário - Correção de saldo', '2026-10-15 11:30:00', 'Ajuste Inventário');

-- ============================================================================
-- 10. HISTORICO_PRECOS (8 registros de auditoria de alteração de preço)
-- ============================================================================
INSERT INTO Historico_Precos (id_produto, id_funcionario, data_alteracao, preco_custo_novo, preco_venda_novo, preco_custo_antigo, preco_venda_antigo) VALUES
(2, 3, '2026-07-25 08:30:00', 380.00, 600.00, 350.00, 550.00),
(4, 3, '2026-08-01 09:00:00', 8900.00, 11500.00, 8900.00, 11000.00),
(8, 3, '2026-08-15 10:00:00', 1350.00, 2200.00, 1200.00, 2000.00),
(10, 3, '2026-08-20 14:15:00', 2400.00, 3500.00, 2300.00, 3300.00),
(15, 3, '2026-09-01 11:00:00', 27500.00, 36000.00, 26000.00, 34500.00),
(16, 3, '2026-09-10 15:30:00', 1200.00, 1800.00, 1100.00, 1650.00),
(18, 3, '2026-09-25 09:45:00', 850.00, 1450.00, 800.00, 1350.00),
(20, 3, '2026-10-05 13:20:00', 1900.00, 2900.00, 1800.00, 2750.00);

-- ------------------------------------------------------------
-- 3. CONSULTAS GERENCIAIS (G01, G02...) E DE AUDITORIA (A01...)
-- ------------------------------------------------------------

-- G01 — Qual o saldo atual e o histórico de movimentações de produtos por fornecedor?
-- Atende: P1 (Divergência de Saldo de Estoque) e KPI-01 (Saldo de Estoque Crítico)
SELECT 
    p.nome AS Produto,
    p.categoria,
    p.quantidade_estoque AS Saldo_Atual,
    f.razao_social AS Fornecedor_Origem,
    m.tipo_movimentacao,
    m.quantidade_mov,
    m.data_movimentacao
FROM Produtos p
LEFT JOIN Movimentacoes_Estoque m ON p.id = m.id_produto
LEFT JOIN Fornecedores f ON m.id_fornecedor = f.id;


-- G02 — Qual o faturamento total acumulado e a distribuição por status das Ordens de Serviço?
-- Atende: P2 (Ausência de Controle Formal de Ordens de Serviço) e KPI-02 (Faturamento de Manutenção)
SELECT 
    status,
    COUNT(id) AS Qtd_OS,
    SUM(valor_mao_obra) AS Faturamento_Mao_Obra,
    SUM(valor_pecas) AS Faturamento_Pecas,
    SUM(valor_total) AS Faturamento_Total_OS
FROM Ordem_Servico
GROUP BY status;


-- G03 — Qual o faturamento bruto, custo total e lucro líquido apurado nas Vendas de Balcão por vendedor?
-- Atende: P3 (Incerteza Financeira na Apuração de Margens e Comissões) e KPI-03 (Margem de Lucro)
SELECT 
    v.id AS ID_Venda,
    v.data_hora,
    v.forma_pagamento,
    f.nome AS Vendedor,
    c.nome_razao AS Cliente,
    v.valor_total AS Valor_Bruto,
    v.lucro_total AS Lucro_Líquido
FROM Vendas v
INNER JOIN Funcionario f ON v.id_funcionario = f.id
LEFT JOIN Clientes c ON v.id_cliente = c.id;


-- A01 — Existe alguma Ordem de Serviço registrada sem cliente vinculado?
-- Verifica: RN03 (Obrigatoriedade de cliente cadastrado para abertura de Ordem de Serviço)
SELECT 
    id AS OS_Invalida, 
    aparelho_drone, 
    defeito_relatado, 
    status 
FROM Ordem_Servico 
WHERE id_cliente IS NULL;
