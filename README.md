# Entrega 2 — Relatório Técnico Final

### Modelagem Lógica, Normalização e Banco de Dados Relacional para a HD Drones

---

## Metadados

* **Nomes dos alunos e RGM:**
* Adriano Salviano Marcal | RGM: 48188697
* Arthur Tigre Francisco | RGM: 48201413
* Gabriel de Oliveira Silva | RGM: 48203068
* Gabriel Marcolino de Oliveira | RGM: 48226718
* Giovanni dos Santos Silva | RGM: 48159077



---

## 1. Caracterização da Organização

* **Nome e natureza da organização:** HD Drones — Comércio e Assistência Técnica de Drones e Acessórios LTDA. Empresa comercial e de serviços de pequeno porte (Sociedade Empresária Limitada).
* **Contexto e porte:** Organização comercial e de serviços atuando na venda de drones novos/seminovos, peças de reposição, acessórios e serviços de manutenção/ordens de serviço. Conta com equipe enxuta composta por 5 colaboradores directos: 1 gestor proprietário, 2 vendedores de balcão e 2 técnicos de assistência. Operação diária média de 15 a 25 atendimentos entre vendas diretas de balcão e entradas de aparelhos para orçamento e reparo.
* **Problemas e necessidades identificados:** O gerenciamento operacional era realizado através de anotações descentralizadas e planilhas manuais. A ausência de um sistema integrado gerava gargalos graves:
* Divergência no saldo de produtos em estoque e perda de rastreabilidade de peças utilizadas na assistência técnica.
* Ausência de controle formal das ordens de serviço (orçamento, aprovação, execução e garantia).
* Dificuldade na apuração de comissões de funcionários e margens reais sobre produtos e serviços.
* Falta de controle do ciclo de compras junto a fornecedores e ausência de histórico auditável sobre alterações de preços e movimentações de estoque.


* **Justificativa da escolha:** A HD Drones é uma empresa real e ativa com acesso direto garantido para pesquisa de campo, entrevistas operacionais e mapeamento de processos.
* **Evidências da organização:**
* **Endereço Completo:** Rua Santa Ifigênia, 480, Loja 22 — Centro Histórico de São Paulo, São Paulo - SP, CEP 01207-000.
* **Forma de contato:** Telefone/WhatsApp empresarial: (11) 98888-0000 | E-mail: contato@hddrones.com.br.
* **Atividades e Acesso de Campo:** O integrante do grupo Gabriel de Oliveira Silva trabalha na própria organização, garantindo acesso direto e diário ao proprietário, às rotinas operacionais, ao fluxo do caixa (PDV) e ao levantamento das ordens de serviço (OS).
* **Comprovação Visual:** Foto do integrante atuando no local de trabalho anexada na pasta de evidências do repositório (`/evidencias/foto_campo.jpg`).



---

## 2. Processos de Negócio

* **Principais processos mapeados:**
1. **Cadastro e Gestão de Clientes e Fornecedores:** Captação de dados cadastrais fiscais e essenciais (`nome_razao`, `cpf_cnpj`, `telefone`, `email`, `endereco`) de clientes e fornecedores para compras e histórico comercial.
2. **Venda de Balcão (PDV):** Seleção de produtos, baixa de saldo em estoque, cálculo da comissão do vendedor e congelamento de preços praticados.
3. **Abertura, Execução e Garantia de Ordem de Serviço (OS):** Registro de assistência técnica vinculando obrigatoriamente um cliente, detalhando defeito, aprovação de orçamento, valor da mão de obra, baixa automática de peças utilizadas (`Pecas_OS`) e prazo legal de garantia (CDC).
4. **Ciclo de Compras e Estoque:** Registro de entrada de mercadorias via fornecedores, ajustes de inventário e auditoria de movimentações (`Movimentacoes_Estoque`).
5. **Apoio e Comissões:** Apuração do lucro líquido por operação e relatório consolidado de comissões por funcionário.



---

## 3. Requisitos do Sistema

### 3.1 Requisitos Funcionais

* **RF01:** O sistema deve permitir o cadastro de clientes e fornecedores com identificador único de CPF ou CNPJ.
* **RF02:** O sistema deve permitir a associação opcional de cliente nas vendas de balcão, mas **exigir obrigatoriamente** o vínculo de um cliente cadastrado ao abrir uma Ordem de Serviço (OS).
* **RF03:** O sistema deve registrar vendas e ordens de serviço associando-as ao funcionário responsável, calculando a respectiva comissão sobre a transação.
* **RF04:** O sistema deve dar baixa automática no estoque de produtos e peças a cada item vendido ou utilizado em ordens de serviço.
* **RF05:** O sistema deve congelar o preço de custo e venda dos itens no momento da transação e registrar prazos de garantia legais para serviços concluídos.
* **RF06:** O sistema deve registrar entradas de compras associadas aos respectivos fornecedores.
* **RF07:** O sistema deve manter histórico auditável imutável de alterações de preços e movimentações físicas de estoque.

### 3.2 Requisitos Não Funcionais

* **RNF01 (Desempenho):** As consultas de saldo de estoque e busca de clientes devem responder em tempo inferior a 2 segundos.
* **RNF02 (Integridade Referencial):** O SGBD deve garantir a consistência das chaves estrangeiras (`FK`), impedindo a exclusão de clientes, fornecedores ou produtos com registros vinculados.
* **RNF03 (Usabilidade e Concorrência):** A interface deve permitir transações simultâneas em ambiente multiusuário garantindo suporte a propriedades ACID através do mecanismo InnoDB no MySQL 8.

---

## 4. Regras de Negócio

* **Regras operacionais:**
* **RN01 (Unicidade de Identificação):** O mesmo CPF ou CNPJ não pode ser cadastrado em duplicidade (`UNIQUE`).
* **RN02 (Congelamento Financeiro):** Os preços e custos aplicados em vendas e OS são salvos nas tabelas associativas no momento da operação para preservar o histórico financeiro.
* **RN03 (Opcionalidade vs. Obrigatoriedade de Cliente):** Vendas de balcão permitem cliente nulo/opcional; Ordens de Serviço exigem cliente cadastrado.
* **RN04 (Garantia Legal CDC):** Toda Ordem de Serviço entregue gera automaticamente uma cobertura de garantia padrão de 90 dias.
* **RN05 (Atribuição de Comissões):** Cada funcionário possui um percentual de comissão associado que incide sobre o valor total gerado nas transações registradas por ele.



---

## 5. Dicionário de Dados Lógico (Resumo de Tabelas)

### Tabela: `Clientes`

| Coluna | Tipo de Dado | Restrições | Descrição |
| --- | --- | --- | --- |
| `id` | `INT` | `PK`, `AUTO_INCREMENT` | Identificador único do cliente. |
| `nome_razao` | `VARCHAR(150)` | `NOT NULL` | Nome completo ou Razão Social. |
| `cpf_cnpj` | `VARCHAR(20)` | `NOT NULL`, `UNIQUE` | Documento fiscal do cliente. |
| `telefone` | `VARCHAR(20)` | `NOT NULL` | Telefone ou WhatsApp para contato. |
| `email` | `VARCHAR(100)` | Opcional | E-mail de contato. |
| `endereco` | `VARCHAR(255)` | Opcional | Endereço residencial ou comercial. |

### Tabela: `Fornecedores`

| Coluna | Tipo de Dado | Restrições | Descrição |
| --- | --- | --- | --- |
| `id` | `INT` | `PK`, `AUTO_INCREMENT` | Identificador único do fornecedor. |
| `razao_social` | `VARCHAR(150)` | `NOT NULL` | Razão Social da empresa fornecedora. |
| `cnpj` | `VARCHAR(20)` | `NOT NULL`, `UNIQUE` | CNPJ do fornecedor. |
| `telefone` | `VARCHAR(20)` | `NOT NULL` | Telefone de contato comercial. |

### Tabela: `Funcionario`

| Coluna | Tipo de Dado | Restrições | Descrição |
| --- | --- | --- | --- |
| `id` | `INT` | `PK`, `AUTO_INCREMENT` | Identificador do colaborador. |
| `nome` | `VARCHAR(100)` | `NOT NULL` | Nome do colaborador. |
| `cargo` | `VARCHAR(50)` | `NOT NULL` | Função exercida na empresa. |
| `percentual_comissao` | `DECIMAL(4,2)` | Valor padrão `0.00` | Alíquota de comissão por venda/serviço. |

### Tabela: `Produtos`

| Coluna | Tipo de Dado | Restrições | Descrição |
| --- | --- | --- | --- |
| `id` | `INT` | `PK`, `AUTO_INCREMENT` | Identificador do produto/peça. |
| `nome` | `VARCHAR(150)` | `NOT NULL` | Descrição comercial do produto. |
| `categoria` | `ENUM` | `NOT NULL` | 'Drones', 'Baterias', 'Acessórios', 'Peças'. |
| `preco_venda` | `DECIMAL(10,2)` | `NOT NULL` | Preço de tabela para venda. |
| `preco_custo` | `DECIMAL(10,2)` | `NOT NULL` | Preço de aquisição do item. |
| `quantidade_estoque` | `INT` | Valor padrão `0` | Saldo físico em estoque. |

### Tabela: `Vendas`

| Coluna | Tipo de Dado | Restrições | Descrição |
| --- | --- | --- | --- |
| `id` | `INT` | `PK`, `AUTO_INCREMENT` | Identificador único da venda de balcão. |
| `data_hora` | `DATETIME` | `DEFAULT CURRENT_TIMESTAMP` | Carimbo de data/hora da transação. |
| `valor_total` | `DECIMAL(10,2)` | `DEFAULT 0.00` | Valor bruto da transação. |
| `lucro_total` | `DECIMAL(10,2)` | `DEFAULT 0.00` | Lucro líquido obtido. |
| `valor_comissao` | `DECIMAL(10,2)` | `DEFAULT 0.00` | Valor da comissão apurada. |
| `forma_pagamento` | `ENUM` | `NOT NULL` | 'Pix', 'Dinheiro', 'Cartão de Crédito', 'Cartão de Débito'. |
| `id_cliente` | `INT` | `FK` (Clientes), Opcional | Cliente vinculado à venda. |
| `id_funcionario` | `INT` | `FK` (Funcionario), `NOT NULL` | Vendedor responsável. |

### Tabela: `Ordem_Servico`

| Coluna | Tipo de Dado | Restrições | Descrição |
| --- | --- | --- | --- |
| `id` | `INT` | `PK`, `AUTO_INCREMENT` | Identificador da Ordem de Serviço. |
| `aparelho_drone` | `VARCHAR(100)` | `NOT NULL` | Modelo do equipamento recebido. |
| `defeito_relatado` | `TEXT` | `NOT NULL` | Descrição do problema pelo cliente. |
| `status` | `ENUM` | Default 'Orçamento' | 'Orçamento', 'Aprovado', 'Em Manutenção', 'Concluído', 'Entregue com Garantia', 'Cancelado'. |
| `valor_mao_obra` | `DECIMAL(10,2)` | `DEFAULT 0.00` | Valor cobrado pelo serviço técnico. |
| `valor_pecas` | `DECIMAL(10,2)` | `DEFAULT 0.00` | Soma das peças aplicadas no conserto. |
| `valor_total` | `DECIMAL(10,2)` | `DEFAULT 0.00` | Valor total da OS (`mao_obra + pecas`). |
| `prazo_garantia_dias` | `INT` | Default `90` | Período legal de garantia. |
| `id_cliente` | `INT` | `FK` (Clientes), `NOT NULL` | Cliente proprietário do equipamento. |
| `id_tecnico` | `INT` | `FK` (Funcionario), `NOT NULL` | Técnico responsável pela manutenção. |

---

## 6. Modelagem Lógica e Relações

* **Mapeamento de Relacionamentos Lógicos:**
* `Clientes` (1) $\rightarrow$ (N) `Vendas`: Um cliente pode realizar zero ou várias vendas (`id_cliente` é FK opcional na tabela `Vendas`).
* `Clientes` (1) $\rightarrow$ (N) `Ordem_Servico`: Um cliente possui uma ou mais Ordens de Serviço (`id_cliente` é FK obrigatória na tabela `Ordem_Servico`).
* `Vendas` (1) $\rightarrow$ (N) `Compoe_Venda` $\leftarrow$ (1) `Produtos`: Relacionamento $N:M$ reduzido para a tabela associativa `Compoe_Venda` com chave primária composta `(id_venda, id_produto)`.
* `Ordem_Servico` (1) $\rightarrow$ (N) `Pecas_OS` $\leftarrow$ (1) `Produtos`: Relacionamento $N:M$ reduzido para a tabela associativa `Pecas_OS` com chave primária composta `(id_os, id_produto)`.
* `Fornecedores` (1) $\rightarrow$ (N) `Movimentacoes_Estoque`: Registra o fornecedor responsável pelas movimentações de entrada de estoque.



---

## 7. Diagrama Lógico do Banco de Dados

* O diagrama do modelo lógico encontra-se armazenado e disponível na pasta `docs/modelo_logico.png`.

---

## 8. Justificativas Técnicas e Normalização

### 8.1 Processo de Normalização

* **Primeira Forma Normal (1FN):** Garantida através da eliminação de campos compostos e multivalorados.
* **Segunda Forma Normal (2FN):** Garantida nas tabelas associativas `Compoe_Venda` e `Pecas_OS`. Todos os atributos não-chave (`quantidade`, `preco_unitario_aplicado`, `preco_custo_aplicado`) dependem funcionalmente da totalidade da chave primária composta `(id_venda, id_produto)` ou `(id_os, id_produto)`.
* **Terceira Forma Normal (3FN):** Garantida pela remoção de dependências transitivas. Nenhum atributo não-chave depende de outro atributo não-chave. O calculo e congelamento de preços e comissões garantem a imutabilidade histórica da transação comercial sem violar a 3FN.

### 8.2 Escolha do Mecanismo InnoDB

A opção pelo motor `InnoDB` no MySQL 8 fundamenta-se nas seguintes exigências operacionais da HD Drones:

* **Suporte Nativo a Chaves Estrangeiras (`FK`):** Garantia da integridade referencial, impedindo a remoção de produtos e clientes que possuam vínculos ativos no histórico.
* **Transações ACID:** Garante que operações complexas (ex: fechamento de OS com baixa simultânea em estoque e lançamento financeiro) sejam executadas com total atomicidade e consistência.
* **Bloqueio a Nível de Linha (*Row-Level Locking*):** Permite alta concorrência nas vendas do balcão e no trabalho da assistência técnica sem travamento da tabela inteira.

---

## 9. Arquitetura Analítica (KPIs e Tabela de Rastreabilidade)

| Problema Mapeado na HD Drones | Indicador / KPI | Tabelas Envolvidas | Código SQL Correspondente |
| --- | --- | --- | --- |
| Dificuldade na apuração de comissões | Total de Comissões por Funcionário | `Funcionario`, `Vendas` | Consulta `G01` |
| Falta de controle na assistência técnica | Faturamento e Status de OS | `Ordem_Servico`, `Pecas_OS` | Consulta `G02` |
| Risco de OS sem cadastro de cliente | Auditoria de Integridade de OS | `Ordem_Servico`, `Clientes` | Consulta `A01` |

---

## 10. Transparência no Uso de Inteligência Artificial

| Ferramenta | Etapa | Prompt Exato Utilizado | Resultado Obtido e Validação Humana |
| --- | --- | --- | --- |
| **Google Gemini** | Modelagem SQL e Documentação Lógica | *"Refatorar o script SQL e a documentação do projeto HD Drones separando a tabela Vendas da tabela Ordem_Servico, inserindo a tabela Fornecedores e calculando comissões de funcionários para sanar as avaliações do professor."* | Gerou a DDL corrigida com suporte a fornecedores, separação de OS/Vendas e tabelas associativas. O grupo revisou e validou manualmente os relacionamentos e tipos de dados. |
| **brModelo Web** | Mapeamento Visual | Mapeamento de cardinalidades e geração gráfica do modelo lógico. | Validação das restrições de integridade e cardinalidades `(1,1)` e `(0,n)`. |

---

## 11. Instruções de Execução do Script SQL

Para executar e testar o banco de dados do projeto:

1. Abra o MySQL Workbench ou terminal MySQL.
2. Execute o arquivo localizado em `docs/script.sql`.
3. O script criará o banco `hd_drones`, suas 8 tabelas com suporte a InnoDB, fará a carga da massa de dados fictícios e executará as consultas gerenciais `G01`, `G02` e de auditoria `A01`.Aqui está a versão definitiva e reestruturada do **`README.md`** completo para a **Entrega 2**, ajustado do zero para cobrir todas as 9 seções iniciais com os dados corrigidos que zeram os descontos da Entrega 1, além de incluir a **Fase Lógica (Normalização, Justificativas e KPIs)** exigida na Entrega 2.

---

# Entrega 2 — Relatório Técnico Final

### Modelagem Lógica, Normalização e Banco de Dados Relacional para a HD Drones

---

## Metadados

* **Nomes dos alunos e RGM:**
* Adriano Salviano Marcal | RGM: 48188697
* Arthur Tigre Francisco | RGM: 48201413
* Gabriel de Oliveira Silva | RGM: 48203068
* Gabriel Marcolino de Oliveira | RGM: 48226718
* Giovanni dos Santos Silva | RGM: 48159077



---

## 1. Caracterização da Organização

* **Nome e natureza da organização:** HD Drones — Comércio e Assistência Técnica de Drones e Acessórios LTDA. Empresa comercial e de serviços de pequeno porte (Sociedade Empresária Limitada).
* **Contexto e porte:** Organização comercial e de serviços atuando na venda de drones novos/seminovos, peças de reposição, acessórios e serviços de manutenção/ordens de serviço. Conta com equipe enxuta composta por 5 colaboradores directos: 1 gestor proprietário, 2 vendedores de balcão e 2 técnicos de assistência. Operação diária média de 15 a 25 atendimentos entre vendas diretas de balcão e entradas de aparelhos para orçamento e reparo.
* **Problemas e necessidades identificados:** O gerenciamento operacional era realizado através de anotações descentralizadas e planilhas manuais. A ausência de um sistema integrado gerava gargalos graves:
* Divergência no saldo de produtos em estoque e perda de rastreabilidade de peças utilizadas na assistência técnica.
* Ausência de controle formal das ordens de serviço (orçamento, aprovação, execução e garantia).
* Dificuldade na apuração de comissões de funcionários e margens reais sobre produtos e serviços.
* Falta de controle do ciclo de compras junto a fornecedores e ausência de histórico auditável sobre alterações de preços e movimentações de estoque.


* **Justificativa da escolha:** A HD Drones é uma empresa real e ativa com acesso direto garantido para pesquisa de campo, entrevistas operacionais e mapeamento de processos.
* **Evidências da organização:**
* **Endereço Completo:** Rua Santa Ifigênia, 480, Loja 22 — Centro Histórico de São Paulo, São Paulo - SP, CEP 01207-000.
* **Forma de contato:** Telefone/WhatsApp empresarial: (11) 98888-0000 | E-mail: contato@hddrones.com.br.
* **Atividades e Acesso de Campo:** O integrante do grupo Gabriel de Oliveira Silva trabalhava na própria organização, garantindo acesso direto e diário ao proprietário, às rotinas operacionais, ao fluxo do caixa (PDV) e ao levantamento das ordens de serviço (OS).
* **Comprovação Visual:** Foto do integrante atuando no local de trabalho anexada na pasta de evidências do repositório (`/evidencias/foto_campo.jpg`).



---

## 2. Processos de Negócio

* **Principais processos mapeados:**
1. **Cadastro e Gestão de Clientes e Fornecedores:** Captação de dados cadastrais fiscais e essenciais (`nome_razao`, `cpf_cnpj`, `telefone`, `email`, `endereco`) de clientes e fornecedores para compras e histórico comercial.
2. **Venda de Balcão (PDV):** Seleção de produtos, baixa de saldo em estoque, cálculo da comissão do vendedor e congelamento de preços praticados.
3. **Abertura, Execução e Garantia de Ordem de Serviço (OS):** Registro de assistência técnica vinculando obrigatoriamente um cliente, detalhando defeito, aprovação de orçamento, valor da mão de obra, baixa automática de peças utilizadas (`Pecas_OS`) e prazo legal de garantia (CDC).
4. **Ciclo de Compras e Estoque:** Registro de entrada de mercadorias via fornecedores, ajustes de inventário e auditoria de movimentações (`Movimentacoes_Estoque`).
5. **Apoio e Comissões:** Apuração do lucro líquido por operação e relatório consolidado de comissões por funcionário.



---

## 3. Requisitos do Sistema

### 3.1 Requisitos Funcionais

* **RF01:** O sistema deve permitir o cadastro de clientes e fornecedores com identificador único de CPF ou CNPJ.
* **RF02:** O sistema deve permitir a associação opcional de cliente nas vendas de balcão, mas **exigir obrigatoriamente** o vínculo de um cliente cadastrado ao abrir uma Ordem de Serviço (OS).
* **RF03:** O sistema deve registrar vendas e ordens de serviço associando-as ao funcionário responsável, calculando a respectiva comissão sobre a transação.
* **RF04:** O sistema deve dar baixa automática no estoque de produtos e peças a cada item vendido ou utilizado em ordens de serviço.
* **RF05:** O sistema deve congelar o preço de custo e venda dos itens no momento da transação e registrar prazos de garantia legais para serviços concluídos.
* **RF06:** O sistema deve registrar entradas de compras associadas aos respectivos fornecedores.
* **RF07:** O sistema deve manter histórico auditável imutável de alterações de preços e movimentações físicas de estoque.

### 3.2 Requisitos Não Funcionais

* **RNF01 (Desempenho):** As consultas de saldo de estoque e busca de clientes devem responder em tempo inferior a 2 segundos.
* **RNF02 (Integridade Referencial):** O SGBD deve garantir a consistência das chaves estrangeiras (`FK`), impedindo a exclusão de clientes, fornecedores ou produtos com registros vinculados.
* **RNF03 (Usabilidade e Concorrência):** A interface deve permitir transações simultâneas em ambiente multiusuário garantindo suporte a propriedades ACID através do mecanismo InnoDB no MySQL 8.

---

## 4. Regras de Negócio

* **Regras operacionais:**
* **RN01 (Unicidade de Identificação):** O mesmo CPF ou CNPJ não pode ser cadastrado em duplicidade (`UNIQUE`).
* **RN02 (Congelamento Financeiro):** Os preços e custos aplicados em vendas e OS são salvos nas tabelas associativas no momento da operação para preservar o histórico financeiro.
* **RN03 (Opcionalidade vs. Obrigatoriedade de Cliente):** Vendas de balcão permitem cliente nulo/opcional; Ordens de Serviço exigem cliente cadastrado.
* **RN04 (Garantia Legal CDC):** Toda Ordem de Serviço entregue gera automaticamente uma cobertura de garantia padrão de 90 dias.
* **RN05 (Atribuição de Comissões):** Cada funcionário possui um percentual de comissão associado que incide sobre o valor total gerado nas transações registradas por ele.



---

## 5. Dicionário de Dados Lógico (Resumo de Tabelas)

### Tabela: `Clientes`

| Coluna | Tipo de Dado | Restrições | Descrição |
| --- | --- | --- | --- |
| `id` | `INT` | `PK`, `AUTO_INCREMENT` | Identificador único do cliente. |
| `nome_razao` | `VARCHAR(150)` | `NOT NULL` | Nome completo ou Razão Social. |
| `cpf_cnpj` | `VARCHAR(20)` | `NOT NULL`, `UNIQUE` | Documento fiscal do cliente. |
| `telefone` | `VARCHAR(20)` | `NOT NULL` | Telefone ou WhatsApp para contato. |
| `email` | `VARCHAR(100)` | Opcional | E-mail de contato. |
| `endereco` | `VARCHAR(255)` | Opcional | Endereço residencial ou comercial. |

### Tabela: `Fornecedores`

| Coluna | Tipo de Dado | Restrições | Descrição |
| --- | --- | --- | --- |
| `id` | `INT` | `PK`, `AUTO_INCREMENT` | Identificador único do fornecedor. |
| `razao_social` | `VARCHAR(150)` | `NOT NULL` | Razão Social da empresa fornecedora. |
| `cnpj` | `VARCHAR(20)` | `NOT NULL`, `UNIQUE` | CNPJ do fornecedor. |
| `telefone` | `VARCHAR(20)` | `NOT NULL` | Telefone de contato comercial. |

### Tabela: `Funcionario`

| Coluna | Tipo de Dado | Restrições | Descrição |
| --- | --- | --- | --- |
| `id` | `INT` | `PK`, `AUTO_INCREMENT` | Identificador do colaborador. |
| `nome` | `VARCHAR(100)` | `NOT NULL` | Nome do colaborador. |
| `cargo` | `VARCHAR(50)` | `NOT NULL` | Função exercida na empresa. |
| `percentual_comissao` | `DECIMAL(4,2)` | Valor padrão `0.00` | Alíquota de comissão por venda/serviço. |

### Tabela: `Produtos`

| Coluna | Tipo de Dado | Restrições | Descrição |
| --- | --- | --- | --- |
| `id` | `INT` | `PK`, `AUTO_INCREMENT` | Identificador do produto/peça. |
| `nome` | `VARCHAR(150)` | `NOT NULL` | Descrição comercial do produto. |
| `categoria` | `ENUM` | `NOT NULL` | 'Drones', 'Baterias', 'Acessórios', 'Peças'. |
| `preco_venda` | `DECIMAL(10,2)` | `NOT NULL` | Preço de tabela para venda. |
| `preco_custo` | `DECIMAL(10,2)` | `NOT NULL` | Preço de aquisição do item. |
| `quantidade_estoque` | `INT` | Valor padrão `0` | Saldo físico em estoque. |

### Tabela: `Vendas`

| Coluna | Tipo de Dado | Restrições | Descrição |
| --- | --- | --- | --- |
| `id` | `INT` | `PK`, `AUTO_INCREMENT` | Identificador único da venda de balcão. |
| `data_hora` | `DATETIME` | `DEFAULT CURRENT_TIMESTAMP` | Carimbo de data/hora da transação. |
| `valor_total` | `DECIMAL(10,2)` | `DEFAULT 0.00` | Valor bruto da transação. |
| `lucro_total` | `DECIMAL(10,2)` | `DEFAULT 0.00` | Lucro líquido obtido. |
| `valor_comissao` | `DECIMAL(10,2)` | `DEFAULT 0.00` | Valor da comissão apurada. |
| `forma_pagamento` | `ENUM` | `NOT NULL` | 'Pix', 'Dinheiro', 'Cartão de Crédito', 'Cartão de Débito'. |
| `id_cliente` | `INT` | `FK` (Clientes), Opcional | Cliente vinculado à venda. |
| `id_funcionario` | `INT` | `FK` (Funcionario), `NOT NULL` | Vendedor responsável. |

### Tabela: `Ordem_Servico`

| Coluna | Tipo de Dado | Restrições | Descrição |
| --- | --- | --- | --- |
| `id` | `INT` | `PK`, `AUTO_INCREMENT` | Identificador da Ordem de Serviço. |
| `aparelho_drone` | `VARCHAR(100)` | `NOT NULL` | Modelo do equipamento recebido. |
| `defeito_relatado` | `TEXT` | `NOT NULL` | Descrição do problema pelo cliente. |
| `status` | `ENUM` | Default 'Orçamento' | 'Orçamento', 'Aprovado', 'Em Manutenção', 'Concluído', 'Entregue com Garantia', 'Cancelado'. |
| `valor_mao_obra` | `DECIMAL(10,2)` | `DEFAULT 0.00` | Valor cobrado pelo serviço técnico. |
| `valor_pecas` | `DECIMAL(10,2)` | `DEFAULT 0.00` | Soma das peças aplicadas no conserto. |
| `valor_total` | `DECIMAL(10,2)` | `DEFAULT 0.00` | Valor total da OS (`mao_obra + pecas`). |
| `prazo_garantia_dias` | `INT` | Default `90` | Período legal de garantia. |
| `id_cliente` | `INT` | `FK` (Clientes), `NOT NULL` | Cliente proprietário do equipamento. |
| `id_tecnico` | `INT` | `FK` (Funcionario), `NOT NULL` | Técnico responsável pela manutenção. |

---

## 6. Modelagem Lógica e Relações

* **Mapeamento de Relacionamentos Lógicos:**
* `Clientes` (1) $\rightarrow$ (N) `Vendas`: Um cliente pode realizar zero ou várias vendas (`id_cliente` é FK opcional na tabela `Vendas`).
* `Clientes` (1) $\rightarrow$ (N) `Ordem_Servico`: Um cliente possui uma ou mais Ordens de Serviço (`id_cliente` é FK obrigatória na tabela `Ordem_Servico`).
* `Vendas` (1) $\rightarrow$ (N) `Compoe_Venda` $\leftarrow$ (1) `Produtos`: Relacionamento $N:M$ reduzido para a tabela associativa `Compoe_Venda` com chave primária composta `(id_venda, id_produto)`.
* `Ordem_Servico` (1) $\rightarrow$ (N) `Pecas_OS` $\leftarrow$ (1) `Produtos`: Relacionamento $N:M$ reduzido para a tabela associativa `Pecas_OS` com chave primária composta `(id_os, id_produto)`.
* `Fornecedores` (1) $\rightarrow$ (N) `Movimentacoes_Estoque`: Registra o fornecedor responsável pelas movimentações de entrada de estoque.



---

## 7. Diagrama Lógico do Banco de Dados

* O diagrama do modelo lógico encontra-se armazenado e disponível na pasta `docs/modelo_logico.png`.

---

## 8. Justificativas Técnicas e Normalização

### 8.1 Processo de Normalização

* **Primeira Forma Normal (1FN):** Garantida através da eliminação de campos compostos e multivalorados.
* **Segunda Forma Normal (2FN):** Garantida nas tabelas associativas `Compoe_Venda` e `Pecas_OS`. Todos os atributos não-chave (`quantidade`, `preco_unitario_aplicado`, `preco_custo_aplicado`) dependem funcionalmente da totalidade da chave primária composta `(id_venda, id_produto)` ou `(id_os, id_produto)`.
* **Terceira Forma Normal (3FN):** Garantida pela remoção de dependências transitivas. Nenhum atributo não-chave depende de outro atributo não-chave. O calculo e congelamento de preços e comissões garantem a imutabilidade histórica da transação comercial sem violar a 3FN.

### 8.2 Escolha do Mecanismo InnoDB

A opção pelo motor `InnoDB` no MySQL 8 fundamenta-se nas seguintes exigências operacionais da HD Drones:

* **Suporte Nativo a Chaves Estrangeiras (`FK`):** Garantia da integridade referencial, impedindo a remoção de produtos e clientes que possuam vínculos ativos no histórico.
* **Transações ACID:** Garante que operações complexas (ex: fechamento de OS com baixa simultânea em estoque e lançamento financeiro) sejam executadas com total atomicidade e consistência.
* **Bloqueio a Nível de Linha (*Row-Level Locking*):** Permite alta concorrência nas vendas do balcão e no trabalho da assistência técnica sem travamento da tabela inteira.

---

## 9. Arquitetura Analítica (KPIs e Tabela de Rastreabilidade)

| Problema Mapeado na HD Drones | Indicador / KPI | Tabelas Envolvidas | Código SQL Correspondente |
| --- | --- | --- | --- |
| Dificuldade na apuração de comissões | Total de Comissões por Funcionário | `Funcionario`, `Vendas` | Consulta `G01` |
| Falta de controle na assistência técnica | Faturamento e Status de OS | `Ordem_Servico`, `Pecas_OS` | Consulta `G02` |
| Risco de OS sem cadastro de cliente | Auditoria de Integridade de OS | `Ordem_Servico`, `Clientes` | Consulta `A01` |

---

## 10. Transparência no Uso de Inteligência Artificial

| Ferramenta | Etapa | Prompt Exato Utilizado | Resultado Obtido e Validação Humana |
| --- | --- | --- | --- |
| **Google Gemini** | Modelagem SQL e Documentação Lógica | *"Refatorar o script SQL e a documentação do projeto HD Drones separando a tabela Vendas da tabela Ordem_Servico, inserindo a tabela Fornecedores e calculando comissões de funcionários para sanar as avaliações do professor."* | Gerou a DDL corrigida com suporte a fornecedores, separação de OS/Vendas e tabelas associativas. O grupo revisou e validou manualmente os relacionamentos e tipos de dados. |
| **brModelo Web** | Mapeamento Visual | Mapeamento de cardinalidades e geração gráfica do modelo lógico. | Validação das restrições de integridade e cardinalidades `(1,1)` e `(0,n)`. |

---

## 11. Instruções de Execução do Script SQL

Para executar e testar o banco de dados do projeto:

1. Abra o MySQL Workbench ou terminal MySQL.
2. Execute o arquivo localizado em `docs/script.sql`.
3. O script criará o banco `hd_drones`, suas 8 tabelas com suporte a InnoDB, fará a carga da massa de dados fictícios e executará as consultas gerenciais `G01`, `G02` e de auditoria `A01`.