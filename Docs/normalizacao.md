
# Processo de Normalização - Adega do Tonho

**Projeto:** Sistema de gerenciamento da Adega do Tonho  
**SGBD:** MySQL 8.0  
**Versão de referência:** 1.4  
**Data de referência:** 01/11/2026  

## 1. Apresentação

A normalização foi utilizada para organizar as informações do banco de dados da Adega do Tonho. O objetivo é evitar dados repetidos sem necessidade, facilitar as alterações e diminuir problemas de inconsistência.

O processo foi analisado considerando as três primeiras formas normais: Primeira Forma Normal (1FN), Segunda Forma Normal (2FN) e Terceira Forma Normal (3FN).

A estrutura utilizada como referência é a versão 1.4 do arquivo `script_adequado_final.sql`, que possui 19 tabelas.

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

### Produto e estoque

Os dados de identificação e comercialização ficam na tabela `produto`, enquanto as informações de quantidade e localização geral ficam na tabela `estoque`.

A ligação é feita por `id_produto`.

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

## 6. Considerações sobre os campos calculados

Algumas tabelas possuem campos calculados pelo próprio banco de dados:

- `caixa.vl_diferenca`: calculado pela diferença entre o valor contado e o valor esperado.
- `item_venda.vl_subtotal`: calculado pela multiplicação da quantidade pelo valor unitário.

Esses campos são gerados pelo banco de dados e não precisam ser informados manualmente nas operações comuns de inserção.

## 7. Conclusão

A organização do banco de dados da Adega do Tonho foi feita buscando atender às três primeiras formas normais.

Na 1FN, os grupos repetitivos foram separados em tabelas próprias e os campos foram organizados para armazenar valores individuais.

Na 2FN, foram utilizadas chaves primárias simples, evitando dependências parciais em relação à chave.

Na 3FN, as informações foram separadas por assunto, como produtos, categorias, fornecedores, compras, vendas e pagamentos, buscando evitar dependências transitivas.

Com essa organização, o banco fica mais fácil de manter, consultar e atualizar. A estrutura também permite acompanhar melhor as atividades da adega e apoiar as decisões de gestão.
