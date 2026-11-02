(2, 'Ana Compradora', '55555555555', '1992-09-20', '11990000002', 200.00, 0, '2026-10-02 11:00:00', '2026-10-02 11:00:00');

-- 4) Fornecedores ficticios
INSERT INTO fornecedor
(id_fornecedor, nm_fornecedor, nr_cnpj, nr_telefone, tp_fornecimento, fl_ativo)
VALUES
(1, 'Distribuidora Modelo Ltda', '11111111000111', '1130000001', 'AMBOS', 1),
(2, 'Bebidas Exemplo ME', '22222222000122', '1130000002', 'ENTREGA', 1);

-- 5) Produtos (o trigger cria automaticamente o estoque zerado)
INSERT INTO produto
(id_produto, id_categoria, cd_barras, nm_produto, vl_venda, fl_vende_dose,
 qt_ml_garrafa, qt_ml_dose, vl_dose, fl_ativo)
VALUES
(1, 1, '7891000000001', 'Cerveja Pilsen  lata 350ml', 5.50, 0, NULL, NULL, NULL, 1),
(2, 2, '7891000000002', 'Vodka 1L', 48.90, 1, 1000, 50, 6.00, 1),
(3, 4, '7891000000003', 'Refrigerante Cola 2L', 9.50, 0, NULL, NULL, NULL, 1),
(4, 5, '7891000000004', 'Amendoim  pacote 100g', 4.00, 0, NULL, NULL, NULL, 1);

-- 6) Configuracao minima dos estoques criados pelo trigger
UPDATE estoque SET qt_minima = 10, ds_localizacao = 'Prateleira A1' WHERE id_produto = 1;
UPDATE estoque SET qt_minima = 3, ds_localizacao = 'Prateleira B1' WHERE id_produto = 2;
UPDATE estoque SET qt_minima = 5, ds_localizacao = 'Geladeira' WHERE id_produto = 3;
UPDATE estoque SET qt_minima = 8, ds_localizacao = 'Balcao' WHERE id_produto = 4;

-- 7) Escalas
INSERT INTO escala (id_escala, id_funcionario, dt_turno, hr_inicio, hr_fim, ds_funcao) VALUES
(1, 1, '2026-11-01', '08:00:00', '16:00:00', 'Gerencia'),
(2, 2, '2026-11-01', '16:00:00', '23:00:00', 'Atendimento'),
(3, 3, '2026-11-02', '08:00:00', '16:00:00', 'Atendimento');

-- 8) Caixa aberto para os exemplos de venda e recebimento
INSERT INTO caixa
(id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa)
VALUES
(1, 1, '2026-11-01 08:00:00', 150.00, 'ABERTO');

-- 9) Compras e itens de compra
INSERT INTO compra
(id_compra, id_fornecedor, id_funcionario, dt_pedido, dt_recebimento,
 tp_recebimento, nr_nota_fiscal, vl_total, st_compra)
VALUES
(1, 1, 1, '2026-10-30 09:00:00', '2026-10-30 14:00:00', 'ENTREGA', 'NF-EXEMPLO-001', 560.00, 'RECEBIDA');

INSERT INTO item_compra
(id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido)
VALUES
(1, 1, 1, 40, 40, 4.00, 1),
(2, 1, 2, 10, 10, 35.00, 1),
(3, 1, 3, 20, 20, 6.00, 1),
(4, 1, 4, 20, 20, 2.00, 1);

-- 10) Lotes: o trigger força qt_disponivel = 0 no cadastro
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
(1, 1, 'CERV-EX-001', '2027-06-30', 40),
(2, 2, 'VODK-EX-001', '2028-05-31', 10),
(3, 3, 'REFRI-EX-001', '2027-03-31', 20),
(4, 4, 'PET-EX-001', '2027-01-31', 20);

-- 11) Entradas: atualizam estoque e lote automaticamente
INSERT INTO movimentacao_estoque
(id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo)
VALUES
(1, 1, 1, 'ENTRADA_COMPRA', 40, 'Recebimento da compra 1'),
(2, 1, 2, 'ENTRADA_COMPRA', 10, 'Recebimento da compra 1'),
(3, 1, 3, 'ENTRADA_COMPRA', 20, 'Recebimento da compra 1'),
(4, 1, 4, 'ENTRADA_COMPRA', 20, 'Recebimento da compra 1');

-- 12) Venda paga no dinheiro
INSERT INTO venda
(id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, fl_maioridade_conferida)
VALUES
(1, 2, 1, '2026-11-01 10:15:00', 0.00, 11.00, 'CONCLUIDA', 1);

INSERT INTO item_venda (id_item_venda, id_venda, id_produto, tp_item, qt_item, vl_unitario) VALUES
(1, 1, 1, 'UNIDADE', 2, 5.50);

INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
(1, 'DINHEIRO', 11.00);

-- Saida correspondente a venda 1
INSERT INTO movimentacao_estoque
(id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo)
VALUES
(1, 2, 1, 'SAIDA_VENDA', 2, 'Venda 1');

-- 13) Venda integralmente no fiado: primeiro venda e itens, depois procedure
INSERT INTO venda
(id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, fl_maioridade_conferida)
VALUES
(2, 2, 1, '2026-11-01 11:30:00', 0.00, 9.50, 'CONCLUIDA', 0);

INSERT INTO item_venda (id_item_venda, id_venda, id_produto, tp_item, qt_item, vl_unitario) VALUES
(2, 2, 3, 'UNIDADE', 1, 9.50);

-- A procedure cria fiado, item_fiado e pagamento FIADO em uma transacao.
CALL sp_registrar_venda_fiado_completo(2, 1, '2026-11-15');

-- Saida correspondente a venda 2
INSERT INTO movimentacao_estoque
(id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo)
VALUES
(3, 2, 3, 'SAIDA_VENDA', 1, 'Venda 2');

-- 14) Recebimento parcial do fiado (o trigger atualiza vl_pago e st_fiado)
INSERT INTO pagamento_fiado
(id_fiado, id_caixa, tp_forma, vl_pago)
VALUES
(1, 1, 'PIX', 4.50);

-- 15) Registro ficticio de auditoria
INSERT INTO log_acesso
(id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip)
VALUES
(1, 'INSERT', 'produto', '1', JSON_OBJECT('acao', 'cadastro ficticio'), '192.0.2.10');

-- Conferencia esperada dos saldos apos as movimentacoes:
-- Produto 1: 38 unidades; Produto 2: 10 unidades;
-- Produto 3: 19 unidades; Produto 4: 20 unidades.
-- Fiado da venda 2: total R$ 9,50; pago R$ 4,50; saldo R$ 5,00.
