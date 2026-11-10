# Processo de Normalização - Adega do Tonho


## 1. Apresentação

A normalização foi utilizada para organizar as informações do banco de dados da Adega do Tonho. O objetivo é evitar dados repetidos sem necessidade, facilitar as alterações e diminuir problemas de inconsistência.

O processo foi analisado considerando as três primeiras formas normais: Primeira Forma Normal (1FN), Segunda Forma Normal (2FN) e Terceira Forma Normal (3FN).

A estrutura utilizada como referência é a versão 2.0 do arquivo `docs/script.sql`, que possui 22 tabelas.

## 2. Primeira Forma Normal (1FN)

A Primeira Forma Normal determina que cada campo deve armazenar um único valor, sem grupos de informações repetidas ou listas dentro de uma mesma coluna.

No projeto, as informações foram separadas em tabelas de acordo com sua finalidade.

Por exemplo, uma venda pode possuir vários produtos. Em vez de colocar todos os produtos em uma única coluna da tabela `venda`, foi criada a tabela `item_venda`.

Dessa forma, cada produto vendido fica registrado em uma linha própria, com sua quantidade e seu preço unitário.

O mesmo foi feito nas compras. A tabela `item_compra` permite registrar cada produto de uma compra separadamente.

**Exemplo da organização:**

| Tabela | Informação armazenada |
|---|---|
| venda | Dados gerais da venda |
| item_venda | Produtos que fazem parte da venda |
| pagamento | Valores e formas de pagamento da venda |
| compra | Dados gerais da compra |
| item_compra | Produtos que fazem parte da compra |
| item_fiado | Linhas da venda que tiveram parte do valor lançada no fiado |
| garrafa_aberta | Garrafas abertas para a venda de doses, uma linha por garrafa |
| movimentacao_caixa | Suprimentos, sangrias e despesas do caixa, uma linha por movimento |

Assim, as informações não precisam ser armazenadas como listas dentro de uma única coluna.

**Resultado:** a estrutura foi organizada para atender à Primeira Forma Normal, considerando que os campos armazenam valores individuais e que os grupos repetitivos foram separados em tabelas próprias.

## 3. Segunda Forma Normal (2FN)

A Segunda Forma Normal exige que a tabela esteja na 1FN e que todos os atributos que não fazem parte da chave dependam da chave primária completa, sem dependências parciais.

No projeto, as tabelas utilizam chaves primárias simples, ou seja, cada tabela possui um único campo identificador como PK.

Por exemplo, na tabela `produto`, o identificador `id_produto` determina as demais informações do produto, como nome, preço, categoria e configuração de venda por dose.

Na tabela `funcionario`, o campo `id_funcionario` identifica o funcionário e determina suas informações cadastradas.

Como as chaves primárias são formadas por apenas uma coluna, não existe dependência parcial em relação a uma parte da chave primária.

**Resultado:** considerando as chaves primárias utilizadas no modelo, a estrutura atende ao critério de Segunda Forma Normal.

## 4. Terceira Forma Normal (3FN)

A Terceira Forma Normal exige que a tabela esteja na 2FN e que os atributos que não fazem parte da chave primária dependam diretamente da chave, sem depender de outros atributos não-chave.

Para organizar o banco, as informações foram separadas conforme o assunto de cada tabela.

Alguns exemplos são:

### Categoria e produto

Os dados da categoria ficam na tabela `categoria`, enquanto os dados do produto ficam na tabela `produto`.

A tabela `produto` utiliza `id_categoria` como chave estrangeira para indicar a qual categoria pertence.

Assim, o nome da categoria não precisa ser repetido em todos os registros de produtos.

### Fornecedor e compra

Os dados do fornecedor ficam na tabela `fornecedor`, enquanto as informações de cada compra ficam na tabela `compra`.

A compra utiliza `id_fornecedor` para indicar quem forneceu os produtos.

Dessa maneira, os dados cadastrais do fornecedor não precisam ser repetidos em cada compra.

### Venda e pagamento

Os dados gerais da venda ficam na tabela `venda`, enquanto os pagamentos ficam na tabela `pagamento`.

Essa separação permite registrar mais de um pagamento para uma mesma venda, sem repetir os dados principais da venda.

### Documento fiscal

Os campos `venda.nr_documento_fiscal` e `compra.nr_nota_fiscal` guardam só o número ou a chave informados na operação. Os dados completos do documento (modelo, série, chave de acesso, data de emissão, valor e situação) ficam em `nota_fiscal`, que depende de `id_nota_fiscal` e se liga a uma compra (`id_compra`, documento de entrada) ou a uma venda (`id_venda`, documento de saída), nunca às duas. Assim a venda e a compra não repetem esses dados, e `nota_fiscal` não repete dados do fornecedor nem do funcionário: chega a eles pela compra ou pela venda. `nota_fiscal.vl_total` repete o total da operação de propósito (ver seção 6), porque o documento registra o valor informado nele.

### Produto e estoque

Os dados de identificação e comercialização ficam na tabela `produto`, enquanto as informações de quantidade e localização geral ficam na tabela `estoque`.

A ligação é feita por `id_produto`.

### Fiado e item do fiado

O produto, a quantidade e o preço de cada linha ficam apenas em `item_venda`. A tabela `item_fiado` guarda só a ligação com a linha (`id_item_venda`) e o valor daquela linha que foi para o fiado (`vl_fiado`). Assim, esses dados não são copiados e não podem divergir. Como o fiado nasce de uma única venda (`fiado.id_venda` é UNIQUE), o cliente e o prazo ficam em `fiado`, e não nas linhas.

### Garrafa aberta e movimentação do caixa

O volume restante de uma garrafa aberta depende da garrafa, por isso fica em `garrafa_aberta` (e não em `produto`, que guarda o volume de uma garrafa nova). Os suprimentos, sangrias e despesas dependem do caixa e ficam em `movimentacao_caixa`, em vez de colunas soltas na tabela `caixa`.

### Compra e lote

Os dados da compra ficam em `compra`, os itens recebidos ficam em `item_compra` e as informações dos lotes ficam em `lote`.

Essa organização permite acompanhar os produtos recebidos e suas respectivas datas de validade.

**Resultado:** a separação das informações busca evitar dependências transitivas e repetição de dados cadastrais. A confirmação formal da 3FN depende da verificação das dependências funcionais de todos os atributos, e não somente da existência de tabelas separadas.

## 5. Justificativa da normalização

A normalização foi importante para o projeto porque a adega trabalha com diferentes informações, como produtos, categorias, estoque, vendas, pagamentos, clientes, compras e fornecedores.

Se todas essas informações fossem armazenadas em poucas tabelas, alguns dados precisariam ser repetidos várias vezes. Isso poderia causar divergências quando um cadastro fosse alterado.

Com a separação das tabelas, cada informação fica armazenada em seu local adequado e os relacionamentos são feitos por meio das chaves primárias e estrangeiras.

Alguns exemplos de benefícios são:

- Evitar repetir os dados de uma categoria em todos os produtos.
- Manter os dados dos fornecedores separados dos dados das compras.
- Registrar vários produtos em uma mesma venda por meio de `item_venda`.
- Registrar vários produtos em uma mesma compra por meio de `item_compra`.
- Separar os pagamentos das informações gerais da venda.
- Controlar os lotes e suas datas de validade separadamente dos dados gerais dos produtos.
- Manter o histórico das movimentações de estoque.

## 6. Redundâncias que mantivemos de propósito

Cinco valores poderiam ser calculados a partir de outras tabelas, mas ficam gravados por motivo de histórico ou de controle. A consistência deles é protegida por triggers, procedures e consultas de auditoria:

| Coluna | Poderia ser calculada de | Por que fica gravada |
|---|---|---|
| `estoque.qt_atual` | soma das movimentações do produto | Saber o saldo sem somar todo o histórico. Só muda por `movimentacao_estoque` (trigger) e a consulta de auditoria A01 confere. |
| `nota_fiscal.vl_total` | `venda.vl_total` ou `compra.vl_total` | O documento fiscal guarda o valor informado nele. Na massa, o valor é copiado da operação; o banco não obriga a igualdade, então diferenças devem ser conferidas. |
| `venda.vl_total` | soma dos itens menos o desconto | Guarda o valor cobrado no momento. A procedure de fiado e o fechamento de caixa conferem com itens e pagamentos (consulta A02). |
| `fiado.vl_pago` e `st_fiado` | soma de `pagamento_fiado` | Mostrar o saldo rápido. O trigger atualiza os dois a cada recebimento e a consulta A09 confere. |
| `lote.qt_disponivel` | soma das movimentações do lote | Escolher o lote na venda. Começa em zero e só muda por movimentação. |

Por isso a 3FN é atendida na estrutura das tabelas, e essas colunas são redundâncias controladas, não erros de modelagem.

## 7. Considerações sobre os campos calculados

Algumas tabelas possuem campos calculados pelo próprio banco de dados:

- `caixa.vl_diferenca`: calculado pela diferença entre o valor contado e o valor esperado.
- `item_venda.vl_subtotal`: calculado pela multiplicação da quantidade pelo valor unitário.

Esses campos são gerados pelo banco de dados e não precisam ser informados manualmente nas operações comuns de inserção.

## 8. Conclusão

A organização do banco de dados da Adega do Tonho foi feita buscando atender às três primeiras formas normais.

Na 1FN, os grupos repetitivos foram separados em tabelas próprias e os campos foram organizados para armazenar valores individuais.

Na 2FN, foram utilizadas chaves primárias simples, evitando dependências parciais em relação à chave.

Na 3FN, as informações foram separadas por assunto, como produtos, categorias, fornecedores, compras, vendas e pagamentos, buscando evitar dependências transitivas.

Com essa organização, o banco fica mais fácil de manter, consultar e atualizar. A estrutura também permite acompanhar melhor as atividades da adega e apoiar as decisões de gestão.
