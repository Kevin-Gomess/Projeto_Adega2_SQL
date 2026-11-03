# Modelo Lógico do Banco de Dados — Adega do Tonho

## 1. Apresentação

O modelo lógico representa a estrutura do banco de dados da Adega do Tonho, mostrando como as entidades do modelo conceitual foram transformadas em tabelas.

Cada tabela possui atributos, tipos de dados e chaves. As chaves primárias (PK) identificam cada registro, enquanto as chaves estrangeiras (FK) fazem a ligação entre as tabelas.

O banco foi desenvolvido para MySQL 8.0, utilizando o padrão de nomenclatura snake_case.

## 2. Conversão do modelo conceitual para o lógico

As entidades identificadas no modelo conceitual foram transformadas em tabelas. Seus atributos passaram a ser colunas, e os relacionamentos foram representados por meio de chaves estrangeiras.

Nos relacionamentos 1:N, a chave estrangeira foi colocada na tabela do lado N. Nos relacionamentos N:N, foram utilizadas tabelas associativas para representar a ligação entre os registros.

As tabelas principais do projeto são:

- CATEGORIA
- PRODUTO
- ESTOQUE
- FUNCIONARIO
- ESCALA
- CLIENTE
- CAIXA
- VENDA
- FIADO
- ITEM_VENDA
- PAGAMENTO
- ITEM_FIADO
- PAGAMENTO_FIADO
- FORNECEDOR
- COMPRA
- ITEM_COMPRA
- LOTE
- MOVIMENTACAO_ESTOQUE
- GARRAFA_ABERTA
- MOVIMENTACAO_CAIXA
- LOG_ACESSO

São 21 tabelas: as 18 entidades de negócio do DER conceitual, mais três tabelas de apoio criadas na implementação (GARRAFA_ABERTA, MOVIMENTACAO_CAIXA e LOG_ACESSO). Elas existem para controlar o volume das garrafas abertas para dose, os suprimentos, sangrias e despesas do caixa e a auditoria.

## 3. Estrutura das tabelas

### 3.1 CATEGORIA

- **PK:** id_categoria
- **Atributos:**
  - id_categoria — INT UNSIGNED
  - nm_categoria — VARCHAR(60)
  - fl_restrita_maiores — TINYINT(1)

Armazena as categorias utilizadas para organizar os produtos e indicar se possuem restrição para maiores de idade.

### 3.2 PRODUTO

- **PK:** id_produto
- **FK:** id_categoria → categoria(id_categoria)
- **Atributos:**
  - id_produto — INT UNSIGNED
  - id_categoria — INT UNSIGNED
  - cd_barras — VARCHAR(14)
  - nm_produto — VARCHAR(100)
  - vl_venda — DECIMAL(10,2)
  - fl_controla_validade — TINYINT(1)
  - fl_vende_dose — TINYINT(1)
  - qt_ml_garrafa — SMALLINT UNSIGNED
  - qt_ml_dose — SMALLINT UNSIGNED
  - vl_dose — DECIMAL(10,2)
  - fl_ativo — TINYINT(1)

Armazena os produtos comercializados pela adega, incluindo preços, se o produto exige controle de validade por lote e as informações sobre a venda por dose.

### 3.3 ESTOQUE

- **PK:** id_estoque
- **FK:** id_produto → produto(id_produto)
- **Atributos:**
  - id_estoque — INT UNSIGNED
  - id_produto — INT UNSIGNED
  - qt_atual — INT
  - qt_minima — INT UNSIGNED
  - ds_localizacao — VARCHAR(60)
  - dt_atualizacao — DATETIME

Registra a quantidade atual de cada produto, a quantidade mínima e sua localização. Cada produto possui no máximo um registro de estoque.

### 3.4 FUNCIONARIO

- **PK:** id_funcionario
- **Atributos:**
  - id_funcionario — INT UNSIGNED
  - nm_funcionario — VARCHAR(100)
  - nr_cpf — CHAR(11)
  - tp_cargo — ENUM
  - ds_login — VARCHAR(40)
  - ds_senha_hash — VARCHAR(255)
  - dt_admissao — DATE
  - fl_ativo — TINYINT(1)

Armazena os dados dos funcionários que utilizam o sistema.

### 3.5 ESCALA

- **PK:** id_escala
- **FK:** id_funcionario → funcionario(id_funcionario)
- **Atributos:**
  - id_escala — INT UNSIGNED
  - id_funcionario — INT UNSIGNED
  - dt_turno — DATE
  - hr_inicio — TIME
  - hr_fim — TIME
  - ds_funcao — VARCHAR(40)

Registra os turnos e as funções exercidas pelos funcionários.

### 3.6 CLIENTE

- **PK:** id_cliente
- **Atributos:**
  - id_cliente — INT UNSIGNED
  - nm_cliente — VARCHAR(100)
  - nr_cpf — CHAR(11)
  - dt_nascimento — DATE
  - nr_telefone — VARCHAR(15)
  - vl_limite_fiado — DECIMAL(10,2)
  - fl_bloqueado — TINYINT(1)
  - dt_consentimento_lgpd — DATETIME
  - dt_cadastro — DATETIME

Armazena os dados dos clientes cadastrados, principalmente para o controle das compras realizadas no fiado. O cliente nasce bloqueado (fl_bloqueado = 1) e só pode comprar fiado depois que o gerente o autoriza e define o limite.

### 3.7 CAIXA

- **PK:** id_caixa
- **FK:** id_funcionario → funcionario(id_funcionario)
- **Atributos:**
  - id_caixa — INT UNSIGNED
  - id_funcionario — INT UNSIGNED
  - dt_abertura — DATETIME
  - dt_fechamento — DATETIME
  - vl_troco_inicial — DECIMAL(10,2)
  - vl_esperado — DECIMAL(10,2)
  - vl_contado — DECIMAL(10,2)
  - vl_diferenca — DECIMAL(10,2) (gerado)
  - st_caixa — ENUM
  - ds_observacao — VARCHAR(255)

Registra a abertura e o fechamento do caixa, incluindo os valores esperados e contados.

### 3.8 VENDA

- **PK:** id_venda
- **FKs:**
  - id_funcionario → funcionario(id_funcionario)
  - id_caixa → caixa(id_caixa)
- **Atributos:**
  - id_venda — BIGINT UNSIGNED
  - id_funcionario — INT UNSIGNED
  - id_caixa — INT UNSIGNED
  - dt_venda — DATETIME
  - vl_desconto — DECIMAL(10,2)
  - vl_total — DECIMAL(10,2)
  - st_venda — ENUM
  - nr_documento_fiscal — VARCHAR(44)
  - fl_maioridade_conferida — TINYINT(1)

Registra as vendas realizadas, o funcionário responsável e o caixa utilizado.

### 3.9 FIADO

- **PK:** id_fiado
- **FKs:**
  - id_venda → venda(id_venda)
  - id_cliente → cliente(id_cliente)
- **Atributos:**
  - id_fiado — INT UNSIGNED
  - id_venda — BIGINT UNSIGNED
  - id_cliente — INT UNSIGNED
  - dt_abertura — DATETIME
  - dt_vencimento — DATE
  - vl_total — DECIMAL(10,2)
  - vl_pago — DECIMAL(10,2)
  - st_fiado — ENUM

Registra as vendas realizadas no fiado, identificando o cliente, o vencimento e os valores pagos e pendentes.

### 3.10 ITEM_VENDA

- **PK:** id_item_venda
- **FKs:**
  - id_venda → venda(id_venda)
  - id_produto → produto(id_produto)
  - id_lote → lote(id_lote) (opcional)
  - id_garrafa_aberta → garrafa_aberta(id_garrafa_aberta) (opcional)
- **Atributos:**
  - id_item_venda — BIGINT UNSIGNED
  - id_venda — BIGINT UNSIGNED
  - id_produto — INT UNSIGNED
  - id_lote — INT UNSIGNED (lote da unidade vendida)
  - id_garrafa_aberta — BIGINT UNSIGNED (garrafa da dose vendida)
  - tp_item — ENUM
  - qt_item — SMALLINT UNSIGNED
  - vl_unitario — DECIMAL(10,2)
  - vl_subtotal — DECIMAL(12,2) (gerado)

Representa os produtos incluídos em cada venda, com quantidade e preço praticado no momento da operação. Na venda de unidade informa o lote de onde saiu; na venda por dose informa a garrafa aberta.

### 3.11 PAGAMENTO

- **PK:** id_pagamento
- **FK:** id_venda → venda(id_venda)
- **Atributos:**
  - id_pagamento — BIGINT UNSIGNED
  - id_venda — BIGINT UNSIGNED
  - tp_forma — ENUM
  - vl_pago — DECIMAL(10,2)
  - dt_pagamento — DATETIME

Registra os pagamentos das vendas. Uma venda pode ter mais de uma forma de pagamento.

### 3.12 ITEM_FIADO

- **PK:** id_item_fiado
- **FK:** id_item_venda → item_venda(id_item_venda)
- **Atributos:**
  - id_item_fiado — BIGINT UNSIGNED
  - id_item_venda — BIGINT UNSIGNED
  - vl_fiado — DECIMAL(10,2)
  - dt_lancamento — DATETIME

Identifica as linhas da venda que tiveram parte do valor destinada ao fiado e quanto de cada linha foi lançado (vl_fiado). Assim uma venda com pagamento dividido (parte à vista, parte no fiado) fica registrada sem copiar produto, quantidade ou preço.

### 3.13 PAGAMENTO_FIADO

- **PK:** id_pagamento_fiado
- **FKs:**
  - id_fiado → fiado(id_fiado)
  - id_caixa → caixa(id_caixa)
- **Atributos:**
  - id_pagamento_fiado — BIGINT UNSIGNED
  - id_fiado — INT UNSIGNED
  - id_caixa — INT UNSIGNED
  - tp_forma — ENUM
  - vl_pago — DECIMAL(10,2)
  - dt_pagamento — DATETIME

Registra os pagamentos realizados para quitar total ou parcialmente uma dívida do fiado.

### 3.14 FORNECEDOR

- **PK:** id_fornecedor
- **Atributos:**
  - id_fornecedor — INT UNSIGNED
  - nm_fornecedor — VARCHAR(100)
  - nr_cnpj — CHAR(14)
  - nr_telefone — VARCHAR(15)
  - tp_fornecimento — ENUM
  - fl_ativo — TINYINT(1)

Armazena os dados dos fornecedores da adega.

### 3.15 COMPRA

- **PK:** id_compra
- **FKs:**
  - id_fornecedor → fornecedor(id_fornecedor)
  - id_funcionario → funcionario(id_funcionario)
- **Atributos:**
  - id_compra — INT UNSIGNED
  - id_fornecedor — INT UNSIGNED
  - id_funcionario — INT UNSIGNED
  - dt_pedido — DATETIME
  - dt_recebimento — DATETIME
  - tp_recebimento — ENUM
  - nr_nota_fiscal — VARCHAR(44)
  - vl_total — DECIMAL(12,2)
  - st_compra — ENUM

Registra os pedidos de compra realizados pela adega, seus fornecedores e os funcionários responsáveis.

### 3.16 ITEM_COMPRA

- **PK:** id_item_compra
- **FKs:**
  - id_compra → compra(id_compra)
  - id_produto → produto(id_produto)
- **Restrição:** UNIQUE(id_compra, id_produto)
- **Atributos:**
  - id_item_compra — INT UNSIGNED
  - id_compra — INT UNSIGNED
  - id_produto — INT UNSIGNED
  - qt_pedida — INT UNSIGNED
  - qt_recebida — INT UNSIGNED
  - vl_custo — DECIMAL(10,2)
  - fl_conferido — TINYINT(1)
  - ds_divergencia — VARCHAR(200)

Representa os produtos incluídos em cada compra, com quantidades pedidas e recebidas.

### 3.17 LOTE

- **PK:** id_lote
- **FK:** id_item_compra → item_compra(id_item_compra)
- **Atributos:**
  - id_lote — INT UNSIGNED
  - id_item_compra — INT UNSIGNED
  - nr_lote — VARCHAR(30)
  - dt_validade — DATE
  - qt_disponivel — INT UNSIGNED

Registra os lotes recebidos e suas datas de validade, permitindo acompanhar a quantidade disponível.

### 3.18 MOVIMENTACAO_ESTOQUE

- **PK:** id_movimentacao
- **FKs:**
  - id_produto → produto(id_produto)
  - id_funcionario → funcionario(id_funcionario)
  - id_lote → lote(id_lote)
- **Atributos:**
  - id_movimentacao — BIGINT UNSIGNED
  - id_produto — INT UNSIGNED
  - id_funcionario — INT UNSIGNED
  - id_lote — INT UNSIGNED
  - tp_movimento — ENUM
  - qt_movimentada — INT UNSIGNED
  - ds_motivo — VARCHAR(200)
  - dt_movimentacao — DATETIME

Registra entradas, saídas, perdas, devoluções e ajustes no estoque.

### 3.19 LOG_ACESSO

- **PK:** id_log
- **FK:** id_funcionario → funcionario(id_funcionario)
- **Atributos:**
  - id_log — BIGINT UNSIGNED
  - id_funcionario — INT UNSIGNED
  - dt_evento — DATETIME
  - tp_evento — ENUM
  - nm_tabela — VARCHAR(40)
  - id_registro — VARCHAR(40)
  - ds_alteracao — JSON
  - ds_ip — VARCHAR(45)

Registra eventos de acesso e alterações para apoiar a auditoria e o controle de acesso aos dados.

### 3.20 GARRAFA_ABERTA

- **PK:** id_garrafa_aberta
- **FKs:**
  - id_lote → lote(id_lote)
  - id_produto → produto(id_produto)
  - id_funcionario → funcionario(id_funcionario)
- **Atributos:**
  - id_garrafa_aberta — BIGINT UNSIGNED
  - id_lote — INT UNSIGNED
  - id_produto — INT UNSIGNED
  - id_funcionario — INT UNSIGNED
  - dt_abertura — DATETIME
  - qt_ml_inicial — SMALLINT UNSIGNED
  - qt_ml_restante — SMALLINT UNSIGNED
  - st_garrafa — ENUM

Controla o volume que ainda resta em cada garrafa aberta para venda de doses. A abertura baixa uma garrafa fechada do estoque (SAIDA_DOSE) e cada dose vendida desconta os mililitros da garrafa.

### 3.21 MOVIMENTACAO_CAIXA

- **PK:** id_movimentacao_caixa
- **FKs:**
  - id_caixa → caixa(id_caixa)
  - id_funcionario → funcionario(id_funcionario)
- **Atributos:**
  - id_movimentacao_caixa — BIGINT UNSIGNED
  - id_caixa — INT UNSIGNED
  - id_funcionario — INT UNSIGNED
  - tp_movimento — ENUM
  - vl_movimento — DECIMAL(10,2)
  - ds_motivo — VARCHAR(200)
  - dt_movimentacao — DATETIME

Registra suprimentos (entrada de dinheiro), sangrias e despesas (saídas) do caixa, para que o valor esperado no fechamento considere o dinheiro que entrou ou saiu fora das vendas.

## 4. Relacionamentos e cardinalidades

As cardinalidades abaixo representam as 30 relações implementadas pelas chaves estrangeiras no script SQL:

| Relacionamento | Cardinalidade |
|---|---|
| CATEGORIA — PRODUTO | 1:N |
| PRODUTO — ESTOQUE | 1:1 |
| FUNCIONARIO — ESCALA | 1:N |
| FUNCIONARIO — CAIXA | 1:N |
| FUNCIONARIO — VENDA | 1:N |
| CAIXA — VENDA | 1:N |
| VENDA — FIADO | 1:0..1 |
| CLIENTE — FIADO | 1:N |
| VENDA — ITEM_VENDA | 1:N |
| PRODUTO — ITEM_VENDA | 1:N |
| VENDA — PAGAMENTO | 1:N |
| ITEM_VENDA — ITEM_FIADO | 1:0..1 |
| FIADO — PAGAMENTO_FIADO | 1:N |
| CAIXA — PAGAMENTO_FIADO | 1:N |
| FORNECEDOR — COMPRA | 1:N |
| FUNCIONARIO — COMPRA | 1:N |
| COMPRA — ITEM_COMPRA | 1:N |
| PRODUTO — ITEM_COMPRA | 1:N |
| ITEM_COMPRA — LOTE | 1:N |
| PRODUTO — MOVIMENTACAO_ESTOQUE | 1:N |
| FUNCIONARIO — MOVIMENTACAO_ESTOQUE | 1:N |
| LOTE — MOVIMENTACAO_ESTOQUE | 1:N |
| LOTE — ITEM_VENDA | 1:N (opcional) |
| GARRAFA_ABERTA — ITEM_VENDA | 1:N (opcional) |
| LOTE — GARRAFA_ABERTA | 1:N |
| PRODUTO — GARRAFA_ABERTA | 1:N |
| FUNCIONARIO — GARRAFA_ABERTA | 1:N |
| CAIXA — MOVIMENTACAO_CAIXA | 1:N |
| FUNCIONARIO — MOVIMENTACAO_CAIXA | 1:N |
| FUNCIONARIO — LOG_ACESSO | 1:N |

Observação: a tabela LOG_ACESSO permite que um evento seja registrado sem funcionário associado, pois sua FK aceita valor nulo. A tabela ESTOQUE possui uma restrição UNIQUE em id_produto, garantindo no máximo um registro de estoque por produto.

## 5. Chaves primárias e estrangeiras

As chaves primárias foram definidas com identificadores próprios, geralmente chamados de id_ seguido do nome da tabela. Elas permitem identificar cada registro sem depender de informações que podem mudar, como nomes ou telefones.

As chaves estrangeiras foram utilizadas para manter a ligação entre os dados e impedir referências a registros inexistentes.

Também foram aplicadas restrições UNIQUE em campos que não podem se repetir, como CPF, CNPJ, login e código de barras, conforme definido no script SQL.

## 6. Regras garantidas no próprio banco

Além das chaves e restrições, o script cria triggers e procedures que impedem dados incoerentes. As principais:

| Regra | Onde está |
|---|---|
| Todo produto cadastrado ganha um registro de estoque zerado | trigger `trg_produto_cria_estoque` |
| O saldo do lote começa em zero e só muda por movimentação | triggers `trg_lote_inicia_zero` e `trg_movimentacao_atualiza_estoque` |
| Venda e recebimento de fiado exigem caixa aberto | `trg_venda_caixa_aberto`, `trg_pagamento_fiado_valida` |
| Item vendido: produto ativo, maioridade conferida, lote do produto, lote não vencido e saldo suficiente | `trg_item_venda_valida` |
| Venda de unidade gera a saída de estoque sozinha | `trg_item_venda_registra_saida` |
| Movimentações, itens de venda, pagamentos e itens de fiado não podem ser alterados nem apagados | triggers `*_bloqueia_update` e `*_bloqueia_delete` |
| Soma dos pagamentos não passa do total da venda | `trg_pagamento_valida` |
| Situação do fiado (ABERTO ou QUITADO) é calculada pelo valor pago | `trg_fiado_status_insert` e `trg_fiado_status_update` |
| Auditoria de cliente, fiado, recebimento e fechamento de caixa | triggers `trg_*_audita_*` e `trg_pagamento_fiado_atualiza` |
| Autorizar cliente para fiado (só gerente) | procedure `sp_autorizar_cliente_fiado` |
| Abrir garrafa para dose | procedure `sp_abrir_garrafa` |
| Lançar parte de uma venda no fiado, com limite e bloqueio | procedure `sp_registrar_venda_fiado` |
| Conferir pagamentos da venda | procedure `sp_validar_pagamentos_venda` |
| Fechar o caixa e calcular o valor esperado | procedure `sp_fechar_caixa` |
| Registrar login, falha de login e consulta a dado pessoal | procedure `sp_registrar_evento_acesso` |

A aplicação deve definir `@id_funcionario_logado` depois que o usuário entra no sistema, porque os triggers de auditoria usam essa variável.

## 7. Considerações finais

O modelo lógico organiza as informações necessárias para os processos de venda, pagamento, fiado, compra, controle de estoque, validade dos produtos, funcionários e caixa.

A estrutura foi implementada em MySQL 8.0 e utiliza chaves e restrições para manter a integridade dos dados.
