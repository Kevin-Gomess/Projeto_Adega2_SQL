  END IF;

  INSERT INTO fiado
    (id_venda, id_cliente, dt_vencimento, vl_total, vl_pago)
  VALUES
    (p_id_venda, p_id_cliente, p_dt_vencimento, v_total, 0.00);

  INSERT INTO item_fiado (id_item_venda)
  SELECT id_item_venda
    FROM item_venda
   WHERE id_venda = p_id_venda;

  INSERT INTO pagamento (id_venda, tp_forma, vl_pago)
  VALUES (p_id_venda, 'FIADO', v_total);

  COMMIT;
END$$

DELIMITER ;

-- =====================================================================
-- EXEMPLOS DE OPERACAO E CONSULTAS
-- INSERT, UPDATE, DELETE e CALL ficam comentados para evitar alteracoes
-- acidentais. Leia e ajuste os IDs antes de retirar os comentarios.
-- Os SELECTs ficam ativos e podem ser executados diretamente.
-- =====================================================================

-- 1) INSERT: cadastrar um produto (o estoque e criado pelo trigger).
-- INSERT INTO produto
--   (id_categoria, nm_produto, vl_venda, fl_vende_dose, fl_ativo)
-- VALUES
--   (1, 'Refrigerante 2L', 9.50, 0, 1);

-- 2) INSERT: registrar uma entrada de mercadoria.
-- O produto precisa ter um estoque e o funcionario precisa existir.
-- INSERT INTO movimentacao_estoque
--   (id_produto, id_funcionario, tp_movimento, qt_movimentada, ds_motivo)
-- VALUES
--   (1, 1, 'ENTRADA_COMPRA', 20, 'Recebimento de mercadoria');

-- 2.1) LOTE: cadastrar o lote com qt_disponivel inicial em zero.
-- A entrada real deve ser registrada em movimentacao_estoque.
-- INSERT INTO lote (id_item_compra, nr_lote, dt_validade, qt_disponivel)
-- VALUES (1, 'LOTE-EXEMPLO-01', '2027-12-31', 0);
--
-- 2.2) FIADO: depois de cadastrar a venda e todos os seus itens,
-- use a procedure para criar a conta, vincular todos os itens e
-- registrar o pagamento FIADO dentro de uma unica transacao.
-- A procedure considera que a venda inteira sera paga no fiado.
-- CALL sp_registrar_venda_fiado_completo(1, 1, '2026-12-15');

-- 3) SELECT simples: consultar produtos e seus saldos.
SELECT p.id_produto, p.nm_produto, p.vl_venda,
       e.qt_atual, e.qt_minima, e.ds_localizacao
FROM produto p
INNER JOIN estoque e ON e.id_produto = p.id_produto
ORDER BY p.nm_produto;

-- 4) SELECT com JOIN: itens de cada venda.
SELECT v.id_venda, v.dt_venda, f.nm_funcionario,
       p.nm_produto, iv.qt_item, iv.tp_item,
       iv.vl_unitario, iv.vl_subtotal
FROM venda v
INNER JOIN funcionario f ON f.id_funcionario = v.id_funcionario
INNER JOIN item_venda iv ON iv.id_venda = v.id_venda
INNER JOIN produto p ON p.id_produto = iv.id_produto
ORDER BY v.dt_venda DESC, v.id_venda;

-- 5) UPDATE: alterar o limite de fiado de um cliente.
-- UPDATE cliente
-- SET vl_limite_fiado = 200.00
-- WHERE id_cliente = 1;

-- 6) DELETE: exemplo seguro de exclusao de um cadastro sem historico.
-- Use somente se a categoria nao estiver vinculada a produtos.
-- DELETE FROM categoria WHERE id_categoria = 99;

-- 7) Consulta gerencial: produtos abaixo do estoque minimo.
SELECT p.id_produto, p.nm_produto, e.qt_atual, e.qt_minima
FROM estoque e
INNER JOIN produto p ON p.id_produto = e.id_produto
WHERE e.qt_atual <= e.qt_minima
ORDER BY e.qt_atual ASC;

-- 8) Consulta gerencial: total vendido por dia.
SELECT DATE(dt_venda) AS dia,
       COUNT(*) AS quantidade_vendas,
       SUM(vl_total) AS total_vendido
FROM venda
WHERE st_venda = 'CONCLUIDA'
GROUP BY DATE(dt_venda)
ORDER BY dia DESC;

-- 9) Consulta gerencial: fiados em aberto e saldo devedor.
SELECT fi.id_fiado, c.nm_cliente, fi.dt_vencimento,
       fi.vl_total, fi.vl_pago,
       (fi.vl_total - fi.vl_pago) AS vl_saldo_devedor,
       fi.st_fiado
FROM fiado fi
INNER JOIN cliente c ON c.id_cliente = fi.id_cliente
WHERE fi.st_fiado = 'ABERTO'
ORDER BY fi.dt_vencimento;

-- 10) Consulta de auditoria: historico de movimentacoes por produto.
SELECT m.id_movimentacao, p.nm_produto, m.tp_movimento,
       m.qt_movimentada, m.ds_motivo, f.nm_funcionario,
       m.dt_movimentacao
FROM movimentacao_estoque m
INNER JOIN produto p ON p.id_produto = m.id_produto
INNER JOIN funcionario f ON f.id_funcionario = m.id_funcionario
ORDER BY m.dt_movimentacao DESC;

-- 11) Consulta de auditoria: eventos registrados no log.
SELECT l.id_log, l.dt_evento, l.tp_evento, l.nm_tabela,
       l.id_registro, f.nm_funcionario, l.ds_alteracao, l.ds_ip
FROM log_acesso l
LEFT JOIN funcionario f ON f.id_funcionario = l.id_funcionario
ORDER BY l.dt_evento DESC;

-- 12) Conferencia: comparar saldo atual com o saldo calculado
-- pelo historico de movimentacoes.
SELECT e.id_produto, p.nm_produto, e.qt_atual,
       COALESCE(SUM(
         CASE
           WHEN m.tp_movimento IN ('ENTRADA_COMPRA','AJUSTE_ENTRADA')
             THEN m.qt_movimentada
           ELSE -m.qt_movimentada
         END
