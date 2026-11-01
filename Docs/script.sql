-- Adega do Tonho — modelo lógico revisado
-- MySQL 8.0.16+ (CHECK constraints e JSON).
-- 18 entidades de negócio + log_auditoria como tabela técnica de apoio.
-- Exemplos e dados do projeto não devem conter informações pessoais reais.

-- Editor online: usa o banco de dados que a plataforma já selecionou.


CREATE TABLE categoria (
  id_categoria INT AUTO_INCREMENT PRIMARY KEY,
  nm_categoria VARCHAR(80) NOT NULL UNIQUE,
  fl_restrita_maiores BOOLEAN NOT NULL DEFAULT FALSE
) ENGINE=InnoDB;
CREATE TABLE produto (
  id_produto INT AUTO_INCREMENT PRIMARY KEY,
  id_categoria INT NOT NULL,
  cd_barras VARCHAR(32) NULL UNIQUE,
  nm_produto VARCHAR(140) NOT NULL,
  vl_venda DECIMAL(10,2) NOT NULL,
  fl_vende_dose BOOLEAN NOT NULL DEFAULT FALSE,
  qt_ml_garrafa DECIMAL(10,2) NULL,
  qt_ml_dose DECIMAL(10,2) NULL,
  vl_dose DECIMAL(10,2) NULL,
  fl_ativo BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_produto_categoria FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria),
  CONSTRAINT ck_produto_vl_venda CHECK (vl_venda >= 0),
  CONSTRAINT ck_produto_dose CHECK (
    (fl_vende_dose = FALSE AND qt_ml_garrafa IS NULL AND qt_ml_dose IS NULL AND vl_dose IS NULL)
    OR (fl_vende_dose = TRUE AND qt_ml_garrafa > 0 AND qt_ml_dose > 0 AND vl_dose >= 0)
  ),
  INDEX ix_produto_nome (nm_produto)
) ENGINE=InnoDB;
CREATE TABLE estoque (
  id_estoque INT AUTO_INCREMENT PRIMARY KEY,
  id_produto INT NOT NULL UNIQUE,
  qt_atual DECIMAL(12,3) NOT NULL DEFAULT 0,
  qt_minima DECIMAL(12,3) NOT NULL DEFAULT 0,
  ds_localizacao VARCHAR(120) NULL,
  dt_atualizacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_estoque_produto FOREIGN KEY (id_produto) REFERENCES produto(id_produto),
  CONSTRAINT ck_estoque_saldo CHECK (qt_atual >= 0),
  CONSTRAINT ck_estoque_minimo CHECK (qt_minima >= 0)
) ENGINE=InnoDB;
CREATE TABLE funcionario (
  id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
  nm_funcionario VARCHAR(140) NOT NULL,
  nr_cpf CHAR(11) NOT NULL UNIQUE,
  tp_cargo ENUM('ATENDENTE','GERENTE') NOT NULL,
  ds_login VARCHAR(80) NOT NULL UNIQUE,
  ds_senha_hash VARCHAR(255) NOT NULL,
  dt_admissao DATE NULL,
  fl_ativo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;
CREATE TABLE fornecedor (
  id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
  nm_fornecedor VARCHAR(160) NOT NULL,
  nr_cnpj CHAR(14) NOT NULL UNIQUE,
  nr_telefone VARCHAR(24) NULL,
  tp_fornecimento ENUM('ENTREGA','RETIRADA','AMBOS') NOT NULL,
  fl_ativo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;
CREATE TABLE caixa (
  id_caixa INT AUTO_INCREMENT PRIMARY KEY,
  id_funcionario_abertura INT NOT NULL,
  dt_abertura DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dt_fechamento DATETIME NULL,
  vl_troco_inicial DECIMAL(10,2) NOT NULL DEFAULT 0,
  vl_esperado DECIMAL(12,2) NULL,
  vl_contado DECIMAL(12,2) NULL,
  vl_diferenca DECIMAL(12,2) NULL,
  st_caixa ENUM('ABERTO','FECHADO') NOT NULL DEFAULT 'ABERTO',
  ds_observacao TEXT NULL,
  CONSTRAINT fk_caixa_funcionario FOREIGN KEY (id_funcionario_abertura) REFERENCES funcionario(id_funcionario),
  CONSTRAINT ck_caixa_troco CHECK (vl_troco_inicial >= 0),
  INDEX ix_caixa_status (st_caixa)
) ENGINE=InnoDB;
CREATE TABLE venda (
  id_venda INT AUTO_INCREMENT PRIMARY KEY,
  id_funcionario INT NOT NULL,
  id_caixa INT NOT NULL,
  dt_venda DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vl_desconto DECIMAL(10,2) NOT NULL DEFAULT 0,
  vl_total DECIMAL(12,2) NOT NULL,
  st_venda ENUM('EM_ABERTO','CONCLUIDA','CANCELADA') NOT NULL DEFAULT 'EM_ABERTO',
  nr_documento_fiscal VARCHAR(60) NULL,
  fl_maioridade_conferida BOOLEAN NOT NULL DEFAULT FALSE,
  CONSTRAINT fk_venda_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario),
  CONSTRAINT fk_venda_caixa FOREIGN KEY (id_caixa) REFERENCES caixa(id_caixa),
  CONSTRAINT ck_venda_valores CHECK (vl_desconto >= 0 AND vl_total >= 0),
  INDEX ix_venda_data (dt_venda),
  INDEX ix_venda_status (st_venda)
) ENGINE=InnoDB;
CREATE TABLE item_venda (
  id_item_venda INT AUTO_INCREMENT PRIMARY KEY,
  id_venda INT NOT NULL,
  id_produto INT NOT NULL,
  tp_item ENUM('UNIDADE','DOSE') NOT NULL,
  qt_item DECIMAL(10,3) NOT NULL,
  vl_unitario DECIMAL(10,2) NOT NULL,
  vl_subtotal DECIMAL(12,2) NOT NULL,
  CONSTRAINT fk_item_venda_venda FOREIGN KEY (id_venda) REFERENCES venda(id_venda),
  CONSTRAINT fk_item_venda_produto FOREIGN KEY (id_produto) REFERENCES produto(id_produto),
  CONSTRAINT ck_item_venda_valores CHECK (qt_item > 0 AND vl_unitario >= 0 AND vl_subtotal >= 0),
  INDEX ix_item_venda_venda (id_venda),
  INDEX ix_item_venda_produto (id_produto)
) ENGINE=InnoDB;
CREATE TABLE cliente (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY,
  nm_cliente VARCHAR(140) NOT NULL,
  nr_cpf CHAR(11) NOT NULL UNIQUE,
  dt_nascimento DATE NOT NULL,
  nr_telefone VARCHAR(24) NULL,
  vl_limite_fiado DECIMAL(10,2) NOT NULL DEFAULT 0,
  fl_bloqueado BOOLEAN NOT NULL DEFAULT FALSE,
  dt_consentimento_lgpd DATETIME NULL,
  dt_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT ck_cliente_limite CHECK (vl_limite_fiado >= 0),
  INDEX ix_cliente_nome (nm_cliente)
) ENGINE=InnoDB;
CREATE TABLE fiado (
  id_fiado INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  dt_abertura DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dt_vencimento DATE NOT NULL,
  vl_total DECIMAL(12,2) NOT NULL,
  vl_pago DECIMAL(12,2) NOT NULL DEFAULT 0,
  st_fiado ENUM('ABERTO','PARCIAL','QUITADO','VENCIDO') NOT NULL DEFAULT 'ABERTO',
  CONSTRAINT fk_fiado_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
  CONSTRAINT ck_fiado_valores CHECK (vl_total >= 0 AND vl_pago >= 0 AND vl_pago <= vl_total),
  INDEX ix_fiado_cliente (id_cliente),
  INDEX ix_fiado_vencimento (dt_vencimento),
  INDEX ix_fiado_status (st_fiado)
) ENGINE=InnoDB;
CREATE TABLE item_fiado (
  id_item_fiado INT AUTO_INCREMENT PRIMARY KEY,
  id_fiado INT NOT NULL,
  id_produto INT NOT NULL,
  tp_item ENUM('UNIDADE','DOSE') NOT NULL,
  qt_item DECIMAL(10,3) NOT NULL,
  vl_unitario DECIMAL(10,2) NOT NULL,
  vl_subtotal DECIMAL(12,2) NOT NULL,
  dt_lancamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_item_fiado_fiado FOREIGN KEY (id_fiado) REFERENCES fiado(id_fiado),
  CONSTRAINT fk_item_fiado_produto FOREIGN KEY (id_produto) REFERENCES produto(id_produto),
  CONSTRAINT ck_item_fiado_valores CHECK (qt_item > 0 AND vl_unitario >= 0 AND vl_subtotal >= 0)
) ENGINE=InnoDB;
CREATE TABLE pagamento (
  id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
  id_venda INT NOT NULL,
  id_fiado INT NULL,
  tp_forma ENUM('PIX','DINHEIRO','CREDITO','DEBITO','FIADO') NOT NULL,
  vl_pago DECIMAL(12,2) NOT NULL,
  dt_pagamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pagamento_venda FOREIGN KEY (id_venda) REFERENCES venda(id_venda),
  CONSTRAINT fk_pagamento_fiado FOREIGN KEY (id_fiado) REFERENCES fiado(id_fiado),
  CONSTRAINT ck_pagamento_valor CHECK (vl_pago > 0)
) ENGINE=InnoDB;
CREATE TABLE pagamento_fiado (
  id_pagamento_fiado INT AUTO_INCREMENT PRIMARY KEY,
  id_fiado INT NOT NULL,
  id_caixa INT NOT NULL,
  tp_forma ENUM('PIX','DINHEIRO','CREDITO','DEBITO') NOT NULL,
  vl_pago DECIMAL(12,2) NOT NULL,
  dt_pagamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pagto_fiado_fiado FOREIGN KEY (id_fiado) REFERENCES fiado(id_fiado),
  CONSTRAINT fk_pagto_fiado_caixa FOREIGN KEY (id_caixa) REFERENCES caixa(id_caixa),
  CONSTRAINT ck_pagto_fiado_valor CHECK (vl_pago > 0),
  INDEX ix_pagamento_fiado_data (dt_pagamento)
) ENGINE=InnoDB;
CREATE TABLE compra (
  id_compra INT AUTO_INCREMENT PRIMARY KEY,
  id_fornecedor INT NOT NULL,
  id_funcionario INT NOT NULL,
  dt_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dt_recebimento DATETIME NULL,
  tp_recebimento ENUM('ENTREGA','RETIRADA') NOT NULL,
  nr_nota_fiscal VARCHAR(60) NULL,
  vl_total DECIMAL(12,2) NOT NULL DEFAULT 0,
  st_compra ENUM('PEDIDA','RECEBIDA_PARCIAL','RECEBIDA','CANCELADA') NOT NULL DEFAULT 'PEDIDA',
  CONSTRAINT fk_compra_fornecedor FOREIGN KEY (id_fornecedor) REFERENCES fornecedor(id_fornecedor),
  CONSTRAINT fk_compra_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario),
  CONSTRAINT ck_compra_total CHECK (vl_total >= 0),
  INDEX ix_compra_data (dt_pedido),
  INDEX ix_compra_status (st_compra)
) ENGINE=InnoDB;
CREATE TABLE item_compra (
  id_item_compra INT AUTO_INCREMENT PRIMARY KEY,
  id_compra INT NOT NULL,
  id_produto INT NOT NULL,
  qt_pedida DECIMAL(12,3) NOT NULL,
  qt_recebida DECIMAL(12,3) NOT NULL DEFAULT 0,
  vl_custo DECIMAL(10,2) NOT NULL,
  fl_conferido BOOLEAN NOT NULL DEFAULT FALSE,
  ds_divergencia TEXT NULL,
  CONSTRAINT fk_item_compra_compra FOREIGN KEY (id_compra) REFERENCES compra(id_compra),
  CONSTRAINT fk_item_compra_produto FOREIGN KEY (id_produto) REFERENCES produto(id_produto),
  CONSTRAINT ck_item_compra_qt CHECK (qt_pedida > 0 AND qt_recebida >= 0 AND qt_recebida <= qt_pedida),
  CONSTRAINT ck_item_compra_custo CHECK (vl_custo >= 0),
  INDEX ix_item_compra_compra (id_compra),
  INDEX ix_item_compra_produto (id_produto)
) ENGINE=InnoDB;
CREATE TABLE lote (
  id_lote INT AUTO_INCREMENT PRIMARY KEY,
  id_item_compra INT NOT NULL,
  nr_lote VARCHAR(80) NULL,
  dt_validade DATE NOT NULL,
  qt_disponivel DECIMAL(12,3) NOT NULL DEFAULT 0,
  CONSTRAINT fk_lote_item_compra FOREIGN KEY (id_item_compra) REFERENCES item_compra(id_item_compra),
  CONSTRAINT ck_lote_qt CHECK (qt_disponivel >= 0),
  INDEX ix_lote_validade (dt_validade)
) ENGINE=InnoDB;
CREATE TABLE movimentacao_estoque (
  id_movimentacao INT AUTO_INCREMENT PRIMARY KEY,
  id_produto INT NOT NULL,
  id_funcionario INT NOT NULL,
  id_lote INT NULL,
  tp_movimento ENUM('ENTRADA','SAIDA','SAIDA_DOSE','PERDA','QUEBRA','VENCIMENTO','AJUSTE_ENTRADA','AJUSTE_SAIDA') NOT NULL,
  qt_movimentada DECIMAL(12,3) NOT NULL,
  ds_motivo VARCHAR(255) NOT NULL,
  dt_movimentacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_mov_produto FOREIGN KEY (id_produto) REFERENCES produto(id_produto),
  CONSTRAINT fk_mov_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario),
  CONSTRAINT fk_mov_lote FOREIGN KEY (id_lote) REFERENCES lote(id_lote),
  CONSTRAINT ck_mov_qt CHECK (qt_movimentada > 0),
  INDEX ix_mov_produto_data (id_produto, dt_movimentacao),
  INDEX ix_mov_lote (id_lote)
) ENGINE=InnoDB;
CREATE TABLE escala (
  id_escala INT AUTO_INCREMENT PRIMARY KEY,
  id_funcionario INT NOT NULL,
  dt_turno DATE NOT NULL,
  hr_inicio TIME NOT NULL,
  hr_fim TIME NOT NULL,
  ds_funcao VARCHAR(100) NOT NULL,
  CONSTRAINT fk_escala_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario),
  INDEX ix_escala_data (dt_turno),
  INDEX ix_escala_funcionario_data (id_funcionario, dt_turno)
) ENGINE=InnoDB;
CREATE TABLE log_auditoria (
  id_log BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_funcionario INT NULL,
  acao VARCHAR(80) NOT NULL,
  entidade VARCHAR(80) NOT NULL,
  id_registro VARCHAR(80) NULL,
  dt_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  detalhes_json JSON NULL,
  usuario_aplicacao VARCHAR(120) NULL,
  CONSTRAINT fk_log_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario) ON DELETE SET NULL,
  INDEX ix_log_hora (dt_hora),
  INDEX ix_log_entidade_registro (entidade, id_registro)
) ENGINE=InnoDB;

