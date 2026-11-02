
# Processo de Normalização — Adega do Tonho

## 1. Apresentação

A normalização é um processo utilizado na organização de bancos de dados para evitar repetição desnecessária de informações e diminuir problemas durante a inclusão, alteração e exclusão de registros.

No projeto da Adega do Tonho, foram consideradas as três primeiras formas normais: Primeira Forma Normal (1FN), Segunda Forma Normal (2FN) e Terceira Forma Normal (3FN).

O objetivo foi organizar as informações em tabelas relacionadas, mantendo cada tabela com uma função específica.

## 2. Primeira Forma Normal (1FN)

A Primeira Forma Normal determina que cada campo da tabela deve armazenar apenas um valor, sem grupos de informações repetidas ou listas dentro de uma mesma coluna.

No projeto, essa organização foi aplicada separando informações que poderiam aparecer várias vezes em registros próprios.

Por exemplo:

- A tabela VENDA armazena os dados gerais de uma venda.
- A tabela ITEM_VENDA armazena os produtos que fazem parte dessa venda.
- A tabela PAGAMENTO registra as formas de pagamento utilizadas.
- A tabela ITEM_COMPRA armazena os produtos de cada compra.
- A tabela MOVIMENTACAO_ESTOQUE registra cada entrada ou saída de produtos.

Dessa forma, uma venda pode possuir vários itens e pagamentos sem precisar criar colunas repetidas, como produto_1, produto_2 ou pagamento_1, pagamento_2.

Assim, os dados ficam organizados em registros separados, atendendo à Primeira Forma Normal.

## 3. Segunda Forma Normal (2FN)

A Segunda Forma Normal determina que a tabela esteja na 1FN e que todos os atributos que não fazem parte da chave dependam da chave primária completa.

No projeto, foram utilizadas chaves primárias próprias para identificar os registros das tabelas, como id_venda, id_produto, id_compra e id_item_venda.

Também foram criadas tabelas específicas para separar informações de diferentes operações.

Por exemplo:

- Os dados gerais da venda ficam na tabela VENDA.
- Os dados dos produtos vendidos ficam na tabela ITEM_VENDA.
- Os dados gerais da compra ficam na tabela COMPRA.
- Os produtos incluídos na compra ficam na tabela ITEM_COMPRA.

Na tabela ITEM_COMPRA, existe também a restrição UNIQUE(id_compra, id_produto), que impede que o mesmo produto seja repetido na mesma compra.

Essa organização evita misturar os dados da operação com os dados dos itens e contribui para atender à Segunda Forma Normal.

## 4. Terceira Forma Normal (3FN)

A Terceira Forma Normal determina que a tabela esteja na 2FN e que os atributos que não são chave dependam diretamente da chave primária, sem depender de outros atributos que também não sejam chave.

No projeto, as informações foram separadas de acordo com sua finalidade.

Alguns exemplos:

- Os dados da categoria ficam na tabela CATEGORIA, enquanto a tabela PRODUTO guarda apenas o identificador da categoria.
- Os dados do fornecedor ficam na tabela FORNECEDOR, enquanto COMPRA armazena o identificador do fornecedor.
- Os dados do funcionário ficam na tabela FUNCIONARIO, enquanto tabelas como VENDA, COMPRA e CAIXA guardam seu identificador.
- Os dados do cliente ficam na tabela CLIENTE, enquanto FIADO registra o identificador do cliente responsável pela dívida.

Com essa separação, informações como nome de fornecedor, nome de funcionário e nome de categoria não precisam ser repetidas em todas as operações relacionadas.

Isso reduz a duplicação e facilita a manutenção dos dados, contribuindo para atender à Terceira Forma Normal.

## 5. Justificativa da normalização

A normalização foi importante para o projeto porque a adega trabalha com diferentes atividades, como cadastro de produtos, vendas, pagamentos, compras, controle de estoque e fiado.

Se todas essas informações fossem armazenadas em uma única tabela, haveria muita repetição e seria mais difícil atualizar os dados corretamente.

Por isso, as informações foram divididas em tabelas específicas e relacionadas por chaves estrangeiras.

A separação permite, por exemplo, alterar o telefone de um cliente em um único cadastro, registrar várias vendas para o mesmo cliente e manter o histórico de movimentações do estoque.

## 6. Considerações finais

A aplicação das três formas normais ajudou a organizar o banco de dados da Adega do Tonho, reduzindo informações repetidas e facilitando o relacionamento entre as tabelas.

A estrutura busca manter os dados consistentes e facilitar futuras consultas e alterações.

A normalização foi considerada durante a construção do modelo lógico e da estrutura SQL do projeto.

