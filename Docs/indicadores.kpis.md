# Indicadores, BI e IA — Adega do Tonho

Este arquivo mostra o que o banco consegue responder para quem toma decisão na adega. Os números de exemplo vêm da **massa de dados fictícia** (03/08/2026 a 01/11/2026, data de referência `@hoje = '2026-11-01'`), então servem para mostrar como a consulta funciona, não para dizer como a adega real está.

## 1. Informações estratégicas que o banco entrega

Antes, as vendas e o fiado ficavam no caderno e no celular. Com cada item vendido registrado, o dono passa a saber:

- quais produtos e categorias mais saem, e em quais dias e horários;
- quanto cada forma de pagamento (dinheiro, Pix, débito, crédito, fiado) representa;
- quanto tem para receber no fiado, de quem, e há quantos dias está atrasado;
- quais produtos estão no mínimo ou abaixo e precisam de compra;
- quanto se perde por quebra e vencimento;
- se o caixa fecha certo no fim do dia;
- quanto se compra de cada fornecedor.

## 2. KPIs

Metas: a de faturamento é a do dono (R$ 5.000 por mês); as outras foram definidas pelo grupo, para uma adega pequena, a partir do ritmo de vendas informado (cerca de 15 vendas por dia de terça a quinta e mais de 25 de sexta a domingo) e na meta de R$ 5.000 por mês (em alguns meses a adega fica bem abaixo disso). São sugestões, para o gerente ajustar.

| Código | KPI | Fórmula | Período | Meta | Consulta |
| :--- | :--- | :--- | :--- | :--- | :--- |
| KPI01 | Faturamento | soma de `venda.vl_total` das vendas CONCLUIDA | dia, mês | R$ 5.000 por mês; terça a quinta cerca de R$ 100 por dia; sexta a domingo mais de R$ 150 por dia | G01, G01b |
| KPI02 | Ticket médio | faturamento ÷ número de vendas concluídas | mês | R$ 8 ou mais por venda (R$ 5.000 por mês dividido pelas vendas do mês) | G02 |
| KPI03 | Produtos mais vendidos | receita e quantidade de `item_venda` por produto | mês | os 10 mais vendidos nunca podem faltar na prateleira | G04 |
| KPI04 | Produtos no mínimo ou abaixo | produtos com `qt_atual <= qt_minima` | diário | no máximo 5 produtos no mínimo ou abaixo ao mesmo tempo, e nenhum dos 10 mais vendidos | G05 |
| KPI05 | Saldo de fiado em aberto | soma de (`vl_total` − `vl_pago`) dos fiados ABERTO | semanal | até R$ 500 em aberto (cerca de 10% do faturamento do mês) | G06 |
| KPI06 | Fiado vencido | fiados ABERTO com `dt_vencimento` anterior a hoje | semanal | até R$ 100 vencido e nenhum cliente com mais de 30 dias de atraso | G07 |
| KPI07 | Perdas e quebras | quantidade e valor das movimentações PERDA | mês | perdas de até 1% do faturamento do mês (uns R$ 50) | G08 |
| KPI08 | Diferença de caixa | soma de `caixa.vl_diferenca` dos caixas FECHADO | dia, mês | soma do mês entre -R$ 20 e +R$ 20, e nenhum caixa com diferença acima de R$ 5 | G09, G09b |
| KPI09 | Vendas com documento fiscal registrado | vendas concluídas com registro em `nota_fiscal` ÷ vendas concluídas | dia, mês | 100% das vendas concluídas com documento fiscal registrado | Controle de notas fiscais (saída) |

### Exemplo de leitura (massa fictícia)

Os valores abaixo foram calculados lendo o arquivo `massa.de_dados.sql` e simulando as regras do banco, sem MySQL. Depois de rodar a massa, conferir com as consultas G indicadas.

| KPI | Resultado na massa de dados |
| :--- | :--- |
| Faturamento | agosto R$ 6.585,50; setembro R$ 6.060,00; outubro R$ 5.967,00; 01/11 R$ 89,00 (643 vendas concluídas e 7 canceladas, R$ 18.701,50 no total) |
| Ticket médio | agosto R$ 31,51; setembro R$ 29,28; outubro R$ 26,64 |
| Formas de pagamento | Pix 32,2%; dinheiro 27,8%; débito 17,0%; crédito 14,1%; fiado 8,9% |
| Produtos no mínimo ou abaixo | 3 |
| Fiado em aberto | 8 contas, R$ 231,50; 3 delas vencidas, R$ 64,50 |
| Perdas | 23 registros, 65 unidades |
| Diferença de caixa | 27 dos 90 caixas fechados com diferença; soma de -R$ 4,00; maior diferença de R$ 5,00 |
| Vendas com documento fiscal registrado | 378 das 643 vendas concluídas (cerca de 59%); os 383 documentos de saída incluem 5 de vendas depois canceladas. Todos entram como SEM_VALIDACAO |

## 3. Relação problema → KPI → consulta

| Problema da Entrega 1 | KPI | Consulta |
| :--- | :--- | :--- |
| P1 — vendas sem registro por item | KPI01, KPI02 | G01, G02, G03 |
| P2 — estoque anotado diferente do real | — | G13 e A01 (auditoria) |
| P3 — não saber o que mais sai | KPI03 | G04 |
| P4 — produto acabando sem aviso | KPI04 | G05 |
| P5 — controle do fiado | KPI05, KPI06 | G06, G07 |
| Perdas, caixa, compras e equipe | KPI07, KPI08 | G08, G09, G10, G11, G12 |
| Documento fiscal | KPI09 | Controle de notas fiscais (entrada e saída) |

## 4. Potencial para BI

Os dados estão em tabelas de movimento (`venda`, `item_venda`, `pagamento`, `movimentacao_estoque`, `movimentacao_caixa`, `garrafa_aberta`, `fiado`, `compra`, `caixa`, `log_acesso`) ligadas às de cadastro (`produto`, `categoria`, `funcionario`, `cliente`, `fornecedor`). Cada consulta G pode virar um gráfico num painel (Power BI, Metabase ou Looker Studio ligados ao MySQL):

| Painel | O que mostra | Consultas |
| :--- | :--- | :--- |
| Vendas | faturamento por dia e mês, ticket médio, formas de pagamento, top 10 produtos | G01, G01b, G02, G03, G04 |
| Estoque | produtos no mínimo, lotes vencidos ou perto de vencer, perdas por categoria | G05, G08, G11, G13 |
| Fiado | saldo por cliente, uso do limite, contas vencidas e dias de atraso | G06, G07 |
| Caixa e equipe | diferenças de caixa, vendas por funcionário, dias e horários de pico | G09, G09b, G12, G12b |
| Compras | valor por fornecedor e por mês, entregas parciais | G10 |

As consultas de auditoria (A) viram um painel de qualidade dos dados: se alguma voltar com linha, o gerente sabe qual regra de negócio foi quebrada.

## 5. Aplicações de IA

**Implementado neste trabalho:** nenhuma. O trabalho entrega o banco, a massa de dados e as consultas; não foi treinado nenhum modelo.

**Possível no futuro**, e o que o banco já guarda para isso:

| Ideia | Dado que já existe | O que falta |
| :--- | :--- | :--- |
| Prever a reposição de cada produto | saída diária em `movimentacao_estoque` e `item_venda` | histórico real de vários meses |
| Prever dias e horários de pico para a escala | `venda.dt_venda` e `escala` | histórico real |
| Sugerir limite de fiado pelo histórico de pagamento | `fiado`, `pagamento_fiado`, `dt_vencimento` | mais clientes e tempo de histórico |
| Alertar produto parado em estoque | estoque, vendas e lotes com validade | regra de "parado" definida pelo dono |

Importante: a massa de dados é fictícia e gerada por regras. Treinar um modelo nela só ensinaria as regras do gerador, não o comportamento da adega. Qualquer modelo precisa de dados reais, com o cuidado da LGPD (CPF e telefone de cliente não entram no treino).

## 6. Observações honestas

- A massa tem em média cerca de 7 vendas por dia (4 a 7 de terça a quinta e até 14 aos sábados), abaixo do ritmo informado pela adega (10 a 20 de terça a quinta e mais de 25 de sexta a domingo). O faturamento mensal da massa (cerca de R$ 6.000) ficou perto da meta de R$ 5.000 do dono; as metas dos KPIs foram pensadas para o ritmo informado.

- Os valores de preço, venda e fiado da massa são inventados e **não foram calibrados** com o caderno da adega. Se o dono passar números reais de faturamento e quantidade de vendas, a proporção da massa deve ser ajustada.
- As metas dos KPIs são sugestões do grupo e precisam ser combinadas com o responsável.
