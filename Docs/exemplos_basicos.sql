-- SET vl_limite_fiado = 250.00
-- WHERE id_cliente = 1;

-- 8) DELETE: exemplo de exclusao de categoria sem vinculo com produtos.
-- Esta categoria de exemplo nao existe na massa de dados.
-- DELETE FROM categoria WHERE id_categoria = 99;

-- 9) Consulta gerencial: produtos no estoque minimo ou abaixo dele.
SELECT p.id_produto, p.nm_produto, e.qt_atual, e.qt_minima
FROM estoque e
INNER JOIN produto p ON p.id_produto = e.id_produto
WHERE e.qt_atual <= e.qt_minima
ORDER BY e.qt_atual ASC;

-- 10) Consulta gerencial: total vendido por dia.
SELECT DATE(dt_venda) AS dia,
       COUNT(*) AS quantidade_vendas,
       SUM(vl_total) AS total_vendido
FROM venda
WHERE st_venda = 'CONCLUIDA'
GROUP BY DATE(dt_venda)
ORDER BY dia DESC;

-- 11) Consulta gerencial: fiados em aberto e saldo devedor.
SELECT fi.id_fiado, c.nm_cliente, fi.dt_vencimento,
       fi.vl_total, fi.vl_pago,
       (fi.vl_total - fi.vl_pago) AS vl_saldo_devedor,
       fi.st_fiado
FROM fiado fi
INNER JOIN cliente c ON c.id_cliente = fi.id_cliente
WHERE fi.st_fiado = 'ABERTO'
ORDER BY fi.dt_vencimento;

-- 12) Consulta de auditoria: historico de movimentacoes por produto.
SELECT m.id_movimentacao, p.nm_produto, m.tp_movimento,
       m.qt_movimentada, m.ds_motivo, f.nm_funcionario,
       m.dt_movimentacao
FROM movimentacao_estoque m
INNER JOIN produto p ON p.id_produto = m.id_produto
INNER JOIN funcionario f ON f.id_funcionario = m.id_funcionario
ORDER BY m.dt_movimentacao DESC;

-- 13) Consulta de auditoria: eventos registrados no log.
SELECT l.id_log, l.dt_evento, l.tp_evento, l.nm_tabela,
       l.id_registro, f.nm_funcionario, l.ds_alteracao, l.ds_ip
FROM log_acesso l
LEFT JOIN funcionario f ON f.id_funcionario = l.id_funcionario
ORDER BY l.dt_evento DESC;

-- 14) Conferencia: compara saldo atual com o saldo calculado no historico.
SELECT e.id_produto, p.nm_produto, e.qt_atual,
       COALESCE(SUM(
         CASE
           WHEN m.tp_movimento IN ('ENTRADA_COMPRA','AJUSTE_ENTRADA')
             THEN m.qt_movimentada
           ELSE -m.qt_movimentada
         END
       ), 0) AS qt_calculada_historico
FROM estoque e
INNER JOIN produto p ON p.id_produto = e.id_produto
LEFT JOIN movimentacao_estoque m ON m.id_produto = e.id_produto
GROUP BY e.id_produto, p.nm_produto, e.qt_atual
HAVING e.qt_atual <> qt_calculada_historico;
