Requisitos funcionais

Código	Requisito funcional

RF01	O sistema deve permitir cadastrar produtos com nome, categoria, preço, código de barras, quando aplicável, e situação.

RF02	O sistema deve permitir consultar produtos, preços e quantidades disponíveis em estoque.

RF03	O sistema deve permitir controlar a quantidade disponível de cada produto.

RF04	O sistema deve permitir registrar entradas de produtos, informando produto, quantidade, data e origem da entrada.

RF05	O sistema deve permitir registrar saídas de produtos, identificando o motivo da movimentação.

RF06	O sistema deve permitir registrar a abertura de garrafas destinadas à venda de doses como saída de estoque.

RF07	O sistema deve permitir registrar vendas com data, funcionário, caixa, produtos, quantidades, preços unitários e valor total.

RF08	O sistema deve permitir registrar uma ou mais formas de pagamento utilizadas em uma venda.

RF09	O sistema deve permitir cadastrar clientes e registrar quais estão autorizados a realizar compras por fiado. O cliente é cadastrado bloqueado para fiado e só é liberado pelo gerente, que também define o limite.

RF10	O sistema deve permitir registrar fiados vinculados a uma venda, identificando o cliente e os itens que ficaram pendentes.

RF11	O sistema deve permitir registrar e consultar o limite de fiado de cada cliente e verificar o limite disponível antes de uma nova operação.

RF12	O sistema deve permitir cadastrar fornecedores com seus dados de identificação e contato.

RF13	O sistema deve permitir registrar compras de fornecedores, incluindo produtos, quantidades, preços e valores.

RF14	O sistema deve permitir identificar produtos que estejam no estoque mínimo ou abaixo dele.

RF15	O sistema deve permitir consultar os produtos com maior quantidade vendida em determinado período.

RF16	O sistema deve permitir cadastrar funcionários e identificar os responsáveis pelas vendas, compras e movimentações de estoque.

RF17	O sistema deve permitir registrar a abertura do caixa, informando o funcionário responsável e o valor inicial.

RF18	O sistema deve permitir registrar o fechamento do caixa, calcular o valor esperado, comparar com o valor contado e registrar justificativas para diferenças.

RF19	O sistema deve permitir registrar pagamentos totais ou parciais de fiado, atualizando o saldo devedor.

RF20	O sistema deve permitir registrar lotes de produtos com suas respectivas quantidades e datas de validade.

RF21	O sistema deve permitir identificar produtos vencidos ou próximos do vencimento.

RF22	O sistema deve permitir cadastrar escalas dos funcionários, informando dia, horário e função.

RF23	O sistema deve permitir registrar perdas, quebras e ajustes de estoque, identificando o motivo e o funcionário responsável.

RF24	O sistema deve permitir registrar a conferência dos itens recebidos em compras e suas possíveis divergências.

RF25	O sistema deve permitir registrar suprimentos, sangrias e despesas em dinheiro no caixa aberto, para que o valor esperado do fechamento considere essas movimentações.

RF26	O sistema deve permitir controlar o volume restante de cada garrafa aberta para venda de doses, impedindo a venda de doses acima do volume disponível.


Requisitos não funcionais


RNF01	Facilidade de uso: a interface deve ser simples e intuitiva para os funcionários.	Avaliação de uso com funcionário da adega.

RNF02	Rapidez: as consultas de produtos, preços e estoque devem apresentar resultados rapidamente.	Meta proposta de até 2 segundos para consultas comuns.

RNF03	Integridade: os dados de vendas, compras e estoque devem permanecer consistentes.	Verificação por consultas de auditoria.

RNF04	Segurança: o acesso às funcionalidades deve respeitar as permissões de cada usuário.	Perfis de atendente e gerente, se implementados.

RNF05	Disponibilidade: as informações devem estar disponíveis durante o horário de funcionamento.	Meta proposta de até 15 minutos de indisponibilidade por semana no horário de funcionamento.

RNF06	Cópia de segurança: o sistema deve permitir cópias de segurança dos dados.	Meta proposta de pelo menos uma cópia por dia.

RNF07	Compatibilidade: o sistema deve permitir utilização em computadores e dispositivos móveis.	Testes em computador e celular.

RNF08	Proteção de dados pessoais: os dados de clientes e funcionários devem ser tratados conforme a LGPD.	Acesso restrito e tratamento adequado dos dados.

RNF09	Manutenibilidade: a estrutura deve facilitar futuras alterações e correções.	Organização das tabelas, relacionamentos e documentação.
