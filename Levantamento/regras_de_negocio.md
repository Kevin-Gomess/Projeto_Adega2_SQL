Código	Regra de negócio

RN01	O sistema deve aceitar os pagamentos por Pix, dinheiro, cartão de crédito e cartão de débito.

RN02	Cada venda registrada deve possuir data, funcionário responsável e seus respectivos itens.

RN03	O valor total da venda deve corresponder à soma dos valores de seus itens, considerando os descontos aplicáveis.

RN04	Uma venda pode possuir vários itens, e cada item deve identificar o produto, a quantidade e o preço praticado.

RN05	Toda movimentação de estoque deve identificar o produto, o tipo de movimentação, a quantidade e a data.

RN06	A abertura de uma garrafa para venda em doses deve gerar a saída correspondente do estoque de garrafas fechadas.

RN07	Uma mesma venda pode possuir mais de uma forma de pagamento, desde que os valores registrados correspondam ao total devido.

RN08	O fiado somente pode ser concedido a clientes identificados e autorizados pela organização.

RN09	Cada registro de fiado deve estar vinculado à venda que originou a dívida.

RN10	O sistema deve manter o limite de fiado definido para cada cliente autorizado.

RN11	Antes de registrar um novo fiado, o sistema deve verificar a autorização do cliente e o limite disponível. A verificação explícita da autorização depende da inclusão de cliente.fl_fiado_autorizado no SQL.

RN12	O saldo devedor deve ser atualizado conforme os pagamentos realizados.

RN13	Os pagamentos de fiado devem registrar data, valor e forma de recebimento.

RN14	O sistema deve permitir identificar fiados em aberto e quitados, considerando os pagamentos registrados.

RN15	Perdas, quebras e vencimentos devem ser registrados como movimentações de saída, com seus respectivos motivos.

RN16	Os ajustes de estoque devem registrar a quantidade ajustada, a data, o motivo e o funcionário responsável.

RN17	A quantidade disponível em estoque deve ser atualizada conforme as entradas e saídas registradas.

RN18	A validade dos produtos que necessitam desse controle deve ser registrada por lote.

RN19	Produtos vencidos não devem ser disponibilizados para venda e devem ter sua saída registrada.

RN20	Cada item de compra deve identificar o produto e a quantidade comprada.

RN21	A conferência do recebimento deve permitir identificar produtos faltantes, incorretos ou avariados.

RN22	A abertura de caixa deve registrar o funcionário responsável e o valor inicial.

RN23	O fechamento de caixa deve comparar o valor esperado com o valor contado e registrar possíveis diferenças.

RN24	As movimentações financeiras devem estar associadas ao caixa correspondente, conforme o tipo de operação.

RN25	A escala deve identificar o funcionário, o dia, o horário e a função exercida.

RN26	O sistema deve impedir a venda de bebidas alcoólicas para menores de 18 anos.

RN27	O sistema deve respeitar as restrições legais aplicáveis à comercialização de produtos de tabaco.

RN28	A emissão e o registro de documentos fiscais devem respeitar as exigências legais aplicáveis à organização.

RN29	Os dados pessoais devem ser tratados conforme a LGPD, com acesso limitado e utilização adequada à finalidade do sistema.

RN30	Ações importantes realizadas no sistema devem poder ser registradas para fins de auditoria.
