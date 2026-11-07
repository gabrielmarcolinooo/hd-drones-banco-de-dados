# Relatório de Levantamento de Requisitos e Pesquisa de Campo

**Empresa:** HD Drones — Comércio e Assistência Técnica de Drones e Acessórios LTDA  
**CNPJ:** 61.945.071/0002-32  
**Local:** Rua Santa Ifigênia, 480, Loja 22 — Centro Histórico de São Paulo, SP, CEP: 01207-000  
**Entrevistadores:** Gabriel Marcolino de Oliveira e Gabriel de Oliveira Silva  
**Respondente:** Gestor / Proprietário da HD Drones  

---

## 1. Resumo da Visita e Contexto Operacional
A pesquisa de campo foi conduzida online via WhatsApp com o proprietário. O objetivo foi mapear os gargalos operacionais no fluxo de caixa diário, o controle físico do estoque de peças e o acompanhamento formal de Ordens de Serviço (OS).

A loja possui equipe enxuta (5 colaboradores), atendendo de 15 a 25 clientes por dia no balcão e mantendo um catálogo ativo de 150 a 300 produtos e peças de reposição.

---

## 2. Detalhamento das Rotinas Entrevistadas e Gargalos (`P1-P4`)

### A. Fluxo de Caixa e Vendas de Balcão (PDV) — `PR02`
- **Rotina Atual:** Vendas diretas de acessórios (baterias, hélices, cabos) ocorrem rapidamente no balcão.
- **Necessidade / Regra de Negócio:** Permitir vendas avulsas sem cadastro obrigatório de cliente para evitar filas (`RN03`), mas exigir o congelamento do preço de venda e custo praticados no momento da transação na tabela associativa `Compoe_Venda` (`RN02`), evitando distorções em relatórios futuros.

### B. Assistência Técnica e Ordens de Serviço (OS) — `PR03`
- **Rotina Atual:** Entrada de equipamentos (drones) com defeito para orçamento, manutenção e aplicação de componentes.
- **Necessidade / Regra de Negócio:** Obrigatoriedade de cadastrar o cliente (`Clientes`) com CPF/CNPJ e telefone para abertura da OS (`RN03`). Estrutura desmembrada da venda comum para permitir acompanhamento de status ('Orçamento', 'Em Manutenção', 'Concluído'), discriminação do valor de mão de obra e peças aplicadas (`Pecas_OS`), e garantia legal de 90 dias após a entrega (`RN04` - CDC).

### C. Gestão de Estoque e Compras com Fornecedores — `PR04`
- **Rotina Atual:** Reposição de peças e drones através de fornecedores oficiais (ex: Multilaser).
- **Necessidade / Regra de Negócio:** Resolver a divergência de saldo de estoque (`P1`). Dar baixa automática no estoque tanto por vendas diretas (`Compoe_Venda`) quanto por peças aplicadas em Ordens de Serviço (`Pecas_OS`). Registrar a auditoria de entradas de mercadoria na tabela `Movimentacoes_Estoque` vinculando o fornecedor de origem (`Fornecedores`).

### D. Apuração de Margens, Lucro e Comissões — `PR05`
- **Rotina Atual:** Vendedores e técnicos recebem atribuições operacionais sobre vendas e serviços executados.
- **Necessidade / Regra de Negócio:** Resolver a incerteza financeira na apuração de margens (`P3`). O sistema deve obrigatoriamente atrelar o funcionário operador (`Funcionario`) a cada venda ou OS registrada para permitir o relatório consolidado de lucro líquido e comissões por colaborador.
