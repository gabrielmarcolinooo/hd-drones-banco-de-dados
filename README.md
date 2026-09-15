# Entrega 1 — Modelo Conceitual (DER)
### Modelagem de um sistema de gestão de informações para uma organização de pequeno porte

---

## Metadados

- **Nomes dos alunos e RGM:**
  - Adriano Salviano Marcal | RGM: 48188697
  - Arthur Tigre | RGM: 48201413
  - Gabriel de Oliveira Silva | RGM: 48203068
  - Gabriel Marcolino de Oliveira | RGM: 48226718
  - Giovanni dos Santos Silva | RGM: 48159077
---

## 1. Caracterização da Organização

- **Nome e natureza da organização:** HD Drones — Assistência Técnica e Comércio de Drones e Acessórios. Empresa comercial e de serviços de pequeno porte (Sociedade Unipessoal / MEI).
- **Contexto e porte:** Organização com fins lucrativos atuando no mercado de tecnologia, especializada em venda de drones novos/seminovos, peças de reposição, acessórios e serviços de manutenção/ordens de serviço. Conta com equipe enxuta composta por 1 gestor/proprietário, vendedores de balcão e técnicos de assistência. Operação diária média de 10 a 25 atendimentos entre vendas diretas e entradas de aparelhos para reparo.
- **Problemas e necessidades identificados:** O gerenciamento operacional era realizado através de anotações descentralizadas e planilhas manuais. A ausência de um sistema integrado gerava gargalos graves:
  - Divergência no saldo de produtos em estoque e perda de rastreabilidade de peças utilizadas na assistência técnica.
  - Dificuldade na apuração de comissões e margens reais sobre produtos e serviços de manutenção.
  - Bloqueios operacionais e falhas no registro unificado do histórico de compras dos clientes.
  - Ausência de histórico auditável sobre alterações de preços de custo/venda e movimentações físicas de produtos.
- **Justificativa da escolha:** A HD Drones é uma empresa real e ativa com acesso direto garantido para pesquisa de campo, entrevistas operacionais e mapeamento de processos. Possui o porte ideal para a disciplina: não é trivial a ponto de ter poucas entidades, nem excessivamente complexa a ponto de inviabilizar a modelagem conceitual dentro do prazo do semestre.
- **Evidências da organização:** 
  - **Endereço Completo:** Cidade Líder, Zona Leste, São Paulo - SP.
  - **Forma de contato:** Telefone/WhatsApp empresarial, e-mail de atendimento comercial e presença em marketplaces.
  - **Atividades de campo:** Visita presencial para mapeamento do fluxo do caixa (PDV) e entrevista com o responsável para levantamento do fluxo de peças e ordem de serviço.

---

## 2. Processos de Negócio

- **Principais processos mapeados:**
  1. **Cadastro e Gestão de Clientes:** Captação de dados cadastrais essenciais (`nome_razao`, `cpf_cnpj`, `telefone`, `email`, `endereco`) para registro histórico e emissão de comprovantes.
  2. **Venda de Balcão (PDV) e Atendimento:** Seleção de produtos em estoque, baixa instantânea de saldo e registro do comprovante e forma de pagamento (`forma_pagamento`).
  3. **Abertura e Execução de Ordem de Serviço (OS):** Registro de manutenção técnica detalhando mão de obra e peças de reposição com baixa automática do estoque.
  4. **Gestão de Estoque e Auditoria:** Registro de entradas/saídas de produtos (compras, ajustes, perdas em `movimentacoes_estoque`) e historização automatizada de alterações de preços de custo e tabela (`historico_precos`).
  5. **Fechamento Financeiro e Margens:** Apuração do lucro total da transação (`lucro_total`) a partir do congelamento dos custos praticados no momento da venda.

---

## 3. Requisitos do Sistema

### 3.1 Requisitos Funcionais
- **RF01:** O sistema deve permitir o cadastro e consulta de clientes com identificador único de CPF ou CNPJ.
- **RF02:** O sistema deve permitir a associação opcional de um cliente a uma venda de balcão ou ordem de serviço.
- **RF03:** O sistema deve registrar vendas de produtos associando-as obrigatoriamente a um usuário operador (vendedor/técnico).
- **RF04:** O sistema deve dar baixa automática no estoque de produtos e peças a cada item vendido ou utilizado em manutenção.
- **RF05:** O sistema deve congelar o preço de custo e o preço unitário praticados no momento da transação na tabela de itens de venda.
- **RF06:** O sistema deve calcular automaticamente o lucro total obtido na venda com base na diferença dos valores aplicados e custos congelados.
- **RF07:** O sistema deve registrar a historização de alterações de preços (custo e venda antigo vs. novo), registrando o usuário autor e a data/hora.
- **RF08:** O sistema deve registrar todas as movimentações físicas de estoque (tipo, quantidade, usuário responsável e observação).

### 3.2 Requisitos Não Funcionais
- **RNF01 (Desempenho):** As consultas de saldo de estoque e busca de clientes devem ter tempo de resposta inferior a 2 segundos.
- **RNF02 (Integridade Referencial):** O banco de dados deve garantir a consistência das chaves estrangeiras (`FK`), impedindo a exclusão de clientes ou produtos vinculados a vendas ativas.
- **RNF03 (Usabilidade):** A interface de frente de caixa deve ser intuitiva, reduzindo etapas para finalização de vendas rápidas.
- **RNF04 (Portabilidade e Concorrência):** O sistema deve utilizar SGBD relacional robusto (MySQL 8 com mecanismo InnoDB) garantindo suporte a transações ACID.

---

## 4. Regras de Negócio

- **Regras operacionais:**
  - **RN01 (Unicidade de Identificação):** O mesmo CPF ou CNPJ não pode ser cadastrado mais de uma vez no banco de dados (`UNIQUE`).
  - **RN02 (Congelamento do Histórico Financeiro):** Toda venda gera registros em `itens_venda` congelando `preco_unitario_aplicado` e `preco_custo_aplicado` para impedir que futuras alterações na tabela de produtos modifiquem relatórios de lucros passados.
  - **RN03 (Opcionalidade de Cliente no Balcão):** Vendas diretas avulsas podem ser registradas sem vínculo com a tabela `clientes` (`cliente_id` nulo/opcional).
  - **RN04 (Baixa de Peças em Assistência):** O uso de peças em ordens de serviço valida o saldo em `produtos` e efetua a baixa automática de estoque.

- **Restrições organizacionais:**
  - **RN05 (Auditoria de Preços e Estoque):** É vedada a alteração sem rastro nos preços e saldos; alterações de preços geram registros imutáveis em `historico_precos` e ajustes físicos geram lançamentos em `movimentacoes_estoque`.
  - **RN06 (Atribuição de Responsabilidade):** Todas as transações, alterações de preço e movimentações de estoque exigem o vínculo obrigatório com o `usuario_id` do colaborador responsável.

---

## 5. Dicionário de Dados Conceitual (Preliminar)

### Entidade: `clientes`
| Atributo | Descrição | Regra de negócio associada |
|----------|-----------|------------------------------|
| `id` | Identificador único do cliente no sistema | Chave Primária (`PK`), autoincremento. |
| `nome_razao` | Nome completo ou Razão Social | Preenchimento obrigatório. Exemplo fictício: *João da Silva*. |
| `cpf_cnpj` | Documento de identificação fiscal | Preenchimento obrigatório e único (`UNIQUE`). Exemplo fictício: *000.000.000-00*. |
| `telefone` | Telefone ou WhatsApp para contato | Opcional. Exemplo fictício: *(11) 99999-0000*. |
| `email` | Correio eletrônico do cliente | Opcional. Exemplo fictício: *cliente@exemplo.com*. |
| `endereco` | Endereço comercial ou residencial completo | Opcional. Exemplo fictício: *Rua das Flores, 123 - São Paulo/SP*. |

### Entidade: `usuarios`
| Atributo | Descrição | Regra de negócio associada |
|----------|-----------|------------------------------|
| `id` | Identificador único do usuário/funcionário | Chave Primária (`PK`), autoincremento. |
| `nome` | Nome do colaborador | Preenchimento obrigatório. Exemplo fictício: *Carlos Vendedor*. |
| `cargo` | Função exercida na empresa | Preenchimento obrigatório. Exemplo fictício: *Vendedor*. |

### Entidade: `produtos`
| Atributo | Descrição | Regra de negócio associada |
|----------|-----------|------------------------------|
| `id` | Identificador único do produto/peça | Chave Primária (`PK`), autoincremento. |
| `nome` | Descrição comercial do item | Preenchimento obrigatório. Exemplo fictício: *Drone DJI Mini 3 Pro*. |
| `categoria` | Classificação do item | Ex.: 'Drones', 'Baterias', 'Acessórios', 'Peças'. Exemplo fictício: *Drones*. |
| `preco_venda` | Valor de tabela para venda | Numérico float. Preenchimento obrigatório. Exemplo fictício: *5000.00*. |
| `preco_custo` | Valor de aquisição do item | Numérico float. Preenchimento obrigatório. Exemplo fictício: *3500.00*. |
| `quantidade_estoque` | Saldo físico atual em loja | Numérico inteiro. Atualizado por vendas e movimentações. Exemplo fictício: *5*. |

### Entidade: `vendas`
| Atributo | Descrição | Regra de negócio associada |
|----------|-----------|------------------------------|
| `id` | Identificador único da transação/OS | Chave Primária (`PK`), autoincremento. |
| `data_hora` | Carimbo de data e hora da operação | Preenchimento automático (`CURRENT_TIMESTAMP`). Exemplo fictício: *2026-09-14 18:00:00*. |
| `valor_total` | Soma total cobrada do cliente | Numérico float. Exemplo fictício: *5000.00*. |
| `lucro_total` | Lucro líquido obtido na operação | Numérico float (`valor_total - custos`). Exemplo fictício: *1500.00*. |
| `forma_pagamento` | Meio de pagamento utilizado | Valores: 'Pix', 'Dinheiro', 'Cartão de Crédito', 'Cartão de Débito'. Exemplo fictício: *Pix*. |
| `cliente_id` | Chave estrangeira do cliente | Chave Estrangeira (`FK` -> `clientes.id`). Opcional no balcão. |
| `usuario_id` | Chave estrangeira do vendedor/técnico | Chave Estrangeira (`FK` -> `usuarios.id`). Preenchimento obrigatório. |

### Entidade: `itens_venda`
| Atributo | Descrição | Regra de negócio associada |
|----------|-----------|------------------------------|
| `id` | Identificador do item na venda | Chave Primária (`PK`), autoincremento. |
| `quantidade` | Quantidade de unidades | Inteiro maior que zero. Exemplo fictício: *1*. |
| `preco_unitario_aplicado` | Preço praticado na unidade | Numérico float congelado na venda. Exemplo fictício: *5000.00*. |
| `preco_custo_aplicado` | Custo do produto no momento da venda | Numérico float congelado na venda. Exemplo fictício: *3500.00*. |
| `venda_id` | Registro da venda correspondente | Chave Estrangeira (`FK` -> `vendas.id`). |
| `produto_id` | Produto/peça comercializado | Chave Estrangeira (`FK` -> `produtos.id`). |

### Entidade: `historico_precos`
| Atributo | Descrição | Regra de negócio associada |
|----------|-----------|------------------------------|
| `id` | Identificador do histórico | Chave Primária (`PK`), autoincremento. |
| `produto_id` | Produto afetado pela alteração | Chave Estrangeira (`FK` -> `produtos.id`). |
| `usuario_id` | Usuário que alterou o preço | Chave Estrangeira (`FK` -> `usuarios.id`). |
| `preco_custo_antigo` | Custo anterior à mudança | Numérico float. Exemplo fictício: *3200.00*. |
| `preco_custo_novo` | Custo atualizado | Numérico float. Exemplo fictício: *3500.00*. |
| `preco_venda_antigo` | Preço de venda anterior | Numérico float. Exemplo fictício: *4800.00*. |
| `preco_venda_novo` | Preço de venda atualizado | Numérico float. Exemplo fictício: *5000.00*. |
| `data_alteracao` | Data/hora exata da mudança | Preenchimento automático (`CURRENT_TIMESTAMP`). Exemplo fictício: *2026-09-10 10:30:00*. |

### Entidade: `movimentacoes_estoque`
| Atributo | Descrição | Regra de negócio associada |
|----------|-----------|------------------------------|
| `id` | Identificador da movimentação | Chave Primária (`PK`), autoincremento. |
| `produto_id_mov` | Produto movimentado | Chave Estrangeira (`FK` -> `produtos.id`). |
| `usuario_id_mov` | Usuário autor da movimentação | Chave Estrangeira (`FK` -> `usuarios.id`). |
| `tipo_movimentacao` | Natureza do movimento | Valores: 'Entrada', 'Saída Manual', 'Ajuste Inventário', 'Perda'. Exemplo fictício: *Entrada*. |
| `quantidade_mov` | Volume movimentado | Numérico inteiro positivo. Exemplo fictício: *10*. |
| `data_movimentacao` | Data/hora do lançamento | Preenchimento automático (`CURRENT_TIMESTAMP`). Exemplo fictício: *2026-09-12 14:15:00*. |
| `observacao` | Justificativa do lançamento | Opcional. Exemplo fictício: *Compra NF 4580 do fornecedor*. |

---

## 6. Modelagem Conceitual (Entidades, Atributos, Relacionamentos)

- **Entidades reconhecidas:**
  - `Clientes`: Representa as pessoas físicas ou jurídicas tomadoras de serviço ou compradoras.
  - `Usuarios`: Representa os colaboradores do sistema (vendedores, técnicos, administradores).
  - `Produtos`: Representa os bens físicos comercializados (drones, baterias, acessórios) e peças de reposição.
  - `Vendas`: Representa a transação comercial ou ordem de serviço fechada.
  - `Itens_Venda`: Entidade associativa que conecta os produtos específicos a uma determinada venda.
  - `Historico_Precos`: Entidade de rastreabilidade para alterações financeiras dos produtos.
  - `Movimentacoes_Estoque`: Entidade de auditoria para fluxo de entrada e saída de mercadorias.

- **Atributos e classificações:**
  - Atributos Identificadores (PK): `id` em todas as tabelas.
  - Atributos Relacionais (FK): `cliente_id`, `usuario_id`, `produto_id`, `venda_id`, `produto_id_mov`, `usuario_id_mov`.
  - Atributos Descritivos: `nome_razao`, `nome`, `categoria`, `forma_pagamento`, `tipo_movimentacao`, `observacao`.
  - Atributos Monotônicos/Monetários: `preco_custo`, `preco_venda`, `valor_total`, `lucro_total`, `preco_unitario_aplicado`, `preco_custo_aplicado`.

- **Relacionamentos pertinentes:**
  - `Clientes` **Realiza** `Vendas`: Um cliente pode realizar zero ou várias vendas `(0,N)`. Uma venda pertence a zero ou um cliente `(0,1)`.
  - `Usuarios` **Registra** `Vendas`: Um usuário pode registrar zero ou varias vendas `(0,N)`. Uma venda é registrada por exatamente um usuário `(1,1)`.
  - `Vendas` **Contém** `Itens_Venda`: Uma venda contém um ou vários itens `(1,N)`. Um item de venda pertence a exatamente uma venda `(1,1)`.
  - `Produtos` **Pertence A** `Itens_Venda`: Um produto pode constar em zero ou vários itens de venda `(0,N)`. Um item de venda refere-se a exatamente um produto `(1,1)`.
  - `Produtos` **Possui** `Historico_Precos`: Um produto pode ter zero ou vários históricos de alteração `(0,N)`. Um histórico refere-se a exatamente um produto `(1,1)`.
  - `Produtos` **Gera** `Movimentacoes_Estoque`: Um produto pode ter zero ou várias movimentações `(0,N)`. Uma movimentação pertence a exatamente um produto `(1,1)`.
  - `Usuarios` **Autoriza** `Historico_Precos` e `Movimentacoes_Estoque`: Um usuário pode autorizar zero ou vários registros de auditoria `(0,N)`.

---

## 7. Diagrama Entidade-Relacionamento (DER)

- O arquivo visual do DER gerado via ferramenta Eraser.io encontra-se anexo no repositório no arquivo `der_hd_drones.png`.

```text
+------------------+             +-------------------+             +-----------------------+
|     Clientes     |             |      Vendas       |             |      Itens_Venda      |
+------------------+             +-------------------+             +-----------------------+
| id (PK)          |1           *| id (PK)           |1           *| id (PK)               |
| nome_razao       |-------------| data_hora         |-------------| quantidade            |
| cpf_cnpj         |             | valor_total       |             | preco_unit_aplicado   |
| telefone         |             | lucro_total       |             | preco_custo_aplicado  |
| email            |             | forma_pagamento   |             | venda_id (FK)         |
| endereco         |             | cliente_id (FK)   |             | produto_id (FK)       |
+------------------+             | usuario_id (FK)   |             +-----------------------+
                                 +-------------------+                         *
                                           *                                   |
                                           |                                   |
                                           |                                   |
+------------------+                       |                                   |
|     Usuarios     |                       |                                   |
+------------------+                       |                                   |
| id (PK)          |1                      |                                   |
| nome             |-----------------------+                                   |
| cargo            |1                                                          |
+------------------+-----------------------+                                   |
         1         \                       \                                   |
         |          \                       \                                  |
         |           +-----------------------+------------------+              |
         |           |                       |                  |              |
         |           |                       v                  v              |
         |           |           +----------------------------------+          |
         |           |           |             Produtos             |          |
         |           |           +----------------------------------+          |
         |           |           | id (PK)                          |1         |
         |           |           | nome                             |----------+
         |           |           | categoria                        |
         |           |           | preco_venda                      |
         |           |           | preco_custo                      |
         |           |           | quantidade_estoque               |
         |           |           +----------------------------------+
         |           |                            1
         |           |                            |
         v           v                            v
+----------------------------------+    +----------------------------------+
|      Movimentacoes_Estoque       |    |         Historico_Precos         |
+----------------------------------+    +----------------------------------+
| id (PK)                          |    | id (PK)                          |
| produto_id_mov (FK)              |    | produto_id (FK)                  |
| usuario_id_mov (FK)              |    | usuario_id (FK)                  |
| tipo_movimentacao                |    | preco_custo_antigo               |
| quantidade_mov                   |    | preco_custo_novo                 |
| data_movimentacao                |    | preco_venda_antigo               |
| observacao                       |    | preco_venda_novo                 |
+----------------------------------+    | data_alteracao                   |
                                        +----------------------------------+

```

## 8. Justificativa Técnica

A estrutura proposta abstrai com precisão as complexidades da operação comercial e técnica da HD Drones. As escolhas de modelagem fundamentam-se nos seguintes pontos:

- **Separação entre Vendas e Itens_Venda (Atributos Congelados):** A criação da entidade associativa `itens_venda` permite que uma única venda contenha múltiplos produtos. Adicionalmente, salvar `preco_unitario_aplicado` e `preco_custo_aplicado` nesta tabela garante a integridade histórica da transação: mesmo que o preço do produto mude no futuro em `produtos`, o registro financeiro do passado não será adulterado.
- **Criação de Tabelas Dedicadas de Historização (Historico_Precos e Movimentacoes_Estoque):** Em vez de utilizar simples atributos atualizáveis em `produtos`, optou-se pela criação de entidades filhas `1:N`. Isso viabiliza auditorias completas de estoque e margens de lucro, permitindo identificar quando um custo subiu, quem aprovou a alteração e qual colaborador efetuou ajustes de inventário.
- **Cardinalidades 1:N estritas com FKs explícitas:** Todas as conexões utilizam relacionamentos `1:N`. Um cliente ou produto relaciona-se com *N* registros históricos ou vendas, mantendo a integridade referencial e permitindo escalabilidade para relatórios sem gerar duplicação de dados.
- **Tratamento de Opcionalidade de Cliente:** O relacionamento `clientes` -> `vendas` é `(0,1)` para `(0,N)`, refletindo com fidelidade a regra do negócio real: vendas rápidas de balcão não exigem cadastro obrigatório do cliente.

---

## 9. Uso de Inteligência Artificial

| Item | O que registrar |
|------|------------------|
| **Ferramenta e etapa** | Google Gemini (Modelo de Linguagem) e Eraser.io (DiagramGPT) utilizados na etapa de estruturação do Dicionário de Dados HTML, refinamento do prompt do DER e redação do README.md. |
| **Motivação** | Agilizar a conversão dos requisitos de campo observados na empresa para a sintaxe padrão de modelagem relacional e validar a consistência das cardinalidades no diagrama visual. |
| **Prompt(s) utilizados** | *"Create a database schema for a commercial management system (HD Drones) with 7 tables: clientes, usuarios, produtos, historico_precos, movimentacoes_estoque, vendas, itens_venda. Define all Foreign Key relationships and 1:N cardinalities."* |
| **Resposta recebida** | Estruturação em código DSL do Eraser.io e gerações de tabelas de dicionário com definições de tipos de dados (`int`, `float`, `string`, `datetime`). |
| **Fontes consultadas e verificadas** | Comparação direta do esquema gerado com o banco de dados relacional `hd_drones.db` pré-existente e validação do fluxo operacional presenciado na empresa. |
| **Trechos rejeitados ou corrigidos** | A IA sugeriu originalmente relacionamentos `1:1` para a tabela de histórico de preços; o trecho foi rejeitado e corrigido manualmente para `1:N`, visto que um produto possui múltiplos históricos ao longo do tempo. |
| **Justificativa da escolha final** | O modelo final manteve 100% da fidelidade às regras de negócio apuradas na pesquisa de campo, utilizando a IA apenas para aceleração de formatação Markdown e renderização gráfica. |
| **Reflexão crítica** | A IA tende a generalizar cardinalidades e sugerir modelos genéricos de e-commerce que ignoram regras específicas de negócios locais. A intervenção humana e o conhecimento do domínio foram indispensáveis para garantir a precisão técnica. |

