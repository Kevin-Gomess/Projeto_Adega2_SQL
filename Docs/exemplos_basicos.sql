USE adega;

-- 1) INSERT: cadastrar um produto (o trigger cria o estoque automaticamente).
-- INSERT INTO produto
--   (id_categoria, nm_produto, vl_venda, fl_vende_dose, fl_ativo)
-- VALUES
--   (1, 'Produto de teste', 7.50, 0, 1);

-- 2) INSERT: registrar entrada de mercadoria.
-- Informe um produto, funcionario e lote que ja existam.
-- INSERT INTO movimentacao_estoque
--   (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo)
-- VALUES
--   (1, 1, 1, 'ENTRADA_COMPRA', 5, 'Entrada de teste');

-- 3) INSERT: criar um lote. O trigger inicia o saldo em zero.
-- A quantidade deve entrar depois por movimentacao_estoque.
-- INSERT INTO lote (id_item_compra, nr_lote, dt_validade, qt_disponivel)
-- VALUES (1, 'LOTE-TESTE-999', '2027-12-31', 0);

-- 4) Exemplo completo de venda no fiado (execute o bloco inteiro).
-- Os IDs 3 sao os proximos IDs livres depois da massa_de_dados.sql.
-- A venda e seus itens sao cadastrados primeiro; a procedure conclui o fiado.
-- INSERT INTO venda
--   (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto,
--    vl_total, st_venda, fl_maioridade_conferida)
-- VALUES
--   (3, 2, 1, NOW(), 0.00, 5.50, 'CONCLUIDA', 1);
--
-- INSERT INTO item_venda
--   (id_item_venda, id_venda, id_produto, id_lote, tp_item, qt_item, vl_unitario)
-- VALUES
--   (3, 3, 1, 1, 'UNIDADE', 1, 5.50);
--
-- Exemplo: R$ 2,00 em PIX e R$ 3,50 no fiado.
-- INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES (3, 'PIX', 2.00);
-- CALL sp_registrar_venda_fiado(3, 2, '2026-12-15', 3.50);
-- CALL sp_validar_pagamentos_venda(3);

-- 5) SELECT simples: produtos e saldos atuais.
SELECT p.id_produto, p.nm_produto, p.vl_venda,
       e.qt_atual, e.qt_minima, e.ds_localizacao
FROM produto p
INNER JOIN estoque e ON e.id_produto = p.id_produto
ORDER BY p.nm_produto;

-- 6) SELECT com JOIN: itens de cada venda.
SELECT v.id_venda, v.dt_venda, f.nm_funcionario,
       p.nm_produto, iv.qt_item, iv.tp_item,
       iv.vl_unitario, iv.vl_subtotal
FROM venda v
INNER JOIN funcionario f ON f.id_funcionario = v.id_funcionario
INNER JOIN item_venda iv ON iv.id_venda = v.id_venda
INNER JOIN produto p ON p.id_produto = iv.id_produto
ORDER BY v.dt_venda DESC, v.id_venda;

-- 7) UPDATE: alterar o limite de fiado de um cliente.
-- UPDATE cliente
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

-- 15) Fechamento de caixa (informe o total contado fisicamente).
-- CALL sp_fechar_caixa(1, 161.00);

-- 16) Registro de consulta a dado pessoal pela aplicação (LGPD).
-- CALL sp_registrar_evento_acesso(1, 'CONSULTA_DADO_PESSOAL', 'cliente', '1', JSON_OBJECT('motivo', 'atendimento'), '192.0.2.10');

-- 17) Para autorizar um cliente conhecido, a aplicação deve definir o funcionário logado:
-- SET @id_funcionario_logado = 1;
-- CALL sp_autorizar_cliente_fiado(1, 300.00);

-- Exemplo de abertura de garrafa para vender doses (produto 2, lote 2).
-- SET @id_garrafa = NULL;
-- CALL sp_abrir_garrafa(2, 2, @id_garrafa);
-- Depois, cadastre item_venda com tp_item='DOSE' e id_garrafa_aberta=@id_garrafa.
