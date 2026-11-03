Adega do Tonho — Projeto de Banco de Dados

Integrantes

Nome completo do aluno	RGM	Usuário do GitHub

Kevin Gomes	47796006	[PREENCHER]

Brayan Antonio Daza Paredes	50184857	[PREENCHER]

Gabriel dos Santos Eufrasio	49005260	[PREENCHER]

Gabriel Gonçalves Moura	48892009	[PREENCHER]

Felipe Militão	49331108	[PREENCHER]


1. Relatório Técnico Final
1.1 Revisão do Modelo Conceitual
1.1.1 Caracterização da organização
Nome e natureza da organização

A organização escolhida é a Adega do Tonho, um comércio de pequeno porte, com fins lucrativos, que atua na venda de bebidas, alimentos, produtos para narguilé, cigarros e outros produtos de conveniência.

A Adega do Tonho é a mesma organização utilizada na Entrega 1, mantendo a continuidade do levantamento e da modelagem.

Contexto e porte
- Tempo de funcionamento: aproximadamente 4 anos.
- Pessoas envolvidas: cerca de 3 a 4 pessoas, conforme o dia.
- Horário de funcionamento: de segunda a quinta-feira, das 13h às 23h; de sexta-feira a domingo, das 13h à meia-noite.
- Produtos comercializados: refrigerantes, cervejas, bebidas alcoólicas, doces, salgadinhos, sucos, itens de mercearia, produtos para narguilé, cigarros e isqueiros.
- Também existem bebidas destinadas à venda em doses.
- Estrutura física: a parte da frente é utilizada para atendimento e exposição dos produtos, enquanto os fundos são utilizados como estoque.
Informações quantitativas da organização

Os números abaixo ainda precisam ser confirmados com o responsável. Não devem ser apresentados como dados levantados enquanto não forem verificados.
- Quantidade aproximada de produtos cadastrados: [PREENCHER após confirmação].
- Média aproximada de vendas por dia ou por semana: [PREENCHER após confirmação].
- Quantidade aproximada de clientes autorizados a comprar no fiado: [PREENCHER após confirmação].
- Quantidade aproximada de compras realizadas com fornecedores por mês: [PREENCHER após confirmação].
Problemas e necessidades identificados

Com base no levantamento realizado na Entrega 1, foram identificadas necessidades relacionadas ao registro das operações, ao controle de estoque e ao acompanhamento das vendas e do fiado.
Código	Problema identificado	Como o sistema poderá ajudar
P1	Nas vendas comuns, não existe registro detalhado de cada produto vendido.	Registrar cada venda e seus respectivos itens, quantidades e preços.
P2	Existem diferenças entre as quantidades anotadas e o estoque real.	Registrar entradas, saídas, perdas e ajustes de estoque.
P3	Existe dificuldade para identificar quais produtos apresentam maior saída.	Consultar os produtos mais vendidos por período.
P4	A identificação de produtos que estão acabando depende principalmente da observação visual.	Permitir o acompanhamento das quantidades disponíveis e dos limites mínimos de estoque.
P5	O controle do fiado é realizado manualmente, dificultando o acompanhamento dos valores devidos e dos recebimentos.	Registrar clientes, vendas fiadas, valores devidos e pagamentos realizados.


Escopo do sistema

O sistema proposto contempla a gestão das principais informações da Adega do Tonho, incluindo:
- Cadastro de produtos e categorias;
- Controle de estoque;
- Registro de movimentações de estoque;
- Registro de vendas e itens vendidos;
- Registro das formas de pagamento;
- Cadastro de clientes;
- Controle de fiado e seus recebimentos;
- Cadastro de fornecedores;
- Registro de compras e itens comprados;
- Controle de lotes e datas de validade;
- Cadastro de funcionários e escalas;
- Controle de abertura e fechamento de caixa;
- Registro de ações importantes realizadas no sistema.
O modelo conceitual possui 18 entidades de negócio. Na implementação lógica há 21 tabelas: as 18 correspondentes às entidades de negócio e três tabelas de apoio criadas na implementação: log_acesso (registro de eventos e auditoria), garrafa_aberta (volume restante das garrafas abertas para dose) e movimentacao_caixa (suprimentos, sangrias e despesas do caixa).

Justificativa da escolha

A Adega do Tonho foi escolhida por ser uma organização real, de pequeno porte, que apresenta processos de vendas, compras, pagamentos, controle de estoque e fiado.

Um dos integrantes do grupo possui vínculo de trabalho com a adega e acompanha parte da rotina de funcionamento. Esse contato facilitou o levantamento das informações e a compreensão dos processos realizados no estabelecimento.

Evidências da organização

As evidências da existência da organização e da pesquisa de campo devem estar disponíveis na pasta [`evidencias/`](evidencias/).
- Endereço completo: [PREENCHER].
- Perfil no Google Maps: [PREENCHER LINK].
- Site ou rede social: [PREENCHER, se houver].
- Fotografias do estabelecimento e da visita: [INFORMAR NOMES DOS ARQUIVOS JPG OU PNG].
Responsável pela organização
- Nome: [PREENCHER].
- Função: [PREENCHER].
- Telefone para contato: [PREENCHER, somente com autorização do responsável].
1.1.2 Relato da entrevista
Quem participou
- Entrevistado: [PREENCHER NOME E FUNÇÃO].
- Integrantes participantes: [PREENCHER].
Quando e onde
- Data da entrevista: [PREENCHER].
- Local: Adega do Tonho, no próprio estabelecimento.
Comprovação

A comprovação da pesquisa de campo deve ser disponibilizada na pasta [`evidencias/`](evidencias/), por meio de fotografias em formato JPG ou PNG.

Principais informações levantadas

Durante o levantamento, foram identificadas as seguintes características da rotina:
- Os preços dos produtos são consultados em cadernos ou etiquetas.
- Nas vendas comuns, os produtos são entregues após o pagamento, mas não existe um registro detalhado de cada item vendido.
- Nas vendas realizadas por fiado, são anotados os produtos retirados e os valores devidos.
- As compras de fornecedores são anotadas no celular, contendo os produtos e suas respectivas quantidades.
- Quando os produtos chegam, é realizada uma conferência item por item.
- A falta de produtos costuma ser percebida pela observação das prateleiras e do estoque.
- Quando uma garrafa é aberta para a venda de doses, ela deixa de ser comercializada como uma garrafa fechada.
- Existem diferenças entre as quantidades anotadas e as quantidades encontradas fisicamente no estoque.
- O fiado é restrito a clientes conhecidos ou autorizados, não sendo disponibilizado livremente para qualquer pessoa.
Achados da observação presencial

A observação da rotina permitiu compreender a organização dos produtos na parte da frente e nos fundos do estabelecimento, a consulta de preços, o atendimento aos clientes, as anotações de compras e a conferência das mercadorias recebidas.

[COMPLEMENTAR: separar quais informações foram observadas diretamente e quais foram confirmadas pelas respostas do responsável.]

Atualizações em relação à Entrega 1

Após a avaliação da primeira entrega, o grupo revisou o modelo conceitual e ampliou a cobertura dos processos.

Foram acrescentados ao sistema proposto:
- Controle de abertura e fechamento de caixa;
- Registro de recebimentos e quitação de fiado;
- Controle de validade por lote;
- Registro de perdas e quebras;
- Cadastro de escalas dos funcionários;
- Registro de ações importantes para auditoria.
Esses recursos foram incluídos como propostas de funcionamento do sistema. Sua inclusão no modelo não significa que todos esses controles já sejam realizados atualmente pela adega.

Também foi esclarecido que o fiado é restrito a clientes conhecidos ou autorizados.

[INFORMAR SE HOUVE NOVA VISITA OU CONFIRMAÇÃO COM O RESPONSÁVEL APÓS A ENTREGA 1.]
1.1.3 Processos de negócio
Os processos detalhados e seus respectivos fluxogramas estão disponíveis em [`Levantamento/processos.md`](Levantamento/processos.md).
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


Processos típicos não incluídos
Processo provável	Justificativa
Entrega em domicílio	Não foi identificada no levantamento da Entrega 1. Confirmar com o responsável se a adega realiza esse serviço.
Folha de pagamento	Não faz parte do escopo definido para o sistema de gestão de vendas, estoque, compras e fiado.
Programa de fidelidade	Não foi identificado como processo existente no levantamento.
Emissão de documento fiscal pelo sistema	A emissão não foi definida como funcionalidade do sistema proposto. A necessidade e o procedimento devem ser confirmados com o responsável.


1.1.4 Requisitos do sistema
O levantamento completo dos requisitos está disponível em [`Levantamento/Requisitos.md`](Levantamento/Requisitos.md).

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
Código	Requisito não funcional	Critério ou medida proposta
RNF01	Facilidade de uso: a interface deve ser simples e intuitiva para os funcionários.	Avaliação de uso com funcionário da adega.
RNF02	Rapidez: as consultas de produtos, preços e estoque devem apresentar resultados rapidamente.	Meta proposta de até 2 segundos para consultas comuns.
RNF03	Integridade: os dados de vendas, compras e estoque devem permanecer consistentes.	Verificação por consultas de auditoria.
RNF04	Segurança: o acesso às funcionalidades deve respeitar as permissões de cada usuário.	Perfis de atendente e gerente, se implementados.
RNF05	Disponibilidade: as informações devem estar disponíveis durante o horário de funcionamento.	Meta proposta de até 15 minutos de indisponibilidade por semana no horário de funcionamento.
RNF06	Cópia de segurança: o sistema deve permitir cópias de segurança dos dados.	Meta proposta de pelo menos uma cópia por dia.
RNF07	Compatibilidade: o sistema deve permitir utilização em computadores e dispositivos móveis.	Testes em computador e celular.
RNF08	Proteção de dados pessoais: os dados de clientes e funcionários devem ser tratados conforme a LGPD.	Acesso restrito e tratamento adequado dos dados.
RNF09	Manutenibilidade: a estrutura deve facilitar futuras alterações e correções.	Organização das tabelas, relacionamentos e documentação.


1.1.5 Regras de negócio
As regras completas estão disponíveis em [`Levantamento/regras_de_negocio.md`](Levantamento/regras_de_negocio.md).

As regras abaixo representam condições operacionais e restrições consideradas no sistema. As regras propostas devem ser validadas com o responsável antes de serem tratadas como procedimentos já vigentes na adega.
Código	Regra de negócio
RN01	Uma venda pode ser paga em dinheiro, Pix, cartão de débito ou cartão de crédito. Também pode ter uma parte do valor lançada como fiado, desde que sejam atendidas as regras de autorização e limite do cliente.
RN02	Toda venda deve possuir data e hora, funcionário responsável, caixa relacionado e pelo menos um item registrado.
RN03	O valor total da venda deve corresponder à soma dos subtotais dos itens, considerando os descontos aplicados.
RN04	Cada item de uma venda deve identificar o produto, o tipo de comercialização, a quantidade e o preço unitário aplicado no momento da venda.
RN05	Toda movimentação de estoque deve identificar o produto, o tipo de movimentação, a quantidade, a data e o funcionário responsável.
RN06	Quando uma garrafa for aberta para venda de doses, a abertura deve ser registrada como saída de uma unidade fechada do estoque, conforme o controle adotado para o produto. O volume restante da garrafa aberta é controlado em mililitros e cada dose vendida o reduz; não se vende dose acima do volume restante.
RN07	Uma venda pode possuir mais de um registro de pagamento. A soma dos valores registrados nas diferentes formas de pagamento, incluindo a parcela destinada ao fiado, deve corresponder ao total da venda. O valor lançado como fiado deve gerar ou atualizar a conta correspondente do cliente.
RN08	Para realizar uma operação com fiado, o cliente deve estar cadastrado e identificado no sistema.
RN09	Toda conta de fiado deve estar relacionada à venda que originou o valor pendente e ao cliente responsável pela dívida.
RN10	Cada cliente deve possuir um limite de crédito definido no cadastro. O valor pendente não pode ultrapassar o limite autorizado.
RN11	Antes de registrar uma nova parcela no fiado, o sistema deve verificar se o cliente não está bloqueado e se possui limite disponível. O limite disponível corresponde ao limite cadastrado menos os valores ainda pendentes.
RN12	Todo pagamento de fiado deve ser considerado no cálculo do valor já pago e do saldo pendente da conta.
RN13	Cada recebimento de fiado deve registrar a conta correspondente, o valor recebido, a forma de pagamento, a data e o caixa responsável.
RN14	Uma conta deve permanecer com situação ABERTO enquanto o valor pago for menor que o valor total devido. Quando o valor pago alcançar o valor total, a situação deve ser QUITADO.
RN15	Produtos perdidos, quebrados, vencidos ou retirados por outros motivos devem ter sua saída registrada com a quantidade, a data, o motivo e o funcionário responsável.
RN16	Toda correção manual de estoque deve registrar a quantidade movimentada, a data, o motivo e o funcionário responsável.
RN17	O saldo do estoque deve refletir as entradas e saídas registradas nas movimentações.
RN18	Produtos que exigem controle de validade devem possuir registro de lote e data de vencimento.
RN19	Produtos com validade vencida não devem ser disponibilizados para venda e sua retirada deve ser registrada no estoque.
RN20	Cada item de uma compra deve identificar o produto, a quantidade solicitada e o custo unitário.
RN21	No recebimento de uma compra, a quantidade recebida deve ser conferida com a quantidade solicitada. Faltas, produtos incorretos ou avarias devem ser registrados.
RN22	Toda abertura de caixa deve registrar o funcionário responsável, a data e hora e o valor inicial disponível.
RN23	No fechamento, o valor contado deve ser comparado com o valor esperado. O valor esperado considera o troco inicial, as vendas e os recebimentos de fiado em dinheiro, os suprimentos e, como saída, as sangrias e despesas. Diferenças devem ser registradas e justificadas.
RN24	Vendas e recebimentos de fiado devem ser relacionados ao caixa em que ocorreram, para permitir a conferência dos valores.
RN25	Toda escala deve identificar o funcionário, o dia de trabalho, o horário de início, o horário de término e a função exercida.
RN26	É proibido vender, fornecer ou entregar bebidas alcoólicas a crianças e adolescentes menores de 18 anos. A maioridade deve ser conferida antes da conclusão da venda.
RN27	A comercialização de produtos fumígenos deve respeitar as restrições legais, incluindo a proibição de venda a menores de 18 anos, as advertências sanitárias obrigatórias e as regras de exposição dos produtos nos pontos de venda.
RN28	As operações de venda e compra devem ter seus documentos fiscais registrados e emitidos conforme as obrigações aplicáveis ao enquadramento tributário e à legislação estadual da organização.
RN29	Os dados pessoais de clientes e funcionários devem ser utilizados somente para finalidades relacionadas às atividades da organização, com acesso restrito e tratamento adequado conforme a LGPD.
RN30	As operações importantes do sistema, como acessos, inclusões, alterações, exclusões e consultas a dados pessoais, devem possuir registro de auditoria, identificando o funcionário, a data, o tipo de evento e o registro envolvido.


Observação sobre implementação: prazos específicos para pagamento de fiado, período de aviso de vencimento e demais limites operacionais dependem de confirmação do responsável. O controle de fiados vencidos também depende da existência de um prazo ou data de vencimento armazenada. Não apresentar esses controles como implementados enquanto não forem confirmados e incluídos no modelo e no SQL.
1.1.6 DER conceitual revisado
O DER conceitual foi revisado considerando os apontamentos da avaliação da Entrega 1 e a ampliação dos processos contemplados pelo sistema.
- Arquivo: Diagramas/der_conceitual [CONFERIR NOME E EXTENSÃO DO ARQUIVO].
- Software utilizado: brModelo [PREENCHER VERSÃO].
Principais alterações realizadas
Apontamento da avaliação da Entrega 1	Alteração realizada	Justificativa
DER apresentava apenas cardinalidades máximas.	Inclusão das cardinalidades mínimas e máximas nos relacionamentos.	Permitir compreender a participação obrigatória ou opcional das entidades.
Chaves estrangeiras apareciam no modelo conceitual.	Retirada das chaves estrangeiras do DER conceitual.	As FKs pertencem ao modelo lógico.
Relacionamentos de estoque e venda estavam inconsistentes.	A movimentação de estoque passou a representar entradas e saídas relacionadas aos produtos.	Evitar relacionamento direto inadequado entre venda e estoque.
Relacionamentos de pagamento apresentavam duplicidade.	Organização do pagamento da venda e do recebimento de fiado em estruturas próprias.	Diferenciar o pagamento da venda do recebimento posterior da dívida.
Faltavam relações com funcionários.	Inclusão das relações entre funcionários, vendas, compras, escalas e movimentações.	Identificar os responsáveis pelas operações.
O modelo não contemplava adequadamente validade e lotes.	Inclusão da entidade LOTE e de sua relação com os itens de compra e movimentações.	Permitir controlar diferentes datas de validade de um mesmo produto.
Não existia representação de caixa.	Inclusão da entidade CAIXA.	Permitir representar as operações de caixa previstas no sistema.
Processos de negócio estavam incompletos.	Ampliação do modelo para contemplar recebimento de fiado, caixa, perdas, validade e escala.	Aumentar a cobertura dos processos da organização.


Entidades do modelo conceitual

O DER revisado contém as seguintes 18 entidades de negócio:
1. CATEGORIA
2. PRODUTO
3. ESTOQUE
4. FUNCIONARIO
5. ESCALA
6. CAIXA
7. VENDA
8. ITEM_VENDA
9. PAGAMENTO
10. CLIENTE
11. FIADO
12. ITEM_FIADO
13. PAGAMENTO_FIADO
14. FORNECEDOR
15. COMPRA
16. ITEM_COMPRA
17. LOTE
18. MOVIMENTACAO_ESTOQUE
As tabelas LOG_ACESSO, GARRAFA_ABERTA e MOVIMENTACAO_CAIXA foram acrescentadas na implementação lógica, com finalidade técnica e de controle, e não são entidades de negócio do DER conceitual. [CONFERIR com o grupo: se preferirem, incluir essas duas últimas no DER conceitual para o diagrama refletir as 20 entidades de negócio.]
1.2 Conversão do Modelo Conceitual para o Modelo Lógico
A conversão do modelo conceitual para o modelo lógico foi realizada transformando as entidades em tabelas, seus atributos em colunas e os relacionamentos em chaves primárias e estrangeiras.

Entidades transformadas em tabelas

Cada entidade do DER conceitual foi convertida em uma tabela relacional. Os atributos foram definidos como colunas, respeitando seus tipos de dados e suas finalidades.

Conversão dos relacionamentos
- Relacionamentos 1:N: foram implementados por meio de chaves estrangeiras no lado N.
- Relacionamentos 1:1: foram implementados por meio de chaves estrangeiras com restrição de unicidade, quando aplicável.
- Relacionamentos N:N: foram representados por tabelas associativas, como ITEM_VENDA e ITEM_COMPRA.
- O relacionamento entre ITEM_VENDA e ITEM_FIADO permite identificar quais linhas de uma venda tiveram valor lançado no fiado. A tabela ITEM_FIADO contém id_item_fiado, id_item_venda (único), vl_fiado e dt_lancamento; produto, quantidade e preço são consultados em ITEM_VENDA, e vl_fiado diz quanto da linha foi para o fiado (no máximo o subtotal), o que permite pagamento dividido.
- ITEM_VENDA guarda também id_lote (lote de onde saiu a unidade) e id_garrafa_aberta (garrafa de onde saiu a dose), ambos opcionais e chaves estrangeiras.
- GARRAFA_ABERTA possui FKs para LOTE, PRODUTO e FUNCIONARIO; MOVIMENTACAO_CAIXA possui FKs para CAIXA e FUNCIONARIO.
- A tabela FIADO possui as FKs id_venda e id_cliente. O campo fiado.id_venda é UNIQUE; portanto, uma venda pode gerar no máximo um registro de fiado.
- A tabela PAGAMENTO não possui id_fiado. Quando o pagamento da venda é do tipo fiado, a associação ao fiado ocorre por meio da venda de origem. Os recebimentos posteriores são registrados em PAGAMENTO_FIADO, que possui FKs para FIADO e CAIXA.
- Não existe relacionamento direto entre FIADO e ITEM_FIADO; a ligação é realizada por ITEM_VENDA.
- A relação entre ITEM_COMPRA e LOTE permite associar um ou vários lotes ao item de compra que lhes deu origem. No SQL, lote.id_item_compra é FK sem UNIQUE.
- A tabela LOG_ACESSO possui referência opcional a FUNCIONARIO, pois id_funcionario aceita NULL.
Decisões de conversão

A tabela ESTOQUE mantém o controle da quantidade total de cada produto. A organização física do estoque não foi dividida em diferentes locais no modelo, pois o levantamento não identificou a necessidade de controlar quantidades separadamente por localização.

A relação conceitual entre PRODUTO e ESTOQUE foi definida como 1:1. No SQL, estoque.id_produto possui NOT NULL e UNIQUE, garantindo que cada registro de estoque esteja associado a um único produto e impedindo mais de um registro de estoque para o mesmo produto. Essa restrição, sozinha, não obriga que todo produto tenha estoque; por isso o trigger trg_produto_cria_estoque cria o registro de estoque a cada produto inserido, garantindo na prática a participação obrigatória.

O controle de validade foi estruturado por lote, pois um mesmo produto pode possuir diferentes datas de vencimento.

O fiado foi modelado como um registro associado à venda de origem, mantendo os recebimentos posteriores em uma tabela própria. Dessa forma, o pagamento da venda e a quitação da dívida são operações distintas.

Autorização para fiado

A regra de negócio diz que o fiado só é concedido a clientes conhecidos e autorizados. No SQL isso é feito com cliente.fl_bloqueado, que nasce com valor 1 (bloqueado). Somente o gerente libera o cliente e define o limite, pela procedure sp_autorizar_cliente_fiado, e a procedure sp_registrar_venda_fiado recusa cliente bloqueado ou sem limite disponível. Por isso não foi criado um campo fl_fiado_autorizado separado.

Arquivos do modelo lógico
- Arquivo editável: [`Diagramas/modelo_logico.brm`](Diagramas/modelo_logico.brm).
- Imagem: [`Diagramas/modelo_logico.png`](Diagramas/modelo_logico.png).
- Software utilizado: brModelo [PREENCHER VERSÃO].
1.3 Definição de Chaves Primárias e Estrangeiras
As chaves primárias identificam exclusivamente cada registro. As chaves estrangeiras estabelecem os relacionamentos entre as tabelas e ajudam a manter a integridade referencial.

A relação completa das PKs e FKs deve seguir exatamente o modelo lógico e o script SQL oficial do grupo.

Conferência dos 30 relacionamentos do modelo lógico

A tabela abaixo resume as relações representadas no modelo lógico. A notação apresenta as cardinalidades mínimas e máximas de cada lado.
Nº	Relacionamento	FK no SQL
1	Categoria (0,N) — Produto (1,1)	produto.id_categoria
2	Produto (1,1) — Estoque (1,1)	estoque.id_produto
3	Produto (0,N) — Movimentação de Estoque (1,1)	movimentacao_estoque.id_produto
4	Funcionário (0,N) — Movimentação de Estoque (1,1)	movimentacao_estoque.id_funcionario
5	Lote (0,N) — Movimentação de Estoque (0,1)	movimentacao_estoque.id_lote
6	Item da Compra (0,N) — Lote (1,1)	lote.id_item_compra
7	Funcionário (0,N) — Escala (1,1)	escala.id_funcionario
8	Funcionário (0,N) — Caixa (1,1)	caixa.id_funcionario
9	Funcionário (0,N) — Venda (1,1)	venda.id_funcionario
10	Caixa (0,N) — Venda (1,1)	venda.id_caixa
11	Venda (1,N) — Item da Venda (1,1)	item_venda.id_venda
12	Produto (0,N) — Item da Venda (1,1)	item_venda.id_produto
13	Venda (1,N) — Pagamento (1,1)	pagamento.id_venda
14	Cliente (0,N) — Fiado (1,1)	fiado.id_cliente
15	Fiado (0,N) — Pagamento do Fiado (1,1)	pagamento_fiado.id_fiado
16	Caixa (0,N) — Pagamento do Fiado (1,1)	pagamento_fiado.id_caixa
17	Venda (0,1) — Fiado (1,1)	fiado.id_venda
18	Item da Venda (0,1) — Item do Fiado (1,1)	item_fiado.id_item_venda
19	Fornecedor (0,N) — Compra (1,1)	compra.id_fornecedor
20	Funcionário (0,N) — Compra (1,1)	compra.id_funcionario
21	Compra (1,N) — Item da Compra (1,1)	item_compra.id_compra
22	Produto (0,N) — Item da Compra (1,1)	item_compra.id_produto
23	Funcionário (0,N) — Log de Acesso (0,1)	log_acesso.id_funcionario
24	Lote (0,N) — Item da Venda (0,1)	item_venda.id_lote
25	Garrafa Aberta (0,N) — Item da Venda (0,1)	item_venda.id_garrafa_aberta
26	Lote (0,N) — Garrafa Aberta (1,1)	garrafa_aberta.id_lote
27	Produto (0,N) — Garrafa Aberta (1,1)	garrafa_aberta.id_produto
28	Funcionário (0,N) — Garrafa Aberta (1,1)	garrafa_aberta.id_funcionario
29	Caixa (0,N) — Movimentação do Caixa (1,1)	movimentacao_caixa.id_caixa
30	Funcionário (0,N) — Movimentação do Caixa (1,1)	movimentacao_caixa.id_funcionario


Pontos de atenção na conferência do diagrama
- fiado.id_venda é FK com UNIQUE; por isso, uma venda pode estar associada a no máximo um fiado.
- item_fiado.id_item_venda é FK com UNIQUE; por isso, um item da venda pode estar associado a no máximo um item do fiado.
- lote.id_item_compra não possui UNIQUE; um item de compra pode originar vários lotes.
- movimentacao_estoque.id_lote aceita NULL; por isso, uma movimentação pode não estar vinculada a um lote.
- pagamento não possui FK direta para fiado.
- estoque.id_produto é UNIQUE e o trigger trg_produto_cria_estoque cria o registro de estoque (zerado) a cada produto cadastrado; assim todo produto passa a ter estoque, embora a restrição de chave sozinha não exija isso.
- item_venda.id_lote e item_venda.id_garrafa_aberta aceitam NULL: o lote é exigido pelo trigger quando o produto controla validade e o item é UNIDADE; a garrafa é exigida quando o item é DOSE.
- log_acesso.id_funcionario aceita NULL; por isso, o vínculo do registro de auditoria com um funcionário é opcional.
Tabelas e suas chaves principais
Tabela	Chave primária	Referências principais
categoria	id_categoria	—
produto	id_produto	id_categoria
estoque	id_estoque	id_produto
funcionario	id_funcionario	—
escala	id_escala	id_funcionario
caixa	id_caixa	id_funcionario
cliente	id_cliente	—
venda	id_venda	id_funcionario, id_caixa
item_venda	id_item_venda	id_venda, id_produto, id_lote (opcional), id_garrafa_aberta (opcional)
pagamento	id_pagamento	id_venda
fiado	id_fiado	id_cliente, id_venda
item_fiado	id_item_fiado	id_item_venda
pagamento_fiado	id_pagamento_fiado	id_fiado, id_caixa
fornecedor	id_fornecedor	—
compra	id_compra	id_fornecedor, id_funcionario
item_compra	id_item_compra	id_compra, id_produto
lote	id_lote	id_item_compra
movimentacao_estoque	id_movimentacao	id_produto, id_lote, id_funcionario
garrafa_aberta	id_garrafa_aberta	id_lote, id_produto, id_funcionario
movimentacao_caixa	id_movimentacao_caixa	id_caixa, id_funcionario
log_acesso	id_log	id_funcionario (FK, aceita NULL)


Observação: a lista é um resumo das referências principais. Os nomes, a obrigatoriedade e as restrições devem ser conferidos com o arquivo SQL definitivo antes da entrega.
1.4 Processo de Normalização (1FN, 2FN e 3FN)
A normalização foi aplicada para organizar os dados, reduzir repetições e evitar inconsistências durante as operações de cadastro, venda, compra e controle de estoque.

Primeira Forma Normal (1FN)

A primeira forma normal exige que cada coluna contenha valores atômicos, sem grupos repetitivos ou listas de valores dentro de uma única coluna.

No projeto, uma venda pode possuir vários produtos. Por isso, os itens foram separados na tabela ITEM_VENDA, em vez de armazenar todos os produtos em uma única coluna da tabela VENDA.

O mesmo princípio foi aplicado às compras, utilizando a tabela ITEM_COMPRA.

Segunda Forma Normal (2FN)

A segunda forma normal exige que os atributos não chave dependam da chave primária completa, eliminando dependências parciais.

As tabelas do projeto utilizam chaves primárias simples, de uma única coluna. Por isso, não há dependência parcial de uma parte da chave primária composta. As informações específicas dos produtos, categorias, fornecedores e funcionários permanecem em suas próprias tabelas, enquanto as tabelas de itens armazenam os dados próprios de cada operação.

Terceira Forma Normal (3FN)

A terceira forma normal exige que os atributos não chave dependam diretamente da chave primária, evitando dependências transitivas.

No projeto, os dados de categorias não são repetidos em cada venda ou item de compra. Eles permanecem na tabela CATEGORIA, enquanto PRODUTO mantém sua referência à categoria.

Da mesma forma, os dados de fornecedores, funcionários e clientes são armazenados em tabelas próprias e relacionados às operações por meio de chaves estrangeiras.

Justificativa da normalização

A normalização é importante para a Adega do Tonho porque o sistema precisa registrar várias operações relacionadas aos mesmos produtos, clientes, funcionários e fornecedores.

A separação das informações evita repetições desnecessárias, facilita atualizações e permite consultar os dados de forma mais organizada. A conformidade final com a 3FN deve ser conferida pelas dependências funcionais de todos os atributos de cada tabela.
1.5 Justificativas Técnicas das Decisões
Chaves primárias

Foram utilizadas chaves primárias identificadoras, como id_produto, id_venda, id_cliente e id_fornecedor, para identificar cada registro de maneira única.

A utilização de identificadores próprios facilita os relacionamentos entre tabelas e evita depender de informações que podem ser alteradas, como nomes e telefones.

Chaves estrangeiras

As chaves estrangeiras foram utilizadas para manter a ligação entre os registros relacionados.

Exemplos:
- produto.id_categoria relaciona um produto à sua categoria.
- item_venda.id_venda relaciona um item à venda correspondente.
- item_venda.id_produto identifica o produto comercializado.
- fiado.id_cliente identifica o cliente responsável pela dívida.
- fiado.id_venda identifica a venda que originou o fiado.
- compra.id_fornecedor identifica o fornecedor da compra.
- movimentacao_estoque.id_produto identifica o produto movimentado.
- log_acesso.id_funcionario permite relacionar um registro de acesso ao funcionário, quando essa informação estiver disponível.
Restrições de integridade

O script utiliza restrições como NOT NULL, UNIQUE, CHECK e DEFAULT conforme a definição de cada coluna. A lista efetiva deve ser conferida diretamente no script SQL.

Essas restrições ajudam a impedir registros incompletos, valores inválidos e duplicidades.

Exemplos de aplicação:
- NOT NULL impede que uma coluna obrigatória receba valor nulo.
- UNIQUE impede a repetição de valores na coluna ou conjunto de colunas definido pela restrição.
- CHECK valida condições definidas para os valores, quando suportado e aplicado pelo SGBD.
- DEFAULT define um valor utilizado quando nenhum valor é informado para a coluna.
- PK identifica cada registro e FK mantém referências entre tabelas.
Decisões arquiteturais
- O estoque foi organizado por produto, mantendo uma quantidade total disponível.
- O controle de validade foi separado por lote para permitir diferentes vencimentos de um mesmo produto.
- Os itens da venda e da compra foram separados em tabelas próprias para permitir operações com vários produtos.
- O fiado possui registro próprio e pagamentos posteriores separados dos pagamentos da venda.
- A tabela LOG_ACESSO foi incluída na implementação lógica para apoiar o registro de ações importantes.
- A tabela CAIXA permite organizar as operações financeiras previstas no sistema por abertura e fechamento.
Regras garantidas no banco e limitações
- A venda de unidade gera sozinha a saída de estoque (trigger trg_item_venda_registra_saida); o saldo do produto e do lote só muda por movimentação (trigger trg_movimentacao_atualiza_estoque). A consulta de auditoria A01 confere os saldos.
- O item de venda informa o lote (unidade) ou a garrafa aberta (dose); o trigger recusa lote de outro produto, lote vencido ou sem saldo. Assim o vínculo entre venda e lote existe e é validado.
- Produto vencido não é vendido (triggers) e a abertura de garrafa de lote vencido é recusada. O que vence e fica parado no estoque precisa ser baixado como PERDA por um funcionário; a consulta A18 lista esses lotes.
- O fiado tem prazo (dt_vencimento); o controle do que está vencido é feito por consulta (G07 e A12). Não existe trigger que bloqueie sozinho o cliente em atraso: o gerente o bloqueia por UPDATE em cliente.fl_bloqueado, e a A12 aponta quem está em atraso e não bloqueado.
- A auditoria em log_acesso é gravada por triggers (cliente, fiado, recebimento de fiado e fechamento de caixa) e pela procedure sp_registrar_evento_acesso (login e consulta a dado pessoal), usando a variável @id_funcionario_logado, que a aplicação precisa definir. Se a aplicação não definir, o evento é gravado sem funcionário.
- Alterações de preço de produto e de outras tabelas não têm trigger de auditoria; ficam como melhoria futura.
- Cancelamento de venda: o banco permite st_venda = 'CANCELADA', mas não devolve o estoque sozinho; a devolução é feita por um ajuste de estoque feito pelo gerente.
- Os triggers usam CURRENT_DATE() do servidor para conferir validade e vencimento; os dados de teste respeitam isso (ver seção 4).
1.6 Proposta de Arquitetura Analítica para BI e IA
O banco de dados proposto permite organizar informações que podem apoiar a gestão da Adega do Tonho.

Com os registros de vendas, produtos, compras, estoque, fiado e caixa, será possível desenvolver consultas gerenciais e relatórios para acompanhar o funcionamento do estabelecimento.

Informações estratégicas
- Produtos com maior quantidade vendida;
- Produtos com estoque abaixo do mínimo;
- Quantidade de vendas por período;
- Valores recebidos por forma de pagamento;
- Valores pendentes de fiado;
- Compras realizadas por fornecedor;
- Produtos próximos do vencimento;
- Perdas e quebras registradas;
- Diferenças identificadas no fechamento de caixa.
Indicadores e métricas gerenciais (KPIs)
Código	Indicador	Forma de cálculo	Tabelas envolvidas
KPI01	Faturamento por período	Soma dos valores das vendas concluídas no período.	VENDA
KPI02	Ticket médio	Valor total das vendas dividido pela quantidade de vendas concluídas.	VENDA
KPI03	Produtos mais vendidos	Soma das quantidades vendidas por produto.	ITEM_VENDA, PRODUTO
KPI04	Produtos no estoque mínimo	Quantidade de produtos cujo estoque está no mínimo ou abaixo dele.	ESTOQUE, PRODUTO
KPI05	Saldo de fiado	Soma dos valores ainda pendentes de pagamento.	FIADO, CLIENTE, PAGAMENTO_FIADO
KPI06	Fiados vencidos	Quantidade e valor de fiados com prazo ultrapassado, somente se houver prazo de vencimento definido e armazenado.	FIADO, CLIENTE
KPI07	Perdas e quebras	Soma das quantidades registradas como perdas e quebras.	MOVIMENTACAO_ESTOQUE, LOTE, PRODUTO
KPI08	Diferença de caixa	Diferença entre o valor esperado e o valor contado no fechamento.	CAIXA, VENDA, PAGAMENTO


Potencial dos dados para BI

A estrutura do banco permite desenvolver painéis e relatórios para acompanhar vendas, estoque, compras, fiado e caixa.

Essas informações podem ajudar a identificar produtos com maior saída, planejar reposições, acompanhar valores pendentes e verificar diferenças nas operações.

Aplicações analíticas e de IA

Com o acúmulo de dados históricos confiáveis, futuramente poderão ser estudadas aplicações como:
- Previsão de demanda de produtos;
- Identificação de períodos com maior volume de vendas;
- Sugestões de reposição de estoque;
- Identificação de padrões de compra;
- Análise de produtos com maior ocorrência de perdas.
Essas aplicações são possibilidades futuras. O banco de dados, por si só, não realiza previsões ou recomendações por inteligência artificial.

Tabela de rastreabilidade dos problemas e indicadores
Problema ou KPI	Tabelas envolvidas	Consulta no script
P1 — Falta de registro detalhado das vendas	VENDA, ITEM_VENDA, PRODUTO	J01, G01, G02, G03, J07
P2 — Diferenças no estoque	ESTOQUE, MOVIMENTACAO_ESTOQUE	G13, A01, A19
P3 — Dificuldade para identificar produtos com maior saída	ITEM_VENDA, PRODUTO	G04
P4 — Identificação de produtos com baixa quantidade	ESTOQUE, PRODUTO	G05
P5 — Controle manual do fiado	FIADO, CLIENTE, PAGAMENTO_FIADO	G06, G07, A07 a A11
KPI01 — Faturamento por período	VENDA	G01, G01b
KPI02 — Ticket médio	VENDA	G02
KPI03 — Produtos mais vendidos	ITEM_VENDA, PRODUTO	G04
KPI04 — Produtos no estoque mínimo	ESTOQUE, PRODUTO	G05
KPI05 — Saldo de fiado	FIADO, PAGAMENTO_FIADO	G06
KPI06 — Fiados vencidos	FIADO, CLIENTE	G07
KPI07 — Perdas e quebras	MOVIMENTACAO_ESTOQUE, LOTE, PRODUTO	G08
KPI08 — Diferença de caixa	CAIXA, VENDA, PAGAMENTO, MOVIMENTACAO_CAIXA	G09, G09b


2. Modelo Lógico Relacional
O modelo lógico apresenta a transformação do DER conceitual em tabelas relacionais, com seus atributos, tipos de dados, chaves primárias, chaves estrangeiras e relacionamentos.
- SGBD previsto: MySQL 8.0.
- Software de modelagem: brModelo [PREENCHER VERSÃO].
- Arquivo editável: [`Diagramas/modelo_logico.brm`](Diagramas/modelo_logico.brm).
- Imagem do modelo lógico: [`Diagramas/modelo_logico.png`](Diagramas/modelo_logico.png).
- Modelo lógico em texto: [`Docs/modelo_logico.md`](Docs/modelo_logico.md).
O modelo lógico contempla 21 tabelas: as 18 entidades do DER mais três tabelas de apoio criadas na implementação: LOG_ACESSO (auditoria e LGPD), GARRAFA_ABERTA (venda de doses) e MOVIMENTACAO_CAIXA (suprimento, sangria e despesa do caixa).

As marcações usadas no diagrama têm os seguintes significados:
- PK: chave primária, identifica cada registro da tabela.
- FK: chave estrangeira, relaciona uma tabela a outra.
- UNIQUE: indica uma restrição de unicidade, que impede valores repetidos no campo ou conjunto de campos definido.
- DERIVADO: indica um atributo obtido por cálculo ou a partir de outras informações, e não necessariamente armazenado diretamente. Manter essa marcação somente nos atributos que realmente sejam derivados no modelo.
As restrições de integridade, como NOT NULL, UNIQUE, CHECK e DEFAULT, devem ser conferidas no [dicionário de dados](Docs/dicionario_dados.html) e no [script SQL](Docs/script.sql).
3. Script SQL Completo
O banco de dados foi estruturado para implementação no SGBD MySQL 8.0.
- SGBD: MySQL 8.0.
- Script principal: [`Docs/script.sql`](Docs/script.sql).
- O `script.sql` já cria o banco, as 21 tabelas, as constraints, os triggers e as procedures (não existe outro arquivo de criação).
- Testes de INSERT, UPDATE, DELETE, constraints e regras: [`Docs/testes.sql`](Docs/testes.sql).
- Consultas JOIN, gerenciais (G) e de auditoria (A): [`Docs/consultas.sql`](Docs/consultas.sql).
- Indicadores, BI e IA: [`Docs/indicadores_kpis.md`](Docs/indicadores_kpis.md).
- Roteiro do pitch de 8 minutos: [`Docs/roteiro_apresentacao.md`](Docs/roteiro_apresentacao.md).
- Ordem de execução: `script.sql` → `massa_de_dados.sql` → `testes.sql` → `consultas.sql`.
- Exemplos de manipulação: [`Docs/exemplos_basicos.sql`](Docs/exemplos_basicos.sql).
- Massa de dados: [`Docs/massa_de_dados.sql`](Docs/massa_de_dados.sql).
Estrutura do script

O script deve contemplar as etapas solicitadas pelo professor:
1. Criação do banco de dados com CREATE DATABASE;
2. Criação das tabelas com CREATE TABLE;
3. Definição das constraints, incluindo PK, FK, NOT NULL, UNIQUE e CHECK;
4. Inserção dos registros com INSERT INTO;
5. Consultas com SELECT e JOIN;
6. Atualização de registros com UPDATE;
7. Exclusão de registros com DELETE;
8. Consultas gerenciais;
9. Consultas de auditoria.
Consultas gerenciais

As consultas gerenciais devem receber códigos sequenciais, como G01, G02 e G03, apresentando a pergunta respondida e o problema ou indicador atendido.

Consultas de auditoria

As consultas de auditoria devem receber códigos como A01, A02 e A03, indicando a regra de negócio que está sendo verificada.

Testes de execução

Preencher somente após executar os arquivos em um ambiente MySQL. Até aqui o script, a massa e as consultas foram conferidos apenas por simulação (sem triggers); a execução real no MySQL 8.0 ainda precisa ser feita pelo grupo:
- Criação do banco a partir de um banco vazio: [PREENCHER].
- Criação de todas as tabelas: [PREENCHER].
- Inserção da massa de dados: [PREENCHER].
- Execução das consultas: [PREENCHER].
- Erros encontrados e correções realizadas: [PREENCHER].
- Evidências dos testes: [`evidencias/`](evidencias/).
O script deve ser testado integralmente em um ambiente MySQL antes da entrega final. A utilização do OneCompiler é apenas o ambiente de execução, não o SGBD em si.
4. Massa de Dados
A massa de dados utilizada no projeto deve ser fictícia, sem utilizar informações pessoais ou dados reais dos clientes da Adega do Tonho.
- Arquivo: [`Docs/massa_de_dados.sql`](Docs/massa_de_dados.sql).
Justificativa do volume de dados

A quantidade de registros deve ser coerente com o porte da organização, considerando a equipe de aproximadamente 3 a 4 pessoas, o funcionamento diário e a variedade de produtos comercializados.

A massa simula cerca de 3 meses de funcionamento (03/08/2026 a 01/11/2026), com 4 funcionários, 60 produtos, 5 fornecedores e 12 clientes. Os números reais de vendas por dia ainda não foram confirmados com o responsável, então o volume é uma estimativa do grupo. A massa respeita os triggers: estoque, saída de venda, status do fiado e log de auditoria são preenchidos pelo próprio banco.

Variedade dos dados

A massa de dados deve contemplar diferentes situações para permitir a demonstração das consultas e dos processos:
- Produtos de diferentes categorias;
- Produtos com e sem venda em doses;
- Produtos com estoque acima, no mínimo e abaixo do mínimo;
- Vendas com diferentes formas de pagamento;
- Vendas com pagamento dividido, se essa operação estiver contemplada na implementação;
- Clientes sem compras;
- Clientes autorizados a comprar por fiado, quando a autorização estiver implementada;
- Fiados em aberto e quitados;
- Recebimentos parciais de fiado;
- Compras de diferentes fornecedores;
- Lotes com datas de validade diferentes;
- Produtos vencidos ou próximos do vencimento;
- Movimentações de entrada, saída, perda e ajuste;
- Caixas com fechamentos diferentes.
Quantidade de registros por tabela
Tabela	Quantidade de registros	Justificativa
categoria	8	Categorias dos produtos comercializados.
produto	60	Variedade de produtos da adega, 5 deles vendidos também em dose.
estoque	60	Um registro de estoque por produto, criado pelo trigger.
funcionario	4	Equipe de 4 pessoas (1 gerente e 3 atendentes).
escala	208	Turnos de 13h às 23h (meia-noite de sexta a domingo) nos 91 dias.
caixa	91	Um caixa por dia; o último fica aberto.
cliente	12	Clientes fictícios, 2 bloqueados por fiado vencido.
venda	650	Vendas fictícias (643 concluídas e 7 canceladas) em 3 meses.
item_venda	1198	Itens das vendas, em unidade e em dose.
pagamento	749	Pagamentos (inclui a parte FIADO lançada pela procedure).
fiado	43	Fiados abertos e quitados.
item_fiado	90	Linhas de venda alocadas ao fiado pela procedure.
pagamento_fiado	44	Recebimentos totais e parciais.
fornecedor	5	Fornecedores fictícios (CNPJs inventados).
compra	86	Compras recebidas, uma cancelada e uma ainda em pedido.
item_compra	329	Produtos e quantidades das compras.
lote	275	Lotes com validades diferentes, inclusive vencidos.
movimentacao_estoque	1593	Entradas, saídas de venda e de dose, perdas, ajustes e devolução.
garrafa_aberta	6	Garrafas abertas para vender doses.
movimentacao_caixa	67	Suprimentos, sangrias e despesas do caixa.
log_acesso	672	Logins, alterações e aprovações registradas pelos triggers e procedures.


As quantidades devem ser atualizadas após a execução dos comandos de inserção, utilizando consultas COUNT(*) em cada tabela.
5. Repositório GitHub
- Repositório: [PREENCHER LINK DO REPOSITÓRIO].
A versão considerada para avaliação deve estar na branch main, conforme orientação do professor.

Organização dos arquivos
Artefato	Localização
Relatório Técnico Final	[`README.md`](README.md)
DER conceitual revisado	[`Diagramas/der_conceitual.png`](Diagramas/der_conceitual.png) e [`Diagramas/der_conceitual.md`](Diagramas/der_conceitual.md)
Modelo lógico editável	[`Diagramas/modelo_logico.brm`](Diagramas/modelo_logico.brm)
Imagem do modelo lógico	[`Diagramas/modelo_logico.png`](Diagramas/modelo_logico.png)
Modelo lógico em texto	[`Docs/modelo_logico.md`](Docs/modelo_logico.md)
Normalização	[`Docs/normalizacao.md`](Docs/normalizacao.md)
Justificativa técnica	[`Docs/justificativa_tecnica.md`](Docs/justificativa_tecnica.md)
Dicionário de dados	[`Docs/dicionario_dados.html`](Docs/dicionario_dados.html)
Script SQL	[`Docs/script.sql`](Docs/script.sql)
Testes de INSERT/UPDATE/DELETE e constraints	[`Docs/testes.sql`](Docs/testes.sql)
Consultas JOIN, gerenciais e de auditoria	[`Docs/consultas.sql`](Docs/consultas.sql)
Indicadores, BI e IA	[`Docs/indicadores_kpis.md`](Docs/indicadores_kpis.md)
Roteiro do pitch	[`Docs/roteiro_apresentacao.md`](Docs/roteiro_apresentacao.md)
Exemplos SQL	[`Docs/exemplos_basicos.sql`](Docs/exemplos_basicos.sql)
Massa de dados	[`Docs/massa_de_dados.sql`](Docs/massa_de_dados.sql)
Levantamento	[`Levantamento/Levantamento.md`](Levantamento/Levantamento.md)
Requisitos	[`Levantamento/Requisitos.md`](Levantamento/Requisitos.md)
Processos de negócio	[`Levantamento/processos.md`](Levantamento/processos.md)
Regras de negócio	[`Levantamento/regras_de_negocio.md`](Levantamento/regras_de_negocio.md)
Evidências	[`evidencias/`](evidencias/)


Histórico de commits e colaboração

O desenvolvimento do projeto deve ser registrado por meio de commits realizados pelos próprios integrantes, utilizando suas respectivas contas do GitHub.

A colaboração deve estar distribuída entre os membros do grupo, demonstrando a participação de todos nas etapas de desenvolvimento.

[COMPLEMENTAR: informar como foi realizada a divisão dos commits e verificar se todos os integrantes estão identificados corretamente no GitHub.]

Divisão de tarefas
Integrante	Responsabilidade	Arquivos ou atividades
Kevin Gomes	Revisão do DER, modelo lógico, chaves, normalização, justificativa técnica, README e organização da documentação.	Modelo lógico, normalização, justificativa técnica e README.
Brayan Antonio Daza Paredes	[CONFIRMAR RESPONSABILIDADE]	[PREENCHER]
Gabriel dos Santos Eufrasio	[CONFIRMAR RESPONSABILIDADE]	[PREENCHER]
Gabriel Gonçalves Moura	[CONFIRMAR RESPONSABILIDADE]	[PREENCHER]
Felipe Militão	[CONFIRMAR RESPONSABILIDADE]	[PREENCHER]


As responsabilidades devem ser conferidas com o grupo. Não manter a divisão genérica por “Integrante 2”, “Integrante 3” etc. sem confirmar quem realizou cada atividade.
6. Uso de Inteligência Artificial
Durante o desenvolvimento do projeto, ferramentas de inteligência artificial foram utilizadas como apoio à organização, revisão e compreensão de conceitos relacionados à modelagem de dados e à documentação.

As informações sobre a Adega do Tonho foram obtidas por meio do levantamento realizado pelo grupo. As ferramentas de IA foram utilizadas como apoio, e não como substitutas da pesquisa de campo.

Registro dos usos de IA
Etapa	Ferramenta	Utilização
Revisão do DER	ChatGPT	Apoio na análise dos relacionamentos, cardinalidades e entidades.
Modelo lógico	ChatGPT	Apoio na conversão das entidades em tabelas e na organização das chaves.
Normalização	ChatGPT	Apoio na compreensão e justificativa das formas normais.
README e documentação	ChatGPT	Organização do conteúdo conforme o esqueleto fornecido pelo professor.
Processos, requisitos e regras	ChatGPT	Apoio na revisão e ampliação dos documentos.
Conferência entre arquivos	Claude	Comparação do script SQL com modelo lógico, dicionário de dados, normalização, requisitos, regras e README; lista de divergências e correções.
Script SQL	[PREENCHER conforme o uso do integrante responsável]	[PREENCHER].
Massa de dados	Claude	Apoio na criação de um gerador de dados fictícios que respeita os triggers e procedures do script; o grupo deve revisar e rodar no MySQL.
Consultas e KPIs	Claude	Apoio na escrita das consultas J, G e A, dos testes e do documento de indicadores; o grupo deve rodar e conferir os resultados.
Apresentação	[PREENCHER conforme o uso do grupo]	[PREENCHER].


Registro 1 — Revisão do DER e modelo lógico
- Ferramenta: ChatGPT.
- Motivação: revisar os apontamentos da avaliação da Entrega 1 e apoiar a conversão do modelo conceitual para o modelo lógico.
- Prompts utilizados: solicitações para revisar os arquivos do projeto, identificar inconsistências entre DER, modelo lógico e script SQL, conferir relacionamentos e organizar as chaves primárias e estrangeiras.
- Resposta recebida: sugestões de ajustes nas entidades, relacionamentos, cardinalidades, chaves e organização das tabelas.
- Fontes consultadas: esqueleto da Entrega 2, avaliação da Entrega 1 e arquivos do próprio grupo.
- Trechos corrigidos ou rejeitados: foram revisadas sugestões que apresentavam duplicação de informações no controle do fiado e inconsistências entre os relacionamentos.
- Justificativa da escolha final: foram mantidas as decisões que apresentavam coerência com o levantamento da organização e com a estrutura do banco.
- Reflexão crítica: a IA ajudou a identificar problemas e organizar a documentação, mas algumas sugestões precisaram ser revistas para não representar como realidade da adega processos que ainda são propostas do sistema.
Registro 2 — README, processos, requisitos e regras
- Ferramenta: ChatGPT.
- Motivação: organizar o relatório conforme o modelo do professor e revisar os processos, requisitos e regras de negócio.
- Prompts utilizados: solicitações para revisar os documentos da Entrega 1, ampliar os processos que estavam incompletos e organizar o README seguindo o esqueleto da Entrega 2.
- Resposta recebida: sugestões de estruturação, revisão de textos, inclusão de processos propostos e organização dos requisitos e regras.
- Fontes consultadas: documentos do grupo, avaliação do professor e esqueleto da Entrega 2.
- Trechos corrigidos ou rejeitados: informações não confirmadas pela organização foram identificadas como propostas ou pendentes de validação.
- Justificativa da escolha final: foram mantidas as informações que correspondem ao levantamento e as propostas foram identificadas separadamente.
- Reflexão crítica: a IA pode sugerir processos comuns de outros estabelecimentos que não necessariamente existem na Adega do Tonho. Por isso, o grupo precisa conferir essas informações com o responsável.
Registros dos demais integrantes

Os integrantes responsáveis pelo script SQL, massa de dados, consultas, KPIs e apresentação devem complementar esta seção com as ferramentas utilizadas, prompts, respostas, ajustes realizados e reflexões críticas.

Caso algum integrante não tenha utilizado IA em determinada etapa, isso deve ser declarado explicitamente.
7. Apresentação Corporativa Final
A apresentação final será organizada no formato de pitch de 8 minutos, seguindo a ordem estabelecida pelo professor.

O objetivo é apresentar os problemas identificados na Adega do Tonho, a solução proposta, a estrutura do banco de dados, a implementação SQL e os benefícios que as informações organizadas podem oferecer à gestão.

Informações da apresentação
- Arquivo dos slides: [PREENCHER CAMINHO OU LINK].
- Ferramenta utilizada: [PREENCHER].
- Tempo previsto: 8 minutos.
Roteiro da apresentação
Ordem	Conteúdo	Tempo sugerido
1	Contextualização da Adega do Tonho e dos problemas identificados.	1 minuto
2	Apresentação da solução proposta.	1 minuto
3	Apresentação do modelo lógico, tabelas e relacionamentos.	1 minuto e 30 segundos
4	Demonstração da implementação SQL em execução.	1 minuto e 30 segundos
5	Demonstração das consultas gerenciais e de auditoria.	1 minuto e 30 segundos
6	Potencial de utilização de BI e IA.	45 segundos
7	Benefícios para a tomada de decisão da organização.	45 segundos


Participação e defesa

Todos os integrantes devem participar da apresentação e estar presentes durante a defesa do modelo lógico.

Cada integrante deverá conhecer e explicar a parte pela qual ficou responsável, incluindo as decisões tomadas durante o desenvolvimento do projeto.
Checklist final antes da entrega
- [ ] README preenchido e salvo na raiz da branch main.
- [ ] Nomes, RGMs e usuários do GitHub conferidos.
- [ ] Quantidades aproximadas da organização confirmadas.
- [ ] Endereço, contato do responsável e evidências incluídos, respeitando a autorização para divulgação.
- [ ] Entrevista e observação presencial descritas.
- [ ] Problemas P1 a P5 relacionados às tabelas e consultas gerenciais.
- [ ] Processos, requisitos e regras revisados.
- [ ] DER conceitual revisado conforme a notação brModelo.
- [ ] Modelo lógico atualizado e compatível com o script SQL.
- [ ] PKs e FKs conferidas em todas as tabelas.
- [ ] Os 30 relacionamentos (chaves estrangeiras) do modelo lógico de 21 tabelas conferidos, incluindo a relação opcional de FUNCIONARIO com LOG_ACESSO.
- [ ] Normalização e justificativas técnicas revisadas.
- [ ] Dicionário de dados atualizado em um único arquivo HTML.
- [ ] Script SQL completo e testado do início ao fim em MySQL.
- [ ] Massa de dados fictícia e coerente com os processos.
- [ ] Consultas gerenciais e de auditoria identificadas por códigos.
- [ ] Tabela de rastreabilidade preenchida com os códigos reais das consultas.
- [ ] Uso de IA documentado por todos os integrantes.
- [ ] Histórico de commits e divisão de tarefas conferidos.
- [ ] Slides preparados para a apresentação de 8 minutos.
- [ ] Todos os links e caminhos de arquivos conferidos na branch main.
- [ ] Autorização de fiado implementada com cliente.fl_bloqueado e sp_autorizar_cliente_fiado (SQL, modelo lógico e dicionário de dados conferidos).
- [ ] Limitações da relação PRODUTO–`ESTOQUE`, da baixa de estoque por venda, do vínculo de lote na venda e do controle de vencimento do fiado documentadas.
- [ ] Registro efetivo de eventos em LOG_ACESSO conferido; a tabela, sozinha, não garante a gravação automática dos eventos.
