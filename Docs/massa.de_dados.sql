-- Nenhum nome, CPF, telefone ou valor aqui é real. CPFs e CNPJs são números inventados e as
-- pessoas e empresas não existem.
--
-- COMO ESTE ARQUIVO FUNCIONA
-- O banco tem triggers e procedures que validam e preenchem várias tabelas sozinhos (estoque
-- do produto, saldo do lote, saída de estoque da venda, status do fiado, log de auditoria).
-- Por isso a massa NÃO insere diretamente em estoque, nem as saídas de venda, nem fiado/item_fiado:
-- ela faz o que a adega faz no dia a dia, na ordem: cadastra, compra, recebe, abre caixa, vende,
-- lança fiado (CALL sp_registrar_venda_fiado), recebe fiado, fecha o caixa (CALL sp_fechar_caixa).
--
-- SET TIMESTAMP: para o NOW() e o CURRENT_DATE() do MySQL valerem a data simulada (os triggers
-- conferem validade e vencimento com CURRENT_DATE), o arquivo usa SET TIMESTAMP. No fim volta ao
-- relógio real. SET TIMESTAMP precisa de usuário com permissão (root no Workbench local tem).
-- Se o seu usuário não tiver, rode com root ou peça a permissão SYSTEM_VARIABLES_ADMIN.

-- =====================================================================
USE adega;

SET TIMESTAMP = UNIX_TIMESTAMP('2026-07-20 09:00:00');
SET @id_funcionario_logado = 1;

-- ---------------------------------------------------------------------
-- 1) Categorias
-- ---------------------------------------------------------------------
INSERT INTO categoria (id_categoria, nm_categoria, fl_restrita_maiores) VALUES
  (1, 'Cervejas', 1),
  (2, 'Refrigerantes, águas e sucos', 0),
  (3, 'Destilados', 1),
  (4, 'Vinhos e espumantes', 1),
  (5, 'Cigarros', 1),
  (6, 'Narguilé', 1),
  (7, 'Doces e salgadinhos', 0),
  (8, 'Mercearia e conveniência', 0);

-- ---------------------------------------------------------------------
-- 2) Funcionários (hash de senha fictício, não é de nenhuma senha real)
-- ---------------------------------------------------------------------
INSERT INTO funcionario (id_funcionario, nm_funcionario, nr_cpf, tp_cargo, ds_login, ds_senha_hash, dt_admissao, fl_ativo) VALUES
  (1, 'Rafael Teixeira Lima', '90000000011', 'GERENTE', 'rafael.lima', '$2b$10$xxxxxxxxxxxxxxxx01fakefakefakefakefakefakefakefakefakeab', '2022-03-14', 1),
  (2, 'Camila Duarte Nunes', '90000000022', 'ATENDENTE', 'camila.nunes', '$2b$10$xxxxxxxxxxxxxxxx02fakefakefakefakefakefakefakefakefakeab', '2023-06-05', 1),
  (3, 'Marcos Vinícius Prado', '90000000033', 'ATENDENTE', 'marcos.prado', '$2b$10$xxxxxxxxxxxxxxxx03fakefakefakefakefakefakefakefakefakeab', '2024-01-22', 1),
  (4, 'Juliana Albuquerque Reis', '90000000044', 'ATENDENTE', 'juliana.reis', '$2b$10$xxxxxxxxxxxxxxxx04fakefakefakefakefakefakefakefakefakeab', '2025-02-10', 1);

-- ---------------------------------------------------------------------
-- 3) Fornecedores (CNPJs inventados)
-- ---------------------------------------------------------------------
INSERT INTO fornecedor (id_fornecedor, nm_fornecedor, nr_cnpj, nr_telefone, tp_fornecimento, fl_ativo) VALUES
  (1, 'Distribuidora Boa Bebida Ltda', '00000000000101', '(11) 4000-0101', 'ENTREGA', 1),
  (2, 'Adega Atacado Vinhos e Destilados', '00000000000202', '(11) 4000-0202', 'AMBOS', 1),
  (3, 'Tabacaria Central Atacado', '00000000000303', '(11) 4000-0303', 'RETIRADA', 1),
  (4, 'Doce Mix Distribuidora', '00000000000404', '(11) 4000-0404', 'ENTREGA', 1),
  (5, 'Atacadão do Bairro Mercearia', '00000000000505', '(11) 4000-0505', 'AMBOS', 1);

-- ---------------------------------------------------------------------
-- 4) Produtos. O trigger trg_produto_cria_estoque cria o estoque zerado de cada um.
-- fl_controla_validade = 1 para o que tem prazo (exige lote na venda). Códigos de barras inventados (prefixo 2).
-- ---------------------------------------------------------------------
INSERT INTO produto (id_produto, id_categoria, cd_barras, nm_produto, vl_venda, fl_controla_validade, fl_vende_dose, qt_ml_garrafa, qt_ml_dose, vl_dose, fl_ativo) VALUES
  (1, 1, '2000000000015', 'Cerveja pilsen lata 350 ml', '4.50', 1, 0, NULL, NULL, NULL, 1),
  (2, 1, '2000000000022', 'Cerveja pilsen lata 473 ml', '5.50', 1, 0, NULL, NULL, NULL, 1),
  (3, 1, '2000000000039', 'Cerveja pilsen lata 269 ml', '3.50', 1, 0, NULL, NULL, NULL, 1),
  (4, 1, '2000000000046', 'Cerveja pilsen long neck 330 ml', '7.00', 1, 0, NULL, NULL, NULL, 1),
  (5, 1, '2000000000053', 'Cerveja pilsen garrafa 600 ml', '9.50', 1, 0, NULL, NULL, NULL, 1),
  (6, 1, '2000000000060', 'Cerveja pilsen garrafa 1 L', '11.00', 1, 0, NULL, NULL, NULL, 1),
  (7, 1, '2000000000077', 'Cerveja premium long neck 330 ml', '9.50', 1, 0, NULL, NULL, NULL, 1),
  (8, 1, '2000000000084', 'Cerveja premium lata 350 ml', '7.00', 1, 0, NULL, NULL, NULL, 1),
  (9, 1, '2000000000091', 'Cerveja artesanal IPA 355 ml', '18.00', 1, 0, NULL, NULL, NULL, 1),
  (10, 2, '2000000000107', 'Refrigerante cola lata 350 ml', '5.00', 1, 0, NULL, NULL, NULL, 1),
  (11, 2, '2000000000114', 'Refrigerante cola 2 L', '11.00', 1, 0, NULL, NULL, NULL, 1),
  (12, 2, '2000000000121', 'Refrigerante guaraná lata 350 ml', '4.50', 1, 0, NULL, NULL, NULL, 1),
  (13, 2, '2000000000138', 'Refrigerante guaraná 2 L', '9.50', 1, 0, NULL, NULL, NULL, 1),
  (14, 2, '2000000000145', 'Refrigerante limão lata 350 ml', '4.50', 1, 0, NULL, NULL, NULL, 1),
  (15, 2, '2000000000152', 'Água mineral sem gás 500 ml', '3.00', 1, 0, NULL, NULL, NULL, 1),
  (16, 2, '2000000000169', 'Água mineral com gás 500 ml', '3.50', 1, 0, NULL, NULL, NULL, 1),
  (17, 2, '2000000000176', 'Suco de laranja 1 L', '9.00', 1, 0, NULL, NULL, NULL, 1),
  (18, 2, '2000000000183', 'Suco de uva lata 290 ml', '4.00', 1, 0, NULL, NULL, NULL, 1),
  (19, 2, '2000000000190', 'Energético lata 250 ml', '9.00', 1, 0, NULL, NULL, NULL, 1),
  (20, 2, '2000000000206', 'Isotônico 500 ml', '7.00', 1, 0, NULL, NULL, NULL, 1),
  (21, 2, '2000000000213', 'Chá gelado 1,5 L', '8.00', 1, 0, NULL, NULL, NULL, 1),
  (22, 3, '2000000000220', 'Vodka 1 L', '38.00', 1, 1, 1000, 50, '7.00', 1),
  (23, 3, '2000000000237', 'Whisky 1 L', '89.00', 1, 1, 1000, 50, '14.00', 1),
  (24, 3, '2000000000244', 'Cachaça 700 ml', '16.00', 1, 1, 700, 50, '4.00', 1),
  (25, 3, '2000000000251', 'Gim 750 ml', '62.00', 1, 1, 750, 50, '10.00', 1),
  (26, 3, '2000000000268', 'Tequila 750 ml', '78.00', 1, 1, 750, 50, '12.00', 1),
  (27, 3, '2000000000275', 'Licor de café 750 ml', '34.00', 0, 0, NULL, NULL, NULL, 1),
  (28, 4, '2000000000282', 'Vinho tinto suave 750 ml', '32.00', 0, 0, NULL, NULL, NULL, 1),
  (29, 4, '2000000000299', 'Vinho tinto seco 750 ml', '45.00', 0, 0, NULL, NULL, NULL, 1),
  (30, 4, '2000000000305', 'Vinho branco seco 750 ml', '36.00', 0, 0, NULL, NULL, NULL, 1),
  (31, 4, '2000000000312', 'Espumante brut 750 ml', '55.00', 0, 0, NULL, NULL, NULL, 1),
  (32, 4, '2000000000329', 'Sidra 660 ml', '18.00', 0, 0, NULL, NULL, NULL, 1),
  (33, 5, '2000000000336', 'Cigarro maço padrão', '12.00', 0, 0, NULL, NULL, NULL, 1),
  (34, 5, '2000000000343', 'Cigarro maço box', '14.00', 0, 0, NULL, NULL, NULL, 1),
  (35, 5, '2000000000350', 'Cigarro mentolado maço', '13.00', 0, 0, NULL, NULL, NULL, 1),
  (36, 6, '2000000000367', 'Essência para narguilé 50 g', '22.00', 0, 0, NULL, NULL, NULL, 1),
  (37, 6, '2000000000374', 'Carvão para narguilé 1 kg', '25.00', 0, 0, NULL, NULL, NULL, 1),
  (38, 6, '2000000000381', 'Piteira descartável (pacote com 10)', '6.00', 0, 0, NULL, NULL, NULL, 1),
  (39, 7, '2000000000398', 'Salgadinho de milho 100 g', '7.00', 1, 0, NULL, NULL, NULL, 1),
  (40, 7, '2000000000404', 'Batata chips 90 g', '8.00', 1, 0, NULL, NULL, NULL, 1),
  (41, 7, '2000000000411', 'Amendoim japonês 150 g', '6.50', 1, 0, NULL, NULL, NULL, 1),
  (42, 7, '2000000000428', 'Chocolate em barra 80 g', '6.00', 1, 0, NULL, NULL, NULL, 1),
  (43, 7, '2000000000435', 'Bala de goma (pacote)', '5.00', 1, 0, NULL, NULL, NULL, 1),
  (44, 7, '2000000000442', 'Chiclete (pacote)', '3.00', 1, 0, NULL, NULL, NULL, 1),
  (45, 7, '2000000000459', 'Pirulito', '1.00', 1, 0, NULL, NULL, NULL, 1),
  (46, 7, '2000000000466', 'Biscoito recheado 120 g', '6.00', 1, 0, NULL, NULL, NULL, 1),
  (47, 7, '2000000000473', 'Paçoca (unidade)', '1.50', 1, 0, NULL, NULL, NULL, 1),
  (48, 7, '2000000000480', 'Barra de cereal', '4.00', 1, 0, NULL, NULL, NULL, 1),
  (49, 8, '2000000000497', 'Gelo em barra 5 kg', '12.00', 0, 0, NULL, NULL, NULL, 1),
  (50, 8, '2000000000503', 'Isqueiro comum', '4.00', 0, 0, NULL, NULL, NULL, 1),
  (51, 8, '2000000000510', 'Copo descartável (pacote com 50)', '8.00', 0, 0, NULL, NULL, NULL, 1),
  (52, 8, '2000000000527', 'Carvão para churrasco 3 kg', '22.00', 0, 0, NULL, NULL, NULL, 1),
  (53, 8, '2000000000534', 'Pilha AA (2 unidades)', '9.00', 0, 0, NULL, NULL, NULL, 1),
  (54, 8, '2000000000541', 'Fósforo (caixa)', '2.50', 0, 0, NULL, NULL, NULL, 1),
  (55, 8, '2000000000558', 'Macarrão espaguete 500 g', '6.00', 0, 0, NULL, NULL, NULL, 1),
  (56, 8, '2000000000565', 'Óleo de soja 900 ml', '9.00', 0, 0, NULL, NULL, NULL, 1),
  (57, 8, '2000000000572', 'Café torrado 250 g', '14.00', 0, 0, NULL, NULL, NULL, 1),
  (58, 8, '2000000000589', 'Açúcar 1 kg', '6.50', 0, 0, NULL, NULL, NULL, 1),
  (59, 8, '2000000000596', 'Leite integral 1 L', '6.00', 1, 0, NULL, NULL, NULL, 1),
  (60, 8, '2000000000602', 'Pão de forma', '8.50', 1, 0, NULL, NULL, NULL, 1);

-- ---------------------------------------------------------------------
-- 5) Quantidade mínima e localização de cada estoque (regra: cerca de 7 dias de venda)
-- ---------------------------------------------------------------------
UPDATE estoque SET qt_minima = 20, ds_localizacao = 'Geladeira 1' WHERE id_produto = 1;
UPDATE estoque SET qt_minima = 16, ds_localizacao = 'Geladeira 1' WHERE id_produto = 2;
UPDATE estoque SET qt_minima = 8, ds_localizacao = 'Geladeira 1' WHERE id_produto = 3;
UPDATE estoque SET qt_minima = 14, ds_localizacao = 'Geladeira 2' WHERE id_produto = 4;
UPDATE estoque SET qt_minima = 12, ds_localizacao = 'Geladeira 2' WHERE id_produto = 5;
UPDATE estoque SET qt_minima = 10, ds_localizacao = 'Depósito' WHERE id_produto = 6;
UPDATE estoque SET qt_minima = 8, ds_localizacao = 'Geladeira 2' WHERE id_produto = 7;
UPDATE estoque SET qt_minima = 8, ds_localizacao = 'Geladeira 1' WHERE id_produto = 8;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Geladeira 2' WHERE id_produto = 9;
UPDATE estoque SET qt_minima = 9, ds_localizacao = 'Geladeira 1' WHERE id_produto = 10;
UPDATE estoque SET qt_minima = 6, ds_localizacao = 'Depósito' WHERE id_produto = 11;
UPDATE estoque SET qt_minima = 6, ds_localizacao = 'Geladeira 1' WHERE id_produto = 12;
UPDATE estoque SET qt_minima = 4, ds_localizacao = 'Depósito' WHERE id_produto = 13;
UPDATE estoque SET qt_minima = 3, ds_localizacao = 'Geladeira 1' WHERE id_produto = 14;
UPDATE estoque SET qt_minima = 8, ds_localizacao = 'Geladeira 1' WHERE id_produto = 15;
UPDATE estoque SET qt_minima = 3, ds_localizacao = 'Geladeira 1' WHERE id_produto = 16;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Geladeira 2' WHERE id_produto = 17;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Geladeira 1' WHERE id_produto = 18;
UPDATE estoque SET qt_minima = 5, ds_localizacao = 'Geladeira 1' WHERE id_produto = 19;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Geladeira 2' WHERE id_produto = 20;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Depósito' WHERE id_produto = 21;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Prateleira A' WHERE id_produto = 22;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Prateleira A' WHERE id_produto = 23;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Prateleira A' WHERE id_produto = 24;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Prateleira A' WHERE id_produto = 25;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Prateleira A' WHERE id_produto = 26;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Prateleira A' WHERE id_produto = 27;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Prateleira B' WHERE id_produto = 28;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Prateleira B' WHERE id_produto = 29;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Prateleira B' WHERE id_produto = 30;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Prateleira B' WHERE id_produto = 31;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Prateleira B' WHERE id_produto = 32;
UPDATE estoque SET qt_minima = 6, ds_localizacao = 'Balcão' WHERE id_produto = 33;
UPDATE estoque SET qt_minima = 4, ds_localizacao = 'Balcão' WHERE id_produto = 34;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Balcão' WHERE id_produto = 35;
UPDATE estoque SET qt_minima = 3, ds_localizacao = 'Prateleira C' WHERE id_produto = 36;
UPDATE estoque SET qt_minima = 3, ds_localizacao = 'Prateleira C' WHERE id_produto = 37;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Prateleira C' WHERE id_produto = 38;
UPDATE estoque SET qt_minima = 6, ds_localizacao = 'Prateleira D' WHERE id_produto = 39;
UPDATE estoque SET qt_minima = 5, ds_localizacao = 'Prateleira D' WHERE id_produto = 40;
UPDATE estoque SET qt_minima = 4, ds_localizacao = 'Prateleira D' WHERE id_produto = 41;
UPDATE estoque SET qt_minima = 5, ds_localizacao = 'Prateleira D' WHERE id_produto = 42;
UPDATE estoque SET qt_minima = 4, ds_localizacao = 'Prateleira D' WHERE id_produto = 43;
UPDATE estoque SET qt_minima = 4, ds_localizacao = 'Balcão' WHERE id_produto = 44;
UPDATE estoque SET qt_minima = 4, ds_localizacao = 'Balcão' WHERE id_produto = 45;
UPDATE estoque SET qt_minima = 4, ds_localizacao = 'Prateleira D' WHERE id_produto = 46;
UPDATE estoque SET qt_minima = 4, ds_localizacao = 'Balcão' WHERE id_produto = 47;
UPDATE estoque SET qt_minima = 3, ds_localizacao = 'Prateleira D' WHERE id_produto = 48;
UPDATE estoque SET qt_minima = 5, ds_localizacao = 'Freezer' WHERE id_produto = 49;
UPDATE estoque SET qt_minima = 4, ds_localizacao = 'Balcão' WHERE id_produto = 50;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Prateleira D' WHERE id_produto = 51;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Depósito' WHERE id_produto = 52;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Balcão' WHERE id_produto = 53;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Balcão' WHERE id_produto = 54;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Prateleira E' WHERE id_produto = 55;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Prateleira E' WHERE id_produto = 56;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Prateleira E' WHERE id_produto = 57;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Prateleira E' WHERE id_produto = 58;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Geladeira 2' WHERE id_produto = 59;
UPDATE estoque SET qt_minima = 2, ds_localizacao = 'Prateleira E' WHERE id_produto = 60;

-- ---------------------------------------------------------------------
-- 6) Escala dos funcionários (sexta a domingo o turno termina à meia-noite)
-- ---------------------------------------------------------------------
INSERT INTO escala (id_escala, id_funcionario, dt_turno, hr_inicio, hr_fim, ds_funcao) VALUES
  (1, 2, '2026-08-03', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (2, 3, '2026-08-03', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (3, 1, '2026-08-04', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (4, 2, '2026-08-04', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (5, 1, '2026-08-05', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (6, 4, '2026-08-05', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (7, 3, '2026-08-06', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (8, 4, '2026-08-06', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (9, 1, '2026-08-07', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (10, 2, '2026-08-07', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (11, 3, '2026-08-07', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (12, 1, '2026-08-08', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (13, 3, '2026-08-08', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (14, 4, '2026-08-08', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (15, 2, '2026-08-09', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (16, 4, '2026-08-09', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (17, 2, '2026-08-10', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (18, 3, '2026-08-10', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (19, 1, '2026-08-11', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (20, 2, '2026-08-11', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (21, 1, '2026-08-12', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (22, 4, '2026-08-12', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (23, 3, '2026-08-13', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (24, 4, '2026-08-13', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (25, 1, '2026-08-14', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (26, 2, '2026-08-14', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (27, 3, '2026-08-14', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (28, 1, '2026-08-15', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (29, 3, '2026-08-15', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (30, 4, '2026-08-15', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (31, 2, '2026-08-16', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (32, 4, '2026-08-16', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (33, 2, '2026-08-17', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (34, 3, '2026-08-17', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (35, 1, '2026-08-18', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (36, 2, '2026-08-18', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (37, 1, '2026-08-19', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (38, 4, '2026-08-19', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (39, 3, '2026-08-20', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (40, 4, '2026-08-20', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (41, 1, '2026-08-21', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (42, 2, '2026-08-21', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (43, 3, '2026-08-21', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (44, 1, '2026-08-22', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (45, 3, '2026-08-22', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (46, 4, '2026-08-22', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (47, 2, '2026-08-23', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (48, 4, '2026-08-23', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (49, 2, '2026-08-24', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (50, 3, '2026-08-24', '13:00:00', '23:00:00', 'Atendimento e caixa');
INSERT INTO escala (id_escala, id_funcionario, dt_turno, hr_inicio, hr_fim, ds_funcao) VALUES
  (51, 1, '2026-08-25', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (52, 2, '2026-08-25', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (53, 1, '2026-08-26', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (54, 4, '2026-08-26', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (55, 3, '2026-08-27', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (56, 4, '2026-08-27', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (57, 1, '2026-08-28', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (58, 2, '2026-08-28', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (59, 3, '2026-08-28', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (60, 1, '2026-08-29', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (61, 3, '2026-08-29', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (62, 4, '2026-08-29', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (63, 2, '2026-08-30', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (64, 4, '2026-08-30', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (65, 2, '2026-08-31', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (66, 3, '2026-08-31', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (67, 1, '2026-09-01', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (68, 2, '2026-09-01', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (69, 1, '2026-09-02', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (70, 4, '2026-09-02', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (71, 3, '2026-09-03', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (72, 4, '2026-09-03', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (73, 1, '2026-09-04', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (74, 2, '2026-09-04', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (75, 3, '2026-09-04', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (76, 1, '2026-09-05', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (77, 3, '2026-09-05', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (78, 4, '2026-09-05', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (79, 2, '2026-09-06', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (80, 4, '2026-09-06', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (81, 2, '2026-09-07', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (82, 3, '2026-09-07', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (83, 1, '2026-09-08', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (84, 2, '2026-09-08', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (85, 1, '2026-09-09', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (86, 4, '2026-09-09', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (87, 3, '2026-09-10', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (88, 4, '2026-09-10', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (89, 1, '2026-09-11', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (90, 2, '2026-09-11', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (91, 3, '2026-09-11', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (92, 1, '2026-09-12', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (93, 3, '2026-09-12', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (94, 4, '2026-09-12', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (95, 2, '2026-09-13', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (96, 4, '2026-09-13', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (97, 2, '2026-09-14', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (98, 3, '2026-09-14', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (99, 1, '2026-09-15', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (100, 2, '2026-09-15', '13:00:00', '23:00:00', 'Atendimento e caixa');
INSERT INTO escala (id_escala, id_funcionario, dt_turno, hr_inicio, hr_fim, ds_funcao) VALUES
  (101, 1, '2026-09-16', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (102, 4, '2026-09-16', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (103, 3, '2026-09-17', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (104, 4, '2026-09-17', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (105, 1, '2026-09-18', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (106, 2, '2026-09-18', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (107, 3, '2026-09-18', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (108, 1, '2026-09-19', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (109, 3, '2026-09-19', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (110, 4, '2026-09-19', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (111, 2, '2026-09-20', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (112, 4, '2026-09-20', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (113, 2, '2026-09-21', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (114, 3, '2026-09-21', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (115, 1, '2026-09-22', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (116, 2, '2026-09-22', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (117, 1, '2026-09-23', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (118, 4, '2026-09-23', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (119, 3, '2026-09-24', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (120, 4, '2026-09-24', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (121, 1, '2026-09-25', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (122, 2, '2026-09-25', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (123, 3, '2026-09-25', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (124, 1, '2026-09-26', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (125, 3, '2026-09-26', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (126, 4, '2026-09-26', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (127, 2, '2026-09-27', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (128, 4, '2026-09-27', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (129, 2, '2026-09-28', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (130, 3, '2026-09-28', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (131, 1, '2026-09-29', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (132, 2, '2026-09-29', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (133, 1, '2026-09-30', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (134, 4, '2026-09-30', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (135, 3, '2026-10-01', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (136, 4, '2026-10-01', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (137, 1, '2026-10-02', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (138, 2, '2026-10-02', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (139, 3, '2026-10-02', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (140, 1, '2026-10-03', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (141, 3, '2026-10-03', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (142, 4, '2026-10-03', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (143, 2, '2026-10-04', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (144, 4, '2026-10-04', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (145, 2, '2026-10-05', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (146, 3, '2026-10-05', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (147, 1, '2026-10-06', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (148, 2, '2026-10-06', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (149, 1, '2026-10-07', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (150, 4, '2026-10-07', '13:00:00', '23:00:00', 'Atendimento e estoque');
INSERT INTO escala (id_escala, id_funcionario, dt_turno, hr_inicio, hr_fim, ds_funcao) VALUES
  (151, 3, '2026-10-08', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (152, 4, '2026-10-08', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (153, 1, '2026-10-09', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (154, 2, '2026-10-09', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (155, 3, '2026-10-09', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (156, 1, '2026-10-10', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (157, 3, '2026-10-10', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (158, 4, '2026-10-10', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (159, 2, '2026-10-11', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (160, 4, '2026-10-11', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (161, 2, '2026-10-12', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (162, 3, '2026-10-12', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (163, 1, '2026-10-13', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (164, 2, '2026-10-13', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (165, 1, '2026-10-14', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (166, 4, '2026-10-14', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (167, 3, '2026-10-15', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (168, 4, '2026-10-15', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (169, 1, '2026-10-16', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (170, 2, '2026-10-16', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (171, 3, '2026-10-16', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (172, 1, '2026-10-17', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (173, 3, '2026-10-17', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (174, 4, '2026-10-17', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (175, 2, '2026-10-18', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (176, 4, '2026-10-18', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (177, 2, '2026-10-19', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (178, 3, '2026-10-19', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (179, 1, '2026-10-20', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (180, 2, '2026-10-20', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (181, 1, '2026-10-21', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (182, 4, '2026-10-21', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (183, 3, '2026-10-22', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (184, 4, '2026-10-22', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (185, 1, '2026-10-23', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (186, 2, '2026-10-23', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (187, 3, '2026-10-23', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (188, 1, '2026-10-24', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (189, 3, '2026-10-24', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (190, 4, '2026-10-24', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (191, 2, '2026-10-25', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (192, 4, '2026-10-25', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (193, 2, '2026-10-26', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (194, 3, '2026-10-26', '13:00:00', '23:00:00', 'Atendimento e estoque'),
  (195, 1, '2026-10-27', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (196, 2, '2026-10-27', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (197, 1, '2026-10-28', '13:00:00', '23:00:00', 'Gerência e caixa'),
  (198, 4, '2026-10-28', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (199, 3, '2026-10-29', '13:00:00', '23:00:00', 'Atendimento e caixa'),
  (200, 4, '2026-10-29', '13:00:00', '23:00:00', 'Atendimento e estoque');
INSERT INTO escala (id_escala, id_funcionario, dt_turno, hr_inicio, hr_fim, ds_funcao) VALUES
  (201, 1, '2026-10-30', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (202, 2, '2026-10-30', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (203, 3, '2026-10-30', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (204, 1, '2026-10-31', '13:00:00', '00:00:00', 'Gerência e caixa'),
  (205, 3, '2026-10-31', '13:00:00', '00:00:00', 'Atendimento e caixa'),
  (206, 4, '2026-10-31', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (207, 2, '2026-11-01', '13:00:00', '00:00:00', 'Atendimento e estoque'),
  (208, 4, '2026-11-01', '13:00:00', '00:00:00', 'Atendimento e estoque');

-- ---------------------------------------------------------------------
-- 7) Compra inicial de estoque (27 a 31/07/2026): um pedido por fornecedor, recebido e conferido
-- ---------------------------------------------------------------------
SET TIMESTAMP = UNIX_TIMESTAMP('2026-07-27 10:32:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (1, 1, 1, '2026-07-27 10:32:00', 'ENTREGA', '2541.55', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (1, 1, 1, 64, 0, '3.10', 0),
  (2, 1, 2, 59, 0, '3.85', 0),
  (3, 1, 3, 28, 0, '2.40', 0),
  (4, 1, 4, 49, 0, '4.90', 0),
  (5, 1, 5, 47, 0, '6.80', 0),
  (6, 1, 6, 37, 0, '8.00', 0),
  (7, 1, 7, 27, 0, '6.70', 0),
  (8, 1, 8, 30, 0, '5.00', 0),
  (9, 1, 9, 7, 0, '12.50', 0),
  (10, 1, 10, 33, 0, '3.40', 0),
  (11, 1, 11, 21, 0, '7.80', 0),
  (12, 1, 12, 18, 0, '3.10', 0),
  (13, 1, 13, 15, 0, '6.60', 0),
  (14, 1, 14, 9, 0, '3.10', 0),
  (15, 1, 15, 28, 0, '1.60', 0),
  (16, 1, 16, 10, 0, '2.00', 0),
  (17, 1, 17, 7, 0, '6.20', 0),
  (18, 1, 18, 8, 0, '2.60', 0),
  (19, 1, 19, 19, 0, '6.20', 0),
  (20, 1, 20, 8, 0, '4.60', 0),
  (21, 1, 21, 6, 0, '5.40', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-07-28 14:30:00');
UPDATE compra SET st_compra = 'RECEBIDA_PARCIAL', dt_recebimento = '2026-07-28 14:30:00', nr_nota_fiscal = '760379' WHERE id_compra = 1;
UPDATE item_compra SET qt_recebida = 64, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 1;
UPDATE item_compra SET qt_recebida = 59, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 2;
UPDATE item_compra SET qt_recebida = 25, fl_conferido = 1, ds_divergencia = 'Produto trocado pelo fornecedor: 3 unidades não entregues' WHERE id_item_compra = 3;
UPDATE item_compra SET qt_recebida = 49, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 4;
UPDATE item_compra SET qt_recebida = 47, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 5;
UPDATE item_compra SET qt_recebida = 37, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 6;
UPDATE item_compra SET qt_recebida = 27, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 7;
UPDATE item_compra SET qt_recebida = 30, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 8;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 9;
UPDATE item_compra SET qt_recebida = 33, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 10;
UPDATE item_compra SET qt_recebida = 21, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 11;
UPDATE item_compra SET qt_recebida = 18, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 12;
UPDATE item_compra SET qt_recebida = 15, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 13;
UPDATE item_compra SET qt_recebida = 9, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 14;
UPDATE item_compra SET qt_recebida = 28, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 15;
UPDATE item_compra SET qt_recebida = 10, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 16;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 17;
UPDATE item_compra SET qt_recebida = 8, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 18;
UPDATE item_compra SET qt_recebida = 19, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 19;
UPDATE item_compra SET qt_recebida = 8, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 20;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 21;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (1, 1, 'L2607280101', '2027-01-10', 0),
  (2, 2, 'L2607280202', '2027-02-05', 0),
  (3, 3, 'L2607280303', '2027-03-16', 0),
  (4, 4, 'L2607280404', '2027-02-13', 0),
  (5, 5, 'L2607280505', '2027-02-05', 0),
  (6, 6, 'L2607280606', '2027-01-19', 0),
  (7, 7, 'L2607280707', '2027-02-27', 0),
  (8, 7, 'L2607280708', '2027-03-29', 0),
  (9, 8, 'L2607280809', '2027-03-20', 0),
  (10, 9, 'L2607280910', '2026-12-25', 0),
  (11, 9, 'L2607280911', '2027-01-20', 0),
  (12, 10, 'L2607281012', '2026-12-06', 0),
  (13, 11, 'L2607281113', '2027-01-20', 0),
  (14, 12, 'L2607281214', '2027-02-05', 0),
  (15, 13, 'L2607281315', '2026-12-08', 0),
  (16, 14, 'L2607281416', '2026-12-02', 0),
  (17, 14, 'L2607281417', '2027-01-11', 0),
  (18, 15, 'L2607281518', '2027-03-17', 0),
  (19, 16, 'L2607281619', '2027-05-08', 0),
  (20, 16, 'L2607281620', '2027-06-03', 0),
  (21, 17, 'L2607281721', '2026-10-20', 0),
  (22, 18, 'L2607281822', '2026-12-25', 0),
  (23, 19, 'L2607281923', '2026-12-26', 0),
  (24, 20, 'L2607282024', '2027-01-03', 0),
  (25, 21, 'L2607282125', '2026-11-21', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (1, 1, 1, 'ENTRADA_COMPRA', 64, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (2, 1, 2, 'ENTRADA_COMPRA', 59, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (3, 1, 3, 'ENTRADA_COMPRA', 25, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (4, 1, 4, 'ENTRADA_COMPRA', 49, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (5, 1, 5, 'ENTRADA_COMPRA', 47, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (6, 1, 6, 'ENTRADA_COMPRA', 37, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (7, 1, 7, 'ENTRADA_COMPRA', 13, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (7, 1, 8, 'ENTRADA_COMPRA', 14, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (8, 1, 9, 'ENTRADA_COMPRA', 30, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (9, 1, 10, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (9, 1, 11, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (10, 1, 12, 'ENTRADA_COMPRA', 33, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (11, 1, 13, 'ENTRADA_COMPRA', 21, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (12, 1, 14, 'ENTRADA_COMPRA', 18, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (13, 1, 15, 'ENTRADA_COMPRA', 15, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (14, 1, 16, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (14, 1, 17, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (15, 1, 18, 'ENTRADA_COMPRA', 28, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (16, 1, 19, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (16, 1, 20, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (17, 1, 21, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (18, 1, 22, 'ENTRADA_COMPRA', 8, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (19, 1, 23, 'ENTRADA_COMPRA', 19, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (20, 1, 24, 'ENTRADA_COMPRA', 8, 'Recebimento da compra 1');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (21, 1, 25, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 1');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-07-28 10:09:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (2, 2, 1, '2026-07-28 10:09:00', 'ENTREGA', '2403.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (22, 2, 22, 7, 0, '27.00', 0),
  (23, 2, 23, 6, 0, '66.00', 0),
  (24, 2, 24, 6, 0, '10.50', 0),
  (25, 2, 25, 8, 0, '45.00', 0),
  (26, 2, 26, 7, 0, '57.00', 0),
  (27, 2, 27, 8, 0, '23.50', 0),
  (28, 2, 28, 6, 0, '21.00', 0),
  (29, 2, 29, 6, 0, '30.00', 0),
  (30, 2, 30, 6, 0, '24.00', 0),
  (31, 2, 31, 7, 0, '38.00', 0),
  (32, 2, 32, 8, 0, '11.50', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-07-29 14:30:00');
UPDATE compra SET st_compra = 'RECEBIDA_PARCIAL', dt_recebimento = '2026-07-29 14:30:00', nr_nota_fiscal = '562866' WHERE id_compra = 2;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 22;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 23;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 24;
UPDATE item_compra SET qt_recebida = 8, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 25;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 26;
UPDATE item_compra SET qt_recebida = 8, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 27;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 28;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 29;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 30;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 31;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = '1 unidades avariadas, devolvidas ao fornecedor' WHERE id_item_compra = 32;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (26, 22, 'L2607292226', '2027-12-21', 0),
  (27, 23, 'L2607292327', '2027-12-15', 0),
  (28, 24, 'L2607292428', '2028-04-03', 0),
  (29, 25, 'L2607292529', '2028-04-10', 0),
  (30, 26, 'L2607292630', '2028-06-08', 0),
  (31, 26, 'L2607292631', '2028-07-08', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (22, 1, 26, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 2');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (23, 1, 27, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 2');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (24, 1, 28, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 2');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (25, 1, 29, 'ENTRADA_COMPRA', 8, 'Recebimento da compra 2');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (26, 1, 30, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 2');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (26, 1, 31, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 2');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (27, 1, NULL, 'ENTRADA_COMPRA', 8, 'Recebimento da compra 2');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (28, 1, NULL, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 2');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (29, 1, NULL, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 2');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (30, 1, NULL, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 2');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (31, 1, NULL, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 2');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (32, 1, NULL, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 2');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-07-29 10:23:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (3, 3, 1, '2026-07-29 10:23:00', 'RETIRADA', '813.10', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (33, 3, 33, 19, 0, '10.20', 0),
  (34, 3, 34, 13, 0, '11.90', 0),
  (35, 3, 35, 6, 0, '11.00', 0),
  (36, 3, 36, 10, 0, '14.50', 0),
  (37, 3, 37, 12, 0, '16.50', 0),
  (38, 3, 38, 8, 0, '3.20', 0),
  (39, 3, 50, 15, 0, '2.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-07-29 17:00:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-07-29 17:00:00', nr_nota_fiscal = '988774' WHERE id_compra = 3;
UPDATE item_compra SET qt_recebida = 19, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 33;
UPDATE item_compra SET qt_recebida = 13, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 34;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 35;
UPDATE item_compra SET qt_recebida = 10, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 36;
UPDATE item_compra SET qt_recebida = 12, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 37;
UPDATE item_compra SET qt_recebida = 8, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 38;
UPDATE item_compra SET qt_recebida = 15, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 39;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (33, 1, NULL, 'ENTRADA_COMPRA', 19, 'Recebimento da compra 3');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (34, 1, NULL, 'ENTRADA_COMPRA', 13, 'Recebimento da compra 3');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (35, 1, NULL, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 3');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (36, 1, NULL, 'ENTRADA_COMPRA', 10, 'Recebimento da compra 3');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (37, 1, NULL, 'ENTRADA_COMPRA', 12, 'Recebimento da compra 3');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (38, 1, NULL, 'ENTRADA_COMPRA', 8, 'Recebimento da compra 3');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (50, 1, NULL, 'ENTRADA_COMPRA', 15, 'Recebimento da compra 3');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-07-30 10:36:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (4, 4, 1, '2026-07-30 10:36:00', 'ENTREGA', '545.70', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (40, 4, 39, 18, 0, '4.60', 0),
  (41, 4, 40, 15, 0, '5.40', 0),
  (42, 4, 41, 15, 0, '4.20', 0),
  (43, 4, 42, 17, 0, '4.00', 0),
  (44, 4, 43, 16, 0, '3.10', 0),
  (45, 4, 44, 15, 0, '1.80', 0),
  (46, 4, 45, 13, 0, '0.50', 0),
  (47, 4, 46, 14, 0, '3.90', 0),
  (48, 4, 47, 14, 0, '0.80', 0),
  (49, 4, 48, 10, 0, '2.50', 0),
  (50, 4, 51, 7, 0, '5.00', 0),
  (51, 4, 53, 6, 0, '5.80', 0),
  (52, 4, 54, 6, 0, '1.20', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-07-31 14:30:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-07-31 14:30:00', nr_nota_fiscal = '751151' WHERE id_compra = 4;
UPDATE item_compra SET qt_recebida = 18, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 40;
UPDATE item_compra SET qt_recebida = 15, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 41;
UPDATE item_compra SET qt_recebida = 15, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 42;
UPDATE item_compra SET qt_recebida = 17, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 43;
UPDATE item_compra SET qt_recebida = 16, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 44;
UPDATE item_compra SET qt_recebida = 15, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 45;
UPDATE item_compra SET qt_recebida = 13, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 46;
UPDATE item_compra SET qt_recebida = 14, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 47;
UPDATE item_compra SET qt_recebida = 14, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 48;
UPDATE item_compra SET qt_recebida = 10, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 49;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 50;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 51;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 52;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (32, 40, 'L2607313932', '2026-10-01', 0),
  (33, 41, 'L2607314033', '2026-10-04', 0),
  (34, 42, 'L2607314134', '2026-12-18', 0),
  (35, 43, 'L2607314235', '2027-01-14', 0),
  (36, 44, 'L2607314336', '2027-02-19', 0),
  (37, 45, 'L2607314437', '2027-01-22', 0),
  (38, 46, 'L2607314538', '2027-04-17', 0),
  (39, 47, 'L2607314639', '2026-11-25', 0),
  (40, 48, 'L2607314740', '2026-11-08', 0),
  (41, 48, 'L2607314741', '2026-12-14', 0),
  (42, 49, 'L2607314842', '2026-11-25', 0),
  (43, 49, 'L2607314843', '2026-12-16', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (39, 1, 32, 'ENTRADA_COMPRA', 18, 'Recebimento da compra 4');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (40, 1, 33, 'ENTRADA_COMPRA', 15, 'Recebimento da compra 4');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (41, 1, 34, 'ENTRADA_COMPRA', 15, 'Recebimento da compra 4');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (42, 1, 35, 'ENTRADA_COMPRA', 17, 'Recebimento da compra 4');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (43, 1, 36, 'ENTRADA_COMPRA', 16, 'Recebimento da compra 4');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (44, 1, 37, 'ENTRADA_COMPRA', 15, 'Recebimento da compra 4');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (45, 1, 38, 'ENTRADA_COMPRA', 13, 'Recebimento da compra 4');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (46, 1, 39, 'ENTRADA_COMPRA', 14, 'Recebimento da compra 4');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (47, 1, 40, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 4');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (47, 1, 41, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 4');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (48, 1, 42, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 4');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (48, 1, 43, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 4');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (51, 1, NULL, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 4');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (53, 1, NULL, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 4');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (54, 1, NULL, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 4');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-07-31 10:33:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (5, 5, 1, '2026-07-31 10:33:00', 'RETIRADA', '470.70', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (53, 5, 49, 20, 0, '6.50', 0),
  (54, 5, 52, 7, 0, '14.00', 0),
  (55, 5, 55, 7, 0, '4.00', 0),
  (56, 5, 56, 6, 0, '6.50', 0),
  (57, 5, 57, 7, 0, '9.50', 0),
  (58, 5, 58, 6, 0, '4.60', 0),
  (59, 5, 59, 8, 0, '4.40', 0),
  (60, 5, 60, 8, 0, '5.80', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-07-31 17:00:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-07-31 17:00:00', nr_nota_fiscal = '118116' WHERE id_compra = 5;
UPDATE item_compra SET qt_recebida = 20, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 53;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 54;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 55;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 56;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 57;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 58;
UPDATE item_compra SET qt_recebida = 8, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 59;
UPDATE item_compra SET qt_recebida = 8, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 60;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (44, 59, 'L2607315944', '2026-09-01', 0),
  (45, 60, 'L2607316045', '2026-08-11', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (49, 1, NULL, 'ENTRADA_COMPRA', 20, 'Recebimento da compra 5');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (52, 1, NULL, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 5');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (55, 1, NULL, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 5');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (56, 1, NULL, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 5');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (57, 1, NULL, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 5');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (58, 1, NULL, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 5');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (59, 1, 44, 'ENTRADA_COMPRA', 8, 'Recebimento da compra 5');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 1, 45, 'ENTRADA_COMPRA', 8, 'Recebimento da compra 5');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-07-20 10:00:00');
INSERT INTO cliente (id_cliente, nm_cliente, nr_cpf, dt_nascimento, nr_telefone, vl_limite_fiado, dt_consentimento_lgpd, dt_cadastro) VALUES (1, 'Anderson Ribeiro Costa', '91000000001', '1988-04-12', '(11) 99000-0001', '0.00', '2026-07-20 10:00:00', '2026-07-20 10:00:00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-07-20 10:05:00');
CALL sp_autorizar_cliente_fiado(1, 300.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-07-20 10:00:00');
INSERT INTO cliente (id_cliente, nm_cliente, nr_cpf, dt_nascimento, nr_telefone, vl_limite_fiado, dt_consentimento_lgpd, dt_cadastro) VALUES (3, 'Cláudio Ferraz Andrade', '91000000003', '1979-01-28', '(11) 99000-0003', '0.00', '2026-07-20 10:00:00', '2026-07-20 10:00:00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-07-20 10:05:00');
CALL sp_autorizar_cliente_fiado(3, 500.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-07-22 10:00:00');
INSERT INTO cliente (id_cliente, nm_cliente, nr_cpf, dt_nascimento, nr_telefone, vl_limite_fiado, dt_consentimento_lgpd, dt_cadastro) VALUES (2, 'Beatriz Fontes Moraes', '91000000002', '1995-09-03', '(11) 99000-0002', '0.00', '2026-07-22 10:00:00', '2026-07-22 10:00:00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-07-22 10:05:00');
CALL sp_autorizar_cliente_fiado(2, 200.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-02 10:00:00');
INSERT INTO cliente (id_cliente, nm_cliente, nr_cpf, dt_nascimento, nr_telefone, vl_limite_fiado, dt_consentimento_lgpd, dt_cadastro) VALUES (4, 'Daniela Matos Pires', '91000000004', '2000-11-17', '(11) 99000-0004', '0.00', '2026-08-02 10:00:00', '2026-08-02 10:00:00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-02 10:05:00');
CALL sp_autorizar_cliente_fiado(4, 150.00);

-- ---------------------------------------------------------------------
-- 8) Dia a dia: cada dia abre o caixa, vende, lança fiado, recebe fiado, repõe estoque e fecha o caixa
-- ---------------------------------------------------------------------

-- ===== 03/08/2026 (segunda) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-03 12:48:23');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-03 12:43:09');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-03 12:59:00');
SET @id_funcionario_logado = 3;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (1, 3, '2026-08-03 12:59:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-03 15:30:11');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (1, 3, 1, '2026-08-03 15:30:11', '0.00', '19.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1, 1, 49, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (2, 1, 39, 32, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (1, 'DINHEIRO', 11.40),
  (1, 'CREDITO', 7.60);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-03 16:30:07');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (2, 3, 1, '2026-08-03 16:30:07', '0.00', '9.00', 'CONCLUIDA', '106963', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (3, 2, 1, 1, NULL, 'UNIDADE', 2, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (2, 'PIX', 9.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-03 19:24:08');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (3, 2, 1, '2026-08-03 19:24:08', '0.00', '8.50', 'CONCLUIDA', '522238', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (4, 3, 60, 45, NULL, 'UNIDADE', 1, '8.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (3, 'PIX', 8.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-03 19:50:00');
SET @id_funcionario_logado = 3;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (1, 1, 3, 'DESPESA', '35.00', 'Sacolas e embalagens');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-03 20:12:28');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (4, 2, 1, '2026-08-03 20:12:28', '0.00', '30.00', 'CONCLUIDA', '296229', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (5, 4, 49, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (6, 4, 17, 21, NULL, 'UNIDADE', 2, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (4, 'PIX', 30.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-03 20:18:17');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (5, 3, 1, '2026-08-03 20:18:17', '0.00', '30.50', 'CONCLUIDA', '959386', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (7, 5, 35, NULL, NULL, 'UNIDADE', 2, '13.00'),
  (8, 5, 1, 1, NULL, 'UNIDADE', 1, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (5, 'DEBITO', 30.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-03 21:46:01');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (6, 2, 1, '2026-08-03 21:46:01', '0.00', '19.00', 'CONCLUIDA', '147267', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (9, 6, 7, 7, NULL, 'UNIDADE', 2, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (6, 'DEBITO', 19.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-03 23:05:00');
SET @id_funcionario_logado = 3;
CALL sp_fechar_caixa(1, 79.40);
UPDATE caixa SET ds_observacao = 'Sobrou R$ 3.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 1;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-03 23:07:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '1', '{"diferenca": "3.00"}', '192.168.0.11');

-- ===== 04/08/2026 (terça) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-04 12:49:57');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-04 12:45:23');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-04 12:51:00');
SET @id_funcionario_logado = 2;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (2, 2, '2026-08-04 12:51:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-04 15:31:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (2, 2, 2, 'DESPESA', '35.00', 'Café e água dos funcionários');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-04 19:04:38');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (7, 1, 2, '2026-08-04 19:04:38', '0.00', '4.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (10, 7, 1, 1, NULL, 'UNIDADE', 1, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (7, 'PIX', 4.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-04 19:32:35');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (8, 2, 2, '2026-08-04 19:32:35', '0.00', '11.00', 'CONCLUIDA', '618742', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (11, 8, 2, 2, NULL, 'UNIDADE', 2, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (8, 'PIX', 5.50),
  (8, 'DEBITO', 5.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-04 20:11:03');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (9, 1, 2, '2026-08-04 20:11:03', '0.00', '43.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (12, 9, 17, 21, NULL, 'UNIDADE', 3, '9.00'),
  (13, 9, 20, 24, NULL, 'UNIDADE', 1, '7.00'),
  (14, 9, 1, 1, NULL, 'UNIDADE', 2, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (9, 'DEBITO', 43.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-04 21:52:39');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (10, 1, 2, '2026-08-04 21:52:39', '0.00', '3.00', 'CONCLUIDA', '908514', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (15, 10, 15, 18, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (10, 'PIX', 3.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-04 23:05:00');
SET @id_funcionario_logado = 2;
CALL sp_fechar_caixa(2, 170.00);
UPDATE caixa SET ds_observacao = 'Sobrou R$ 5.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 2;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-04 23:07:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '2', '{"diferenca": "5.00"}', '192.168.0.11');

-- ===== 05/08/2026 (quarta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-05 10:00:00');
SET @id_funcionario_logado = 1;
INSERT INTO cliente (id_cliente, nm_cliente, nr_cpf, dt_nascimento, nr_telefone, vl_limite_fiado, dt_consentimento_lgpd, dt_cadastro) VALUES (5, 'Eduardo Salgado Neto', '91000000005', '1992-06-30', '(11) 99000-0005', '0.00', '2026-08-05 10:00:00', '2026-08-05 10:00:00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-05 10:05:00');
CALL sp_autorizar_cliente_fiado(5, 250.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-05 10:00:00');
INSERT INTO cliente (id_cliente, nm_cliente, nr_cpf, dt_nascimento, nr_telefone, vl_limite_fiado, dt_consentimento_lgpd, dt_cadastro) VALUES (6, 'Fernanda Quintela Rocha', '91000000006', '1985-12-09', '(11) 99000-0006', '0.00', '2026-08-05 10:00:00', '2026-08-05 10:00:00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-05 10:05:00');
CALL sp_autorizar_cliente_fiado(6, 200.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-05 12:44:23');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-05 12:44:28');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-05 12:54:00');
SET @id_funcionario_logado = 4;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (3, 4, '2026-08-05 12:54:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-05 14:48:02');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (11, 1, 3, '2026-08-05 14:48:02', '0.00', '18.50', 'CONCLUIDA', '898305', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (16, 11, 3, 3, NULL, 'UNIDADE', 4, '3.50'),
  (17, 11, 1, 1, NULL, 'UNIDADE', 1, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (11, 'DEBITO', 18.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-05 18:18:36');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (12, 1, 3, '2026-08-05 18:18:36', '0.00', '57.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (18, 12, 37, NULL, NULL, 'UNIDADE', 1, '25.00'),
  (19, 12, 24, 28, NULL, 'UNIDADE', 2, '16.00');
CALL sp_registrar_venda_fiado(12, 3, '2026-09-04', 57.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-05 19:42:08');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (13, 4, 3, '2026-08-05 19:42:08', '0.00', '30.00', 'CONCLUIDA', '274544', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (20, 13, 11, 13, NULL, 'UNIDADE', 1, '11.00'),
  (21, 13, 7, 7, NULL, 'UNIDADE', 2, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (13, 'DINHEIRO', 30.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-05 19:59:40');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (14, 1, 3, '2026-08-05 19:59:40', '0.00', '26.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (22, 14, 19, 23, NULL, 'UNIDADE', 2, '9.00'),
  (23, 14, 21, 25, NULL, 'UNIDADE', 1, '8.00');
CALL sp_registrar_venda_fiado(14, 6, '2026-09-04', 26.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-05 20:41:31');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (15, 4, 3, '2026-08-05 20:41:31', '0.00', '3.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (24, 15, 15, 18, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (15, 'PIX', 3.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-05 22:42:33');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (16, 1, 3, '2026-08-05 22:42:33', '0.00', '9.00', 'CONCLUIDA', '153112', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (25, 16, 1, 1, NULL, 'UNIDADE', 2, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (16, 'PIX', 9.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-05 23:05:00');
SET @id_funcionario_logado = 4;
CALL sp_fechar_caixa(3, 180.00);

-- ===== 06/08/2026 (quinta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-06 12:42:43');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-06 12:45:45');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-06 12:50:00');
SET @id_funcionario_logado = 3;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (4, 3, '2026-08-06 12:50:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-06 14:56:33');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (17, 3, 4, '2026-08-06 14:56:33', '0.00', '57.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (26, 17, 7, 7, NULL, 'UNIDADE', 6, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (17, 'DEBITO', 57.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-06 15:40:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (3, 4, 3, 'DESPESA', '20.00', 'Sacolas e embalagens');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-06 16:23:05');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (18, 4, 4, '2026-08-06 16:23:05', '0.00', '11.00', 'CONCLUIDA', '949842', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (27, 18, 2, 2, NULL, 'UNIDADE', 2, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (18, 'PIX', 11.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-06 20:01:36');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (19, 4, 4, '2026-08-06 20:01:36', '0.00', '20.00', 'CONCLUIDA', '122723', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (28, 19, 51, NULL, NULL, 'UNIDADE', 1, '8.00'),
  (29, 19, 49, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (19, 'DEBITO', 20.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-06 20:17:48');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (20, 4, 4, '2026-08-06 20:17:48', '0.00', '32.50', 'CONCLUIDA', '947979', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (30, 20, 41, 34, NULL, 'UNIDADE', 5, '6.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (20, 'DINHEIRO', 32.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-06 20:33:17');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (21, 3, 4, '2026-08-06 20:33:17', '0.00', '87.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (31, 21, 37, NULL, NULL, 'UNIDADE', 2, '25.00'),
  (32, 21, 24, 28, NULL, 'UNIDADE', 1, '16.00'),
  (33, 21, 14, 16, NULL, 'UNIDADE', 2, '4.50'),
  (34, 21, 33, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (21, 'DINHEIRO', 50.00);
CALL sp_registrar_venda_fiado(21, 6, '2026-09-05', 37.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-06 20:43:23');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (22, 4, 4, '2026-08-06 20:43:23', '0.00', '14.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (35, 22, 3, 3, NULL, 'UNIDADE', 4, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (22, 'CREDITO', 14.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-06 22:10:42');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (23, 3, 4, '2026-08-06 22:10:42', '0.00', '14.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (36, 23, 57, NULL, NULL, 'UNIDADE', 1, '14.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (23, 'PIX', 14.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-06 23:05:00');
CALL sp_fechar_caixa(4, 211.50);
UPDATE caixa SET ds_observacao = 'Faltou R$ 1.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 4;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-06 23:07:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '4', '{"diferenca": "-1.00"}', '192.168.0.11');

-- ===== 07/08/2026 (sexta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-07 12:42:40');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-07 12:48:57');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-07 12:42:08');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-07 12:50:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (5, 3, '2026-08-07 12:50:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-07 10:30:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (6, 1, 1, '2026-08-07 10:30:00', 'ENTREGA', '24.80', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (61, 6, 17, 4, 0, '6.20', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-07 13:14:35');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (24, 3, 5, '2026-08-07 13:14:35', '0.00', '42.00', 'CONCLUIDA', '918417', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (37, 24, 8, 9, NULL, 'UNIDADE', 6, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (24, 'DINHEIRO', 42.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-07 15:11:02');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (25, 2, 5, '2026-08-07 15:11:02', '0.00', '13.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (38, 25, 44, 37, NULL, 'UNIDADE', 3, '3.00'),
  (39, 25, 50, NULL, NULL, 'UNIDADE', 1, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (25, 'PIX', 13.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-07 15:40:12');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (26, 3, 5, '2026-08-07 15:40:12', '0.00', '7.00', 'CONCLUIDA', '319155', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (40, 26, 39, 32, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (26, 'DINHEIRO', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-07 16:03:00');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (49, 1, NULL, 'PERDA', 3, 'Caiu no chão durante a reposição');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-07 16:04:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '108', '{"tipo": "PERDA", "motivo": "Caiu no chão durante a reposição", "quantidade": 3}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-07 17:14:09');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (27, 2, 5, '2026-08-07 17:14:09', '0.00', '14.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (41, 27, 34, NULL, NULL, 'UNIDADE', 1, '14.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (27, 'DINHEIRO', 14.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-07 17:26:00');
SET @id_funcionario_logado = 3;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (4, 5, 3, 'DESPESA', '50.00', 'Café e água dos funcionários');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-07 17:32:35');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (28, 1, 5, '2026-08-07 17:32:35', '0.00', '19.00', 'CONCLUIDA', '178065', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (42, 28, 7, 7, NULL, 'UNIDADE', 2, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (28, 'PIX', 19.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-07 19:04:24');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (29, 3, 5, '2026-08-07 19:04:24', '0.00', '36.00', 'CONCLUIDA', '289504', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (43, 29, 30, NULL, NULL, 'UNIDADE', 1, '36.00');
CALL sp_registrar_venda_fiado(29, 2, '2026-09-06', 36.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-07 19:49:08');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (30, 3, 5, '2026-08-07 19:49:08', '0.00', '38.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (44, 30, 49, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (45, 30, 1, 1, NULL, 'UNIDADE', 4, '4.50'),
  (46, 30, 48, 42, NULL, 'UNIDADE', 2, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (30, 'DEBITO', 38.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-07 20:21:20');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (31, 1, 5, '2026-08-07 20:21:20', '0.00', '22.00', 'CONCLUIDA', '823856', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (47, 31, 36, NULL, NULL, 'UNIDADE', 1, '22.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (31, 'CREDITO', 11.00),
  (31, 'DINHEIRO', 11.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-07 21:00:00');
SET @id_funcionario_logado = 3;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (5, 5, 3, 'SANGRIA', '100.00', 'Sangria: retirada do excesso de dinheiro do caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-07 21:44:06');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (32, 3, 5, '2026-08-07 21:44:06', '0.00', '78.00', 'CONCLUIDA', '450336', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (48, 32, 12, 14, NULL, 'UNIDADE', 1, '4.50'),
  (49, 32, 47, 40, NULL, 'UNIDADE', 3, '1.50'),
  (50, 32, 5, 5, NULL, 'UNIDADE', 6, '9.50'),
  (51, 32, 42, 35, NULL, 'UNIDADE', 2, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (32, 'DINHEIRO', 31.20),
  (32, 'CREDITO', 46.80);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-07 21:59:34');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (33, 1, 5, '2026-08-07 21:59:34', '0.00', '94.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (52, 33, 40, 33, NULL, 'UNIDADE', 5, '8.00'),
  (53, 33, 1, 1, NULL, 'UNIDADE', 12, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (33, 'CREDITO', 56.40),
  (33, 'DEBITO', 37.60);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-08 00:08:00');
SET @id_funcionario_logado = 3;
CALL sp_fechar_caixa(5, 105.20);

-- ===== 08/08/2026 (sábado) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-08 12:41:41');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-08 12:49:05');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-08 12:41:02');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-08 12:59:00');
SET @id_funcionario_logado = 1;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (6, 1, '2026-08-08 12:59:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-08 14:30:00');
SET @id_funcionario_logado = 3;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-08-08 14:30:00', nr_nota_fiscal = '799215' WHERE id_compra = 6;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 61;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (46, 61, 'L2608081746', '2026-11-05', 0),
  (47, 61, 'L2608081747', '2026-12-06', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (17, 3, 46, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 6');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (17, 3, 47, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 6');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-08 18:10:54');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (34, 3, 6, '2026-08-08 18:10:54', '0.00', '34.00', 'CONCLUIDA', '567822', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (54, 34, 4, 4, NULL, 'UNIDADE', 1, '7.00'),
  (55, 34, 1, 1, NULL, 'UNIDADE', 6, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (34, 'PIX', 34.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-08 19:08:00');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (6, 6, 1, 'DESPESA', '35.00', 'Compra de gelo para o balcão');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-08 19:24:05');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (35, 3, 6, '2026-08-08 19:24:05', '0.00', '62.00', 'CONCLUIDA', '157639', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (56, 35, 40, 33, NULL, 'UNIDADE', 3, '8.00'),
  (57, 35, 38, NULL, NULL, 'UNIDADE', 1, '6.00'),
  (58, 35, 11, 13, NULL, 'UNIDADE', 1, '11.00'),
  (59, 35, 4, 4, NULL, 'UNIDADE', 3, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (35, 'PIX', 62.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-08 19:50:41');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (36, 3, 6, '2026-08-08 19:50:41', '0.00', '19.00', 'CONCLUIDA', '863095', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (60, 36, 5, 5, NULL, 'UNIDADE', 2, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (36, 'DEBITO', 7.60),
  (36, 'DINHEIRO', 11.40);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-08 19:52:34');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (37, 3, 6, '2026-08-08 19:52:34', '0.00', '44.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (61, 37, 36, NULL, NULL, 'UNIDADE', 2, '22.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (37, 'DINHEIRO', 44.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-08 19:59:52');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (38, 3, 6, '2026-08-08 19:59:52', '0.00', '7.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (62, 38, 4, 4, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (38, 'DEBITO', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-08 20:04:32');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (39, 4, 6, '2026-08-08 20:04:32', '0.00', '24.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (63, 39, 49, NULL, NULL, 'UNIDADE', 2, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (39, 'DINHEIRO', 24.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-08 20:52:58');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (40, 4, 6, '2026-08-08 20:52:58', '0.00', '38.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (64, 40, 28, NULL, NULL, 'UNIDADE', 1, '32.00'),
  (65, 40, 42, 35, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (40, 'DINHEIRO', 38.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-08 21:00:00');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (7, 6, 1, 'SANGRIA', '150.00', 'Sangria: retirada do excesso de dinheiro do caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-08 21:04:53');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (41, 4, 6, '2026-08-08 21:04:53', '0.00', '12.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (66, 41, 49, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (41, 'CREDITO', 7.20),
  (41, 'DEBITO', 4.80);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-08 21:27:25');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (42, 1, 6, '2026-08-08 21:27:25', '0.00', '38.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (67, 42, 13, 15, NULL, 'UNIDADE', 3, '9.50'),
  (68, 42, 20, 24, NULL, 'UNIDADE', 1, '7.00'),
  (69, 42, 44, 37, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (42, 'DINHEIRO', 38.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-08 22:14:47');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (43, 4, 6, '2026-08-08 22:14:47', '0.00', '83.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (70, 43, 3, 3, NULL, 'UNIDADE', 6, '3.50'),
  (71, 43, 25, 29, NULL, 'UNIDADE', 1, '62.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (43, 'PIX', 83.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-08 22:48:31');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (44, 4, 6, '2026-08-08 22:48:31', '0.00', '89.00', 'CONCLUIDA', '291868', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (72, 44, 23, 27, NULL, 'UNIDADE', 1, '89.00');
CALL sp_registrar_venda_fiado(44, 6, '2026-09-07', 89.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-09 00:08:00');
SET @id_funcionario_logado = 1;
CALL sp_fechar_caixa(6, 120.90);

-- ===== 09/08/2026 (domingo) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-09 12:47:08');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-09 12:43:43');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-09 12:55:00');
SET @id_funcionario_logado = 4;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (7, 4, '2026-08-09 12:55:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-09 13:22:57');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (45, 4, 7, '2026-08-09 13:22:57', '0.00', '12.00', 'CONCLUIDA', '269733', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (73, 45, 49, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (45, 'PIX', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-09 14:34:00');
CALL sp_registrar_evento_acesso(4, 'CONSULTA_DADO_PESSOAL', 'cliente', '6', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-09 14:36:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (1, 5, 7, 'DINHEIRO', '89.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-09 15:28:28');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (46, 2, 7, '2026-08-09 15:28:28', '0.00', '26.00', 'CONCLUIDA', '434173', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (74, 46, 35, NULL, NULL, 'UNIDADE', 2, '13.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (46, 'DINHEIRO', 26.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-09 16:13:29');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (47, 2, 7, '2026-08-09 16:13:29', '0.00', '90.50', 'CONCLUIDA', '753058', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (75, 47, 42, 35, NULL, 'UNIDADE', 2, '6.00'),
  (76, 47, 40, 33, NULL, 'UNIDADE', 5, '8.00'),
  (77, 47, 3, 3, NULL, 'UNIDADE', 11, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (47, 'DINHEIRO', 90.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-09 17:45:40');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (48, 2, 7, '2026-08-09 17:45:40', '0.00', '8.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (78, 48, 40, 33, NULL, 'UNIDADE', 1, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (48, 'DINHEIRO', 8.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-09 18:37:26');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (49, 4, 7, '2026-08-09 18:37:26', '0.00', '4.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (79, 49, 50, NULL, NULL, 'UNIDADE', 1, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (49, 'PIX', 4.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-09 19:23:23');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (50, 4, 7, '2026-08-09 19:23:23', '0.00', '32.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (80, 50, 21, 25, NULL, 'UNIDADE', 1, '8.00'),
  (81, 50, 33, NULL, NULL, 'UNIDADE', 2, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (50, 'CREDITO', 32.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-09 22:01:38');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (51, 4, 7, '2026-08-09 22:01:38', '0.00', '18.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (82, 51, 42, 35, NULL, 'UNIDADE', 3, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (51, 'DEBITO', 18.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-10 00:08:00');
CALL sp_fechar_caixa(7, 313.50);

-- ===== 10/08/2026 (segunda) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-10 12:45:05');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-10 12:48:52');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-10 12:52:00');
SET @id_funcionario_logado = 2;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (8, 2, '2026-08-10 12:52:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-10 10:03:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (7, 3, 1, '2026-08-10 10:03:00', 'RETIRADA', '44.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (62, 7, 35, 4, 0, '11.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-10 10:14:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (8, 5, 1, '2026-08-10 10:14:00', 'RETIRADA', '39.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (63, 8, 49, 6, 0, '6.50', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-10 14:49:26');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (52, 2, 8, '2026-08-10 14:49:26', '0.00', '140.00', 'CONCLUIDA', '967997', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (83, 52, 22, 26, NULL, 'UNIDADE', 1, '38.00'),
  (84, 52, 15, 18, NULL, 'UNIDADE', 2, '3.00'),
  (85, 52, 14, 16, NULL, 'UNIDADE', 1, '4.50'),
  (86, 52, 23, 27, NULL, 'UNIDADE', 1, '89.00'),
  (87, 52, 54, NULL, NULL, 'UNIDADE', 1, '2.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (52, 'CREDITO', 6.00);
CALL sp_registrar_venda_fiado(52, 3, '2026-09-09', 134.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-10 17:00:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-08-10 17:00:00', nr_nota_fiscal = '834485' WHERE id_compra = 7;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 62;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (35, 2, NULL, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 7');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-08-10 17:00:00', nr_nota_fiscal = '923923' WHERE id_compra = 8;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 63;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (49, 2, NULL, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 8');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-10 18:14:30');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (53, 2, 8, '2026-08-10 18:14:30', '0.00', '26.00', 'CONCLUIDA', '494198', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (88, 53, 4, 4, NULL, 'UNIDADE', 2, '7.00'),
  (89, 53, 49, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (53, 'DEBITO', 26.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-10 19:48:16');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (54, 2, 8, '2026-08-10 19:48:16', '0.00', '17.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (90, 54, 4, 4, NULL, 'UNIDADE', 2, '7.00'),
  (91, 54, 16, 19, NULL, 'UNIDADE', 1, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (54, 'DINHEIRO', 17.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-10 20:35:55');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (55, 2, 8, '2026-08-10 20:35:55', '0.00', '68.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (92, 55, 10, 12, NULL, 'UNIDADE', 1, '5.00'),
  (93, 55, 7, 7, NULL, 'UNIDADE', 1, '9.50'),
  (94, 55, 7, 8, NULL, 'UNIDADE', 2, '9.50'),
  (95, 55, 39, 32, NULL, 'UNIDADE', 2, '7.00'),
  (96, 55, 8, 9, NULL, 'UNIDADE', 3, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (55, 'DINHEIRO', 68.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-10 22:00:04');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (56, 2, 8, '2026-08-10 22:00:04', '0.00', '15.00', 'CONCLUIDA', '223092', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (97, 56, 10, 12, NULL, 'UNIDADE', 3, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (56, 'PIX', 15.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-10 22:31:46');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (57, 3, 8, '2026-08-10 22:31:46', '0.00', '41.50', 'CONCLUIDA', '849287', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (98, 57, 55, NULL, NULL, 'UNIDADE', 1, '6.00'),
  (99, 57, 19, 23, NULL, 'UNIDADE', 2, '9.00'),
  (100, 57, 45, 38, NULL, 'UNIDADE', 2, '1.00'),
  (101, 57, 2, 2, NULL, 'UNIDADE', 2, '5.50'),
  (102, 57, 14, 16, NULL, 'UNIDADE', 1, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (57, 'DINHEIRO', 41.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-10 23:05:00');
SET @id_funcionario_logado = 2;
CALL sp_fechar_caixa(8, 227.50);

-- ===== 11/08/2026 (terça) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-11 12:42:16');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-11 12:43:56');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-11 12:55:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (9, 2, '2026-08-11 12:55:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-11 10:23:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (9, 1, 1, '2026-08-11 10:23:00', 'ENTREGA', '244.90', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (64, 9, 1, 27, 0, '3.10', 0),
  (65, 9, 3, 24, 0, '2.40', 0),
  (66, 9, 7, 12, 0, '6.70', 0),
  (67, 9, 14, 4, 0, '3.10', 0),
  (68, 9, 21, 2, 0, '5.40', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-11 13:30:21');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (58, 2, 9, '2026-08-11 13:30:21', '0.00', '56.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (103, 58, 45, 38, NULL, 'UNIDADE', 2, '1.00'),
  (104, 58, 37, NULL, NULL, 'UNIDADE', 2, '25.00'),
  (105, 58, 18, 22, NULL, 'UNIDADE', 1, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (58, 'PIX', 56.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-11 17:43:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (8, 9, 2, 'DESPESA', '15.00', 'Compra de gelo para o balcão');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-11 18:36:33');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (59, 1, 9, '2026-08-11 18:36:33', '0.00', '6.00', 'CONCLUIDA', '157503', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (106, 59, 42, 35, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (59, 'DEBITO', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-11 18:46:00');
CALL sp_registrar_evento_acesso(1, 'CONSULTA_DADO_PESSOAL', 'cliente', '3', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-11 18:48:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (2, 1, 9, 'PIX', '20.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-11 21:15:03');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (60, 1, 9, '2026-08-11 21:15:03', '0.00', '95.00', 'CONCLUIDA', '261584', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (107, 60, 4, 4, NULL, 'UNIDADE', 2, '7.00'),
  (108, 60, 37, NULL, NULL, 'UNIDADE', 2, '25.00'),
  (109, 60, 41, 34, NULL, 'UNIDADE', 2, '6.50'),
  (110, 60, 1, 1, NULL, 'UNIDADE', 4, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (60, 'PIX', 95.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-11 21:53:21');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (61, 1, 9, '2026-08-11 21:53:21', '3.00', '113.00', 'CONCLUIDA', '112156', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (111, 61, 2, 2, NULL, 'UNIDADE', 2, '5.50'),
  (112, 61, 42, 35, NULL, 'UNIDADE', 1, '6.00'),
  (113, 61, 1, 1, NULL, 'UNIDADE', 6, '4.50'),
  (114, 61, 34, NULL, NULL, 'UNIDADE', 2, '14.00'),
  (115, 61, 6, 6, NULL, 'UNIDADE', 4, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (61, 'DINHEIRO', 113.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-11 22:31:54');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (62, 2, 9, '2026-08-11 22:31:54', '0.00', '43.00', 'CONCLUIDA', '475690', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (116, 62, 43, 36, NULL, 'UNIDADE', 1, '5.00'),
  (117, 62, 5, 5, NULL, 'UNIDADE', 4, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (62, 'DEBITO', 43.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-11 23:05:00');
CALL sp_fechar_caixa(9, 248.00);

-- ===== 12/08/2026 (quarta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-12 10:00:00');
SET @id_funcionario_logado = 1;
INSERT INTO cliente (id_cliente, nm_cliente, nr_cpf, dt_nascimento, nr_telefone, vl_limite_fiado, dt_consentimento_lgpd, dt_cadastro) VALUES (7, 'Gustavo Pereira Dias', '91000000007', '1998-02-21', '(11) 99000-0007', '0.00', '2026-08-12 10:00:00', '2026-08-12 10:00:00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-12 10:05:00');
CALL sp_autorizar_cliente_fiado(7, 150.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-12 10:00:00');
INSERT INTO cliente (id_cliente, nm_cliente, nr_cpf, dt_nascimento, nr_telefone, vl_limite_fiado, dt_consentimento_lgpd, dt_cadastro) VALUES (8, 'Helena Barros Siqueira', '91000000008', '1976-08-14', '(11) 99000-0008', '0.00', '2026-08-12 10:00:00', '2026-08-12 10:00:00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-12 10:05:00');
CALL sp_autorizar_cliente_fiado(8, 400.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-12 12:44:34');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-12 12:49:01');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-12 12:54:00');
SET @id_funcionario_logado = 4;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (10, 4, '2026-08-12 12:54:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-12 10:37:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (10, 2, 1, '2026-08-12 10:37:00', 'ENTREGA', '163.50', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (69, 10, 23, 2, 0, '66.00', 0),
  (70, 10, 24, 3, 0, '10.50', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-12 13:20:00');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 1, 45, 'PERDA', 7, 'Lote vencido em 11/08/2026');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-12 13:21:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '190', '{"tipo": "PERDA", "motivo": "vencimento", "lote": 45, "quantidade": 7}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-12 14:30:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-08-12 14:30:00', nr_nota_fiscal = '202193' WHERE id_compra = 9;
UPDATE item_compra SET qt_recebida = 27, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 64;
UPDATE item_compra SET qt_recebida = 24, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 65;
UPDATE item_compra SET qt_recebida = 12, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 66;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 67;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 68;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (48, 64, 'L2608120148', '2027-02-08', 0),
  (49, 65, 'L2608120349', '2027-02-13', 0),
  (50, 66, 'L2608120750', '2027-01-11', 0),
  (51, 67, 'L2608121451', '2027-01-23', 0),
  (52, 68, 'L2608122152', '2026-11-12', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (1, 1, 48, 'ENTRADA_COMPRA', 27, 'Recebimento da compra 9');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (3, 1, 49, 'ENTRADA_COMPRA', 24, 'Recebimento da compra 9');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (7, 1, 50, 'ENTRADA_COMPRA', 12, 'Recebimento da compra 9');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (14, 1, 51, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 9');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (21, 1, 52, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 9');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-12 16:34:00');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (47, 1, 40, 'PERDA', 2, 'Embalagem avariada no manuseio');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-12 16:35:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '196', '{"tipo": "PERDA", "motivo": "Embalagem avariada no manuseio", "quantidade": 2}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-12 17:17:58');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (63, 4, 10, '2026-08-12 17:17:58', '0.00', '13.50', 'CONCLUIDA', '683303', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (118, 63, 1, 1, NULL, 'UNIDADE', 3, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (63, 'PIX', 5.40),
  (63, 'CREDITO', 8.10);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-12 17:55:19');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (64, 1, 10, '2026-08-12 17:55:19', '0.00', '24.00', 'CONCLUIDA', '852814', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (119, 64, 33, NULL, NULL, 'UNIDADE', 2, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (64, 'PIX', 24.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-12 18:35:03');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (65, 4, 10, '2026-08-12 18:35:03', '0.00', '34.00', 'CONCLUIDA', '870941', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (120, 65, 27, NULL, NULL, 'UNIDADE', 1, '34.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (65, 'PIX', 13.60),
  (65, 'DEBITO', 20.40);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-12 20:47:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (9, 10, 4, 'DESPESA', '35.00', 'Café e água dos funcionários');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-12 22:03:15');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (66, 4, 10, '2026-08-12 22:03:15', '0.00', '5.00', 'CONCLUIDA', '668510', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (121, 66, 43, 36, NULL, 'UNIDADE', 1, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (66, 'PIX', 5.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-12 23:05:00');
CALL sp_fechar_caixa(10, 165.00);

-- ===== 13/08/2026 (quinta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-13 12:43:43');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-13 12:40:43');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-13 12:52:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (11, 4, '2026-08-13 12:52:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-13 10:09:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (11, 4, 1, '2026-08-13 10:09:00', 'ENTREGA', '124.40', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (71, 11, 40, 14, 0, '5.40', 0),
  (72, 11, 41, 4, 0, '4.20', 0),
  (73, 11, 42, 8, 0, '4.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-13 10:38:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (12, 5, 1, '2026-08-13 10:38:00', 'RETIRADA', '34.80', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (74, 12, 60, 6, 0, '5.80', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-13 13:24:13');
SET @id_funcionario_logado = 4;
CALL sp_abrir_garrafa(26, 4, @garrafa);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-13 13:25:13');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (67, 4, 11, '2026-08-13 13:25:13', '0.00', '27.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (122, 67, 40, 33, NULL, 'UNIDADE', 1, '8.00'),
  (123, 67, 22, NULL, 1, 'DOSE', 1, '7.00'),
  (124, 67, 46, 39, NULL, 'UNIDADE', 2, '6.00');
CALL sp_registrar_venda_fiado(67, 1, '2026-09-12', 27.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-13 14:20:28');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (68, 3, 11, '2026-08-13 14:20:28', '0.00', '25.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (125, 68, 37, NULL, NULL, 'UNIDADE', 1, '25.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (68, 'PIX', 12.50),
  (68, 'DINHEIRO', 12.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-13 14:30:00');
SET @id_funcionario_logado = 4;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-08-13 14:30:00', nr_nota_fiscal = '949951' WHERE id_compra = 10;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 69;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 70;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (53, 69, 'L2608132353', '2027-11-16', 0),
  (54, 70, 'L2608132454', '2027-12-17', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (23, 4, 53, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 10');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (24, 4, 54, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 10');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-13 15:18:32');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (69, 4, 11, '2026-08-13 15:18:32', '0.00', '10.00', 'CONCLUIDA', '464655', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (126, 69, 10, 12, NULL, 'UNIDADE', 2, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (69, 'PIX', 10.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-13 15:48:42');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (70, 4, 11, '2026-08-13 15:48:42', '0.00', '11.00', 'CONCLUIDA', '449146', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (127, 70, 6, 6, NULL, 'UNIDADE', 1, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (70, 'PIX', 11.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-13 17:00:00');
SET @id_funcionario_logado = 3;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-08-13 17:00:00', nr_nota_fiscal = '181769' WHERE id_compra = 12;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 74;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (55, 74, 'L2608136055', '2026-08-23', 0),
  (56, 74, 'L2608136056', '2026-09-25', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 3, 55, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 12');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 3, 56, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-13 19:55:05');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (71, 3, 11, '2026-08-13 19:55:05', '0.00', '1.50', 'CONCLUIDA', '688331', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (128, 71, 47, 40, NULL, 'UNIDADE', 1, '1.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (71, 'DINHEIRO', 1.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-13 23:05:00');
SET @id_funcionario_logado = 4;
CALL sp_fechar_caixa(11, 112.00);
UPDATE caixa SET ds_observacao = 'Faltou R$ 2.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 11;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-13 23:07:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '11', '{"diferenca": "-2.00"}', '192.168.0.11');

-- ===== 14/08/2026 (sexta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-14 12:44:22');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-14 12:43:33');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-14 12:43:22');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-14 12:51:00');
SET @id_funcionario_logado = 1;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (12, 1, '2026-08-14 12:51:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-14 13:05:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (10, 12, 1, 'SUPRIMENTO', '100.00', 'Reforço de troco para o caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-14 13:36:21');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (72, 3, 12, '2026-08-14 13:36:21', '0.00', '14.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (129, 72, 4, 4, NULL, 'UNIDADE', 2, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (72, 'CREDITO', 14.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-14 14:17:47');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (73, 1, 12, '2026-08-14 14:17:47', '0.00', '42.00', 'CONCLUIDA', '185149', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (130, 73, 49, NULL, NULL, 'UNIDADE', 2, '12.00'),
  (131, 73, 53, NULL, NULL, 'UNIDADE', 2, '9.00');
CALL sp_registrar_venda_fiado(73, 7, '2026-09-13', 42.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-14 14:30:00');
SET @id_funcionario_logado = 3;
UPDATE compra SET st_compra = 'RECEBIDA_PARCIAL', dt_recebimento = '2026-08-14 14:30:00', nr_nota_fiscal = '850685' WHERE id_compra = 11;
UPDATE item_compra SET qt_recebida = 14, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 71;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = 'Faltaram 1 unidades na entrega' WHERE id_item_compra = 72;
UPDATE item_compra SET qt_recebida = 8, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 73;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (57, 71, 'L2608144057', '2026-10-14', 0),
  (58, 72, 'L2608144158', '2026-12-30', 0),
  (59, 73, 'L2608144259', '2027-01-20', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (40, 3, 57, 'ENTRADA_COMPRA', 14, 'Recebimento da compra 11');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (41, 3, 58, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 11');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (42, 3, 59, 'ENTRADA_COMPRA', 8, 'Recebimento da compra 11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-14 15:08:58');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (74, 2, 12, '2026-08-14 15:08:58', '0.00', '4.00', 'CONCLUIDA', '627332', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (132, 74, 18, 22, NULL, 'UNIDADE', 1, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (74, 'CREDITO', 4.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-14 16:25:00');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (11, 12, 1, 'DESPESA', '50.00', 'Material de limpeza');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-14 16:26:58');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (75, 3, 12, '2026-08-14 16:26:58', '0.00', '61.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (133, 75, 8, 9, NULL, 'UNIDADE', 6, '7.00'),
  (134, 75, 33, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (135, 75, 39, 32, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (75, 'DEBITO', 61.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-14 18:39:45');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (76, 2, 12, '2026-08-14 18:39:45', '0.00', '28.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (136, 76, 7, 50, NULL, 'UNIDADE', 3, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (76, 'DINHEIRO', 28.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-14 19:14:25');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (77, 3, 12, '2026-08-14 19:14:25', '0.00', '4.50', 'CONCLUIDA', '471039', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (137, 77, 12, 14, NULL, 'UNIDADE', 1, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (77, 'DINHEIRO', 4.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-14 20:29:37');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (78, 2, 12, '2026-08-14 20:29:37', '0.00', '36.00', 'CONCLUIDA', '126993', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (138, 78, 1, 1, NULL, 'UNIDADE', 6, '4.50'),
  (139, 78, 19, 23, NULL, 'UNIDADE', 1, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (78, 'PIX', 36.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-14 21:00:00');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (12, 12, 1, 'SANGRIA', '200.00', 'Sangria: retirada do excesso de dinheiro do caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-14 21:26:11');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (79, 1, 12, '2026-08-14 21:26:11', '0.00', '12.00', 'CONCLUIDA', '850355', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (140, 79, 49, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (79, 'CREDITO', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-14 22:02:21');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (80, 3, 12, '2026-08-14 22:02:21', '0.00', '53.50', 'CONCLUIDA', '600068', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (141, 80, 3, 49, NULL, 'UNIDADE', 1, '3.50'),
  (142, 80, 37, NULL, NULL, 'UNIDADE', 2, '25.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (80, 'DEBITO', 53.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-14 22:35:57');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (81, 3, 12, '2026-08-14 22:35:57', '0.00', '14.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (143, 81, 4, 4, NULL, 'UNIDADE', 2, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (81, 'PIX', 14.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 00:08:00');
SET @id_funcionario_logado = 1;
CALL sp_fechar_caixa(12, 84.00);
UPDATE caixa SET ds_observacao = 'Sobrou R$ 1.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 12;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 00:10:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '12', '{"diferenca": "1.00"}', '192.168.0.11');

-- ===== 15/08/2026 (sábado) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 12:41:43');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 12:45:34');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 12:46:19');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 12:50:00');
SET @id_funcionario_logado = 4;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (13, 4, '2026-08-15 12:50:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 15:37:12');
SET @id_funcionario_logado = 3;
CALL sp_abrir_garrafa(30, 3, @garrafa);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 15:38:12');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (82, 3, 13, '2026-08-15 15:38:12', '0.00', '62.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (144, 82, 26, NULL, 2, 'DOSE', 2, '12.00'),
  (145, 82, 10, 12, NULL, 'UNIDADE', 1, '5.00'),
  (146, 82, 36, NULL, NULL, 'UNIDADE', 1, '22.00'),
  (147, 82, 2, 2, NULL, 'UNIDADE', 2, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (82, 'DINHEIRO', 62.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 15:57:21');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (83, 1, 13, '2026-08-15 15:57:21', '0.00', '18.50', 'CONCLUIDA', '299640', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (148, 83, 12, 14, NULL, 'UNIDADE', 2, '4.50'),
  (149, 83, 16, 19, NULL, 'UNIDADE', 1, '3.50'),
  (150, 83, 59, 44, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (83, 'PIX', 18.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 16:45:58');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (84, 4, 13, '2026-08-15 16:45:58', '0.00', '20.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (151, 84, 33, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (152, 84, 21, 52, NULL, 'UNIDADE', 1, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (84, 'DEBITO', 20.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 17:17:49');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (85, 1, 13, '2026-08-15 17:17:49', '0.00', '6.00', 'CONCLUIDA', '824916', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (153, 85, 42, 35, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (85, 'DINHEIRO', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 17:46:11');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (86, 3, 13, '2026-08-15 17:46:11', '0.00', '8.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (154, 86, 21, 52, NULL, 'UNIDADE', 1, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (86, 'DEBITO', 8.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 19:24:56');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (87, 1, 13, '2026-08-15 19:24:56', '0.00', '10.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (155, 87, 16, 19, NULL, 'UNIDADE', 3, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (87, 'DEBITO', 6.30),
  (87, 'CREDITO', 4.20);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 19:27:29');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (88, 3, 13, '2026-08-15 19:27:29', '0.00', '19.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (156, 88, 5, 5, NULL, 'UNIDADE', 2, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (88, 'DINHEIRO', 19.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 19:35:57');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (89, 1, 13, '2026-08-15 19:35:57', '0.00', '3.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (157, 89, 15, 18, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (89, 'DINHEIRO', 3.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 20:19:55');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (90, 1, 13, '2026-08-15 20:19:55', '0.00', '5.00', 'CONCLUIDA', '188422', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (158, 90, 10, 12, NULL, 'UNIDADE', 1, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (90, 'DINHEIRO', 5.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 21:00:00');
SET @id_funcionario_logado = 4;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (13, 13, 4, 'SANGRIA', '200.00', 'Sangria: retirada do excesso de dinheiro do caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 21:19:47');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (91, 3, 13, '2026-08-15 21:19:47', '0.00', '5.50', 'CONCLUIDA', '338746', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (159, 91, 2, 2, NULL, 'UNIDADE', 1, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (91, 'DEBITO', 5.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 21:26:40');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (92, 3, 13, '2026-08-15 21:26:40', '0.00', '8.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (160, 92, 50, NULL, NULL, 'UNIDADE', 2, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (92, 'PIX', 8.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 21:54:47');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (93, 1, 13, '2026-08-15 21:54:47', '0.00', '16.50', 'CONCLUIDA', '274274', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (161, 93, 10, 12, NULL, 'UNIDADE', 2, '5.00'),
  (162, 93, 41, 34, NULL, 'UNIDADE', 1, '6.50');
CALL sp_registrar_venda_fiado(93, 3, '2026-09-14', 16.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 22:46:08');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (94, 1, 13, '2026-08-15 22:46:08', '0.00', '28.00', 'CONCLUIDA', '655051', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (163, 94, 15, 18, NULL, 'UNIDADE', 2, '3.00'),
  (164, 94, 11, 13, NULL, 'UNIDADE', 2, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (94, 'DEBITO', 28.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-15 23:18:44');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (95, 4, 13, '2026-08-15 23:18:44', '0.00', '14.00', 'CONCLUIDA', '815497', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (165, 95, 20, 24, NULL, 'UNIDADE', 2, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (95, 'PIX', 14.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-16 00:08:00');
CALL sp_fechar_caixa(13, 45.00);

-- ===== 16/08/2026 (domingo) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-16 12:46:39');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-16 12:45:06');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-16 12:59:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (14, 4, '2026-08-16 12:59:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-16 13:05:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (14, 14, 4, 'SUPRIMENTO', '100.00', 'Reforço de troco para o caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-16 17:13:00');
CALL sp_registrar_evento_acesso(4, 'CONSULTA_DADO_PESSOAL', 'cliente', '7', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-16 17:15:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (3, 8, 14, 'DEBITO', '42.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-16 17:28:15');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (96, 4, 14, '2026-08-16 17:28:15', '0.00', '66.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (166, 96, 10, 12, NULL, 'UNIDADE', 1, '5.00'),
  (167, 96, 3, 49, NULL, 'UNIDADE', 1, '3.50'),
  (168, 96, 52, NULL, NULL, 'UNIDADE', 2, '22.00'),
  (169, 96, 57, NULL, NULL, 'UNIDADE', 1, '14.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (96, 'PIX', 66.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-16 19:31:30');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (97, 4, 14, '2026-08-16 19:31:30', '0.00', '12.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (170, 97, 33, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (97, 'DEBITO', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-16 20:02:03');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (98, 2, 14, '2026-08-16 20:02:03', '0.00', '16.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (171, 98, 2, 2, NULL, 'UNIDADE', 3, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (98, 'DEBITO', 16.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-16 20:20:38');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (99, 2, 14, '2026-08-16 20:20:38', '0.00', '15.00', 'CONCLUIDA', '231951', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (172, 99, 10, 12, NULL, 'UNIDADE', 3, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (99, 'PIX', 15.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-16 20:52:10');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (100, 2, 14, '2026-08-16 20:52:10', '0.00', '9.00', 'CONCLUIDA', '279796', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (173, 100, 12, 14, NULL, 'UNIDADE', 2, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (100, 'DINHEIRO', 9.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-16 22:02:14');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (101, 2, 14, '2026-08-16 22:02:14', '0.00', '54.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (174, 101, 1, 1, NULL, 'UNIDADE', 12, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (101, 'DINHEIRO', 21.60),
  (101, 'PIX', 32.40);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-16 22:39:29');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (102, 2, 14, '2026-08-16 22:39:29', '0.00', '2.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (175, 102, 45, 38, NULL, 'UNIDADE', 2, '1.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (102, 'CREDITO', 2.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-17 00:08:00');
SET @id_funcionario_logado = 4;
CALL sp_fechar_caixa(14, 280.60);

-- ===== 17/08/2026 (segunda) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-17 12:43:24');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-17 12:43:28');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-17 12:52:00');
SET @id_funcionario_logado = 3;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (15, 3, '2026-08-17 12:52:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-17 10:22:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (13, 3, 1, '2026-08-17 10:22:00', 'RETIRADA', '230.40', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (75, 13, 33, 7, 0, '10.20', 0),
  (76, 13, 36, 3, 0, '14.50', 0),
  (77, 13, 37, 7, 0, '16.50', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-17 16:32:25');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (103, 3, 15, '2026-08-17 16:32:25', '0.00', '4.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (176, 103, 50, NULL, NULL, 'UNIDADE', 1, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (103, 'CREDITO', 4.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-17 17:00:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-08-17 17:00:00', nr_nota_fiscal = '205787' WHERE id_compra = 13;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 75;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 76;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 77;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (33, 3, NULL, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 13');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (36, 3, NULL, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 13');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (37, 3, NULL, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-17 17:58:20');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (104, 3, 15, '2026-08-17 17:58:20', '0.00', '22.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (177, 104, 6, 6, NULL, 'UNIDADE', 2, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (104, 'DINHEIRO', 22.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-17 18:04:00');
CALL sp_registrar_evento_acesso(3, 'CONSULTA_DADO_PESSOAL', 'cliente', '3', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-17 18:06:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (4, 9, 15, 'DEBITO', '16.50');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-17 18:23:17');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (105, 3, 15, '2026-08-17 18:23:17', '0.00', '16.50', 'CONCLUIDA', '582372', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (178, 105, 2, 2, NULL, 'UNIDADE', 3, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (105, 'DINHEIRO', 16.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-17 18:45:11');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (106, 2, 15, '2026-08-17 18:45:11', '0.00', '6.00', 'CONCLUIDA', '825956', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (179, 106, 42, 35, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (106, 'DINHEIRO', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-17 18:49:00');
SET @id_funcionario_logado = 3;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (15, 15, 3, 'DESPESA', '15.00', 'Café e água dos funcionários');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-17 18:55:21');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (107, 2, 15, '2026-08-17 18:55:21', '0.00', '33.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (180, 107, 6, 6, NULL, 'UNIDADE', 3, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (107, 'PIX', 16.50),
  (107, 'CREDITO', 16.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-17 19:33:25');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (108, 2, 15, '2026-08-17 19:33:25', '0.00', '18.00', 'CONCLUIDA', '435387', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (181, 108, 19, 23, NULL, 'UNIDADE', 2, '9.00');
CALL sp_registrar_venda_fiado(108, 8, '2026-09-16', 18.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-17 23:05:00');
SET @id_funcionario_logado = 3;
CALL sp_fechar_caixa(15, 179.50);

-- ===== 18/08/2026 (terça) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-18 12:45:05');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-18 12:42:29');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-18 12:55:00');
SET @id_funcionario_logado = 2;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (16, 2, '2026-08-18 12:55:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-18 10:03:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (14, 1, 1, '2026-08-18 10:03:00', 'ENTREGA', '187.70', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (78, 14, 1, 31, 0, '3.10', 0),
  (79, 14, 8, 9, 0, '5.00', 0),
  (80, 14, 12, 6, 0, '3.10', 0),
  (81, 14, 16, 4, 0, '2.00', 0),
  (82, 14, 20, 2, 0, '4.60', 0),
  (83, 14, 21, 2, 0, '5.40', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-18 14:58:26');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (109, 2, 16, '2026-08-18 14:58:26', '0.00', '7.00', 'CONCLUIDA', '129898', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (182, 109, 22, NULL, 1, 'DOSE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (109, 'PIX', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-18 16:18:00');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (14, 1, 17, 'PERDA', 3, 'Caiu no chão durante a reposição');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-18 16:19:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '271', '{"tipo": "PERDA", "motivo": "Caiu no chão durante a reposição", "quantidade": 3}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-18 18:15:00');
SET @id_funcionario_logado = 2;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (16, 16, 2, 'DESPESA', '50.00', 'Compra de gelo para o balcão');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-18 18:44:06');
CALL sp_abrir_garrafa(54, 2, @garrafa);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-18 18:45:06');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (110, 2, 16, '2026-08-18 18:45:06', '0.00', '13.50', 'CONCLUIDA', '880592', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (183, 110, 10, 12, NULL, 'UNIDADE', 1, '5.00'),
  (184, 110, 24, NULL, 3, 'DOSE', 1, '4.00'),
  (185, 110, 1, 1, NULL, 'UNIDADE', 1, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (110, 'PIX', 13.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-18 19:30:38');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (111, 2, 16, '2026-08-18 19:30:38', '0.00', '24.00', 'CONCLUIDA', '152898', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (186, 111, 10, 12, NULL, 'UNIDADE', 1, '5.00'),
  (187, 111, 35, NULL, NULL, 'UNIDADE', 1, '13.00'),
  (188, 111, 44, 37, NULL, 'UNIDADE', 2, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (111, 'DINHEIRO', 24.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-18 20:25:43');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (112, 1, 16, '2026-08-18 20:25:43', '0.00', '25.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (189, 112, 44, 37, NULL, 'UNIDADE', 1, '3.00'),
  (190, 112, 36, NULL, NULL, 'UNIDADE', 1, '22.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (112, 'DEBITO', 25.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-18 20:38:31');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (113, 1, 16, '2026-08-18 20:38:31', '0.00', '29.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (191, 113, 12, 14, NULL, 'UNIDADE', 1, '4.50'),
  (192, 113, 37, NULL, NULL, 'UNIDADE', 1, '25.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (113, 'DEBITO', 29.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-18 23:05:00');
SET @id_funcionario_logado = 2;
CALL sp_fechar_caixa(16, 124.00);

-- ===== 19/08/2026 (quarta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-19 12:44:15');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-19 12:40:28');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-19 12:51:00');
SET @id_funcionario_logado = 4;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (17, 4, '2026-08-19 12:51:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-19 14:28:16');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (114, 1, 17, '2026-08-19 14:28:16', '0.00', '9.00', 'CONCLUIDA', '754951', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (193, 114, 14, 17, NULL, 'UNIDADE', 2, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (114, 'DEBITO', 9.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-19 14:30:00');
SET @id_funcionario_logado = 4;
UPDATE compra SET st_compra = 'RECEBIDA_PARCIAL', dt_recebimento = '2026-08-19 14:30:00', nr_nota_fiscal = '120819' WHERE id_compra = 14;
UPDATE item_compra SET qt_recebida = 31, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 78;
UPDATE item_compra SET qt_recebida = 9, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 79;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 80;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = 'Faltaram 1 unidades na entrega' WHERE id_item_compra = 81;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 82;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 83;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (60, 78, 'L2608190160', '2027-04-03', 0),
  (61, 79, 'L2608190861', '2027-02-12', 0),
  (62, 80, 'L2608191262', '2027-03-02', 0),
  (63, 81, 'L2608191663', '2027-04-12', 0),
  (64, 82, 'L2608192064', '2027-01-06', 0),
  (65, 83, 'L2608192165', '2027-01-17', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (1, 4, 60, 'ENTRADA_COMPRA', 31, 'Recebimento da compra 14');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (8, 4, 61, 'ENTRADA_COMPRA', 9, 'Recebimento da compra 14');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (12, 4, 62, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 14');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (16, 4, 63, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 14');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (20, 4, 64, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 14');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (21, 4, 65, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-19 14:46:26');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (115, 4, 17, '2026-08-19 14:46:26', '0.00', '17.00', 'CONCLUIDA', '683754', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (194, 115, 45, 38, NULL, 'UNIDADE', 1, '1.00'),
  (195, 115, 40, 57, NULL, 'UNIDADE', 2, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (115, 'DEBITO', 8.50),
  (115, 'DINHEIRO', 8.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-19 16:10:00');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (48, 1, 42, 'PERDA', 3, 'Caiu no chão durante a reposição');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-19 16:11:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '291', '{"tipo": "PERDA", "motivo": "Caiu no chão durante a reposição", "quantidade": 3}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-19 17:02:05');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (116, 1, 17, '2026-08-19 17:02:05', '0.00', '5.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (196, 116, 10, 12, NULL, 'UNIDADE', 1, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (116, 'PIX', 5.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-19 18:13:47');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (117, 4, 17, '2026-08-19 18:13:47', '0.00', '22.00', 'CONCLUIDA', '983550', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (197, 117, 36, NULL, NULL, 'UNIDADE', 1, '22.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (117, 'PIX', 22.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-19 18:29:00');
CALL sp_registrar_evento_acesso(4, 'CONSULTA_DADO_PESSOAL', 'cliente', '2', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-19 18:31:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (5, 4, 17, 'PIX', '30.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-19 18:30:00');
CALL sp_registrar_evento_acesso(4, 'CONSULTA_DADO_PESSOAL', 'cliente', '3', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-19 18:32:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (6, 1, 17, 'DEBITO', '30.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-19 23:05:00');
CALL sp_fechar_caixa(17, 158.50);

-- ===== 20/08/2026 (quinta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-20 12:46:48');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-20 12:46:56');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-20 12:54:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (18, 4, '2026-08-20 12:54:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-20 10:14:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (15, 4, 1, '2026-08-20 10:14:00', 'ENTREGA', '35.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (84, 15, 44, 4, 0, '1.80', 0),
  (85, 15, 45, 6, 0, '0.50', 0),
  (86, 15, 47, 4, 0, '0.80', 0),
  (87, 15, 48, 4, 0, '2.50', 0),
  (88, 15, 53, 2, 0, '5.80', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-20 13:50:24');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (118, 4, 18, '2026-08-20 13:50:24', '0.00', '22.00', 'CONCLUIDA', '512542', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (198, 118, 6, 6, NULL, 'UNIDADE', 2, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (118, 'CREDITO', 22.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-20 17:15:47');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (119, 4, 18, '2026-08-20 17:15:47', '0.00', '114.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (199, 119, 7, 50, NULL, 'UNIDADE', 9, '9.50'),
  (200, 119, 7, 8, NULL, 'UNIDADE', 3, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (119, 'DINHEIRO', 114.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-20 17:24:16');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (120, 3, 18, '2026-08-20 17:24:16', '0.00', '38.00', 'CONCLUIDA', '195131', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (201, 120, 22, 26, NULL, 'UNIDADE', 1, '38.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (120, 'PIX', 38.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-20 18:32:52');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (121, 4, 18, '2026-08-20 18:32:52', '0.00', '28.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (202, 121, 5, 5, NULL, 'UNIDADE', 3, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (121, 'PIX', 28.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-20 18:57:03');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (122, 4, 18, '2026-08-20 18:57:03', '0.00', '33.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (203, 122, 6, 6, NULL, 'UNIDADE', 3, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (122, 'DEBITO', 33.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-20 22:45:10');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (123, 3, 18, '2026-08-20 22:45:10', '0.00', '42.00', 'CONCLUIDA', '118643', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (204, 123, 4, 4, NULL, 'UNIDADE', 6, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (123, 'PIX', 42.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-20 23:05:00');
SET @id_funcionario_logado = 4;
CALL sp_fechar_caixa(18, 266.00);
UPDATE caixa SET ds_observacao = 'Sobrou R$ 2.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 18;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-20 23:07:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '18', '{"diferenca": "2.00"}', '192.168.0.11');

-- ===== 21/08/2026 (sexta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-21 12:42:56');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-21 12:40:52');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-21 12:40:51');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-21 12:53:00');
SET @id_funcionario_logado = 1;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (19, 1, '2026-08-21 12:53:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-21 10:08:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (16, 1, 1, '2026-08-21 10:08:00', 'ENTREGA', '222.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (89, 16, 4, 14, 0, '4.90', 0),
  (90, 16, 7, 15, 0, '6.70', 0),
  (91, 16, 10, 11, 0, '3.40', 0),
  (92, 16, 14, 5, 0, '3.10', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-21 14:30:00');
UPDATE compra SET st_compra = 'RECEBIDA_PARCIAL', dt_recebimento = '2026-08-21 14:30:00', nr_nota_fiscal = '689821' WHERE id_compra = 15;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 84;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 85;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 86;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = 'Produto trocado pelo fornecedor: 1 unidades não entregues' WHERE id_item_compra = 87;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 88;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (66, 84, 'L2608214466', '2027-03-24', 0),
  (67, 85, 'L2608214567', '2027-01-31', 0),
  (68, 86, 'L2608214768', '2026-12-16', 0),
  (69, 86, 'L2608214769', '2027-01-13', 0),
  (70, 87, 'L2608214870', '2027-02-05', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (44, 1, 66, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 15');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (45, 1, 67, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 15');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (47, 1, 68, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 15');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (47, 1, 69, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 15');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (48, 1, 70, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 15');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (53, 1, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 15');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-21 14:37:29');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (124, 2, 19, '2026-08-21 14:37:29', '0.00', '22.00', 'CONCLUIDA', '748593', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (205, 124, 57, NULL, NULL, 'UNIDADE', 1, '14.00'),
  (206, 124, 51, NULL, NULL, 'UNIDADE', 1, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (124, 'PIX', 22.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-21 15:18:50');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (125, 1, 19, '2026-08-21 15:18:50', '0.00', '68.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (207, 125, 4, 4, NULL, 'UNIDADE', 6, '7.00'),
  (208, 125, 10, 12, NULL, 'UNIDADE', 3, '5.00'),
  (209, 125, 11, 13, NULL, 'UNIDADE', 1, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (125, 'PIX', 68.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-21 15:31:50');
UPDATE venda SET st_venda = 'CANCELADA' WHERE id_venda = 125;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (4, 1, 4, 'AJUSTE_ENTRADA', 6, 'Cancelamento da venda 125: produto devolvido ao estoque');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (10, 1, 12, 'AJUSTE_ENTRADA', 3, 'Cancelamento da venda 125: produto devolvido ao estoque');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (11, 1, 13, 'AJUSTE_ENTRADA', 1, 'Cancelamento da venda 125: produto devolvido ao estoque');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'venda', '125', '{"acao": "cancelamento", "total": "68.00"}', '192.168.0.11');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'UPDATE', 'venda', '125', '{"coluna": "st_venda", "antes": "CONCLUIDA", "depois": "CANCELADA"}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-21 17:01:04');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (126, 3, 19, '2026-08-21 17:01:04', '0.00', '25.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (210, 126, 37, NULL, NULL, 'UNIDADE', 1, '25.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (126, 'PIX', 12.50),
  (126, 'CREDITO', 12.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-21 17:18:34');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (127, 3, 19, '2026-08-21 17:18:34', '0.00', '21.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (211, 127, 39, 32, NULL, 'UNIDADE', 3, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (127, 'DEBITO', 21.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-21 19:05:13');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (128, 2, 19, '2026-08-21 19:05:13', '0.00', '11.00', 'CONCLUIDA', '719124', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (212, 128, 6, 6, NULL, 'UNIDADE', 1, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (128, 'PIX', 11.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-21 20:01:18');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (129, 3, 19, '2026-08-21 20:01:18', '0.00', '12.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (213, 129, 45, 67, NULL, 'UNIDADE', 5, '1.00'),
  (214, 129, 20, 24, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (129, 'CREDITO', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-21 20:21:45');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (130, 2, 19, '2026-08-21 20:21:45', '0.00', '6.00', 'CONCLUIDA', '711169', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (215, 130, 44, 37, NULL, 'UNIDADE', 2, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (130, 'PIX', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-21 21:00:00');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (17, 19, 1, 'SANGRIA', '100.00', 'Sangria: retirada do excesso de dinheiro do caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-21 21:59:34');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (131, 3, 19, '2026-08-21 21:59:34', '0.00', '26.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (216, 131, 33, NULL, NULL, 'UNIDADE', 2, '12.00'),
  (217, 131, 54, NULL, NULL, 'UNIDADE', 1, '2.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (131, 'CREDITO', 26.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-21 22:18:15');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (132, 1, 19, '2026-08-21 22:18:15', '0.00', '151.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (218, 132, 6, 6, NULL, 'UNIDADE', 1, '11.00'),
  (219, 132, 4, 4, NULL, 'UNIDADE', 6, '7.00'),
  (220, 132, 27, NULL, NULL, 'UNIDADE', 2, '34.00'),
  (221, 132, 44, 37, NULL, 'UNIDADE', 1, '3.00'),
  (222, 132, 1, 1, NULL, 'UNIDADE', 1, '4.50'),
  (223, 132, 1, 48, NULL, 'UNIDADE', 5, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (132, 'DEBITO', 60.40),
  (132, 'DINHEIRO', 90.60);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-21 22:33:41');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (133, 2, 19, '2026-08-21 22:33:41', '0.00', '6.00', 'CONCLUIDA', '507247', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (224, 133, 42, 35, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (133, 'DEBITO', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 00:08:00');
SET @id_funcionario_logado = 1;
CALL sp_fechar_caixa(19, 190.60);

-- ===== 22/08/2026 (sábado) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 12:44:28');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 12:48:20');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 12:42:16');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 12:56:00');
SET @id_funcionario_logado = 4;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (20, 4, '2026-08-22 12:56:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 13:05:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (18, 20, 4, 'SUPRIMENTO', '50.00', 'Reforço de troco para o caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 13:16:49');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (134, 4, 20, '2026-08-22 13:16:49', '0.00', '65.50', 'CONCLUIDA', '873185', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (225, 134, 11, 13, NULL, 'UNIDADE', 1, '11.00'),
  (226, 134, 4, 4, NULL, 'UNIDADE', 6, '7.00'),
  (227, 134, 13, 15, NULL, 'UNIDADE', 1, '9.50'),
  (228, 134, 45, 67, NULL, 'UNIDADE', 1, '1.00'),
  (229, 134, 45, 38, NULL, 'UNIDADE', 2, '1.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (134, 'DINHEIRO', 65.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 14:30:00');
SET @id_funcionario_logado = 1;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-08-22 14:30:00', nr_nota_fiscal = '117948' WHERE id_compra = 16;
UPDATE item_compra SET qt_recebida = 14, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 89;
UPDATE item_compra SET qt_recebida = 15, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 90;
UPDATE item_compra SET qt_recebida = 11, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 91;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 92;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (71, 89, 'L2608220471', '2027-03-13', 0),
  (72, 89, 'L2608220472', '2027-04-11', 0),
  (73, 90, 'L2608220773', '2027-01-23', 0),
  (74, 91, 'L2608221074', '2027-02-07', 0),
  (75, 91, 'L2608221075', '2027-03-04', 0),
  (76, 92, 'L2608221476', '2027-02-02', 0),
  (77, 92, 'L2608221477', '2027-02-26', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (4, 1, 71, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 16');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (4, 1, 72, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 16');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (7, 1, 73, 'ENTRADA_COMPRA', 15, 'Recebimento da compra 16');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (10, 1, 74, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 16');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (10, 1, 75, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 16');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (14, 1, 76, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 16');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (14, 1, 77, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 16');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 15:09:14');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (135, 4, 20, '2026-08-22 15:09:14', '3.00', '63.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (230, 135, 5, 5, NULL, 'UNIDADE', 3, '9.50'),
  (231, 135, 7, 73, NULL, 'UNIDADE', 4, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (135, 'DINHEIRO', 63.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 15:17:47');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (136, 3, 20, '2026-08-22 15:17:47', '0.00', '16.00', 'CONCLUIDA', '168586', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (232, 136, 41, 34, NULL, 'UNIDADE', 1, '6.50'),
  (233, 136, 13, 15, NULL, 'UNIDADE', 1, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (136, 'PIX', 8.00),
  (136, 'DEBITO', 8.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 16:00:00');
CALL sp_registrar_evento_acesso(3, 'CONSULTA_DADO_PESSOAL', 'cliente', '8', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 16:02:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (7, 10, 20, 'DINHEIRO', '18.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 16:05:00');
SET @id_funcionario_logado = 4;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (19, 20, 4, 'DESPESA', '15.00', 'Material de limpeza');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 18:36:32');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (137, 1, 20, '2026-08-22 18:36:32', '0.00', '30.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (234, 137, 60, 55, NULL, 'UNIDADE', 1, '8.50'),
  (235, 137, 6, 6, NULL, 'UNIDADE', 2, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (137, 'DEBITO', 15.20),
  (137, 'PIX', 15.30);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 19:32:38');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (138, 1, 20, '2026-08-22 19:32:38', '0.00', '3.50', 'CONCLUIDA', '912117', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (236, 138, 3, 49, NULL, 'UNIDADE', 1, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (138, 'PIX', 3.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 20:20:04');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (139, 1, 20, '2026-08-22 20:20:04', '0.00', '44.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (237, 139, 36, NULL, NULL, 'UNIDADE', 2, '22.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (139, 'DEBITO', 44.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 20:25:24');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (140, 4, 20, '2026-08-22 20:25:24', '0.00', '6.00', 'CONCLUIDA', '768915', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (238, 140, 42, 35, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (140, 'PIX', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 21:00:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (20, 20, 4, 'SANGRIA', '150.00', 'Sangria: retirada do excesso de dinheiro do caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 21:34:39');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (141, 3, 20, '2026-08-22 21:34:39', '0.00', '55.00', 'CONCLUIDA', '809553', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (239, 141, 31, NULL, NULL, 'UNIDADE', 1, '55.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (141, 'PIX', 55.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 21:36:02');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (142, 4, 20, '2026-08-22 21:36:02', '0.00', '16.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (240, 142, 13, 15, NULL, 'UNIDADE', 1, '9.50'),
  (241, 142, 41, 34, NULL, 'UNIDADE', 1, '6.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (142, 'CREDITO', 9.60),
  (142, 'PIX', 6.40);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 21:44:51');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (143, 3, 20, '2026-08-22 21:44:51', '0.00', '138.00', 'CONCLUIDA', '562619', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (242, 143, 1, 48, NULL, 'UNIDADE', 12, '4.50'),
  (243, 143, 33, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (244, 143, 11, 13, NULL, 'UNIDADE', 2, '11.00'),
  (245, 143, 37, NULL, NULL, 'UNIDADE', 2, '25.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (143, 'PIX', 138.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 23:22:12');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (144, 1, 20, '2026-08-22 23:22:12', '0.00', '26.00', 'CONCLUIDA', '521456', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (246, 144, 50, NULL, NULL, 'UNIDADE', 1, '4.00'),
  (247, 144, 11, 13, NULL, 'UNIDADE', 2, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (144, 'PIX', 26.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 23:36:36');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (145, 1, 20, '2026-08-22 23:36:36', '0.00', '67.00', 'CONCLUIDA', '164260', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (248, 145, 57, NULL, NULL, 'UNIDADE', 2, '14.00'),
  (249, 145, 43, 36, NULL, 'UNIDADE', 3, '5.00'),
  (250, 145, 42, 35, NULL, 'UNIDADE', 2, '6.00'),
  (251, 145, 49, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (145, 'CREDITO', 67.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-22 23:37:49');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (146, 4, 20, '2026-08-22 23:37:49', '0.00', '4.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (252, 146, 50, NULL, NULL, 'UNIDADE', 1, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (146, 'CREDITO', 4.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-23 00:08:00');
CALL sp_fechar_caixa(20, 231.00);
UPDATE caixa SET ds_observacao = 'Faltou R$ 1.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 20;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-23 00:10:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '20', '{"diferenca": "-1.00"}', '192.168.0.11');

-- ===== 23/08/2026 (domingo) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-23 12:42:17');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-23 12:43:25');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-23 12:52:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (21, 4, '2026-08-23 12:52:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-23 13:37:06');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (147, 2, 21, '2026-08-23 13:37:06', '0.00', '50.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (253, 147, 33, NULL, NULL, 'UNIDADE', 2, '12.00'),
  (254, 147, 1, 48, NULL, 'UNIDADE', 1, '4.50'),
  (255, 147, 36, NULL, NULL, 'UNIDADE', 1, '22.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (147, 'PIX', 50.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-23 15:08:29');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (148, 4, 21, '2026-08-23 15:08:29', '0.00', '58.00', 'CONCLUIDA', '575541', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (256, 148, 11, 13, NULL, 'UNIDADE', 1, '11.00'),
  (257, 148, 16, 63, NULL, 'UNIDADE', 2, '3.50'),
  (258, 148, 40, 57, NULL, 'UNIDADE', 5, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (148, 'CREDITO', 58.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-23 16:29:13');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (149, 4, 21, '2026-08-23 16:29:13', '0.00', '30.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (259, 149, 1, 48, NULL, 'UNIDADE', 4, '4.50'),
  (260, 149, 33, NULL, NULL, 'UNIDADE', 1, '12.00');
CALL sp_registrar_venda_fiado(149, 8, '2026-09-22', 30.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-23 16:59:15');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (150, 2, 21, '2026-08-23 16:59:15', '0.00', '9.00', 'CONCLUIDA', '796244', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (261, 150, 19, 23, NULL, 'UNIDADE', 1, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (150, 'DEBITO', 9.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-23 18:44:31');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (151, 4, 21, '2026-08-23 18:44:31', '0.00', '11.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (262, 151, 11, 13, NULL, 'UNIDADE', 1, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (151, 'PIX', 5.50),
  (151, 'CREDITO', 5.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-23 19:36:16');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (152, 2, 21, '2026-08-23 19:36:16', '0.00', '6.00', 'CONCLUIDA', '775951', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (263, 152, 44, 37, NULL, 'UNIDADE', 2, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (152, 'DINHEIRO', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-23 20:50:02');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (153, 2, 21, '2026-08-23 20:50:02', '0.00', '26.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (264, 153, 36, NULL, NULL, 'UNIDADE', 1, '22.00'),
  (265, 153, 50, NULL, NULL, 'UNIDADE', 1, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (153, 'DEBITO', 26.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-23 22:37:48');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (154, 4, 21, '2026-08-23 22:37:48', '0.00', '13.50', 'CONCLUIDA', '377881', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (266, 154, 12, 14, NULL, 'UNIDADE', 3, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (154, 'CREDITO', 5.40),
  (154, 'PIX', 8.10);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-23 23:03:19');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (155, 4, 21, '2026-08-23 23:03:19', '0.00', '4.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (267, 155, 50, NULL, NULL, 'UNIDADE', 1, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (155, 'DINHEIRO', 4.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-23 23:10:31');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (156, 2, 21, '2026-08-23 23:10:31', '2.00', '28.00', 'CONCLUIDA', '213777', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (268, 156, 4, 4, NULL, 'UNIDADE', 3, '7.00'),
  (269, 156, 14, 51, NULL, 'UNIDADE', 2, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (156, 'DINHEIRO', 28.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-24 00:08:00');
SET @id_funcionario_logado = 4;
CALL sp_fechar_caixa(21, 238.00);

-- ===== 24/08/2026 (segunda) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-24 12:46:14');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-24 12:40:30');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-24 12:54:00');
SET @id_funcionario_logado = 3;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (22, 3, '2026-08-24 12:54:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-24 10:34:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (17, 3, 1, '2026-08-24 10:34:00', 'RETIRADA', '226.20', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (93, 17, 33, 6, 0, '10.20', 0),
  (94, 17, 36, 6, 0, '14.50', 0),
  (95, 17, 37, 4, 0, '16.50', 0),
  (96, 17, 50, 6, 0, '2.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-24 10:23:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (18, 5, 1, '2026-08-24 10:23:00', 'RETIRADA', '70.50', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (97, 18, 49, 5, 0, '6.50', 0),
  (98, 18, 57, 4, 0, '9.50', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-24 14:24:44');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (157, 3, 22, '2026-08-24 14:24:44', '0.00', '8.00', 'CONCLUIDA', '582522', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (270, 157, 40, 57, NULL, 'UNIDADE', 1, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (157, 'DINHEIRO', 8.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-24 14:32:56');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (158, 3, 22, '2026-08-24 14:32:56', '0.00', '62.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (271, 158, 28, NULL, NULL, 'UNIDADE', 1, '32.00'),
  (272, 158, 47, 40, NULL, 'UNIDADE', 1, '1.50'),
  (273, 158, 7, 73, NULL, 'UNIDADE', 3, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (158, 'CREDITO', 62.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-24 16:10:32');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (159, 2, 22, '2026-08-24 16:10:32', '0.00', '9.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (274, 159, 15, 18, NULL, 'UNIDADE', 3, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (159, 'DEBITO', 9.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-24 17:00:00');
SET @id_funcionario_logado = 3;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-08-24 17:00:00', nr_nota_fiscal = '786077' WHERE id_compra = 17;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 93;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 94;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 95;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 96;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (33, 3, NULL, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 17');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (36, 3, NULL, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 17');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (37, 3, NULL, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 17');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (50, 3, NULL, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 17');
SET @id_funcionario_logado = 2;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-08-24 17:00:00', nr_nota_fiscal = '678370' WHERE id_compra = 18;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 97;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 98;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (49, 2, NULL, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 18');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (57, 2, NULL, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 18');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-24 17:35:49');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (160, 3, 22, '2026-08-24 17:35:49', '0.00', '9.00', 'CONCLUIDA', '218390', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (275, 160, 15, 18, NULL, 'UNIDADE', 3, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (160, 'PIX', 9.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-24 18:51:49');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (161, 3, 22, '2026-08-24 18:51:49', '0.00', '3.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (276, 161, 47, 41, NULL, 'UNIDADE', 2, '1.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (161, 'PIX', 3.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-24 18:57:00');
SET @id_funcionario_logado = 2;
CALL sp_registrar_evento_acesso(2, 'CONSULTA_DADO_PESSOAL', 'cliente', '8', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-24 18:59:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (8, 11, 22, 'DINHEIRO', '30.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-24 23:05:00');
SET @id_funcionario_logado = 3;
CALL sp_fechar_caixa(22, 238.00);

-- ===== 25/08/2026 (terça) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-25 12:49:42');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-25 12:44:12');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-25 12:57:00');
SET @id_funcionario_logado = 1;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (23, 1, '2026-08-25 12:57:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-25 10:18:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (19, 1, 1, '2026-08-25 10:18:00', 'ENTREGA', '326.70', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (99, 19, 1, 24, 0, '3.10', 0),
  (100, 19, 4, 15, 0, '4.90', 0),
  (101, 19, 6, 12, 0, '8.00', 0),
  (102, 19, 11, 8, 0, '7.80', 0),
  (103, 19, 15, 9, 0, '1.60', 0),
  (104, 19, 16, 3, 0, '2.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-25 13:20:00');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 1, 55, 'PERDA', 2, 'Lote vencido em 23/08/2026');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-25 13:21:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '395', '{"tipo": "PERDA", "motivo": "vencimento", "lote": 55, "quantidade": 2}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-25 17:38:04');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (162, 2, 23, '2026-08-25 17:38:04', '0.00', '28.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (277, 162, 38, NULL, NULL, 'UNIDADE', 1, '6.00'),
  (278, 162, 56, NULL, NULL, 'UNIDADE', 1, '9.00'),
  (279, 162, 35, NULL, NULL, 'UNIDADE', 1, '13.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (162, 'DINHEIRO', 11.20),
  (162, 'CREDITO', 16.80);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-25 17:42:42');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (163, 2, 23, '2026-08-25 17:42:42', '0.00', '38.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (280, 163, 10, 12, NULL, 'UNIDADE', 1, '5.00'),
  (281, 163, 2, 2, NULL, 'UNIDADE', 6, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (163, 'DEBITO', 38.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-25 18:45:04');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (164, 2, 23, '2026-08-25 18:45:04', '0.00', '40.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (282, 164, 19, 23, NULL, 'UNIDADE', 2, '9.00'),
  (283, 164, 52, NULL, NULL, 'UNIDADE', 1, '22.00');
CALL sp_registrar_venda_fiado(164, 1, '2026-09-24', 40.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-25 20:15:05');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (165, 2, 23, '2026-08-25 20:15:05', '0.00', '35.00', 'CONCLUIDA', '681911', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (284, 165, 18, 22, NULL, 'UNIDADE', 1, '4.00'),
  (285, 165, 10, 12, NULL, 'UNIDADE', 2, '5.00'),
  (286, 165, 4, 4, NULL, 'UNIDADE', 3, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (165, 'DINHEIRO', 35.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-25 20:16:01');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (166, 1, 23, '2026-08-25 20:16:01', '0.00', '111.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (287, 166, 27, NULL, NULL, 'UNIDADE', 1, '34.00'),
  (288, 166, 3, 49, NULL, 'UNIDADE', 12, '3.50'),
  (289, 166, 41, 34, NULL, 'UNIDADE', 2, '6.50'),
  (290, 166, 44, 37, NULL, 'UNIDADE', 2, '3.00'),
  (291, 166, 24, 54, NULL, 'UNIDADE', 1, '16.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (166, 'DEBITO', 66.60),
  (166, 'CREDITO', 44.40);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-25 21:49:19');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (167, 1, 23, '2026-08-25 21:49:19', '0.00', '78.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (292, 167, 42, 35, NULL, 'UNIDADE', 1, '6.00'),
  (293, 167, 42, 59, NULL, 'UNIDADE', 1, '6.00'),
  (294, 167, 49, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (295, 167, 1, 48, NULL, 'UNIDADE', 5, '4.50'),
  (296, 167, 1, 60, NULL, 'UNIDADE', 7, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (167, 'DINHEIRO', 78.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-25 23:05:00');
CALL sp_fechar_caixa(23, 274.20);

-- ===== 26/08/2026 (quarta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-26 12:44:30');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-26 12:44:26');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-26 12:54:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (24, 1, '2026-08-26 12:54:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-26 10:40:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (20, 2, 1, '2026-08-26 10:40:00', 'ENTREGA', '164.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (105, 20, 22, 2, 0, '27.00', 0),
  (106, 20, 24, 2, 0, '10.50', 0),
  (107, 20, 27, 2, 0, '23.50', 0),
  (108, 20, 28, 2, 0, '21.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-26 14:30:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-08-26 14:30:00', nr_nota_fiscal = '278516' WHERE id_compra = 19;
UPDATE item_compra SET qt_recebida = 24, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 99;
UPDATE item_compra SET qt_recebida = 15, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 100;
UPDATE item_compra SET qt_recebida = 12, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 101;
UPDATE item_compra SET qt_recebida = 8, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 102;
UPDATE item_compra SET qt_recebida = 9, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 103;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 104;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (78, 99, 'L2608260178', '2027-03-07', 0),
  (79, 99, 'L2608260179', '2027-04-10', 0),
  (80, 100, 'L2608260480', '2027-02-14', 0),
  (81, 100, 'L2608260481', '2027-03-21', 0),
  (82, 101, 'L2608260682', '2027-01-31', 0),
  (83, 102, 'L2608261183', '2027-03-10', 0),
  (84, 103, 'L2608261584', '2027-06-09', 0),
  (85, 104, 'L2608261685', '2027-05-24', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (1, 1, 78, 'ENTRADA_COMPRA', 12, 'Recebimento da compra 19');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (1, 1, 79, 'ENTRADA_COMPRA', 12, 'Recebimento da compra 19');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (4, 1, 80, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 19');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (4, 1, 81, 'ENTRADA_COMPRA', 8, 'Recebimento da compra 19');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (6, 1, 82, 'ENTRADA_COMPRA', 12, 'Recebimento da compra 19');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (11, 1, 83, 'ENTRADA_COMPRA', 8, 'Recebimento da compra 19');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (15, 1, 84, 'ENTRADA_COMPRA', 9, 'Recebimento da compra 19');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (16, 1, 85, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 19');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-26 15:16:00');
CALL sp_registrar_evento_acesso(1, 'CONSULTA_DADO_PESSOAL', 'cliente', '3', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-26 15:18:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (9, 6, 24, 'PIX', '75.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-26 16:19:00');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (1, 1, 78, 'PERDA', 3, 'Caiu no chão durante a reposição');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-26 16:20:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '424', '{"tipo": "PERDA", "motivo": "Caiu no chão durante a reposição", "quantidade": 3}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-26 17:01:24');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (168, 1, 24, '2026-08-26 17:01:24', '0.00', '24.00', 'CONCLUIDA', '514450', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (297, 168, 33, NULL, NULL, 'UNIDADE', 2, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (168, 'DINHEIRO', 12.00),
  (168, 'PIX', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-26 17:17:47');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (169, 1, 24, '2026-08-26 17:17:47', '0.00', '27.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (298, 169, 14, 51, NULL, 'UNIDADE', 2, '4.50'),
  (299, 169, 1, 78, NULL, 'UNIDADE', 4, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (169, 'DEBITO', 27.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-26 18:54:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (21, 24, 1, 'DESPESA', '50.00', 'Sacolas e embalagens');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-26 19:47:52');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (170, 1, 24, '2026-08-26 19:47:52', '0.00', '43.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (300, 170, 6, 6, NULL, 'UNIDADE', 3, '11.00'),
  (301, 170, 10, 12, NULL, 'UNIDADE', 2, '5.00');
CALL sp_registrar_venda_fiado(170, 8, '2026-09-25', 43.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-26 22:46:30');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (171, 1, 24, '2026-08-26 22:46:30', '0.00', '30.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (302, 171, 42, 59, NULL, 'UNIDADE', 5, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (171, 'PIX', 30.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-26 23:05:00');
CALL sp_fechar_caixa(24, 62.00);

-- ===== 27/08/2026 (quinta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-27 12:47:25');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-27 12:45:34');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-27 12:51:00');
SET @id_funcionario_logado = 3;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (25, 3, '2026-08-27 12:51:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-27 10:03:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (21, 4, 1, '2026-08-27 10:03:00', 'ENTREGA', '181.60', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (109, 21, 39, 8, 0, '4.60', 0),
  (110, 21, 40, 9, 0, '5.40', 0),
  (111, 21, 41, 6, 0, '4.20', 0),
  (112, 21, 42, 13, 0, '4.00', 0),
  (113, 21, 44, 7, 0, '1.80', 0),
  (114, 21, 45, 8, 0, '0.50', 0),
  (115, 21, 54, 2, 0, '1.20', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-27 10:31:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (22, 5, 1, '2026-08-27 10:31:00', 'RETIRADA', '45.40', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (116, 22, 52, 2, 0, '14.00', 0),
  (117, 22, 60, 3, 0, '5.80', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-27 14:30:00');
SET @id_funcionario_logado = 4;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-08-27 14:30:00', nr_nota_fiscal = '314055' WHERE id_compra = 20;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 105;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 106;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 107;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 108;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (86, 105, 'L2608272286', '2028-05-06', 0),
  (87, 106, 'L2608272487', '2027-10-30', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (22, 4, 86, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 20');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (24, 4, 87, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 20');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (27, 4, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 20');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (28, 4, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 20');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-27 15:07:53');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (172, 4, 25, '2026-08-27 15:07:53', '0.00', '64.50', 'CONCLUIDA', '909489', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (303, 172, 12, 14, NULL, 'UNIDADE', 2, '4.50'),
  (304, 172, 33, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (305, 172, 39, 32, NULL, 'UNIDADE', 1, '7.00'),
  (306, 172, 1, 78, NULL, 'UNIDADE', 5, '4.50'),
  (307, 172, 1, 60, NULL, 'UNIDADE', 1, '4.50'),
  (308, 172, 5, 5, NULL, 'UNIDADE', 1, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (172, 'PIX', 25.80),
  (172, 'CREDITO', 38.70);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-27 15:25:58');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (173, 3, 25, '2026-08-27 15:25:58', '0.00', '8.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (309, 173, 18, 22, NULL, 'UNIDADE', 2, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (173, 'CREDITO', 8.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-27 15:30:00');
SET @id_funcionario_logado = 4;
CALL sp_registrar_evento_acesso(4, 'CONSULTA_DADO_PESSOAL', 'cliente', '3', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-27 15:32:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (10, 1, 25, 'CREDITO', '7.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-27 17:00:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-08-27 17:00:00', nr_nota_fiscal = '139997' WHERE id_compra = 22;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 116;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 117;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (88, 117, 'L2608276088', '2026-09-05', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (52, 4, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 22');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 4, 88, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 22');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-27 18:10:12');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (174, 3, 25, '2026-08-27 18:10:12', '0.00', '9.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (310, 174, 17, 21, NULL, 'UNIDADE', 1, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (174, 'DEBITO', 9.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-27 18:59:13');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (175, 4, 25, '2026-08-27 18:59:13', '0.00', '21.00', 'CONCLUIDA', '102279', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (311, 175, 39, 32, NULL, 'UNIDADE', 3, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (175, 'DEBITO', 21.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-27 19:27:28');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (176, 3, 25, '2026-08-27 19:27:28', '0.00', '36.00', 'CONCLUIDA', '628834', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (312, 176, 20, 24, NULL, 'UNIDADE', 2, '7.00'),
  (313, 176, 52, NULL, NULL, 'UNIDADE', 1, '22.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (176, 'PIX', 36.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-27 20:59:00');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (177, 3, 25, '2026-08-27 20:59:00', '0.00', '19.00', 'CONCLUIDA', '431055', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (314, 177, 5, 5, NULL, 'UNIDADE', 2, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (177, 'DINHEIRO', 19.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-27 21:44:00');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (178, 3, 25, '2026-08-27 21:44:00', '0.00', '49.50', 'CONCLUIDA', '906712', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (315, 178, 5, 5, NULL, 'UNIDADE', 1, '9.50'),
  (316, 178, 6, 6, NULL, 'UNIDADE', 1, '11.00'),
  (317, 178, 46, 39, NULL, 'UNIDADE', 1, '6.00'),
  (318, 178, 2, 2, NULL, 'UNIDADE', 2, '5.50'),
  (319, 178, 49, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (178, 'PIX', 49.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-27 23:05:00');
CALL sp_fechar_caixa(25, 169.00);

-- ===== 28/08/2026 (sexta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-28 12:46:32');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-28 12:42:38');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-28 12:41:38');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-28 12:52:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (26, 3, '2026-08-28 12:52:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-28 10:32:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (23, 1, 1, '2026-08-28 10:32:00', 'ENTREGA', '291.70', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (118, 23, 1, 25, 0, '3.10', 0),
  (119, 23, 3, 15, 0, '2.40', 0),
  (120, 23, 5, 13, 0, '6.80', 0),
  (121, 23, 12, 6, 0, '3.10', 0),
  (122, 23, 14, 4, 0, '3.10', 0),
  (123, 23, 18, 3, 0, '2.60', 0),
  (124, 23, 19, 6, 0, '6.20', 0),
  (125, 23, 20, 3, 0, '4.60', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-28 14:07:04');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (179, 1, 26, '2026-08-28 14:07:04', '0.00', '32.00', 'CONCLUIDA', '863017', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (320, 179, 43, 36, NULL, 'UNIDADE', 1, '5.00'),
  (321, 179, 11, 13, NULL, 'UNIDADE', 2, '11.00'),
  (322, 179, 10, 12, NULL, 'UNIDADE', 1, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (179, 'PIX', 32.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-28 14:30:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-08-28 14:30:00', nr_nota_fiscal = '110088' WHERE id_compra = 21;
UPDATE item_compra SET qt_recebida = 8, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 109;
UPDATE item_compra SET qt_recebida = 9, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 110;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 111;
UPDATE item_compra SET qt_recebida = 13, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 112;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 113;
UPDATE item_compra SET qt_recebida = 8, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 114;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 115;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (89, 109, 'L2608283989', '2026-11-07', 0),
  (90, 109, 'L2608283990', '2026-12-09', 0),
  (91, 110, 'L2608284091', '2026-10-30', 0),
  (92, 110, 'L2608284092', '2026-11-29', 0),
  (93, 111, 'L2608284193', '2027-03-03', 0),
  (94, 112, 'L2608284294', '2027-01-28', 0),
  (95, 113, 'L2608284495', '2027-03-18', 0),
  (96, 114, 'L2608284596', '2027-01-28', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (39, 1, 89, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 21');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (39, 1, 90, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 21');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (40, 1, 91, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 21');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (40, 1, 92, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 21');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (41, 1, 93, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 21');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (42, 1, 94, 'ENTRADA_COMPRA', 13, 'Recebimento da compra 21');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (44, 1, 95, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 21');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (45, 1, 96, 'ENTRADA_COMPRA', 8, 'Recebimento da compra 21');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (54, 1, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 21');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-28 14:32:16');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (180, 2, 26, '2026-08-28 14:32:16', '0.00', '8.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (323, 180, 40, 57, NULL, 'UNIDADE', 1, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (180, 'DEBITO', 8.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-28 14:40:16');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (181, 1, 26, '2026-08-28 14:40:16', '5.00', '45.00', 'CONCLUIDA', '385973', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (324, 181, 4, 4, NULL, 'UNIDADE', 6, '7.00'),
  (325, 181, 48, 43, NULL, 'UNIDADE', 2, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (181, 'DINHEIRO', 45.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-28 16:28:03');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (182, 2, 26, '2026-08-28 16:28:03', '0.00', '15.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (326, 182, 15, 18, NULL, 'UNIDADE', 2, '3.00'),
  (327, 182, 17, 21, NULL, 'UNIDADE', 1, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (182, 'PIX', 15.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-28 17:06:00');
SET @id_funcionario_logado = 3;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (22, 26, 3, 'DESPESA', '50.00', 'Café e água dos funcionários');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-28 17:55:21');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (183, 1, 26, '2026-08-28 17:55:21', '0.00', '84.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (328, 183, 4, 4, NULL, 'UNIDADE', 4, '7.00'),
  (329, 183, 4, 80, NULL, 'UNIDADE', 7, '7.00'),
  (330, 183, 4, 71, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (183, 'PIX', 84.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-28 18:11:03');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (184, 3, 26, '2026-08-28 18:11:03', '0.00', '60.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (331, 184, 39, 32, NULL, 'UNIDADE', 5, '7.00'),
  (332, 184, 37, NULL, NULL, 'UNIDADE', 1, '25.00');
CALL sp_registrar_venda_fiado(184, 8, '2026-09-27', 60.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-28 21:03:48');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (185, 3, 26, '2026-08-28 21:03:48', '0.00', '64.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (333, 185, 52, NULL, NULL, 'UNIDADE', 1, '22.00'),
  (334, 185, 8, 61, NULL, 'UNIDADE', 6, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (185, 'CREDITO', 38.40),
  (185, 'DEBITO', 25.60);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-28 21:33:51');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (186, 1, 26, '2026-08-28 21:33:51', '0.00', '141.00', 'CONCLUIDA', '883379', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (335, 186, 4, 71, NULL, 'UNIDADE', 6, '7.00'),
  (336, 186, 56, NULL, NULL, 'UNIDADE', 1, '9.00'),
  (337, 186, 34, NULL, NULL, 'UNIDADE', 1, '14.00'),
  (338, 186, 33, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (339, 186, 28, NULL, NULL, 'UNIDADE', 2, '32.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (186, 'PIX', 56.40),
  (186, 'DINHEIRO', 84.60);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-28 22:02:22');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (187, 2, 26, '2026-08-28 22:02:22', '0.00', '34.50', 'CONCLUIDA', '158462', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (340, 187, 43, 36, NULL, 'UNIDADE', 5, '5.00'),
  (341, 187, 10, 12, NULL, 'UNIDADE', 1, '5.00'),
  (342, 187, 14, 76, NULL, 'UNIDADE', 1, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (187, 'CREDITO', 20.70),
  (187, 'PIX', 13.80);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-29 00:08:00');
SET @id_funcionario_logado = 3;
CALL sp_fechar_caixa(26, 179.60);

-- ===== 29/08/2026 (sábado) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-29 12:49:32');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-29 12:45:31');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-29 12:48:28');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-29 12:58:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (27, 3, '2026-08-29 12:58:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-29 14:30:00');
SET @id_funcionario_logado = 1;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-08-29 14:30:00', nr_nota_fiscal = '955030' WHERE id_compra = 23;
UPDATE item_compra SET qt_recebida = 25, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 118;
UPDATE item_compra SET qt_recebida = 15, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 119;
UPDATE item_compra SET qt_recebida = 13, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 120;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 121;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 122;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 123;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 124;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 125;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (97, 118, 'L2608290197', '2027-03-15', 0),
  (98, 119, 'L2608290398', '2027-04-03', 0),
  (99, 120, 'L2608290599', '2027-02-07', 0),
  (100, 121, 'L2608291200', '2027-02-27', 0),
  (101, 122, 'L2608291401', '2027-02-10', 0),
  (102, 123, 'L2608291802', '2027-02-18', 0),
  (103, 124, 'L2608291903', '2027-04-17', 0),
  (104, 125, 'L2608292004', '2027-03-05', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (1, 1, 97, 'ENTRADA_COMPRA', 25, 'Recebimento da compra 23');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (3, 1, 98, 'ENTRADA_COMPRA', 15, 'Recebimento da compra 23');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (5, 1, 99, 'ENTRADA_COMPRA', 13, 'Recebimento da compra 23');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (12, 1, 100, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 23');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (14, 1, 101, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 23');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (18, 1, 102, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 23');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (19, 1, 103, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 23');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (20, 1, 104, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 23');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-29 16:26:36');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (188, 4, 27, '2026-08-29 16:26:36', '0.00', '28.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (343, 188, 4, 81, NULL, 'UNIDADE', 4, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (188, 'DINHEIRO', 28.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-29 16:49:51');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (189, 1, 27, '2026-08-29 16:49:51', '0.00', '5.00', 'CONCLUIDA', '105219', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (344, 189, 10, 12, NULL, 'UNIDADE', 1, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (189, 'PIX', 5.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-29 18:10:04');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (190, 1, 27, '2026-08-29 18:10:04', '0.00', '2.00', 'CONCLUIDA', '588307', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (345, 190, 45, 96, NULL, 'UNIDADE', 2, '1.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (190, 'CREDITO', 2.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-29 19:39:40');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (191, 4, 27, '2026-08-29 19:39:40', '0.00', '92.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (346, 191, 1, 97, NULL, 'UNIDADE', 2, '4.50'),
  (347, 191, 30, NULL, NULL, 'UNIDADE', 2, '36.00'),
  (348, 191, 2, 2, NULL, 'UNIDADE', 2, '5.50');
CALL sp_registrar_venda_fiado(191, 6, '2026-09-28', 92.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-29 19:54:48');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (192, 4, 27, '2026-08-29 19:54:48', '0.00', '15.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (349, 192, 47, 41, NULL, 'UNIDADE', 3, '1.50'),
  (350, 192, 41, 34, NULL, 'UNIDADE', 1, '6.50'),
  (351, 192, 24, NULL, 3, 'DOSE', 1, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (192, 'DEBITO', 15.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-29 20:10:39');
CALL sp_abrir_garrafa(29, 4, @garrafa);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-29 20:11:39');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (193, 4, 27, '2026-08-29 20:11:39', '0.00', '252.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (352, 193, 25, NULL, 4, 'DOSE', 1, '10.00'),
  (353, 193, 23, 53, NULL, 'UNIDADE', 1, '89.00'),
  (354, 193, 6, 6, NULL, 'UNIDADE', 12, '11.00'),
  (355, 193, 42, 59, NULL, 'UNIDADE', 2, '6.00'),
  (356, 193, 14, 76, NULL, 'UNIDADE', 1, '4.50'),
  (357, 193, 14, 101, NULL, 'UNIDADE', 1, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (193, 'DEBITO', 252.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-29 20:16:51');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (194, 4, 27, '2026-08-29 20:16:51', '0.00', '76.00', 'CONCLUIDA', '632003', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (358, 194, 51, NULL, NULL, 'UNIDADE', 1, '8.00'),
  (359, 194, 52, NULL, NULL, 'UNIDADE', 1, '22.00'),
  (360, 194, 2, 2, NULL, 'UNIDADE', 4, '5.50'),
  (361, 194, 49, NULL, NULL, 'UNIDADE', 2, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (194, 'PIX', 54.00);
CALL sp_registrar_venda_fiado(194, 4, '2026-09-28', 22.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-29 21:24:35');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (195, 4, 27, '2026-08-29 21:24:35', '0.00', '9.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (362, 195, 7, 73, NULL, 'UNIDADE', 1, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (195, 'DINHEIRO', 9.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-29 21:57:11');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (196, 3, 27, '2026-08-29 21:57:11', '0.00', '11.50', 'CONCLUIDA', '530845', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (363, 196, 50, NULL, NULL, 'UNIDADE', 2, '4.00'),
  (364, 196, 16, 63, NULL, 'UNIDADE', 1, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (196, 'DINHEIRO', 5.70),
  (196, 'PIX', 5.80);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-29 21:58:43');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (197, 1, 27, '2026-08-29 21:58:43', '0.00', '28.00', 'CONCLUIDA', '720798', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (365, 197, 19, 23, NULL, 'UNIDADE', 1, '9.00'),
  (366, 197, 7, 73, NULL, 'UNIDADE', 2, '9.50');
CALL sp_registrar_venda_fiado(197, 6, '2026-09-28', 28.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-30 00:08:00');
SET @id_funcionario_logado = 3;
CALL sp_fechar_caixa(27, 143.20);

-- ===== 30/08/2026 (domingo) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-30 12:41:13');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-30 12:45:35');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-30 12:59:00');
SET @id_funcionario_logado = 2;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (28, 2, '2026-08-30 12:59:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-30 14:01:14');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (198, 4, 28, '2026-08-30 14:01:14', '0.00', '31.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (367, 198, 49, NULL, NULL, 'UNIDADE', 2, '12.00'),
  (368, 198, 4, 81, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (198, 'DEBITO', 31.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-30 14:59:50');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (199, 2, 28, '2026-08-30 14:59:50', '0.00', '9.00', 'CONCLUIDA', '717824', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (369, 199, 15, 18, NULL, 'UNIDADE', 3, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (199, 'PIX', 9.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-30 17:10:08');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (200, 2, 28, '2026-08-30 17:10:08', '0.00', '10.50', 'CONCLUIDA', '668382', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (370, 200, 12, 14, NULL, 'UNIDADE', 1, '4.50'),
  (371, 200, 38, NULL, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (200, 'PIX', 10.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-30 18:35:24');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (201, 2, 28, '2026-08-30 18:35:24', '2.00', '35.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (372, 201, 12, 14, NULL, 'UNIDADE', 2, '4.50'),
  (373, 201, 42, 94, NULL, 'UNIDADE', 2, '6.00'),
  (374, 201, 2, 2, NULL, 'UNIDADE', 3, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (201, 'PIX', 35.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-30 19:13:32');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (202, 2, 28, '2026-08-30 19:13:32', '0.00', '33.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (375, 202, 51, NULL, NULL, 'UNIDADE', 1, '8.00'),
  (376, 202, 39, 32, NULL, 'UNIDADE', 1, '7.00'),
  (377, 202, 53, NULL, NULL, 'UNIDADE', 2, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (202, 'DEBITO', 13.20),
  (202, 'DINHEIRO', 19.80);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-30 19:51:09');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (203, 4, 28, '2026-08-30 19:51:09', '0.00', '28.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (378, 203, 33, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (379, 203, 51, NULL, NULL, 'UNIDADE', 2, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (203, 'CREDITO', 28.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-30 21:32:27');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (204, 4, 28, '2026-08-30 21:32:27', '0.00', '32.00', 'CONCLUIDA', '293807', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (380, 204, 28, NULL, NULL, 'UNIDADE', 1, '32.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (204, 'PIX', 32.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-30 22:30:29');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (205, 2, 28, '2026-08-30 22:30:29', '0.00', '28.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (381, 205, 5, 5, NULL, 'UNIDADE', 3, '9.50');
CALL sp_registrar_venda_fiado(205, 1, '2026-09-29', 28.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-30 23:21:12');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (206, 2, 28, '2026-08-30 23:21:12', '0.00', '1.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (382, 206, 47, 41, NULL, 'UNIDADE', 1, '1.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (206, 'CREDITO', 1.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-31 00:08:00');
CALL sp_fechar_caixa(28, 119.80);

-- ===== 31/08/2026 (segunda) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-31 12:41:52');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-31 12:40:15');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-31 12:53:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (29, 2, '2026-08-31 12:53:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-31 10:02:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (24, 3, 1, '2026-08-31 10:02:00', 'RETIRADA', '22.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (126, 24, 35, 2, 0, '11.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-31 10:29:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (25, 5, 1, '2026-08-31 10:29:00', 'RETIRADA', '94.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (127, 25, 49, 6, 0, '6.50', 0),
  (128, 25, 52, 3, 0, '14.00', 0),
  (129, 25, 56, 2, 0, '6.50', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-31 14:05:00');
SET @id_funcionario_logado = 2;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (23, 29, 2, 'DESPESA', '50.00', 'Material de limpeza');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-31 17:00:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-08-31 17:00:00', nr_nota_fiscal = '579514' WHERE id_compra = 24;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 126;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (35, 2, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 24');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-08-31 17:00:00', nr_nota_fiscal = '238614' WHERE id_compra = 25;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 127;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 128;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 129;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (49, 2, NULL, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 25');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (52, 2, NULL, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 25');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (56, 2, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 25');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-31 17:29:05');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (207, 3, 29, '2026-08-31 17:29:05', '0.00', '25.00', 'CONCLUIDA', '616516', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (383, 207, 46, 39, NULL, 'UNIDADE', 2, '6.00'),
  (384, 207, 43, 36, NULL, 'UNIDADE', 1, '5.00'),
  (385, 207, 40, 57, NULL, 'UNIDADE', 1, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (207, 'PIX', 25.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-31 18:46:16');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (208, 3, 29, '2026-08-31 18:46:16', '0.00', '4.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (386, 208, 12, 14, NULL, 'UNIDADE', 1, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (208, 'PIX', 4.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-31 19:00:24');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (209, 3, 29, '2026-08-31 19:00:24', '0.00', '7.00', 'CONCLUIDA', '137877', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (387, 209, 39, 89, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (209, 'CREDITO', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-31 19:19:10');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (210, 2, 29, '2026-08-31 19:19:10', '0.00', '3.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (388, 210, 16, 85, NULL, 'UNIDADE', 1, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (210, 'DEBITO', 3.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-31 19:18:00');
SET @id_funcionario_logado = 3;
CALL sp_registrar_evento_acesso(3, 'CONSULTA_DADO_PESSOAL', 'cliente', '1', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-31 19:20:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (11, 12, 29, 'PIX', '40.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-31 19:22:00');
SET @id_funcionario_logado = 2;
CALL sp_registrar_evento_acesso(2, 'CONSULTA_DADO_PESSOAL', 'cliente', '6', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-31 19:24:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (12, 15, 29, 'DINHEIRO', '30.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-31 23:05:00');
CALL sp_fechar_caixa(29, 129.00);
UPDATE caixa SET ds_observacao = 'Faltou R$ 1.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 29;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-08-31 23:07:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '29', '{"diferenca": "-1.00"}', '192.168.0.11');

-- ===== 01/09/2026 (terça) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-01 10:00:00');
SET @id_funcionario_logado = 1;
INSERT INTO cliente (id_cliente, nm_cliente, nr_cpf, dt_nascimento, nr_telefone, vl_limite_fiado, dt_consentimento_lgpd, dt_cadastro) VALUES (9, 'Igor Valadares Cunha', '91000000009', '2003-05-25', '(11) 99000-0009', '0.00', '2026-09-01 10:00:00', '2026-09-01 10:00:00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-01 10:05:00');
CALL sp_autorizar_cliente_fiado(9, 100.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-01 12:40:00');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-01 12:44:18');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-01 12:50:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (30, 1, '2026-09-01 12:50:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-01 11:30:00');
UPDATE produto SET vl_venda = 5.00 WHERE id_produto = 1;
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'UPDATE', 'produto', '1', '{"coluna": "vl_venda", "antes": "4.50", "depois": "5.00"}', '192.168.0.11');
UPDATE produto SET vl_venda = 6.00 WHERE id_produto = 2;
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'UPDATE', 'produto', '2', '{"coluna": "vl_venda", "antes": "5.50", "depois": "6.00"}', '192.168.0.11');
UPDATE produto SET vl_venda = 5.50 WHERE id_produto = 10;
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'UPDATE', 'produto', '10', '{"coluna": "vl_venda", "antes": "5.00", "depois": "5.50"}', '192.168.0.11');
UPDATE produto SET vl_venda = 12.50 WHERE id_produto = 34;
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'UPDATE', 'produto', '34', '{"coluna": "vl_venda", "antes": "14.00", "depois": "12.50"}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-01 10:06:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (26, 1, 1, '2026-09-01 10:06:00', 'ENTREGA', '462.05', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (130, 26, 2, 23, 0, '3.85', 0),
  (131, 26, 4, 32, 0, '4.90', 0),
  (132, 26, 6, 16, 0, '8.00', 0),
  (133, 26, 7, 10, 0, '6.70', 0),
  (134, 26, 14, 3, 0, '3.10', 0),
  (135, 26, 17, 2, 0, '6.20', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-01 13:05:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (24, 30, 1, 'SUPRIMENTO', '50.00', 'Reforço de troco para o caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-01 14:42:36');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (211, 2, 30, '2026-09-01 14:42:36', '0.00', '25.50', 'CONCLUIDA', '260165', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (389, 211, 10, 12, NULL, 'UNIDADE', 1, '5.50'),
  (390, 211, 42, 94, NULL, 'UNIDADE', 2, '6.00'),
  (391, 211, 50, NULL, NULL, 'UNIDADE', 2, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (211, 'CREDITO', 15.30),
  (211, 'DINHEIRO', 10.20);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-01 14:52:57');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (212, 1, 30, '2026-09-01 14:52:57', '0.00', '9.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (392, 212, 12, 14, NULL, 'UNIDADE', 2, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (212, 'DEBITO', 9.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-01 15:02:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (25, 30, 1, 'DESPESA', '50.00', 'Compra de gelo para o balcão');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-01 18:11:50');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (213, 1, 30, '2026-09-01 18:11:50', '2.00', '77.00', 'CONCLUIDA', '364183', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (393, 213, 30, NULL, NULL, 'UNIDADE', 2, '36.00'),
  (394, 213, 39, 89, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (213, 'PIX', 77.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-01 18:57:08');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (214, 1, 30, '2026-09-01 18:57:08', '0.00', '20.00', 'CONCLUIDA', '403563', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (395, 214, 1, 97, NULL, 'UNIDADE', 4, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (214, 'DEBITO', 20.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-01 21:19:27');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (215, 2, 30, '2026-09-01 21:19:27', '0.00', '11.00', 'CONCLUIDA', '856316', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (396, 215, 40, 57, NULL, 'UNIDADE', 1, '8.00'),
  (397, 215, 15, 18, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (215, 'DINHEIRO', 11.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-01 21:44:30');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (216, 1, 30, '2026-09-01 21:44:30', '0.00', '14.00', 'CONCLUIDA', '165105', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (398, 216, 4, 81, NULL, 'UNIDADE', 2, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (216, 'DEBITO', 14.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-01 23:05:00');
CALL sp_fechar_caixa(30, 121.20);

-- ===== 02/09/2026 (quarta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-02 12:48:35');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-02 12:49:51');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-02 12:50:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (31, 1, '2026-09-02 12:50:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-02 10:20:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (27, 2, 1, '2026-09-02 10:20:00', 'ENTREGA', '183.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (136, 27, 28, 3, 0, '21.00', 0),
  (137, 27, 30, 5, 0, '24.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-02 13:20:00');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (59, 1, 44, 'PERDA', 7, 'Lote vencido em 01/09/2026');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-02 13:21:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '553', '{"tipo": "PERDA", "motivo": "vencimento", "lote": 44, "quantidade": 7}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-02 14:30:00');
SET @id_funcionario_logado = 4;
UPDATE compra SET st_compra = 'RECEBIDA_PARCIAL', dt_recebimento = '2026-09-02 14:30:00', nr_nota_fiscal = '763145' WHERE id_compra = 26;
UPDATE item_compra SET qt_recebida = 23, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 130;
UPDATE item_compra SET qt_recebida = 32, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 131;
UPDATE item_compra SET qt_recebida = 14, fl_conferido = 1, ds_divergencia = 'Faltaram 2 unidades na entrega' WHERE id_item_compra = 132;
UPDATE item_compra SET qt_recebida = 10, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 133;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 134;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 135;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (105, 130, 'L2609020205', '2027-03-20', 0),
  (106, 131, 'L2609020406', '2027-04-05', 0),
  (107, 132, 'L2609020607', '2027-03-07', 0),
  (108, 133, 'L2609020708', '2027-04-17', 0),
  (109, 134, 'L2609021409', '2027-01-13', 0),
  (110, 135, 'L2609021710', '2026-11-09', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (2, 4, 105, 'ENTRADA_COMPRA', 23, 'Recebimento da compra 26');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (4, 4, 106, 'ENTRADA_COMPRA', 32, 'Recebimento da compra 26');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (6, 4, 107, 'ENTRADA_COMPRA', 14, 'Recebimento da compra 26');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (7, 4, 108, 'ENTRADA_COMPRA', 10, 'Recebimento da compra 26');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (14, 4, 109, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 26');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (17, 4, 110, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 26');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-02 15:01:00');
SET @id_funcionario_logado = 1;
CALL sp_registrar_evento_acesso(1, 'CONSULTA_DADO_PESSOAL', 'cliente', '3', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-02 15:03:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (13, 6, 31, 'DINHEIRO', '30.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-02 15:49:59');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (217, 1, 31, '2026-09-02 15:49:59', '0.00', '12.00', 'CONCLUIDA', '737337', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (399, 217, 49, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (217, 'CREDITO', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-02 16:37:22');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (218, 1, 31, '2026-09-02 16:37:22', '0.00', '34.00', 'CONCLUIDA', '774726', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (400, 218, 27, NULL, NULL, 'UNIDADE', 1, '34.00');
CALL sp_registrar_venda_fiado(218, 9, '2026-10-02', 34.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-02 17:32:23');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (219, 1, 31, '2026-09-02 17:32:23', '0.00', '9.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (401, 219, 15, 18, NULL, 'UNIDADE', 3, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (219, 'DINHEIRO', 9.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-02 18:25:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (26, 31, 1, 'DESPESA', '50.00', 'Compra de gelo para o balcão');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-02 19:58:11');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (220, 4, 31, '2026-09-02 19:58:11', '0.00', '33.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (402, 220, 1, 97, NULL, 'UNIDADE', 1, '5.00'),
  (403, 220, 36, NULL, NULL, 'UNIDADE', 1, '22.00'),
  (404, 220, 41, 34, NULL, 'UNIDADE', 1, '6.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (220, 'DINHEIRO', 33.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-02 21:41:49');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (221, 1, 31, '2026-09-02 21:41:49', '0.00', '48.50', 'CONCLUIDA', '298167', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (405, 221, 37, NULL, NULL, 'UNIDADE', 1, '25.00'),
  (406, 221, 12, 100, NULL, 'UNIDADE', 1, '4.50'),
  (407, 221, 5, 5, NULL, 'UNIDADE', 2, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (221, 'CREDITO', 48.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-02 23:05:00');
CALL sp_fechar_caixa(31, 125.50);
UPDATE caixa SET ds_observacao = 'Sobrou R$ 3.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 31;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-02 23:07:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '31', '{"diferenca": "3.00"}', '192.168.0.11');

-- ===== 03/09/2026 (quinta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-03 10:00:00');
INSERT INTO cliente (id_cliente, nm_cliente, nr_cpf, dt_nascimento, nr_telefone, vl_limite_fiado, dt_consentimento_lgpd, dt_cadastro) VALUES (10, 'Joana Machado Teles', '91000000010', '1990-03-07', '(11) 99000-0010', '0.00', '2026-09-03 10:00:00', '2026-09-03 10:00:00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-03 10:05:00');
CALL sp_autorizar_cliente_fiado(10, 200.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-03 12:45:40');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-03 12:40:04');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-03 12:56:00');
SET @id_funcionario_logado = 3;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (32, 3, '2026-09-03 12:56:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-03 10:34:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (28, 4, 1, '2026-09-03 10:34:00', 'ENTREGA', '153.70', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (138, 28, 39, 12, 0, '4.60', 0),
  (139, 28, 42, 6, 0, '4.00', 0),
  (140, 28, 43, 8, 0, '3.10', 0),
  (141, 28, 47, 7, 0, '0.80', 0),
  (142, 28, 48, 3, 0, '2.50', 0),
  (143, 28, 51, 5, 0, '5.00', 0),
  (144, 28, 53, 2, 0, '5.80', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-03 10:00:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (29, 5, 1, '2026-09-03 10:00:00', 'RETIRADA', '26.40', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (145, 29, 59, 6, 0, '4.40', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-03 14:30:00');
SET @id_funcionario_logado = 4;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-03 14:30:00', nr_nota_fiscal = '926899' WHERE id_compra = 27;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 136;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 137;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (28, 4, NULL, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 27');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (30, 4, NULL, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 27');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-03 15:36:17');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (222, 3, 32, '2026-09-03 15:36:17', '0.00', '6.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (408, 222, 42, 94, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (222, 'DEBITO', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-03 17:00:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-03 17:00:00', nr_nota_fiscal = '460002' WHERE id_compra = 29;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 145;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (111, 145, 'L2609035911', '2026-10-02', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (59, 3, 111, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 29');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-03 18:47:00');
CALL sp_registrar_evento_acesso(3, 'CONSULTA_DADO_PESSOAL', 'cliente', '1', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-03 18:49:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (14, 7, 32, 'DINHEIRO', '27.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-03 19:07:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (27, 32, 3, 'DESPESA', '15.00', 'Material de limpeza');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-03 19:09:39');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (223, 3, 32, '2026-09-03 19:09:39', '0.00', '18.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (409, 223, 17, 46, NULL, 'UNIDADE', 2, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (223, 'DEBITO', 18.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-03 19:22:35');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (224, 3, 32, '2026-09-03 19:22:35', '0.00', '44.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (410, 224, 3, 49, NULL, 'UNIDADE', 6, '3.50'),
  (411, 224, 11, 13, NULL, 'UNIDADE', 1, '11.00'),
  (412, 224, 33, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (224, 'DINHEIRO', 44.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-03 21:18:39');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (225, 4, 32, '2026-09-03 21:18:39', '0.00', '12.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (413, 225, 46, 39, NULL, 'UNIDADE', 2, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (225, 'CREDITO', 7.20),
  (225, 'PIX', 4.80);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-03 22:28:48');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (226, 3, 32, '2026-09-03 22:28:48', '0.00', '18.00', 'CONCLUIDA', '463996', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (414, 226, 42, 94, NULL, 'UNIDADE', 3, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (226, 'DEBITO', 18.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-03 23:05:00');
CALL sp_fechar_caixa(32, 208.00);
UPDATE caixa SET ds_observacao = 'Sobrou R$ 2.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 32;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-03 23:07:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '32', '{"diferenca": "2.00"}', '192.168.0.11');

-- ===== 04/09/2026 (sexta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-04 12:44:44');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-04 12:44:10');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-04 12:40:59');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-04 12:54:00');
SET @id_funcionario_logado = 1;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (33, 1, '2026-09-04 12:54:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-04 10:13:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (30, 1, 1, '2026-09-04 10:13:00', 'ENTREGA', '79.10', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (146, 30, 10, 9, 0, '3.40', 0),
  (147, 30, 12, 7, 0, '3.10', 0),
  (148, 30, 15, 9, 0, '1.60', 0),
  (149, 30, 17, 2, 0, '6.20', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-04 13:35:59');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (227, 1, 33, '2026-09-04 13:35:59', '0.00', '13.00', 'CONCLUIDA', '543325', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (415, 227, 35, NULL, NULL, 'UNIDADE', 1, '13.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (227, 'DINHEIRO', 13.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-04 13:42:57');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (228, 2, 33, '2026-09-04 13:42:57', '0.00', '66.00', 'CONCLUIDA', '803436', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (416, 228, 11, 13, NULL, 'UNIDADE', 2, '11.00'),
  (417, 228, 52, NULL, NULL, 'UNIDADE', 2, '22.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (228, 'CREDITO', 66.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-04 14:30:00');
SET @id_funcionario_logado = 1;
UPDATE compra SET st_compra = 'RECEBIDA_PARCIAL', dt_recebimento = '2026-09-04 14:30:00', nr_nota_fiscal = '487307' WHERE id_compra = 28;
UPDATE item_compra SET qt_recebida = 11, fl_conferido = 1, ds_divergencia = '1 unidades avariadas, devolvidas ao fornecedor' WHERE id_item_compra = 138;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 139;
UPDATE item_compra SET qt_recebida = 8, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 140;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 141;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 142;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 143;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 144;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (112, 138, 'L2609043912', '2026-11-19', 0),
  (113, 139, 'L2609044213', '2027-01-13', 0),
  (114, 140, 'L2609044314', '2027-03-26', 0),
  (115, 141, 'L2609044715', '2026-12-23', 0),
  (116, 141, 'L2609044716', '2027-01-14', 0),
  (117, 142, 'L2609044817', '2026-12-26', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (39, 1, 112, 'ENTRADA_COMPRA', 11, 'Recebimento da compra 28');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (42, 1, 113, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 28');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (43, 1, 114, 'ENTRADA_COMPRA', 8, 'Recebimento da compra 28');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (47, 1, 115, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 28');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (47, 1, 116, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 28');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (48, 1, 117, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 28');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (51, 1, NULL, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 28');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (53, 1, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 28');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-04 15:27:51');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (229, 3, 33, '2026-09-04 15:27:51', '0.00', '36.00', 'CONCLUIDA', '984588', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (418, 229, 9, 10, NULL, 'UNIDADE', 2, '18.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (229, 'DEBITO', 14.40),
  (229, 'PIX', 21.60);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-04 16:22:49');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (230, 1, 33, '2026-09-04 16:22:49', '0.00', '5.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (419, 230, 10, 12, NULL, 'UNIDADE', 1, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (230, 'PIX', 5.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-04 16:30:25');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (231, 2, 33, '2026-09-04 16:30:25', '0.00', '98.00', 'CONCLUIDA', '198954', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (420, 231, 29, NULL, NULL, 'UNIDADE', 1, '45.00'),
  (421, 231, 52, NULL, NULL, 'UNIDADE', 1, '22.00'),
  (422, 231, 56, NULL, NULL, 'UNIDADE', 2, '9.00'),
  (423, 231, 41, 34, NULL, 'UNIDADE', 1, '6.50'),
  (424, 231, 41, 58, NULL, 'UNIDADE', 1, '6.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (231, 'PIX', 98.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-04 17:48:42');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (232, 3, 33, '2026-09-04 17:48:42', '0.00', '12.00', 'CONCLUIDA', '510772', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (425, 232, 26, NULL, 2, 'DOSE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (232, 'DEBITO', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-04 18:19:26');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (233, 3, 33, '2026-09-04 18:19:26', '0.00', '12.00', 'CONCLUIDA', '847618', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (426, 233, 24, NULL, 3, 'DOSE', 3, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (233, 'PIX', 4.80),
  (233, 'CREDITO', 7.20);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-04 20:24:25');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (234, 3, 33, '2026-09-04 20:24:25', '0.00', '28.50', 'CONCLUIDA', '531390', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (427, 234, 19, 23, NULL, 'UNIDADE', 1, '9.00'),
  (428, 234, 38, NULL, NULL, 'UNIDADE', 2, '6.00'),
  (429, 234, 47, 41, NULL, 'UNIDADE', 1, '1.50'),
  (430, 234, 47, 68, NULL, 'UNIDADE', 2, '1.50'),
  (431, 234, 47, 115, NULL, 'UNIDADE', 2, '1.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (234, 'PIX', 28.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-05 00:08:00');
SET @id_funcionario_logado = 1;
CALL sp_fechar_caixa(33, 113.00);

-- ===== 05/09/2026 (sábado) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-05 12:45:16');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-05 12:49:39');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-05 12:47:38');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-05 12:58:00');
SET @id_funcionario_logado = 4;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (34, 4, '2026-09-05 12:58:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-05 13:05:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (28, 34, 4, 'SUPRIMENTO', '100.00', 'Reforço de troco para o caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-05 14:30:00');
SET @id_funcionario_logado = 3;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-05 14:30:00', nr_nota_fiscal = '227850' WHERE id_compra = 30;
UPDATE item_compra SET qt_recebida = 9, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 146;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 147;
UPDATE item_compra SET qt_recebida = 9, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 148;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 149;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (118, 146, 'L2609051018', '2027-03-10', 0),
  (119, 147, 'L2609051219', '2027-02-23', 0),
  (120, 148, 'L2609051520', '2027-06-06', 0),
  (121, 148, 'L2609051521', '2027-07-08', 0),
  (122, 149, 'L2609051722', '2026-12-10', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (10, 3, 118, 'ENTRADA_COMPRA', 9, 'Recebimento da compra 30');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (12, 3, 119, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 30');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (15, 3, 120, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 30');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (15, 3, 121, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 30');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (17, 3, 122, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 30');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-05 15:28:04');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (235, 4, 34, '2026-09-05 15:28:04', '0.00', '26.00', 'CONCLUIDA', '203877', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (432, 235, 35, NULL, NULL, 'UNIDADE', 2, '13.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (235, 'DEBITO', 26.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-05 15:48:38');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (236, 4, 34, '2026-09-05 15:48:38', '0.00', '44.50', 'CONCLUIDA', '518953', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (433, 236, 46, 39, NULL, 'UNIDADE', 2, '6.00'),
  (434, 236, 50, NULL, NULL, 'UNIDADE', 1, '4.00'),
  (435, 236, 5, 5, NULL, 'UNIDADE', 3, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (236, 'CREDITO', 22.20),
  (236, 'DINHEIRO', 22.30);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-05 16:05:13');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (237, 4, 34, '2026-09-05 16:05:13', '0.00', '15.00', 'CONCLUIDA', '690947', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (436, 237, 1, 97, NULL, 'UNIDADE', 3, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (237, 'PIX', 15.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-05 16:17:43');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (238, 4, 34, '2026-09-05 16:17:43', '0.00', '24.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (437, 238, 33, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (438, 238, 42, 113, NULL, 'UNIDADE', 2, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (238, 'PIX', 24.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-05 18:19:05');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (239, 1, 34, '2026-09-05 18:19:05', '0.00', '24.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (439, 239, 2, 2, NULL, 'UNIDADE', 4, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (239, 'PIX', 24.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-05 18:32:55');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (240, 4, 34, '2026-09-05 18:32:55', '0.00', '12.00', 'CONCLUIDA', '944203', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (440, 240, 49, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (240, 'DEBITO', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-05 18:41:57');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (241, 3, 34, '2026-09-05 18:41:57', '0.00', '19.50', 'CONCLUIDA', '531081', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (441, 241, 19, 23, NULL, 'UNIDADE', 2, '9.00'),
  (442, 241, 47, 115, NULL, 'UNIDADE', 1, '1.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (241, 'DEBITO', 19.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-05 19:40:39');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (242, 3, 34, '2026-09-05 19:40:39', '0.00', '55.50', 'CONCLUIDA', '494180', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (443, 242, 2, 2, NULL, 'UNIDADE', 1, '6.00'),
  (444, 242, 47, 69, NULL, 'UNIDADE', 1, '1.50'),
  (445, 242, 43, 36, NULL, 'UNIDADE', 3, '5.00'),
  (446, 242, 12, 119, NULL, 'UNIDADE', 1, '4.50'),
  (447, 242, 13, 15, NULL, 'UNIDADE', 3, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (242, 'DEBITO', 55.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-05 21:00:00');
SET @id_funcionario_logado = 4;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (29, 34, 4, 'SANGRIA', '150.00', 'Sangria: retirada do excesso de dinheiro do caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-05 21:02:36');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (243, 4, 34, '2026-09-05 21:02:36', '0.00', '33.00', 'CONCLUIDA', '378572', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (448, 243, 13, 15, NULL, 'UNIDADE', 2, '9.50'),
  (449, 243, 22, NULL, 1, 'DOSE', 2, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (243, 'DEBITO', 19.00);
CALL sp_registrar_venda_fiado(243, 2, '2026-10-05', 14.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-05 21:58:56');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (244, 4, 34, '2026-09-05 21:58:56', '0.00', '11.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (450, 244, 10, 12, NULL, 'UNIDADE', 2, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (244, 'DINHEIRO', 11.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-05 22:48:27');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (245, 4, 34, '2026-09-05 22:48:27', '0.00', '62.00', 'CONCLUIDA', '587356', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (451, 245, 49, NULL, NULL, 'UNIDADE', 2, '12.00'),
  (452, 245, 22, 26, NULL, 'UNIDADE', 1, '38.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (245, 'PIX', 62.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-05 23:32:27');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (246, 1, 34, '2026-09-05 23:32:27', '0.00', '7.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (453, 246, 4, 81, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (246, 'DEBITO', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-05 23:48:17');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (247, 3, 34, '2026-09-05 23:48:17', '3.00', '31.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (454, 247, 15, 18, NULL, 'UNIDADE', 2, '3.00'),
  (455, 247, 54, NULL, NULL, 'UNIDADE', 1, '2.50'),
  (456, 247, 12, 119, NULL, 'UNIDADE', 1, '4.50'),
  (457, 247, 39, 89, NULL, 'UNIDADE', 2, '7.00'),
  (458, 247, 39, 112, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (247, 'PIX', 31.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-06 00:08:00');
SET @id_funcionario_logado = 4;
CALL sp_fechar_caixa(34, 133.30);

-- ===== 06/09/2026 (domingo) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-06 12:43:12');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-06 12:45:53');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-06 12:50:00');
SET @id_funcionario_logado = 2;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (35, 2, '2026-09-06 12:50:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-06 13:46:20');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (248, 4, 35, '2026-09-06 13:46:20', '0.00', '31.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (459, 248, 57, NULL, NULL, 'UNIDADE', 1, '14.00'),
  (460, 248, 10, 12, NULL, 'UNIDADE', 1, '5.50'),
  (461, 248, 49, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (248, 'DEBITO', 31.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-06 15:38:06');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (249, 4, 35, '2026-09-06 15:38:06', '0.00', '3.00', 'CONCLUIDA', '971449', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (462, 249, 15, 18, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (249, 'DEBITO', 3.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-06 15:56:00');
SET @id_funcionario_logado = 2;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (30, 35, 2, 'DESPESA', '20.00', 'Café e água dos funcionários');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-06 19:04:39');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (250, 2, 35, '2026-09-06 19:04:39', '0.00', '19.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (463, 250, 5, 5, NULL, 'UNIDADE', 2, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (250, 'DINHEIRO', 19.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-06 19:55:42');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (251, 2, 35, '2026-09-06 19:55:42', '0.00', '42.00', 'CONCLUIDA', '461108', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (464, 251, 4, 106, NULL, 'UNIDADE', 6, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (251, 'DEBITO', 42.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-06 20:20:37');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (252, 2, 35, '2026-09-06 20:20:37', '0.00', '7.50', 'CONCLUIDA', '722362', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (465, 252, 47, 69, NULL, 'UNIDADE', 1, '1.50'),
  (466, 252, 47, 116, NULL, 'UNIDADE', 4, '1.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (252, 'PIX', 7.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-06 20:25:37');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (253, 4, 35, '2026-09-06 20:25:37', '0.00', '15.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (467, 253, 1, 97, NULL, 'UNIDADE', 3, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (253, 'DINHEIRO', 15.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-06 21:33:59');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (254, 4, 35, '2026-09-06 21:33:59', '0.00', '2.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (468, 254, 45, 96, NULL, 'UNIDADE', 2, '1.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (254, 'PIX', 2.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-06 22:17:47');
CALL sp_abrir_garrafa(53, 4, @garrafa);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-06 22:18:47');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (255, 4, 35, '2026-09-06 22:18:47', '0.00', '84.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (469, 255, 4, 106, NULL, 'UNIDADE', 1, '7.00'),
  (470, 255, 13, 15, NULL, 'UNIDADE', 2, '9.50'),
  (471, 255, 52, NULL, NULL, 'UNIDADE', 2, '22.00'),
  (472, 255, 23, NULL, 5, 'DOSE', 1, '14.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (255, 'PIX', 84.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-07 00:08:00');
SET @id_funcionario_logado = 2;
CALL sp_fechar_caixa(35, 114.00);

-- ===== 07/09/2026 (segunda) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-07 12:47:21');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-07 12:42:02');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-07 12:53:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (36, 2, '2026-09-07 12:53:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-07 10:36:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (31, 3, 1, '2026-09-07 10:36:00', 'RETIRADA', '124.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (150, 31, 33, 7, 0, '10.20', 0),
  (151, 31, 35, 3, 0, '11.00', 0),
  (152, 31, 38, 3, 0, '3.20', 0),
  (153, 31, 50, 5, 0, '2.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-07 10:00:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (32, 5, 1, '2026-09-07 10:00:00', 'RETIRADA', '115.50', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (154, 32, 49, 5, 0, '6.50', 0),
  (155, 32, 52, 5, 0, '14.00', 0),
  (156, 32, 56, 2, 0, '6.50', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-07 13:05:00');
SET @id_funcionario_logado = 2;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (31, 36, 2, 'SUPRIMENTO', '100.00', 'Reforço de troco para o caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-07 17:00:00');
SET @id_funcionario_logado = 3;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-07 17:00:00', nr_nota_fiscal = '410526' WHERE id_compra = 31;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 150;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 151;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 152;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 153;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (33, 3, NULL, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 31');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (35, 3, NULL, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 31');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (38, 3, NULL, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 31');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (50, 3, NULL, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 31');
SET @id_funcionario_logado = 2;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-07 17:00:00', nr_nota_fiscal = '282049' WHERE id_compra = 32;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 154;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 155;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 156;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (49, 2, NULL, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 32');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (52, 2, NULL, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 32');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (56, 2, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 32');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-07 18:26:59');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (256, 2, 36, '2026-09-07 18:26:59', '0.00', '10.50', 'CONCLUIDA', '171796', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (473, 256, 16, 85, NULL, 'UNIDADE', 2, '3.50'),
  (474, 256, 16, 20, NULL, 'UNIDADE', 1, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (256, 'DINHEIRO', 6.30),
  (256, 'CREDITO', 4.20);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-07 20:35:24');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (257, 2, 36, '2026-09-07 20:35:24', '0.00', '15.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (475, 257, 1, 97, NULL, 'UNIDADE', 3, '5.00');
CALL sp_registrar_venda_fiado(257, 10, '2026-10-07', 15.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-07 20:36:54');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (258, 2, 36, '2026-09-07 20:36:54', '0.00', '8.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (476, 258, 40, 57, NULL, 'UNIDADE', 1, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (258, 'DEBITO', 8.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-07 21:25:00');
CALL sp_registrar_evento_acesso(2, 'CONSULTA_DADO_PESSOAL', 'cliente', '2', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-07 21:27:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (15, 20, 36, 'PIX', '14.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-07 22:02:03');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (259, 3, 36, '2026-09-07 22:02:03', '0.00', '1.00', 'CONCLUIDA', '425962', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (477, 259, 45, 96, NULL, 'UNIDADE', 1, '1.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (259, 'PIX', 1.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-07 22:11:42');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (260, 2, 36, '2026-09-07 22:11:42', '0.00', '20.00', 'CONCLUIDA', '737686', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (478, 260, 40, 57, NULL, 'UNIDADE', 1, '8.00'),
  (479, 260, 2, 2, NULL, 'UNIDADE', 2, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (260, 'PIX', 20.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-07 22:42:15');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (261, 3, 36, '2026-09-07 22:42:15', '0.00', '8.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (480, 261, 50, NULL, NULL, 'UNIDADE', 2, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (261, 'CREDITO', 8.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-07 23:05:00');
SET @id_funcionario_logado = 2;
CALL sp_fechar_caixa(36, 256.30);

-- ===== 08/09/2026 (terça) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-08 12:45:48');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-08 12:49:06');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-08 12:52:00');
SET @id_funcionario_logado = 1;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (37, 1, '2026-09-08 12:52:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-08 10:20:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (33, 1, 1, '2026-09-08 10:20:00', 'ENTREGA', '76.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (157, 33, 13, 10, 0, '6.60', 0),
  (158, 33, 16, 5, 0, '2.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-08 13:20:00');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 1, 88, 'PERDA', 3, 'Lote vencido em 05/09/2026');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-08 13:21:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '662', '{"tipo": "PERDA", "motivo": "vencimento", "lote": 88, "quantidade": 3}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-08 14:52:22');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (262, 2, 37, '2026-09-08 14:52:22', '0.00', '15.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (481, 262, 1, 97, NULL, 'UNIDADE', 3, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (262, 'CREDITO', 15.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-08 17:27:56');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (263, 1, 37, '2026-09-08 17:27:56', '2.00', '28.00', 'CONCLUIDA', '993688', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (482, 263, 49, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (483, 263, 19, 23, NULL, 'UNIDADE', 2, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (263, 'PIX', 28.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-08 20:29:00');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (264, 1, 37, '2026-09-08 20:29:00', '0.00', '35.00', 'CONCLUIDA', '548711', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (484, 264, 13, 15, NULL, 'UNIDADE', 2, '9.50'),
  (485, 264, 40, 57, NULL, 'UNIDADE', 1, '8.00'),
  (486, 264, 40, 91, NULL, 'UNIDADE', 1, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (264, 'DEBITO', 35.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-08 22:56:50');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (265, 1, 37, '2026-09-08 22:56:50', '0.00', '36.00', 'CONCLUIDA', '735959', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (487, 265, 30, NULL, NULL, 'UNIDADE', 1, '36.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (265, 'DINHEIRO', 36.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-08 23:05:00');
CALL sp_fechar_caixa(37, 237.00);
UPDATE caixa SET ds_observacao = 'Sobrou R$ 1.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 37;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-08 23:07:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '37', '{"diferenca": "1.00"}', '192.168.0.11');

-- ===== 09/09/2026 (quarta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-09 12:40:05');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-09 12:42:33');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-09 12:50:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (38, 1, '2026-09-09 12:50:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-09 10:40:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (34, 2, 1, '2026-09-09 10:40:00', 'ENTREGA', '132.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (159, 34, 23, 2, 0, '66.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-09 13:04:20');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (266, 1, 38, '2026-09-09 13:04:20', '0.00', '23.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (488, 266, 4, 106, NULL, 'UNIDADE', 2, '7.00'),
  (489, 266, 58, NULL, NULL, 'UNIDADE', 1, '6.50'),
  (490, 266, 15, 18, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (266, 'DINHEIRO', 23.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-09 14:11:18');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (267, 1, 38, '2026-09-09 14:11:18', '0.00', '128.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (491, 267, 9, 10, NULL, 'UNIDADE', 1, '18.00'),
  (492, 267, 9, 11, NULL, 'UNIDADE', 4, '18.00'),
  (493, 267, 5, 5, NULL, 'UNIDADE', 4, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (267, 'DINHEIRO', 76.80),
  (267, 'DEBITO', 51.20);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-09 14:30:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-09 14:30:00', nr_nota_fiscal = '533113' WHERE id_compra = 33;
UPDATE item_compra SET qt_recebida = 10, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 157;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 158;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (123, 157, 'L2609091323', '2027-01-17', 0),
  (124, 157, 'L2609091324', '2027-02-23', 0),
  (125, 158, 'L2609091625', '2027-07-06', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (13, 1, 123, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 33');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (13, 1, 124, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 33');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (16, 1, 125, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 33');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-09 14:30:22');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (268, 1, 38, '2026-09-09 14:30:22', '2.00', '130.00', 'CONCLUIDA', '189140', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (494, 268, 6, 6, NULL, 'UNIDADE', 2, '11.00'),
  (495, 268, 6, 82, NULL, 'UNIDADE', 10, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (268, 'DEBITO', 52.00),
  (268, 'DINHEIRO', 78.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-09 17:26:00');
CALL sp_registrar_evento_acesso(1, 'CONSULTA_DADO_PESSOAL', 'cliente', '10', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-09 17:28:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (16, 21, 38, 'CREDITO', '15.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-09 17:33:54');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (269, 1, 38, '2026-09-09 17:33:54', '0.00', '15.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (496, 269, 48, 43, NULL, 'UNIDADE', 1, '4.00'),
  (497, 269, 11, 13, NULL, 'UNIDADE', 1, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (269, 'DINHEIRO', 15.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-09 22:28:07');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (270, 1, 38, '2026-09-09 22:28:07', '0.00', '16.00', 'CONCLUIDA', '980875', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (498, 270, 24, 87, NULL, 'UNIDADE', 1, '16.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (270, 'DEBITO', 16.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-09 23:05:00');
CALL sp_fechar_caixa(38, 293.30);

-- ===== 10/09/2026 (quinta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-10 10:00:00');
INSERT INTO cliente (id_cliente, nm_cliente, nr_cpf, dt_nascimento, nr_telefone, vl_limite_fiado, dt_consentimento_lgpd, dt_cadastro) VALUES (11, 'Leandro Bastos Freire', '91000000011', '1983-10-19', '(11) 99000-0011', '0.00', '2026-09-10 10:00:00', '2026-09-10 10:00:00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-10 10:05:00');
CALL sp_autorizar_cliente_fiado(11, 300.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-10 12:45:20');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-10 12:41:31');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-10 12:55:00');
SET @id_funcionario_logado = 3;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (39, 3, '2026-09-10 12:55:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-10 10:12:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (35, 4, 1, '2026-09-10 10:12:00', 'ENTREGA', '118.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (160, 35, 40, 7, 0, '5.40', 0),
  (161, 35, 41, 4, 0, '4.20', 0),
  (162, 35, 42, 6, 0, '4.00', 0),
  (163, 35, 45, 5, 0, '0.50', 0),
  (164, 35, 46, 7, 0, '3.90', 0),
  (165, 35, 47, 12, 0, '0.80', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-10 10:06:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (36, 5, 1, '2026-09-10 10:06:00', 'RETIRADA', '17.40', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (166, 36, 60, 3, 0, '5.80', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-10 14:09:00');
SET @id_funcionario_logado = 3;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (32, 39, 3, 'DESPESA', '15.00', 'Compra de gelo para o balcão');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-10 14:30:00');
SET @id_funcionario_logado = 4;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-10 14:30:00', nr_nota_fiscal = '202815' WHERE id_compra = 34;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 159;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (126, 159, 'L2609102326', '2028-05-22', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (23, 4, 126, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 34');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-10 16:08:59');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (271, 4, 39, '2026-09-10 16:08:59', '0.00', '156.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (499, 271, 8, 61, NULL, 'UNIDADE', 3, '7.00'),
  (500, 271, 8, 9, NULL, 'UNIDADE', 3, '7.00'),
  (501, 271, 5, 5, NULL, 'UNIDADE', 9, '9.50'),
  (502, 271, 5, 99, NULL, 'UNIDADE', 3, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (271, 'PIX', 156.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-10 16:21:03');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (272, 3, 39, '2026-09-10 16:21:03', '0.00', '51.00', 'CONCLUIDA', '572976', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (503, 272, 2, 2, NULL, 'UNIDADE', 6, '6.00'),
  (504, 272, 34, NULL, NULL, 'UNIDADE', 1, '12.50'),
  (505, 272, 54, NULL, NULL, 'UNIDADE', 1, '2.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (272, 'DEBITO', 51.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-10 17:00:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-10 17:00:00', nr_nota_fiscal = '737738' WHERE id_compra = 36;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 166;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (127, 166, 'L2609106027', '2026-09-20', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 3, 127, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 36');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (3, 1, 49, 'DEVOLUCAO_FORNECEDOR', 2, 'Devolvido ao fornecedor: latas amassadas no lote');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-10 17:27:18');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (273, 4, 39, '2026-09-10 17:27:18', '0.00', '3.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (506, 273, 15, 18, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (273, 'CREDITO', 3.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-10 20:14:44');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (274, 4, 39, '2026-09-10 20:14:44', '0.00', '37.50', 'CONCLUIDA', '164700', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (507, 274, 59, 111, NULL, 'UNIDADE', 1, '6.00'),
  (508, 274, 41, 58, NULL, 'UNIDADE', 1, '6.50'),
  (509, 274, 43, 36, NULL, 'UNIDADE', 1, '5.00'),
  (510, 274, 43, 114, NULL, 'UNIDADE', 4, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (274, 'DINHEIRO', 37.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-10 21:37:47');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (275, 4, 39, '2026-09-10 21:37:47', '2.00', '48.00', 'CONCLUIDA', '813134', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (511, 275, 36, NULL, NULL, 'UNIDADE', 2, '22.00'),
  (512, 275, 44, 37, NULL, 'UNIDADE', 1, '3.00'),
  (513, 275, 44, 95, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (275, 'PIX', 48.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-10 23:05:00');
SET @id_funcionario_logado = 3;
CALL sp_fechar_caixa(39, 227.50);
UPDATE caixa SET ds_observacao = 'Sobrou R$ 5.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 39;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-10 23:07:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '39', '{"diferenca": "5.00"}', '192.168.0.11');

-- ===== 11/09/2026 (sexta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-11 12:44:04');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-11 12:47:59');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-11 12:41:41');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-11 12:55:00');
SET @id_funcionario_logado = 2;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (40, 2, '2026-09-11 12:55:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-11 10:05:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (37, 1, 1, '2026-09-11 10:05:00', 'ENTREGA', '527.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (167, 37, 3, 8, 0, '2.40', 0),
  (168, 37, 5, 26, 0, '6.80', 0),
  (169, 37, 6, 14, 0, '8.00', 0),
  (170, 37, 8, 12, 0, '5.00', 0),
  (171, 37, 9, 6, 0, '12.50', 0),
  (172, 37, 11, 6, 0, '7.80', 0),
  (173, 37, 19, 6, 0, '6.20', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-11 14:02:21');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (276, 3, 40, '2026-09-11 14:02:21', '0.00', '1.00', 'CONCLUIDA', '290221', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (514, 276, 45, 96, NULL, 'UNIDADE', 1, '1.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (276, 'DEBITO', 1.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-11 14:30:00');
SET @id_funcionario_logado = 1;
UPDATE compra SET st_compra = 'RECEBIDA_PARCIAL', dt_recebimento = '2026-09-11 14:30:00', nr_nota_fiscal = '495965' WHERE id_compra = 35;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = 'Faltaram 1 unidades na entrega' WHERE id_item_compra = 160;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 161;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 162;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 163;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 164;
UPDATE item_compra SET qt_recebida = 12, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 165;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (128, 160, 'L2609114028', '2026-12-03', 0),
  (129, 161, 'L2609114129', '2027-01-17', 0),
  (130, 162, 'L2609114230', '2027-02-22', 0),
  (131, 163, 'L2609114531', '2027-05-18', 0),
  (132, 163, 'L2609114532', '2027-06-26', 0),
  (133, 164, 'L2609114633', '2027-02-16', 0),
  (134, 164, 'L2609114634', '2027-03-26', 0),
  (135, 165, 'L2609114735', '2026-11-30', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (40, 1, 128, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 35');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (41, 1, 129, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 35');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (42, 1, 130, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 35');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (45, 1, 131, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 35');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (45, 1, 132, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 35');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (46, 1, 133, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 35');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (46, 1, 134, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 35');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (47, 1, 135, 'ENTRADA_COMPRA', 12, 'Recebimento da compra 35');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-11 14:46:29');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (277, 1, 40, '2026-09-11 14:46:29', '0.00', '28.50', 'CONCLUIDA', '836102', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (515, 277, 5, 99, NULL, 'UNIDADE', 3, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (277, 'DINHEIRO', 17.10),
  (277, 'DEBITO', 11.40);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-11 15:38:01');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (278, 1, 40, '2026-09-11 15:38:01', '0.00', '19.00', 'CONCLUIDA', '523447', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (516, 278, 13, 123, NULL, 'UNIDADE', 2, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (278, 'CREDITO', 9.50),
  (278, 'DINHEIRO', 9.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-11 16:48:00');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (19, 1, 23, 'PERDA', 3, 'Caiu no chão durante a reposição');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-11 16:49:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '713', '{"tipo": "PERDA", "motivo": "Caiu no chão durante a reposição", "quantidade": 3}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-11 17:01:00');
SET @id_funcionario_logado = 2;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (33, 40, 2, 'DESPESA', '20.00', 'Café e água dos funcionários');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-11 19:10:22');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (279, 1, 40, '2026-09-11 19:10:22', '0.00', '5.00', 'CONCLUIDA', '289342', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (517, 279, 43, 114, NULL, 'UNIDADE', 1, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (279, 'CREDITO', 5.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-11 19:12:13');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (280, 2, 40, '2026-09-11 19:12:13', '0.00', '14.00', 'CONCLUIDA', '239628', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (518, 280, 39, 112, NULL, 'UNIDADE', 2, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (280, 'PIX', 14.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-11 19:14:20');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (281, 3, 40, '2026-09-11 19:14:20', '0.00', '19.00', 'CONCLUIDA', '674993', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (519, 281, 50, NULL, NULL, 'UNIDADE', 1, '4.00'),
  (520, 281, 19, 103, NULL, 'UNIDADE', 1, '9.00'),
  (521, 281, 15, 18, NULL, 'UNIDADE', 1, '3.00'),
  (522, 281, 15, 120, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (281, 'DINHEIRO', 19.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-11 19:30:35');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (282, 3, 40, '2026-09-11 19:30:35', '0.00', '8.00', 'CONCLUIDA', '833015', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (523, 282, 50, NULL, NULL, 'UNIDADE', 2, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (282, 'DINHEIRO', 8.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-11 21:00:00');
SET @id_funcionario_logado = 2;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (34, 40, 2, 'SANGRIA', '100.00', 'Sangria: retirada do excesso de dinheiro do caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-11 22:10:29');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (283, 3, 40, '2026-09-11 22:10:29', '0.00', '9.50', 'CONCLUIDA', '413500', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (524, 283, 13, 123, NULL, 'UNIDADE', 1, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (283, 'PIX', 9.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 00:08:00');
SET @id_funcionario_logado = 2;
CALL sp_fechar_caixa(40, 130.60);
UPDATE caixa SET ds_observacao = 'Faltou R$ 3.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 40;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 00:10:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '40', '{"diferenca": "-3.00"}', '192.168.0.11');

-- ===== 12/09/2026 (sábado) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 12:43:27');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 12:41:34');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 12:49:42');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 12:55:00');
SET @id_funcionario_logado = 4;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (41, 4, '2026-09-12 12:55:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 14:30:00');
SET @id_funcionario_logado = 1;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-12 14:30:00', nr_nota_fiscal = '582954' WHERE id_compra = 37;
UPDATE item_compra SET qt_recebida = 8, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 167;
UPDATE item_compra SET qt_recebida = 26, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 168;
UPDATE item_compra SET qt_recebida = 14, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 169;
UPDATE item_compra SET qt_recebida = 12, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 170;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 171;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 172;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 173;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (136, 167, 'L2609120336', '2027-03-26', 0),
  (137, 167, 'L2609120337', '2027-04-16', 0),
  (138, 168, 'L2609120538', '2027-05-05', 0),
  (139, 169, 'L2609120639', '2027-04-18', 0),
  (140, 170, 'L2609120840', '2027-05-08', 0),
  (141, 171, 'L2609120941', '2027-01-17', 0),
  (142, 172, 'L2609121142', '2027-03-16', 0),
  (143, 173, 'L2609121943', '2027-05-04', 0),
  (144, 173, 'L2609121944', '2027-06-09', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (3, 1, 136, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 37');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (3, 1, 137, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 37');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (5, 1, 138, 'ENTRADA_COMPRA', 26, 'Recebimento da compra 37');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (6, 1, 139, 'ENTRADA_COMPRA', 14, 'Recebimento da compra 37');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (8, 1, 140, 'ENTRADA_COMPRA', 12, 'Recebimento da compra 37');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (9, 1, 141, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 37');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (11, 1, 142, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 37');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (19, 1, 143, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 37');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (19, 1, 144, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 37');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 14:33:39');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (284, 4, 41, '2026-09-12 14:33:39', '0.00', '54.50', 'CONCLUIDA', '931361', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (525, 284, 57, NULL, NULL, 'UNIDADE', 1, '14.00'),
  (526, 284, 49, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (527, 284, 5, 99, NULL, 'UNIDADE', 1, '9.50'),
  (528, 284, 8, 9, NULL, 'UNIDADE', 1, '7.00'),
  (529, 284, 24, NULL, 3, 'DOSE', 3, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (284, 'PIX', 54.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 16:13:22');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (285, 1, 41, '2026-09-12 16:13:22', '0.00', '3.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (530, 285, 15, 120, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (285, 'DINHEIRO', 3.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 18:04:58');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (286, 4, 41, '2026-09-12 18:04:58', '0.00', '12.00', 'CONCLUIDA', '502233', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (531, 286, 42, 113, NULL, 'UNIDADE', 2, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (286, 'CREDITO', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 18:26:13');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (287, 1, 41, '2026-09-12 18:26:13', '0.00', '138.00', 'CONCLUIDA', '370073', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (532, 287, 9, 141, NULL, 'UNIDADE', 6, '18.00'),
  (533, 287, 1, 97, NULL, 'UNIDADE', 6, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (287, 'DEBITO', 55.20),
  (287, 'PIX', 82.80);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 19:26:00');
SET @id_funcionario_logado = 4;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (35, 41, 4, 'DESPESA', '15.00', 'Material de limpeza');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 19:57:55');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (288, 1, 41, '2026-09-12 19:57:55', '0.00', '22.00', 'CONCLUIDA', '360199', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (534, 288, 6, 82, NULL, 'UNIDADE', 2, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (288, 'PIX', 8.80),
  (288, 'DINHEIRO', 13.20);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 20:34:12');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (289, 4, 41, '2026-09-12 20:34:12', '0.00', '12.50', 'CONCLUIDA', '326934', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (535, 289, 41, 58, NULL, 'UNIDADE', 1, '6.50'),
  (536, 289, 42, 113, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (289, 'DINHEIRO', 12.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 20:51:04');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (290, 3, 41, '2026-09-12 20:51:04', '0.00', '41.50', 'CONCLUIDA', '247805', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (537, 290, 28, NULL, NULL, 'UNIDADE', 1, '32.00'),
  (538, 290, 5, 99, NULL, 'UNIDADE', 1, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (290, 'CREDITO', 41.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 21:00:00');
SET @id_funcionario_logado = 4;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (36, 41, 4, 'SANGRIA', '100.00', 'Sangria: retirada do excesso de dinheiro do caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 21:10:08');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (291, 3, 41, '2026-09-12 21:10:08', '0.00', '6.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (539, 291, 41, 129, NULL, 'UNIDADE', 1, '6.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (291, 'PIX', 6.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 21:18:10');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (292, 3, 41, '2026-09-12 21:18:10', '0.00', '72.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (540, 292, 30, NULL, NULL, 'UNIDADE', 2, '36.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (292, 'PIX', 72.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 21:39:22');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (293, 3, 41, '2026-09-12 21:39:22', '0.00', '9.00', 'CONCLUIDA', '386519', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (541, 293, 17, 110, NULL, 'UNIDADE', 1, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (293, 'DINHEIRO', 9.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 22:02:50');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (294, 3, 41, '2026-09-12 22:02:50', '0.00', '8.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (542, 294, 3, 49, NULL, 'UNIDADE', 1, '3.50'),
  (543, 294, 1, 60, NULL, 'UNIDADE', 1, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (294, 'CREDITO', 8.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 22:18:38');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (295, 1, 41, '2026-09-12 22:18:38', '0.00', '11.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (544, 295, 38, NULL, NULL, 'UNIDADE', 1, '6.00'),
  (545, 295, 10, 12, NULL, 'UNIDADE', 1, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (295, 'PIX', 11.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-12 22:53:27');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (296, 4, 41, '2026-09-12 22:53:27', '0.00', '12.00', 'CONCLUIDA', '141367', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (546, 296, 2, 2, NULL, 'UNIDADE', 2, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (296, 'DINHEIRO', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-13 00:08:00');
CALL sp_fechar_caixa(41, 131.70);
UPDATE caixa SET ds_observacao = 'Faltou R$ 3.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 41;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-13 00:10:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '41', '{"diferenca": "-3.00"}', '192.168.0.11');

-- ===== 13/09/2026 (domingo) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-13 12:48:49');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-13 12:42:51');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-13 12:51:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (42, 4, '2026-09-13 12:51:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-13 15:39:55');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (297, 4, 42, '2026-09-13 15:39:55', '0.00', '12.00', 'CONCLUIDA', '985176', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (547, 297, 49, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (297, 'PIX', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-13 17:19:08');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (298, 2, 42, '2026-09-13 17:19:08', '0.00', '102.00', 'CONCLUIDA', '555226', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (548, 298, 28, NULL, NULL, 'UNIDADE', 1, '32.00'),
  (549, 298, 3, 136, NULL, 'UNIDADE', 4, '3.50'),
  (550, 298, 3, 98, NULL, 'UNIDADE', 8, '3.50'),
  (551, 298, 15, 120, NULL, 'UNIDADE', 1, '3.00'),
  (552, 298, 37, NULL, NULL, 'UNIDADE', 1, '25.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (298, 'PIX', 102.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-13 18:20:34');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (299, 4, 42, '2026-09-13 18:20:34', '0.00', '33.00', 'CONCLUIDA', '859363', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (553, 299, 12, 119, NULL, 'UNIDADE', 1, '4.50'),
  (554, 299, 7, 73, NULL, 'UNIDADE', 3, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (299, 'PIX', 33.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-13 18:25:01');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (300, 4, 42, '2026-09-13 18:25:01', '0.00', '66.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (555, 300, 50, NULL, NULL, 'UNIDADE', 1, '4.00'),
  (556, 300, 39, 112, NULL, 'UNIDADE', 1, '7.00'),
  (557, 300, 31, NULL, NULL, 'UNIDADE', 1, '55.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (300, 'DINHEIRO', 66.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-13 18:37:47');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (301, 2, 42, '2026-09-13 18:37:47', '0.00', '7.00', 'CONCLUIDA', '384950', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (558, 301, 20, 24, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (301, 'DINHEIRO', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-13 20:08:07');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (302, 2, 42, '2026-09-13 20:08:07', '0.00', '32.00', 'CONCLUIDA', '464167', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (559, 302, 28, NULL, NULL, 'UNIDADE', 1, '32.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (302, 'PIX', 32.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-13 21:00:19');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (303, 4, 42, '2026-09-13 21:00:19', '0.00', '88.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (560, 303, 37, NULL, NULL, 'UNIDADE', 2, '25.00'),
  (561, 303, 7, 73, NULL, 'UNIDADE', 2, '9.50'),
  (562, 303, 7, 8, NULL, 'UNIDADE', 2, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (303, 'DINHEIRO', 9.50),
  (303, 'CREDITO', 9.50);
CALL sp_registrar_venda_fiado(303, 10, '2026-10-13', 69.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-14 00:08:00');
CALL sp_fechar_caixa(42, 182.50);

-- ===== 14/09/2026 (segunda) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-14 12:43:16');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-14 12:45:37');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-14 12:58:00');
SET @id_funcionario_logado = 3;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (43, 3, '2026-09-14 12:58:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-14 10:20:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (38, 3, 1, '2026-09-14 10:20:00', 'RETIRADA', '185.60', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (174, 38, 34, 4, 0, '11.90', 0),
  (175, 38, 36, 3, 0, '14.50', 0),
  (176, 38, 37, 5, 0, '16.50', 0),
  (177, 38, 50, 6, 0, '2.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-14 10:37:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (39, 5, 1, '2026-09-14 10:37:00', 'RETIRADA', '19.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (178, 39, 57, 2, 0, '9.50', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-14 15:33:27');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (304, 3, 43, '2026-09-14 15:33:27', '0.00', '22.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (563, 304, 36, NULL, NULL, 'UNIDADE', 1, '22.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (304, 'DINHEIRO', 22.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-14 16:26:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (37, 43, 3, 'DESPESA', '50.00', 'Café e água dos funcionários');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-14 17:00:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-14 17:00:00', nr_nota_fiscal = '359947' WHERE id_compra = 38;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 174;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 175;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 176;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 177;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (34, 3, NULL, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 38');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (36, 3, NULL, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 38');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (37, 3, NULL, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 38');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (50, 3, NULL, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 38');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-14 17:00:00', nr_nota_fiscal = '850010' WHERE id_compra = 39;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 178;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (57, 3, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 39');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-14 18:49:05');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (305, 3, 43, '2026-09-14 18:49:05', '2.00', '47.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (564, 305, 39, 112, NULL, 'UNIDADE', 5, '7.00'),
  (565, 305, 57, NULL, NULL, 'UNIDADE', 1, '14.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (305, 'PIX', 47.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-14 21:37:00');
CALL sp_registrar_evento_acesso(3, 'CONSULTA_DADO_PESSOAL', 'cliente', '3', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-14 21:39:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (17, 6, 43, 'PIX', '29.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-14 22:51:46');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (306, 2, 43, '2026-09-14 22:51:46', '0.00', '3.50', 'CONCLUIDA', '357833', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (566, 306, 3, 98, NULL, 'UNIDADE', 1, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (306, 'PIX', 3.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-14 22:59:28');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (307, 2, 43, '2026-09-14 22:59:28', '0.00', '6.00', 'CONCLUIDA', '974884', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (567, 307, 15, 120, NULL, 'UNIDADE', 1, '3.00'),
  (568, 307, 15, 84, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (307, 'PIX', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-14 23:05:00');
SET @id_funcionario_logado = 3;
CALL sp_fechar_caixa(43, 122.00);

-- ===== 15/09/2026 (terça) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-15 12:40:33');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-15 12:46:04');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-15 12:55:00');
SET @id_funcionario_logado = 2;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (44, 2, '2026-09-15 12:55:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-15 11:45:00');
SET @id_funcionario_logado = 1;
CALL sp_autorizar_cliente_fiado(2, 300.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-15 10:33:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (40, 1, 1, '2026-09-15 10:33:00', 'ENTREGA', '239.80', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (179, 40, 1, 26, 0, '3.10', 0),
  (180, 40, 3, 14, 0, '2.40', 0),
  (181, 40, 9, 6, 0, '12.50', 0),
  (182, 40, 13, 5, 0, '6.60', 0),
  (183, 40, 15, 11, 0, '1.60', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-15 15:42:52');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (308, 2, 44, '2026-09-15 15:42:52', '0.00', '28.00', 'CONCLUIDA', '520387', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (569, 308, 6, 107, NULL, 'UNIDADE', 2, '11.00'),
  (570, 308, 46, 39, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (308, 'CREDITO', 28.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-15 18:22:34');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (309, 2, 44, '2026-09-15 18:22:34', '0.00', '12.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (571, 309, 34, NULL, NULL, 'UNIDADE', 1, '12.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (309, 'PIX', 12.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-15 19:02:55');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (310, 1, 44, '2026-09-15 19:02:55', '0.00', '22.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (572, 310, 6, 107, NULL, 'UNIDADE', 2, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (310, 'DINHEIRO', 22.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-15 19:10:35');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (311, 1, 44, '2026-09-15 19:10:35', '0.00', '55.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (573, 311, 46, 39, NULL, 'UNIDADE', 4, '6.00'),
  (574, 311, 46, 133, NULL, 'UNIDADE', 1, '6.00'),
  (575, 311, 40, 91, NULL, 'UNIDADE', 1, '8.00'),
  (576, 311, 2, 2, NULL, 'UNIDADE', 1, '6.00'),
  (577, 311, 6, 107, NULL, 'UNIDADE', 1, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (311, 'PIX', 55.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-15 19:25:26');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (312, 1, 44, '2026-09-15 19:25:26', '0.00', '38.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (578, 312, 4, 106, NULL, 'UNIDADE', 4, '7.00'),
  (579, 312, 1, 60, NULL, 'UNIDADE', 2, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (312, 'CREDITO', 38.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-15 20:58:16');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (313, 1, 44, '2026-09-15 20:58:16', '0.00', '28.00', 'CONCLUIDA', '626506', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (580, 313, 57, NULL, NULL, 'UNIDADE', 2, '14.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (313, 'DINHEIRO', 28.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-15 23:05:00');
SET @id_funcionario_logado = 2;
CALL sp_fechar_caixa(44, 147.00);
UPDATE caixa SET ds_observacao = 'Faltou R$ 3.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 44;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-15 23:07:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '44', '{"diferenca": "-3.00"}', '192.168.0.11');

-- ===== 16/09/2026 (quarta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-16 12:44:31');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-16 12:48:07');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-16 12:56:00');
SET @id_funcionario_logado = 4;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (45, 4, '2026-09-16 12:56:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-16 10:01:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (41, 2, 1, '2026-09-16 10:01:00', 'ENTREGA', '135.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (184, 41, 28, 3, 0, '21.00', 0),
  (185, 41, 30, 3, 0, '24.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-16 10:03:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (42, 3, 1, '2026-09-16 10:03:00', 'RETIRADA', '173.40', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (186, 42, 33, 10, 0, '10.20', 0),
  (187, 42, 34, 6, 0, '11.90', 0);
UPDATE compra SET st_compra = 'CANCELADA' WHERE id_compra = 42;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-16 13:47:51');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (314, 4, 45, '2026-09-16 13:47:51', '0.00', '24.00', 'CONCLUIDA', '334357', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (581, 314, 2, 2, NULL, 'UNIDADE', 4, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (314, 'CREDITO', 24.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-16 14:30:00');
SET @id_funcionario_logado = 1;
UPDATE compra SET st_compra = 'RECEBIDA_PARCIAL', dt_recebimento = '2026-09-16 14:30:00', nr_nota_fiscal = '661816' WHERE id_compra = 40;
UPDATE item_compra SET qt_recebida = 26, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 179;
UPDATE item_compra SET qt_recebida = 12, fl_conferido = 1, ds_divergencia = 'Faltaram 2 unidades na entrega' WHERE id_item_compra = 180;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = 'Produto trocado pelo fornecedor: 1 unidades não entregues' WHERE id_item_compra = 181;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 182;
UPDATE item_compra SET qt_recebida = 11, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 183;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (145, 179, 'L2609160145', '2027-04-04', 0),
  (146, 179, 'L2609160146', '2027-04-29', 0),
  (147, 180, 'L2609160347', '2027-03-30', 0),
  (148, 180, 'L2609160348', '2027-04-29', 0),
  (149, 181, 'L2609160949', '2027-01-25', 0),
  (150, 182, 'L2609161350', '2027-03-02', 0),
  (151, 183, 'L2609161551', '2027-06-19', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (1, 1, 145, 'ENTRADA_COMPRA', 13, 'Recebimento da compra 40');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (1, 1, 146, 'ENTRADA_COMPRA', 13, 'Recebimento da compra 40');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (3, 1, 147, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 40');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (3, 1, 148, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 40');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (9, 1, 149, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 40');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (13, 1, 150, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 40');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (15, 1, 151, 'ENTRADA_COMPRA', 11, 'Recebimento da compra 40');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-16 15:09:00');
CALL sp_registrar_evento_acesso(1, 'CONSULTA_DADO_PESSOAL', 'cliente', '10', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-16 15:11:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (18, 22, 45, 'DINHEIRO', '69.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-16 17:24:46');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (315, 4, 45, '2026-09-16 17:24:46', '0.00', '44.50', 'CONCLUIDA', '535647', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (582, 315, 41, 129, NULL, 'UNIDADE', 2, '6.50'),
  (583, 315, 19, 103, NULL, 'UNIDADE', 2, '9.00'),
  (584, 315, 14, 109, NULL, 'UNIDADE', 3, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (315, 'PIX', 44.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-16 18:51:15');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (316, 1, 45, '2026-09-16 18:51:15', '0.00', '10.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (585, 316, 1, 60, NULL, 'UNIDADE', 2, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (316, 'DINHEIRO', 10.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-16 19:00:48');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (317, 1, 45, '2026-09-16 19:00:48', '2.00', '43.00', 'CONCLUIDA', '957431', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (586, 317, 29, NULL, NULL, 'UNIDADE', 1, '45.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (317, 'DINHEIRO', 43.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-16 20:06:46');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (318, 4, 45, '2026-09-16 20:06:46', '0.00', '18.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (587, 318, 11, 13, NULL, 'UNIDADE', 1, '11.00'),
  (588, 318, 20, 64, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (318, 'PIX', 18.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-16 22:08:07');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (319, 4, 45, '2026-09-16 22:08:07', '0.00', '11.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (589, 319, 6, 107, NULL, 'UNIDADE', 1, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (319, 'CREDITO', 11.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-16 23:05:00');
CALL sp_fechar_caixa(45, 272.00);

-- ===== 17/09/2026 (quinta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-17 12:45:44');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-17 12:44:19');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-17 12:57:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (46, 4, '2026-09-17 12:57:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-17 10:35:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (43, 4, 1, '2026-09-17 10:35:00', 'ENTREGA', '129.90', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (188, 43, 39, 12, 0, '4.60', 0),
  (189, 43, 41, 5, 0, '4.20', 0),
  (190, 43, 43, 9, 0, '3.10', 0),
  (191, 43, 46, 6, 0, '3.90', 0),
  (192, 43, 54, 2, 0, '1.20', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-17 10:06:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (44, 5, 1, '2026-09-17 10:06:00', 'RETIRADA', '28.50', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (193, 44, 57, 3, 0, '9.50', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-17 14:20:50');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (320, 4, 46, '2026-09-17 14:20:50', '0.00', '14.00', 'CONCLUIDA', '922874', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (590, 320, 4, 106, NULL, 'UNIDADE', 2, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (320, 'DEBITO', 14.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-17 14:30:00');
SET @id_funcionario_logado = 3;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-17 14:30:00', nr_nota_fiscal = '157706' WHERE id_compra = 41;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 184;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 185;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (28, 3, NULL, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 41');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (30, 3, NULL, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 41');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-17 14:46:18');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (321, 3, 46, '2026-09-17 14:46:18', '0.00', '11.00', 'CONCLUIDA', '769427', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (591, 321, 10, 12, NULL, 'UNIDADE', 2, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (321, 'DEBITO', 11.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-17 15:02:00');
SET @id_funcionario_logado = 4;
CALL sp_registrar_evento_acesso(4, 'CONSULTA_DADO_PESSOAL', 'cliente', '1', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-17 15:04:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (19, 18, 46, 'DINHEIRO', '28.50');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-17 15:21:12');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (322, 4, 46, '2026-09-17 15:21:12', '0.00', '7.00', 'CONCLUIDA', '189597', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (592, 322, 16, 20, NULL, 'UNIDADE', 2, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (322, 'DEBITO', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-17 16:18:23');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (323, 4, 46, '2026-09-17 16:18:23', '0.00', '4.50', 'CONCLUIDA', '406142', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (593, 323, 12, 119, NULL, 'UNIDADE', 1, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (323, 'PIX', 4.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-17 17:00:00');
SET @id_funcionario_logado = 3;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-17 17:00:00', nr_nota_fiscal = '340660' WHERE id_compra = 44;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 193;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (57, 3, NULL, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 44');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-17 18:49:00');
CALL sp_registrar_evento_acesso(3, 'CONSULTA_DADO_PESSOAL', 'cliente', '6', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-17 18:51:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (20, 2, 46, 'DINHEIRO', '26.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-17 19:14:30');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (324, 4, 46, '2026-09-17 19:14:30', '0.00', '84.00', 'CONCLUIDA', '897333', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (594, 324, 19, 103, NULL, 'UNIDADE', 2, '9.00'),
  (595, 324, 6, 107, NULL, 'UNIDADE', 6, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (324, 'CREDITO', 84.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-17 19:33:17');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (325, 3, 46, '2026-09-17 19:33:17', '0.00', '12.00', 'CONCLUIDA', '477475', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (596, 325, 49, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (325, 'DEBITO', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-17 20:18:10');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (326, 3, 46, '2026-09-17 20:18:10', '0.00', '18.00', 'CONCLUIDA', '769556', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (597, 326, 53, NULL, NULL, 'UNIDADE', 2, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (326, 'DINHEIRO', 18.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-17 23:05:00');
SET @id_funcionario_logado = 4;
CALL sp_fechar_caixa(46, 170.50);
UPDATE caixa SET ds_observacao = 'Faltou R$ 2.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 46;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-17 23:07:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '46', '{"diferenca": "-2.00"}', '192.168.0.11');

-- ===== 18/09/2026 (sexta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-18 12:45:26');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-18 12:46:56');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-18 12:42:42');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-18 12:55:00');
SET @id_funcionario_logado = 2;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (47, 2, '2026-09-18 12:55:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-18 10:37:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (45, 1, 1, '2026-09-18 10:37:00', 'ENTREGA', '345.30', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (194, 45, 2, 20, 0, '3.85', 0),
  (195, 45, 4, 18, 0, '4.90', 0),
  (196, 45, 6, 14, 0, '8.00', 0),
  (197, 45, 14, 3, 0, '3.10', 0),
  (198, 45, 19, 8, 0, '6.20', 0),
  (199, 45, 20, 2, 0, '4.60', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-18 14:28:03');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (327, 1, 47, '2026-09-18 14:28:03', '0.00', '31.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (598, 327, 11, 13, NULL, 'UNIDADE', 1, '11.00'),
  (599, 327, 45, 96, NULL, 'UNIDADE', 1, '1.00'),
  (600, 327, 5, 99, NULL, 'UNIDADE', 2, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (327, 'DINHEIRO', 18.60),
  (327, 'PIX', 12.40);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-18 14:30:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-18 14:30:00', nr_nota_fiscal = '133025' WHERE id_compra = 43;
UPDATE item_compra SET qt_recebida = 12, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 188;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 189;
UPDATE item_compra SET qt_recebida = 9, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 190;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 191;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 192;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (152, 188, 'L2609183952', '2026-11-30', 0),
  (153, 189, 'L2609184153', '2027-01-26', 0),
  (154, 190, 'L2609184354', '2027-03-30', 0),
  (155, 191, 'L2609184655', '2027-03-12', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (39, 1, 152, 'ENTRADA_COMPRA', 12, 'Recebimento da compra 43');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (41, 1, 153, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 43');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (43, 1, 154, 'ENTRADA_COMPRA', 9, 'Recebimento da compra 43');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (46, 1, 155, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 43');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (54, 1, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 43');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-18 14:46:02');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (328, 3, 47, '2026-09-18 14:46:02', '0.00', '5.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (601, 328, 10, 74, NULL, 'UNIDADE', 1, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (328, 'PIX', 5.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-18 15:45:11');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (329, 3, 47, '2026-09-18 15:45:11', '0.00', '1.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (602, 329, 47, 135, NULL, 'UNIDADE', 1, '1.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (329, 'PIX', 1.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-18 16:02:02');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (330, 2, 47, '2026-09-18 16:02:02', '0.00', '51.00', 'CONCLUIDA', '810674', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (603, 330, 1, 60, NULL, 'UNIDADE', 3, '5.00'),
  (604, 330, 2, 2, NULL, 'UNIDADE', 5, '6.00'),
  (605, 330, 2, 105, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (330, 'DINHEIRO', 51.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-18 16:52:37');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (331, 1, 47, '2026-09-18 16:52:37', '0.00', '12.00', 'CONCLUIDA', '303575', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (606, 331, 38, NULL, NULL, 'UNIDADE', 2, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (331, 'DEBITO', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-18 19:49:52');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (332, 3, 47, '2026-09-18 19:49:52', '0.00', '36.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (607, 332, 11, 13, NULL, 'UNIDADE', 1, '11.00'),
  (608, 332, 34, NULL, NULL, 'UNIDADE', 2, '12.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (332, 'DEBITO', 36.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-18 21:00:00');
SET @id_funcionario_logado = 2;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (38, 47, 2, 'SANGRIA', '150.00', 'Sangria: retirada do excesso de dinheiro do caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-18 21:04:00');
SET @id_funcionario_logado = 3;
CALL sp_registrar_evento_acesso(3, 'CONSULTA_DADO_PESSOAL', 'cliente', '2', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-18 21:06:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (21, 4, 47, 'PIX', '6.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-18 22:00:18');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (333, 2, 47, '2026-09-18 22:00:18', '0.00', '24.00', 'CONCLUIDA', '939566', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (609, 333, 2, 105, NULL, 'UNIDADE', 4, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (333, 'DINHEIRO', 24.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-18 22:07:42');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (334, 3, 47, '2026-09-18 22:07:42', '0.00', '18.00', 'CONCLUIDA', '284685', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (610, 334, 2, 105, NULL, 'UNIDADE', 3, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (334, 'PIX', 18.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-18 22:10:07');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (335, 2, 47, '2026-09-18 22:10:07', '0.00', '7.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (611, 335, 4, 106, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (335, 'CREDITO', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-18 23:28:38');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (336, 3, 47, '2026-09-18 23:28:38', '0.00', '4.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (612, 336, 47, 135, NULL, 'UNIDADE', 3, '1.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (336, 'DEBITO', 4.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-19 00:08:00');
SET @id_funcionario_logado = 2;
CALL sp_fechar_caixa(47, 93.60);

-- ===== 19/09/2026 (sábado) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-19 12:49:16');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-19 12:44:23');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-19 12:47:48');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-19 12:51:00');
SET @id_funcionario_logado = 4;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (48, 4, '2026-09-19 12:51:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-19 13:02:13');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (337, 3, 48, '2026-09-19 13:02:13', '0.00', '12.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (613, 337, 34, NULL, NULL, 'UNIDADE', 1, '12.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (337, 'PIX', 12.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-19 14:30:00');
SET @id_funcionario_logado = 4;
UPDATE compra SET st_compra = 'RECEBIDA_PARCIAL', dt_recebimento = '2026-09-19 14:30:00', nr_nota_fiscal = '306197' WHERE id_compra = 45;
UPDATE item_compra SET qt_recebida = 20, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 194;
UPDATE item_compra SET qt_recebida = 18, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 195;
UPDATE item_compra SET qt_recebida = 12, fl_conferido = 1, ds_divergencia = '2 unidades avariadas, devolvidas ao fornecedor' WHERE id_item_compra = 196;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 197;
UPDATE item_compra SET qt_recebida = 8, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 198;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 199;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (156, 194, 'L2609190256', '2027-05-07', 0),
  (157, 195, 'L2609190457', '2027-04-30', 0),
  (158, 196, 'L2609190658', '2027-04-16', 0),
  (159, 197, 'L2609191459', '2027-02-23', 0),
  (160, 198, 'L2609191960', '2027-03-05', 0),
  (161, 198, 'L2609191961', '2027-03-28', 0),
  (162, 199, 'L2609192062', '2027-01-21', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (2, 4, 156, 'ENTRADA_COMPRA', 20, 'Recebimento da compra 45');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (4, 4, 157, 'ENTRADA_COMPRA', 18, 'Recebimento da compra 45');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (6, 4, 158, 'ENTRADA_COMPRA', 12, 'Recebimento da compra 45');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (14, 4, 159, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 45');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (19, 4, 160, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 45');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (19, 4, 161, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 45');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (20, 4, 162, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 45');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-19 16:48:28');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (338, 1, 48, '2026-09-19 16:48:28', '0.00', '64.50', 'CONCLUIDA', '760918', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (614, 338, 2, 105, NULL, 'UNIDADE', 1, '6.00'),
  (615, 338, 31, NULL, NULL, 'UNIDADE', 1, '55.00'),
  (616, 338, 16, 20, NULL, 'UNIDADE', 1, '3.50');
CALL sp_registrar_venda_fiado(338, 5, '2026-10-19', 64.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-19 17:40:03');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (339, 1, 48, '2026-09-19 17:40:03', '0.00', '36.00', 'CONCLUIDA', '788155', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (617, 339, 20, 64, NULL, 'UNIDADE', 1, '7.00'),
  (618, 339, 20, 162, NULL, 'UNIDADE', 1, '7.00'),
  (619, 339, 6, 107, NULL, 'UNIDADE', 2, '11.00');
CALL sp_registrar_venda_fiado(339, 10, '2026-10-19', 36.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-19 18:24:00');
SET @id_funcionario_logado = 4;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (39, 48, 4, 'DESPESA', '50.00', 'Material de limpeza');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-19 19:52:06');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (340, 4, 48, '2026-09-19 19:52:06', '0.00', '7.00', 'CONCLUIDA', '729584', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (620, 340, 39, 112, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (340, 'DEBITO', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-19 19:55:45');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (341, 4, 48, '2026-09-19 19:55:45', '0.00', '27.50', 'CONCLUIDA', '435518', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (621, 341, 2, 105, NULL, 'UNIDADE', 4, '6.00'),
  (622, 341, 45, 96, NULL, 'UNIDADE', 1, '1.00'),
  (623, 341, 54, NULL, NULL, 'UNIDADE', 1, '2.50');
CALL sp_registrar_venda_fiado(341, 11, '2026-10-19', 27.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-19 20:38:33');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (342, 3, 48, '2026-09-19 20:38:33', '0.00', '3.00', 'CONCLUIDA', '159142', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (624, 342, 44, 95, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (342, 'DEBITO', 3.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-19 20:46:21');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (343, 1, 48, '2026-09-19 20:46:21', '0.00', '5.50', 'CONCLUIDA', '672431', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (625, 343, 10, 74, NULL, 'UNIDADE', 1, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (343, 'PIX', 5.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-19 21:36:22');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (344, 4, 48, '2026-09-19 21:36:22', '0.00', '61.00', 'CONCLUIDA', '212711', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (626, 344, 5, 99, NULL, 'UNIDADE', 3, '9.50'),
  (627, 344, 5, 138, NULL, 'UNIDADE', 3, '9.50'),
  (628, 344, 48, 43, NULL, 'UNIDADE', 1, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (344, 'PIX', 61.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-19 23:19:08');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (345, 4, 48, '2026-09-19 23:19:08', '0.00', '40.00', 'CONCLUIDA', '660126', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (629, 345, 4, 106, NULL, 'UNIDADE', 4, '7.00'),
  (630, 345, 2, 105, NULL, 'UNIDADE', 2, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (345, 'PIX', 16.00),
  (345, 'DEBITO', 24.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-19 23:38:30');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (346, 4, 48, '2026-09-19 23:38:30', '0.00', '19.50', 'CONCLUIDA', '990407', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (631, 346, 41, 129, NULL, 'UNIDADE', 1, '6.50'),
  (632, 346, 41, 153, NULL, 'UNIDADE', 2, '6.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (346, 'CREDITO', 7.80),
  (346, 'DINHEIRO', 11.70);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-20 00:08:00');
CALL sp_fechar_caixa(48, 61.70);

-- ===== 20/09/2026 (domingo) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-20 12:43:38');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-20 12:48:14');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-20 22:21:00');
CALL sp_registrar_evento_acesso(4, 'LOGIN_FALHA', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-20 12:57:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (49, 4, '2026-09-20 12:57:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-20 13:33:18');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (347, 4, 49, '2026-09-20 13:33:18', '0.00', '3.00', 'CONCLUIDA', '324484', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (633, 347, 47, 135, NULL, 'UNIDADE', 2, '1.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (347, 'DINHEIRO', 3.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-20 19:12:05');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (348, 2, 49, '2026-09-20 19:12:05', '0.00', '12.50', 'CONCLUIDA', '211052', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (634, 348, 34, NULL, NULL, 'UNIDADE', 1, '12.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (348, 'PIX', 7.50),
  (348, 'DINHEIRO', 5.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-20 20:15:50');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (349, 4, 49, '2026-09-20 20:15:50', '0.00', '42.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (635, 349, 4, 106, NULL, 'UNIDADE', 6, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (349, 'DINHEIRO', 42.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-20 20:20:20');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (350, 2, 49, '2026-09-20 20:20:20', '0.00', '59.00', 'CONCLUIDA', '624261', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (636, 350, 6, 158, NULL, 'UNIDADE', 4, '11.00'),
  (637, 350, 49, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (638, 350, 15, 84, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (350, 'DINHEIRO', 59.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-20 20:55:18');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (351, 4, 49, '2026-09-20 20:55:18', '0.00', '7.00', 'CONCLUIDA', '730257', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (639, 351, 3, 147, NULL, 'UNIDADE', 2, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (351, 'PIX', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-20 21:29:12');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (352, 4, 49, '2026-09-20 21:29:12', '0.00', '14.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (640, 352, 57, NULL, NULL, 'UNIDADE', 1, '14.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (352, 'CREDITO', 14.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-20 21:49:30');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (353, 4, 49, '2026-09-20 21:49:30', '0.00', '18.00', 'CONCLUIDA', '232266', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (641, 353, 17, 110, NULL, 'UNIDADE', 1, '9.00'),
  (642, 353, 17, 47, NULL, 'UNIDADE', 1, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (353, 'PIX', 18.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-21 00:08:00');
CALL sp_fechar_caixa(49, 208.00);
UPDATE caixa SET ds_observacao = 'Faltou R$ 1.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 49;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-21 00:10:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '49', '{"diferenca": "-1.00"}', '192.168.0.11');

-- ===== 21/09/2026 (segunda) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-21 12:47:23');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-21 12:47:43');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-21 12:52:00');
SET @id_funcionario_logado = 3;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (50, 3, '2026-09-21 12:52:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-21 10:12:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (46, 3, 1, '2026-09-21 10:12:00', 'RETIRADA', '69.10', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (200, 46, 34, 5, 0, '11.90', 0),
  (201, 46, 38, 3, 0, '3.20', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-21 10:04:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (47, 5, 1, '2026-09-21 10:04:00', 'RETIRADA', '32.50', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (202, 47, 49, 5, 0, '6.50', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-21 13:27:40');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (354, 3, 50, '2026-09-21 13:27:40', '0.00', '7.00', 'CONCLUIDA', '552963', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (643, 354, 8, 9, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (354, 'DEBITO', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-21 17:00:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-21 17:00:00', nr_nota_fiscal = '462258' WHERE id_compra = 46;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 200;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 201;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (34, 3, NULL, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 46');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (38, 3, NULL, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 46');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-21 17:00:00', nr_nota_fiscal = '468592' WHERE id_compra = 47;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 202;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (49, 3, NULL, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 47');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-21 18:14:48');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (355, 3, 50, '2026-09-21 18:14:48', '0.00', '34.00', 'CONCLUIDA', '630859', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (644, 355, 20, 162, NULL, 'UNIDADE', 1, '7.00'),
  (645, 355, 20, 104, NULL, 'UNIDADE', 1, '7.00'),
  (646, 355, 12, 119, NULL, 'UNIDADE', 2, '4.50'),
  (647, 355, 11, 13, NULL, 'UNIDADE', 1, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (355, 'DINHEIRO', 34.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-21 20:36:00');
CALL sp_registrar_evento_acesso(3, 'CONSULTA_DADO_PESSOAL', 'cliente', '5', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-21 20:38:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (22, 23, 50, 'DINHEIRO', '64.50');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-21 21:19:45');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (356, 2, 50, '2026-09-21 21:19:45', '0.00', '21.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (648, 356, 8, 9, NULL, 'UNIDADE', 3, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (356, 'DINHEIRO', 21.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-21 21:26:39');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (357, 3, 50, '2026-09-21 21:26:39', '0.00', '12.00', 'CONCLUIDA', '935049', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (649, 357, 38, NULL, NULL, 'UNIDADE', 2, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (357, 'DINHEIRO', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-21 23:05:00');
CALL sp_fechar_caixa(50, 283.50);
UPDATE caixa SET ds_observacao = 'Sobrou R$ 2.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 50;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-21 23:07:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '50', '{"diferenca": "2.00"}', '192.168.0.11');

-- ===== 22/09/2026 (terça) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-22 12:44:05');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-22 12:45:54');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-22 12:54:00');
SET @id_funcionario_logado = 1;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (51, 1, '2026-09-22 12:54:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-22 10:21:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (48, 1, 1, '2026-09-22 10:21:00', 'ENTREGA', '257.60', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (203, 48, 2, 20, 0, '3.85', 0),
  (204, 48, 5, 13, 0, '6.80', 0),
  (205, 48, 10, 9, 0, '3.40', 0),
  (206, 48, 12, 6, 0, '3.10', 0),
  (207, 48, 16, 3, 0, '2.00', 0),
  (208, 48, 17, 3, 0, '6.20', 0),
  (209, 48, 20, 4, 0, '4.60', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-22 13:20:00');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 1, 127, 'PERDA', 3, 'Lote vencido em 20/09/2026');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-22 13:21:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '885', '{"tipo": "PERDA", "motivo": "vencimento", "lote": 127, "quantidade": 3}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-22 18:34:17');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (358, 2, 51, '2026-09-22 18:34:17', '0.00', '43.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (650, 358, 36, NULL, NULL, 'UNIDADE', 1, '22.00'),
  (651, 358, 2, 105, NULL, 'UNIDADE', 2, '6.00'),
  (652, 358, 12, 119, NULL, 'UNIDADE', 1, '4.50'),
  (653, 358, 12, 100, NULL, 'UNIDADE', 1, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (358, 'CREDITO', 43.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-22 20:20:56');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (359, 2, 51, '2026-09-22 20:20:56', '0.00', '79.50', 'CONCLUIDA', '859430', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (654, 359, 39, 112, NULL, 'UNIDADE', 1, '7.00'),
  (655, 359, 39, 152, NULL, 'UNIDADE', 1, '7.00'),
  (656, 359, 7, 8, NULL, 'UNIDADE', 6, '9.50'),
  (657, 359, 60, 56, NULL, 'UNIDADE', 1, '8.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (359, 'CREDITO', 79.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-22 21:53:41');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (360, 1, 51, '2026-09-22 21:53:41', '0.00', '18.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (658, 360, 56, NULL, NULL, 'UNIDADE', 2, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (360, 'DINHEIRO', 18.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-22 21:58:17');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (361, 1, 51, '2026-09-22 21:58:17', '0.00', '30.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (659, 361, 1, 60, NULL, 'UNIDADE', 6, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (361, 'DINHEIRO', 30.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-22 23:05:00');
CALL sp_fechar_caixa(51, 198.00);

-- ===== 23/09/2026 (quarta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-23 12:41:28');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-23 12:45:14');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-23 13:20:00');
CALL sp_registrar_evento_acesso(4, 'LOGIN_FALHA', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-23 12:57:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (52, 1, '2026-09-23 12:57:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-23 10:10:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (49, 2, 1, '2026-09-23 10:10:00', 'ENTREGA', '136.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (210, 49, 29, 2, 0, '30.00', 0),
  (211, 49, 31, 2, 0, '38.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-23 14:30:00');
SET @id_funcionario_logado = 4;
UPDATE compra SET st_compra = 'RECEBIDA_PARCIAL', dt_recebimento = '2026-09-23 14:30:00', nr_nota_fiscal = '475182' WHERE id_compra = 48;
UPDATE item_compra SET qt_recebida = 18, fl_conferido = 1, ds_divergencia = 'Faltaram 2 unidades na entrega' WHERE id_item_compra = 203;
UPDATE item_compra SET qt_recebida = 13, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 204;
UPDATE item_compra SET qt_recebida = 9, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 205;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = '1 unidades avariadas, devolvidas ao fornecedor' WHERE id_item_compra = 206;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 207;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 208;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 209;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (163, 203, 'L2609230263', '2027-05-16', 0),
  (164, 204, 'L2609230564', '2027-04-14', 0),
  (165, 205, 'L2609231065', '2027-02-15', 0),
  (166, 205, 'L2609231066', '2027-03-08', 0),
  (167, 206, 'L2609231267', '2027-02-26', 0),
  (168, 207, 'L2609231668', '2027-04-03', 0),
  (169, 208, 'L2609231769', '2026-12-04', 0),
  (170, 209, 'L2609232070', '2027-04-07', 0),
  (171, 209, 'L2609232071', '2027-05-13', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (2, 4, 163, 'ENTRADA_COMPRA', 18, 'Recebimento da compra 48');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (5, 4, 164, 'ENTRADA_COMPRA', 13, 'Recebimento da compra 48');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (10, 4, 165, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 48');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (10, 4, 166, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 48');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (12, 4, 167, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 48');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (16, 4, 168, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 48');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (17, 4, 169, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 48');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (20, 4, 170, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 48');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (20, 4, 171, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 48');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-23 16:15:00');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (12, 1, 167, 'PERDA', 1, 'Embalagem avariada no manuseio');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-23 16:16:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '905', '{"tipo": "PERDA", "motivo": "Embalagem avariada no manuseio", "quantidade": 1}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-23 16:44:04');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (362, 1, 52, '2026-09-23 16:44:04', '0.00', '14.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (660, 362, 16, 168, NULL, 'UNIDADE', 2, '3.50'),
  (661, 362, 8, 9, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (362, 'DEBITO', 14.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-23 19:38:28');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (363, 1, 52, '2026-09-23 19:38:28', '0.00', '48.00', 'CONCLUIDA', '894678', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (662, 363, 34, NULL, NULL, 'UNIDADE', 1, '12.50'),
  (663, 363, 47, 135, NULL, 'UNIDADE', 1, '1.50'),
  (664, 363, 33, NULL, NULL, 'UNIDADE', 2, '12.00'),
  (665, 363, 1, 60, NULL, 'UNIDADE', 2, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (363, 'PIX', 48.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-23 20:01:22');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (364, 4, 52, '2026-09-23 20:01:22', '0.00', '17.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (666, 364, 10, 74, NULL, 'UNIDADE', 1, '5.50'),
  (667, 364, 12, 167, NULL, 'UNIDADE', 2, '4.50'),
  (668, 364, 15, 84, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (364, 'DINHEIRO', 9.00);
CALL sp_registrar_venda_fiado(364, 4, '2026-10-23', 8.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-23 21:32:00');
SET @id_funcionario_logado = 1;
CALL sp_registrar_evento_acesso(1, 'CONSULTA_DADO_PESSOAL', 'cliente', '8', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-23 21:34:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (23, 13, 52, 'DEBITO', '43.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-23 21:45:15');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (365, 4, 52, '2026-09-23 21:45:15', '0.00', '31.50', 'CONCLUIDA', '272314', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (669, 365, 15, 84, NULL, 'UNIDADE', 1, '3.00'),
  (670, 365, 7, 8, NULL, 'UNIDADE', 1, '9.50'),
  (671, 365, 7, 108, NULL, 'UNIDADE', 2, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (365, 'CREDITO', 31.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-23 23:05:00');
SET @id_funcionario_logado = 1;
CALL sp_fechar_caixa(52, 159.00);

-- ===== 24/09/2026 (quinta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-24 12:42:17');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-24 12:41:10');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-24 12:59:00');
SET @id_funcionario_logado = 4;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (53, 4, '2026-09-24 12:59:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-24 10:06:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (50, 4, 1, '2026-09-24 10:06:00', 'ENTREGA', '17.20', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (212, 50, 47, 7, 0, '0.80', 0),
  (213, 50, 53, 2, 0, '5.80', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-24 10:23:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (51, 5, 1, '2026-09-24 10:23:00', 'RETIRADA', '36.20', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (214, 51, 56, 2, 0, '6.50', 0),
  (215, 51, 60, 4, 0, '5.80', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-24 13:25:58');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (366, 3, 53, '2026-09-24 13:25:58', '0.00', '101.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (672, 366, 23, 27, NULL, 'UNIDADE', 1, '89.00'),
  (673, 366, 33, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (366, 'DINHEIRO', 101.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-24 14:30:00');
SET @id_funcionario_logado = 4;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-24 14:30:00', nr_nota_fiscal = '929146' WHERE id_compra = 49;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 210;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 211;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (29, 4, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 49');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (31, 4, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 49');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-24 17:00:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-24 17:00:00', nr_nota_fiscal = '488658' WHERE id_compra = 51;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 214;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 215;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (172, 215, 'L2609246072', '2026-10-03', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (56, 4, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 51');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 4, 172, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 51');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-24 17:44:44');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (367, 3, 53, '2026-09-24 17:44:44', '0.00', '169.00', 'CONCLUIDA', '669118', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (674, 367, 31, NULL, NULL, 'UNIDADE', 1, '55.00'),
  (675, 367, 8, 9, NULL, 'UNIDADE', 6, '7.00'),
  (676, 367, 8, 140, NULL, 'UNIDADE', 6, '7.00'),
  (677, 367, 9, 149, NULL, 'UNIDADE', 1, '18.00'),
  (678, 367, 46, 133, NULL, 'UNIDADE', 2, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (367, 'PIX', 169.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-24 18:14:45');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (368, 4, 53, '2026-09-24 18:14:45', '0.00', '5.00', 'CONCLUIDA', '548936', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (679, 368, 1, 60, NULL, 'UNIDADE', 1, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (368, 'DINHEIRO', 5.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-24 18:40:28');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (369, 3, 53, '2026-09-24 18:40:28', '0.00', '13.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (680, 369, 54, NULL, NULL, 'UNIDADE', 1, '2.50'),
  (681, 369, 51, NULL, NULL, 'UNIDADE', 1, '8.00'),
  (682, 369, 15, 84, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (369, 'PIX', 13.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-24 19:31:00');
CALL sp_registrar_evento_acesso(3, 'CONSULTA_DADO_PESSOAL', 'cliente', '10', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-24 19:33:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (24, 24, 53, 'PIX', '36.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-24 21:12:22');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (370, 3, 53, '2026-09-24 21:12:22', '0.00', '11.00', 'CONCLUIDA', '603831', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (683, 370, 11, 83, NULL, 'UNIDADE', 1, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (370, 'CREDITO', 11.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-24 23:05:00');
SET @id_funcionario_logado = 4;
CALL sp_fechar_caixa(53, 203.00);
UPDATE caixa SET ds_observacao = 'Faltou R$ 3.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 53;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-24 23:07:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '53', '{"diferenca": "-3.00"}', '192.168.0.11');

-- ===== 25/09/2026 (sexta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-25 12:41:06');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-25 12:42:47');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-25 12:49:16');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-25 12:56:00');
SET @id_funcionario_logado = 1;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (54, 1, '2026-09-25 12:56:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-25 10:18:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (52, 1, 1, '2026-09-25 10:18:00', 'ENTREGA', '240.80', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (216, 52, 7, 16, 0, '6.70', 0),
  (217, 52, 8, 18, 0, '5.00', 0),
  (218, 52, 9, 2, 0, '12.50', 0),
  (219, 52, 12, 6, 0, '3.10', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-25 14:23:36');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (371, 1, 54, '2026-09-25 14:23:36', '0.00', '12.50', 'CONCLUIDA', '977947', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (684, 371, 7, 108, NULL, 'UNIDADE', 1, '9.50'),
  (685, 371, 44, 95, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (371, 'PIX', 12.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-25 14:30:00');
SET @id_funcionario_logado = 2;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-25 14:30:00', nr_nota_fiscal = '428955' WHERE id_compra = 50;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 212;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 213;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (173, 212, 'L2609254773', '2027-01-31', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (47, 2, 173, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 50');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (53, 2, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 50');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-25 15:38:49');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (372, 3, 54, '2026-09-25 15:38:49', '0.00', '43.00', 'CONCLUIDA', '855941', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (686, 372, 46, 155, NULL, 'UNIDADE', 5, '6.00'),
  (687, 372, 44, 95, NULL, 'UNIDADE', 1, '3.00'),
  (688, 372, 1, 60, NULL, 'UNIDADE', 2, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (372, 'DEBITO', 43.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-25 16:23:02');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (373, 3, 54, '2026-09-25 16:23:02', '0.00', '102.00', 'CONCLUIDA', '847830', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (689, 373, 2, 105, NULL, 'UNIDADE', 6, '6.00'),
  (690, 373, 2, 156, NULL, 'UNIDADE', 6, '6.00'),
  (691, 373, 1, 60, NULL, 'UNIDADE', 4, '5.00'),
  (692, 373, 1, 145, NULL, 'UNIDADE', 2, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (373, 'DINHEIRO', 40.80),
  (373, 'CREDITO', 61.20);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-25 16:43:00');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (40, 54, 1, 'DESPESA', '50.00', 'Compra de gelo para o balcão');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-25 18:12:23');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (374, 3, 54, '2026-09-25 18:12:23', '2.00', '32.00', 'CONCLUIDA', '457636', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (693, 374, 33, NULL, NULL, 'UNIDADE', 2, '12.00'),
  (694, 374, 43, 114, NULL, 'UNIDADE', 2, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (374, 'DEBITO', 32.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-25 19:04:59');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (375, 3, 54, '2026-09-25 19:04:59', '0.00', '22.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (695, 375, 6, 158, NULL, 'UNIDADE', 2, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (375, 'PIX', 22.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-25 19:18:19');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (376, 2, 54, '2026-09-25 19:18:19', '0.00', '92.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (696, 376, 13, 123, NULL, 'UNIDADE', 2, '9.50'),
  (697, 376, 13, 124, NULL, 'UNIDADE', 1, '9.50'),
  (698, 376, 4, 106, NULL, 'UNIDADE', 6, '7.00'),
  (699, 376, 3, 147, NULL, 'UNIDADE', 2, '3.50'),
  (700, 376, 44, 95, NULL, 'UNIDADE', 1, '3.00'),
  (701, 376, 26, NULL, 2, 'DOSE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (376, 'PIX', 92.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-25 19:52:00');
CALL sp_registrar_evento_acesso(2, 'CONSULTA_DADO_PESSOAL', 'cliente', '8', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-25 19:54:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (25, 14, 54, 'DINHEIRO', '60.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-25 20:49:53');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (377, 3, 54, '2026-09-25 20:49:53', '0.00', '192.00', 'CONCLUIDA', '666416', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (702, 377, 1, 145, NULL, 'UNIDADE', 11, '5.00'),
  (703, 377, 1, 79, NULL, 'UNIDADE', 1, '5.00'),
  (704, 377, 6, 158, NULL, 'UNIDADE', 6, '11.00'),
  (705, 377, 6, 139, NULL, 'UNIDADE', 6, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (377, 'DINHEIRO', 192.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-25 21:00:00');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (41, 54, 1, 'SANGRIA', '150.00', 'Sangria: retirada do excesso de dinheiro do caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-25 21:40:45');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (378, 1, 54, '2026-09-25 21:40:45', '0.00', '64.00', 'CONCLUIDA', '346116', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (706, 378, 28, NULL, NULL, 'UNIDADE', 2, '32.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (378, 'DEBITO', 25.60),
  (378, 'PIX', 38.40);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-25 23:00:26');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (379, 3, 54, '2026-09-25 23:00:26', '0.00', '30.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (707, 379, 3, 147, NULL, 'UNIDADE', 2, '3.50'),
  (708, 379, 3, 98, NULL, 'UNIDADE', 4, '3.50'),
  (709, 379, 44, 95, NULL, 'UNIDADE', 2, '3.00'),
  (710, 379, 44, 66, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (379, 'DINHEIRO', 30.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-25 23:44:25');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (380, 2, 54, '2026-09-25 23:44:25', '0.00', '16.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (711, 380, 40, 91, NULL, 'UNIDADE', 2, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (380, 'PIX', 16.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 00:08:00');
SET @id_funcionario_logado = 1;
CALL sp_fechar_caixa(54, 224.80);
UPDATE caixa SET ds_observacao = 'Sobrou R$ 2.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 54;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 00:10:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '54', '{"diferenca": "2.00"}', '192.168.0.11');

-- ===== 26/09/2026 (sábado) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 12:44:54');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 12:44:28');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 12:48:23');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 12:53:00');
SET @id_funcionario_logado = 4;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (55, 4, '2026-09-26 12:53:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 13:05:47');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (381, 3, 55, '2026-09-26 13:05:47', '0.00', '25.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (712, 381, 19, 160, NULL, 'UNIDADE', 1, '9.00'),
  (713, 381, 11, 83, NULL, 'UNIDADE', 1, '11.00'),
  (714, 381, 54, NULL, NULL, 'UNIDADE', 2, '2.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (381, 'DINHEIRO', 25.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 13:20:00');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 1, 56, 'PERDA', 2, 'Lote vencido em 25/09/2026');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 13:21:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '966', '{"tipo": "PERDA", "motivo": "vencimento", "lote": 56, "quantidade": 2}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 13:27:38');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (382, 3, 55, '2026-09-26 13:27:38', '0.00', '31.00', 'CONCLUIDA', '844059', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (715, 382, 54, NULL, NULL, 'UNIDADE', 1, '2.50'),
  (716, 382, 13, 124, NULL, 'UNIDADE', 3, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (382, 'DINHEIRO', 31.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 13:50:47');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (383, 3, 55, '2026-09-26 13:50:47', '0.00', '95.50', 'CONCLUIDA', '344263', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (717, 383, 29, NULL, NULL, 'UNIDADE', 1, '45.00'),
  (718, 383, 39, 152, NULL, 'UNIDADE', 3, '7.00'),
  (719, 383, 47, 135, NULL, 'UNIDADE', 1, '1.50'),
  (720, 383, 4, 72, NULL, 'UNIDADE', 4, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (383, 'DEBITO', 95.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 14:30:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-26 14:30:00', nr_nota_fiscal = '562831' WHERE id_compra = 52;
UPDATE item_compra SET qt_recebida = 16, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 216;
UPDATE item_compra SET qt_recebida = 18, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 217;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 218;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 219;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (174, 216, 'L2609260774', '2027-04-19', 0),
  (175, 217, 'L2609260875', '2027-05-18', 0),
  (176, 217, 'L2609260876', '2027-06-18', 0),
  (177, 218, 'L2609260977', '2027-03-10', 0),
  (178, 219, 'L2609261278', '2027-02-05', 0),
  (179, 219, 'L2609261279', '2027-02-27', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (7, 3, 174, 'ENTRADA_COMPRA', 16, 'Recebimento da compra 52');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (8, 3, 175, 'ENTRADA_COMPRA', 9, 'Recebimento da compra 52');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (8, 3, 176, 'ENTRADA_COMPRA', 9, 'Recebimento da compra 52');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (9, 3, 177, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 52');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (12, 3, 178, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 52');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (12, 3, 179, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 52');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 15:39:00');
SET @id_funcionario_logado = 4;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (42, 55, 4, 'DESPESA', '20.00', 'Café e água dos funcionários');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 17:08:42');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (384, 1, 55, '2026-09-26 17:08:42', '0.00', '5.00', 'CONCLUIDA', '644669', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (721, 384, 1, 79, NULL, 'UNIDADE', 1, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (384, 'PIX', 5.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 17:28:25');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (385, 3, 55, '2026-09-26 17:28:25', '0.00', '25.50', 'CONCLUIDA', '515094', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (722, 385, 54, NULL, NULL, 'UNIDADE', 1, '2.50'),
  (723, 385, 46, 155, NULL, 'UNIDADE', 1, '6.00'),
  (724, 385, 46, 134, NULL, 'UNIDADE', 1, '6.00'),
  (725, 385, 11, 83, NULL, 'UNIDADE', 1, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (385, 'PIX', 25.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 18:31:51');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (386, 4, 55, '2026-09-26 18:31:51', '0.00', '27.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (726, 386, 49, NULL, NULL, 'UNIDADE', 2, '12.00'),
  (727, 386, 3, 98, NULL, 'UNIDADE', 1, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (386, 'DINHEIRO', 27.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 18:56:40');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (387, 1, 55, '2026-09-26 18:56:40', '0.00', '36.00', 'CONCLUIDA', '391812', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (728, 387, 1, 79, NULL, 'UNIDADE', 4, '5.00'),
  (729, 387, 24, 87, NULL, 'UNIDADE', 1, '16.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (387, 'DEBITO', 21.60),
  (387, 'CREDITO', 14.40);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 19:36:25');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (388, 1, 55, '2026-09-26 19:36:25', '0.00', '6.00', 'CONCLUIDA', '405570', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (730, 388, 15, 84, NULL, 'UNIDADE', 2, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (388, 'CREDITO', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 20:32:13');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (389, 1, 55, '2026-09-26 20:32:13', '0.00', '40.00', 'CONCLUIDA', '110337', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (731, 389, 55, NULL, NULL, 'UNIDADE', 2, '6.00'),
  (732, 389, 57, NULL, NULL, 'UNIDADE', 2, '14.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (389, 'CREDITO', 40.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 20:46:46');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (390, 4, 55, '2026-09-26 20:46:46', '0.00', '18.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (733, 390, 56, NULL, NULL, 'UNIDADE', 2, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (390, 'DEBITO', 18.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 21:13:44');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (391, 3, 55, '2026-09-26 21:13:44', '0.00', '18.00', 'CONCLUIDA', '443265', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (734, 391, 12, 178, NULL, 'UNIDADE', 2, '4.50'),
  (735, 391, 17, 169, NULL, 'UNIDADE', 1, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (391, 'DINHEIRO', 18.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 21:12:00');
CALL sp_registrar_evento_acesso(3, 'CONSULTA_DADO_PESSOAL', 'cliente', '6', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 21:14:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (26, 15, 55, 'DEBITO', '50.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 21:51:32');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (392, 3, 55, '2026-09-26 21:51:32', '0.00', '36.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (736, 392, 35, NULL, NULL, 'UNIDADE', 1, '13.00'),
  (737, 392, 10, 74, NULL, 'UNIDADE', 2, '5.50'),
  (738, 392, 33, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (392, 'CREDITO', 14.40),
  (392, 'PIX', 21.60);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-26 22:36:10');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (393, 4, 55, '2026-09-26 22:36:10', '0.00', '4.00', 'CONCLUIDA', '978128', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (739, 393, 18, 22, NULL, 'UNIDADE', 1, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (393, 'PIX', 4.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-27 00:08:00');
CALL sp_fechar_caixa(55, 181.50);

-- ===== 27/09/2026 (domingo) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-27 12:45:55');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-27 12:43:31');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-27 12:51:00');
SET @id_funcionario_logado = 2;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (56, 2, '2026-09-27 12:51:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-27 15:10:59');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (394, 2, 56, '2026-09-27 15:10:59', '0.00', '4.50', 'CONCLUIDA', '706746', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (740, 394, 14, 101, NULL, 'UNIDADE', 1, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (394, 'PIX', 4.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-27 15:15:20');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (395, 2, 56, '2026-09-27 15:15:20', '0.00', '11.00', 'CONCLUIDA', '460009', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (741, 395, 10, 165, NULL, 'UNIDADE', 2, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (395, 'CREDITO', 11.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-27 15:24:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (43, 56, 2, 'DESPESA', '50.00', 'Material de limpeza');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-27 17:56:02');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (396, 2, 56, '2026-09-27 17:56:02', '0.00', '24.00', 'CONCLUIDA', '895760', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (742, 396, 33, NULL, NULL, 'UNIDADE', 2, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (396, 'DEBITO', 24.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-27 18:19:14');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (397, 2, 56, '2026-09-27 18:19:14', '0.00', '6.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (743, 397, 38, NULL, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (397, 'DINHEIRO', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-27 19:10:58');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (398, 2, 56, '2026-09-27 19:10:58', '0.00', '32.00', 'CONCLUIDA', '526510', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (744, 398, 28, NULL, NULL, 'UNIDADE', 1, '32.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (398, 'CREDITO', 32.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-27 21:21:38');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (399, 4, 56, '2026-09-27 21:21:38', '0.00', '7.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (745, 399, 8, 140, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (399, 'PIX', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-27 22:09:30');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (400, 2, 56, '2026-09-27 22:09:30', '0.00', '11.00', 'CONCLUIDA', '944067', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (746, 400, 10, 165, NULL, 'UNIDADE', 2, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (400, 'DEBITO', 11.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-28 00:08:00');
CALL sp_fechar_caixa(56, 106.00);

-- ===== 28/09/2026 (segunda) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-28 12:40:35');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-28 12:48:24');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-28 12:58:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (57, 2, '2026-09-28 12:58:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-28 10:13:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (53, 3, 1, '2026-09-28 10:13:00', 'RETIRADA', '91.20', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (220, 53, 33, 8, 0, '10.20', 0),
  (221, 53, 38, 3, 0, '3.20', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-28 10:18:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (54, 5, 1, '2026-09-28 10:18:00', 'RETIRADA', '61.10', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (222, 54, 55, 2, 0, '4.00', 0),
  (223, 54, 56, 2, 0, '6.50', 0),
  (224, 54, 57, 3, 0, '9.50', 0),
  (225, 54, 60, 2, 0, '5.80', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-28 14:33:05');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (401, 2, 57, '2026-09-28 14:33:05', '0.00', '3.00', 'CONCLUIDA', '653653', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (747, 401, 44, 66, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (401, 'PIX', 3.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-28 15:53:42');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (402, 2, 57, '2026-09-28 15:53:42', '0.00', '12.50', 'CONCLUIDA', '732989', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (748, 402, 47, 135, NULL, 'UNIDADE', 1, '1.50'),
  (749, 402, 10, 75, NULL, 'UNIDADE', 2, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (402, 'PIX', 12.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-28 17:00:00');
SET @id_funcionario_logado = 3;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-28 17:00:00', nr_nota_fiscal = '588122' WHERE id_compra = 53;
UPDATE item_compra SET qt_recebida = 8, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 220;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 221;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (33, 3, NULL, 'ENTRADA_COMPRA', 8, 'Recebimento da compra 53');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (38, 3, NULL, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 53');
SET @id_funcionario_logado = 2;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-28 17:00:00', nr_nota_fiscal = '173635' WHERE id_compra = 54;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 222;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 223;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 224;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 225;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (180, 225, 'L2609286080', '2026-10-09', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (55, 2, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 54');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (56, 2, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 54');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (57, 2, NULL, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 54');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 2, 180, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 54');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-28 17:49:29');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (403, 2, 57, '2026-09-28 17:49:29', '0.00', '9.50', 'CONCLUIDA', '925275', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (750, 403, 5, 164, NULL, 'UNIDADE', 1, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (403, 'PIX', 9.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-28 19:36:21');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (404, 2, 57, '2026-09-28 19:36:21', '0.00', '8.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (751, 404, 40, 92, NULL, 'UNIDADE', 1, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (404, 'DEBITO', 8.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-28 20:23:52');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (405, 3, 57, '2026-09-28 20:23:52', '0.00', '11.00', 'CONCLUIDA', '280378', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (752, 405, 10, 75, NULL, 'UNIDADE', 2, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (405, 'CREDITO', 5.50),
  (405, 'PIX', 5.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-28 22:19:56');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (406, 3, 57, '2026-09-28 22:19:56', '0.00', '29.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (753, 406, 50, NULL, NULL, 'UNIDADE', 1, '4.00'),
  (754, 406, 37, NULL, NULL, 'UNIDADE', 1, '25.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (406, 'PIX', 29.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-28 23:05:00');
SET @id_funcionario_logado = 2;
CALL sp_fechar_caixa(57, 200.00);

-- ===== 29/09/2026 (terça) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-29 12:47:32');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-29 12:42:24');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-29 12:52:00');
SET @id_funcionario_logado = 1;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (58, 1, '2026-09-29 12:52:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-29 10:20:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (55, 1, 1, '2026-09-29 10:20:00', 'ENTREGA', '630.40', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (226, 55, 1, 41, 0, '3.10', 0),
  (227, 55, 2, 16, 0, '3.85', 0),
  (228, 55, 3, 13, 0, '2.40', 0),
  (229, 55, 4, 21, 0, '4.90', 0),
  (230, 55, 6, 22, 0, '8.00', 0),
  (231, 55, 10, 11, 0, '3.40', 0),
  (232, 55, 11, 7, 0, '7.80', 0),
  (233, 55, 13, 6, 0, '6.60', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-29 16:56:00');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (9, 1, 149, 'PERDA', 3, 'Produto danificado no transporte');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-29 16:57:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '1019', '{"tipo": "PERDA", "motivo": "Produto danificado no transporte", "quantidade": 3}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-29 18:52:47');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (407, 2, 58, '2026-09-29 18:52:47', '0.00', '21.00', 'CONCLUIDA', '944931', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (755, 407, 22, NULL, 1, 'DOSE', 3, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (407, 'DINHEIRO', 21.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-29 19:04:18');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (408, 2, 58, '2026-09-29 19:04:18', '0.00', '16.50', 'CONCLUIDA', '287533', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (756, 408, 10, 75, NULL, 'UNIDADE', 2, '5.50'),
  (757, 408, 10, 166, NULL, 'UNIDADE', 1, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (408, 'DEBITO', 16.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-29 20:08:45');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (409, 1, 58, '2026-09-29 20:08:45', '0.00', '9.50', 'CONCLUIDA', '577327', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (758, 409, 5, 164, NULL, 'UNIDADE', 1, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (409, 'PIX', 9.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-29 20:44:48');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (410, 1, 58, '2026-09-29 20:44:48', '0.00', '25.50', 'CONCLUIDA', '175003', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (759, 410, 34, NULL, NULL, 'UNIDADE', 1, '12.50'),
  (760, 410, 46, 134, NULL, 'UNIDADE', 1, '6.00'),
  (761, 410, 4, 72, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (410, 'DINHEIRO', 25.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-29 21:12:47');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (411, 2, 58, '2026-09-29 21:12:47', '0.00', '12.00', 'CONCLUIDA', '459022', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (762, 411, 49, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (411, 'CREDITO', 7.20),
  (411, 'DEBITO', 4.80);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-29 22:20:07');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (412, 1, 58, '2026-09-29 22:20:07', '0.00', '21.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (763, 412, 39, 152, NULL, 'UNIDADE', 3, '7.00');
CALL sp_registrar_venda_fiado(412, 5, '2026-10-29', 21.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-29 23:05:00');
CALL sp_fechar_caixa(58, 146.50);

-- ===== 30/09/2026 (quarta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-30 12:49:45');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-30 12:44:36');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-30 12:52:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (59, 1, '2026-09-30 12:52:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-30 10:32:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (56, 2, 1, '2026-09-30 10:32:00', 'ENTREGA', '84.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (234, 56, 24, 2, 0, '10.50', 0),
  (235, 56, 28, 3, 0, '21.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-30 14:30:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-09-30 14:30:00', nr_nota_fiscal = '554229' WHERE id_compra = 55;
UPDATE item_compra SET qt_recebida = 41, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 226;
UPDATE item_compra SET qt_recebida = 16, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 227;
UPDATE item_compra SET qt_recebida = 13, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 228;
UPDATE item_compra SET qt_recebida = 21, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 229;
UPDATE item_compra SET qt_recebida = 22, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 230;
UPDATE item_compra SET qt_recebida = 11, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 231;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 232;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 233;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (181, 226, 'L2609300181', '2027-03-31', 0),
  (182, 226, 'L2609300182', '2027-04-29', 0),
  (183, 227, 'L2609300283', '2027-05-16', 0),
  (184, 227, 'L2609300284', '2027-06-20', 0),
  (185, 228, 'L2609300385', '2027-03-18', 0),
  (186, 228, 'L2609300386', '2027-04-20', 0),
  (187, 229, 'L2609300487', '2027-04-14', 0),
  (188, 229, 'L2609300488', '2027-05-05', 0),
  (189, 230, 'L2609300689', '2027-04-19', 0),
  (190, 230, 'L2609300690', '2027-05-26', 0),
  (191, 231, 'L2609301091', '2027-02-19', 0),
  (192, 231, 'L2609301092', '2027-03-16', 0),
  (193, 232, 'L2609301193', '2027-01-30', 0),
  (194, 233, 'L2609301394', '2027-02-19', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (1, 1, 181, 'ENTRADA_COMPRA', 20, 'Recebimento da compra 55');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (1, 1, 182, 'ENTRADA_COMPRA', 21, 'Recebimento da compra 55');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (2, 1, 183, 'ENTRADA_COMPRA', 8, 'Recebimento da compra 55');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (2, 1, 184, 'ENTRADA_COMPRA', 8, 'Recebimento da compra 55');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (3, 1, 185, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 55');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (3, 1, 186, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 55');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (4, 1, 187, 'ENTRADA_COMPRA', 10, 'Recebimento da compra 55');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (4, 1, 188, 'ENTRADA_COMPRA', 11, 'Recebimento da compra 55');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (6, 1, 189, 'ENTRADA_COMPRA', 11, 'Recebimento da compra 55');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (6, 1, 190, 'ENTRADA_COMPRA', 11, 'Recebimento da compra 55');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (10, 1, 191, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 55');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (10, 1, 192, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 55');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (11, 1, 193, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 55');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (13, 1, 194, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 55');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-30 16:34:43');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (413, 1, 59, '2026-09-30 16:34:43', '0.00', '42.00', 'CONCLUIDA', '927551', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (764, 413, 3, 185, NULL, 'UNIDADE', 4, '3.50'),
  (765, 413, 23, NULL, 5, 'DOSE', 2, '14.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (413, 'PIX', 42.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-30 18:47:11');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (414, 4, 59, '2026-09-30 18:47:11', '0.00', '5.00', 'CONCLUIDA', '684741', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (766, 414, 1, 181, NULL, 'UNIDADE', 1, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (414, 'PIX', 5.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-30 20:30:32');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (415, 1, 59, '2026-09-30 20:30:32', '0.00', '25.00', 'CONCLUIDA', '407916', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (767, 415, 10, 191, NULL, 'UNIDADE', 2, '5.50'),
  (768, 415, 22, NULL, 1, 'DOSE', 2, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (415, 'PIX', 25.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-30 21:09:59');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (416, 1, 59, '2026-09-30 21:09:59', '0.00', '34.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (769, 416, 8, 140, NULL, 'UNIDADE', 3, '7.00'),
  (770, 416, 50, NULL, NULL, 'UNIDADE', 1, '4.00'),
  (771, 416, 5, 164, NULL, 'UNIDADE', 1, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (416, 'PIX', 34.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-30 21:29:18');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (417, 1, 59, '2026-09-30 21:29:18', '0.00', '3.00', 'CONCLUIDA', '842779', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (772, 417, 15, 84, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (417, 'PIX', 3.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-09-30 23:05:00');
CALL sp_fechar_caixa(59, 150.00);

-- ===== 01/10/2026 (quinta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-01 10:00:00');
INSERT INTO cliente (id_cliente, nm_cliente, nr_cpf, dt_nascimento, nr_telefone, vl_limite_fiado, dt_consentimento_lgpd, dt_cadastro) VALUES (12, 'Mônica Cavalcante Lopes', '91000000012', '1994-07-02', '(11) 99000-0012', '0.00', '2026-10-01 10:00:00', '2026-10-01 10:00:00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-01 10:05:00');
CALL sp_autorizar_cliente_fiado(12, 100.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-01 12:44:10');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-01 12:45:11');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-01 12:53:00');
SET @id_funcionario_logado = 4;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (60, 4, '2026-10-01 12:53:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-01 11:30:00');
SET @id_funcionario_logado = 1;
UPDATE produto SET vl_venda = 7.50 WHERE id_produto = 4;
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'UPDATE', 'produto', '4', '{"coluna": "vl_venda", "antes": "7.00", "depois": "7.50"}', '192.168.0.11');
UPDATE produto SET vl_venda = 10.00 WHERE id_produto = 5;
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'UPDATE', 'produto', '5', '{"coluna": "vl_venda", "antes": "9.50", "depois": "10.00"}', '192.168.0.11');
UPDATE produto SET vl_venda = 95.00 WHERE id_produto = 23;
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'UPDATE', 'produto', '23', '{"coluna": "vl_venda", "antes": "89.00", "depois": "95.00"}', '192.168.0.11');
UPDATE produto SET vl_venda = 24.00 WHERE id_produto = 35;
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'UPDATE', 'produto', '35', '{"coluna": "vl_venda", "antes": "13.00", "depois": "24.00"}', '192.168.0.11');
UPDATE produto SET vl_venda = 13.00 WHERE id_produto = 46;
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'UPDATE', 'produto', '46', '{"coluna": "vl_venda", "antes": "6.00", "depois": "13.00"}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-01 10:25:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (57, 4, 1, '2026-10-01 10:25:00', 'ENTREGA', '132.60', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (236, 57, 39, 9, 0, '4.60', 0),
  (237, 57, 40, 5, 0, '5.40', 0),
  (238, 57, 44, 10, 0, '1.80', 0),
  (239, 57, 46, 10, 0, '3.90', 0),
  (240, 57, 54, 6, 0, '1.20', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-01 14:30:00');
SET @id_funcionario_logado = 4;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-01 14:30:00', nr_nota_fiscal = '792798' WHERE id_compra = 56;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 234;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 235;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (195, 234, 'L2610012495', '2028-04-16', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (24, 4, 195, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 56');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (28, 4, NULL, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 56');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-01 15:27:59');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (418, 4, 60, '2026-10-01 15:27:59', '0.00', '27.00', 'CONCLUIDA', '840652', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (773, 418, 43, 114, NULL, 'UNIDADE', 1, '5.00'),
  (774, 418, 12, 178, NULL, 'UNIDADE', 1, '4.50'),
  (775, 418, 12, 167, NULL, 'UNIDADE', 1, '4.50'),
  (776, 418, 41, 153, NULL, 'UNIDADE', 2, '6.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (418, 'PIX', 27.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-01 16:49:44');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (419, 4, 60, '2026-10-01 16:49:44', '0.00', '57.00', 'CONCLUIDA', '532963', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (777, 419, 45, 38, NULL, 'UNIDADE', 2, '1.00'),
  (778, 419, 37, NULL, NULL, 'UNIDADE', 1, '25.00'),
  (779, 419, 1, 181, NULL, 'UNIDADE', 6, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (419, 'DEBITO', 57.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-01 17:18:00');
SET @id_funcionario_logado = 3;
CALL sp_registrar_evento_acesso(3, 'CONSULTA_DADO_PESSOAL', 'cliente', '11', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-01 17:20:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (27, 25, 60, 'DINHEIRO', '27.50');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-01 17:41:22');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (420, 4, 60, '2026-10-01 17:41:22', '0.00', '7.00', 'CONCLUIDA', '780142', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (780, 420, 16, 168, NULL, 'UNIDADE', 1, '3.50'),
  (781, 420, 16, 20, NULL, 'UNIDADE', 1, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (420, 'DINHEIRO', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-01 17:44:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (44, 60, 4, 'DESPESA', '20.00', 'Material de limpeza');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-01 21:43:31');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (421, 4, 60, '2026-10-01 21:43:31', '0.00', '4.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (782, 421, 14, 101, NULL, 'UNIDADE', 1, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (421, 'DINHEIRO', 4.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-01 22:12:49');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (422, 4, 60, '2026-10-01 22:12:49', '0.00', '1.50', 'CONCLUIDA', '737143', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (783, 422, 47, 135, NULL, 'UNIDADE', 1, '1.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (422, 'PIX', 1.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-01 22:47:51');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (423, 4, 60, '2026-10-01 22:47:51', '0.00', '21.00', 'CONCLUIDA', '805424', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (784, 423, 40, 92, NULL, 'UNIDADE', 1, '8.00'),
  (785, 423, 46, 134, NULL, 'UNIDADE', 1, '13.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (423, 'DINHEIRO', 10.50),
  (423, 'DEBITO', 10.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-01 23:05:00');
CALL sp_fechar_caixa(60, 177.50);
UPDATE caixa SET ds_observacao = 'Faltou R$ 2.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 60;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-01 23:07:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '60', '{"diferenca": "-2.00"}', '192.168.0.11');

-- ===== 02/10/2026 (sexta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-02 12:48:41');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-02 12:45:09');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-02 12:42:24');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-02 12:56:00');
SET @id_funcionario_logado = 2;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (61, 2, '2026-10-02 12:56:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-02 10:04:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (58, 1, 1, '2026-10-02 10:04:00', 'ENTREGA', '45.50', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (241, 58, 9, 3, 0, '12.50', 0),
  (242, 58, 16, 4, 0, '2.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-02 13:10:52');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (424, 1, 61, '2026-10-02 13:10:52', '0.00', '12.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (786, 424, 34, NULL, NULL, 'UNIDADE', 1, '12.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (424, 'PIX', 12.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-02 14:30:00');
SET @id_funcionario_logado = 3;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-02 14:30:00', nr_nota_fiscal = '182375' WHERE id_compra = 57;
UPDATE item_compra SET qt_recebida = 9, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 236;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 237;
UPDATE item_compra SET qt_recebida = 10, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 238;
UPDATE item_compra SET qt_recebida = 10, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 239;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 240;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (196, 236, 'L2610023996', '2026-12-03', 0),
  (197, 237, 'L2610024097', '2026-12-06', 0),
  (198, 238, 'L2610024498', '2027-06-09', 0),
  (199, 238, 'L2610024499', '2027-07-08', 0),
  (200, 239, 'L2610024600', '2027-02-03', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (39, 3, 196, 'ENTRADA_COMPRA', 9, 'Recebimento da compra 57');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (40, 3, 197, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 57');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (44, 3, 198, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 57');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (44, 3, 199, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 57');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (46, 3, 200, 'ENTRADA_COMPRA', 10, 'Recebimento da compra 57');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (54, 3, NULL, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 57');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-02 15:05:13');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (425, 2, 61, '2026-10-02 15:05:13', '0.00', '3.00', 'CONCLUIDA', '799269', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (787, 425, 47, 135, NULL, 'UNIDADE', 2, '1.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (425, 'CREDITO', 3.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-02 16:10:37');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (426, 3, 61, '2026-10-02 16:10:37', '0.00', '9.00', 'CONCLUIDA', '783711', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (788, 426, 56, NULL, NULL, 'UNIDADE', 1, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (426, 'PIX', 9.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-02 16:21:20');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (427, 1, 61, '2026-10-02 16:21:20', '0.00', '6.00', 'CONCLUIDA', '526814', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (789, 427, 42, 113, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (427, 'DINHEIRO', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-02 16:50:00');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (15, 1, 84, 'PERDA', 1, 'Garrafa quebrada na prateleira');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (15, 1, 151, 'PERDA', 1, 'Garrafa quebrada na prateleira');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-02 16:51:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '1075', '{"tipo": "PERDA", "motivo": "Garrafa quebrada na prateleira", "quantidade": 2}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-02 18:23:42');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (428, 3, 61, '2026-10-02 18:23:42', '0.00', '82.00', 'CONCLUIDA', '938570', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (790, 428, 8, 140, NULL, 'UNIDADE', 2, '7.00'),
  (791, 428, 8, 175, NULL, 'UNIDADE', 4, '7.00'),
  (792, 428, 5, 164, NULL, 'UNIDADE', 4, '10.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (428, 'DINHEIRO', 82.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-02 18:26:00');
SET @id_funcionario_logado = 2;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (45, 61, 2, 'DESPESA', '35.00', 'Material de limpeza');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-02 18:58:29');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (429, 2, 61, '2026-10-02 18:58:29', '0.00', '15.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (793, 429, 54, NULL, NULL, 'UNIDADE', 1, '2.50'),
  (794, 429, 15, 151, NULL, 'UNIDADE', 1, '3.00'),
  (795, 429, 7, 108, NULL, 'UNIDADE', 1, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (429, 'CREDITO', 9.00),
  (429, 'DEBITO', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-02 19:14:21');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (430, 2, 61, '2026-10-02 19:14:21', '0.00', '13.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (796, 430, 15, 151, NULL, 'UNIDADE', 3, '3.00'),
  (797, 430, 47, 173, NULL, 'UNIDADE', 3, '1.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (430, 'DINHEIRO', 6.70),
  (430, 'CREDITO', 6.80);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-02 20:15:21');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (431, 3, 61, '2026-10-02 20:15:21', '0.00', '60.00', 'CONCLUIDA', '246085', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (798, 431, 1, 181, NULL, 'UNIDADE', 1, '5.00'),
  (799, 431, 31, NULL, NULL, 'UNIDADE', 1, '55.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (431, 'PIX', 60.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-02 20:55:01');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (432, 3, 61, '2026-10-02 20:55:01', '0.00', '18.00', 'CONCLUIDA', '156307', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (800, 432, 19, 160, NULL, 'UNIDADE', 2, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (432, 'PIX', 18.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-02 22:58:07');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (433, 3, 61, '2026-10-02 22:58:07', '0.00', '28.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (801, 433, 35, NULL, NULL, 'UNIDADE', 1, '24.00'),
  (802, 433, 48, 43, NULL, 'UNIDADE', 1, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (433, 'PIX', 28.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 00:08:00');
SET @id_funcionario_logado = 2;
CALL sp_fechar_caixa(61, 156.70);
UPDATE caixa SET ds_observacao = 'Faltou R$ 3.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 61;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 00:10:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '61', '{"diferenca": "-3.00"}', '192.168.0.11');

-- ===== 03/10/2026 (sábado) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 12:44:59');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 12:47:15');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 12:45:01');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 12:52:00');
SET @id_funcionario_logado = 1;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (62, 1, '2026-10-03 12:52:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 13:20:00');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (59, 1, 111, 'PERDA', 5, 'Lote vencido em 02/10/2026');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 13:21:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '1089', '{"tipo": "PERDA", "motivo": "vencimento", "lote": 111, "quantidade": 5}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 14:11:22');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (434, 3, 62, '2026-10-03 14:11:22', '0.00', '9.00', 'CONCLUIDA', '432864', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (803, 434, 14, 101, NULL, 'UNIDADE', 1, '4.50'),
  (804, 434, 14, 159, NULL, 'UNIDADE', 1, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (434, 'CREDITO', 9.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 14:30:00');
SET @id_funcionario_logado = 1;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-03 14:30:00', nr_nota_fiscal = '716873' WHERE id_compra = 58;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 241;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 242;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (201, 241, 'L2610030901', '2027-03-20', 0),
  (202, 242, 'L2610031602', '2027-06-16', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (9, 1, 201, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 58');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (16, 1, 202, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 58');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 14:38:17');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (435, 3, 62, '2026-10-03 14:38:17', '0.00', '45.00', 'CONCLUIDA', '744639', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (805, 435, 29, NULL, NULL, 'UNIDADE', 1, '45.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (435, 'CREDITO', 45.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 15:07:45');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (436, 4, 62, '2026-10-03 15:07:45', '0.00', '41.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (806, 436, 37, NULL, NULL, 'UNIDADE', 1, '25.00'),
  (807, 436, 46, 200, NULL, 'UNIDADE', 1, '13.00'),
  (808, 436, 16, 202, NULL, 'UNIDADE', 1, '3.50');
CALL sp_registrar_venda_fiado(436, 8, '2026-11-02', 41.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 15:52:49');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (437, 4, 62, '2026-10-03 15:52:49', '2.00', '30.00', 'CONCLUIDA', '227148', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (809, 437, 40, 92, NULL, 'UNIDADE', 2, '8.00'),
  (810, 437, 15, 151, NULL, 'UNIDADE', 1, '3.00'),
  (811, 437, 46, 200, NULL, 'UNIDADE', 1, '13.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (437, 'PIX', 30.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 15:58:08');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (438, 3, 62, '2026-10-03 15:58:08', '0.00', '12.00', 'CONCLUIDA', '460370', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (812, 438, 55, NULL, NULL, 'UNIDADE', 2, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (438, 'DINHEIRO', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 16:44:00');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (46, 1, 200, 'PERDA', 2, 'Garrafa quebrada na prateleira');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 16:45:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '1102', '{"tipo": "PERDA", "motivo": "Garrafa quebrada na prateleira", "quantidade": 2}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 16:51:36');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (439, 4, 62, '2026-10-03 16:51:36', '0.00', '25.00', 'CONCLUIDA', '253701', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (813, 439, 34, NULL, NULL, 'UNIDADE', 2, '12.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (439, 'PIX', 25.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 16:54:45');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (440, 1, 62, '2026-10-03 16:54:45', '0.00', '98.50', 'CONCLUIDA', '868602', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (814, 440, 22, NULL, 1, 'DOSE', 1, '7.00'),
  (815, 440, 14, 159, NULL, 'UNIDADE', 1, '4.50'),
  (816, 440, 47, 173, NULL, 'UNIDADE', 2, '1.50'),
  (817, 440, 40, 92, NULL, 'UNIDADE', 1, '8.00'),
  (818, 440, 40, 128, NULL, 'UNIDADE', 2, '8.00'),
  (819, 440, 1, 181, NULL, 'UNIDADE', 12, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (440, 'CREDITO', 98.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 19:59:06');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (441, 4, 62, '2026-10-03 19:59:06', '0.00', '9.50', 'CONCLUIDA', '519253', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (820, 441, 13, 194, NULL, 'UNIDADE', 1, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (441, 'CREDITO', 9.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 20:08:06');
SET @id_funcionario_logado = 1;
UPDATE venda SET st_venda = 'CANCELADA' WHERE id_venda = 441;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (13, 1, 194, 'AJUSTE_ENTRADA', 1, 'Cancelamento da venda 441: produto devolvido ao estoque');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'venda', '441', '{"acao": "cancelamento", "total": "9.50"}', '192.168.0.11');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'UPDATE', 'venda', '441', '{"coluna": "st_venda", "antes": "CONCLUIDA", "depois": "CANCELADA"}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 20:02:01');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (442, 1, 62, '2026-10-03 20:02:01', '0.00', '13.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (821, 442, 12, 167, NULL, 'UNIDADE', 1, '4.50'),
  (822, 442, 12, 100, NULL, 'UNIDADE', 2, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (442, 'CREDITO', 6.70),
  (442, 'DINHEIRO', 6.80);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 20:28:58');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (443, 1, 62, '2026-10-03 20:28:58', '0.00', '13.00', 'CONCLUIDA', '668766', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (823, 443, 49, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (824, 443, 45, 38, NULL, 'UNIDADE', 1, '1.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (443, 'DINHEIRO', 13.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 21:00:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (46, 62, 1, 'SANGRIA', '150.00', 'Sangria: retirada do excesso de dinheiro do caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 22:16:46');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (444, 4, 62, '2026-10-03 22:16:46', '0.00', '45.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (825, 444, 29, NULL, NULL, 'UNIDADE', 1, '45.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (444, 'PIX', 45.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 22:47:20');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (445, 1, 62, '2026-10-03 22:47:20', '0.00', '10.00', 'CONCLUIDA', '329341', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (826, 445, 44, 66, NULL, 'UNIDADE', 1, '3.00'),
  (827, 445, 16, 202, NULL, 'UNIDADE', 2, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (445, 'CREDITO', 10.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-03 23:15:48');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (446, 4, 62, '2026-10-03 23:15:48', '0.00', '6.00', 'CONCLUIDA', '224387', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (828, 446, 42, 94, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (446, 'PIX', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-04 00:08:00');
SET @id_funcionario_logado = 1;
CALL sp_fechar_caixa(62, 28.80);
UPDATE caixa SET ds_observacao = 'Faltou R$ 3.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 62;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-04 00:10:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '62', '{"diferenca": "-3.00"}', '192.168.0.11');

-- ===== 04/10/2026 (domingo) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-04 12:41:32');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-04 12:42:05');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-04 12:55:00');
SET @id_funcionario_logado = 2;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (63, 2, '2026-10-04 12:55:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-04 14:45:40');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (447, 2, 63, '2026-10-04 14:45:40', '0.00', '30.00', 'CONCLUIDA', '529815', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (829, 447, 1, 79, NULL, 'UNIDADE', 6, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (447, 'PIX', 30.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-04 15:00:48');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (448, 4, 63, '2026-10-04 15:00:48', '0.00', '53.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (830, 448, 22, NULL, 1, 'DOSE', 3, '7.00'),
  (831, 448, 28, NULL, NULL, 'UNIDADE', 1, '32.00');
CALL sp_registrar_venda_fiado(448, 5, '2026-11-03', 53.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-04 15:20:34');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (449, 2, 63, '2026-10-04 15:20:34', '0.00', '72.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (832, 449, 6, 139, NULL, 'UNIDADE', 6, '11.00'),
  (833, 449, 55, NULL, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (449, 'PIX', 28.80),
  (449, 'CREDITO', 43.20);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-04 15:51:33');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (450, 4, 63, '2026-10-04 15:51:33', '0.00', '7.00', 'CONCLUIDA', '736440', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (834, 450, 16, 202, NULL, 'UNIDADE', 1, '3.50'),
  (835, 450, 16, 125, NULL, 'UNIDADE', 1, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (450, 'DEBITO', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-04 16:07:34');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (451, 4, 63, '2026-10-04 16:07:34', '0.00', '10.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (836, 451, 3, 185, NULL, 'UNIDADE', 2, '3.50'),
  (837, 451, 3, 98, NULL, 'UNIDADE', 1, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (451, 'PIX', 10.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-04 16:13:00');
SET @id_funcionario_logado = 2;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (47, 63, 2, 'DESPESA', '15.00', 'Sacolas e embalagens');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-04 18:49:29');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (452, 2, 63, '2026-10-04 18:49:29', '0.00', '7.00', 'CONCLUIDA', '232076', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (838, 452, 8, 175, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (452, 'DINHEIRO', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-04 20:27:10');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (453, 4, 63, '2026-10-04 20:27:10', '0.00', '12.00', 'CONCLUIDA', '720747', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (839, 453, 33, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (453, 'CREDITO', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-04 21:43:10');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (454, 4, 63, '2026-10-04 21:43:10', '0.00', '15.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (840, 454, 48, 117, NULL, 'UNIDADE', 3, '4.00'),
  (841, 454, 16, 125, NULL, 'UNIDADE', 1, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (454, 'DINHEIRO', 9.30),
  (454, 'DEBITO', 6.20);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-04 22:00:54');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (455, 4, 63, '2026-10-04 22:00:54', '0.00', '5.50', 'CONCLUIDA', '718960', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (842, 455, 10, 191, NULL, 'UNIDADE', 1, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (455, 'CREDITO', 5.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-05 00:08:00');
SET @id_funcionario_logado = 2;
CALL sp_fechar_caixa(63, 201.30);

-- ===== 05/10/2026 (segunda) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-05 12:44:46');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-05 12:40:28');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-05 12:52:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (64, 2, '2026-10-05 12:52:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-05 11:45:00');
SET @id_funcionario_logado = 1;
CALL sp_autorizar_cliente_fiado(5, 350.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-05 10:10:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (59, 3, 1, '2026-10-05 10:10:00', 'RETIRADA', '131.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (243, 59, 34, 5, 0, '11.90', 0),
  (244, 59, 35, 2, 0, '11.00', 0),
  (245, 59, 37, 3, 0, '16.50', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-05 10:09:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (60, 5, 1, '2026-10-05 10:09:00', 'RETIRADA', '38.40', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (246, 60, 55, 3, 0, '4.00', 0),
  (247, 60, 59, 6, 0, '4.40', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-05 16:22:55');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (456, 2, 64, '2026-10-05 16:22:55', '0.00', '3.50', 'CONCLUIDA', '509090', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (843, 456, 16, 125, NULL, 'UNIDADE', 1, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (456, 'DEBITO', 3.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-05 16:27:35');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (457, 2, 64, '2026-10-05 16:27:35', '0.00', '32.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (844, 457, 28, NULL, NULL, 'UNIDADE', 1, '32.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (457, 'DEBITO', 19.20),
  (457, 'CREDITO', 12.80);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-05 17:00:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-05 17:00:00', nr_nota_fiscal = '100111' WHERE id_compra = 59;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 243;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 244;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 245;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (34, 2, NULL, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 59');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (35, 2, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 59');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (37, 2, NULL, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 59');
SET @id_funcionario_logado = 3;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-05 17:00:00', nr_nota_fiscal = '690796' WHERE id_compra = 60;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 246;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 247;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (203, 247, 'L2610055903', '2026-11-13', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (55, 3, NULL, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 60');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (59, 3, 203, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 60');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-05 17:43:13');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (458, 3, 64, '2026-10-05 17:43:13', '0.00', '45.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (845, 458, 29, NULL, NULL, 'UNIDADE', 1, '45.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (458, 'DINHEIRO', 45.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-05 18:52:12');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (459, 2, 64, '2026-10-05 18:52:12', '0.00', '27.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (846, 459, 49, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (847, 459, 1, 146, NULL, 'UNIDADE', 2, '5.00'),
  (848, 459, 10, 191, NULL, 'UNIDADE', 1, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (459, 'DINHEIRO', 27.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-05 18:54:36');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (460, 3, 64, '2026-10-05 18:54:36', '0.00', '24.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (849, 460, 33, NULL, NULL, 'UNIDADE', 2, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (460, 'PIX', 24.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-05 18:57:00');
SET @id_funcionario_logado = 2;
CALL sp_registrar_evento_acesso(2, 'CONSULTA_DADO_PESSOAL', 'cliente', '5', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-05 18:59:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (28, 27, 64, 'CREDITO', '21.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-05 19:51:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (48, 64, 2, 'DESPESA', '20.00', 'Compra de gelo para o balcão');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-05 23:05:00');
CALL sp_fechar_caixa(64, 252.50);

-- ===== 06/10/2026 (terça) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-06 12:40:02');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-06 12:41:57');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-06 12:52:00');
SET @id_funcionario_logado = 1;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (65, 1, '2026-10-06 12:52:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-06 10:35:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (61, 1, 1, '2026-10-06 10:35:00', 'ENTREGA', '215.40', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (248, 61, 1, 28, 0, '3.10', 0),
  (249, 61, 8, 11, 0, '5.00', 0),
  (250, 61, 12, 7, 0, '3.10', 0),
  (251, 61, 14, 5, 0, '3.10', 0),
  (252, 61, 15, 14, 0, '1.60', 0),
  (253, 61, 16, 7, 0, '2.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-06 13:20:00');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 1, 172, 'PERDA', 4, 'Lote vencido em 03/10/2026');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-06 13:21:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '1144', '{"tipo": "PERDA", "motivo": "vencimento", "lote": 172, "quantidade": 4}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-06 18:10:09');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (461, 1, 65, '2026-10-06 18:10:09', '0.00', '32.00', 'CONCLUIDA', '478366', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (850, 461, 18, 22, NULL, 'UNIDADE', 2, '4.00'),
  (851, 461, 6, 139, NULL, 'UNIDADE', 1, '11.00'),
  (852, 461, 41, 153, NULL, 'UNIDADE', 1, '6.50'),
  (853, 461, 41, 93, NULL, 'UNIDADE', 1, '6.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (461, 'CREDITO', 19.20),
  (461, 'DEBITO', 12.80);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-06 18:40:00');
CALL sp_registrar_evento_acesso(1, 'CONSULTA_DADO_PESSOAL', 'cliente', '8', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-06 18:42:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (29, 28, 65, 'PIX', '41.50');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-06 20:19:47');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (462, 2, 65, '2026-10-06 20:19:47', '0.00', '24.00', 'CONCLUIDA', '625542', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (854, 462, 2, 156, NULL, 'UNIDADE', 4, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (462, 'DINHEIRO', 24.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-06 21:19:39');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (463, 1, 65, '2026-10-06 21:19:39', '0.00', '7.00', 'CONCLUIDA', '742845', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (855, 463, 20, 104, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (463, 'DINHEIRO', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-06 22:53:48');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (464, 1, 65, '2026-10-06 22:53:48', '3.00', '41.00', 'CONCLUIDA', '785408', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (856, 464, 52, NULL, NULL, 'UNIDADE', 2, '22.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (464, 'DINHEIRO', 41.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-06 23:05:00');
CALL sp_fechar_caixa(65, 272.00);

-- ===== 07/10/2026 (quarta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-07 12:45:34');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-07 12:40:24');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-07 12:59:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (66, 1, '2026-10-07 12:59:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-07 10:30:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (62, 2, 1, '2026-10-07 10:30:00', 'ENTREGA', '238.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (254, 62, 28, 2, 0, '21.00', 0),
  (255, 62, 29, 4, 0, '30.00', 0),
  (256, 62, 31, 2, 0, '38.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-07 14:30:00');
SET @id_funcionario_logado = 4;
UPDATE compra SET st_compra = 'RECEBIDA_PARCIAL', dt_recebimento = '2026-10-07 14:30:00', nr_nota_fiscal = '626830' WHERE id_compra = 61;
UPDATE item_compra SET qt_recebida = 28, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 248;
UPDATE item_compra SET qt_recebida = 11, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 249;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 250;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = '1 unidades avariadas, devolvidas ao fornecedor' WHERE id_item_compra = 251;
UPDATE item_compra SET qt_recebida = 14, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 252;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = 'Produto trocado pelo fornecedor: 1 unidades não entregues' WHERE id_item_compra = 253;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (204, 248, 'L2610070104', '2027-04-09', 0),
  (205, 248, 'L2610070105', '2027-05-17', 0),
  (206, 249, 'L2610070806', '2027-04-18', 0),
  (207, 249, 'L2610070807', '2027-05-09', 0),
  (208, 250, 'L2610071208', '2027-02-17', 0),
  (209, 251, 'L2610071409', '2027-03-13', 0),
  (210, 252, 'L2610071510', '2027-04-21', 0),
  (211, 252, 'L2610071511', '2027-05-22', 0),
  (212, 253, 'L2610071612', '2027-07-31', 0),
  (213, 253, 'L2610071613', '2027-08-25', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (1, 4, 204, 'ENTRADA_COMPRA', 14, 'Recebimento da compra 61');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (1, 4, 205, 'ENTRADA_COMPRA', 14, 'Recebimento da compra 61');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (8, 4, 206, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 61');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (8, 4, 207, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 61');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (12, 4, 208, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 61');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (14, 4, 209, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 61');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (15, 4, 210, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 61');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (15, 4, 211, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 61');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (16, 4, 212, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 61');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (16, 4, 213, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 61');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-07 14:44:30');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (465, 1, 66, '2026-10-07 14:44:30', '0.00', '9.00', 'CONCLUIDA', '128844', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (857, 465, 17, 169, NULL, 'UNIDADE', 1, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (465, 'PIX', 9.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-07 15:42:35');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (466, 4, 66, '2026-10-07 15:42:35', '0.00', '3.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (858, 466, 15, 210, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (466, 'DINHEIRO', 3.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-07 16:10:00');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 1, 180, 'PERDA', 1, 'Garrafa quebrada na prateleira');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-07 16:11:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '1164', '{"tipo": "PERDA", "motivo": "Garrafa quebrada na prateleira", "quantidade": 1}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-07 19:39:11');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (467, 1, 66, '2026-10-07 19:39:11', '0.00', '15.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (859, 467, 10, 191, NULL, 'UNIDADE', 1, '5.50'),
  (860, 467, 7, 108, NULL, 'UNIDADE', 1, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (467, 'PIX', 15.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-07 20:52:27');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (468, 1, 66, '2026-10-07 20:52:27', '0.00', '107.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (861, 468, 37, NULL, NULL, 'UNIDADE', 2, '25.00'),
  (862, 468, 13, 194, NULL, 'UNIDADE', 1, '9.50'),
  (863, 468, 3, 137, NULL, 'UNIDADE', 2, '3.50'),
  (864, 468, 19, 160, NULL, 'UNIDADE', 1, '9.00'),
  (865, 468, 28, NULL, NULL, 'UNIDADE', 1, '32.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (468, 'PIX', 91.00);
CALL sp_registrar_venda_fiado(468, 3, '2026-11-06', 16.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-07 21:14:31');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (469, 1, 66, '2026-10-07 21:14:31', '0.00', '169.00', 'CONCLUIDA', '208097', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (866, 469, 25, 29, NULL, 'UNIDADE', 1, '62.00'),
  (867, 469, 49, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (868, 469, 10, 166, NULL, 'UNIDADE', 2, '5.50'),
  (869, 469, 2, 156, NULL, 'UNIDADE', 6, '6.00'),
  (870, 469, 35, NULL, NULL, 'UNIDADE', 2, '24.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (469, 'PIX', 169.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-07 22:00:16');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (470, 1, 66, '2026-10-07 22:00:16', '0.00', '21.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (871, 470, 50, NULL, NULL, 'UNIDADE', 2, '4.00'),
  (872, 470, 14, 159, NULL, 'UNIDADE', 1, '4.50'),
  (873, 470, 14, 77, NULL, 'UNIDADE', 1, '4.50'),
  (874, 470, 18, 102, NULL, 'UNIDADE', 1, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (470, 'PIX', 21.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-07 23:05:00');
CALL sp_fechar_caixa(66, 203.00);

-- ===== 08/10/2026 (quinta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-08 12:41:48');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-08 12:42:02');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-08 16:52:00');
CALL sp_registrar_evento_acesso(4, 'LOGIN_FALHA', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-08 12:59:00');
SET @id_funcionario_logado = 3;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (67, 3, '2026-10-08 12:59:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-08 10:28:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (63, 4, 1, '2026-10-08 10:28:00', 'ENTREGA', '127.30', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (257, 63, 40, 6, 0, '5.40', 0),
  (258, 63, 41, 7, 0, '4.20', 0),
  (259, 63, 42, 5, 0, '4.00', 0),
  (260, 63, 45, 6, 0, '0.50', 0),
  (261, 63, 46, 5, 0, '3.90', 0),
  (262, 63, 47, 10, 0, '0.80', 0),
  (263, 63, 48, 6, 0, '2.50', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-08 10:01:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (64, 5, 1, '2026-10-08 10:01:00', 'RETIRADA', '96.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (264, 64, 49, 6, 0, '6.50', 0),
  (265, 64, 52, 2, 0, '14.00', 0),
  (266, 64, 60, 5, 0, '5.80', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-08 14:30:00');
SET @id_funcionario_logado = 3;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-08 14:30:00', nr_nota_fiscal = '738204' WHERE id_compra = 62;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 254;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 255;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 256;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (28, 3, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 62');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (29, 3, NULL, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 62');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (31, 3, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 62');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-08 15:10:00');
CALL sp_registrar_evento_acesso(3, 'CONSULTA_DADO_PESSOAL', 'cliente', '6', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-08 15:12:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (30, 3, 67, 'PIX', '37.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-08 17:00:00');
UPDATE compra SET st_compra = 'RECEBIDA_PARCIAL', dt_recebimento = '2026-10-08 17:00:00', nr_nota_fiscal = '387000' WHERE id_compra = 64;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = 'Produto trocado pelo fornecedor: 1 unidades não entregues' WHERE id_item_compra = 264;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 265;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 266;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (214, 266, 'L2610086014', '2026-10-16', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (49, 3, NULL, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 64');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (52, 3, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 64');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 3, 214, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 64');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (8, 1, 206, 'DEVOLUCAO_FORNECEDOR', 2, 'Devolvido ao fornecedor: latas amassadas no lote');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-08 17:07:21');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (471, 3, 67, '2026-10-08 17:07:21', '0.00', '4.00', 'CONCLUIDA', '509751', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (875, 471, 50, NULL, NULL, 'UNIDADE', 1, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (471, 'PIX', 4.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-08 18:01:05');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (472, 4, 67, '2026-10-08 18:01:05', '0.00', '4.50', 'CONCLUIDA', '575856', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (876, 472, 12, 208, NULL, 'UNIDADE', 1, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (472, 'DINHEIRO', 4.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-08 18:03:45');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (473, 3, 67, '2026-10-08 18:03:45', '0.00', '2.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (877, 473, 54, NULL, NULL, 'UNIDADE', 1, '2.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (473, 'DEBITO', 2.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-08 18:10:32');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (474, 3, 67, '2026-10-08 18:10:32', '0.00', '25.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (878, 474, 34, NULL, NULL, 'UNIDADE', 2, '12.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (474, 'PIX', 25.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-08 20:42:04');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (475, 4, 67, '2026-10-08 20:42:04', '0.00', '7.00', 'CONCLUIDA', '681312', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (879, 475, 22, NULL, 1, 'DOSE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (475, 'CREDITO', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-08 22:41:01');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (476, 3, 67, '2026-10-08 22:41:01', '0.00', '47.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (880, 476, 37, NULL, NULL, 'UNIDADE', 1, '25.00'),
  (881, 476, 52, NULL, NULL, 'UNIDADE', 1, '22.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (476, 'DINHEIRO', 22.00);
CALL sp_registrar_venda_fiado(476, 7, '2026-11-07', 25.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-08 23:05:00');
CALL sp_fechar_caixa(67, 171.50);
UPDATE caixa SET ds_observacao = 'Faltou R$ 5.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 67;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-08 23:07:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '67', '{"diferenca": "-5.00"}', '192.168.0.11');

-- ===== 09/10/2026 (sexta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-09 12:45:24');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-09 12:42:07');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-09 12:43:21');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-09 12:50:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (68, 3, '2026-10-09 12:50:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-09 10:39:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (65, 1, 1, '2026-10-09 10:39:00', 'ENTREGA', '87.70', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (267, 65, 3, 9, 0, '2.40', 0),
  (268, 65, 10, 10, 0, '3.40', 0),
  (269, 65, 14, 3, 0, '3.10', 0),
  (270, 65, 17, 2, 0, '6.20', 0),
  (271, 65, 18, 4, 0, '2.60', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-09 13:59:42');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (477, 3, 68, '2026-10-09 13:59:42', '0.00', '28.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (882, 477, 13, 194, NULL, 'UNIDADE', 2, '9.50'),
  (883, 477, 15, 210, NULL, 'UNIDADE', 3, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (477, 'DINHEIRO', 28.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-09 14:30:00');
SET @id_funcionario_logado = 2;
UPDATE compra SET st_compra = 'RECEBIDA_PARCIAL', dt_recebimento = '2026-10-09 14:30:00', nr_nota_fiscal = '921514' WHERE id_compra = 63;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = 'Faltaram 1 unidades na entrega' WHERE id_item_compra = 257;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 258;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 259;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 260;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 261;
UPDATE item_compra SET qt_recebida = 10, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 262;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 263;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (215, 257, 'L2610094015', '2026-12-26', 0),
  (216, 258, 'L2610094116', '2027-03-06', 0),
  (217, 259, 'L2610094217', '2027-02-03', 0),
  (218, 260, 'L2610094518', '2027-06-13', 0),
  (219, 260, 'L2610094519', '2027-07-22', 0),
  (220, 261, 'L2610094620', '2027-04-01', 0),
  (221, 262, 'L2610094721', '2027-02-22', 0),
  (222, 263, 'L2610094822', '2027-02-10', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (40, 2, 215, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 63');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (41, 2, 216, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 63');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (42, 2, 217, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 63');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (45, 2, 218, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 63');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (45, 2, 219, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 63');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (46, 2, 220, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 63');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (47, 2, 221, 'ENTRADA_COMPRA', 10, 'Recebimento da compra 63');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (48, 2, 222, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 63');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-09 14:42:21');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (478, 2, 68, '2026-10-09 14:42:21', '0.00', '12.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (884, 478, 10, 166, NULL, 'UNIDADE', 1, '5.50'),
  (885, 478, 16, 125, NULL, 'UNIDADE', 2, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (478, 'PIX', 12.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-09 15:00:21');
SET @id_funcionario_logado = 1;
UPDATE venda SET st_venda = 'CANCELADA' WHERE id_venda = 478;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (10, 1, 166, 'AJUSTE_ENTRADA', 1, 'Cancelamento da venda 478: produto devolvido ao estoque');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (16, 1, 125, 'AJUSTE_ENTRADA', 2, 'Cancelamento da venda 478: produto devolvido ao estoque');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'venda', '478', '{"acao": "cancelamento", "total": "12.50"}', '192.168.0.11');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'UPDATE', 'venda', '478', '{"coluna": "st_venda", "antes": "CONCLUIDA", "depois": "CANCELADA"}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-09 17:02:08');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (479, 2, 68, '2026-10-09 17:02:08', '0.00', '18.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (886, 479, 56, NULL, NULL, 'UNIDADE', 1, '9.00'),
  (887, 479, 7, 108, NULL, 'UNIDADE', 1, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (479, 'CREDITO', 18.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-09 18:35:13');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (480, 1, 68, '2026-10-09 18:35:13', '0.00', '63.00', 'CONCLUIDA', '186032', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (888, 480, 31, NULL, NULL, 'UNIDADE', 1, '55.00'),
  (889, 480, 50, NULL, NULL, 'UNIDADE', 2, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (480, 'DINHEIRO', 63.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-09 19:49:35');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (481, 2, 68, '2026-10-09 19:49:35', '0.00', '5.00', 'CONCLUIDA', '397232', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (890, 481, 1, 204, NULL, 'UNIDADE', 1, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (481, 'PIX', 5.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-09 20:17:35');
SET @id_funcionario_logado = 1;
UPDATE venda SET st_venda = 'CANCELADA' WHERE id_venda = 481;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (1, 1, 204, 'AJUSTE_ENTRADA', 1, 'Cancelamento da venda 481: produto devolvido ao estoque');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'venda', '481', '{"acao": "cancelamento", "total": "5.00"}', '192.168.0.11');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'UPDATE', 'venda', '481', '{"coluna": "st_venda", "antes": "CONCLUIDA", "depois": "CANCELADA"}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-09 20:23:03');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (482, 2, 68, '2026-10-09 20:23:03', '0.00', '15.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (891, 482, 10, 166, NULL, 'UNIDADE', 1, '5.50'),
  (892, 482, 5, 164, NULL, 'UNIDADE', 1, '10.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (482, 'CREDITO', 15.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-09 21:00:00');
SET @id_funcionario_logado = 3;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (49, 68, 3, 'SANGRIA', '200.00', 'Sangria: retirada do excesso de dinheiro do caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-09 22:41:48');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (483, 1, 68, '2026-10-09 22:41:48', '0.00', '24.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (893, 483, 19, 161, NULL, 'UNIDADE', 1, '9.00'),
  (894, 483, 44, 66, NULL, 'UNIDADE', 1, '3.00'),
  (895, 483, 44, 198, NULL, 'UNIDADE', 4, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (483, 'DINHEIRO', 9.00);
CALL sp_registrar_venda_fiado(483, 11, '2026-11-08', 15.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-09 22:51:27');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (484, 1, 68, '2026-10-09 22:51:27', '0.00', '32.00', 'CONCLUIDA', '139693', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (896, 484, 28, NULL, NULL, 'UNIDADE', 1, '32.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (484, 'PIX', 32.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-09 22:58:27');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (485, 1, 68, '2026-10-09 22:58:27', '0.00', '26.00', 'CONCLUIDA', '574099', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (897, 485, 54, NULL, NULL, 'UNIDADE', 2, '2.50'),
  (898, 485, 22, NULL, 1, 'DOSE', 3, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (485, 'DEBITO', 26.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-09 23:54:24');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (486, 1, 68, '2026-10-09 23:54:24', '0.00', '7.00', 'CONCLUIDA', '892002', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (899, 486, 39, 152, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (486, 'PIX', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 00:08:00');
SET @id_funcionario_logado = 3;
CALL sp_fechar_caixa(68, 50.00);

-- ===== 10/10/2026 (sábado) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 12:45:57');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 12:44:31');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 12:40:00');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 14:49:00');
CALL sp_registrar_evento_acesso(3, 'LOGIN_FALHA', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 12:59:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (69, 3, '2026-10-10 12:59:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 13:20:00');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 1, 180, 'PERDA', 1, 'Lote vencido em 09/10/2026');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 13:21:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '1222', '{"tipo": "PERDA", "motivo": "vencimento", "lote": 180, "quantidade": 1}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 14:30:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-10 14:30:00', nr_nota_fiscal = '893288' WHERE id_compra = 65;
UPDATE item_compra SET qt_recebida = 9, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 267;
UPDATE item_compra SET qt_recebida = 10, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 268;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 269;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 270;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 271;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (223, 267, 'L2610100323', '2027-04-28', 0),
  (224, 268, 'L2610101024', '2027-03-30', 0),
  (225, 269, 'L2610101425', '2027-03-12', 0),
  (226, 270, 'L2610101726', '2026-12-15', 0),
  (227, 271, 'L2610101827', '2027-03-15', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (3, 1, 223, 'ENTRADA_COMPRA', 9, 'Recebimento da compra 65');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (10, 1, 224, 'ENTRADA_COMPRA', 10, 'Recebimento da compra 65');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (14, 1, 225, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 65');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (17, 1, 226, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 65');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (18, 1, 227, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 65');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 15:19:42');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (487, 4, 69, '2026-10-10 15:19:42', '0.00', '36.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (900, 487, 44, 198, NULL, 'UNIDADE', 1, '3.00'),
  (901, 487, 44, 199, NULL, 'UNIDADE', 1, '3.00'),
  (902, 487, 39, 152, NULL, 'UNIDADE', 1, '7.00'),
  (903, 487, 10, 166, NULL, 'UNIDADE', 1, '5.50'),
  (904, 487, 10, 118, NULL, 'UNIDADE', 1, '5.50'),
  (905, 487, 42, 94, NULL, 'UNIDADE', 2, '6.00');
CALL sp_registrar_venda_fiado(487, 7, '2026-11-09', 36.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 16:53:49');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (488, 4, 69, '2026-10-10 16:53:49', '0.00', '51.00', 'CONCLUIDA', '503637', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (906, 488, 35, NULL, NULL, 'UNIDADE', 2, '24.00'),
  (907, 488, 15, 210, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (488, 'CREDITO', 30.60),
  (488, 'PIX', 20.40);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 18:11:59');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (489, 4, 69, '2026-10-10 18:11:59', '0.00', '50.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (908, 489, 28, NULL, NULL, 'UNIDADE', 1, '32.00'),
  (909, 489, 19, 161, NULL, 'UNIDADE', 2, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (489, 'DEBITO', 50.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 19:47:59');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (490, 4, 69, '2026-10-10 19:47:59', '0.00', '32.50', 'CONCLUIDA', '786804', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (910, 490, 19, 161, NULL, 'UNIDADE', 1, '9.00'),
  (911, 490, 50, NULL, NULL, 'UNIDADE', 1, '4.00'),
  (912, 490, 12, 208, NULL, 'UNIDADE', 1, '4.50'),
  (913, 490, 4, 72, NULL, 'UNIDADE', 2, '7.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (490, 'CREDITO', 32.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 19:48:01');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (491, 1, 69, '2026-10-10 19:48:01', '0.00', '5.00', 'CONCLUIDA', '723264', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (914, 491, 1, 204, NULL, 'UNIDADE', 1, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (491, 'DEBITO', 5.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 19:53:58');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (492, 1, 69, '2026-10-10 19:53:58', '0.00', '31.00', 'CONCLUIDA', '983625', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (915, 492, 33, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (916, 492, 48, 70, NULL, 'UNIDADE', 1, '4.00'),
  (917, 492, 59, 203, NULL, 'UNIDADE', 1, '6.00'),
  (918, 492, 53, NULL, NULL, 'UNIDADE', 1, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (492, 'PIX', 18.60),
  (492, 'CREDITO', 12.40);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 19:58:45');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (493, 4, 69, '2026-10-10 19:58:45', '3.00', '54.00', 'CONCLUIDA', '372023', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (919, 493, 49, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (920, 493, 29, NULL, NULL, 'UNIDADE', 1, '45.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (493, 'DINHEIRO', 54.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 20:16:45');
SET @id_funcionario_logado = 1;
UPDATE venda SET st_venda = 'CANCELADA' WHERE id_venda = 493;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (49, 1, NULL, 'AJUSTE_ENTRADA', 1, 'Cancelamento da venda 493: produto devolvido ao estoque');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (29, 1, NULL, 'AJUSTE_ENTRADA', 1, 'Cancelamento da venda 493: produto devolvido ao estoque');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'venda', '493', '{"acao": "cancelamento", "total": "54.00"}', '192.168.0.11');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'UPDATE', 'venda', '493', '{"coluna": "st_venda", "antes": "CONCLUIDA", "depois": "CANCELADA"}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 20:18:10');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (494, 1, 69, '2026-10-10 20:18:10', '0.00', '6.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (921, 494, 38, NULL, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (494, 'PIX', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 20:34:32');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (495, 4, 69, '2026-10-10 20:34:32', '0.00', '52.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (922, 495, 4, 187, NULL, 'UNIDADE', 6, '7.50'),
  (923, 495, 22, NULL, 1, 'DOSE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (495, 'DINHEIRO', 52.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 21:00:00');
SET @id_funcionario_logado = 3;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (50, 69, 3, 'SANGRIA', '150.00', 'Sangria: retirada do excesso de dinheiro do caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 21:10:20');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (496, 1, 69, '2026-10-10 21:10:20', '0.00', '7.00', 'CONCLUIDA', '646092', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (924, 496, 3, 137, NULL, 'UNIDADE', 2, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (496, 'PIX', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 21:47:49');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (497, 3, 69, '2026-10-10 21:47:49', '0.00', '13.00', 'CONCLUIDA', '378900', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (925, 497, 46, 200, NULL, 'UNIDADE', 1, '13.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (497, 'CREDITO', 13.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 22:49:12');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (498, 3, 69, '2026-10-10 22:49:12', '0.00', '12.50', 'CONCLUIDA', '461996', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (926, 498, 16, 125, NULL, 'UNIDADE', 1, '3.50'),
  (927, 498, 17, 169, NULL, 'UNIDADE', 1, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (498, 'DINHEIRO', 5.00),
  (498, 'CREDITO', 7.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 23:06:38');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (499, 4, 69, '2026-10-10 23:06:38', '0.00', '3.50', 'CONCLUIDA', '368718', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (928, 499, 16, 125, NULL, 'UNIDADE', 1, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (499, 'DINHEIRO', 3.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-10 23:52:31');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (500, 4, 69, '2026-10-10 23:52:31', '0.00', '5.50', 'CONCLUIDA', '190499', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (929, 500, 10, 118, NULL, 'UNIDADE', 1, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (500, 'CREDITO', 5.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-11 00:08:00');
SET @id_funcionario_logado = 3;
CALL sp_fechar_caixa(69, 60.50);

-- ===== 11/10/2026 (domingo) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-11 12:49:58');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-11 12:40:06');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-11 12:50:00');
SET @id_funcionario_logado = 2;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (70, 2, '2026-10-11 12:50:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-11 14:22:56');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (501, 2, 70, '2026-10-11 14:22:56', '0.00', '22.50', 'CONCLUIDA', '103264', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (930, 501, 4, 187, NULL, 'UNIDADE', 3, '7.50');
CALL sp_registrar_venda_fiado(501, 8, '2026-11-10', 22.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-11 15:59:22');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (502, 4, 70, '2026-10-11 15:59:22', '0.00', '5.00', 'CONCLUIDA', '198618', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (931, 502, 54, NULL, NULL, 'UNIDADE', 2, '2.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (502, 'CREDITO', 5.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-11 16:27:00');
SET @id_funcionario_logado = 2;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (51, 70, 2, 'DESPESA', '15.00', 'Compra de gelo para o balcão');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-11 18:40:39');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (503, 2, 70, '2026-10-11 18:40:39', '0.00', '22.00', 'CONCLUIDA', '309686', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (932, 503, 42, 94, NULL, 'UNIDADE', 1, '6.00'),
  (933, 503, 40, 128, NULL, 'UNIDADE', 2, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (503, 'DINHEIRO', 22.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-11 19:23:45');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (504, 2, 70, '2026-10-11 19:23:45', '0.00', '19.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (934, 504, 39, 152, NULL, 'UNIDADE', 1, '7.00'),
  (935, 504, 33, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (504, 'DINHEIRO', 19.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-11 19:29:00');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (505, 4, 70, '2026-10-11 19:29:00', '0.00', '12.00', 'CONCLUIDA', '506057', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (936, 505, 44, 199, NULL, 'UNIDADE', 4, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (505, 'DEBITO', 6.00),
  (505, 'PIX', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-11 19:35:38');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (506, 2, 70, '2026-10-11 19:35:38', '0.00', '21.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (937, 506, 20, 104, NULL, 'UNIDADE', 1, '7.00'),
  (938, 506, 20, 170, NULL, 'UNIDADE', 2, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (506, 'PIX', 21.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-11 19:49:00');
CALL sp_registrar_evento_acesso(2, 'CONSULTA_DADO_PESSOAL', 'cliente', '6', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-11 19:51:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (31, 17, 70, 'DEBITO', '28.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-11 20:45:55');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (507, 2, 70, '2026-10-11 20:45:55', '0.00', '78.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (939, 507, 1, 204, NULL, 'UNIDADE', 1, '5.00'),
  (940, 507, 5, 164, NULL, 'UNIDADE', 1, '10.00'),
  (941, 507, 37, NULL, NULL, 'UNIDADE', 1, '25.00'),
  (942, 507, 19, 103, NULL, 'UNIDADE', 1, '9.00'),
  (943, 507, 19, 143, NULL, 'UNIDADE', 2, '9.00'),
  (944, 507, 11, 193, NULL, 'UNIDADE', 1, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (507, 'CREDITO', 78.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-11 23:18:51');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (508, 2, 70, '2026-10-11 23:18:51', '0.00', '22.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (945, 508, 11, 193, NULL, 'UNIDADE', 2, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (508, 'PIX', 22.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-11 23:28:45');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (509, 2, 70, '2026-10-11 23:28:45', '0.00', '9.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (946, 509, 7, 108, NULL, 'UNIDADE', 1, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (509, 'DEBITO', 9.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-11 23:42:43');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (510, 4, 70, '2026-10-11 23:42:43', '0.00', '11.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (947, 510, 16, 212, NULL, 'UNIDADE', 1, '3.50'),
  (948, 510, 18, 102, NULL, 'UNIDADE', 2, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (510, 'DINHEIRO', 11.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-12 00:08:00');
SET @id_funcionario_logado = 2;
CALL sp_fechar_caixa(70, 137.50);

-- ===== 12/10/2026 (segunda) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-12 12:45:45');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-12 12:48:56');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-12 12:59:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (71, 2, '2026-10-12 12:59:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-12 10:08:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (66, 3, 1, '2026-10-12 10:08:00', 'RETIRADA', '126.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (272, 66, 35, 4, 0, '11.00', 0),
  (273, 66, 37, 4, 0, '16.50', 0),
  (274, 66, 50, 8, 0, '2.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-12 10:06:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (67, 5, 1, '2026-10-12 10:06:00', 'RETIRADA', '13.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (275, 67, 56, 2, 0, '6.50', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-12 16:18:22');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (511, 2, 71, '2026-10-12 16:18:22', '0.00', '30.00', 'CONCLUIDA', '852709', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (949, 511, 1, 204, NULL, 'UNIDADE', 6, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (511, 'DINHEIRO', 30.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-12 17:00:00');
SET @id_funcionario_logado = 3;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-12 17:00:00', nr_nota_fiscal = '343714' WHERE id_compra = 66;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 272;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 273;
UPDATE item_compra SET qt_recebida = 8, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 274;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (35, 3, NULL, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 66');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (37, 3, NULL, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 66');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (50, 3, NULL, 'ENTRADA_COMPRA', 8, 'Recebimento da compra 66');
SET @id_funcionario_logado = 2;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-12 17:00:00', nr_nota_fiscal = '560045' WHERE id_compra = 67;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 275;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (56, 2, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 67');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-12 18:39:57');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (512, 2, 71, '2026-10-12 18:39:57', '0.00', '12.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (950, 512, 49, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (512, 'DINHEIRO', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-12 20:44:14');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (513, 2, 71, '2026-10-12 20:44:14', '0.00', '66.50', 'CONCLUIDA', '771032', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (951, 513, 15, 210, NULL, 'UNIDADE', 1, '3.00'),
  (952, 513, 36, NULL, NULL, 'UNIDADE', 2, '22.00'),
  (953, 513, 10, 118, NULL, 'UNIDADE', 2, '5.50'),
  (954, 513, 60, 214, NULL, 'UNIDADE', 1, '8.50');
CALL sp_registrar_venda_fiado(513, 7, '2026-11-11', 66.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-12 21:16:49');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (514, 3, 71, '2026-10-12 21:16:49', '0.00', '54.00', 'CONCLUIDA', '374900', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (955, 514, 49, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (956, 514, 4, 187, NULL, 'UNIDADE', 1, '7.50'),
  (957, 514, 4, 157, NULL, 'UNIDADE', 3, '7.50'),
  (958, 514, 38, NULL, NULL, 'UNIDADE', 2, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (514, 'DEBITO', 12.00);
CALL sp_registrar_venda_fiado(514, 8, '2026-11-11', 42.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-12 22:23:56');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (515, 3, 71, '2026-10-12 22:23:56', '0.00', '21.00', 'CONCLUIDA', '556322', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (959, 515, 1, 204, NULL, 'UNIDADE', 4, '5.00'),
  (960, 515, 45, 38, NULL, 'UNIDADE', 1, '1.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (515, 'DEBITO', 21.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-12 23:05:00');
SET @id_funcionario_logado = 2;
CALL sp_fechar_caixa(71, 191.00);
UPDATE caixa SET ds_observacao = 'Faltou R$ 1.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 71;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-12 23:07:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '71', '{"diferenca": "-1.00"}', '192.168.0.11');

-- ===== 13/10/2026 (terça) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-13 12:44:36');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-13 12:49:55');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-13 12:54:00');
SET @id_funcionario_logado = 1;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (72, 1, '2026-10-13 12:54:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-13 10:23:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (68, 1, 1, '2026-10-13 10:23:00', 'ENTREGA', '110.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (276, 68, 4, 16, 0, '4.90', 0),
  (277, 68, 16, 4, 0, '2.00', 0),
  (278, 68, 18, 2, 0, '2.60', 0),
  (279, 68, 20, 4, 0, '4.60', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-13 13:02:58');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (516, 2, 72, '2026-10-13 13:02:58', '0.00', '12.00', 'CONCLUIDA', '813691', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (961, 516, 49, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (516, 'DINHEIRO', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-13 16:50:00');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (52, 72, 1, 'DESPESA', '50.00', 'Sacolas e embalagens');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-13 17:06:40');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (517, 1, 72, '2026-10-13 17:06:40', '0.00', '25.00', 'CONCLUIDA', '512705', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (962, 517, 19, 143, NULL, 'UNIDADE', 1, '9.00'),
  (963, 517, 19, 144, NULL, 'UNIDADE', 1, '9.00'),
  (964, 517, 8, 206, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (517, 'DINHEIRO', 25.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-13 19:20:40');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (518, 2, 72, '2026-10-13 19:20:40', '0.00', '27.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (965, 518, 52, NULL, NULL, 'UNIDADE', 1, '22.00'),
  (966, 518, 1, 204, NULL, 'UNIDADE', 1, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (518, 'PIX', 27.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-13 20:42:21');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (519, 1, 72, '2026-10-13 20:42:21', '0.00', '38.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (967, 519, 11, 193, NULL, 'UNIDADE', 2, '11.00'),
  (968, 519, 49, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (969, 519, 48, 70, NULL, 'UNIDADE', 1, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (519, 'PIX', 38.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-13 21:35:32');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (520, 2, 72, '2026-10-13 21:35:32', '0.00', '33.00', 'CONCLUIDA', '889918', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (970, 520, 56, NULL, NULL, 'UNIDADE', 1, '9.00'),
  (971, 520, 33, NULL, NULL, 'UNIDADE', 2, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (520, 'DINHEIRO', 33.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-13 23:05:00');
SET @id_funcionario_logado = 1;
CALL sp_fechar_caixa(72, 120.00);

-- ===== 14/10/2026 (quarta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-14 12:42:04');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-14 12:45:56');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-14 12:58:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (73, 1, '2026-10-14 12:58:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-14 10:20:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (69, 2, 1, '2026-10-14 10:20:00', 'ENTREGA', '63.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (280, 69, 28, 3, 0, '21.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-14 14:30:00');
SET @id_funcionario_logado = 4;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-14 14:30:00', nr_nota_fiscal = '617374' WHERE id_compra = 68;
UPDATE item_compra SET qt_recebida = 16, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 276;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 277;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 278;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 279;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (228, 276, 'L2610140428', '2027-05-09', 0),
  (229, 277, 'L2610141629', '2027-07-02', 0),
  (230, 278, 'L2610141830', '2027-04-01', 0),
  (231, 279, 'L2610142031', '2027-02-14', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (4, 4, 228, 'ENTRADA_COMPRA', 16, 'Recebimento da compra 68');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (16, 4, 229, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 68');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (18, 4, 230, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 68');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (20, 4, 231, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 68');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-14 16:27:00');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (521, 1, 73, '2026-10-14 16:27:00', '0.00', '7.00', 'CONCLUIDA', '672944', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (972, 521, 39, 152, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (521, 'DEBITO', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-14 21:10:19');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (522, 4, 73, '2026-10-14 21:10:19', '0.00', '44.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (973, 522, 5, 164, NULL, 'UNIDADE', 1, '10.00'),
  (974, 522, 36, NULL, NULL, 'UNIDADE', 1, '22.00'),
  (975, 522, 33, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (522, 'PIX', 22.00),
  (522, 'CREDITO', 22.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-14 21:58:15');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (523, 4, 73, '2026-10-14 21:58:15', '5.00', '45.00', 'CONCLUIDA', '838028', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (976, 523, 43, 154, NULL, 'UNIDADE', 2, '5.00'),
  (977, 523, 40, 128, NULL, 'UNIDADE', 2, '8.00'),
  (978, 523, 40, 197, NULL, 'UNIDADE', 3, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (523, 'PIX', 45.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-14 22:18:06');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (524, 1, 73, '2026-10-14 22:18:06', '0.00', '4.50', 'CONCLUIDA', '698271', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (979, 524, 12, 208, NULL, 'UNIDADE', 1, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (524, 'CREDITO', 4.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-14 22:30:39');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (525, 4, 73, '2026-10-14 22:30:39', '0.00', '33.00', 'CONCLUIDA', '198837', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (980, 525, 24, NULL, 3, 'DOSE', 1, '4.00'),
  (981, 525, 46, 200, NULL, 'UNIDADE', 1, '13.00'),
  (982, 525, 51, NULL, NULL, 'UNIDADE', 2, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (525, 'PIX', 33.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-14 23:05:00');
SET @id_funcionario_logado = 1;
CALL sp_fechar_caixa(73, 200.00);

-- ===== 15/10/2026 (quinta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-15 12:43:26');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-15 12:45:30');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-15 12:52:00');
SET @id_funcionario_logado = 4;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (74, 4, '2026-10-15 12:52:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-15 10:40:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (70, 4, 1, '2026-10-15 10:40:00', 'ENTREGA', '102.50', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (281, 70, 40, 8, 0, '5.40', 0),
  (282, 70, 43, 5, 0, '3.10', 0),
  (283, 70, 44, 12, 0, '1.80', 0),
  (284, 70, 51, 3, 0, '5.00', 0),
  (285, 70, 54, 6, 0, '1.20', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-15 10:13:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (71, 5, 1, '2026-10-15 10:13:00', 'RETIRADA', '44.10', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (286, 71, 49, 5, 0, '6.50', 0),
  (287, 71, 60, 2, 0, '5.80', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-15 14:30:00');
SET @id_funcionario_logado = 3;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-15 14:30:00', nr_nota_fiscal = '748130' WHERE id_compra = 69;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 280;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (28, 3, NULL, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 69');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-15 17:00:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-15 17:00:00', nr_nota_fiscal = '326879' WHERE id_compra = 71;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 286;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 287;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (232, 287, 'L2610156032', '2026-10-24', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (49, 3, NULL, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 71');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 3, 232, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 71');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-15 17:29:34');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (526, 3, 74, '2026-10-15 17:29:34', '0.00', '20.50', 'CONCLUIDA', '852454', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (983, 526, 1, 204, NULL, 'UNIDADE', 1, '5.00'),
  (984, 526, 1, 146, NULL, 'UNIDADE', 2, '5.00'),
  (985, 526, 10, 118, NULL, 'UNIDADE', 1, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (526, 'PIX', 20.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-15 18:02:24');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (527, 4, 74, '2026-10-15 18:02:24', '0.00', '67.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (986, 527, 7, 108, NULL, 'UNIDADE', 3, '9.50'),
  (987, 527, 7, 174, NULL, 'UNIDADE', 3, '9.50'),
  (988, 527, 5, 164, NULL, 'UNIDADE', 1, '10.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (527, 'CREDITO', 28.50);
CALL sp_registrar_venda_fiado(527, 12, '2026-11-14', 38.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-15 18:46:00');
SET @id_funcionario_logado = 3;
CALL sp_registrar_evento_acesso(3, 'CONSULTA_DADO_PESSOAL', 'cliente', '7', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-15 18:48:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (32, 33, 74, 'PIX', '36.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-15 19:28:09');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (528, 4, 74, '2026-10-15 19:28:09', '0.00', '5.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (989, 528, 1, 146, NULL, 'UNIDADE', 1, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (528, 'DEBITO', 5.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-15 21:15:03');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (529, 4, 74, '2026-10-15 21:15:03', '0.00', '34.00', 'CONCLUIDA', '635719', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (990, 529, 42, 94, NULL, 'UNIDADE', 1, '6.00'),
  (991, 529, 24, NULL, 3, 'DOSE', 2, '4.00'),
  (992, 529, 2, 156, NULL, 'UNIDADE', 1, '6.00'),
  (993, 529, 23, NULL, 5, 'DOSE', 1, '14.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (529, 'DINHEIRO', 34.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-15 21:20:37');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (530, 3, 74, '2026-10-15 21:20:37', '0.00', '40.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (994, 530, 5, 164, NULL, 'UNIDADE', 2, '10.00'),
  (995, 530, 5, 138, NULL, 'UNIDADE', 2, '10.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (530, 'DINHEIRO', 40.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-15 21:57:36');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (531, 4, 74, '2026-10-15 21:57:36', '0.00', '25.00', 'CONCLUIDA', '887278', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (996, 531, 15, 210, NULL, 'UNIDADE', 1, '3.00'),
  (997, 531, 42, 217, NULL, 'UNIDADE', 1, '6.00'),
  (998, 531, 40, 197, NULL, 'UNIDADE', 2, '8.00');
CALL sp_registrar_venda_fiado(531, 1, '2026-11-14', 25.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-15 23:05:00');
CALL sp_fechar_caixa(74, 274.00);

-- ===== 16/10/2026 (sexta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-16 12:47:31');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-16 12:47:43');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-16 12:40:00');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-16 12:53:00');
SET @id_funcionario_logado = 3;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (75, 3, '2026-10-16 12:53:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-16 10:14:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (72, 1, 1, '2026-10-16 10:14:00', 'ENTREGA', '175.70', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (288, 72, 5, 15, 0, '6.80', 0),
  (289, 72, 7, 11, 0, '6.70', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-16 14:30:00');
SET @id_funcionario_logado = 2;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-16 14:30:00', nr_nota_fiscal = '215738' WHERE id_compra = 70;
UPDATE item_compra SET qt_recebida = 8, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 281;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 282;
UPDATE item_compra SET qt_recebida = 12, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 283;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 284;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 285;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (233, 281, 'L2610164033', '2026-12-24', 0),
  (234, 281, 'L2610164034', '2027-01-30', 0),
  (235, 282, 'L2610164335', '2027-04-02', 0),
  (236, 283, 'L2610164436', '2027-05-02', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (40, 2, 233, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 70');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (40, 2, 234, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 70');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (43, 2, 235, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 70');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (44, 2, 236, 'ENTRADA_COMPRA', 12, 'Recebimento da compra 70');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (51, 2, NULL, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 70');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (54, 2, NULL, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 70');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-16 15:13:00');
SET @id_funcionario_logado = 3;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (53, 75, 3, 'DESPESA', '20.00', 'Material de limpeza');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-16 16:19:00');
CALL sp_registrar_evento_acesso(3, 'CONSULTA_DADO_PESSOAL', 'cliente', '1', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-16 16:21:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (33, 38, 75, 'CREDITO', '25.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-16 16:38:31');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (532, 1, 75, '2026-10-16 16:38:31', '0.00', '12.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (999, 532, 49, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (532, 'PIX', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-16 16:49:40');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (533, 2, 75, '2026-10-16 16:49:40', '0.00', '1.50', 'CONCLUIDA', '238903', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1000, 533, 47, 173, NULL, 'UNIDADE', 1, '1.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (533, 'PIX', 1.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-16 18:09:33');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (534, 3, 75, '2026-10-16 18:09:33', '0.00', '42.00', 'CONCLUIDA', '247416', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1001, 534, 9, 149, NULL, 'UNIDADE', 1, '18.00'),
  (1002, 534, 35, NULL, NULL, 'UNIDADE', 1, '24.00');
CALL sp_registrar_venda_fiado(534, 12, '2026-11-15', 42.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-16 19:26:07');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (535, 2, 75, '2026-10-16 19:26:07', '0.00', '33.50', 'CONCLUIDA', '180234', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1003, 535, 34, NULL, NULL, 'UNIDADE', 1, '12.50'),
  (1004, 535, 20, 231, NULL, 'UNIDADE', 3, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (535, 'DINHEIRO', 16.70),
  (535, 'PIX', 16.80);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-16 19:56:07');
SET @id_funcionario_logado = 1;
UPDATE venda SET st_venda = 'CANCELADA' WHERE id_venda = 535;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (34, 1, NULL, 'AJUSTE_ENTRADA', 1, 'Cancelamento da venda 535: produto devolvido ao estoque');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (20, 1, 231, 'AJUSTE_ENTRADA', 3, 'Cancelamento da venda 535: produto devolvido ao estoque');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'venda', '535', '{"acao": "cancelamento", "total": "33.50"}', '192.168.0.11');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'UPDATE', 'venda', '535', '{"coluna": "st_venda", "antes": "CONCLUIDA", "depois": "CANCELADA"}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-16 19:36:57');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (536, 1, 75, '2026-10-16 19:36:57', '0.00', '25.00', 'CONCLUIDA', '902065', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1005, 536, 37, NULL, NULL, 'UNIDADE', 1, '25.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (536, 'PIX', 15.00),
  (536, 'CREDITO', 10.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-16 19:42:06');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (537, 2, 75, '2026-10-16 19:42:06', '0.00', '9.00', 'CONCLUIDA', '698060', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1006, 537, 12, 208, NULL, 'UNIDADE', 2, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (537, 'PIX', 9.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-16 20:28:00');
CALL sp_registrar_evento_acesso(2, 'CONSULTA_DADO_PESSOAL', 'cliente', '6', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-16 20:30:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (34, 15, 75, 'PIX', '12.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-16 21:57:10');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (538, 3, 75, '2026-10-16 21:57:10', '0.00', '34.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1007, 538, 7, 174, NULL, 'UNIDADE', 3, '9.50'),
  (1008, 538, 10, 118, NULL, 'UNIDADE', 1, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (538, 'DEBITO', 17.00),
  (538, 'DINHEIRO', 17.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-16 23:43:49');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (539, 2, 75, '2026-10-16 23:43:49', '0.00', '18.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1009, 539, 2, 156, NULL, 'UNIDADE', 3, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (539, 'DINHEIRO', 18.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 00:08:00');
SET @id_funcionario_logado = 3;
CALL sp_fechar_caixa(75, 165.00);

-- ===== 17/10/2026 (sábado) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 12:46:28');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 12:46:48');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 12:41:35');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 12:55:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (76, 3, '2026-10-17 12:55:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 13:20:00');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 1, 214, 'PERDA', 4, 'Lote vencido em 16/10/2026');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 13:21:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '1355', '{"tipo": "PERDA", "motivo": "vencimento", "lote": 214, "quantidade": 4}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 13:39:14');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (540, 1, 76, '2026-10-17 13:39:14', '0.00', '57.00', 'CONCLUIDA', '764445', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1010, 540, 7, 174, NULL, 'UNIDADE', 6, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (540, 'PIX', 57.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 14:25:49');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (541, 4, 76, '2026-10-17 14:25:49', '0.00', '12.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1011, 541, 38, NULL, NULL, 'UNIDADE', 2, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (541, 'DEBITO', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 14:30:00');
SET @id_funcionario_logado = 1;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-17 14:30:00', nr_nota_fiscal = '534762' WHERE id_compra = 72;
UPDATE item_compra SET qt_recebida = 15, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 288;
UPDATE item_compra SET qt_recebida = 11, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 289;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (237, 288, 'L2610170537', '2027-06-11', 0),
  (238, 288, 'L2610170538', '2027-07-06', 0),
  (239, 289, 'L2610170739', '2027-03-18', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (5, 1, 237, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 72');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (5, 1, 238, 'ENTRADA_COMPRA', 8, 'Recebimento da compra 72');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (7, 1, 239, 'ENTRADA_COMPRA', 11, 'Recebimento da compra 72');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 14:39:54');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (542, 3, 76, '2026-10-17 14:39:54', '0.00', '18.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1012, 542, 2, 163, NULL, 'UNIDADE', 3, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (542, 'PIX', 18.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 15:03:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (54, 76, 3, 'DESPESA', '50.00', 'Material de limpeza');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 15:36:45');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (543, 4, 76, '2026-10-17 15:36:45', '0.00', '40.00', 'CONCLUIDA', '141653', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1013, 543, 5, 138, NULL, 'UNIDADE', 4, '10.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (543, 'CREDITO', 40.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 17:56:47');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (544, 1, 76, '2026-10-17 17:56:47', '0.00', '94.00', 'CONCLUIDA', '590525', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1014, 544, 5, 138, NULL, 'UNIDADE', 2, '10.00'),
  (1015, 544, 52, NULL, NULL, 'UNIDADE', 2, '22.00'),
  (1016, 544, 2, 163, NULL, 'UNIDADE', 4, '6.00'),
  (1017, 544, 38, NULL, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (544, 'PIX', 94.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 18:08:37');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (545, 3, 76, '2026-10-17 18:08:37', '0.00', '28.50', 'CONCLUIDA', '156724', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1018, 545, 3, 186, NULL, 'UNIDADE', 1, '3.50'),
  (1019, 545, 34, NULL, NULL, 'UNIDADE', 2, '12.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (545, 'DEBITO', 28.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 18:24:38');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (546, 4, 76, '2026-10-17 18:24:38', '0.00', '42.50', 'CONCLUIDA', '764651', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1020, 546, 12, 208, NULL, 'UNIDADE', 1, '4.50'),
  (1021, 546, 8, 206, NULL, 'UNIDADE', 2, '7.00'),
  (1022, 546, 2, 163, NULL, 'UNIDADE', 4, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (546, 'DINHEIRO', 42.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 18:47:00');
CALL sp_registrar_evento_acesso(4, 'CONSULTA_DADO_PESSOAL', 'cliente', '8', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 18:49:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (35, 36, 76, 'DEBITO', '42.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 19:15:21');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (547, 4, 76, '2026-10-17 19:15:21', '0.00', '3.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1023, 547, 15, 211, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (547, 'CREDITO', 3.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 19:46:19');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (548, 1, 76, '2026-10-17 19:46:19', '0.00', '4.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1024, 548, 12, 208, NULL, 'UNIDADE', 1, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (548, 'PIX', 4.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 19:51:09');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (549, 4, 76, '2026-10-17 19:51:09', '0.00', '6.00', 'CONCLUIDA', '723489', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1025, 549, 55, NULL, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (549, 'DINHEIRO', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-17 21:35:58');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (550, 4, 76, '2026-10-17 21:35:58', '0.00', '15.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1026, 550, 4, 157, NULL, 'UNIDADE', 2, '7.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (550, 'DINHEIRO', 15.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-18 00:08:00');
SET @id_funcionario_logado = 3;
CALL sp_fechar_caixa(76, 113.50);

-- ===== 18/10/2026 (domingo) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-18 12:43:41');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-18 12:49:31');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-18 12:57:00');
SET @id_funcionario_logado = 2;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (77, 2, '2026-10-18 12:57:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-18 15:29:58');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (551, 4, 77, '2026-10-18 15:29:58', '0.00', '10.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1027, 551, 15, 211, NULL, 'UNIDADE', 1, '3.00'),
  (1028, 551, 3, 186, NULL, 'UNIDADE', 2, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (551, 'DEBITO', 4.00),
  (551, 'CREDITO', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-18 17:07:11');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (552, 4, 77, '2026-10-18 17:07:11', '0.00', '22.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1029, 552, 45, 131, NULL, 'UNIDADE', 2, '1.00'),
  (1030, 552, 1, 146, NULL, 'UNIDADE', 4, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (552, 'DEBITO', 22.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-18 19:43:23');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (553, 2, 77, '2026-10-18 19:43:23', '0.00', '71.00', 'CONCLUIDA', '431597', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1031, 553, 11, 193, NULL, 'UNIDADE', 1, '11.00'),
  (1032, 553, 5, 138, NULL, 'UNIDADE', 6, '10.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (553, 'PIX', 71.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-18 19:49:58');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (554, 4, 77, '2026-10-18 19:49:58', '0.00', '8.00', 'CONCLUIDA', '422917', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1033, 554, 40, 233, NULL, 'UNIDADE', 1, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (554, 'PIX', 8.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-18 20:39:54');
SET @id_funcionario_logado = 2;
CALL sp_abrir_garrafa(26, 2, @garrafa);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-18 20:40:54');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (555, 2, 77, '2026-10-18 20:40:54', '0.00', '30.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1034, 555, 13, 194, NULL, 'UNIDADE', 1, '9.50'),
  (1035, 555, 22, NULL, 1, 'DOSE', 2, '7.00'),
  (1036, 555, 22, NULL, 6, 'DOSE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (555, 'CREDITO', 18.30),
  (555, 'DINHEIRO', 12.20);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-18 21:07:08');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (556, 4, 77, '2026-10-18 21:07:08', '0.00', '42.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1037, 556, 30, NULL, NULL, 'UNIDADE', 1, '36.00'),
  (1038, 556, 2, 163, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (556, 'DINHEIRO', 25.20),
  (556, 'PIX', 16.80);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-18 21:46:56');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (557, 4, 77, '2026-10-18 21:46:56', '0.00', '3.00', 'CONCLUIDA', '921255', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1039, 557, 15, 211, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (557, 'DINHEIRO', 3.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-18 23:48:24');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (558, 2, 77, '2026-10-18 23:48:24', '0.00', '16.00', 'CONCLUIDA', '919814', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1040, 558, 40, 233, NULL, 'UNIDADE', 2, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (558, 'PIX', 16.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-19 00:08:00');
CALL sp_fechar_caixa(77, 191.40);
UPDATE caixa SET ds_observacao = 'Sobrou R$ 1.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 77;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-19 00:10:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '77', '{"diferenca": "1.00"}', '192.168.0.11');

-- ===== 19/10/2026 (segunda) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-19 12:42:01');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-19 12:42:41');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-19 12:51:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (78, 2, '2026-10-19 12:51:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-19 10:40:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (73, 3, 1, '2026-10-19 10:40:00', 'RETIRADA', '220.90', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (290, 73, 33, 8, 0, '10.20', 0),
  (291, 73, 34, 4, 0, '11.90', 0),
  (292, 73, 36, 5, 0, '14.50', 0),
  (293, 73, 38, 6, 0, '3.20', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-19 10:21:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (74, 5, 1, '2026-10-19 10:21:00', 'RETIRADA', '23.20', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (294, 74, 60, 4, 0, '5.80', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-19 13:05:00');
SET @id_funcionario_logado = 2;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (55, 78, 2, 'SUPRIMENTO', '100.00', 'Reforço de troco para o caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-19 16:46:06');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (559, 2, 78, '2026-10-19 16:46:06', '0.00', '22.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1041, 559, 56, NULL, NULL, 'UNIDADE', 1, '9.00'),
  (1042, 559, 10, 118, NULL, 'UNIDADE', 1, '5.50'),
  (1043, 559, 51, NULL, NULL, 'UNIDADE', 1, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (559, 'PIX', 22.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-19 17:00:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-19 17:00:00', nr_nota_fiscal = '355999' WHERE id_compra = 73;
UPDATE item_compra SET qt_recebida = 8, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 290;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 291;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 292;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 293;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (33, 2, NULL, 'ENTRADA_COMPRA', 8, 'Recebimento da compra 73');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (34, 2, NULL, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 73');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (36, 2, NULL, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 73');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (38, 2, NULL, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 73');
SET @id_funcionario_logado = 3;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-19 17:00:00', nr_nota_fiscal = '487810' WHERE id_compra = 74;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 294;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (240, 294, 'L2610196040', '2026-10-31', 0),
  (241, 294, 'L2610196041', '2026-12-09', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 3, 240, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 74');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 3, 241, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 74');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-19 18:26:00');
CALL sp_registrar_evento_acesso(3, 'CONSULTA_DADO_PESSOAL', 'cliente', '11', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-19 18:28:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (36, 32, 78, 'DINHEIRO', '15.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-19 18:41:44');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (560, 2, 78, '2026-10-19 18:41:44', '0.00', '7.00', 'CONCLUIDA', '905069', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1044, 560, 3, 186, NULL, 'UNIDADE', 2, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (560, 'CREDITO', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-19 20:15:39');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (561, 3, 78, '2026-10-19 20:15:39', '0.00', '12.00', 'CONCLUIDA', '379469', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1045, 561, 33, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (561, 'PIX', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-19 20:54:10');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (562, 3, 78, '2026-10-19 20:54:10', '0.00', '55.00', 'CONCLUIDA', '948765', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1046, 562, 5, 138, NULL, 'UNIDADE', 3, '10.00'),
  (1047, 562, 37, NULL, NULL, 'UNIDADE', 1, '25.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (562, 'CREDITO', 55.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-19 22:08:53');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (563, 3, 78, '2026-10-19 22:08:53', '0.00', '103.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1048, 563, 7, 239, NULL, 'UNIDADE', 3, '9.50'),
  (1049, 563, 1, 146, NULL, 'UNIDADE', 3, '5.00'),
  (1050, 563, 31, NULL, NULL, 'UNIDADE', 1, '55.00'),
  (1051, 563, 43, 154, NULL, 'UNIDADE', 1, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (563, 'DINHEIRO', 103.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-19 23:05:00');
SET @id_funcionario_logado = 2;
CALL sp_fechar_caixa(78, 318.50);

-- ===== 20/10/2026 (terça) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-20 12:48:58');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-20 12:43:26');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-20 12:54:00');
SET @id_funcionario_logado = 1;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (79, 1, '2026-10-20 12:54:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-20 11:45:00');
CALL sp_autorizar_cliente_fiado(7, 200.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-20 10:25:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (75, 1, 1, '2026-10-20 10:25:00', 'ENTREGA', '467.80', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (295, 75, 1, 24, 0, '3.10', 0),
  (296, 75, 2, 26, 0, '3.85', 0),
  (297, 75, 5, 15, 0, '6.80', 0),
  (298, 75, 7, 12, 0, '6.70', 0),
  (299, 75, 11, 6, 0, '7.80', 0),
  (300, 75, 12, 7, 0, '3.10', 0),
  (301, 75, 13, 4, 0, '6.60', 0),
  (302, 75, 15, 10, 0, '1.60', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-20 13:13:03');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (564, 1, 79, '2026-10-20 13:13:03', '0.00', '32.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1052, 564, 24, 54, NULL, 'UNIDADE', 1, '16.00'),
  (1053, 564, 24, 28, NULL, 'UNIDADE', 1, '16.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (564, 'CREDITO', 12.80),
  (564, 'DEBITO', 19.20);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-20 15:10:00');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (36, 1, NULL, 'AJUSTE_ENTRADA', 2, 'Ajuste após contagem física: sobrou no estoque');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-20 15:11:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '1408', '{"tipo": "AJUSTE", "motivo": "contagem física"}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-20 15:32:54');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (565, 2, 79, '2026-10-20 15:32:54', '0.00', '6.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1054, 565, 41, 93, NULL, 'UNIDADE', 1, '6.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (565, 'PIX', 6.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-20 16:35:27');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (566, 1, 79, '2026-10-20 16:35:27', '0.00', '12.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1055, 566, 34, NULL, NULL, 'UNIDADE', 1, '12.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (566, 'PIX', 12.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-20 19:22:00');
CALL sp_registrar_evento_acesso(1, 'CONSULTA_DADO_PESSOAL', 'cliente', '7', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-20 19:24:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (37, 35, 79, 'DEBITO', '66.50');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-20 20:07:59');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (567, 1, 79, '2026-10-20 20:07:59', '0.00', '35.00', 'CONCLUIDA', '640038', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1056, 567, 39, 152, NULL, 'UNIDADE', 1, '7.00'),
  (1057, 567, 39, 196, NULL, 'UNIDADE', 2, '7.00'),
  (1058, 567, 23, NULL, 5, 'DOSE', 1, '14.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (567, 'DINHEIRO', 35.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-20 21:24:00');
CALL sp_registrar_evento_acesso(1, 'CONSULTA_DADO_PESSOAL', 'cliente', '5', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-20 21:26:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (38, 29, 79, 'PIX', '30.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-20 23:05:00');
CALL sp_fechar_caixa(79, 238.00);
UPDATE caixa SET ds_observacao = 'Sobrou R$ 3.00 no fechamento; conferido pelo gerente' WHERE id_caixa = 79;
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-20 23:07:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'caixa', '79', '{"diferenca": "3.00"}', '192.168.0.11');

-- ===== 21/10/2026 (quarta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-21 12:43:57');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-21 12:48:37');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-21 12:54:00');
SET @id_funcionario_logado = 4;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (80, 4, '2026-10-21 12:54:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-21 10:02:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (76, 2, 1, '2026-10-21 10:02:00', 'ENTREGA', '75.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (303, 76, 22, 2, 0, '27.00', 0),
  (304, 76, 24, 2, 0, '10.50', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-21 13:26:05');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (568, 1, 80, '2026-10-21 13:26:05', '0.00', '13.50', 'CONCLUIDA', '360911', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1059, 568, 4, 157, NULL, 'UNIDADE', 1, '7.50'),
  (1060, 568, 38, NULL, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (568, 'CREDITO', 13.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-21 14:24:01');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (569, 1, 80, '2026-10-21 14:24:01', '0.00', '37.00', 'CONCLUIDA', '843113', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1061, 569, 8, 207, NULL, 'UNIDADE', 3, '7.00'),
  (1062, 569, 39, 196, NULL, 'UNIDADE', 1, '7.00'),
  (1063, 569, 53, NULL, NULL, 'UNIDADE', 1, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (569, 'PIX', 18.50),
  (569, 'DINHEIRO', 18.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-21 14:30:00');
SET @id_funcionario_logado = 4;
UPDATE compra SET st_compra = 'RECEBIDA_PARCIAL', dt_recebimento = '2026-10-21 14:30:00', nr_nota_fiscal = '930686' WHERE id_compra = 75;
UPDATE item_compra SET qt_recebida = 24, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 295;
UPDATE item_compra SET qt_recebida = 26, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 296;
UPDATE item_compra SET qt_recebida = 15, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 297;
UPDATE item_compra SET qt_recebida = 12, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 298;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 299;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = '1 unidades avariadas, devolvidas ao fornecedor' WHERE id_item_compra = 300;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 301;
UPDATE item_compra SET qt_recebida = 10, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 302;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (242, 295, 'L2610210142', '2027-05-25', 0),
  (243, 295, 'L2610210143', '2027-06-14', 0),
  (244, 296, 'L2610210244', '2027-05-18', 0),
  (245, 296, 'L2610210245', '2027-06-07', 0),
  (246, 297, 'L2610210546', '2027-04-12', 0),
  (247, 298, 'L2610210747', '2027-06-13', 0),
  (248, 299, 'L2610211148', '2027-03-25', 0),
  (249, 300, 'L2610211249', '2027-05-09', 0),
  (250, 301, 'L2610211350', '2027-02-25', 0),
  (251, 302, 'L2610211551', '2027-04-26', 0),
  (252, 302, 'L2610211552', '2027-06-01', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (1, 4, 242, 'ENTRADA_COMPRA', 12, 'Recebimento da compra 75');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (1, 4, 243, 'ENTRADA_COMPRA', 12, 'Recebimento da compra 75');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (2, 4, 244, 'ENTRADA_COMPRA', 13, 'Recebimento da compra 75');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (2, 4, 245, 'ENTRADA_COMPRA', 13, 'Recebimento da compra 75');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (5, 4, 246, 'ENTRADA_COMPRA', 15, 'Recebimento da compra 75');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (7, 4, 247, 'ENTRADA_COMPRA', 12, 'Recebimento da compra 75');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (11, 4, 248, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 75');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (12, 4, 249, 'ENTRADA_COMPRA', 6, 'Recebimento da compra 75');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (13, 4, 250, 'ENTRADA_COMPRA', 4, 'Recebimento da compra 75');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (15, 4, 251, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 75');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (15, 4, 252, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 75');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-21 19:11:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (56, 80, 4, 'DESPESA', '50.00', 'Material de limpeza');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-21 19:55:16');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (570, 1, 80, '2026-10-21 19:55:16', '0.00', '42.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1064, 570, 5, 246, NULL, 'UNIDADE', 3, '10.00'),
  (1065, 570, 33, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (570, 'DINHEIRO', 42.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-21 20:01:45');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (571, 1, 80, '2026-10-21 20:01:45', '0.00', '55.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1066, 571, 31, NULL, NULL, 'UNIDADE', 1, '55.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (571, 'CREDITO', 55.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-21 21:29:08');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (572, 4, 80, '2026-10-21 21:29:08', '0.00', '74.00', 'CONCLUIDA', '362205', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1067, 572, 26, NULL, 2, 'DOSE', 3, '12.00'),
  (1068, 572, 7, 239, NULL, 'UNIDADE', 4, '9.50');
CALL sp_registrar_venda_fiado(572, 11, '2026-11-20', 74.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-21 23:05:00');
CALL sp_fechar_caixa(80, 160.50);

-- ===== 22/10/2026 (quinta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-22 12:44:27');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-22 12:49:09');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-22 12:55:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (81, 4, '2026-10-22 12:55:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-22 10:36:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (77, 4, 1, '2026-10-22 10:36:00', 'ENTREGA', '95.40', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (305, 77, 39, 8, 0, '4.60', 0),
  (306, 77, 40, 5, 0, '5.40', 0),
  (307, 77, 42, 5, 0, '4.00', 0),
  (308, 77, 53, 2, 0, '5.80', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-22 10:05:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (78, 5, 1, '2026-10-22 10:05:00', 'RETIRADA', '13.00', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (309, 78, 56, 2, 0, '6.50', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-22 14:22:00');
SET @id_funcionario_logado = 4;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (57, 81, 4, 'DESPESA', '15.00', 'Sacolas e embalagens');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-22 14:30:00');
SET @id_funcionario_logado = 3;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-22 14:30:00', nr_nota_fiscal = '319133' WHERE id_compra = 76;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 303;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 304;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (253, 303, 'L2610222253', '2028-07-13', 0),
  (254, 304, 'L2610222454', '2028-08-04', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (22, 3, 253, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 76');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (24, 3, 254, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 76');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-22 14:32:00');
SET @id_funcionario_logado = 4;
CALL sp_registrar_evento_acesso(4, 'CONSULTA_DADO_PESSOAL', 'cliente', '3', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-22 14:34:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (39, 30, 81, 'DINHEIRO', '16.50');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-22 17:00:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-22 17:00:00', nr_nota_fiscal = '428178' WHERE id_compra = 78;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 309;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (56, 4, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 78');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-22 19:45:42');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (573, 4, 81, '2026-10-22 19:45:42', '0.00', '8.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1069, 573, 51, NULL, NULL, 'UNIDADE', 1, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (573, 'DINHEIRO', 8.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-22 20:41:26');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (574, 3, 81, '2026-10-22 20:41:26', '0.00', '33.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1070, 574, 10, 118, NULL, 'UNIDADE', 1, '5.50'),
  (1071, 574, 57, NULL, NULL, 'UNIDADE', 2, '14.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (574, 'DINHEIRO', 33.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-22 20:47:47');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (575, 4, 81, '2026-10-22 20:47:47', '0.00', '28.50', 'CONCLUIDA', '218241', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1072, 575, 41, 93, NULL, 'UNIDADE', 1, '6.50'),
  (1073, 575, 6, 139, NULL, 'UNIDADE', 1, '11.00'),
  (1074, 575, 6, 189, NULL, 'UNIDADE', 1, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (575, 'PIX', 28.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-22 21:36:22');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (576, 3, 81, '2026-10-22 21:36:22', '0.00', '12.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1075, 576, 33, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (576, 'DINHEIRO', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-22 22:03:40');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (577, 4, 81, '2026-10-22 22:03:40', '0.00', '14.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1076, 577, 20, 231, NULL, 'UNIDADE', 2, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (577, 'PIX', 14.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-22 22:03:52');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (578, 3, 81, '2026-10-22 22:03:52', '0.00', '18.00', 'CONCLUIDA', '134313', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1077, 578, 19, 144, NULL, 'UNIDADE', 2, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (578, 'PIX', 18.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-22 23:05:00');
SET @id_funcionario_logado = 4;
CALL sp_fechar_caixa(81, 155.00);

-- ===== 23/10/2026 (sexta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-23 12:40:28');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-23 12:41:31');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-23 12:47:12');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-23 12:53:00');
SET @id_funcionario_logado = 1;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (82, 1, '2026-10-23 12:53:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-23 10:38:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (79, 1, 1, '2026-10-23 10:38:00', 'ENTREGA', '49.20', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (310, 79, 8, 8, 0, '5.00', 0),
  (311, 79, 20, 2, 0, '4.60', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-23 14:30:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-23 14:30:00', nr_nota_fiscal = '284658' WHERE id_compra = 77;
UPDATE item_compra SET qt_recebida = 8, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 305;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 306;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 307;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 308;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (255, 305, 'L2610233955', '2027-01-04', 0),
  (256, 306, 'L2610234056', '2027-01-18', 0),
  (257, 307, 'L2610234257', '2027-04-08', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (39, 1, 255, 'ENTRADA_COMPRA', 8, 'Recebimento da compra 77');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (40, 1, 256, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 77');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (42, 1, 257, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 77');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (53, 1, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 77');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-23 16:32:32');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (579, 3, 82, '2026-10-23 16:32:32', '0.00', '8.50', 'CONCLUIDA', '382732', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1078, 579, 60, 232, NULL, 'UNIDADE', 1, '8.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (579, 'PIX', 8.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-23 16:38:00');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (58, 82, 1, 'DESPESA', '35.00', 'Material de limpeza');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-23 17:12:38');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (580, 1, 82, '2026-10-23 17:12:38', '0.00', '80.00', 'CONCLUIDA', '275619', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1079, 580, 37, NULL, NULL, 'UNIDADE', 2, '25.00'),
  (1080, 580, 33, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (1081, 580, 17, 47, NULL, 'UNIDADE', 1, '9.00'),
  (1082, 580, 17, 122, NULL, 'UNIDADE', 1, '9.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (580, 'CREDITO', 80.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-23 18:20:42');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (581, 1, 82, '2026-10-23 18:20:42', '0.00', '12.00', 'CONCLUIDA', '510462', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1083, 581, 33, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (581, 'PIX', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-23 19:28:00');
SET @id_funcionario_logado = 2;
CALL sp_registrar_evento_acesso(2, 'CONSULTA_DADO_PESSOAL', 'cliente', '5', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-23 19:30:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (40, 29, 82, 'PIX', '23.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-23 19:50:49');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (582, 1, 82, '2026-10-23 19:50:49', '0.00', '33.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1084, 582, 10, 118, NULL, 'UNIDADE', 1, '5.50'),
  (1085, 582, 10, 192, NULL, 'UNIDADE', 2, '5.50'),
  (1086, 582, 1, 146, NULL, 'UNIDADE', 1, '5.00'),
  (1087, 582, 1, 182, NULL, 'UNIDADE', 1, '5.00'),
  (1088, 582, 41, 93, NULL, 'UNIDADE', 1, '6.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (582, 'CREDITO', 16.50),
  (582, 'PIX', 16.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-23 20:02:08');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (583, 2, 82, '2026-10-23 20:02:08', '0.00', '15.00', 'CONCLUIDA', '628656', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1089, 583, 4, 157, NULL, 'UNIDADE', 2, '7.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (583, 'DINHEIRO', 7.50),
  (583, 'CREDITO', 7.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-23 20:54:15');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (584, 2, 82, '2026-10-23 20:54:15', '0.00', '14.00', 'CONCLUIDA', '819694', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1090, 584, 3, 186, NULL, 'UNIDADE', 2, '3.50'),
  (1091, 584, 3, 223, NULL, 'UNIDADE', 2, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (584, 'DINHEIRO', 14.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-23 20:58:39');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (585, 2, 82, '2026-10-23 20:58:39', '0.00', '6.00', 'CONCLUIDA', '694883', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1092, 585, 2, 163, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (585, 'PIX', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-23 22:49:00');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (586, 3, 82, '2026-10-23 22:49:00', '0.00', '33.00', 'CONCLUIDA', '526495', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1093, 586, 37, NULL, NULL, 'UNIDADE', 1, '25.00'),
  (1094, 586, 21, 25, NULL, 'UNIDADE', 1, '8.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (586, 'DINHEIRO', 33.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-23 23:27:24');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (587, 3, 82, '2026-10-23 23:27:24', '0.00', '7.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1095, 587, 39, 196, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (587, 'DINHEIRO', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-24 00:08:00');
SET @id_funcionario_logado = 1;
CALL sp_fechar_caixa(82, 176.50);

-- ===== 24/10/2026 (sábado) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-24 12:44:25');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-24 12:46:04');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-24 12:42:18');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-24 12:55:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (83, 1, '2026-10-24 12:55:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-24 14:30:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-24 14:30:00', nr_nota_fiscal = '388296' WHERE id_compra = 79;
UPDATE item_compra SET qt_recebida = 8, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 310;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 311;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (258, 310, 'L2610240858', '2027-06-13', 0),
  (259, 311, 'L2610242059', '2027-04-05', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (8, 1, 258, 'ENTRADA_COMPRA', 8, 'Recebimento da compra 79');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (20, 1, 259, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 79');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-24 14:55:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (59, 83, 1, 'DESPESA', '50.00', 'Café e água dos funcionários');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-24 15:51:33');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (588, 4, 83, '2026-10-24 15:51:33', '0.00', '20.00', 'CONCLUIDA', '394623', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1096, 588, 25, NULL, 4, 'DOSE', 2, '10.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (588, 'PIX', 20.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-24 17:05:11');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (589, 1, 83, '2026-10-24 17:05:11', '0.00', '60.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1097, 589, 5, 246, NULL, 'UNIDADE', 6, '10.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (589, 'DEBITO', 60.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-24 18:02:14');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (590, 1, 83, '2026-10-24 18:02:14', '0.00', '12.50', 'CONCLUIDA', '822710', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1098, 590, 34, NULL, NULL, 'UNIDADE', 1, '12.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (590, 'CREDITO', 12.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-24 18:15:14');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (591, 1, 83, '2026-10-24 18:15:14', '0.00', '4.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1099, 591, 50, NULL, NULL, 'UNIDADE', 1, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (591, 'DEBITO', 4.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-24 18:36:00');
SET @id_funcionario_logado = 4;
CALL sp_registrar_evento_acesso(4, 'CONSULTA_DADO_PESSOAL', 'cliente', '12', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-24 18:38:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (41, 39, 83, 'DINHEIRO', '20.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-24 18:56:31');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (592, 3, 83, '2026-10-24 18:56:31', '0.00', '7.00', 'CONCLUIDA', '865771', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1100, 592, 39, 196, NULL, 'UNIDADE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (592, 'PIX', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-24 19:02:47');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (593, 3, 83, '2026-10-24 19:02:47', '0.00', '46.50', 'CONCLUIDA', '484217', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1101, 593, 33, NULL, NULL, 'UNIDADE', 1, '12.00'),
  (1102, 593, 7, 239, NULL, 'UNIDADE', 1, '9.50'),
  (1103, 593, 37, NULL, NULL, 'UNIDADE', 1, '25.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (593, 'PIX', 46.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-24 20:12:51');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (594, 3, 83, '2026-10-24 20:12:51', '0.00', '40.50', 'CONCLUIDA', '167815', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1104, 594, 23, NULL, 5, 'DOSE', 2, '14.00'),
  (1105, 594, 34, NULL, NULL, 'UNIDADE', 1, '12.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (594, 'DEBITO', 20.20),
  (594, 'DINHEIRO', 20.30);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-24 21:03:17');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (595, 3, 83, '2026-10-24 21:03:17', '0.00', '65.00', 'CONCLUIDA', '694618', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1106, 595, 43, 154, NULL, 'UNIDADE', 3, '5.00'),
  (1107, 595, 37, NULL, NULL, 'UNIDADE', 2, '25.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (595, 'PIX', 65.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-24 22:36:06');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (596, 4, 83, '2026-10-24 22:36:06', '0.00', '18.50', 'CONCLUIDA', '332275', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1108, 596, 46, 200, NULL, 'UNIDADE', 1, '13.00'),
  (1109, 596, 10, 192, NULL, 'UNIDADE', 1, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (596, 'DINHEIRO', 18.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-24 23:56:31');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (597, 3, 83, '2026-10-24 23:56:31', '0.00', '5.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1110, 597, 10, 192, NULL, 'UNIDADE', 1, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (597, 'DINHEIRO', 5.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-25 00:08:00');
SET @id_funcionario_logado = 1;
CALL sp_fechar_caixa(83, 164.30);

-- ===== 25/10/2026 (domingo) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-25 12:42:41');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-25 12:45:33');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-25 12:57:00');
SET @id_funcionario_logado = 2;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (84, 2, '2026-10-25 12:57:00', '100.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-25 15:59:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (60, 84, 2, 'DESPESA', '35.00', 'Compra de gelo para o balcão');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-25 17:19:58');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (598, 4, 84, '2026-10-25 17:19:58', '0.00', '26.00', 'CONCLUIDA', '404652', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1111, 598, 46, 200, NULL, 'UNIDADE', 2, '13.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (598, 'PIX', 26.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-25 18:37:21');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (599, 4, 84, '2026-10-25 18:37:21', '0.00', '33.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1112, 599, 11, 193, NULL, 'UNIDADE', 1, '11.00'),
  (1113, 599, 4, 157, NULL, 'UNIDADE', 3, '7.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (599, 'PIX', 11.00);
CALL sp_registrar_venda_fiado(599, 2, '2026-11-24', 22.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-25 20:23:26');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (600, 4, 84, '2026-10-25 20:23:26', '0.00', '5.00', 'CONCLUIDA', '853390', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1114, 600, 43, 154, NULL, 'UNIDADE', 1, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (600, 'PIX', 5.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-25 20:28:21');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (601, 4, 84, '2026-10-25 20:28:21', '0.00', '24.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1115, 601, 40, 233, NULL, 'UNIDADE', 1, '8.00'),
  (1116, 601, 2, 163, NULL, 'UNIDADE', 2, '6.00'),
  (1117, 601, 14, 77, NULL, 'UNIDADE', 1, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (601, 'DINHEIRO', 12.20),
  (601, 'PIX', 12.30);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-25 21:31:08');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (602, 2, 84, '2026-10-25 21:31:08', '0.00', '5.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1118, 602, 10, 192, NULL, 'UNIDADE', 1, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (602, 'DINHEIRO', 5.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-25 22:20:09');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (603, 2, 84, '2026-10-25 22:20:09', '0.00', '12.00', 'CONCLUIDA', '136321', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1119, 603, 33, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (603, 'CREDITO', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-25 22:42:02');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (604, 2, 84, '2026-10-25 22:42:02', '0.00', '4.00', 'CONCLUIDA', '294806', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1120, 604, 18, 227, NULL, 'UNIDADE', 1, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (604, 'PIX', 4.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-25 23:13:36');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (605, 2, 84, '2026-10-25 23:13:36', '0.00', '27.50', 'CONCLUIDA', '335866', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1121, 605, 2, 163, NULL, 'UNIDADE', 3, '6.00'),
  (1122, 605, 58, NULL, NULL, 'UNIDADE', 1, '6.50'),
  (1123, 605, 15, 251, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (605, 'DEBITO', 27.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-26 00:08:00');
CALL sp_fechar_caixa(84, 82.70);

-- ===== 26/10/2026 (segunda) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-26 12:46:52');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-26 12:49:02');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-26 12:54:00');
SET @id_funcionario_logado = 3;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (85, 3, '2026-10-26 12:54:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-26 10:26:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (80, 3, 1, '2026-10-26 10:26:00', 'RETIRADA', '203.40', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (312, 80, 33, 7, 0, '10.20', 0),
  (313, 80, 37, 8, 0, '16.50', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-26 10:31:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (81, 5, 1, '2026-10-26 10:31:00', 'RETIRADA', '28.20', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (314, 81, 57, 2, 0, '9.50', 0),
  (315, 81, 58, 2, 0, '4.60', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-26 15:07:35');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (606, 3, 85, '2026-10-26 15:07:35', '0.00', '61.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1124, 606, 40, 215, NULL, 'UNIDADE', 5, '8.00'),
  (1125, 606, 20, 231, NULL, 'UNIDADE', 2, '7.00'),
  (1126, 606, 22, NULL, 6, 'DOSE', 1, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (606, 'DINHEIRO', 61.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-26 17:00:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-26 17:00:00', nr_nota_fiscal = '327655' WHERE id_compra = 80;
UPDATE item_compra SET qt_recebida = 7, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 312;
UPDATE item_compra SET qt_recebida = 8, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 313;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (33, 3, NULL, 'ENTRADA_COMPRA', 7, 'Recebimento da compra 80');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (37, 3, NULL, 'ENTRADA_COMPRA', 8, 'Recebimento da compra 80');
SET @id_funcionario_logado = 2;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-26 17:00:00', nr_nota_fiscal = '379539' WHERE id_compra = 81;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 314;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 315;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (57, 2, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 81');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (58, 2, NULL, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 81');
SET @id_funcionario_logado = 3;
CALL sp_registrar_evento_acesso(3, 'CONSULTA_DADO_PESSOAL', 'cliente', '7', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-26 17:02:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (42, 31, 85, 'DEBITO', '25.00');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-26 17:39:00');
SET @id_funcionario_logado = 2;
CALL sp_registrar_evento_acesso(2, 'CONSULTA_DADO_PESSOAL', 'cliente', '8', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-26 17:41:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (43, 34, 85, 'PIX', '22.50');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-26 17:47:16');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (607, 3, 85, '2026-10-26 17:47:16', '0.00', '12.00', 'CONCLUIDA', '591377', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1127, 607, 33, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (607, 'DINHEIRO', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-26 19:46:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (61, 85, 3, 'DESPESA', '15.00', 'Café e água dos funcionários');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-26 20:26:35');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (608, 2, 85, '2026-10-26 20:26:35', '0.00', '2.50', 'CONCLUIDA', '685466', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1128, 608, 54, NULL, NULL, 'UNIDADE', 1, '2.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (608, 'PIX', 2.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-26 22:02:06');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (609, 2, 85, '2026-10-26 22:02:06', '0.00', '25.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1129, 609, 43, 154, NULL, 'UNIDADE', 2, '5.00'),
  (1130, 609, 43, 235, NULL, 'UNIDADE', 3, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (609, 'DINHEIRO', 25.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-26 22:08:33');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (610, 3, 85, '2026-10-26 22:08:33', '0.00', '18.00', 'CONCLUIDA', '835458', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1131, 610, 44, 236, NULL, 'UNIDADE', 1, '3.00'),
  (1132, 610, 1, 182, NULL, 'UNIDADE', 3, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (610, 'PIX', 7.20),
  (610, 'DEBITO', 10.80);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-26 23:05:00');
CALL sp_fechar_caixa(85, 283.00);

-- ===== 27/10/2026 (terça) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-27 12:49:27');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-27 12:47:58');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-27 12:58:00');
SET @id_funcionario_logado = 1;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (86, 1, '2026-10-27 12:58:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-27 10:26:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (82, 1, 1, '2026-10-27 10:26:00', 'ENTREGA', '54.20', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (316, 82, 3, 11, 0, '2.40', 0),
  (317, 82, 17, 3, 0, '6.20', 0),
  (318, 82, 20, 2, 0, '4.60', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-27 13:13:48');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (611, 2, 86, '2026-10-27 13:13:48', '0.00', '99.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1133, 611, 11, 83, NULL, 'UNIDADE', 1, '11.00'),
  (1134, 611, 26, 30, NULL, 'UNIDADE', 1, '78.00'),
  (1135, 611, 16, 229, NULL, 'UNIDADE', 3, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (611, 'DEBITO', 99.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-27 13:20:00');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 1, 232, 'PERDA', 1, 'Lote vencido em 24/10/2026');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-27 13:21:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '1510', '{"tipo": "PERDA", "motivo": "vencimento", "lote": 232, "quantidade": 1}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-27 15:10:00');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (51, 1, NULL, 'AJUSTE_SAIDA', 1, 'Ajuste após contagem física: faltou no estoque');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-27 15:11:00');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'movimentacao_estoque', '1511', '{"tipo": "AJUSTE", "motivo": "contagem física"}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-27 18:09:13');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (612, 1, 86, '2026-10-27 18:09:13', '0.00', '25.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1136, 612, 37, NULL, NULL, 'UNIDADE', 1, '25.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (612, 'CREDITO', 25.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-27 18:09:29');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (613, 2, 86, '2026-10-27 18:09:29', '0.00', '6.50', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1137, 613, 58, NULL, NULL, 'UNIDADE', 1, '6.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (613, 'DINHEIRO', 6.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-27 18:47:50');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (614, 2, 86, '2026-10-27 18:47:50', '0.00', '6.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1138, 614, 44, 236, NULL, 'UNIDADE', 2, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (614, 'DINHEIRO', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-27 20:52:10');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (615, 1, 86, '2026-10-27 20:52:10', '0.00', '5.50', 'CONCLUIDA', '531514', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1139, 615, 10, 192, NULL, 'UNIDADE', 1, '5.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (615, 'CREDITO', 5.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-27 20:58:13');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (616, 1, 86, '2026-10-27 20:58:13', '0.00', '109.00', 'CONCLUIDA', '870132', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1140, 616, 34, NULL, NULL, 'UNIDADE', 2, '12.50'),
  (1141, 616, 32, NULL, NULL, 'UNIDADE', 1, '18.00'),
  (1142, 616, 6, 189, NULL, 'UNIDADE', 6, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (616, 'CREDITO', 43.60),
  (616, 'DINHEIRO', 65.40);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-27 21:20:13');
UPDATE venda SET st_venda = 'CANCELADA' WHERE id_venda = 616;
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (34, 1, NULL, 'AJUSTE_ENTRADA', 2, 'Cancelamento da venda 616: produto devolvido ao estoque');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (32, 1, NULL, 'AJUSTE_ENTRADA', 1, 'Cancelamento da venda 616: produto devolvido ao estoque');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (6, 1, 189, 'AJUSTE_ENTRADA', 6, 'Cancelamento da venda 616: produto devolvido ao estoque');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'APROVACAO', 'venda', '616', '{"acao": "cancelamento", "total": "109.00"}', '192.168.0.11');
INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip) VALUES (1, 'UPDATE', 'venda', '616', '{"coluna": "st_venda", "antes": "CONCLUIDA", "depois": "CANCELADA"}', '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-27 23:05:00');
CALL sp_fechar_caixa(86, 162.50);

-- ===== 28/10/2026 (quarta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-28 12:40:56');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-28 12:48:38');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-28 12:52:00');
SET @id_funcionario_logado = 4;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (87, 4, '2026-10-28 12:52:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-28 14:30:00');
SET @id_funcionario_logado = 1;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-28 14:30:00', nr_nota_fiscal = '280314' WHERE id_compra = 82;
UPDATE item_compra SET qt_recebida = 11, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 316;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 317;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 318;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (260, 316, 'L2610280360', '2027-04-14', 0),
  (261, 317, 'L2610281761', '2027-01-09', 0),
  (262, 318, 'L2610282062', '2027-03-26', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (3, 1, 260, 'ENTRADA_COMPRA', 11, 'Recebimento da compra 82');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (17, 1, 261, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 82');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (20, 1, 262, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 82');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-28 14:51:31');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (617, 1, 87, '2026-10-28 14:51:31', '0.00', '20.00', 'CONCLUIDA', '536906', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1143, 617, 1, 182, NULL, 'UNIDADE', 4, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (617, 'PIX', 20.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-28 15:25:35');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (618, 4, 87, '2026-10-28 15:25:35', '0.00', '36.00', 'CONCLUIDA', '252800', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1144, 618, 2, 183, NULL, 'UNIDADE', 1, '6.00'),
  (1145, 618, 1, 182, NULL, 'UNIDADE', 6, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (618, 'PIX', 36.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-28 17:00:05');
SET @id_funcionario_logado = 1;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (619, 1, 87, '2026-10-28 17:00:05', '0.00', '3.00', 'CONCLUIDA', '254983', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1146, 619, 15, 251, NULL, 'UNIDADE', 1, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (619, 'CREDITO', 3.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-28 20:48:24');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (620, 1, 87, '2026-10-28 20:48:24', '0.00', '4.50', 'CONCLUIDA', '450099', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1147, 620, 14, 77, NULL, 'UNIDADE', 1, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (620, 'CREDITO', 4.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-28 23:05:00');
SET @id_funcionario_logado = 4;
CALL sp_fechar_caixa(87, 200.00);

-- ===== 29/10/2026 (quinta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-29 12:41:25');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-29 12:46:13');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-29 12:55:00');
SET @id_funcionario_logado = 3;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (88, 3, '2026-10-29 12:55:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-29 10:16:00');
SET @id_funcionario_logado = 1;
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (83, 4, 1, '2026-10-29 10:16:00', 'ENTREGA', '97.90', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (319, 83, 40, 6, 0, '5.40', 0),
  (320, 83, 43, 10, 0, '3.10', 0),
  (321, 83, 46, 5, 0, '3.90', 0),
  (322, 83, 51, 3, 0, '5.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-29 10:07:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (84, 5, 1, '2026-10-29 10:07:00', 'RETIRADA', '11.60', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (323, 84, 60, 2, 0, '5.80', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-29 14:04:18');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (621, 4, 88, '2026-10-29 14:04:18', '0.00', '12.00', 'CONCLUIDA', '121672', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1148, 621, 33, NULL, NULL, 'UNIDADE', 1, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (621, 'PIX', 7.20),
  (621, 'DEBITO', 4.80);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-29 16:14:12');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (622, 4, 88, '2026-10-29 16:14:12', '0.00', '21.00', 'CONCLUIDA', '491852', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1149, 622, 39, 196, NULL, 'UNIDADE', 3, '7.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (622, 'DINHEIRO', 21.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-29 16:34:02');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (623, 4, 88, '2026-10-29 16:34:02', '0.00', '30.00', 'CONCLUIDA', '754178', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1150, 623, 1, 182, NULL, 'UNIDADE', 6, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (623, 'DINHEIRO', 30.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-29 16:49:23');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (624, 4, 88, '2026-10-29 16:49:23', '0.00', '4.50', 'CONCLUIDA', '912405', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1151, 624, 12, 100, NULL, 'UNIDADE', 1, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (624, 'DEBITO', 4.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-29 17:00:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-29 17:00:00', nr_nota_fiscal = '947191' WHERE id_compra = 84;
UPDATE item_compra SET qt_recebida = 2, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 323;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (263, 323, 'L2610296063', '2026-11-06', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (60, 4, 263, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 84');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-29 17:22:36');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (625, 4, 88, '2026-10-29 17:22:36', '0.00', '7.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1152, 625, 4, 157, NULL, 'UNIDADE', 1, '7.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (625, 'PIX', 7.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-29 18:36:00');
SET @id_funcionario_logado = 3;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (62, 88, 3, 'DESPESA', '20.00', 'Material de limpeza');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-29 20:40:08');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (626, 4, 88, '2026-10-29 20:40:08', '0.00', '94.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1153, 626, 6, 189, NULL, 'UNIDADE', 6, '11.00'),
  (1154, 626, 3, 260, NULL, 'UNIDADE', 1, '3.50'),
  (1155, 626, 1, 182, NULL, 'UNIDADE', 1, '5.00'),
  (1156, 626, 5, 246, NULL, 'UNIDADE', 2, '10.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (626, 'CREDITO', 37.80),
  (626, 'DEBITO', 56.70);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-29 23:05:00');
SET @id_funcionario_logado = 3;
CALL sp_fechar_caixa(88, 181.00);

-- ===== 30/10/2026 (sexta) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-30 12:43:17');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-30 12:44:09');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-30 12:49:16');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-30 12:57:00');
SET @id_funcionario_logado = 1;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (89, 1, '2026-10-30 12:57:00', '150.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-30 10:03:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (85, 1, 1, '2026-10-30 10:03:00', 'ENTREGA', '194.20', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (324, 85, 1, 22, 0, '3.10', 0),
  (325, 85, 6, 15, 0, '8.00', 0),
  (326, 85, 16, 3, 0, '2.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-30 14:12:10');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (627, 2, 89, '2026-10-30 14:12:10', '0.00', '45.00', 'CONCLUIDA', '793547', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1157, 627, 29, NULL, NULL, 'UNIDADE', 1, '45.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (627, 'PIX', 45.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-30 14:30:00');
SET @id_funcionario_logado = 1;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-30 14:30:00', nr_nota_fiscal = '894338' WHERE id_compra = 83;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 319;
UPDATE item_compra SET qt_recebida = 10, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 320;
UPDATE item_compra SET qt_recebida = 5, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 321;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 322;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (264, 319, 'L2610304064', '2027-02-02', 0),
  (265, 319, 'L2610304065', '2027-03-07', 0),
  (266, 320, 'L2610304366', '2027-05-28', 0),
  (267, 321, 'L2610304667', '2027-02-23', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (40, 1, 264, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 83');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (40, 1, 265, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 83');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (43, 1, 266, 'ENTRADA_COMPRA', 10, 'Recebimento da compra 83');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (46, 1, 267, 'ENTRADA_COMPRA', 5, 'Recebimento da compra 83');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (51, 1, NULL, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 83');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-30 14:57:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (63, 89, 1, 'DESPESA', '15.00', 'Café e água dos funcionários');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-30 15:44:18');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (628, 1, 89, '2026-10-30 15:44:18', '3.00', '209.00', 'CONCLUIDA', '901882', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1158, 628, 48, 70, NULL, 'UNIDADE', 1, '4.00'),
  (1159, 628, 5, 246, NULL, 'UNIDADE', 4, '10.00'),
  (1160, 628, 2, 183, NULL, 'UNIDADE', 6, '6.00'),
  (1161, 628, 6, 189, NULL, 'UNIDADE', 4, '11.00'),
  (1162, 628, 6, 190, NULL, 'UNIDADE', 8, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (628, 'DINHEIRO', 209.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-30 16:43:14');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (629, 1, 89, '2026-10-30 16:43:14', '0.00', '4.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1163, 629, 50, NULL, NULL, 'UNIDADE', 1, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (629, 'DINHEIRO', 4.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-30 17:43:39');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (630, 1, 89, '2026-10-30 17:43:39', '0.00', '9.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1164, 630, 15, 251, NULL, 'UNIDADE', 3, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (630, 'DEBITO', 9.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-30 17:44:06');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (631, 1, 89, '2026-10-30 17:44:06', '0.00', '19.00', 'CONCLUIDA', '704082', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1165, 631, 45, 218, NULL, 'UNIDADE', 1, '1.00'),
  (1166, 631, 2, 183, NULL, 'UNIDADE', 1, '6.00'),
  (1167, 631, 2, 244, NULL, 'UNIDADE', 2, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (631, 'PIX', 19.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-30 18:08:06');
SET @id_funcionario_logado = 2;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (632, 2, 89, '2026-10-30 18:08:06', '0.00', '10.00', 'CONCLUIDA', '294571', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1168, 632, 5, 138, NULL, 'UNIDADE', 1, '10.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (632, 'PIX', 10.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-30 20:22:06');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (633, 3, 89, '2026-10-30 20:22:06', '0.00', '48.00', 'CONCLUIDA', '922602', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1169, 633, 35, NULL, NULL, 'UNIDADE', 2, '24.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (633, 'DINHEIRO', 19.20),
  (633, 'CREDITO', 28.80);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-30 20:26:06');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (634, 3, 89, '2026-10-30 20:26:06', '0.00', '19.00', 'CONCLUIDA', '740496', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1170, 634, 7, 239, NULL, 'UNIDADE', 2, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (634, 'PIX', 19.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-30 21:00:00');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (64, 89, 1, 'SANGRIA', '150.00', 'Sangria: retirada do excesso de dinheiro do caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-30 22:04:10');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (635, 1, 89, '2026-10-30 22:04:10', '0.00', '13.00', 'CONCLUIDA', '581971', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1171, 635, 46, 200, NULL, 'UNIDADE', 1, '13.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (635, 'PIX', 13.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-31 00:08:00');
CALL sp_fechar_caixa(89, 217.20);

-- ===== 31/10/2026 (sábado) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-31 12:45:43');
CALL sp_registrar_evento_acesso(1, 'LOGIN', NULL, NULL, NULL, '192.168.0.11');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-31 12:47:00');
CALL sp_registrar_evento_acesso(3, 'LOGIN', NULL, NULL, NULL, '192.168.0.13');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-31 12:48:09');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-31 12:55:00');
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (90, 1, '2026-10-31 12:55:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-31 10:23:00');
INSERT INTO compra (id_compra, id_fornecedor, id_funcionario, dt_pedido, tp_recebimento, vl_total, st_compra) VALUES (86, 2, 1, '2026-10-31 10:23:00', 'ENTREGA', '275.40', 'PEDIDO');
INSERT INTO item_compra (id_item_compra, id_compra, id_produto, qt_pedida, qt_recebida, vl_custo, fl_conferido) VALUES
  (327, 86, 21, 6, 0, '5.40', 0),
  (328, 86, 22, 4, 0, '27.00', 0),
  (329, 86, 25, 3, 0, '45.00', 0);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-31 14:30:00');
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-10-31 14:30:00', nr_nota_fiscal = '223456' WHERE id_compra = 85;
UPDATE item_compra SET qt_recebida = 22, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 324;
UPDATE item_compra SET qt_recebida = 15, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 325;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 326;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (268, 324, 'L2610310168', '2027-05-10', 0),
  (269, 325, 'L2610310669', '2027-04-13', 0),
  (270, 326, 'L2610311670', '2027-08-21', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (1, 1, 268, 'ENTRADA_COMPRA', 22, 'Recebimento da compra 85');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (6, 1, 269, 'ENTRADA_COMPRA', 15, 'Recebimento da compra 85');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (16, 1, 270, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 85');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-31 15:03:50');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (636, 1, 90, '2026-10-31 15:03:50', '0.00', '7.00', 'CONCLUIDA', '941212', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1172, 636, 10, 224, NULL, 'UNIDADE', 1, '5.50'),
  (1173, 636, 47, 173, NULL, 'UNIDADE', 1, '1.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (636, 'DEBITO', 7.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-31 15:10:00');
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (65, 90, 1, 'DESPESA', '35.00', 'Café e água dos funcionários');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-31 18:25:37');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (637, 3, 90, '2026-10-31 18:25:37', '0.00', '12.00', 'CONCLUIDA', '265984', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1174, 637, 51, NULL, NULL, 'UNIDADE', 1, '8.00'),
  (1175, 637, 50, NULL, NULL, 'UNIDADE', 1, '4.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (637, 'DINHEIRO', 6.00),
  (637, 'PIX', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-31 20:19:21');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (638, 4, 90, '2026-10-31 20:19:21', '0.00', '18.00', 'CONCLUIDA', '174203', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1176, 638, 22, NULL, 6, 'DOSE', 1, '7.00'),
  (1177, 638, 6, 269, NULL, 'UNIDADE', 1, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (638, 'PIX', 9.00),
  (638, 'DEBITO', 9.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-31 20:20:42');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (639, 4, 90, '2026-10-31 20:20:42', '0.00', '24.00', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1178, 639, 33, NULL, NULL, 'UNIDADE', 2, '12.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (639, 'DINHEIRO', 12.00),
  (639, 'PIX', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-31 20:26:51');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (640, 4, 90, '2026-10-31 20:26:51', '0.00', '22.00', 'CONCLUIDA', '884305', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1179, 640, 11, 83, NULL, 'UNIDADE', 2, '11.00');
CALL sp_registrar_venda_fiado(640, 5, '2026-11-30', 22.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-31 21:00:00');
SET @id_funcionario_logado = 1;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (66, 90, 1, 'SANGRIA', '100.00', 'Sangria: retirada do excesso de dinheiro do caixa');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-31 21:11:47');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (641, 3, 90, '2026-10-31 21:11:47', '0.00', '5.00', 'CONCLUIDA', '998220', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1180, 641, 1, 268, NULL, 'UNIDADE', 1, '5.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (641, 'DEBITO', 5.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-31 21:32:35');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (642, 3, 90, '2026-10-31 21:32:35', '0.00', '17.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1181, 642, 39, 196, NULL, 'UNIDADE', 1, '7.00'),
  (1182, 642, 3, 260, NULL, 'UNIDADE', 3, '3.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (642, 'DINHEIRO', 7.00);
CALL sp_registrar_venda_fiado(642, 8, '2026-11-30', 10.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-31 21:39:15');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (643, 4, 90, '2026-10-31 21:39:15', '0.00', '19.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1183, 643, 3, 260, NULL, 'UNIDADE', 2, '3.50'),
  (1184, 643, 34, NULL, NULL, 'UNIDADE', 1, '12.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (643, 'CREDITO', 19.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-31 22:11:59');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (644, 4, 90, '2026-10-31 22:11:59', '0.00', '39.50', 'CONCLUIDA', NULL, 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1185, 644, 43, 235, NULL, 'UNIDADE', 2, '5.00'),
  (1186, 644, 37, NULL, NULL, 'UNIDADE', 1, '25.00'),
  (1187, 644, 12, 100, NULL, 'UNIDADE', 1, '4.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (644, 'DINHEIRO', 39.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-31 22:42:42');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (645, 4, 90, '2026-10-31 22:42:42', '0.00', '6.00', 'CONCLUIDA', '405925', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1188, 645, 2, 244, NULL, 'UNIDADE', 1, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (645, 'PIX', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-31 23:07:05');
SET @id_funcionario_logado = 3;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (646, 3, 90, '2026-10-31 23:07:05', '0.00', '28.50', 'CONCLUIDA', '919340', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1189, 646, 4, 157, NULL, 'UNIDADE', 3, '7.50'),
  (1190, 646, 15, 211, NULL, 'UNIDADE', 2, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (646, 'DINHEIRO', 28.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-10-31 23:11:12');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (647, 3, 90, '2026-10-31 23:11:12', '0.00', '24.50', 'CONCLUIDA', '376485', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1191, 647, 34, NULL, NULL, 'UNIDADE', 1, '12.50'),
  (1192, 647, 54, NULL, NULL, 'UNIDADE', 1, '2.50'),
  (1193, 647, 7, 239, NULL, 'UNIDADE', 1, '9.50');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (647, 'PIX', 24.50);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-11-01 00:08:00');
SET @id_funcionario_logado = 1;
CALL sp_fechar_caixa(90, 158.00);

-- ===== 01/11/2026 (domingo) =====
SET TIMESTAMP = UNIX_TIMESTAMP('2026-11-01 12:49:53');
CALL sp_registrar_evento_acesso(2, 'LOGIN', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-11-01 12:43:41');
CALL sp_registrar_evento_acesso(4, 'LOGIN', NULL, NULL, NULL, '192.168.0.14');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-11-01 16:50:00');
CALL sp_registrar_evento_acesso(2, 'LOGIN_FALHA', NULL, NULL, NULL, '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-11-01 12:58:00');
SET @id_funcionario_logado = 4;
INSERT INTO caixa (id_caixa, id_funcionario, dt_abertura, vl_troco_inicial, st_caixa) VALUES (91, 4, '2026-11-01 12:58:00', '200.00', 'ABERTO');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-11-01 13:50:46');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (648, 4, 91, '2026-11-01 13:50:46', '0.00', '12.00', 'CONCLUIDA', NULL, 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1194, 648, 55, NULL, NULL, 'UNIDADE', 2, '6.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (648, 'DINHEIRO', 12.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-11-01 14:30:00');
SET @id_funcionario_logado = 2;
UPDATE compra SET st_compra = 'RECEBIDA', dt_recebimento = '2026-11-01 14:30:00', nr_nota_fiscal = '241988' WHERE id_compra = 86;
UPDATE item_compra SET qt_recebida = 6, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 327;
UPDATE item_compra SET qt_recebida = 4, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 328;
UPDATE item_compra SET qt_recebida = 3, fl_conferido = 1, ds_divergencia = NULL WHERE id_item_compra = 329;
INSERT INTO lote (id_lote, id_item_compra, nr_lote, dt_validade, qt_disponivel) VALUES
  (271, 327, 'L2611012171', '2027-04-08', 0),
  (272, 327, 'L2611012172', '2027-05-15', 0),
  (273, 328, 'L2611012273', '2028-03-16', 0),
  (274, 328, 'L2611012274', '2028-04-22', 0),
  (275, 329, 'L2611012575', '2027-12-14', 0);
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (21, 2, 271, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 86');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (21, 2, 272, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 86');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (22, 2, 273, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 86');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (22, 2, 274, 'ENTRADA_COMPRA', 2, 'Recebimento da compra 86');
INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo) VALUES (25, 2, 275, 'ENTRADA_COMPRA', 3, 'Recebimento da compra 86');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-11-01 15:56:00');
SET @id_funcionario_logado = 4;
INSERT INTO movimentacao_caixa (id_movimentacao_caixa, id_caixa, id_funcionario, tp_movimento, vl_movimento, ds_motivo) VALUES (67, 91, 4, 'DESPESA', '35.00', 'Material de limpeza');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-11-01 16:36:09');
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (649, 4, 91, '2026-11-01 16:36:09', '0.00', '6.00', 'CONCLUIDA', '610656', 0);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1195, 649, 15, 211, NULL, 'UNIDADE', 2, '3.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (649, 'PIX', 6.00);
SET TIMESTAMP = UNIX_TIMESTAMP('2026-11-01 17:02:00');
SET @id_funcionario_logado = 2;
CALL sp_registrar_evento_acesso(2, 'CONSULTA_DADO_PESSOAL', 'cliente', '2', JSON_OBJECT('motivo', 'cobrança de fiado'), '192.168.0.12');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-11-01 17:04:00');
INSERT INTO pagamento_fiado (id_pagamento_fiado, id_fiado, id_caixa, tp_forma, vl_pago) VALUES (44, 41, 91, 'PIX', '22.50');
SET TIMESTAMP = UNIX_TIMESTAMP('2026-11-01 20:24:03');
SET @id_funcionario_logado = 4;
INSERT INTO venda (id_venda, id_funcionario, id_caixa, dt_venda, vl_desconto, vl_total, st_venda, nr_documento_fiscal, fl_maioridade_conferida) VALUES (650, 4, 91, '2026-11-01 20:24:03', '0.00', '71.00', 'CONCLUIDA', '330359', 1);
INSERT INTO item_venda (id_item_venda, id_venda, id_produto, id_lote, id_garrafa_aberta, tp_item, qt_item, vl_unitario) VALUES
  (1196, 650, 29, NULL, NULL, 'UNIDADE', 1, '45.00'),
  (1197, 650, 50, NULL, NULL, 'UNIDADE', 1, '4.00'),
  (1198, 650, 11, 83, NULL, 'UNIDADE', 2, '11.00');
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES
  (650, 'DINHEIRO', 71.00);

-- ---------------------------------------------------------------------
-- 9) Bloqueio dos clientes com fiado vencido e não pago (RN12): o gerente bloqueia no fim do período
-- ---------------------------------------------------------------------
SET TIMESTAMP = UNIX_TIMESTAMP('2026-11-01 20:45:00');
SET @id_funcionario_logado = 1;
UPDATE cliente SET fl_bloqueado = 1 WHERE id_cliente = 4;
UPDATE cliente SET fl_bloqueado = 1 WHERE id_cliente = 9;

-- Volta ao relógio real e limpa o funcionário logado.
SET TIMESTAMP = DEFAULT;
SET @id_funcionario_logado = NULL;


-- =====================================================================
-- MIGRAÇÃO DOS DOCUMENTOS FISCAIS JÁ INFORMADOS NAS COMPRAS E VENDAS
-- Os campos antigos guardavam somente o número/referência. Aqui eles são
-- copiados para a tabela NOTA_FISCAL. Série, chave de acesso e data de emissão
-- ficam sem preenchimento quando não há essa informação na massa original.
-- SEM_VALIDACAO significa registro interno, não autorização pela SEFAZ.
-- =====================================================================
USE adega;

INSERT INTO nota_fiscal
  (tp_operacao, tp_modelo, nr_numero, nr_serie, cd_chave_acesso,
   dt_emissao, vl_total, st_documento, ds_observacao, id_compra, id_venda)
SELECT 'ENTRADA', 'OUTRO', TRIM(c.nr_nota_fiscal), NULL, NULL,
       NULL, c.vl_total, 'SEM_VALIDACAO',
       'Importado do campo nr_nota_fiscal da tabela compra; conferir dados completos do documento.',
       c.id_compra, NULL
  FROM compra AS c
 WHERE c.nr_nota_fiscal IS NOT NULL
   AND TRIM(c.nr_nota_fiscal) <> '';

INSERT INTO nota_fiscal
  (tp_operacao, tp_modelo, nr_numero, nr_serie, cd_chave_acesso,
   dt_emissao, vl_total, st_documento, ds_observacao, id_compra, id_venda)
SELECT 'SAIDA', 'OUTRO', TRIM(v.nr_documento_fiscal), NULL, NULL,
       NULL, v.vl_total, 'SEM_VALIDACAO',
       'Importado do campo nr_documento_fiscal da tabela venda; conferir se corresponde a NFC-e ou cupom fiscal.',
       NULL, v.id_venda
  FROM venda AS v
 WHERE v.nr_documento_fiscal IS NOT NULL
   AND TRIM(v.nr_documento_fiscal) <> '';
