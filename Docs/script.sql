-- =====================================================================
-- Projeto Adega - script de criação do banco (MySQL 8.0)

-- =====================================================================

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Item comercializado. Pode ser vendido fechado (unidade) ou em doses.';

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Saldo atual de cada produto (relação 1:1 com PRODUTO). Atualizado via Trigger.';

CREATE TABLE funcionario (
  id_funcionario INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador do funcionário',
  nm_funcionario VARCHAR(100) NOT NULL COMMENT 'Nome completo',
  nr_cpf CHAR(11) NOT NULL COMMENT 'CPF do funcionário (dado pessoal, LGPD)',
  tp_cargo ENUM('ATENDENTE','GERENTE') NOT NULL COMMENT 'Perfil de acesso no sistema',
  ds_login VARCHAR(40) NOT NULL COMMENT 'Nome de usuário para entrar no sistema',
  ds_senha_hash VARCHAR(255) NOT NULL COMMENT 'Hash da senha',
  dt_admissao DATE NOT NULL COMMENT 'Data de entrada na adega',
  fl_ativo TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Indica se o funcionário ainda atua',
  PRIMARY KEY (id_funcionario),
  UNIQUE KEY uq_funcionario_nr_cpf (nr_cpf),
  UNIQUE KEY uq_funcionario_ds_login (ds_login)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Pessoa da equipe que usa o sistema.';

CREATE TABLE escala (
  id_escala INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador do turno',
  id_funcionario INT UNSIGNED NOT NULL COMMENT 'Funcionário escalado',
  dt_turno DATE NOT NULL COMMENT 'Dia do turno',
  hr_inicio TIME NOT NULL COMMENT 'Hora de início',
  hr_fim TIME NOT NULL COMMENT 'Hora de término',
  ds_funcao VARCHAR(40) NOT NULL COMMENT 'Função exercida no turno',
  PRIMARY KEY (id_escala),
  UNIQUE KEY uq_escala_turno (id_funcionario, dt_turno, hr_inicio),
  CONSTRAINT fk_escala_id_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario (id_funcionario),
  CONSTRAINT chk_escala_horario CHECK (hr_fim <> hr_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Turno de trabalho de um funcionário.';

CREATE TABLE cliente (
  id_cliente INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador do cliente',
  nm_cliente VARCHAR(100) NOT NULL COMMENT 'Nome completo',
  nr_cpf CHAR(11) NOT NULL COMMENT 'CPF do cliente (LGPD)',
  dt_nascimento DATE NOT NULL COMMENT 'Data de nascimento, para comprovar maioridade',
  nr_telefone VARCHAR(15) NOT NULL COMMENT 'Telefone com DDD',
  vl_limite_fiado DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Limite de saldo devedor autorizado',
  fl_bloqueado TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Indica se o cliente está impedido de comprar fiado',
  fl_fiado_autorizado TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Indica se o cliente tem autorização para compra fiada',
  dt_consentimento_lgpd DATETIME NOT NULL COMMENT 'Momento em que o cliente consentiu o uso dos dados',
  dt_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora do cadastro',
  PRIMARY KEY (id_cliente),
  UNIQUE KEY uq_cliente_nr_cpf (nr_cpf),
  CONSTRAINT chk_cliente_limite CHECK (vl_limite_fiado >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Cliente cadastrado para compras.';

CREATE TABLE caixa (
  id_caixa INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador da sessão de caixa',
  id_funcionario INT UNSIGNED NOT NULL COMMENT 'Funcionário responsável',
  dt_abertura DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora de abertura',
  dt_fechamento DATETIME NULL COMMENT 'Data e hora de fechamento',
  vl_troco_inicial DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Troco inicial',
  vl_esperado DECIMAL(10,2) NULL COMMENT 'Dinheiro esperado no fechamento',
  vl_contado DECIMAL(10,2) NULL COMMENT 'Dinheiro contado fisicamente',
  vl_diferenca DECIMAL(10,2) AS (vl_contado - vl_esperado) STORED COMMENT 'Diferença de caixa',
  st_caixa ENUM('ABERTO','FECHADO') NOT NULL DEFAULT 'ABERTO' COMMENT 'Situação da sessão',
  ds_observacao VARCHAR(255) NULL COMMENT 'Justificativa de diferenças',
  PRIMARY KEY (id_caixa),
  CONSTRAINT fk_caixa_id_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario (id_funcionario),
  CONSTRAINT chk_caixa_fechamento CHECK ((st_caixa = 'ABERTO' AND dt_fechamento IS NULL) OR (st_caixa = 'FECHADO' AND dt_fechamento IS NOT NULL AND vl_contado IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Sessão de caixa.';

CREATE TABLE venda (
  id_venda BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador da venda',
  id_funcionario INT UNSIGNED NOT NULL COMMENT 'Funcionário que realizou a venda',
  id_caixa INT UNSIGNED NOT NULL COMMENT 'Caixa aberto',
  dt_venda DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora da venda',
  vl_desconto DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Desconto concedido',
  vl_total DECIMAL(10,2) NOT NULL COMMENT 'Valor total cobrado',
  st_venda ENUM('CONCLUIDA','CANCELADA') NOT NULL DEFAULT 'CONCLUIDA' COMMENT 'Situação',
  nr_documento_fiscal VARCHAR(44) NULL COMMENT 'Nota fiscal',
  fl_maioridade_conferida TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Maioridade conferida',
  PRIMARY KEY (id_venda),
  CONSTRAINT fk_venda_id_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario (id_funcionario),
  CONSTRAINT fk_venda_id_caixa FOREIGN KEY (id_caixa) REFERENCES caixa (id_caixa),
  CONSTRAINT chk_venda_valores CHECK (vl_desconto >= 0 AND vl_total >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Venda feita no balcão.';

CREATE TABLE fiado (
  id_fiado INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador do fiado',
  id_venda BIGINT UNSIGNED NOT NULL COMMENT 'Venda de origem',
  id_cliente INT UNSIGNED NOT NULL COMMENT 'Cliente devedor',
  dt_abertura DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de abertura',
  dt_vencimento DATE NOT NULL COMMENT 'Data limite',
  vl_total DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Total lançado',
  vl_pago DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Total já pago',
  st_fiado ENUM('ABERTO','QUITADO') NOT NULL DEFAULT 'ABERTO' COMMENT 'Situação',
  PRIMARY KEY (id_fiado),
  UNIQUE KEY uq_fiado_id_venda (id_venda),
  CONSTRAINT fk_fiado_id_venda FOREIGN KEY (id_venda) REFERENCES venda (id_venda),
  CONSTRAINT fk_fiado_id_cliente FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
  CONSTRAINT chk_fiado_valores CHECK (vl_pago >= 0 AND vl_total >= 0 AND vl_pago <= vl_total)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Conta de fiado corrigida (sem valores negativos e com validação de quitação).';

CREATE TABLE item_venda (
  id_item_venda BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador do item',
  id_venda BIGINT UNSIGNED NOT NULL COMMENT 'Venda',
  id_produto INT UNSIGNED NOT NULL COMMENT 'Produto',
  tp_item ENUM('UNIDADE','DOSE') NOT NULL DEFAULT 'UNIDADE' COMMENT 'Tipo',
  qt_item SMALLINT UNSIGNED NOT NULL COMMENT 'Quantidade',
  vl_unitario DECIMAL(10,2) NOT NULL COMMENT 'Preço unitário',
  vl_subtotal DECIMAL(12,2) AS (qt_item * vl_unitario) STORED COMMENT 'Subtotal',
  PRIMARY KEY (id_item_venda),
  CONSTRAINT fk_item_venda_id_venda FOREIGN KEY (id_venda) REFERENCES venda (id_venda),
  CONSTRAINT fk_item_venda_id_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto),
  CONSTRAINT chk_item_venda_qt CHECK (qt_item > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Itens da venda.';

CREATE TABLE pagamento (
  id_pagamento BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador',
  id_venda BIGINT UNSIGNED NOT NULL COMMENT 'Venda',
  tp_forma ENUM('DINHEIRO','PIX','DEBITO','CREDITO','FIADO') NOT NULL COMMENT 'Forma',
  vl_pago DECIMAL(10,2) NOT NULL COMMENT 'Valor',
  dt_pagamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data',
  PRIMARY KEY (id_pagamento),
  CONSTRAINT fk_pagamento_id_venda FOREIGN KEY (id_venda) REFERENCES venda (id_venda),
  CONSTRAINT chk_pagamento_valor CHECK (vl_pago > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Pagamentos da venda.';

CREATE TABLE item_fiado (
  id_item_fiado BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador',
  id_item_venda BIGINT UNSIGNED NOT NULL COMMENT 'Item da venda original',
  dt_lancamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data',
  PRIMARY KEY (id_item_fiado),
  UNIQUE KEY uq_item_fiado_id_item_venda (id_item_venda),
  CONSTRAINT fk_item_fiado_id_item_venda FOREIGN KEY (id_item_venda) REFERENCES item_venda (id_item_venda)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Itens atrelados ao fiado via item_venda.';

CREATE TABLE pagamento_fiado (
  id_pagamento_fiado BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador',
  id_fiado INT UNSIGNED NOT NULL COMMENT 'Fiado',
  id_caixa INT UNSIGNED NOT NULL COMMENT 'Caixa',
  tp_forma ENUM('DINHEIRO','PIX','DEBITO','CREDITO') NOT NULL COMMENT 'Forma',
  vl_pago DECIMAL(10,2) NOT NULL COMMENT 'Valor',
  dt_pagamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data',
  PRIMARY KEY (id_pagamento_fiado),
  CONSTRAINT fk_pagamento_fiado_id_fiado FOREIGN KEY (id_fiado) REFERENCES fiado (id_fiado),
  CONSTRAINT fk_pagamento_fiado_id_caixa FOREIGN KEY (id_caixa) REFERENCES caixa (id_caixa),
  CONSTRAINT chk_pagamento_fiado_valor CHECK (vl_pago > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Recebimentos de fiado.';

CREATE TABLE fornecedor (
  id_fornecedor INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador',
  nm_fornecedor VARCHAR(100) NOT NULL COMMENT 'Nome',
  nr_cnpj CHAR(14) NOT NULL COMMENT 'CNPJ',
  nr_telefone VARCHAR(15) NULL COMMENT 'Telefone',
  tp_fornecimento ENUM('ENTREGA','RETIRADA','AMBOS') NOT NULL COMMENT 'Tipo',
  fl_ativo TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Ativo',
  PRIMARY KEY (id_fornecedor),
  UNIQUE KEY uq_fornecedor_nr_cnpj (nr_cnpj)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Fornecedores.';

CREATE TABLE compra (
  id_compra INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador',
  id_fornecedor INT UNSIGNED NOT NULL COMMENT 'Fornecedor',
  id_funcionario INT UNSIGNED NOT NULL COMMENT 'Funcionário',
  dt_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data pedido',
  dt_recebimento DATETIME NULL COMMENT 'Data recebimento',
  tp_recebimento ENUM('ENTREGA','RETIRADA') NOT NULL COMMENT 'Tipo',
  nr_nota_fiscal VARCHAR(44) NULL COMMENT 'NF',
  vl_total DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Total',
  st_compra ENUM('PEDIDO','RECEBIDA','RECEBIDA_PARCIAL','CANCELADA') NOT NULL DEFAULT 'PEDIDO' COMMENT 'Status',
  PRIMARY KEY (id_compra),
  CONSTRAINT fk_compra_id_fornecedor FOREIGN KEY (id_fornecedor) REFERENCES fornecedor (id_fornecedor),
  CONSTRAINT fk_compra_id_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario (id_funcionario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Compras de fornecedores.';

CREATE TABLE item_compra (
  id_item_compra INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador',
  id_compra INT UNSIGNED NOT NULL COMMENT 'Compra',
  id_produto INT UNSIGNED NOT NULL COMMENT 'Produto',
  qt_pedida INT UNSIGNED NOT NULL COMMENT 'Qtd pedida',
  qt_recebida INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Qtd recebida',
  vl_custo DECIMAL(10,2) NOT NULL COMMENT 'Custo unitário',
  fl_conferido TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Conferido',
  ds_divergencia VARCHAR(200) NULL COMMENT 'Divergência',
  PRIMARY KEY (id_item_compra),
  UNIQUE KEY uq_item_compra_produto (id_compra, id_produto),
  CONSTRAINT fk_item_compra_id_compra FOREIGN KEY (id_compra) REFERENCES compra (id_compra),
  CONSTRAINT fk_item_compra_id_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto),
  CONSTRAINT chk_item_compra_qt CHECK (qt_pedida > 0 AND qt_recebida <= qt_pedida),
  CONSTRAINT chk_item_compra_custo CHECK (vl_custo >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Itens da compra.';

CREATE TABLE lote (
  id_lote INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador',
  id_item_compra INT UNSIGNED NOT NULL COMMENT 'Item de compra',
  nr_lote VARCHAR(30) NULL COMMENT 'Número do lote',
  dt_validade DATE NOT NULL COMMENT 'Validade',
  qt_disponivel INT UNSIGNED NOT NULL COMMENT 'Disponível',
  PRIMARY KEY (id_lote),
  CONSTRAINT fk_lote_id_item_compra FOREIGN KEY (id_item_compra) REFERENCES item_compra (id_item_compra)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Lotes de produtos.';

CREATE TABLE movimentacao_estoque (
  id_movimentacao BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador',
  id_produto INT UNSIGNED NOT NULL COMMENT 'Produto',
  id_funcionario INT UNSIGNED NOT NULL COMMENT 'Funcionário',
  id_lote INT UNSIGNED NULL COMMENT 'Lote',
  tp_movimento ENUM('ENTRADA_COMPRA','SAIDA_VENDA','SAIDA_DOSE','PERDA','DEVOLUCAO_FORNECEDOR','AJUSTE_ENTRADA','AJUSTE_SAIDA') NOT NULL COMMENT 'Tipo',
  qt_movimentada INT UNSIGNED NOT NULL COMMENT 'Quantidade',
  ds_motivo VARCHAR(200) NULL COMMENT 'Motivo',
  dt_movimentacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data',
  PRIMARY KEY (id_movimentacao),
  CONSTRAINT fk_movimentacao_estoque_id_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto),
  CONSTRAINT fk_movimentacao_estoque_id_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario (id_funcionario),
  CONSTRAINT fk_movimentacao_estoque_id_lote FOREIGN KEY (id_lote) REFERENCES lote (id_lote),
  CONSTRAINT chk_mov_qt CHECK (qt_movimentada > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Movimentações de estoque.';

CREATE TABLE log_acesso (
  id_log BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador',
  id_funcionario INT UNSIGNED NULL COMMENT 'Funcionário',
  dt_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data',
  tp_evento ENUM('LOGIN','LOGIN_FALHA','INSERT','UPDATE','DELETE','CONSULTA_DADO_PESSOAL','APROVACAO') NOT NULL COMMENT 'Tipo evento',
  nm_tabela VARCHAR(40) NULL COMMENT 'Tabela',
  id_registro VARCHAR(40) NULL COMMENT 'Registro',
  ds_alteracao JSON NULL COMMENT 'Alteração JSON',
  ds_ip VARCHAR(45) NULL COMMENT 'IP',
  PRIMARY KEY (id_log),
  CONSTRAINT fk_log_acesso_id_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario (id_funcionario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Auditoria.';


-- =====================================================================
-- TRIGGER PARA ATUALIZAÇÃO AUTOMÁTICA DE ESTOQUE (Corrigindo o Ponto 1)
-- =====================================================================
DELIMITER //

CREATE TRIGGER trg_atualiza_estoque_ai
AFTER INSERT ON movimentacao_estoque
FOR EACH ROW
BEGIN
    -- Se for entrada no estoque
    IF NEW.tp_movimento IN ('ENTRADA_COMPRA', 'DEVOLUCAO_FORNECEDOR', 'AJUSTE_ENTRADA') THEN
        UPDATE estoque 
        SET qt_atual = qt_atual + NEW.qt_movimentada 
        WHERE id_produto = NEW.id_produto;
        
    -- Se for saída do estoque
    ELSEIF NEW.tp_movimento IN ('SAIDA_VENDA', 'SAIDA_DOSE', 'PERDA', 'AJUSTE_SAIDA') THEN
        UPDATE estoque 
        SET qt_atual = qt_atual - NEW.qt_movimentada 
        WHERE id_produto = NEW.id_produto;
    END IF;
END//

DELIMITER ;


-- =====================================================================
-- DADOS INICIAIS E EXEMPLOS COMPLETOS DE ENTREGA (Corrigindo o Ponto 5)
-- =====================================================================

INSERT INTO categoria (nm_categoria, fl_restrita_maiores) VALUES
  ('Cerveja', 1),
  ('Destilado', 1),
  ('Vinho', 1),
  ('Tabaco', 1),
  ('Refrigerante e agua', 0),
  ('Petisco e conveniencia', 0);

-- Exemplo de INSERT em Produto e Estoque correspondente
INSERT INTO produto (id_categoria, cd_barras, nm_produto, vl_venda, fl_vende_dose, qt_ml_garrafa, qt_ml_dose, vl_dose) VALUES
  (1, '7891000100102', 'Cerveja Pilsen 600ml', 10.00, 0, NULL, NULL, NULL),
  (2, '7892000200203', 'Uísque 1L', 120.00, 1, 1000, 50, 12.00);

INSERT INTO estoque (id_produto, qt_atual, qt_minima, ds_localizacao) VALUES
  (1, 50, 10, 'Corredor 1, Prateleira A'),
  (2, 12, 3, 'Corredor 2, Cofre');

INSERT INTO funcionario (nm_funcionario, nr_cpf, tp_cargo, ds_login, ds_senha_hash, dt_admissao) VALUES
  ('Carlos Silva', '12345678901', 'GERENTE', 'carlos.gerente', '$2y$10$exemploHashSenhaBcryptSegura123', '2025-01-10'),
  ('Ana Souza', '98765432109', 'ATENDENTE', 'ana.atendente', '$2y$10$exemploHashSenhaBcryptSegura456', '2026-03-15');

INSERT INTO cliente (nm_cliente, nr_cpf, dt_nascimento, nr_telefone, vl_limite_fiado, fl_bloqueado, fl_fiado_autorizado, dt_consentimento_lgpd) VALUES
  ('Marcos Oliveira', '11122233344', '1985-05-20', '11999998888', 300.00, 0, 1, NOW());

INSERT INTO fornecedor (nm_fornecedor, nr_cnpj, nr_telefone, tp_fornecimento) VALUES
  ('Distribuidora de Bebidas Exemplo Ltda', '12345678000199', '1133334444', 'ENTREGA');


-- --- EXEMPLO DE UPDATE ---
UPDATE produto 
SET vl_venda = 11.50 
WHERE id_produto = 1;


-- --- EXEMPLO DE DELETE (Inativação lógica para manter integridade histórica) ---
UPDATE produto 
SET fl_ativo = 0 
WHERE id_produto = 2;


-- --- EXEMPLOS DE SELECT COM JOIN ---
-- 1. Listar produtos com suas categorias e estoque atual
SELECT 
    p.id_produto,
    p.nm_produto,
    c.nm_categoria,
    p.vl_venda,
    e.qt_atual
FROM produto p
INNER JOIN categoria c ON p.id_categoria = c.id_categoria
INNER JOIN estoque e ON p.id_produto = e.id_produto;


-- --- CONSULTAS GERENCIAIS ---
-- Relatório de produtos com estoque abaixo do mínimo
SELECT 
    p.nm_produto,
    e.qt_atual,
    e.qt_minima,
    e.ds_localizacao
FROM estoque e
INNER JOIN produto p ON e.id_produto = p.id_produto
WHERE e.qt_atual <= e.qt_minima;


-- --- CONSULTAS DE AUDITORIA ---
SELECT 
    l.id_log,
    f.nm_funcionario,
    l.dt_evento,
    l.tp_evento,
    l.nm_tabela
FROM log_acesso l
LEFT JOIN funcionario f ON l.id_funcionario = f.id_funcionario
ORDER BY l.dt_evento DESC;
