-- =====================================================================
-- ADEGA - SCRIPT CONSOLIDADO
--
-- Este arquivo reúne a estrutura do banco, as consultas e os exemplos
-- básicos que antes estavam em arquivos separados.
--
-- ORDEM DE EXECUÇÃO:
-- 1) Execute primeiro somente a PARTE 1 - ESTRUTURA DO BANCO (até o
--    marcador FIM DA PARTE 1).
-- 2) Execute o arquivo massa_de_dados.sql para inserir os dados.
-- 3) Depois, execute a PARTE 2 (consultas) e a PARTE 3 (exemplos/testes).
--    Os testes identificados como ERRO devem realmente apresentar erro.
--    Na PARTE 3, execute os testes individualmente (ou configure o cliente SQL
--    para continuar após erros), pois alguns comandos falham de propósito.
--
-- Execute a PARTE 1 em um schema novo/vazio: o script não apaga tabelas
-- antigas e não foi feito para recriar a estrutura por cima de uma já existente.
-- Não execute o arquivo inteiro de uma vez em um banco vazio: as consultas
-- e vários testes dependem dos registros inseridos pela massa de dados.
-- =====================================================================

-- =====================================================================
-- PARTE 1 - ESTRUTURA DO BANCO (tabelas, triggers e procedures)
-- Antes de cada tabela há dois comentários: sua função e seu objetivo.
-- =====================================================================
-- ====================================================================
CREATE DATABASE IF NOT EXISTS adega DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE adega;

-- Tabela CATEGORIA
-- Função: Organiza os produtos da adega em grupos, como bebidas, cigarros e petiscos.
-- Objetivo: Permitir a classificação dos produtos e indicar quando uma categoria exige conferência de maioridade.
CREATE TABLE categoria (
  id_categoria INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador da categoria',
  nm_categoria VARCHAR(60) NOT NULL COMMENT 'Nome da categoria',
  fl_restrita_maiores TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Indica se os produtos da categoria só podem ser vendidos a maiores de 18 anos',
  PRIMARY KEY (id_categoria),
  UNIQUE KEY uq_categoria_nm_categoria (nm_categoria)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Agrupa os produtos da adega e define se a venda é restrita a maiores de 18 anos.';

-- Tabela PRODUTO
-- Função: Armazena o cadastro e as características comerciais de cada produto vendido pela adega.
-- Objetivo: Manter nome, categoria, código de barras, preços e regras de venda por unidade ou dose.
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

-- Tabela ESTOQUE
-- Função: Registra o saldo atual e a quantidade mínima de cada produto.
-- Objetivo: Acompanhar a disponibilidade das mercadorias e indicar quando é necessário repor o estoque.
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

-- Tabela FUNCIONARIO
-- Função: Armazena os dados dos funcionários que utilizam o sistema.
-- Objetivo: Identificar quem realiza as operações e controlar os perfis de acesso de atendente e gerente.
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

-- Tabela ESCALA
-- Função: Registra os turnos, horários e funções de trabalho dos funcionários.
-- Objetivo: Organizar a jornada da equipe e permitir consultar quem trabalhou em cada período.
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

-- Tabela CLIENTE
-- Função: Armazena os dados cadastrais dos clientes, incluindo informações necessárias ao controle de fiado.
-- Objetivo: Identificar clientes e apoiar a análise de autorização, limite e cobrança de compras a prazo, respeitando a LGPD.
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

-- Tabela CAIXA
-- Função: Registra cada sessão de caixa, desde a abertura até o fechamento.
-- Objetivo: Controlar o responsável, o troco inicial e a conferência dos valores esperados e contados.
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

-- Tabela VENDA
-- Função: Armazena os dados gerais de cada venda realizada no balcão.
-- Objetivo: Registrar data, funcionário, caixa, valores, situação e confirmação de maioridade quando necessária.
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

-- Tabela FIADO
-- Função: Registra uma conta a prazo originada por uma venda e vinculada a um cliente.
-- Objetivo: Acompanhar vencimento, valor total, pagamentos recebidos e saldo devedor do cliente.
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

-- Tabela ITEM_VENDA
-- Função: Detalha os produtos, quantidades e preços que compõem cada venda.
-- Objetivo: Guardar os itens vendidos e o preço praticado no momento da compra, incluindo lote ou garrafa quando aplicável.
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

-- Tabela PAGAMENTO
-- Função: Registra cada pagamento associado a uma venda.
-- Objetivo: Informar quanto foi pago em cada forma de pagamento e permitir que uma venda seja quitada por mais de uma forma.
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

-- Tabela ITEM_FIADO
-- Função: Identifica os itens da venda e os valores de cada item destinados ao fiado.
-- Objetivo: Detalhar quais produtos e parcelas compõem a dívida vinculada à venda.
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

-- Tabela PAGAMENTO_FIADO
-- Função: Registra os recebimentos feitos para quitar, total ou parcialmente, uma conta de fiado.
-- Objetivo: Controlar cada abatimento da dívida, sua forma de pagamento e o caixa que recebeu o valor.
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

-- Tabela FORNECEDOR
-- Função: Armazena o cadastro das empresas que fornecem mercadorias à adega.
-- Objetivo: Manter os dados de contato e a modalidade de fornecimento para organizar as compras.
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

-- Tabela COMPRA
-- Função: Registra os pedidos de mercadorias feitos aos fornecedores.
-- Objetivo: Acompanhar responsável, datas, recebimento, nota fiscal, valor total e situação de cada compra.
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

-- Tabela ITEM_COMPRA
-- Função: Detalha os produtos e as quantidades que fazem parte de cada compra.
-- Objetivo: Controlar quantidades pedidas e recebidas, custo unitário e conferência de divergências.
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

-- Tabela NOTA_FISCAL
-- Função: Armazena os dados de identificação e controle dos documentos fiscais de entrada e saída.
-- Objetivo: Relacionar cada documento a uma compra ou venda e permitir consultar número, série, chave de acesso, emissão, valor e situação.
-- Observação: Esta tabela registra documentos; não emite NF-e/NFC-e nem consulta ou autoriza documentos na SEFAZ.
CREATE TABLE nota_fiscal (
  id_nota_fiscal BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador interno do documento fiscal',
  tp_operacao ENUM('ENTRADA','SAIDA') NOT NULL COMMENT 'Indica se o documento acompanha uma compra ou uma venda',
  tp_modelo ENUM('NF_E','NFC_E','CUPOM_FISCAL','OUTRO') NOT NULL DEFAULT 'OUTRO' COMMENT 'Modelo do documento fiscal',
  nr_numero VARCHAR(44) NOT NULL COMMENT 'Número ou identificador informado no documento',
  nr_serie VARCHAR(10) NULL COMMENT 'Série do documento fiscal, quando aplicável',
  cd_chave_acesso CHAR(44) NULL COMMENT 'Chave de acesso de 44 dígitos, quando disponível',
  dt_emissao DATETIME NULL COMMENT 'Data e hora de emissão informadas no documento',
  vl_total DECIMAL(12,2) NOT NULL COMMENT 'Valor total registrado no documento',
  st_documento ENUM('SEM_VALIDACAO','AUTORIZADA','CANCELADA','DENEGADA') NOT NULL DEFAULT 'SEM_VALIDACAO' COMMENT 'Situação de controle; autorização deve ser confirmada externamente',
  ds_observacao VARCHAR(255) NULL COMMENT 'Observações sobre o documento fiscal',
  id_compra INT UNSIGNED NULL COMMENT 'Compra relacionada, para documento de entrada',
  id_venda BIGINT UNSIGNED NULL COMMENT 'Venda relacionada, para documento de saída',
  dt_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora do registro no sistema',
  PRIMARY KEY (id_nota_fiscal),
  UNIQUE KEY uq_nota_fiscal_compra (id_compra),
  UNIQUE KEY uq_nota_fiscal_venda (id_venda),
  UNIQUE KEY uq_nota_fiscal_chave_acesso (cd_chave_acesso),
  KEY idx_nota_fiscal_operacao_data (tp_operacao, dt_emissao),
  CONSTRAINT fk_nota_fiscal_id_compra FOREIGN KEY (id_compra) REFERENCES compra (id_compra),
  CONSTRAINT fk_nota_fiscal_id_venda FOREIGN KEY (id_venda) REFERENCES venda (id_venda),
  CONSTRAINT chk_nota_fiscal_origem CHECK (
    (tp_operacao = 'ENTRADA' AND id_compra IS NOT NULL AND id_venda IS NULL)
    OR
    (tp_operacao = 'SAIDA' AND id_compra IS NULL AND id_venda IS NOT NULL)
  ),
  CONSTRAINT chk_nota_fiscal_valor CHECK (vl_total >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Cadastro e controle interno de documentos fiscais vinculados a compras ou vendas.';

-- Tabela LOTE
-- Função: Armazena os lotes recebidos de produtos que possuem controle de validade.
-- Objetivo: Rastrear a origem, a data de vencimento e a quantidade disponível de cada lote.
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

-- Tabela MOVIMENTACAO_ESTOQUE
-- Função: Registra as entradas, saídas, perdas, devoluções e ajustes do estoque.
-- Objetivo: Manter o histórico das alterações de quantidade para permitir controle e auditoria do estoque.
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



-- Tabela GARRAFA_ABERTA
-- Função: Controla as garrafas abertas que são utilizadas para vender doses.
-- Objetivo: Acompanhar o volume inicial e restante de cada garrafa e identificar sua situação.
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

-- Tabela MOVIMENTACAO_CAIXA
-- Função: Registra entradas e saídas de dinheiro do caixa que não são pagamentos diretos de vendas.
-- Objetivo: Controlar suprimentos, sangrias e despesas para apoiar a conferência e o fechamento do caixa.
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

-- Tabela LOG_ACESSO
-- Função: Armazena eventos e operações realizados pelos usuários no sistema.
-- Objetivo: Permitir auditoria de acessos e alterações, identificando o funcionário, a tabela e o registro envolvidos, inclusive para apoio à LGPD.
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


-- =====================================================================
-- FIM DA PARTE 1 - ESTRUTURA DO BANCO
-- =====================================================================

-- =====================================================================
-- PARTE 2 - CONSULTAS DO BANCO (antigo arquivo criacao_banco.sql)
-- Execute esta parte depois de carregar massa_de_dados.sql.
-- =====================================================================

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
-- CONTROLE DE NOTAS FISCAIS
-- Os itens e produtos continuam detalhados em ITEM_COMPRA e ITEM_VENDA.
-- A tabela NOTA_FISCAL guarda os dados gerais do documento e sua ligação à operação.

-- Documentos fiscais de entrada (compras e respectivos fornecedores).
SELECT nf.id_nota_fiscal, nf.tp_modelo, nf.nr_numero, nf.nr_serie,
       nf.cd_chave_acesso, nf.dt_emissao, nf.vl_total, nf.st_documento,
       c.id_compra, f.nm_fornecedor
  FROM nota_fiscal AS nf
  JOIN compra AS c ON c.id_compra = nf.id_compra
  JOIN fornecedor AS f ON f.id_fornecedor = c.id_fornecedor
 WHERE nf.tp_operacao = 'ENTRADA'
 ORDER BY nf.id_nota_fiscal;

-- Documentos fiscais de saída (vendas e respectivos caixas/funcionários).
SELECT nf.id_nota_fiscal, nf.tp_modelo, nf.nr_numero, nf.nr_serie,
       nf.cd_chave_acesso, nf.dt_emissao, nf.vl_total, nf.st_documento,
       v.id_venda, v.dt_venda, v.id_caixa, v.id_funcionario
  FROM nota_fiscal AS nf
  JOIN venda AS v ON v.id_venda = nf.id_venda
 WHERE nf.tp_operacao = 'SAIDA'
 ORDER BY nf.id_nota_fiscal;

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

-- =====================================================================
-- PARTE 3 - EXEMPLOS BÁSICOS E TESTES (antigo exemplos_basicos.sql)
-- Execute esta parte depois de carregar massa_de_dados.sql.
-- Os testes de violações foram escritos para gerar os erros descritos.
-- Execute um por vez; erros esperados não significam falha da estrutura.
-- =====================================================================

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
INSERT INTO venda (id_funcionario, id_caixa, vl_total, fl_maioridade_conferida) VALUES (2, 91, 10.00, 1);
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
-- A procedure executa COMMIT internamente; por isso usamos um caixa exclusivo do teste,
-- sem alterar o caixa 91, que será utilizado nos testes seguintes.
INSERT INTO caixa (id_funcionario, vl_troco_inicial) VALUES (4, 0.00);
SET @caixa_teste = LAST_INSERT_ID();
SET @id_funcionario_logado = 4;
CALL sp_fechar_caixa(@caixa_teste, 150.00);
SELECT st_caixa, vl_esperado, vl_contado, vl_diferenca
FROM caixa WHERE id_caixa = @caixa_teste;
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
VALUES (2, 27, 'UNIDADE', 0, 5.00);

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

-- T26 — TRIGGER: impedir aumento do volume restante da garrafa
-- Esperado: ERRO 1644 (trigger): 'Dados da garrafa não podem ser aumentados ou trocados; registre nova abertura.'
UPDATE garrafa_aberta SET qt_ml_restante = qt_ml_inicial + 1 WHERE id_garrafa_aberta = 1;

-- T27 — NOT NULL: cliente sem CPF
-- Esperado: ERRO 1048 (Column 'nr_cpf' cannot be null)
INSERT INTO cliente (nm_cliente, nr_cpf, dt_nascimento, nr_telefone, dt_consentimento_lgpd)
VALUES ('Cliente sem CPF', NULL, '1990-01-01', '11900000002', '2026-11-01 10:00:00');

-- T28 — Coluna calculada não aceita valor digitado
-- Esperado: ERRO 3105 (The value specified for generated column 'vl_subtotal' ... is not allowed)
INSERT INTO item_venda (id_venda, id_produto, tp_item, qt_item, vl_unitario, vl_subtotal)
VALUES (2, 27, 'UNIDADE', 1, 5.00, 999.00);

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
INSERT INTO venda (id_funcionario, id_caixa, vl_total, fl_maioridade_conferida) VALUES (2, 91, 10.00, 1);
SET @v = LAST_INSERT_ID();
INSERT INTO item_venda (id_venda, id_produto, tp_item, qt_item, vl_unitario) VALUES (@v, 27, 'UNIDADE', 1, 10.00);
INSERT INTO pagamento (id_venda, tp_forma, vl_pago) VALUES (@v, 'FIADO', 10.00);
ROLLBACK;

-- T38 — Autorizar fiado sendo atendente (só gerente pode)
-- Esperado: 'Somente gerente pode autorizar cliente para fiado.'
SET @id_funcionario_logado = 2;
CALL sp_autorizar_cliente_fiado(4, 100.00);
SET @id_funcionario_logado = 1;

-- T39 — Fiado para cliente bloqueado (cliente 4 está bloqueado por fiado vencido)
-- Esperado: 'Fiado permitido somente para cliente conhecido e autorizado pela gerência.'
START TRANSACTION;
INSERT INTO venda (id_funcionario, id_caixa, vl_total, fl_maioridade_conferida) VALUES (2, 91, 10.00, 1);
SET @v = LAST_INSERT_ID();
INSERT INTO item_venda (id_venda, id_produto, tp_item, qt_item, vl_unitario) VALUES (@v, 27, 'UNIDADE', 1, 10.00);
CALL sp_registrar_venda_fiado(@v, 4, DATE_ADD(CURDATE(), INTERVAL 30 DAY), 10.00);
ROLLBACK;

-- T40 — Fiado acima do limite do cliente (cliente 12 tem limite 100,00)
-- Esperado: 'Fiado recusado: valor ultrapassa o limite disponível do cliente.'
START TRANSACTION;
INSERT INTO venda (id_funcionario, id_caixa, vl_total, fl_maioridade_conferida) VALUES (2, 91, 500.00, 1);
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
