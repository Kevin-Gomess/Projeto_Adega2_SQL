## Regras de Negócio

- **RN01 — Formas de pagamento:** Uma venda pode ser paga em dinheiro, Pix, cartão de débito ou cartão de crédito. Também pode ter uma parte do valor lançada como fiado, desde que sejam atendidas as regras de autorização e limite do cliente.

- **RN02 — Registro da venda:** Toda venda deve possuir data e hora, funcionário responsável, caixa relacionado e pelo menos um item registrado.

- **RN03 — Cálculo da venda:** O valor total da venda deve corresponder à soma dos subtotais dos itens, considerando os descontos aplicados.

- **RN04 — Itens da venda:** Cada item de uma venda deve identificar o produto, o tipo de comercialização, a quantidade e o preço unitário aplicado no momento da venda.

- **RN05 — Registro de movimentação:** Toda movimentação de estoque deve identificar o produto, o tipo de movimentação, a quantidade, a data e o funcionário responsável.

- **RN06 — Venda de doses:** Quando uma garrafa for aberta para venda de doses, a abertura deve ser registrada como saída de uma unidade fechada do estoque, conforme o controle adotado para o produto. O volume restante da garrafa aberta é controlado em mililitros e cada dose vendida o reduz; não se vende dose acima do volume restante.

- **RN07 — Pagamento dividido:** Uma venda pode possuir mais de um registro de pagamento. A soma dos valores registrados nas diferentes formas de pagamento, incluindo a parcela destinada ao fiado, deve corresponder ao total da venda. O valor lançado como fiado deve gerar ou atualizar a conta correspondente do cliente.

- **RN08 — Identificação do cliente:** Para realizar uma operação com fiado, o cliente deve estar cadastrado e identificado no sistema.

- **RN09 — Relação do fiado com a venda:** Toda conta de fiado deve estar relacionada à venda que originou o valor pendente e ao cliente responsável pela dívida.

- **RN10 — Limite de fiado:** Cada cliente deve possuir um limite de crédito definido no cadastro. O valor pendente não pode ultrapassar o limite autorizado.

- **RN11 — Verificação antes do fiado:** Antes de registrar uma nova parcela no fiado, o sistema deve verificar se o cliente não está bloqueado e se possui limite disponível. O limite disponível corresponde ao limite cadastrado menos os valores ainda pendentes.

- **RN12 — Atualização do saldo:** Todo pagamento de fiado deve ser considerado no cálculo do valor já pago e do saldo pendente da conta.

- **RN13 — Registro de pagamento de fiado:** Cada recebimento de fiado deve registrar a conta correspondente, o valor recebido, a forma de pagamento, a data e o caixa responsável.

- **RN14 — Situação do fiado:** Uma conta deve permanecer com situação ABERTO enquanto o valor pago for menor que o valor total devido. Quando o valor pago alcançar o valor total, a situação deve ser QUITADO.

- **RN15 — Registro de perdas:** Produtos perdidos, quebrados, vencidos ou retirados por outros motivos devem ter sua saída registrada com a quantidade, a data, o motivo e o funcionário responsável.

- **RN16 — Ajuste de estoque:** Toda correção manual de estoque deve registrar a quantidade movimentada, a data, o motivo e o funcionário responsável.

- **RN17 — Atualização do estoque:** O saldo do estoque deve refletir as entradas e saídas registradas nas movimentações.

- **RN18 — Controle por lote:** Produtos que exigem controle de validade devem possuir registro de lote e data de vencimento.

- **RN19 — Produtos vencidos:** Produtos com validade vencida não devem ser disponibilizados para venda e sua retirada deve ser registrada no estoque.

- **RN20 — Itens de compra:** Cada item de uma compra deve identificar o produto, a quantidade solicitada e o custo unitário.

- **RN21 — Conferência de recebimento:** No recebimento de uma compra, a quantidade recebida deve ser conferida com a quantidade solicitada. Faltas, produtos incorretos ou avarias devem ser registrados.

- **RN22 — Abertura de caixa:** Toda abertura de caixa deve registrar o funcionário responsável, a data e hora e o valor inicial disponível.

- **RN23 — Fechamento de caixa:** No fechamento, o valor contado deve ser comparado com o valor esperado. O valor esperado considera o troco inicial, as vendas e os recebimentos de fiado em dinheiro, os suprimentos e, como saída, as sangrias e despesas. Diferenças devem ser registradas e justificadas.

- **RN24 — Relação dos movimentos com o caixa:** Vendas e recebimentos de fiado devem ser relacionados ao caixa em que ocorreram, para permitir a conferência dos valores.

- **RN25 — Registro de escala:** Toda escala deve identificar o funcionário, o dia de trabalho, o horário de início, o horário de término e a função exercida.

- **RN26 — Venda de bebidas alcoólicas:** É proibido vender, fornecer ou entregar bebidas alcoólicas a crianças e adolescentes menores de 18 anos. A maioridade deve ser conferida antes da conclusão da venda.

- **RN27 — Comercialização de produtos de tabaco:** A comercialização de produtos fumígenos deve respeitar as restrições legais, incluindo a proibição de venda a menores de 18 anos, as advertências sanitárias obrigatórias e as regras de exposição dos produtos nos pontos de venda.

- **RN28 — Documentos fiscais:** As operações de venda e compra devem ter seus documentos fiscais registrados e emitidos conforme as obrigações aplicáveis ao enquadramento tributário e à legislação estadual da organização.

- **RN29 — Proteção de dados pessoais:** Os dados pessoais de clientes e funcionários devem ser utilizados somente para finalidades relacionadas às atividades da organização, com acesso restrito e tratamento adequado conforme a LGPD.

- **RN30 — Auditoria:** As operações importantes do sistema, como acessos, inclusões, alterações, exclusões e consultas a dados pessoais, devem possuir registro de auditoria, identificando o funcionário, a data, o tipo de evento e o registro envolvido.
