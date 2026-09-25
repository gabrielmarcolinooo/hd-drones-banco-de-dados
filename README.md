# Entrega 1 — Modelo Conceitual (DER)
### Modelagem de um sistema de gestão de informações para a HD Drones 

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
  4. **Gestão de Estoque e Auditoria:** Registro de entradas/saídas de produtos (compras, ajustes, perdas em `Movimentacoes_Estoque`) e historização automatizada de alterações de preços de custo e tabela (`Historico_Precos`).
  5. **Fechamento Financeiro e Margens:** Apuração do lucro total da transação (`lucro_total`) a partir do congelamento dos custos praticados no momento da venda.

---

## 3. Requisitos do Sistema

### 3.1 Requisitos Funcionais
- **RF01:** O sistema deve permitir o cadastro e consulta de clientes com identificador único de CPF ou CNPJ.
- **RF02:** O sistema deve permitir a associação opcional de um cliente a uma venda de balcão ou ordem de serviço.
- **RF03:** O sistema deve registrar vendas de produtos associando-as obrigatoriamente a um funcionário operador (vendedor/técnico).
- **RF04:** O sistema deve dar baixa automática no estoque de produtos e peças a cada item vendido ou utilizado em manutenção.
- **RF05:** O sistema deve congelar o preço de custo e o preço unitário praticados no momento da transação através de atributos associativos no relacionamento de itens compostos da venda.
- **RF06:** O sistema deve calcular automaticamente o lucro total obtido na venda com base na diferença dos valores aplicados e custos congelados.
- **RF07:** O sistema deve registrar a historização de alterações de preços (custo e venda antigo vs. novo), registrando o funcionário autor e a data/hora.
- **RF08:** O sistema deve registrar todas as movimentações físicas de estoque (tipo, quantidade, funcionário responsável e observação).

### 3.2 Requisitos Não Funcionais
- **RNF01 (Desempenho):** As consultas de saldo de estoque e busca de clientes devem ter tempo de resposta inferior a 2 segundos.
- **RNF02 (Integridade Referencial):** O banco de dados deve garantir a consistência das chaves estrangeiras (`FK`), impedindo a exclusão de clientes ou produtos vinculados a vendas ativas.
- **RNF03 (Usabilidade):** A interface de frente de caixa deve ser intuitiva, reduzindo etapas para finalização de vendas rápidas.
- **RNF04 (Portabilidade e Concorrência):** O sistema deve utilizar SGBD relacional robusto (MySQL 8 com mecanismo InnoDB) garantindo suporte a transações ACID.

---

## 4. Regras de Negócio

- **Regras operacionais:**
  - **RN01 (Unicidade de Identificação):** O mesmo CPF ou CNPJ não pode ser cadastrado mais de uma vez no banco de dados (`UNIQUE`).
  - **RN02 (Congelamento do Histórico Financeiro):** Toda venda associa produtos através de `<Compoe>`, congelando `preco_unitario_aplicado` e `preco_custo_aplicado` no relacionamento para impedir que futuras alterações na tabela de produtos modifiquem relatórios de lucros passados.
  - **RN03 (Opcionalidade de Cliente no Balcão):** Vendas diretas avulsas podem ser registradas sem vínculo com a tabela `Clientes`.
  - **RN04 (Baixa de Peças em Assistência):** O uso de peças em ordens de serviço valida o saldo em `Produtos` e efetua a baixa automática de estoque.

- **Restrições organizacionais:**
  - **RN05 (Auditoria de Preços e Estoque):** É vedada a alteração sem rastro nos preços e saldos; alterações de preços geram registros imutáveis em `Historico_Precos` e ajustes físicos geram lançamentos em `Movimentacoes_Estoque`.
  - **RN06 (Atribuição de Responsabilidade):** Todas as transações, alterações de preço e movimentações de estoque exigem o vínculo obrigatório com o `Funcionario` responsável.

---

## 5. Dicionário de Dados Conceitual (Preliminar)

### Entidade: `Clientes`
| Atributo | Descrição | Regra de negócio associada |
|----------|-----------|------------------------------|
| `id` | Identificador único do cliente no sistema | Chave Primária (`PK`), autoincremento. |
| `nome_razao` | Nome completo ou Razão Social | Preenchimento obrigatório. Exemplo fictício: *João da Silva*. |
| `cpf_cnpj` | Documento de identificação fiscal | Preenchimento obrigatório e único (`UNIQUE`). Exemplo fictício: *000.000.000-00*. |
| `telefone` | Telefone ou WhatsApp para contato | Opcional. Exemplo fictício: *(11) 99999-0000*. |
| `email` | Correio eletrônico do cliente | Opcional. Exemplo fictício: *cliente@exemplo.com*. |
| `endereco` | Endereço comercial ou residencial completo | Opcional. Exemplo fictício: *Rua das Flores, 123 - São Paulo/SP*. |

### Entidade: `Funcionario`
| Atributo | Descrição | Regra de negócio associada |
|----------|-----------|------------------------------|
| `id` | Identificador único do funcionário | Chave Primária (`PK`), autoincremento. |
| `nome` | Nome do colaborador | Preenchimento obrigatório. Exemplo fictício: *Carlos Vendedor*. |
| `cargo` | Função exercida na empresa | Preenchimento obrigatório. Exemplo fictício: *Vendedor*. |

### Entidade: `Produtos`
| Atributo | Descrição | Regra de negócio associada |
|----------|-----------|------------------------------|
| `id` | Identificador único do produto/peça | Chave Primária (`PK`), autoincremento. |
| `nome` | Descrição comercial do item | Preenchimento obrigatório. Exemplo fictício: *Drone DJI Mini 3 Pro*. |
| `categoria` | Classificação do item | Ex.: 'Drones', 'Baterias', 'Acessórios', 'Peças'. Exemplo fictício: *Drones*. |
| `preco_venda` | Valor de tabela para venda | Numérico float/decimal. Preenchimento obrigatório. Exemplo fictício: *5000.00*. |
| `preco_custo` | Valor de aquisição do item | Numérico float/decimal. Preenchimento obrigatório. Exemplo fictício: *3500.00*. |
| `quantidade_estoque` | Saldo físico atual em loja | Numérico inteiro. Atualizado por vendas e movimentações. Exemplo fictício: *5*. |

### Entidade: `Vendas`
| Atributo | Descrição | Regra de negócio associada |
|----------|-----------|------------------------------|
| `id` | Identificador único da transação/OS | Chave Primária (`PK`), autoincremento. |
| `data_hora` | Carimbo de data e hora da operação | Preenchimento automático (`CURRENT_TIMESTAMP`). Exemplo fictício: *2026-09-14 18:00:00*. |
| `valor_total` | Soma total cobrada do cliente | Numérico float/decimal. Exemplo fictício: *5000.00*. |
| `lucro_total` | Lucro líquido obtido na operação | Numérico float/decimal (`valor_total - custos`). Exemplo fictício: *1500.00*. |
| `forma_pagamento` | Meio de pagamento utilizado | Valores: 'Pix', 'Dinheiro', 'Cartão de Crédito', 'Cartão de Débito'. Exemplo fictício: *Pix*. |

### Relacionamento Associativo: `<Compoe>` (Entre `Vendas` e `Produtos`)
| Atributo | Descrição | Regra de negócio associada |
|----------|-----------|------------------------------|
| `quantidade` | Quantidade de unidades vendidas do item | Inteiro maior que zero. Exemplo fictício: *1*. |
| `preco_unitario_aplicado` | Preço praticado na unidade | Numérico float/decimal congelado na venda. Exemplo fictício: *5000.00*. |
| `preco_custo_aplicado` | Custo do produto no momento da venda | Numérico float/decimal congelado na venda. Exemplo fictício: *3500.00*. |

### Entidade: `Historico_Precos`
| Atributo | Descrição | Regra de negócio associada |
|----------|-----------|------------------------------|
| `id` | Identificador do histórico | Chave Primária (`PK`), autoincremento. |
| `preco_custo_antigo` | Custo anterior à mudança | Numérico float/decimal. Exemplo fictício: *3200.00*. |
| `preco_venda_antigo` | Preço de venda anterior | Numérico float/decimal. Exemplo fictício: *4800.00*. |
| `preco_custo_novo` | Custo atualizado | Numérico float/decimal. Exemplo fictício: *3500.00*. |
| `preco_venda_novo` | Preço de venda atualizado | Numérico float/decimal. Exemplo fictício: *5000.00*. |
| `data_alteracao` | Data/hora exata da mudança | Preenchimento automático (`CURRENT_TIMESTAMP`). Exemplo fictício: *2026-09-10 10:30:00*. |

### Entidade: `Movimentacoes_Estoque`
| Atributo | Descrição | Regra de negócio associada |
|----------|-----------|------------------------------|
| `id` | Identificador da movimentação | Chave Primária (`PK`), autoincremento. |
| `quantidade_mov` | Volume movimentado | Numérico inteiro positivo. Exemplo fictício: *10*. |
| `tipo_movimentacao` | Natureza do movimento | Valores: 'Entrada', 'Saída Manual', 'Ajuste Inventário', 'Perda'. Exemplo fictício: *Entrada*. |
| `data_movimentacao` | Data/hora do lançamento | Preenchimento automático (`CURRENT_TIMESTAMP`). Exemplo fictício: *2026-09-12 14:15:00*. |
| `observacao` | Justificativa do lançamento | Opcional. Exemplo fictício: *Compra NF 4580 do fornecedor*. |

---

## 6. Modelagem Conceitual (Entidades, Atributos, Relacionamentos)

- **Entidades reconhecidas:**
  - `Clientes`: Representa as pessoas físicas ou jurídicas tomadoras de serviço ou compradoras.
  - `Funcionario`: Representa os colaboradores do sistema (vendedores, técnicos, administradores).
  - `Produtos`: Representa os bens físicos comercializados (drones, baterias, acessórios) e peças de reposição.
  - `Vendas`: Representa a transação comercial ou ordem de serviço fechada.
  - `Historico_Precos`: Entidade de rastreabilidade para alterações financeiras dos produtos.
  - `Movimentacoes_Estoque`: Entidade de auditoria para fluxo de entrada e saída de mercadorias.

- **Atributos e classificações:**
  - Atributos Identificadores (PK): `id` em todas as entidades.
  - Atributos Associativos (no relacionamento N:M `<Compoe>`): `quantidade`, `preco_unitario_aplicado`, `preco_custo_aplicado`.
  - Atributos Descritivos: `nome_razao`, `nome`, `categoria`, `forma_pagamento`, `tipo_movimentacao`, `observacao`, `cargo`.
  - Atributos Monotônicos/Monetários: `preco_custo`, `preco_venda`, `valor_total`, `lucro_total`, `preco_custo_antigo`, `preco_venda_antigo`, `preco_custo_novo`, `preco_venda_novo`.

- **Relacionamentos e Cardinalidades Mapeadas no brModelo Web:**
  - `Clientes` **`<Realiza>`** `Vendas`: Cardinalidade `(0,n)` em Clientes e `(0,1)` em Vendas. Um cliente pode realizar zero ou várias vendas; uma venda pode ser associada a no máximo um cliente (opcional no balcão).
  - `Vendas` **`<Compoe>`** `Produtos`: Relacionamento $N:M$. Cardinalidade `(1,n)` em Vendas e `(0,n)` em Produtos. Possui os atributos associativos congelados na transação.
  - `Produtos` **`<Gera>`** `Movimentacoes_Estoque`: Cardinalidade `(0,n)` em Produtos e `(1,1)` em Movimentacoes_Estoque. Cada movimentação física refere-se obrigatoriamente a exatamente 1 produto.
  - `Produtos` **`<Historiza>`** `Historico_Precos`: Cardinalidade `(0,n)` em Produtos e `(1,1)` em Historico_Precos. Cada alteração histórica refere-se a exatamente 1 produto.
  - `Funcionario` **`<Registra>`** `Vendas`: Cardinalidade `(0,n)` em Funcionario e `(1,1)` em Vendas.
  - `Funcionario` **`<Autoriza>`** `Movimentacoes_Estoque`: Cardinalidade `(0,n)` em Funcionario e `(1,1)` em Movimentacoes_Estoque.
  - `Funcionario` **`<Altera>`** `Historico_Precos`: Cardinalidade `(0,n)` em Funcionario e `(1,1)` em Historico_Precos.

---

## 7. Diagrama Entidade-Relacionamento (DER)

- O arquivo visual do DER gerado via brModelo Web encontra-se anexo no repositório no arquivo `der_HD_drones.png`
  
---

## 8. Justificativa Técnica

A estrutura proposta abstrai com precisão as complexidades da operação comercial e técnica da HD Drones. As escolhas de modelagem fundamentam-se nos seguintes pontos:

- **Relacionamento $N:M$ `<Compoe>` com Atributos Congelados:** A modelagem direta entre `Vendas` e `Produtos` via losango associativo `<Compoe>` simplifica a representação conceitual mantendo a robustez necessária ao congelar `preco_unitario_aplicado` e `preco_custo_aplicado`. Isso garante a integridade histórica da transação, impedindo que alterações futuras no preço do produto adulterem relatórios de lucros passados.
- **Criação de Tabelas Dedicadas de Historização (`Historico_Precos` e `Movimentacoes_Estoque`):** Em vez de utilizar simples atributos atualizáveis em `Produtos`, optou-se pela criação de entidades filhas ligadas diretamente aos produtos e funcionários. Isso viabiliza auditorias completas de estoque e margens de lucro.
- **Padronização das Cardinalidades:** Mapeamento preciso no brModelo Web que garante a correta transição para o modelo lógico e físico (geração automatizada de chaves estrangeiras `FK` nos lados `(1,1)`).
- **Tratamento de Opcionalidade de Cliente:** O relacionamento `Clientes` -> `<Realiza>` -> `Vendas` utiliza cardinalidade `(0,1)` na ponta da venda, refletindo com fidelidade a regra do negócio real: vendas rápidas de balcão não exigem cadastro obrigatório do cliente.

---

## 9. Uso de Inteligência Artificial

| Item | O que registrar |
|------|------------------|
| **Ferramenta e etapa** | Google Gemini (Modelo de Linguagem) e brModelo Web utilizados na etapa de estruturação da documentação, refinamento das cardinalidades do DER e apoio na conversão conceitual-lógica. |
| **Motivação** | Agilizar a conversão dos requisitos de campo observados na empresa para a sintaxe padrão do brModelo Web e validar a consistência das cardinalidades e atributos associativos. |
| **Prompt(s) utilizados** | *"Ajustar documentação relacional do DER para o brModelo Web com as entidades Clientes, Funcionario, Produtos, Historico_Precos, Movimentacoes_Estoque, Vendas e relacionamento N:M Compoe."* |
| **Resposta recebida** | Estruturação dos dicionários e mapeamentos de cardinalidades para adequação estrita às regras do brModelo Web. |
| **Fontes consultadas e verificadas** | Comparação direta do esquema conceitual com as regras de modelagem relacional acadêmica e validação do fluxo operacional presenciado na HD Drones. |
| **Trechos rejeitados ou corrigidos** | A sugestão inicial de usar uma entidade associativa intermediária separada no modelo conceitual foi ajustada para o uso direto do relacionamento $N:M$ com atributos próprios no losango `<Compoe>`, atendendo ao padrão formal do brModelo Web. |
| **Justificativa da escolha final** | O modelo final manteve 100% da fidelidade às regras de negócio apuradas na pesquisa de campo, garantindo excelente representação visual e facilidade de conversão para o modelo lógico. |
| **Reflexão crítica** | A IA auxilia significativamente na organização textual e sintaxe, mas a validação humana das cardinalidades e regras específicas do negócio de assistência e vendas foi fundamental para evitar falhas de modelagem. |
