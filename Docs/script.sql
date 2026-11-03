-- ====================================================================
-
CREATE DATABASE IF NOT EXISTS adega DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE adega;

CREATE TABLE categoria (
  id_categoria INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador da categoria',
  nm_categoria VARCHAR(60) NOT NULL COMMENT 'Nome da categoria',
  fl_restrita_maiores TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Indica se os produtos da categoria só podem ser vendidos a maiores de 18 anos',
  PRIMARY KEY (id_categoria),
  UNIQUE KEY uq_categoria_nm_categoria (nm_categoria)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Agrupa os produtos da adega e define se a venda é restrita a maiores de 18 anos.';

CREATE TABLE produto (
  id_produto INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador do produto',
  id_categoria INT UNSIGNED NOT NULL COMMENT 'Categoria do produto',
  cd_barras VARCHAR(14) NULL COMMENT 'Código de barras (EAN-8, EAN-13 ou EAN-14) lido no balcão',
  nm_produto VARCHAR(100) NOT NULL COMMENT 'Nome comercial com a medida',
  vl_venda DECIMAL(10,2) NOT NULL COMMENT 'Preço de venda da unidade fechada',
  fl_controla_validade TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indica se o produto exige controle por lote e validade',
  fl_vende_dose TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Indica se o produto também é vendido em doses',
  qt_ml_garrafa SMALLINT UNSIGNED NULL COMMENT 'Volume da garrafa em mililitros',
  qt_ml_dose SMALLINT UNSIGNED NULL COMMENT 'Volume de uma dose em mililitros',
  vl_dose DECIMAL(10,2) NULL COMMENT 'Preço de uma dose',
  fl_ativo TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indica se o produto está ativo para venda',
  PRIMARY KEY (id_produto),
  UNIQUE KEY uq_produto_cd_barras (cd_barras),
  KEY idx_produto_nm (nm_produto),
  CONSTRAINT fk_produto_id_categoria FOREIGN KEY (id_categoria) REFERENCES categoria (id_categoria),
  CONSTRAINT chk_produto_vl_venda CHECK (vl_venda >= 0),
  CONSTRAINT chk_produto_dose CHECK (fl_vende_dose = 0 OR (qt_ml_garrafa IS NOT NULL AND qt_ml_dose IS NOT NULL AND vl_dose IS NOT NULL AND qt_ml_dose <= qt_ml_garrafa))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Item comercializado: bebida, cigarro, petisco ou conveniência. Pode ser vendido fechado (unidade) ou em doses.';

CREATE TABLE estoque (
  id_estoque INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador do registro de estoque',
  id_produto INT UNSIGNED NOT NULL COMMENT 'Produto controlado',
  qt_atual INT NOT NULL DEFAULT 0 COMMENT 'Quantidade atual em unidades',
  qt_minima INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Quantidade mínima antes de repor (ponto de reposição)',
  ds_localizacao VARCHAR(60) NULL COMMENT 'Localização geral do produto no armazenamento',
  dt_atualizacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data e hora da última alteração do saldo',
  PRIMARY KEY (id_estoque),
  UNIQUE KEY uq_estoque_id_produto (id_produto),
  CONSTRAINT fk_estoque_id_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto),
  CONSTRAINT chk_estoque_qt_atual CHECK (qt_atual >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Saldo atual de cada produto (relação 1:1 com PRODUTO). Só muda por meio de MOVIMENTACAO_ESTOQUE.';

CREATE TABLE funcionario (
  id_funcionario INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador do funcionário',
  nm_funcionario VARCHAR(100) NOT NULL COMMENT 'Nome completo',
  nr_cpf CHAR(11) NOT NULL COMMENT 'CPF do funcionário (dado pessoal, LGPD)',
  tp_cargo ENUM('ATENDENTE','GERENTE') NOT NULL COMMENT 'Perfil de acesso no sistema',
  ds_login VARCHAR(40) NOT NULL COMMENT 'Nome de usuário para entrar no sistema',
  ds_senha_hash VARCHAR(255) NOT NULL COMMENT 'Hash da senha (bcrypt ou argon2)',
  dt_admissao DATE NOT NULL COMMENT 'Data de entrada na adega',
  fl_ativo TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indica se o funcionário ainda atua',
  PRIMARY KEY (id_funcionario),
  UNIQUE KEY uq_funcionario_nr_cpf (nr_cpf),
  UNIQUE KEY uq_funcionario_ds_login (ds_login)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Pessoa da equipe (3 a 4 funcionários) que usa o sistema. Perfis: atendente e gerente.';

CREATE TABLE escala (
  id_escala INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador do turno',
  id_funcionario INT UNSIGNED NOT NULL COMMENT 'Funcionário escalado',
  dt_turno DATE NOT NULL COMMENT 'Dia do turno',
  hr_inicio TIME NOT NULL COMMENT 'Hora de início',
  hr_fim TIME NOT NULL COMMENT 'Hora de término',
  ds_funcao VARCHAR(40) NOT NULL COMMENT 'Função exercida no turno',
  PRIMARY KEY (id_escala),
  UNIQUE KEY uq_escala_turno (id_funcionario, dt_turno, hr_inicio),
  KEY idx_escala_dt (dt_turno),
  CONSTRAINT fk_escala_id_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario (id_funcionario),
  CONSTRAINT chk_escala_horario CHECK (hr_fim <> hr_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Turno de trabalho de um funcionário em um dia, com a função que ele exerce.';

CREATE TABLE cliente (
  id_cliente INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador do cliente',
  nm_cliente VARCHAR(100) NOT NULL COMMENT 'Nome completo',
  nr_cpf CHAR(11) NOT NULL COMMENT 'CPF do cliente (dado pessoal, LGPD)',
  dt_nascimento DATE NOT NULL COMMENT 'Data de nascimento, para comprovar maioridade',
  nr_telefone VARCHAR(15) NOT NULL COMMENT 'Telefone com DDD, para cobrança',
  vl_limite_fiado DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Limite de saldo devedor autorizado',
  fl_bloqueado TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indica se o cliente está impedido de comprar fiado',
  dt_consentimento_lgpd DATETIME NOT NULL COMMENT 'Momento em que o cliente consentiu o uso dos dados',
  dt_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora do cadastro',
  PRIMARY KEY (id_cliente),
  UNIQUE KEY uq_cliente_nr_cpf (nr_cpf),
  KEY idx_cliente_nm (nm_cliente),
  CONSTRAINT chk_cliente_limite CHECK (vl_limite_fiado >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Cliente cadastrado para comprar fiado. Reúne dados pessoais protegidos pela LGPD.';

CREATE TABLE caixa (
  id_caixa INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador da sessão de caixa',
  id_funcionario INT UNSIGNED NOT NULL COMMENT 'Funcionário responsável pelo caixa',
  dt_abertura DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora de abertura',
  dt_fechamento DATETIME NULL COMMENT 'Data e hora de fechamento',
  vl_troco_inicial DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Dinheiro de troco colocado na abertura',
  vl_esperado DECIMAL(10,2) NULL COMMENT 'Dinheiro que deveria estar na gaveta no fechamento',
  vl_contado DECIMAL(10,2) NULL COMMENT 'Dinheiro contado fisicamente no fechamento',
  vl_diferenca DECIMAL(10,2) AS (vl_contado - vl_esperado) STORED COMMENT 'Diferença entre o contado e o esperado',
  st_caixa ENUM('ABERTO','FECHADO') NOT NULL DEFAULT 'ABERTO' COMMENT 'Situação da sessão',
  ds_observacao VARCHAR(255) NULL COMMENT 'Justificativa da diferença e registro de sangrias',
  PRIMARY KEY (id_caixa),
  KEY idx_caixa_dt (dt_abertura),
  CONSTRAINT fk_caixa_id_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario (id_funcionario),
  CONSTRAINT chk_caixa_fechamento CHECK ((st_caixa = 'ABERTO' AND dt_fechamento IS NULL) OR (st_caixa = 'FECHADO' AND dt_fechamento IS NOT NULL AND vl_contado IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Sessão de caixa, da abertura ao fechamento, com a conferência do dinheiro.';

CREATE TABLE venda (
  id_venda BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador da venda',
  id_funcionario INT UNSIGNED NOT NULL COMMENT 'Funcionário que realizou a venda',
  id_caixa INT UNSIGNED NOT NULL COMMENT 'Caixa aberto em que a venda foi feita',
  dt_venda DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora da venda',
  vl_desconto DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Desconto concedido na venda',
  vl_total DECIMAL(10,2) NOT NULL COMMENT 'Valor total cobrado',
  st_venda ENUM('CONCLUIDA','CANCELADA') NOT NULL DEFAULT 'CONCLUIDA' COMMENT 'Situação da venda',
  nr_documento_fiscal VARCHAR(44) NULL COMMENT 'Chave de acesso da NFC-e ou número do cupom fiscal',
  fl_maioridade_conferida TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Indica que o atendente conferiu a maioridade do comprador',
  PRIMARY KEY (id_venda),
  KEY idx_venda_dt (dt_venda),
  CONSTRAINT fk_venda_id_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario (id_funcionario),
  CONSTRAINT fk_venda_id_caixa FOREIGN KEY (id_caixa) REFERENCES caixa (id_caixa),
  CONSTRAINT chk_venda_valores CHECK (vl_desconto >= 0 AND vl_total >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Venda feita no balcão, ligada ao funcionário e ao caixa aberto.';

CREATE TABLE fiado (
  id_fiado INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador do fiado',
  id_venda BIGINT UNSIGNED NOT NULL COMMENT 'Venda original que gerou esta conta de fiado',
  id_cliente INT UNSIGNED NOT NULL COMMENT 'Cliente devedor',
  dt_abertura DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora de abertura da conta',
  dt_vencimento DATE NOT NULL COMMENT 'Data limite para pagamento',
  vl_total DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Total lançado na conta',
  vl_pago DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Total já pago',
  st_fiado ENUM('ABERTO','QUITADO') NOT NULL DEFAULT 'ABERTO' COMMENT 'Situação da conta',
  PRIMARY KEY (id_fiado),
  UNIQUE KEY uq_fiado_id_venda (id_venda),
  KEY idx_fiado_cliente_status (id_cliente, st_fiado),
  KEY idx_fiado_venc (dt_vencimento),
  CONSTRAINT fk_fiado_id_venda FOREIGN KEY (id_venda) REFERENCES venda (id_venda),
  CONSTRAINT fk_fiado_id_cliente FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
  CONSTRAINT chk_fiado_valores CHECK (vl_total > 0 AND vl_pago >= 0 AND vl_pago <= vl_total)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Conta de fiado de uma única venda, aberta para um cliente, com prazo e saldo.';

CREATE TABLE item_venda (
  id_item_venda BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador do item da venda',
  id_venda BIGINT UNSIGNED NOT NULL COMMENT 'Venda a que o item pertence',
  id_produto INT UNSIGNED NOT NULL COMMENT 'Produto vendido',
  id_lote INT UNSIGNED NULL COMMENT 'Lote de onde saiu a unidade vendida; obrigatório para produto com controle de validade',
  id_garrafa_aberta BIGINT UNSIGNED NULL COMMENT 'Garrafa aberta de onde saiu a dose; usado somente para venda por dose',
  tp_item ENUM('UNIDADE','DOSE') NOT NULL DEFAULT 'UNIDADE' COMMENT 'Indica se foi vendida a unidade fechada ou uma dose',
  qt_item SMALLINT UNSIGNED NOT NULL COMMENT 'Quantidade vendida',
  vl_unitario DECIMAL(10,2) NOT NULL COMMENT 'Preço unitário no momento da venda',
  vl_subtotal DECIMAL(12,2) AS (qt_item * vl_unitario) STORED COMMENT 'Valor do item',
  PRIMARY KEY (id_item_venda),
  CONSTRAINT fk_item_venda_id_venda FOREIGN KEY (id_venda) REFERENCES venda (id_venda),
  CONSTRAINT fk_item_venda_id_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto),
  CONSTRAINT chk_item_venda_qt CHECK (qt_item > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Produto vendido em uma venda, com quantidade e preço do momento.';

CREATE TABLE pagamento (
  id_pagamento BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador do pagamento',
  id_venda BIGINT UNSIGNED NOT NULL COMMENT 'Venda paga',
  tp_forma ENUM('DINHEIRO','PIX','DEBITO','CREDITO','FIADO') NOT NULL COMMENT 'Forma de pagamento',
  vl_pago DECIMAL(10,2) NOT NULL COMMENT 'Valor pago nesta forma',
  dt_pagamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora do pagamento',
  PRIMARY KEY (id_pagamento),
  KEY idx_pagamento_forma (tp_forma, dt_pagamento),
  CONSTRAINT fk_pagamento_id_venda FOREIGN KEY (id_venda) REFERENCES venda (id_venda),
  CONSTRAINT chk_pagamento_valor CHECK (vl_pago > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Forma de pagamento de uma venda. Uma venda pode ter vários pagamentos (pagamento dividido). Na forma FIADO, o valor é a parcela que ficou na conta de fiado da venda.';

CREATE TABLE item_fiado (
  id_item_fiado BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador do item do fiado',
  id_item_venda BIGINT UNSIGNED NOT NULL COMMENT 'Linha da venda que possui uma parte do valor destinada ao fiado',
  vl_fiado DECIMAL(10,2) NOT NULL COMMENT 'Valor desta linha que foi lançado no fiado',
  dt_lancamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora do lançamento',
  PRIMARY KEY (id_item_fiado),
  UNIQUE KEY uq_item_fiado_id_item_venda (id_item_venda),
  CONSTRAINT fk_item_fiado_id_item_venda FOREIGN KEY (id_item_venda) REFERENCES item_venda (id_item_venda),
  CONSTRAINT chk_item_fiado_valor CHECK (vl_fiado > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Registra quanto de cada item da venda foi destinado ao fiado, permitindo pagamento dividido.';

CREATE TABLE pagamento_fiado (
  id_pagamento_fiado BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador do pagamento do fiado',
  id_fiado INT UNSIGNED NOT NULL COMMENT 'Fiado abatido',
  id_caixa INT UNSIGNED NOT NULL COMMENT 'Caixa que recebeu o valor',
  tp_forma ENUM('DINHEIRO','PIX','DEBITO','CREDITO') NOT NULL COMMENT 'Forma usada para quitar',
  vl_pago DECIMAL(10,2) NOT NULL COMMENT 'Valor recebido',
  dt_pagamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora do recebimento',
  PRIMARY KEY (id_pagamento_fiado),
  CONSTRAINT fk_pagamento_fiado_id_fiado FOREIGN KEY (id_fiado) REFERENCES fiado (id_fiado),
  CONSTRAINT fk_pagamento_fiado_id_caixa FOREIGN KEY (id_caixa) REFERENCES caixa (id_caixa),
  CONSTRAINT chk_pagamento_fiado_valor CHECK (vl_pago > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Pagamento (total ou parcial) recebido para abater um fiado.';

CREATE TABLE fornecedor (
  id_fornecedor INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador do fornecedor',
  nm_fornecedor VARCHAR(100) NOT NULL COMMENT 'Razão social ou nome fantasia',
  nr_cnpj CHAR(14) NOT NULL COMMENT 'CNPJ do fornecedor',
  nr_telefone VARCHAR(15) NULL COMMENT 'Telefone de contato com DDD',
  tp_fornecimento ENUM('ENTREGA','RETIRADA','AMBOS') NOT NULL COMMENT 'Como o fornecedor costuma atender',
  fl_ativo TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indica se o fornecedor está ativo',
  PRIMARY KEY (id_fornecedor),
  UNIQUE KEY uq_fornecedor_nr_cnpj (nr_cnpj)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Empresa que vende mercadoria para a adega, com entrega ou retirada.';

CREATE TABLE compra (
  id_compra INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador da compra',
  id_fornecedor INT UNSIGNED NOT NULL COMMENT 'Fornecedor do pedido',
  id_funcionario INT UNSIGNED NOT NULL COMMENT 'Funcionário que fez a compra',
  dt_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora do pedido',
  dt_recebimento DATETIME NULL COMMENT 'Data e hora do recebimento',
  tp_recebimento ENUM('ENTREGA','RETIRADA') NOT NULL COMMENT 'Como a mercadoria chegou',
  nr_nota_fiscal VARCHAR(44) NULL COMMENT 'Número ou chave da nota fiscal do fornecedor',
  vl_total DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Valor total do pedido',
  st_compra ENUM('PEDIDO','RECEBIDA','RECEBIDA_PARCIAL','CANCELADA') NOT NULL DEFAULT 'PEDIDO' COMMENT 'Situação da compra',
  PRIMARY KEY (id_compra),
  KEY idx_compra_dt (dt_pedido),
  CONSTRAINT fk_compra_id_fornecedor FOREIGN KEY (id_fornecedor) REFERENCES fornecedor (id_fornecedor),
  CONSTRAINT fk_compra_id_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario (id_funcionario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Pedido de compra feito a um fornecedor por um funcionário.';

CREATE TABLE item_compra (
  id_item_compra INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador do item da compra',
  id_compra INT UNSIGNED NOT NULL COMMENT 'Compra a que o item pertence',
  id_produto INT UNSIGNED NOT NULL COMMENT 'Produto pedido',
  qt_pedida INT UNSIGNED NOT NULL COMMENT 'Quantidade pedida ao fornecedor',
  qt_recebida INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Quantidade realmente recebida',
  vl_custo DECIMAL(10,2) NOT NULL COMMENT 'Custo unitário pago ao fornecedor',
  fl_conferido TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Indica que o item foi conferido no recebimento',
  ds_divergencia VARCHAR(200) NULL COMMENT 'Descrição de erro, falta ou avaria',
  PRIMARY KEY (id_item_compra),
  UNIQUE KEY uq_item_compra_produto (id_compra, id_produto),
  CONSTRAINT fk_item_compra_id_compra FOREIGN KEY (id_compra) REFERENCES compra (id_compra),
  CONSTRAINT fk_item_compra_id_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto),
  CONSTRAINT chk_item_compra_qt CHECK (qt_pedida > 0 AND qt_recebida <= qt_pedida),
  CONSTRAINT chk_item_compra_custo CHECK (vl_custo >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Produto pedido em uma compra, com quantidade pedida, recebida e conferência.';

CREATE TABLE lote (
  id_lote INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador do lote',
  id_item_compra INT UNSIGNED NOT NULL COMMENT 'Item de compra que originou o lote',
  nr_lote VARCHAR(30) NULL COMMENT 'Número do lote impresso na embalagem',
  dt_validade DATE NOT NULL COMMENT 'Data de validade do lote',
  qt_disponivel INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Quantidade disponível no lote; começa em zero e é atualizada pelas movimentações de estoque',
  PRIMARY KEY (id_lote),
  KEY idx_lote_item_compra (id_item_compra),
  KEY idx_lote_validade (dt_validade),
  CONSTRAINT fk_lote_id_item_compra FOREIGN KEY (id_item_compra) REFERENCES item_compra (id_item_compra)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Lote recebido de produto com validade. Permite controlar vencimento e vender primeiro o que vence antes.';

CREATE TABLE movimentacao_estoque (
  id_movimentacao BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador da movimentação',
  id_produto INT UNSIGNED NOT NULL COMMENT 'Produto movimentado',
  id_funcionario INT UNSIGNED NOT NULL COMMENT 'Funcionário que registrou',
  id_lote INT UNSIGNED NULL COMMENT 'Lote atingido, quando houver',
  tp_movimento ENUM('ENTRADA_COMPRA','SAIDA_VENDA','SAIDA_DOSE','PERDA','DEVOLUCAO_FORNECEDOR','AJUSTE_ENTRADA','AJUSTE_SAIDA') NOT NULL COMMENT 'Tipo da movimentação',
  qt_movimentada INT UNSIGNED NOT NULL COMMENT 'Quantidade movimentada, sempre positiva',
  ds_motivo VARCHAR(200) NULL COMMENT 'Motivo da movimentação',
  dt_movimentacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora da movimentação',
  PRIMARY KEY (id_movimentacao),
  KEY idx_mov_produto_dt (id_produto, dt_movimentacao),
  CONSTRAINT fk_movimentacao_estoque_id_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto),
  CONSTRAINT fk_movimentacao_estoque_id_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario (id_funcionario),
  CONSTRAINT fk_movimentacao_estoque_id_lote FOREIGN KEY (id_lote) REFERENCES lote (id_lote),
  CONSTRAINT chk_mov_qt CHECK (qt_movimentada > 0),
  CONSTRAINT chk_mov_motivo CHECK (tp_movimento NOT IN ('PERDA','AJUSTE_ENTRADA','AJUSTE_SAIDA') OR ds_motivo IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Histórico de toda entrada e saída de estoque. Não pode ser alterado nem excluído.';



CREATE TABLE garrafa_aberta (
  id_garrafa_aberta BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador da garrafa aberta para venda de doses',
  id_lote INT UNSIGNED NOT NULL COMMENT 'Lote da garrafa aberta',
  id_produto INT UNSIGNED NOT NULL COMMENT 'Produto da garrafa',
  id_funcionario INT UNSIGNED NOT NULL COMMENT 'Funcionário que abriu a garrafa',
  dt_abertura DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora da abertura',
  qt_ml_inicial SMALLINT UNSIGNED NOT NULL COMMENT 'Volume inicial da garrafa em mililitros',
  qt_ml_restante SMALLINT UNSIGNED NOT NULL COMMENT 'Volume restante em mililitros',
  st_garrafa ENUM('ABERTA','ESGOTADA') NOT NULL DEFAULT 'ABERTA' COMMENT 'Situação da garrafa',
  PRIMARY KEY (id_garrafa_aberta),
  KEY idx_garrafa_lote_status (id_lote, st_garrafa),
  CONSTRAINT fk_garrafa_lote FOREIGN KEY (id_lote) REFERENCES lote (id_lote),
  CONSTRAINT fk_garrafa_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto),
  CONSTRAINT fk_garrafa_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario (id_funcionario),
  CONSTRAINT chk_garrafa_volume CHECK (qt_ml_inicial > 0 AND qt_ml_restante <= qt_ml_inicial)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Controla o volume restante de garrafas abertas para venda de doses.';

CREATE TABLE movimentacao_caixa (
  id_movimentacao_caixa BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador da movimentação financeira do caixa',
  id_caixa INT UNSIGNED NOT NULL COMMENT 'Sessão de caixa afetada',
  id_funcionario INT UNSIGNED NOT NULL COMMENT 'Funcionário que registrou a movimentação',
  tp_movimento ENUM('SUPRIMENTO','SANGRIA','DESPESA') NOT NULL COMMENT 'Entrada ou saída de dinheiro fora das vendas',
  vl_movimento DECIMAL(10,2) NOT NULL COMMENT 'Valor movimentado, sempre positivo',
  ds_motivo VARCHAR(200) NOT NULL COMMENT 'Motivo do suprimento, sangria ou despesa',
  dt_movimentacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora da movimentação',
  PRIMARY KEY (id_movimentacao_caixa),
  KEY idx_mov_caixa_dt (id_caixa, dt_movimentacao),
  CONSTRAINT fk_mov_caixa_caixa FOREIGN KEY (id_caixa) REFERENCES caixa (id_caixa),
  CONSTRAINT fk_mov_caixa_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario (id_funcionario),
  CONSTRAINT chk_mov_caixa_valor CHECK (vl_movimento > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Registra suprimentos, sangrias e despesas para calcular o fechamento do caixa.';

CREATE TABLE log_acesso (
  id_log BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador do registro de log',
  id_funcionario INT UNSIGNED NULL COMMENT 'Funcionário que gerou o evento',
  dt_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora do evento',
  tp_evento ENUM('LOGIN','LOGIN_FALHA','INSERT','UPDATE','DELETE','CONSULTA_DADO_PESSOAL','APROVACAO') NOT NULL COMMENT 'Tipo do evento registrado',
  nm_tabela VARCHAR(40) NULL COMMENT 'Tabela atingida',
  id_registro VARCHAR(40) NULL COMMENT 'Identificador do registro atingido',
  ds_alteracao JSON NULL COMMENT 'Valores antes e depois da alteração',
  ds_ip VARCHAR(45) NULL COMMENT 'Endereço IP de origem',
  PRIMARY KEY (id_log),
  KEY idx_log_dt (dt_evento),
  KEY idx_log_tabela (nm_tabela, id_registro),
  CONSTRAINT fk_log_acesso_id_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario (id_funcionario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Tabela de apoio (fora do DER conceitual) que registra quem fez o quê no sistema, para auditoria e LGPD.';



ALTER TABLE item_venda ADD CONSTRAINT fk_item_venda_lote FOREIGN KEY (id_lote) REFERENCES lote (id_lote);
ALTER TABLE item_venda ADD CONSTRAINT fk_item_venda_garrafa FOREIGN KEY (id_garrafa_aberta) REFERENCES garrafa_aberta (id_garrafa_aberta);

-- =====================================================================
-- TRIGGERS, PROCEDURES E REGRAS DE CONSISTENCIA
-- MySQL 8.0.16 ou superior (CHECK constraints ativos)
-- A aplicação deve definir @id_funcionario_logado após autenticar o usuário.
-- =====================================================================
DELIMITER $$

CREATE TRIGGER trg_produto_cria_estoque
AFTER INSERT ON produto FOR EACH ROW
BEGIN
  INSERT INTO estoque (id_produto, qt_atual, qt_minima)
  VALUES (NEW.id_produto, 0, 0);
END$$

CREATE TRIGGER trg_lote_inicia_zero
BEFORE INSERT ON lote FOR EACH ROW
BEGIN
  SET NEW.qt_disponivel = 0;
END$$

CREATE TRIGGER trg_venda_caixa_aberto
BEFORE INSERT ON venda FOR EACH ROW
BEGIN
  DECLARE v_status VARCHAR(10) DEFAULT NULL;
  SELECT st_caixa INTO v_status FROM caixa WHERE id_caixa = NEW.id_caixa;
  IF v_status IS NULL OR v_status <> 'ABERTO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A venda exige um caixa aberto.';
  END IF;
END$$

CREATE TRIGGER trg_item_venda_valida
BEFORE INSERT ON item_venda FOR EACH ROW
BEGIN
  DECLARE v_qt INT DEFAULT 0;
  DECLARE v_ativo TINYINT DEFAULT 0;
  DECLARE v_dose TINYINT DEFAULT 0;
  DECLARE v_controla TINYINT DEFAULT 1;
  DECLARE v_restrita TINYINT DEFAULT 0;
  DECLARE v_ml_dose SMALLINT UNSIGNED DEFAULT NULL;
  DECLARE v_maioridade TINYINT DEFAULT 0;
  DECLARE v_produto_lote INT UNSIGNED DEFAULT NULL;
  DECLARE v_validade DATE DEFAULT NULL;
  DECLARE v_saldo_lote INT UNSIGNED DEFAULT 0;
  DECLARE v_produto_garrafa INT UNSIGNED DEFAULT NULL;
  DECLARE v_ml_restante INT UNSIGNED DEFAULT 0;
  DECLARE v_status_garrafa VARCHAR(10) DEFAULT NULL;

  SELECT COUNT(*), MAX(p.fl_ativo), MAX(p.fl_vende_dose),
         MAX(p.fl_controla_validade), MAX(c.fl_restrita_maiores), MAX(p.qt_ml_dose)
    INTO v_qt, v_ativo, v_dose, v_controla, v_restrita, v_ml_dose
    FROM produto p JOIN categoria c ON c.id_categoria = p.id_categoria
   WHERE p.id_produto = NEW.id_produto;
  IF v_qt = 0 OR v_ativo = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Produto inexistente ou inativo.';
  END IF;

  SELECT COALESCE(MAX(fl_maioridade_conferida), 0)
    INTO v_maioridade FROM venda WHERE id_venda = NEW.id_venda;
  IF v_restrita = 1 AND v_maioridade <> 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Venda de produto restrito exige conferência da maioridade.';
  END IF;

  IF NEW.tp_item = 'UNIDADE' THEN
    IF NEW.id_garrafa_aberta IS NOT NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Item UNIDADE não pode apontar para garrafa aberta.';
    END IF;
    IF v_controla = 1 AND NEW.id_lote IS NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Produto com controle de validade exige informar o lote vendido.';
    END IF;
    IF NEW.id_lote IS NOT NULL THEN
      SELECT COUNT(*), MAX(ic.id_produto), MAX(l.dt_validade), MAX(l.qt_disponivel)
        INTO v_qt, v_produto_lote, v_validade, v_saldo_lote
        FROM lote l JOIN item_compra ic ON ic.id_item_compra = l.id_item_compra
       WHERE l.id_lote = NEW.id_lote;
      IF v_qt = 0 OR v_produto_lote <> NEW.id_produto THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lote não pertence ao produto vendido.';
      END IF;
      IF v_validade < CURRENT_DATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não é permitido vender produto vencido.';
      END IF;
      IF v_saldo_lote < NEW.qt_item THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo do lote insuficiente para a venda.';
      END IF;
    END IF;
  ELSEIF NEW.tp_item = 'DOSE' THEN
    IF v_dose <> 1 OR NEW.id_garrafa_aberta IS NULL OR NEW.id_lote IS NOT NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Venda por dose exige produto habilitado e uma garrafa aberta; não informe lote diretamente.';
    END IF;
    SELECT COUNT(*), MAX(ga.id_produto), MAX(ga.qt_ml_restante), MAX(ga.st_garrafa), MAX(l.dt_validade)
      INTO v_qt, v_produto_garrafa, v_ml_restante, v_status_garrafa, v_validade
      FROM garrafa_aberta ga JOIN lote l ON l.id_lote = ga.id_lote
     WHERE ga.id_garrafa_aberta = NEW.id_garrafa_aberta;
    IF v_qt = 0 OR v_produto_garrafa <> NEW.id_produto OR v_status_garrafa <> 'ABERTA' THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Garrafa aberta inexistente, esgotada ou de outro produto.';
    END IF;
    IF v_validade < CURRENT_DATE() THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não é permitido vender dose de lote vencido.';
    END IF;
    IF v_ml_restante < (NEW.qt_item * v_ml_dose) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Volume restante da garrafa insuficiente para as doses.';
    END IF;
  END IF;
END$$

CREATE TRIGGER trg_item_venda_registra_saida
AFTER INSERT ON item_venda FOR EACH ROW
BEGIN
  DECLARE v_funcionario INT UNSIGNED;
  DECLARE v_ml_dose SMALLINT UNSIGNED;
  DECLARE v_restante INT UNSIGNED;
  SELECT id_funcionario INTO v_funcionario FROM venda WHERE id_venda = NEW.id_venda;
  IF NEW.tp_item = 'UNIDADE' THEN
    INSERT INTO movimentacao_estoque
      (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo)
    VALUES
      (NEW.id_produto, v_funcionario, NEW.id_lote, 'SAIDA_VENDA', NEW.qt_item,
       CONCAT('Saída automática pela venda ', NEW.id_venda));
  ELSE
    SELECT qt_ml_dose INTO v_ml_dose FROM produto WHERE id_produto = NEW.id_produto;
    UPDATE garrafa_aberta
       SET st_garrafa = IF(qt_ml_restante - (NEW.qt_item * v_ml_dose) = 0, 'ESGOTADA', 'ABERTA'),
           qt_ml_restante = qt_ml_restante - (NEW.qt_item * v_ml_dose)
     WHERE id_garrafa_aberta = NEW.id_garrafa_aberta;
  END IF;
END$$

CREATE TRIGGER trg_item_venda_bloqueia_update
BEFORE UPDATE ON item_venda FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Item de venda não pode ser alterado; registre cancelamento/ajuste apropriado.';
END$$

CREATE TRIGGER trg_item_venda_bloqueia_delete
BEFORE DELETE ON item_venda FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Item de venda não pode ser excluído; registre cancelamento/ajuste apropriado.';
END$$

CREATE TRIGGER trg_movimentacao_valida_lote
BEFORE INSERT ON movimentacao_estoque FOR EACH ROW
BEGIN
  DECLARE v_produto INT UNSIGNED DEFAULT NULL;
  DECLARE v_validade DATE DEFAULT NULL;
  DECLARE v_saldo INT UNSIGNED DEFAULT NULL;
  DECLARE v_controla TINYINT DEFAULT 0;
  IF NEW.id_lote IS NOT NULL THEN
    SELECT ic.id_produto, l.dt_validade, l.qt_disponivel
      INTO v_produto, v_validade, v_saldo
      FROM lote l JOIN item_compra ic ON ic.id_item_compra = l.id_item_compra
     WHERE l.id_lote = NEW.id_lote FOR UPDATE;
    IF v_produto IS NULL OR v_produto <> NEW.id_produto THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lote informado não pertence ao produto da movimentação.';
    END IF;
    IF NEW.tp_movimento IN ('SAIDA_VENDA','SAIDA_DOSE') AND v_validade < CURRENT_DATE() THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saída de venda bloqueada: lote vencido.';
    END IF;
    IF NEW.tp_movimento IN ('SAIDA_VENDA','SAIDA_DOSE','PERDA','DEVOLUCAO_FORNECEDOR','AJUSTE_SAIDA')
       AND NEW.qt_movimentada > v_saldo THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantidade maior que o saldo disponível no lote.';
    END IF;
  ELSEIF NEW.tp_movimento IN ('SAIDA_VENDA','SAIDA_DOSE') THEN
    SELECT fl_controla_validade INTO v_controla FROM produto WHERE id_produto = NEW.id_produto;
    IF v_controla = 1 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saída de venda exige lote para produto com controle de validade.';
    END IF;
  END IF;
END$$

CREATE TRIGGER trg_movimentacao_atualiza_estoque
AFTER INSERT ON movimentacao_estoque FOR EACH ROW
BEGIN
  DECLARE v_delta INT DEFAULT 0;
  IF NEW.tp_movimento IN ('ENTRADA_COMPRA','AJUSTE_ENTRADA') THEN
    SET v_delta = NEW.qt_movimentada;
  ELSE
    SET v_delta = -CAST(NEW.qt_movimentada AS SIGNED);
  END IF;
  UPDATE estoque SET qt_atual = qt_atual + v_delta WHERE id_produto = NEW.id_produto;
  IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Produto sem registro de estoque.';
  END IF;
  IF NEW.id_lote IS NOT NULL THEN
    UPDATE lote SET qt_disponivel = qt_disponivel + v_delta WHERE id_lote = NEW.id_lote;
  END IF;
END$$

CREATE TRIGGER trg_movimentacao_bloqueia_update
BEFORE UPDATE ON movimentacao_estoque FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Movimentações não podem ser alteradas; registre um ajuste.';
END$$
CREATE TRIGGER trg_movimentacao_bloqueia_delete
BEFORE DELETE ON movimentacao_estoque FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Movimentações não podem ser excluídas.';
END$$

CREATE TRIGGER trg_garrafa_bloqueia_update_volume
BEFORE UPDATE ON garrafa_aberta FOR EACH ROW
BEGIN
  IF NEW.id_lote <> OLD.id_lote OR NEW.id_produto <> OLD.id_produto
     OR NEW.qt_ml_inicial <> OLD.qt_ml_inicial OR NEW.qt_ml_restante > OLD.qt_ml_restante
     OR (OLD.st_garrafa = 'ESGOTADA' AND NEW.st_garrafa <> OLD.st_garrafa) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dados da garrafa não podem ser aumentados ou trocados; registre nova abertura.';
  END IF;
END$$

CREATE TRIGGER trg_fiado_status_insert
BEFORE INSERT ON fiado FOR EACH ROW
BEGIN
  IF NEW.vl_total <= 0 OR NEW.vl_pago < 0 OR NEW.vl_pago > NEW.vl_total THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valores do fiado inválidos.';
  END IF;
  SET NEW.st_fiado = IF(NEW.vl_pago = NEW.vl_total, 'QUITADO', 'ABERTO');
END$$
CREATE TRIGGER trg_fiado_status_update
BEFORE UPDATE ON fiado FOR EACH ROW
BEGIN
  IF NEW.vl_total <= 0 OR NEW.vl_pago < 0 OR NEW.vl_pago > NEW.vl_total THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valores do fiado inválidos.';
  END IF;
  SET NEW.st_fiado = IF(NEW.vl_pago = NEW.vl_total, 'QUITADO', 'ABERTO');
END$$

CREATE TRIGGER trg_pagamento_valida
BEFORE INSERT ON pagamento FOR EACH ROW
BEGIN
  DECLARE v_total DECIMAL(10,2) DEFAULT NULL;
  DECLARE v_soma DECIMAL(10,2) DEFAULT 0.00;
  DECLARE v_fiado DECIMAL(10,2) DEFAULT NULL;
  DECLARE v_fiado_pago DECIMAL(10,2) DEFAULT 0.00;
  DECLARE v_caixa VARCHAR(10) DEFAULT NULL;
  SELECT vl_total INTO v_total FROM venda WHERE id_venda = NEW.id_venda AND st_venda = 'CONCLUIDA';
  IF v_total IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pagamento exige venda concluída.';
  END IF;
  SELECT COALESCE(SUM(vl_pago),0) INTO v_soma FROM pagamento WHERE id_venda = NEW.id_venda;
  IF v_soma + NEW.vl_pago > v_total THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A soma dos pagamentos não pode ultrapassar o total da venda.';
  END IF;
  IF NEW.tp_forma = 'FIADO' THEN
    SELECT vl_total INTO v_fiado FROM fiado WHERE id_venda = NEW.id_venda;
    IF v_fiado IS NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cadastre o fiado antes de registrar o pagamento FIADO.';
    END IF;
    SELECT COALESCE(SUM(vl_pago),0) INTO v_fiado_pago FROM pagamento WHERE id_venda = NEW.id_venda AND tp_forma = 'FIADO';
    IF v_fiado_pago + NEW.vl_pago > v_fiado THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pagamento FIADO ultrapassa o valor lançado na conta.';
    END IF;
  END IF;
END$$

CREATE TRIGGER trg_item_fiado_valida
BEFORE INSERT ON item_fiado FOR EACH ROW
BEGIN
  DECLARE v_venda BIGINT UNSIGNED DEFAULT NULL;
  DECLARE v_subtotal DECIMAL(12,2) DEFAULT NULL;
  DECLARE v_tem_fiado INT DEFAULT 0;
  SELECT id_venda, vl_subtotal INTO v_venda, v_subtotal
    FROM item_venda WHERE id_item_venda = NEW.id_item_venda;
  SELECT COUNT(*) INTO v_tem_fiado FROM fiado WHERE id_venda = v_venda;
  IF v_venda IS NULL OR v_tem_fiado = 0 OR NEW.vl_fiado <= 0 OR NEW.vl_fiado > v_subtotal THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Alocação de fiado inválida para o item da venda.';
  END IF;
END$$

CREATE TRIGGER trg_pagamento_bloqueia_update
BEFORE UPDATE ON pagamento FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pagamento de venda não pode ser alterado; registre estorno controlado.';
END$$
CREATE TRIGGER trg_pagamento_bloqueia_delete
BEFORE DELETE ON pagamento FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pagamento de venda não pode ser excluído; registre estorno controlado.';
END$$
CREATE TRIGGER trg_item_fiado_bloqueia_update
BEFORE UPDATE ON item_fiado FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Alocação do fiado não pode ser alterada.';
END$$
CREATE TRIGGER trg_item_fiado_bloqueia_delete
BEFORE DELETE ON item_fiado FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Alocação do fiado não pode ser excluída.';
END$$
CREATE TRIGGER trg_movimentacao_caixa_bloqueia_update
BEFORE UPDATE ON movimentacao_caixa FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Movimentação de caixa não pode ser alterada; registre movimento compensatório.';
END$$
CREATE TRIGGER trg_movimentacao_caixa_bloqueia_delete
BEFORE DELETE ON movimentacao_caixa FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Movimentação de caixa não pode ser excluída.';
END$$

CREATE TRIGGER trg_pagamento_fiado_valida
BEFORE INSERT ON pagamento_fiado FOR EACH ROW
BEGIN
  DECLARE v_total DECIMAL(10,2) DEFAULT NULL;
  DECLARE v_pago DECIMAL(10,2) DEFAULT 0.00;
  DECLARE v_caixa VARCHAR(10) DEFAULT NULL;
  SELECT vl_total, vl_pago INTO v_total, v_pago FROM fiado WHERE id_fiado = NEW.id_fiado FOR UPDATE;
  IF v_total IS NULL OR NEW.vl_pago <= 0 OR v_pago + NEW.vl_pago > v_total THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pagamento inválido ou maior que o saldo devedor.';
  END IF;
  SELECT st_caixa INTO v_caixa FROM caixa WHERE id_caixa = NEW.id_caixa;
  IF v_caixa IS NULL OR v_caixa <> 'ABERTO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Recebimento de fiado exige caixa aberto.';
  END IF;
END$$

CREATE TRIGGER trg_pagamento_fiado_bloqueia_update
BEFORE UPDATE ON pagamento_fiado FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Recebimento não pode ser alterado; faça estorno por procedimento próprio.';
END$$
CREATE TRIGGER trg_pagamento_fiado_bloqueia_delete
BEFORE DELETE ON pagamento_fiado FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Recebimento não pode ser excluído; faça estorno por procedimento próprio.';
END$$

CREATE TRIGGER trg_pagamento_fiado_atualiza
AFTER INSERT ON pagamento_fiado FOR EACH ROW
BEGIN
  UPDATE fiado SET vl_pago = vl_pago + NEW.vl_pago WHERE id_fiado = NEW.id_fiado;
  INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao)
  VALUES ((SELECT id_funcionario FROM funcionario WHERE id_funcionario = @id_funcionario_logado),
          'INSERT', 'pagamento_fiado', CAST(NEW.id_pagamento_fiado AS CHAR),
          JSON_OBJECT('vl_pago', NEW.vl_pago, 'id_fiado', NEW.id_fiado));
END$$

CREATE TRIGGER trg_movimentacao_caixa_aberto
BEFORE INSERT ON movimentacao_caixa FOR EACH ROW
BEGIN
  DECLARE v_status VARCHAR(10) DEFAULT NULL;
  SELECT st_caixa INTO v_status FROM caixa WHERE id_caixa = NEW.id_caixa;
  IF v_status IS NULL OR v_status <> 'ABERTO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Movimentação exige caixa aberto.';
  END IF;
END$$

CREATE TRIGGER trg_cliente_audita_insert
AFTER INSERT ON cliente FOR EACH ROW
BEGIN
  INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao)
  VALUES ((SELECT id_funcionario FROM funcionario WHERE id_funcionario = @id_funcionario_logado),
          'INSERT', 'cliente', CAST(NEW.id_cliente AS CHAR), JSON_OBJECT('fl_bloqueado', NEW.fl_bloqueado, 'vl_limite_fiado', NEW.vl_limite_fiado));
END$$
CREATE TRIGGER trg_cliente_audita_update
AFTER UPDATE ON cliente FOR EACH ROW
BEGIN
  INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao)
  VALUES ((SELECT id_funcionario FROM funcionario WHERE id_funcionario = @id_funcionario_logado),
          IF(OLD.fl_bloqueado = 1 AND NEW.fl_bloqueado = 0, 'APROVACAO', 'UPDATE'),
          'cliente', CAST(NEW.id_cliente AS CHAR),
          JSON_OBJECT('fl_bloqueado_antes', OLD.fl_bloqueado, 'fl_bloqueado_depois', NEW.fl_bloqueado,
                      'limite_antes', OLD.vl_limite_fiado, 'limite_depois', NEW.vl_limite_fiado));
END$$
CREATE TRIGGER trg_cliente_audita_delete
AFTER DELETE ON cliente FOR EACH ROW
BEGIN
  INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao)
  VALUES ((SELECT id_funcionario FROM funcionario WHERE id_funcionario = @id_funcionario_logado),
          'DELETE', 'cliente', CAST(OLD.id_cliente AS CHAR), JSON_OBJECT('registro', 'cliente excluído'));
END$$
CREATE TRIGGER trg_fiado_audita_insert
AFTER INSERT ON fiado FOR EACH ROW
BEGIN
  INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao)
  VALUES ((SELECT id_funcionario FROM funcionario WHERE id_funcionario = @id_funcionario_logado),
          'INSERT', 'fiado', CAST(NEW.id_fiado AS CHAR), JSON_OBJECT('id_cliente', NEW.id_cliente, 'vl_total', NEW.vl_total));
END$$
CREATE TRIGGER trg_fiado_audita_update
AFTER UPDATE ON fiado FOR EACH ROW
BEGIN
  INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao)
  VALUES ((SELECT id_funcionario FROM funcionario WHERE id_funcionario = @id_funcionario_logado),
          'UPDATE', 'fiado', CAST(NEW.id_fiado AS CHAR), JSON_OBJECT('vl_pago_antes', OLD.vl_pago, 'vl_pago_depois', NEW.vl_pago, 'status', NEW.st_fiado));
END$$
CREATE TRIGGER trg_caixa_audita_fechamento
AFTER UPDATE ON caixa FOR EACH ROW
BEGIN
  IF OLD.st_caixa = 'ABERTO' AND NEW.st_caixa = 'FECHADO' THEN
    INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao)
    VALUES ((SELECT id_funcionario FROM funcionario WHERE id_funcionario = @id_funcionario_logado),
            'UPDATE', 'caixa', CAST(NEW.id_caixa AS CHAR), JSON_OBJECT('vl_esperado', NEW.vl_esperado, 'vl_contado', NEW.vl_contado, 'vl_diferenca', NEW.vl_diferenca));
  END IF;
END$$

CREATE PROCEDURE sp_registrar_evento_acesso(
  IN p_id_funcionario INT UNSIGNED,
  IN p_tp_evento VARCHAR(30),
  IN p_nm_tabela VARCHAR(40),
  IN p_id_registro VARCHAR(40),
  IN p_ds_alteracao JSON,
  IN p_ds_ip VARCHAR(45)
)
BEGIN
  IF p_tp_evento NOT IN ('LOGIN','LOGIN_FALHA','CONSULTA_DADO_PESSOAL') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Evento reservado para login e consulta de dado pessoal.';
  END IF;
  INSERT INTO log_acesso (id_funcionario, tp_evento, nm_tabela, id_registro, ds_alteracao, ds_ip)
  VALUES (p_id_funcionario, p_tp_evento, p_nm_tabela, p_id_registro, p_ds_alteracao, p_ds_ip);
END$$

CREATE PROCEDURE sp_autorizar_cliente_fiado(
  IN p_id_cliente INT UNSIGNED,
  IN p_vl_limite DECIMAL(10,2)
)
BEGIN
  DECLARE v_cargo VARCHAR(20) DEFAULT NULL;
  DECLARE v_existe INT DEFAULT 0;
  SELECT COUNT(*) INTO v_existe FROM funcionario WHERE id_funcionario = @id_funcionario_logado AND fl_ativo = 1;
  IF v_existe = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Funcionário logado inválido ou inativo.';
  END IF;
  SELECT tp_cargo INTO v_cargo FROM funcionario WHERE id_funcionario = @id_funcionario_logado;
  IF v_cargo <> 'GERENTE' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Somente gerente pode autorizar cliente para fiado.';
  END IF;
  IF p_vl_limite <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Limite de fiado deve ser maior que zero.';
  END IF;
  UPDATE cliente SET vl_limite_fiado = p_vl_limite, fl_bloqueado = 0 WHERE id_cliente = p_id_cliente;
  IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente não encontrado ou sem alteração.';
  END IF;
END$$

CREATE PROCEDURE sp_abrir_garrafa(
  IN p_id_lote INT UNSIGNED,
  IN p_id_funcionario INT UNSIGNED,
  OUT p_id_garrafa_aberta BIGINT UNSIGNED
)
BEGIN
  DECLARE v_id_produto INT UNSIGNED DEFAULT NULL;
  DECLARE v_ml SMALLINT UNSIGNED DEFAULT NULL;
  DECLARE v_vende_dose TINYINT DEFAULT 0;
  DECLARE v_validade DATE DEFAULT NULL;
  DECLARE v_saldo INT UNSIGNED DEFAULT 0;
  DECLARE v_lote_existe INT DEFAULT 0;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
  START TRANSACTION;
  SELECT COUNT(*) INTO v_lote_existe FROM lote WHERE id_lote = p_id_lote;
  IF v_lote_existe = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lote não encontrado.';
  END IF;
  SELECT ic.id_produto, p.qt_ml_garrafa, p.fl_vende_dose, l.dt_validade, l.qt_disponivel
    INTO v_id_produto, v_ml, v_vende_dose, v_validade, v_saldo
    FROM lote l JOIN item_compra ic ON ic.id_item_compra = l.id_item_compra
    JOIN produto p ON p.id_produto = ic.id_produto
   WHERE l.id_lote = p_id_lote FOR UPDATE;
  IF v_vende_dose <> 1 OR v_ml IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Produto não está habilitado para venda por dose.';
  END IF;
  IF v_validade < CURRENT_DATE() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não é permitido abrir lote vencido.';
  END IF;
  IF v_saldo < 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não há garrafa fechada disponível neste lote.';
  END IF;
  INSERT INTO movimentacao_estoque (id_produto, id_funcionario, id_lote, tp_movimento, qt_movimentada, ds_motivo)
  VALUES (v_id_produto, p_id_funcionario, p_id_lote, 'SAIDA_DOSE', 1, 'Abertura de garrafa para venda de doses');
  INSERT INTO garrafa_aberta (id_lote, id_produto, id_funcionario, qt_ml_inicial, qt_ml_restante)
  VALUES (p_id_lote, v_id_produto, p_id_funcionario, v_ml, v_ml);
  SET p_id_garrafa_aberta = LAST_INSERT_ID();
  COMMIT;
END$$

CREATE PROCEDURE sp_registrar_venda_fiado(
  IN p_id_venda BIGINT UNSIGNED,
  IN p_id_cliente INT UNSIGNED,
  IN p_dt_vencimento DATE,
  IN p_vl_fiado DECIMAL(10,2)
)
BEGIN
  DECLARE v_total DECIMAL(10,2) DEFAULT NULL;
  DECLARE v_desconto DECIMAL(10,2) DEFAULT 0.00;
  DECLARE v_bloqueado TINYINT DEFAULT 1;
  DECLARE v_limite DECIMAL(10,2) DEFAULT 0.00;
  DECLARE v_saldo_aberto DECIMAL(10,2) DEFAULT 0.00;
  DECLARE v_pagamentos DECIMAL(10,2) DEFAULT 0.00;
  DECLARE v_soma_itens DECIMAL(12,2) DEFAULT 0.00;
  DECLARE v_tem_fiado INT DEFAULT 0;
  DECLARE v_tem_pagamento_fiado INT DEFAULT 0;
  DECLARE v_qt_itens INT DEFAULT 0;
  DECLARE v_done TINYINT DEFAULT 0;
  DECLARE v_id_item BIGINT UNSIGNED;
  DECLARE v_subtotal DECIMAL(12,2);
  DECLARE v_alocado DECIMAL(12,2);
  DECLARE v_restante DECIMAL(10,2);
  DECLARE cur_itens CURSOR FOR
    SELECT id_item_venda, vl_subtotal FROM item_venda
     WHERE id_venda = p_id_venda ORDER BY id_item_venda;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

  START TRANSACTION;
  SELECT COUNT(*) INTO v_qt_itens FROM venda WHERE id_venda = p_id_venda AND st_venda = 'CONCLUIDA';
  IF v_qt_itens = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Venda não encontrada ou não concluída.';
  END IF;
  SELECT vl_total, vl_desconto INTO v_total, v_desconto FROM venda WHERE id_venda = p_id_venda FOR UPDATE;

  SELECT COUNT(*) INTO v_qt_itens FROM cliente WHERE id_cliente = p_id_cliente;
  IF v_qt_itens = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente não encontrado.';
  END IF;
  SELECT fl_bloqueado, vl_limite_fiado INTO v_bloqueado, v_limite
    FROM cliente WHERE id_cliente = p_id_cliente FOR UPDATE;
  IF v_bloqueado = 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fiado permitido somente para cliente conhecido e autorizado pela gerência.';
  END IF;
  IF p_vl_fiado <= 0 OR p_dt_vencimento < CURRENT_DATE() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valor do fiado deve ser positivo e vencimento não pode estar no passado.';
  END IF;

  SELECT COALESCE(SUM(vl_total - vl_pago),0) INTO v_saldo_aberto
    FROM fiado WHERE id_cliente = p_id_cliente AND st_fiado = 'ABERTO';
  IF v_saldo_aberto + p_vl_fiado > v_limite THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fiado recusado: valor ultrapassa o limite disponível do cliente.';
  END IF;

  SELECT COUNT(*) INTO v_tem_fiado FROM fiado WHERE id_venda = p_id_venda;
  SELECT COUNT(*) INTO v_tem_pagamento_fiado FROM pagamento WHERE id_venda = p_id_venda AND tp_forma = 'FIADO';
  IF v_tem_fiado > 0 OR v_tem_pagamento_fiado > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esta venda já possui lançamento de fiado.';
  END IF;

  SELECT COALESCE(SUM(vl_pago),0) INTO v_pagamentos
    FROM pagamento WHERE id_venda = p_id_venda AND tp_forma <> 'FIADO';
  IF ABS((v_pagamentos + p_vl_fiado) - v_total) > 0.01 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pagamentos comuns mais a parte fiada devem ser iguais ao total da venda.';
  END IF;
  SELECT COUNT(*), COALESCE(SUM(vl_subtotal),0) INTO v_qt_itens, v_soma_itens
    FROM item_venda WHERE id_venda = p_id_venda;
  IF v_qt_itens = 0 OR ABS((v_soma_itens - v_desconto) - v_total) > 0.01 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Itens, desconto e total da venda não conferem.';
  END IF;
  IF p_vl_fiado > v_soma_itens THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Parte fiada não pode superar a soma dos itens.';
  END IF;

  INSERT INTO fiado (id_venda, id_cliente, dt_vencimento, vl_total, vl_pago)
  VALUES (p_id_venda, p_id_cliente, p_dt_vencimento, p_vl_fiado, 0.00);

  SET v_restante = p_vl_fiado;
  SET v_done = 0;
  OPEN cur_itens;
  alocar: LOOP
    FETCH cur_itens INTO v_id_item, v_subtotal;
    IF v_done = 1 THEN LEAVE alocar; END IF;
    IF v_restante > 0 THEN
      SET v_alocado = LEAST(v_subtotal, v_restante);
      IF v_alocado > 0 THEN
        INSERT INTO item_fiado (id_item_venda, vl_fiado) VALUES (v_id_item, v_alocado);
        SET v_restante = v_restante - v_alocado;
      END IF;
    END IF;
  END LOOP;
  CLOSE cur_itens;
  IF v_restante > 0.01 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não foi possível distribuir o valor fiado entre os itens.';
  END IF;
  INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES (p_id_venda, 'FIADO', p_vl_fiado);
  COMMIT;
END$$

CREATE PROCEDURE sp_validar_pagamentos_venda(IN p_id_venda BIGINT UNSIGNED)
BEGIN
  DECLARE v_total DECIMAL(10,2) DEFAULT NULL;
  DECLARE v_soma DECIMAL(12,2) DEFAULT 0.00;
  DECLARE v_fiado DECIMAL(12,2) DEFAULT 0.00;
  DECLARE v_fiado_conta DECIMAL(10,2) DEFAULT 0.00;
  DECLARE v_itens DECIMAL(12,2) DEFAULT 0.00;
  DECLARE v_desconto DECIMAL(10,2) DEFAULT 0.00;
  SELECT vl_total, vl_desconto INTO v_total, v_desconto
    FROM venda WHERE id_venda = p_id_venda AND st_venda = 'CONCLUIDA';
  IF v_total IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Venda inexistente ou não concluída.';
  END IF;
  SELECT COALESCE(SUM(vl_pago),0) INTO v_soma FROM pagamento WHERE id_venda = p_id_venda;
  IF ABS(v_soma - v_total) > 0.01 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A soma dos pagamentos ainda não corresponde ao total da venda.';
  END IF;
  SELECT COALESCE(SUM(vl_pago),0) INTO v_fiado FROM pagamento WHERE id_venda = p_id_venda AND tp_forma = 'FIADO';
  SELECT COALESCE(MAX(vl_total),0) INTO v_fiado_conta FROM fiado WHERE id_venda = p_id_venda;
  IF ABS(v_fiado - v_fiado_conta) > 0.01 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valor de pagamento FIADO não confere com a conta de fiado.';
  END IF;
  SELECT COALESCE(SUM(vl_fiado),0) INTO v_itens
    FROM item_fiado x JOIN item_venda i ON i.id_item_venda = x.id_item_venda
   WHERE i.id_venda = p_id_venda;
  IF ABS(v_itens - v_fiado_conta) > 0.01 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Distribuição do fiado entre os itens não confere com o total da conta.';
  END IF;
END$$

CREATE PROCEDURE sp_fechar_caixa(
  IN p_id_caixa INT UNSIGNED,
  IN p_vl_contado DECIMAL(10,2)
)
BEGIN
  DECLARE v_troco DECIMAL(10,2) DEFAULT 0.00;
  DECLARE v_vendas_dinheiro DECIMAL(12,2) DEFAULT 0.00;
  DECLARE v_fiados_dinheiro DECIMAL(12,2) DEFAULT 0.00;
  DECLARE v_suprimentos DECIMAL(12,2) DEFAULT 0.00;
  DECLARE v_saidas DECIMAL(12,2) DEFAULT 0.00;
  DECLARE v_esperado DECIMAL(12,2) DEFAULT 0.00;
  DECLARE v_aberto INT DEFAULT 0;
  DECLARE v_vendas_pendentes INT DEFAULT 0;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
  IF p_vl_contado < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valor contado não pode ser negativo.';
  END IF;
  START TRANSACTION;
  SELECT COUNT(*) INTO v_aberto FROM caixa WHERE id_caixa = p_id_caixa AND st_caixa = 'ABERTO';
  IF v_aberto = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Caixa inexistente ou já fechado.';
  END IF;
  SELECT vl_troco_inicial INTO v_troco FROM caixa WHERE id_caixa = p_id_caixa FOR UPDATE;
  SELECT COUNT(*) INTO v_vendas_pendentes
    FROM venda v
   WHERE v.id_caixa = p_id_caixa AND v.st_venda = 'CONCLUIDA'
     AND ABS(v.vl_total - (SELECT COALESCE(SUM(p.vl_pago),0) FROM pagamento p WHERE p.id_venda = v.id_venda)) > 0.01;
  IF v_vendas_pendentes > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não é possível fechar o caixa: há venda com pagamento incompleto.';
  END IF;
  SELECT COALESCE(SUM(p.vl_pago),0) INTO v_vendas_dinheiro
    FROM pagamento p JOIN venda v ON v.id_venda = p.id_venda
   WHERE v.id_caixa = p_id_caixa AND v.st_venda = 'CONCLUIDA' AND p.tp_forma = 'DINHEIRO';
  SELECT COALESCE(SUM(vl_pago),0) INTO v_fiados_dinheiro
    FROM pagamento_fiado WHERE id_caixa = p_id_caixa AND tp_forma = 'DINHEIRO';
  SELECT COALESCE(SUM(CASE WHEN tp_movimento = 'SUPRIMENTO' THEN vl_movimento ELSE 0 END),0),
         COALESCE(SUM(CASE WHEN tp_movimento IN ('SANGRIA','DESPESA') THEN vl_movimento ELSE 0 END),0)
    INTO v_suprimentos, v_saidas FROM movimentacao_caixa WHERE id_caixa = p_id_caixa;
  SET v_esperado = v_troco + v_vendas_dinheiro + v_fiados_dinheiro + v_suprimentos - v_saidas;
  IF v_esperado < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cálculo do caixa resultou em valor negativo; confira as movimentações.';
  END IF;
  UPDATE caixa SET vl_esperado = v_esperado, vl_contado = p_vl_contado,
                   dt_fechamento = CURRENT_TIMESTAMP, st_caixa = 'FECHADO'
   WHERE id_caixa = p_id_caixa;
  COMMIT;
END$$

DELIMITER ;
