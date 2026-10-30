- 01_ddl.sql — HD Drones (MySQL 8 / InnoDB)
DROP DATABASE IF EXISTS hd_drones;
CREATE DATABASE hd_drones CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hd_drones;

CREATE TABLE funcionario (
  id_funcionario INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome  VARCHAR(100) NOT NULL,
  cargo VARCHAR(20)  NOT NULL,
  ativo TINYINT(1)   NOT NULL DEFAULT 1,
  CONSTRAINT pk_funcionario PRIMARY KEY (id_funcionario),
  CONSTRAINT ck_funcionario_cargo CHECK (cargo IN ('Proprietário','Vendedor','Técnico'))
) ENGINE=InnoDB;

CREATE TABLE vendedor (
  id_funcionario INT UNSIGNED NOT NULL,
  percentual_comissao DECIMAL(5,2) NOT NULL DEFAULT 0,
  CONSTRAINT pk_vendedor PRIMARY KEY (id_funcionario),
  CONSTRAINT fk_vendedor_func FOREIGN KEY (id_funcionario) REFERENCES funcionario (id_funcionario),
  CONSTRAINT ck_vendedor_comissao CHECK (percentual_comissao BETWEEN 0 AND 100)
) ENGINE=InnoDB;

CREATE TABLE tecnico (
  id_funcionario INT UNSIGNED NOT NULL,
  especialidade VARCHAR(80) NOT NULL,
  CONSTRAINT pk_tecnico PRIMARY KEY (id_funcionario),
  CONSTRAINT fk_tecnico_func FOREIGN KEY (id_funcionario) REFERENCES funcionario (id_funcionario)
) ENGINE=InnoDB;

CREATE TABLE cliente (
  id_cliente INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome_razao  VARCHAR(120) NOT NULL,
  cpf_cnpj    VARCHAR(18)  NOT NULL,
  telefone    VARCHAR(15)  NULL,
  email       VARCHAR(120) NULL,
  logradouro  VARCHAR(120) NULL,
  numero      VARCHAR(10)  NULL,
  complemento VARCHAR(60)  NULL,
  bairro      VARCHAR(60)  NULL,
  cidade      VARCHAR(60)  NULL,
  uf          CHAR(2)      NULL,
  cep         CHAR(9)      NULL,
  CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
  CONSTRAINT uq_cliente_cpf_cnpj UNIQUE (cpf_cnpj),
  CONSTRAINT ck_cliente_doc CHECK (CHAR_LENGTH(cpf_cnpj) IN (14,18))
) ENGINE=InnoDB;

CREATE TABLE produto (
  id_produto INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  categoria VARCHAR(20) NOT NULL,
  preco_venda DECIMAL(10,2) NOT NULL,
  preco_custo DECIMAL(10,2) NOT NULL,
  quantidade_estoque INT NOT NULL DEFAULT 0,
  estoque_minimo INT NOT NULL DEFAULT 0,
  CONSTRAINT pk_produto PRIMARY KEY (id_produto),
  CONSTRAINT ck_produto_categoria CHECK (categoria IN ('Drones','Baterias','Acessórios','Peças')),
  CONSTRAINT ck_produto_precos CHECK (preco_venda >= 0 AND preco_custo >= 0),
  CONSTRAINT ck_produto_estoque CHECK (quantidade_estoque >= 0 AND estoque_minimo >= 0)
) ENGINE=InnoDB;
CREATE INDEX idx_produto_nome ON produto (nome);

CREATE TABLE venda (
  id_venda INT UNSIGNED NOT NULL AUTO_INCREMENT,
  data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tipo VARCHAR(20) NOT NULL DEFAULT 'Venda Balcão',
  status VARCHAR(15) NOT NULL DEFAULT 'Concluída',
  valor_total DECIMAL(12,2) NOT NULL DEFAULT 0,
  lucro_total DECIMAL(12,2) NOT NULL DEFAULT 0,
  forma_pagamento VARCHAR(20) NOT NULL,
  id_cliente INT UNSIGNED NULL,
  id_funcionario INT UNSIGNED NOT NULL,
  CONSTRAINT pk_venda PRIMARY KEY (id_venda),
  CONSTRAINT fk_venda_cliente FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
  CONSTRAINT fk_venda_func FOREIGN KEY (id_funcionario) REFERENCES funcionario (id_funcionario),
  CONSTRAINT ck_venda_tipo CHECK (tipo IN ('Venda Balcão','Ordem de Serviço')),
  CONSTRAINT ck_venda_status CHECK (status IN ('Em Andamento','Concluída','Cancelada')),
  CONSTRAINT ck_venda_pgto CHECK (forma_pagamento IN ('Pix','Dinheiro','Cartão de Crédito','Cartão de Débito'))
) ENGINE=InnoDB;
CREATE INDEX idx_venda_data ON venda (data_hora);

CREATE TABLE ordem_servico (
  id_venda INT UNSIGNED NOT NULL,
  id_tecnico INT UNSIGNED NOT NULL,
  equipamento VARCHAR(100) NOT NULL,
  defeito_relatado VARCHAR(255) NOT NULL,
  valor_mao_obra DECIMAL(10,2) NOT NULL DEFAULT 0,
  data_conclusao DATETIME NULL,
  CONSTRAINT pk_os PRIMARY KEY (id_venda),
  CONSTRAINT fk_os_venda FOREIGN KEY (id_venda) REFERENCES venda (id_venda),
  CONSTRAINT fk_os_tecnico FOREIGN KEY (id_tecnico) REFERENCES tecnico (id_funcionario),
  CONSTRAINT ck_os_mao_obra CHECK (valor_mao_obra >= 0)
) ENGINE=InnoDB;

CREATE TABLE item_venda (
  id_venda INT UNSIGNED NOT NULL,
  id_produto INT UNSIGNED NOT NULL,
  quantidade INT NOT NULL,
  preco_unitario_aplicado DECIMAL(10,2) NOT NULL,
  preco_custo_aplicado DECIMAL(10,2) NOT NULL,
  CONSTRAINT pk_item_venda PRIMARY KEY (id_venda, id_produto),
  CONSTRAINT fk_item_venda FOREIGN KEY (id_venda) REFERENCES venda (id_venda),
  CONSTRAINT fk_item_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto),
  CONSTRAINT ck_item_qtd CHECK (quantidade > 0),
  CONSTRAINT ck_item_precos CHECK (preco_unitario_aplicado >= 0 AND preco_custo_aplicado >= 0)
) ENGINE=InnoDB;

CREATE TABLE historico_preco (
  id_historico INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_produto INT UNSIGNED NOT NULL,
  id_funcionario INT UNSIGNED NOT NULL,
  preco_custo_antigo DECIMAL(10,2) NOT NULL,
  preco_venda_antigo DECIMAL(10,2) NOT NULL,
  preco_custo_novo DECIMAL(10,2) NOT NULL,
  preco_venda_novo DECIMAL(10,2) NOT NULL,
  data_alteracao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_historico PRIMARY KEY (id_historico),
  CONSTRAINT fk_hist_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto),
  CONSTRAINT fk_hist_func FOREIGN KEY (id_funcionario) REFERENCES funcionario (id_funcionario)
) ENGINE=InnoDB;

CREATE TABLE movimentacao_estoque (
  id_movimentacao INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_produto INT UNSIGNED NOT NULL,
  id_funcionario INT UNSIGNED NOT NULL,
  id_venda INT UNSIGNED NULL,
  quantidade_mov INT NOT NULL,
  tipo_movimentacao VARCHAR(25) NOT NULL,
  data_movimentacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  observacao VARCHAR(255) NULL,
  CONSTRAINT pk_movimentacao PRIMARY KEY (id_movimentacao),
  CONSTRAINT fk_mov_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto),
  CONSTRAINT fk_mov_func FOREIGN KEY (id_funcionario) REFERENCES funcionario (id_funcionario),
  CONSTRAINT fk_mov_venda FOREIGN KEY (id_venda) REFERENCES venda (id_venda),
  CONSTRAINT ck_mov_qtd CHECK (quantidade_mov > 0),
  CONSTRAINT ck_mov_tipo CHECK (tipo_movimentacao IN ('Entrada','Saída Manual','Ajuste Positivo','Ajuste Negativo','Perda','Saída Venda','Saída OS','Estorno Cancelamento'))
) ENGINE=InnoDB;
CREATE INDEX idx_mov_produto_data ON movimentacao_estoque (id_produto, data_movimentacao);
