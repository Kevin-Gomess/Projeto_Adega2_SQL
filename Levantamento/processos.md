Código	Processo	Descrição resumida	Origem	Representação no modelo

PR01	Venda no balcão	Atendimento ao cliente, conferência dos preços, cálculo do valor e conclusão da venda.	Observado	VENDA, ITEM_VENDA, PRODUTO, FUNCIONARIO e CAIXA

PR02	Pagamento de venda	Registro do pagamento por Pix, dinheiro, cartão ou fiado. O sistema também prevê pagamentos divididos.	Formas de pagamento observadas; divisão como proposta	PAGAMENTO e VENDA

PR03	Venda fiada	Registro dos produtos retirados por clientes conhecidos ou autorizados e do valor que ficará pendente.	Registro de fiado observado; controles adicionais como proposta	CLIENTE, FIADO, ITEM_FIADO, VENDA e ITEM_VENDA

PR04	Recebimento de fiado	Registro de pagamentos totais ou parciais e atualização do saldo devedor.	Proposta	FIADO, PAGAMENTO_FIADO e CAIXA

PR05	Compra de produtos	Identificação da necessidade de reposição e realização do pedido ao fornecedor.	Observado	COMPRA, ITEM_COMPRA, FORNECEDOR e FUNCIONARIO

PR06	Recebimento e conferência	Conferência dos produtos recebidos e identificação de divergências.	Observado	COMPRA, ITEM_COMPRA, FORNECEDOR e LOTE

PR07	Controle de estoque	Acompanhamento das quantidades disponíveis e identificação da necessidade de reposição.	Observado; controle informatizado como proposta	PRODUTO e ESTOQUE

PR08	Movimentação de estoque	Registro de entradas, saídas, abertura de garrafas para doses e ajustes.	Parcialmente observado; registro informatizado como proposta	MOVIMENTACAO_ESTOQUE, PRODUTO e FUNCIONARIO

PR09	Perdas e validade	Registro de produtos quebrados, perdidos ou vencidos, com controle de validade por lote.	Proposta	LOTE, MOVIMENTACAO_ESTOQUE e PRODUTO

PR10	Abertura e fechamento de caixa	Registro do valor inicial, movimentações, valor contado e possíveis diferenças no fechamento.	Proposta	CAIXA, VENDA e PAGAMENTO

PR11	Cadastro de produtos	Organização das informações dos produtos, categorias, preços e características de venda.	Necessidade identificada no levantamento	PRODUTO e CATEGORIA

PR12	Escala de funcionários	Registro dos dias, horários e funções dos funcionários.	Proposta	FUNCIONARIO e ESCALA



