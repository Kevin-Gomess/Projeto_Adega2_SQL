
-- =====================================================================
USE adega;
SET @hoje   = '2026-11-01';
SET @inicio = '2026-10-01';   
SET @fim    = '2026-11-01';   

-- =====================================================================
-- PARTE 1 - SELECT COM JOIN
-- =====================================================================

-- J01 — Quais itens foram vendidos nas últimas 10 vendas, quem vendeu e quanto?
-- Atende: P1 (registro de cada produto vendido)
SELECT v.id_venda, v.dt_venda, f.nm_funcionario AS vendedor, p.nm_produto,
       iv.tp_item, iv.qt_item, iv.vl_unitario, iv.vl_subtotal
FROM venda AS v
JOIN funcionario AS f ON f.id_funcionario = v.id_funcionario
JOIN item_venda  AS iv ON iv.id_venda = v.id_venda
JOIN produto     AS p ON p.id_produto = iv.id_produto
WHERE v.id_venda > (SELECT MAX(id_venda) - 10 FROM venda)
ORDER BY v.id_venda DESC, iv.id_item_venda;

-- J02 — Como está o estoque de cada produto, com a categoria e a localização?
-- Atende: P2 e P4 (saber o que existe no estoque)
SELECT c.nm_categoria, p.nm_produto, e.qt_atual, e.qt_minima, e.ds_localizacao
FROM produto AS p
JOIN categoria AS c ON c.id_categoria = p.id_categoria
JOIN estoque   AS e ON e.id_produto = p.id_produto
ORDER BY c.nm_categoria, p.nm_produto;

-- J03 — O que foi comprado de cada fornecedor na compra mais recente de cada um?
-- Atende: compras e fornecedores
SELECT fo.nm_fornecedor, c.id_compra, c.dt_pedido, c.st_compra,
       p.nm_produto, ic.qt_pedida, ic.qt_recebida, ic.vl_custo
FROM compra AS c
JOIN fornecedor  AS fo ON fo.id_fornecedor = c.id_fornecedor
JOIN item_compra AS ic ON ic.id_compra = c.id_compra
JOIN produto     AS p  ON p.id_produto = ic.id_produto
WHERE c.id_compra = (SELECT MAX(c2.id_compra) FROM compra AS c2 WHERE c2.id_fornecedor = c.id_fornecedor)
ORDER BY fo.nm_fornecedor, p.nm_produto;

-- J04 — Quais clientes têm fiado em aberto e de qual venda ele veio?
-- Atende: P5 (controle do fiado)
SELECT cl.nm_cliente, f.id_fiado, f.id_venda, f.dt_abertura, f.dt_vencimento,
       f.vl_total, f.vl_pago, (f.vl_total - f.vl_pago) AS saldo
FROM fiado AS f
JOIN cliente AS cl ON cl.id_cliente = f.id_cliente
WHERE f.st_fiado = 'ABERTO'
ORDER BY f.dt_vencimento;

-- J05 — Quais produtos entraram em cada fiado (linhas da venda marcadas)?
-- Atende: P5 e RN04 (produto, quantidade e preço ficam em item_venda)
SELECT f.id_fiado, cl.nm_cliente, p.nm_produto, iv.qt_item, iv.vl_unitario, iv.vl_subtotal
FROM fiado AS f
JOIN cliente     AS cl ON cl.id_cliente = f.id_cliente
JOIN item_venda  AS iv ON iv.id_venda = f.id_venda
JOIN item_fiado  AS fi ON fi.id_item_venda = iv.id_item_venda
JOIN produto     AS p  ON p.id_produto = iv.id_produto
WHERE f.id_fiado <= 5
ORDER BY f.id_fiado, iv.id_item_venda;

-- J06 — Quem trabalhou em cada dia da última semana e em qual função?
-- Atende: escala dos funcionários
SELECT e.dt_turno, fu.nm_funcionario, fu.tp_cargo, e.ds_funcao, e.hr_inicio, e.hr_fim
FROM escala AS e
JOIN funcionario AS fu ON fu.id_funcionario = e.id_funcionario
WHERE e.dt_turno BETWEEN DATE_ADD(@hoje, INTERVAL -6 DAY) AND @hoje
ORDER BY e.dt_turno, fu.nm_funcionario;

-- J07 — Quais garrafas foram abertas para vender doses, por quem e quanto ainda resta?
-- Atende: P1 e RN06 (abertura de garrafa e venda por dose)
SELECT g.id_garrafa_aberta, p.nm_produto, f.nm_funcionario AS aberta_por, g.dt_abertura,
       g.qt_ml_inicial, g.qt_ml_restante, g.st_garrafa
FROM garrafa_aberta AS g
JOIN produto AS p ON p.id_produto = g.id_produto
JOIN funcionario AS f ON f.id_funcionario = g.id_funcionario
ORDER BY g.dt_abertura;

-- =====================================================================
-- PARTE 2 - CONSULTAS GERENCIAIS
-- =====================================================================

-- G01 — Qual o faturamento e o número de vendas por mês?
-- Atende: P1 e KPI01 (faturamento). Só vendas concluídas.
SELECT DATE_FORMAT(v.dt_venda, '%Y-%m') AS mes,
       COUNT(*) AS vendas,
       SUM(v.vl_total) AS faturamento
FROM venda AS v
WHERE v.st_venda = 'CONCLUIDA'
GROUP BY DATE_FORMAT(v.dt_venda, '%Y-%m')
ORDER BY mes;

-- G01b — E por dia, nos últimos 14 dias?
-- Atende: P1 e KPI01
SELECT DATE(v.dt_venda) AS dia, COUNT(*) AS vendas, SUM(v.vl_total) AS faturamento
FROM venda AS v
WHERE v.st_venda = 'CONCLUIDA'
  AND DATE(v.dt_venda) > DATE_ADD(@hoje, INTERVAL -14 DAY)
GROUP BY DATE(v.dt_venda)
ORDER BY dia;

-- G02 — Qual o ticket médio (valor médio por venda) em cada mês?
-- Atende: KPI02 (ticket médio)
SELECT DATE_FORMAT(v.dt_venda, '%Y-%m') AS mes,
       COUNT(*) AS vendas,
       ROUND(SUM(v.vl_total) / COUNT(*), 2) AS ticket_medio
FROM venda AS v
WHERE v.st_venda = 'CONCLUIDA'
GROUP BY DATE_FORMAT(v.dt_venda, '%Y-%m')
ORDER BY mes;

-- G03 — Quanto cada forma de pagamento representa no total das vendas concluídas?
-- Atende: P1 (o que antes só aparecia como "recebimento")
SELECT p.tp_forma,
       COUNT(*) AS pagamentos,
       SUM(p.vl_pago) AS valor,
       ROUND(100 * SUM(p.vl_pago) / (SELECT SUM(p2.vl_pago)
                                      FROM pagamento AS p2
                                      JOIN venda AS v2 ON v2.id_venda = p2.id_venda
                                      WHERE v2.st_venda = 'CONCLUIDA'), 1) AS percentual
FROM pagamento AS p
JOIN venda AS v ON v.id_venda = p.id_venda
WHERE v.st_venda = 'CONCLUIDA'
GROUP BY p.tp_forma
ORDER BY valor DESC;

-- G04 — Quais são os 10 produtos que mais vendem no período (de @inicio até @fim)?
-- Atende: P3 e KPI03 (produtos mais vendidos)
SELECT p.nm_produto, c.nm_categoria,
       SUM(CASE WHEN iv.tp_item = 'UNIDADE' THEN iv.qt_item ELSE 0 END) AS unidades,
       SUM(CASE WHEN iv.tp_item = 'DOSE'    THEN iv.qt_item ELSE 0 END) AS doses,
       SUM(iv.vl_subtotal) AS receita
FROM item_venda AS iv
JOIN venda     AS v ON v.id_venda = iv.id_venda
JOIN produto   AS p ON p.id_produto = iv.id_produto
JOIN categoria AS c ON c.id_categoria = p.id_categoria
WHERE v.st_venda = 'CONCLUIDA' AND DATE(v.dt_venda) BETWEEN @inicio AND @fim
GROUP BY p.id_produto, p.nm_produto, c.nm_categoria
ORDER BY receita DESC
LIMIT 10;

-- G05 — Quais produtos estão no mínimo ou abaixo dele hoje?
-- Atende: P4 e KPI04 (produtos que estão acabando)
SELECT p.nm_produto, c.nm_categoria, e.qt_atual, e.qt_minima,
       (e.qt_minima - e.qt_atual) AS falta_para_o_minimo
FROM estoque AS e
JOIN produto   AS p ON p.id_produto = e.id_produto
JOIN categoria AS c ON c.id_categoria = p.id_categoria
WHERE e.qt_atual <= e.qt_minima AND p.fl_ativo = 1
ORDER BY falta_para_o_minimo DESC, p.nm_produto;

-- G06 — Qual o saldo de fiado em aberto de cada cliente e quanto do limite já foi usado?
-- Atende: P5 e KPI05 (saldo de fiado em aberto)
SELECT cl.nm_cliente, cl.vl_limite_fiado,
       SUM(f.vl_total - f.vl_pago) AS saldo_devedor,
       ROUND(100 * SUM(f.vl_total - f.vl_pago) / cl.vl_limite_fiado, 1) AS percentual_do_limite
FROM cliente AS cl
JOIN fiado AS f ON f.id_cliente = cl.id_cliente
WHERE f.st_fiado = 'ABERTO'
GROUP BY cl.id_cliente, cl.nm_cliente, cl.vl_limite_fiado
ORDER BY saldo_devedor DESC;

-- G07 — Quais fiados estão vencidos, há quantos dias e de quem?
-- Atende: P5 e KPI06 (fiado vencido). Vencido = em aberto e com dt_vencimento anterior a hoje.
SELECT cl.nm_cliente, f.id_fiado, f.dt_vencimento,
       DATEDIFF(@hoje, f.dt_vencimento) AS dias_de_atraso,
       (f.vl_total - f.vl_pago) AS saldo, cl.fl_bloqueado
FROM fiado AS f
JOIN cliente AS cl ON cl.id_cliente = f.id_cliente
WHERE f.st_fiado = 'ABERTO' AND f.dt_vencimento < @hoje
ORDER BY dias_de_atraso DESC;

-- G08 — Quanto foi perdido por mês, por categoria (quebra, avaria, vencimento)?
-- Atende: KPI07 (perdas e quebras). Valor calculado ao preço de venda atual do produto.
SELECT DATE_FORMAT(m.dt_movimentacao, '%Y-%m') AS mes, c.nm_categoria,
       SUM(m.qt_movimentada) AS unidades_perdidas,
       SUM(m.qt_movimentada * p.vl_venda) AS valor_a_preco_de_venda
FROM movimentacao_estoque AS m
JOIN produto   AS p ON p.id_produto = m.id_produto
JOIN categoria AS c ON c.id_categoria = p.id_categoria
WHERE m.tp_movimento = 'PERDA'
GROUP BY DATE_FORMAT(m.dt_movimentacao, '%Y-%m'), c.nm_categoria
ORDER BY mes, valor_a_preco_de_venda DESC;

-- G09 — Quais caixas fecharam com diferença e de quanto, e quem estava responsável?
-- Atende: KPI08 (diferença de caixa)
SELECT cx.id_caixa, DATE(cx.dt_abertura) AS dia, fu.nm_funcionario AS responsavel,
       cx.vl_esperado, cx.vl_contado, cx.vl_diferenca, cx.ds_observacao
FROM caixa AS cx
JOIN funcionario AS fu ON fu.id_funcionario = cx.id_funcionario
WHERE cx.st_caixa = 'FECHADO' AND cx.vl_diferenca <> 0
ORDER BY cx.dt_abertura;

-- G09b — Resumo mensal das diferenças de caixa
-- Atende: KPI08
SELECT DATE_FORMAT(cx.dt_abertura, '%Y-%m') AS mes,
       COUNT(*) AS caixas_fechados,
       SUM(CASE WHEN cx.vl_diferenca <> 0 THEN 1 ELSE 0 END) AS com_diferenca,
       SUM(cx.vl_diferenca) AS soma_das_diferencas
FROM caixa AS cx
WHERE cx.st_caixa = 'FECHADO'
GROUP BY DATE_FORMAT(cx.dt_abertura, '%Y-%m')
ORDER BY mes;

-- G10 — Quanto foi comprado de cada fornecedor por mês?
-- Atende: compras e fornecedores
SELECT fo.nm_fornecedor, DATE_FORMAT(c.dt_pedido, '%Y-%m') AS mes,
       COUNT(*) AS compras, SUM(c.vl_total) AS valor_comprado,
       SUM(CASE WHEN c.st_compra = 'RECEBIDA_PARCIAL' THEN 1 ELSE 0 END) AS recebidas_parcialmente
FROM compra AS c
JOIN fornecedor AS fo ON fo.id_fornecedor = c.id_fornecedor
WHERE c.st_compra <> 'CANCELADA'
GROUP BY fo.id_fornecedor, fo.nm_fornecedor, DATE_FORMAT(c.dt_pedido, '%Y-%m')
ORDER BY fo.nm_fornecedor, mes;

-- G11 — Quais lotes ainda com saldo estão vencidos ou vencem em até 30 dias?
-- Atende: RN18 e RN19 (controle de validade por lote)
SELECT p.nm_produto, l.nr_lote, l.dt_validade, l.qt_disponivel,
       DATEDIFF(l.dt_validade, @hoje) AS dias_para_vencer,
       CASE WHEN l.dt_validade < @hoje THEN 'VENCIDO' ELSE 'VENCE EM ATÉ 30 DIAS' END AS situacao
FROM lote AS l
JOIN item_compra AS ic ON ic.id_item_compra = l.id_item_compra
JOIN produto     AS p  ON p.id_produto = ic.id_produto
WHERE l.qt_disponivel > 0 AND l.dt_validade <= DATE_ADD(@hoje, INTERVAL 30 DAY)
ORDER BY l.dt_validade, p.nm_produto;

-- G12 — Quanto cada funcionário vendeu?
-- Atende: BI (desempenho da equipe)
SELECT fu.nm_funcionario, fu.tp_cargo, COUNT(*) AS vendas, SUM(v.vl_total) AS valor_vendido
FROM venda AS v
JOIN funcionario AS fu ON fu.id_funcionario = v.id_funcionario
WHERE v.st_venda = 'CONCLUIDA'
GROUP BY fu.id_funcionario, fu.nm_funcionario, fu.tp_cargo
ORDER BY valor_vendido DESC;

-- G12b — Em quais dias da semana e horários a adega mais vende?
-- Atende: BI (dias e horários de pico, apoio à escala)
SELECT DAYOFWEEK(v.dt_venda) AS dia_da_semana_1dom_a_7sab, HOUR(v.dt_venda) AS hora,
       COUNT(*) AS vendas, SUM(v.vl_total) AS faturamento
FROM venda AS v
WHERE v.st_venda = 'CONCLUIDA'
GROUP BY DAYOFWEEK(v.dt_venda), HOUR(v.dt_venda)
ORDER BY vendas DESC
LIMIT 10;

-- G13 — O que entrou e saiu do estoque de cada produto no período, por tipo de movimentação?
-- Atende: P2 (estoque anotado x estoque real)
SELECT p.nm_produto,
       SUM(CASE WHEN m.tp_movimento = 'ENTRADA_COMPRA' THEN m.qt_movimentada ELSE 0 END) AS entradas_compra,
       SUM(CASE WHEN m.tp_movimento = 'SAIDA_VENDA'    THEN m.qt_movimentada ELSE 0 END) AS saidas_venda,
       SUM(CASE WHEN m.tp_movimento = 'SAIDA_DOSE'     THEN m.qt_movimentada ELSE 0 END) AS garrafas_para_dose,
       SUM(CASE WHEN m.tp_movimento = 'PERDA'          THEN m.qt_movimentada ELSE 0 END) AS perdas,
       SUM(CASE WHEN m.tp_movimento IN ('AJUSTE_ENTRADA','AJUSTE_SAIDA','DEVOLUCAO_FORNECEDOR')
                THEN m.qt_movimentada ELSE 0 END) AS ajustes_e_devolucoes
FROM movimentacao_estoque AS m
JOIN produto AS p ON p.id_produto = m.id_produto
WHERE DATE(m.dt_movimentacao) BETWEEN @inicio AND @fim
GROUP BY p.id_produto, p.nm_produto
ORDER BY saidas_venda DESC
LIMIT 15;

-- G14 — Quanto entrou e saiu do caixa fora das vendas (suprimento, sangria e despesa) por mês?
-- Atende: P3 e RN23 (controle de caixa)
SELECT DATE_FORMAT(dt_movimentacao, '%Y-%m') AS mes, tp_movimento,
       COUNT(*) AS qtd, SUM(vl_movimento) AS total
FROM movimentacao_caixa
GROUP BY DATE_FORMAT(dt_movimentacao, '%Y-%m'), tp_movimento
ORDER BY mes, tp_movimento;

-- G15 — Quantos eventos de auditoria cada funcionário gerou, por tipo de evento?
-- Atende: RN30 (auditoria) e RN29 (consultas a dado pessoal ficam registradas)
SELECT fu.nm_funcionario, l.tp_evento, COUNT(*) AS qtd
FROM log_acesso AS l
JOIN funcionario AS fu ON fu.id_funcionario = l.id_funcionario
GROUP BY fu.nm_funcionario, l.tp_evento
ORDER BY fu.nm_funcionario, qtd DESC;

-- =====================================================================
-- PARTE 3 - CONSULTAS DE AUDITORIA (devem voltar vazias, salvo aviso)
-- =====================================================================

-- A01 — O saldo do estoque bate com a soma das movimentações de cada produto?
-- Verifica: RN17 (o saldo do estoque reflete as movimentações)
SELECT e.id_produto, p.nm_produto, e.qt_atual,
       COALESCE(SUM(CASE WHEN m.tp_movimento IN ('ENTRADA_COMPRA','AJUSTE_ENTRADA') THEN m.qt_movimentada
                         ELSE -m.qt_movimentada END), 0) AS saldo_pelas_movimentacoes
FROM estoque AS e
JOIN produto AS p ON p.id_produto = e.id_produto
LEFT JOIN movimentacao_estoque AS m ON m.id_produto = e.id_produto
GROUP BY e.id_produto, p.nm_produto, e.qt_atual
HAVING e.qt_atual <> COALESCE(SUM(CASE WHEN m.tp_movimento IN ('ENTRADA_COMPRA','AJUSTE_ENTRADA') THEN m.qt_movimentada
                                       ELSE -m.qt_movimentada END), 0);

-- A02 — Existe venda cujo total não bate com a soma dos itens menos o desconto?
-- Verifica: RN03 (total da venda = soma dos itens menos desconto)
SELECT v.id_venda, v.vl_total, SUM(iv.vl_subtotal) - v.vl_desconto AS total_calculado
FROM venda AS v
JOIN item_venda AS iv ON iv.id_venda = v.id_venda
GROUP BY v.id_venda, v.vl_total, v.vl_desconto
HAVING v.vl_total <> SUM(iv.vl_subtotal) - v.vl_desconto;

-- A03 — Existe venda cuja soma dos pagamentos é diferente do total?
-- Verifica: RN07 (a soma dos pagamentos, inclusive a parcela do fiado, é igual ao total da venda)
SELECT v.id_venda, v.vl_total, COALESCE(SUM(p.vl_pago), 0) AS soma_pagamentos
FROM venda AS v
LEFT JOIN pagamento AS p ON p.id_venda = v.id_venda
GROUP BY v.id_venda, v.vl_total
HAVING v.vl_total <> COALESCE(SUM(p.vl_pago), 0);

-- A04 — Existe venda registrada sem nenhum item?
-- Verifica: RN02 (toda venda tem ao menos um item)
SELECT v.id_venda, v.dt_venda
FROM venda AS v
WHERE NOT EXISTS (SELECT 1 FROM item_venda AS iv WHERE iv.id_venda = v.id_venda);

-- A05 — Existe venda feita fora do período em que o caixa esteve aberto?
-- Verifica: RN24 e RN02 (a venda pertence a um caixa e acontece enquanto ele está aberto)
SELECT v.id_venda, v.dt_venda, cx.dt_abertura, cx.dt_fechamento
FROM venda AS v
JOIN caixa AS cx ON cx.id_caixa = v.id_caixa
WHERE v.dt_venda < cx.dt_abertura
   OR (cx.dt_fechamento IS NOT NULL AND v.dt_venda > cx.dt_fechamento);

-- A06 — Existe venda de bebida alcoólica ou cigarro sem a conferência de maioridade?
-- Verifica: RN26 e RN27
SELECT DISTINCT v.id_venda, v.dt_venda, c.nm_categoria
FROM venda AS v
JOIN item_venda AS iv ON iv.id_venda = v.id_venda
JOIN produto    AS p  ON p.id_produto = iv.id_produto
JOIN categoria  AS c  ON c.id_categoria = p.id_categoria
WHERE c.fl_restrita_maiores = 1 AND v.fl_maioridade_conferida = 0;

-- A07 — Existe fiado cujo total não bate com a soma dos valores lançados nas linhas (item_fiado)?
-- Verifica: RN09 e RN07 (o fiado vem da venda e o valor dele é o que foi lançado nas linhas)
SELECT f.id_fiado, f.vl_total, COALESCE(SUM(fi.vl_fiado), 0) AS soma_lancada
FROM fiado AS f
LEFT JOIN item_venda AS iv ON iv.id_venda = f.id_venda
LEFT JOIN item_fiado AS fi ON fi.id_item_venda = iv.id_item_venda
GROUP BY f.id_fiado, f.vl_total
HAVING f.vl_total <> COALESCE(SUM(fi.vl_fiado), 0);

-- A08 — Existe pagamento FIADO em venda sem fiado, ou fiado cuja venda não tem pagamento FIADO do mesmo valor?
-- Verifica: RN07 e RN09
SELECT p.id_venda, 'pagamento FIADO sem fiado' AS problema
FROM pagamento AS p
WHERE p.tp_forma = 'FIADO' AND NOT EXISTS (SELECT 1 FROM fiado AS f WHERE f.id_venda = p.id_venda)
UNION ALL
SELECT f.id_venda, 'fiado sem pagamento FIADO do mesmo valor'
FROM fiado AS f
WHERE f.vl_total <> COALESCE((SELECT SUM(p2.vl_pago) FROM pagamento AS p2
                              WHERE p2.id_venda = f.id_venda AND p2.tp_forma = 'FIADO'), 0);

-- A09 — Existe fiado cujo valor pago não bate com a soma dos recebimentos?
-- Verifica: RN12 e RN13 (o valor pago do fiado é a soma dos recebimentos)
SELECT f.id_fiado, f.vl_pago, COALESCE(SUM(pf.vl_pago), 0) AS soma_recebimentos
FROM fiado AS f
LEFT JOIN pagamento_fiado AS pf ON pf.id_fiado = f.id_fiado
GROUP BY f.id_fiado, f.vl_pago
HAVING f.vl_pago <> COALESCE(SUM(pf.vl_pago), 0);

-- A10 — Existe fiado de cliente menor de 18 anos ou sem consentimento LGPD na data de abertura?
-- Verifica: RN08 e RN29 (cliente identificado, maior de idade e com consentimento LGPD)
SELECT f.id_fiado, cl.nm_cliente, cl.dt_nascimento, cl.dt_consentimento_lgpd
FROM fiado AS f
JOIN cliente AS cl ON cl.id_cliente = f.id_cliente
WHERE cl.dt_consentimento_lgpd > f.dt_abertura
   OR DATE_ADD(cl.dt_nascimento, INTERVAL 6570 DAY) > DATE(f.dt_abertura);

-- A11 — Existe cliente com saldo de fiado acima do limite?
-- Verifica: RN10
SELECT cl.id_cliente, cl.nm_cliente, cl.vl_limite_fiado, SUM(f.vl_total - f.vl_pago) AS saldo
FROM cliente AS cl
JOIN fiado AS f ON f.id_cliente = cl.id_cliente
GROUP BY cl.id_cliente, cl.nm_cliente, cl.vl_limite_fiado
HAVING SUM(f.vl_total - f.vl_pago) > cl.vl_limite_fiado;

-- A12 — Existe fiado com situação diferente do que os valores dizem (QUITADO com saldo ou ABERTO sem saldo)?
-- Verifica: RN14 (ABERTO enquanto o pago for menor que o total; QUITADO quando alcançar o total)
SELECT f.id_fiado, f.vl_total, f.vl_pago, f.st_fiado
FROM fiado AS f
WHERE (f.st_fiado = 'QUITADO' AND f.vl_pago < f.vl_total)
   OR (f.st_fiado = 'ABERTO'  AND f.vl_pago >= f.vl_total);

-- A13 — Existe caixa fechado com diferença e sem justificativa?
-- Verifica: RN23
SELECT cx.id_caixa, cx.vl_diferenca
FROM caixa AS cx
WHERE cx.st_caixa = 'FECHADO' AND cx.vl_diferenca <> 0 AND cx.ds_observacao IS NULL;

-- A14 — Existe mais de um caixa aberto ao mesmo tempo, ou o valor esperado de um caixa fechado não bate com o recalculado?
-- Verifica: RN22 e RN23 (esperado = troco + dinheiro das vendas e dos fiados + suprimentos - sangrias e despesas)
SELECT 'mais de um caixa aberto' AS problema, COUNT(*) AS quantidade
FROM caixa WHERE st_caixa = 'ABERTO'
HAVING COUNT(*) > 1
UNION ALL
SELECT CONCAT('caixa ', cx.id_caixa, ': esperado diferente do recalculado'), cx.vl_esperado
FROM caixa AS cx
WHERE cx.st_caixa = 'FECHADO'
  AND ABS(cx.vl_esperado - (cx.vl_troco_inicial
      + COALESCE((SELECT SUM(p.vl_pago) FROM pagamento AS p
                  JOIN venda AS v ON v.id_venda = p.id_venda
                  WHERE v.id_caixa = cx.id_caixa AND v.st_venda = 'CONCLUIDA' AND p.tp_forma = 'DINHEIRO'), 0)
      + COALESCE((SELECT SUM(pf.vl_pago) FROM pagamento_fiado AS pf
                  WHERE pf.id_caixa = cx.id_caixa AND pf.tp_forma = 'DINHEIRO'), 0)
      + COALESCE((SELECT SUM(CASE WHEN mc.tp_movimento = 'SUPRIMENTO' THEN mc.vl_movimento ELSE -mc.vl_movimento END)
                  FROM movimentacao_caixa AS mc WHERE mc.id_caixa = cx.id_caixa), 0))) > 0.005;

-- A15 — Existe item de compra recebido sem conferência, ou divergência sem descrição?
-- Verifica: RN21 (conferência do recebimento e registro da divergência)
SELECT ic.id_item_compra, c.id_compra, c.st_compra, ic.fl_conferido, ic.ds_divergencia
FROM item_compra AS ic
JOIN compra AS c ON c.id_compra = ic.id_compra
WHERE (c.st_compra IN ('RECEBIDA','RECEBIDA_PARCIAL') AND ic.fl_conferido = 0)
   OR (ic.qt_recebida < ic.qt_pedida AND ic.qt_recebida > 0 AND ic.ds_divergencia IS NULL);

-- A16 — Existe compra cujo valor total não bate com a soma dos itens?
-- Verifica: RN20 (valor da compra = soma dos itens)
SELECT c.id_compra, c.vl_total, COALESCE(SUM(ic.qt_pedida * ic.vl_custo), 0) AS soma_itens
FROM compra AS c
LEFT JOIN item_compra AS ic ON ic.id_compra = c.id_compra
GROUP BY c.id_compra, c.vl_total
HAVING ROUND(c.vl_total, 2) <> ROUND(COALESCE(SUM(ic.qt_pedida * ic.vl_custo), 0), 2);

-- A17 — Alguma venda deixou de gerar a saída de estoque? (unidades vendidas x saídas por venda, por produto)
-- Verifica: RN05 e RN17 (cada unidade vendida gerou a saída de estoque)
SELECT t.id_produto, t.nm_produto, t.unidades_vendidas, t.saidas_registradas
FROM (SELECT p.id_produto, p.nm_produto,
             COALESCE((SELECT SUM(iv.qt_item) FROM item_venda AS iv
                       WHERE iv.id_produto = p.id_produto AND iv.tp_item = 'UNIDADE'), 0) AS unidades_vendidas,
             COALESCE((SELECT SUM(m.qt_movimentada) FROM movimentacao_estoque AS m
                       WHERE m.id_produto = p.id_produto AND m.tp_movimento = 'SAIDA_VENDA'), 0) AS saidas_registradas
      FROM produto AS p) AS t
WHERE t.unidades_vendidas <> t.saidas_registradas;

-- A18 — Existe lote vencido que ainda tem saldo e não foi baixado como perda?
-- Verifica: RN19 (produto vencido sai da venda e é baixado). ATENÇÃO: pode trazer linhas, e isso é
-- o que a consulta serve para mostrar: lotes que venceram depois da última conferência do gerente.
SELECT p.nm_produto, l.nr_lote, l.dt_validade, l.qt_disponivel
FROM lote AS l
JOIN item_compra AS ic ON ic.id_item_compra = l.id_item_compra
JOIN produto     AS p  ON p.id_produto = ic.id_produto
WHERE l.qt_disponivel > 0 AND l.dt_validade < @hoje
ORDER BY l.dt_validade;

-- A19 — Existe perda ou ajuste de estoque sem motivo, ou feito por quem não é gerente?
-- Verifica: RN15 e RN16 (perda e ajuste exigem motivo e funcionário responsável; a aprovação do gerente é regra da massa)
SELECT m.id_movimentacao, m.tp_movimento, fu.nm_funcionario, fu.tp_cargo, m.ds_motivo
FROM movimentacao_estoque AS m
JOIN funcionario AS fu ON fu.id_funcionario = m.id_funcionario
WHERE m.tp_movimento IN ('PERDA','AJUSTE_ENTRADA','AJUSTE_SAIDA')
  AND (m.ds_motivo IS NULL OR fu.tp_cargo <> 'GERENTE');

-- A20 — Existe garrafa aberta com ml restante errado (maior que o inicial, ou diferente do inicial menos as doses vendidas)?
-- Verifica: RN06 (a venda de doses desconta os ml da garrafa aberta)
SELECT g.id_garrafa_aberta, g.qt_ml_inicial, g.qt_ml_restante,
       COALESCE(SUM(iv.qt_item), 0) * p.qt_ml_dose AS ml_vendidos
FROM garrafa_aberta AS g
JOIN produto AS p ON p.id_produto = g.id_produto
LEFT JOIN item_venda AS iv ON iv.id_garrafa_aberta = g.id_garrafa_aberta AND iv.tp_item = 'DOSE'
GROUP BY g.id_garrafa_aberta, g.qt_ml_inicial, g.qt_ml_restante, p.qt_ml_dose
HAVING g.qt_ml_restante <> g.qt_ml_inicial - COALESCE(SUM(iv.qt_item), 0) * p.qt_ml_dose
    OR g.qt_ml_restante < 0;
