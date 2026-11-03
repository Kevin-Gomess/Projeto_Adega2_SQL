
-- =====================================================================
USE adega;
SET @id_funcionario_logado = 1;

-- ---------------------------------------------------------------------
-- BLOCO 1 - INSERT que funciona
-- ---------------------------------------------------------------------

-- T01 — Cadastrar um produto novo (o trigger cria o estoque zerado sozinho)
-- Esperado: OK. O SELECT mostra o produto e o estoque com qt_atual = 0.
START TRANSACTION;
INSERT INTO produto (id_categoria, cd_barras, nm_produto, vl_venda, fl_controla_validade)
VALUES (1, '2000000009991', 'Produto de teste 350 ml', 4.50, 0);
SELECT p.id_produto, p.nm_produto, e.qt_atual
FROM produto AS p JOIN estoque AS e ON e.id_produto = p.id_produto
WHERE p.cd_barras = '2000000009991';
ROLLBACK;

-- T02 — Cadastrar um cliente adulto, com consentimento LGPD
-- Esperado: OK. Nasce BLOQUEADO para fiado (fl_bloqueado = 1) e o trigger grava no log_acesso.
START TRANSACTION;
INSERT INTO cliente (nm_cliente, nr_cpf, dt_nascimento, nr_telefone, dt_consentimento_lgpd)
VALUES ('Cliente Teste da Silva', '91999999999', '1990-05-10', '11900000000', '2026-11-01 10:00:00');
SELECT id_cliente, nm_cliente, vl_limite_fiado, fl_bloqueado FROM cliente WHERE nr_cpf = '91999999999';
SELECT tp_evento, nm_tabela FROM log_acesso ORDER BY id_log DESC LIMIT 1;
ROLLBACK;

-- T03 — Entrada de compra: o trigger soma no estoque
-- Esperado: OK. qt_atual do produto 27 sobe 3 unidades (produto sem controle de validade).
START TRANSACTION;
SELECT qt_atual AS antes FROM estoque WHERE id_produto = 27;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, tp_movimento, qt_movimentada, ds_motivo)
VALUES (27, 1, 'ENTRADA_COMPRA', 3, 'Teste de recebimento');
SELECT qt_atual AS depois FROM estoque WHERE id_produto = 27;
ROLLBACK;

-- T04 — Venda simples de um produto sem controle de validade, paga em dinheiro
-- Esperado: OK. O trigger baixa 1 unidade do estoque sozinho (SAIDA_VENDA automática).
START TRANSACTION;
SELECT qt_atual AS antes FROM estoque WHERE id_produto = 27;
INSERT INTO venda (id_funcionario, id_caixa, vl_total, fl_maioridade_conferida) VALUES (2, 91, 10.00, 0);
SET @v = LAST_INSERT_ID();
INSERT INTO item_venda (id_venda, id_produto, tp_item, qt_item, vl_unitario) VALUES (@v, 27, 'UNIDADE', 1, 10.00);
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES (@v, 'DINHEIRO', 10.00);
SELECT qt_atual AS depois FROM estoque WHERE id_produto = 27;
SELECT tp_movimento, qt_movimentada FROM movimentacao_estoque ORDER BY id_movimentacao DESC LIMIT 1;
ROLLBACK;

-- T05 — Autorizar cliente para fiado pela procedure (só o gerente pode)
-- Esperado: OK. Cliente 4 (bloqueado) passa a ter limite 120,00 e fl_bloqueado = 0.
START TRANSACTION;
CALL sp_autorizar_cliente_fiado(4, 120.00);
SELECT id_cliente, vl_limite_fiado, fl_bloqueado FROM cliente WHERE id_cliente = 4;
ROLLBACK;

-- T06 — Fechar o caixa pela procedure
-- Esperado: OK. A procedure calcula o esperado e grava a diferença (coluna calculada).
START TRANSACTION;
SET @id_funcionario_logado = 4;
CALL sp_fechar_caixa(91, 150.00);
SELECT st_caixa, vl_esperado, vl_contado, vl_diferenca FROM caixa WHERE id_caixa = 91;
ROLLBACK;
SET @id_funcionario_logado = 1;

-- ---------------------------------------------------------------------
-- BLOCO 2 - UPDATE
-- ---------------------------------------------------------------------

-- T07 — Reajustar o preço de um produto (RN04: o preço novo vale só para vendas futuras)
-- Esperado: OK. Vendas antigas continuam com o vl_unitario que gravaram.
START TRANSACTION;
UPDATE produto SET vl_venda = vl_venda + 1.00 WHERE id_produto = 1;
SELECT id_produto, nm_produto, vl_venda FROM produto WHERE id_produto = 1;
SELECT iv.id_item_venda, iv.vl_unitario FROM item_venda AS iv WHERE iv.id_produto = 1 LIMIT 3;
ROLLBACK;

-- T08 — Alterar a quantidade mínima do estoque (a quantidade atual só muda por movimentação)
-- Esperado: OK
START TRANSACTION;
UPDATE estoque SET qt_minima = qt_minima + 2 WHERE id_produto = 27;
SELECT id_produto, qt_atual, qt_minima FROM estoque WHERE id_produto = 27;
ROLLBACK;

-- T09 — Bloquear um cliente (volta a exigir autorização do gerente para fiado)
-- Esperado: OK, e o trigger registra a alteração no log_acesso.
START TRANSACTION;
UPDATE cliente SET fl_bloqueado = 1 WHERE id_cliente = 1;
SELECT id_cliente, fl_bloqueado FROM cliente WHERE id_cliente = 1;
SELECT tp_evento, nm_tabela, id_registro FROM log_acesso ORDER BY id_log DESC LIMIT 1;
ROLLBACK;

-- ---------------------------------------------------------------------
-- BLOCO 3 - DELETE
-- ---------------------------------------------------------------------

-- T10 — Apagar um registro que nenhuma outra tabela usa
-- Esperado: OK (1 linha apagada)
START TRANSACTION;
INSERT INTO categoria (nm_categoria, fl_restrita_maiores) VALUES ('Categoria de teste', 0);
DELETE FROM categoria WHERE nm_categoria = 'Categoria de teste';
SELECT COUNT(*) AS sobrou FROM categoria WHERE nm_categoria = 'Categoria de teste';
ROLLBACK;

-- T11 — Apagar uma categoria que tem produtos
-- Esperado: ERRO 1451 (Cannot delete or update a parent row: a foreign key constraint fails)
-- Porque: as FKs são RESTRICT, então não dá para apagar o "pai" com "filhos".
DELETE FROM categoria WHERE id_categoria = 1;

-- T12 — Apagar um cliente que tem fiado
-- Esperado: ERRO 1451
DELETE FROM cliente WHERE id_cliente = 1;

-- T13 — Apagar um item de venda
-- Esperado: ERRO 1644 (SQLSTATE 45000): 'Item de venda não pode ser excluído; registre cancelamento/ajuste apropriado.'
DELETE FROM item_venda WHERE id_item_venda = 1;

-- T14 — Apagar uma movimentação de estoque
-- Esperado: ERRO 1644: 'Movimentações não podem ser excluídas.'
DELETE FROM movimentacao_estoque WHERE id_movimentacao = 1;

-- ---------------------------------------------------------------------
-- BLOCO 4 - violações de constraint (todas devem dar erro)
-- ---------------------------------------------------------------------

-- T15 — PK repetida
-- Esperado: ERRO 1062 (Duplicate entry '1' for key 'categoria.PRIMARY')
INSERT INTO categoria (id_categoria, nm_categoria, fl_restrita_maiores) VALUES (1, 'Categoria repetida', 0);

-- T16 — FK que não existe (produto com categoria 999)
-- Esperado: ERRO 1452 (Cannot add or update a child row: a foreign key constraint fails)
INSERT INTO produto (id_categoria, nm_produto, vl_venda) VALUES (999, 'Produto sem categoria', 5.00);

-- T17 — UNIQUE: CPF de cliente repetido
-- Esperado: ERRO 1062 (... for key 'cliente.uq_cliente_nr_cpf')
INSERT INTO cliente (nm_cliente, nr_cpf, dt_nascimento, nr_telefone, dt_consentimento_lgpd)
SELECT 'Cliente repetido', nr_cpf, '1990-01-01', '11900000001', '2026-11-01 10:00:00' FROM cliente WHERE id_cliente = 1;

-- T18 — UNIQUE: código de barras repetido
-- Esperado: ERRO 1062 (... for key 'produto.uq_produto_cd_barras')
INSERT INTO produto (id_categoria, cd_barras, nm_produto, vl_venda)
SELECT id_categoria, cd_barras, 'Produto com código repetido', 5.00 FROM produto WHERE cd_barras IS NOT NULL LIMIT 1;

-- T19 — UNIQUE: segundo fiado para a mesma venda
-- Esperado: ERRO 1062 (... for key 'fiado.uq_fiado_id_venda'). Um fiado nasce de uma única venda.
INSERT INTO fiado (id_venda, id_cliente, dt_vencimento, vl_total)
SELECT id_venda, id_cliente, '2026-12-01', 10.00 FROM fiado WHERE id_fiado = 1;

-- T20 — CHECK: preço de venda negativo
-- Esperado: ERRO 3819 (Check constraint 'chk_produto_vl_venda' is violated)
INSERT INTO produto (id_categoria, nm_produto, vl_venda) VALUES (1, 'Produto preço negativo', -5.00);

-- T21 — CHECK: quantidade zero no item de venda
-- Esperado: ERRO 3819 (chk_item_venda_qt)
INSERT INTO item_venda (id_venda, id_produto, tp_item, qt_item, vl_unitario)
VALUES (1, 27, 'UNIDADE', 0, 5.00);

-- T22 — CHECK: pagamento de valor zero
-- Esperado: ERRO 3819 (chk_pagamento_valor)
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES (1, 'DINHEIRO', 0);

-- T23 — CHECK: estoque negativo
-- Esperado: ERRO 3819 (chk_estoque_qt_atual)
UPDATE estoque SET qt_atual = -1 WHERE id_produto = 27;

-- T24 — CHECK: perda sem motivo
-- Esperado: ERRO 3819 (chk_mov_motivo). RN15: perda exige motivo.
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, tp_movimento, qt_movimentada)
VALUES (27, 1, 'PERDA', 1);

-- T25 — CHECK: fechar o caixa sem informar o valor contado
-- Esperado: ERRO 3819 (chk_caixa_fechamento)
UPDATE caixa SET st_caixa = 'FECHADO', dt_fechamento = NOW() WHERE id_caixa = 91;

-- T26 — CHECK: garrafa com volume restante maior que o inicial
-- Esperado: ERRO 3819 (chk_garrafa_volume)
UPDATE garrafa_aberta SET qt_ml_restante = qt_ml_inicial + 1 WHERE id_garrafa_aberta = 1;

-- T27 — NOT NULL: cliente sem CPF
-- Esperado: ERRO 1048 (Column 'nr_cpf' cannot be null)
INSERT INTO cliente (nm_cliente, nr_cpf, dt_nascimento, nr_telefone, dt_consentimento_lgpd)
VALUES ('Cliente sem CPF', NULL, '1990-01-01', '11900000002', '2026-11-01 10:00:00');

-- T28 — Coluna calculada não aceita valor digitado
-- Esperado: ERRO 3105 (The value specified for generated column 'vl_subtotal' ... is not allowed)
INSERT INTO item_venda (id_venda, id_produto, tp_item, qt_item, vl_unitario, vl_subtotal)
VALUES (1, 27, 'UNIDADE', 1, 5.00, 999.00);

-- T29 — ENUM com valor fora da lista
-- Esperado: ERRO 1265 (Data truncated for column 'tp_forma'), no modo estrito do MySQL 8.0
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES (1, 'CHEQUE', 10.00);

-- ---------------------------------------------------------------------
-- BLOCO 5 - regras de negócio nos triggers e procedures (todas devem dar erro)
-- Mensagem esperada: ERRO 1644 (SQLSTATE 45000) com o texto indicado.
-- ---------------------------------------------------------------------

-- T30 — Item de venda alterado depois de gravado
-- Esperado: 'Item de venda não pode ser alterado; registre cancelamento/ajuste apropriado.'
UPDATE item_venda SET qt_item = qt_item + 1 WHERE id_item_venda = 1;

-- T31 — Movimentação de estoque alterada
-- Esperado: 'Movimentações não podem ser alteradas; registre um ajuste.'
UPDATE movimentacao_estoque SET qt_movimentada = 99 WHERE id_movimentacao = 1;

-- T32 — Venda com o caixa fechado
-- Esperado: 'A venda exige um caixa aberto.'
INSERT INTO venda (id_funcionario, id_caixa, vl_total) VALUES (2, 1, 10.00);

-- T33 — Venda de produto restrito (bebida alcoólica) sem conferir a maioridade
-- Esperado: 'Venda de produto restrito exige conferência da maioridade.'
START TRANSACTION;
INSERT INTO venda (id_funcionario, id_caixa, vl_total, fl_maioridade_conferida) VALUES (2, 91, 10.00, 0);
INSERT INTO item_venda (id_venda, id_produto, tp_item, qt_item, vl_unitario)
SELECT LAST_INSERT_ID(), p.id_produto, 'UNIDADE', 1, 10.00
FROM produto AS p JOIN categoria AS c ON c.id_categoria = p.id_categoria
WHERE c.fl_restrita_maiores = 1 LIMIT 1;
ROLLBACK;

-- T34 — Produto com controle de validade vendido sem informar o lote
-- Esperado: 'Produto com controle de validade exige informar o lote vendido.'
START TRANSACTION;
INSERT INTO venda (id_funcionario, id_caixa, vl_total, fl_maioridade_conferida) VALUES (2, 91, 10.00, 1);
INSERT INTO item_venda (id_venda, id_produto, tp_item, qt_item, vl_unitario)
SELECT LAST_INSERT_ID(), id_produto, 'UNIDADE', 1, 10.00 FROM produto WHERE fl_controla_validade = 1 AND fl_vende_dose = 0 LIMIT 1;
ROLLBACK;

-- T35 — Saída de lote maior que o saldo
-- Esperado: 'Quantidade maior que o saldo disponível no lote.'
START TRANSACTION;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo)
SELECT ic.id_produto, 1, l.id_lote, 'PERDA', l.qt_disponivel + 1, 'Teste de saldo'
FROM lote AS l JOIN item_compra AS ic ON ic.id_item_compra = l.id_item_compra
WHERE l.qt_disponivel > 0 LIMIT 1;
ROLLBACK;

-- T36 — Pagamento passando do total da venda
-- Esperado: 'A soma dos pagamentos não pode ultrapassar o total da venda.'
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES (1, 'PIX', 9999.00);

-- T37 — Pagamento FIADO sem cadastrar o fiado antes
-- Esperado: 'Cadastre o fiado antes de registrar o pagamento FIADO.'
START TRANSACTION;
INSERT INTO venda (id_funcionario, id_caixa, vl_total, fl_maioridade_conferida) VALUES (2, 91, 10.00, 0);
INSERT INTO item_venda (id_venda, id_produto, tp_item, qt_item, vl_unitario) VALUES (LAST_INSERT_ID(), 27, 'UNIDADE', 1, 10.00);
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES (LAST_INSERT_ID(), 'FIADO', 10.00);
ROLLBACK;

-- T38 — Autorizar fiado sendo atendente (só gerente pode)
-- Esperado: 'Somente gerente pode autorizar cliente para fiado.'
SET @id_funcionario_logado = 2;
CALL sp_autorizar_cliente_fiado(4, 100.00);
SET @id_funcionario_logado = 1;

-- T39 — Fiado para cliente bloqueado (cliente 4 está bloqueado por fiado vencido)
-- Esperado: 'Fiado permitido somente para cliente conhecido e autorizado pela gerência.'
START TRANSACTION;
INSERT INTO venda (id_funcionario, id_caixa, vl_total, fl_maioridade_conferida) VALUES (2, 91, 10.00, 0);
SET @v = LAST_INSERT_ID();
INSERT INTO item_venda (id_venda, id_produto, tp_item, qt_item, vl_unitario) VALUES (@v, 27, 'UNIDADE', 1, 10.00);
CALL sp_registrar_venda_fiado(@v, 4, DATE_ADD(CURDATE(), INTERVAL 30 DAY), 10.00);
ROLLBACK;

-- T40 — Fiado acima do limite do cliente (cliente 12 tem limite 100,00)
-- Esperado: 'Fiado recusado: valor ultrapassa o limite disponível do cliente.'
START TRANSACTION;
INSERT INTO venda (id_funcionario, id_caixa, vl_total, fl_maioridade_conferida) VALUES (2, 91, 500.00, 0);
SET @v = LAST_INSERT_ID();
INSERT INTO item_venda (id_venda, id_produto, tp_item, qt_item, vl_unitario) VALUES (@v, 27, 'UNIDADE', 1, 500.00);
CALL sp_registrar_venda_fiado(@v, 12, DATE_ADD(CURDATE(), INTERVAL 30 DAY), 500.00);
ROLLBACK;

-- T41 — Recebimento de fiado maior que o saldo devedor
-- Esperado: 'Pagamento inválido ou maior que o saldo devedor.'
INSERT INTO pagamento_fiado (id_fiado, id_caixa, tp_forma, vl_pago) VALUES (1, 91, 'PIX', 99999.00);

-- T42 — Abrir garrafa de produto que não vende dose
-- Esperado: 'Produto não está habilitado para venda por dose.'
START TRANSACTION;
SELECT l.id_lote INTO @lote_sem_dose
FROM lote AS l JOIN item_compra AS ic ON ic.id_item_compra = l.id_item_compra
JOIN produto AS p ON p.id_produto = ic.id_produto
WHERE p.fl_vende_dose = 0 AND l.qt_disponivel > 0 LIMIT 1;
CALL sp_abrir_garrafa(@lote_sem_dose, 2, @g);
ROLLBACK;

-- T43 — Fechar um caixa que já está fechado
-- Esperado: 'Caixa inexistente ou já fechado.'
CALL sp_fechar_caixa(1, 100.00);

-- T44 — Movimentar caixa (sangria) com o caixa fechado
-- Esperado: 'Movimentação exige caixa aberto.'
INSERT INTO movimentacao_caixa (id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo)
VALUES (1, 1, 'SANGRIA', 50.00, 'Teste com caixa fechado');

-- T45 — Registrar evento de acesso com tipo reservado
-- Esperado: 'Evento reservado para login e consulta de dado pessoal.'
CALL sp_registrar_evento_acesso(1, 'UPDATE', 'cliente', '1', NULL, '192.168.0.1');
