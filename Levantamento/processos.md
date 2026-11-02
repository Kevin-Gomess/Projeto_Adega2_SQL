## Processos de Negócio

### PR01 — Venda no balcão e consulta de preços

O processo começa quando o cliente solicita um produto. O funcionário consulta o preço no sistema, pesquisando pelo nome ou código de barras. O sistema apresenta o nome do produto, a categoria, o preço da unidade fechada, o preço da dose, quando disponível, e a situação do estoque.

Depois da consulta, o funcionário informa o valor ao cliente e registra os produtos escolhidos. Para cada item, são registrados o produto, o tipo de venda (unidade ou dose), a quantidade e o preço unitário aplicado. O sistema calcula o subtotal dos itens, considera eventual desconto e apresenta o total da venda.

Quando o produto for vendido em dose, o funcionário seleciona essa opção e informa a quantidade de doses. O sistema utiliza o preço cadastrado para a dose e registra o item com o tipo `DOSE`. A venda é associada ao funcionário responsável, ao caixa e à data e hora da operação.

**Dados envolvidos:** produto, categoria, preço da unidade, preço da dose, quantidade, tipo do item, subtotal, desconto, total, funcionário, caixa e data da venda.

**Entidades relacionadas:** PRODUTO, CATEGORIA, ESTOQUE, VENDA, ITEM_VENDA, FUNCIONARIO e CAIXA.

### PR02 — Pagamento de venda

Após o registro dos produtos, o funcionário informa como o cliente deseja pagar. O sistema permite registrar dinheiro, Pix, cartão de débito, cartão de crédito ou fiado.

Uma venda pode ter mais de uma forma de pagamento. Por exemplo, o cliente pode pagar uma parte no Pix e outra em dinheiro. Também pode existir uma parte paga normalmente e outra parte lançada no fiado, desde que o cliente esteja autorizado e respeite o limite definido.

O funcionário registra o valor correspondente a cada forma de pagamento. A soma dos valores registrados deve corresponder ao total da venda. Quando houver valor lançado no fiado, esse valor deverá ser relacionado à conta do cliente.

**Dados envolvidos:** venda, forma de pagamento, valor pago, data e hora do pagamento e, quando houver fiado, cliente e valor pendente.

**Entidades relacionadas:** VENDA, PAGAMENTO, CLIENTE e FIADO.

### PR03 — Venda fiada

Quando uma venda tiver uma parte ou todo o valor lançado no fiado, o funcionário identifica o cliente e verifica se ele está bloqueado e se possui limite disponível.

Se a operação for permitida, o valor destinado ao fiado é registrado e associado à venda e ao cliente. O sistema mantém o valor total da conta, o valor já pago, a data de abertura e o vencimento.

O cliente deve ser identificado no cadastro para que a adega consiga acompanhar os valores pendentes.

**Dados envolvidos:** cliente, venda, itens vendidos, valor lançado no fiado, limite disponível, data de abertura e vencimento.

**Entidades relacionadas:** CLIENTE, VENDA, ITEM_VENDA, FIADO e PAGAMENTO.

### PR04 — Recebimento e quitação do fiado

Quando o cliente retorna para pagar uma dívida, o funcionário consulta suas contas de fiado em aberto. O pagamento pode ser total ou parcial e pode ser feito por dinheiro, Pix ou cartão.

O funcionário registra o valor recebido, a forma de pagamento, a data e o caixa responsável. O valor recebido é utilizado para atualizar o saldo da conta.

Quando o total pago alcançar o valor devido, a situação do fiado passa para quitado. Enquanto existir saldo pendente, a conta permanece em aberto.

**Dados envolvidos:** cliente, conta de fiado, valor total, valor pago, saldo pendente, forma de pagamento, data e caixa.

**Entidades relacionadas:** CLIENTE, FIADO, PAGAMENTO_FIADO e CAIXA.

### PR05 — Compra de produtos e contato com fornecedores

Quando identifica a necessidade de reposição, o funcionário consulta os produtos que precisam ser comprados e entra em contato com um fornecedor.

A compra registra o fornecedor, o funcionário responsável, a data do pedido, os produtos solicitados, as quantidades e os custos. O recebimento pode acontecer de duas maneiras: o fornecedor entrega a mercadoria na adega ou um funcionário vai até o fornecedor para retirar os produtos.

A forma de recebimento é registrada na compra para manter o histórico da operação.

**Dados envolvidos:** fornecedor, funcionário, data do pedido, produtos, quantidades pedidas, custo unitário e forma de recebimento.

**Entidades relacionadas:** FORNECEDOR, COMPRA, ITEM_COMPRA e FUNCIONARIO.

### PR06 — Recebimento, conferência e armazenamento

Quando a mercadoria chega à adega, seja por entrega do fornecedor ou por retirada feita por um funcionário, é realizada a conferência dos produtos.

O funcionário compara a quantidade recebida com a quantidade pedida e verifica se existem produtos faltando, incorretos ou danificados. As divergências são registradas na compra.

Depois da conferência, os produtos aprovados são armazenados nos locais utilizados pela adega, como prateleiras, áreas de estoque ou outros espaços destinados a cada tipo de produto. Quando o produto possui controle de validade, também é registrado o lote e sua data de vencimento.

A localização geral do produto é registrada no controle de estoque.

**Dados envolvidos:** compra, fornecedor, produto, quantidade pedida, quantidade recebida, conferência, divergências, lote, validade e localização.

**Entidades relacionadas:** COMPRA, ITEM_COMPRA, FORNECEDOR, LOTE, PRODUTO e ESTOQUE.

### PR07 — Controle de estoque

O estoque é utilizado para acompanhar a quantidade disponível de cada produto e sua localização na adega. O funcionário pode consultar o saldo atual e a quantidade mínima definida para reposição.

Quando a quantidade de um produto fica igual ou abaixo do mínimo, o sistema permite identificar a necessidade de uma nova compra.

O saldo do estoque deve acompanhar as entradas e saídas registradas nas movimentações. Assim, a quantidade disponível não depende apenas de uma alteração manual no cadastro do produto.

**Dados envolvidos:** produto, quantidade atual, quantidade mínima, localização e data da última atualização.

**Entidades relacionadas:** PRODUTO, ESTOQUE e MOVIMENTACAO_ESTOQUE.

### PR08 — Movimentação de estoque e venda de doses

Toda entrada ou saída de produtos deve ser registrada para manter o histórico do estoque. As movimentações podem ocorrer por recebimento de compras, vendas, abertura de garrafas para venda de doses, perdas, devoluções ou ajustes.

Na venda de doses, o funcionário registra a quantidade de doses vendidas. A abertura da garrafa representa uma saída de uma unidade fechada do estoque, conforme o controle adotado para o produto. O sistema registra o tipo de movimentação, o produto, a quantidade, a data e o funcionário responsável.

Quando a movimentação estiver relacionada a um lote, essa informação também é registrada.

**Dados envolvidos:** produto, funcionário, lote, tipo de movimentação, quantidade, motivo e data.

**Entidades relacionadas:** MOVIMENTACAO_ESTOQUE, PRODUTO, FUNCIONARIO e LOTE.

### PR09 — Registro de perdas, quebras e controle de validade

Quando um produto quebra, vence ou precisa ser retirado do estoque por outro motivo, o funcionário registra a saída e informa a justificativa.

Nos produtos controlados por lote, o sistema permite consultar a data de validade e identificar aqueles que estão vencidos ou próximos do vencimento. Produtos vencidos não devem permanecer disponíveis para venda e precisam ter sua retirada registrada.

**Dados envolvidos:** produto, lote, data de validade, quantidade, motivo da perda e funcionário responsável.

**Entidades relacionadas:** LOTE, MOVIMENTACAO_ESTOQUE, PRODUTO e FUNCIONARIO.

### PR10 — Abertura e fechamento de caixa

No início do expediente, o funcionário responsável registra a abertura do caixa e o valor inicial disponível para troco.

Durante o funcionamento, as vendas e os recebimentos de fiado são relacionados ao caixa correspondente. No encerramento, o funcionário informa o valor contado. O sistema compara o valor contado com o valor esperado e registra a diferença, quando existir, junto com uma observação ou justificativa.

**Dados envolvidos:** funcionário, data e hora de abertura, valor inicial, vendas, recebimentos, data e hora de fechamento, valor esperado, valor contado e diferença.

**Entidades relacionadas:** CAIXA, FUNCIONARIO, VENDA, PAGAMENTO e PAGAMENTO_FIADO.

### PR11 — Cadastro de produtos e categorias

O cadastro de produtos permite organizar os itens comercializados pela adega. O funcionário registra o nome, a categoria, o código de barras quando disponível e o preço de venda.

Quando o produto também pode ser vendido em doses, são informados o volume da garrafa, o volume da dose e o preço correspondente. O cadastro também indica se o produto está ativo para comercialização e se possui restrição de idade.

**Dados envolvidos:** produto, categoria, código de barras, preço de venda, indicação de venda por dose, volumes, preço da dose e situação do produto.

**Entidades relacionadas:** PRODUTO e CATEGORIA.

### PR12 — Escala de funcionários

O processo de escala organiza os dias e horários de trabalho dos funcionários. São registrados o funcionário, a data do turno, o horário de início, o horário de término e a função exercida.

Essas informações permitem consultar quem está escalado em cada dia e organizar a rotina da equipe.

**Dados envolvidos:** funcionário, data do turno, horário de início, horário de término e função.

**Entidades relacionadas:** FUNCIONARIO e ESCALA.
