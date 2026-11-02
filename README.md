integrantes
Nome completo do aluno	RGM	Usuário do GitHub
Kevin Gomes	47796006	[PREENCHER]
Brayan Antonio Daza Paredes	48892009	[PREENCHER]
Gabriel dos Santos Eufrasio	49005260	[PREENCHER]
Gabriel Gonçalves Moura	[CONFERIR RGM]	[PREENCHER]
Felipe Militão	[CONFERIR RGM]	[PREENCHER]


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
P5	O controle do fiado é realizado manualmente, dificultando o acompanhamento dos valores devidos e dos recebimentos.	Registrar clientes autorizados, vendas fiadas, valores devidos e pagamentos realizados.


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
O modelo conceitual possui 18 entidades de negócio. Na implementação lógica, há 19 tabelas: as 18 correspondentes às entidades conceituais e a tabela técnica adicional log_acesso, utilizada para registrar eventos e apoiar a auditoria do sistema.

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
- Telefone para contato: [PREENCHER, com autorização do responsável].
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

Também foi esclarecido que o fiado é restrito a clientes conhecidos ou autorizados, não sendo uma modalidade disponibilizada livremente para qualquer pessoa.

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
RF09	O sistema deve permitir cadastrar clientes e registrar explicitamente quais estão autorizados a realizar compras por fiado. A autorização depende da inclusão do campo fl_fiado_autorizado no SQL.
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


Requisitos não funcionais
Código	Requisito não funcional	Critério ou medida
RNF01	Facilidade de uso: a interface deve ser simples e intuitiva para os funcionários.	Avaliação de uso com funcionário da adega.
RNF02	Rapidez: as consultas de produtos, preços e estoque devem apresentar resultados rapidamente.	Até 2 segundos para consultas comuns.
RNF03	Integridade: os dados de vendas, compras e estoque devem permanecer consistentes.	Verificação por consultas de auditoria.
RNF04	Segurança: o acesso às funcionalidades deve respeitar as permissões de cada usuário.	Perfis de atendente e gerente.
RNF05	Disponibilidade: as informações devem estar disponíveis durante o horário de funcionamento.	Meta proposta de até 15 minutos de indisponibilidade por semana no horário de funcionamento.
RNF06	Cópia de segurança: o sistema deve permitir cópias de segurança dos dados.	Pelo menos uma cópia por dia.
RNF07	Compatibilidade: o sistema deve permitir utilização em computadores e dispositivos móveis.	Testes em computador e celular.
RNF08	Proteção de dados pessoais: os dados de clientes e funcionários devem ser tratados conforme a LGPD.	Acesso restrito e tratamento adequado dos dados.
RNF09	Manutenibilidade: a estrutura deve facilitar futuras alterações e correções.	Organização das tabelas, relacionamentos e documentação.


1.1.5 Regras de negócio
As regras completas estão disponíveis em [`Levantamento/regras_de_negocio.md`](Levantamento/regras_de_negocio.md).

As regras abaixo representam as condições operacionais e as restrições consideradas no sistema. As regras propostas devem ser validadas com o responsável antes de serem tratadas como procedimentos já vigentes na adega.
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


Observação: prazos específicos para pagamento de fiado, período de aviso de vencimento e demais limites operacionais dependem de confirmação do responsável. O indicador KPI06 também depende de um campo ou regra de vencimento efetivamente definido no banco. Não apresente esses controles como implementados enquanto não forem confirmados e incluídos no modelo e no SQL.
1.1.6 DER conceitual revisado
O DER conceitual foi revisado considerando os apontamentos da avaliação da Entrega 1 e a ampliação dos processos contemplados pelo sistema.

Arquivo: Diagramas/der_conceitual.

Software utilizado: brModelo [PREENCHER VERSÃO].

Principais alterações realizadas
Apontamento da avaliação da Entrega 1	Alteração realizada	Justificativa
DER apresentava apenas cardinalidades máximas.	Inclusão das cardinalidades mínimas e máximas nos relacionamentos.	Permitir compreender a participação obrigatória ou opcional das entidades.
Chaves estrangeiras apareciam no modelo conceitual.	Retirada das chaves estrangeiras do DER conceitual.	As FKs pertencem ao modelo lógico.
Relacionamentos de estoque e venda estavam inconsistentes.	A movimentação de estoque passou a representar as entradas e saídas relacionadas aos produtos.	Evitar relacionamento direto inadequado entre venda e estoque.
Relacionamentos de pagamento apresentavam duplicidade.	Organização do pagamento da venda e do recebimento de fiado em estruturas próprias.	Diferenciar o pagamento da venda do recebimento posterior da dívida.
Faltavam relações com funcionários.	Inclusão das relações entre funcionários, vendas, compras, escalas e movimentações.	Identificar os responsáveis pelas operações.
O modelo não contemplava adequadamente validade e lotes.	Inclusão da entidade LOTE e de sua relação com os itens de compra e movimentações.	Permitir controlar diferentes datas de validade de um mesmo produto.
Não existia representação de caixa.	Inclusão da entidade CAIXA.	Permitir representar abertura, movimentações e fechamento de caixa.
Processos de negócio estavam incompletos.	Ampliação do modelo para contemplar recebimento de fiado, caixa, perdas, validade e escala.	Aumentar a cobertura dos processos da organização.


Entidades do modelo conceitual

O DER revisado contém as seguintes 18 entidades:
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
A tabela técnica log_acesso pertence à implementação lógica e não foi considerada uma entidade de negócio do DER conceitual.
1.2 Conversão do Modelo Conceitual para o Modelo Lógico
A conversão do modelo conceitual para o modelo lógico foi realizada transformando as entidades em tabelas, seus atributos em colunas e os relacionamentos em chaves primárias e estrangeiras.

Entidades transformadas em tabelas

Cada entidade do DER conceitual foi convertida em uma tabela relacional. Os atributos foram definidos como colunas, respeitando seus tipos de dados e suas finalidades.

Conversão dos relacionamentos
- Relacionamentos 1:N: foram implementados por meio de chaves estrangeiras no lado N.
- Relacionamentos 1:1: foram implementados por meio de chaves estrangeiras com restrição de unicidade, quando aplicável.
- Relacionamentos N:N: foram representados por tabelas associativas, como ITEM_VENDA e ITEM_COMPRA.
- O relacionamento entre ITEM_VENDA e ITEM_FIADO permite identificar quais itens de uma venda ficaram pendentes de pagamento. A tabela item_fiado contém id_item_fiado, id_item_venda e dt_lancamento; produto, quantidade e preço são consultados em item_venda.
- A tabela fiado possui as FKs id_venda e id_cliente. O campo fiado.id_venda é UNIQUE, portanto uma venda pode gerar no máximo um registro de fiado.
- A tabela pagamento não possui id_fiado. Quando o pagamento da venda é do tipo FIADO, a associação ao fiado ocorre por meio da venda de origem. Os recebimentos posteriores são registrados em pagamento_fiado, que possui FKs para fiado e caixa.
- Não existe relacionamento direto entre FIADO e ITEM_FIADO; a ligação é realizada por ITEM_VENDA.
- A relação entre ITEM_COMPRA e LOTE permite associar um ou vários lotes ao item de compra que lhes deu origem. No SQL, lote.id_item_compra é FK sem UNIQUE.
Decisões de conversão

A tabela ESTOQUE mantém o controle da quantidade total de cada produto. A organização física do estoque não foi dividida em diferentes locais no modelo, pois o levantamento não identificou a necessidade de controlar quantidades separadamente por localização.

A relação conceitual entre PRODUTO e ESTOQUE foi definida como 1:1. No SQL, estoque.id_produto possui NOT NULL e UNIQUE, garantindo que cada registro de estoque esteja associado a um único produto e impedindo mais de um registro de estoque para o mesmo produto. Essa restrição, porém, não obriga que todo produto cadastrado tenha um registro correspondente em estoque. Portanto, a participação obrigatória de todo produto no relacionamento conceitual não é totalmente garantida apenas pela restrição atual do banco.

O controle de validade foi estruturado por lote, pois um mesmo produto pode possuir diferentes datas de vencimento.

O fiado foi modelado como um registro associado à venda de origem, mantendo os recebimentos posteriores em uma tabela própria. Dessa forma, o pagamento da venda e a quitação da dívida são operações distintas.

Autorização para fiado — ajuste pendente

A regra de negócio estabelece que o fiado somente pode ser concedido a clientes conhecidos ou autorizados. Entretanto, a estrutura SQL analisada possui cliente.fl_bloqueado, mas não possui um campo específico fl_fiado_autorizado.

Recomenda-se acrescentar fl_fiado_autorizado TINYINT(1) NOT NULL DEFAULT 0 à tabela cliente, atualizar o modelo lógico e o dicionário de dados e implementar a validação correspondente. Até que essa alteração seja feita e testada, a autorização explícita para fiado deve ser tratada como uma melhoria pendente, e não como funcionalidade já implementada.

Arquivo do modelo lógico: [`Diagramas/modelo_logico.brm`](Diagramas/modelo_logico.brm).

Software utilizado: brModelo [PREENCHER VERSÃO].
1.3 Definição de Chaves Primárias e Estrangeiras
As chaves primárias identificam exclusivamente cada registro. As chaves estrangeiras estabelecem os relacionamentos entre as tabelas e garantem a integridade referencial.

A relação completa das PKs e FKs deve seguir exatamente o modelo lógico e o script SQL oficial do grupo.

Conferência dos 22 relacionamentos

A tabela abaixo resume as relações implementadas no modelo lógico. A notação 1:N e 1:1 resume a cardinalidade máxima; as participações mínimas e máximas devem ser conferidas no diagrama.
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


Pontos de atenção na conferência do diagrama:
- fiado.id_venda é FK com UNIQUE; por isso, uma venda pode estar associada a no máximo um fiado.
- item_fiado.id_item_venda é FK com UNIQUE; por isso, um item da venda pode estar associado a no máximo um item do fiado.
- lote.id_item_compra não possui UNIQUE; um item de compra pode originar vários lotes.
- movimentacao_estoque.id_lote aceita NULL; por isso, uma movimentação pode não estar vinculada a um lote.
- pagamento não possui FK direta para fiado.
- estoque.id_produto é UNIQUE, mas o SQL atual não garante que todo produto tenha obrigatoriamente um registro em estoque.
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
item_venda	id_item_venda	id_venda, id_produto
pagamento	id_pagamento	id_venda
fiado	id_fiado	id_cliente, id_venda
item_fiado	id_item_fiado	id_item_venda
pagamento_fiado	id_pagamento_fiado	id_fiado, id_caixa
fornecedor	id_fornecedor	—
compra	id_compra	id_fornecedor, id_funcionario
item_compra	id_item_compra	id_compra, id_produto
lote	id_lote	id_item_compra
movimentacao_estoque	id_movimentacao	id_produto, id_lote, id_funcionario
log_acesso	id_log	id_funcionario (FK, aceita NULL)


Observação: a lista acima é um resumo das referências principais. Os nomes, a obrigatoriedade e as restrições devem ser conferidos com o arquivo SQL e com o diagrama lógico definitivo antes da entrega.
1.4 Processo de Normalização (1FN, 2FN e 3FN)
A normalização foi aplicada para organizar os dados, reduzir repetições e evitar inconsistências durante as operações de cadastro, venda, compra e controle de estoque.

Primeira Forma Normal (1FN)

A primeira forma normal exige que cada coluna contenha valores atômicos, sem grupos repetitivos ou listas de valores dentro de uma única coluna.

No projeto, uma venda pode possuir vários produtos. Por isso, os itens foram separados na tabela ITEM_VENDA, em vez de armazenar todos os produtos em uma única coluna da tabela VENDA.

O mesmo princípio foi aplicado às compras, utilizando a tabela ITEM_COMPRA.

Segunda Forma Normal (2FN)

A segunda forma normal exige que os atributos não chave dependam da chave primária completa, eliminando dependências parciais.

No projeto, as informações de produtos, categorias, fornecedores e funcionários foram mantidas em suas próprias tabelas. As tabelas associativas armazenam as informações específicas de cada item da venda ou da compra.

Terceira Forma Normal (3FN)

A terceira forma normal exige que os atributos não chave dependam diretamente da chave primária, evitando dependências transitivas.

No projeto, os dados de categorias não são repetidos em cada venda ou item de compra. Eles permanecem na tabela CATEGORIA, enquanto PRODUTO mantém sua referência à categoria.

Da mesma forma, os dados de fornecedores, funcionários e clientes são armazenados em tabelas próprias e relacionados às operações por meio de chaves estrangeiras.

Justificativa da normalização

A normalização é importante para a Adega do Tonho porque o sistema precisa registrar várias operações relacionadas aos mesmos produtos, clientes, funcionários e fornecedores.

A separação das informações evita repetições desnecessárias, facilita atualizações e permite consultar os dados de forma mais organizada.
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
Restrições de integridade

O script utiliza restrições como NOT NULL, UNIQUE, CHECK e DEFAULT conforme a definição de cada coluna. A lista efetiva deve ser conferida diretamente no script SQL.

Essas restrições ajudam a impedir registros incompletos, valores inválidos e duplicidades.

Exemplos de aplicação:
- Restrições de unicidade devem ser aplicadas somente aos campos para os quais isso estiver definido no script SQL.
- Quantidades e valores devem respeitar os limites definidos no banco.
- Situações e tipos de movimentação devem utilizar valores permitidos.
- Relacionamentos devem respeitar a existência dos registros referenciados.
As restrições específicas e suas regras correspondentes estão documentadas no dicionário de dados e implementadas no script SQL.

Decisões arquiteturais
- O estoque foi organizado por produto, mantendo uma quantidade total disponível.
- O controle de validade foi separado por lote para permitir diferentes vencimentos de um mesmo produto.
- Os itens da venda e da compra foram separados em tabelas próprias para permitir operações com vários produtos.
- O fiado possui registro próprio e pagamentos posteriores separados dos pagamentos da venda.
- A tabela log_acesso foi incluída na implementação lógica para apoiar o registro de ações importantes.
- A tabela CAIXA permite organizar as operações financeiras por abertura e fechamento.
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
P1 — Falta de registro detalhado das vendas	VENDA, ITEM_VENDA, PRODUTO	[PREENCHER G__]
P2 — Diferenças no estoque	ESTOQUE, MOVIMENTACAO_ESTOQUE	[PREENCHER G__]
P3 — Dificuldade para identificar produtos com maior saída	ITEM_VENDA, PRODUTO	[PREENCHER G__]
P4 — Identificação de produtos com baixa quantidade	ESTOQUE, PRODUTO	[PREENCHER G__]
P5 — Controle manual do fiado	FIADO, CLIENTE, PAGAMENTO_FIADO	[PREENCHER G__]
KPI01 — Faturamento por período	VENDA	[PREENCHER G__]
KPI02 — Ticket médio	VENDA	[PREENCHER G__]
KPI03 — Produtos mais vendidos	ITEM_VENDA, PRODUTO	[PREENCHER G__]
KPI04 — Produtos no estoque mínimo	ESTOQUE, PRODUTO	[PREENCHER G__]
KPI05 — Saldo de fiado	FIADO, PAGAMENTO_FIADO	[PREENCHER G__]
KPI06 — Fiados vencidos	FIADO, CLIENTE	[PREENCHER G__]
KPI07 — Perdas e quebras	MOVIMENTACAO_ESTOQUE, LOTE, PRODUTO	[PREENCHER G__]
KPI08 — Diferença de caixa	CAIXA, VENDA, PAGAMENTO	[PREENCHER G__]


2. Modelo Lógico Relacional
O modelo lógico apresenta a transformação do DER conceitual em tabelas relacionais, com seus atributos, tipos de dados, chaves primárias, chaves estrangeiras e cardinalidades.

Software utilizado: brModelo [PREENCHER VERSÃO].

Arquivo editável: [`Diagramas/modelo_logico.brm`](Diagramas/modelo_logico.brm).

Imagem do modelo lógico: [`Diagramas/modelo_logico.png`](Diagramas/modelo_logico.png).

O modelo lógico contempla as 19 tabelas utilizadas na implementação do banco de dados.

As restrições de integridade, como NOT NULL, UNIQUE, CHECK e DEFAULT, estão documentadas no [dicionário de dados](Docs/dicionario_dados.html) e implementadas no [script SQL](Docs/script.sql).
3. Script SQL Completo
O banco de dados foi estruturado para ser implementado no SGBD MySQL.
- SGBD: MySQL 8.0.
- Script principal: [`Docs/script.sql`](Docs/script.sql).
- Script de criação das tabelas: [`Docs/criacao_banco.sql`](Docs/criacao_banco.sql).
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
- Criação do banco a partir de um banco vazio: [PREENCHER].
- Criação de todas as tabelas: [PREENCHER].
- Inserção da massa de dados: [PREENCHER].
- Execução das consultas: [PREENCHER].
- Erros encontrados e correções realizadas: [PREENCHER].
- Evidências dos testes: [`evidencias/`](evidencias/).
O script deve ser testado integralmente em um ambiente MySQL antes da entrega final. A utilização do OneCompiler é apenas o ambiente de execução, não o SGBD em si.
4. Massa de Dados
A massa de dados utilizada no projeto deve ser fictícia, sem utilizar informações pessoais ou dados reais dos clientes da Adega do Tonho.

Arquivo: [`Docs/massa_de_dados.sql`](Docs/massa_de_dados.sql).

Justificativa do volume de dados

A quantidade de registros deve ser coerente com o porte da organização, considerando a equipe de aproximadamente 3 a 4 pessoas, o funcionamento diário e a variedade de produtos comercializados.

A quantidade final de registros deve ser definida após a conferência dos dados inseridos e dos números aproximados levantados com o responsável.

Variedade dos dados

A massa de dados deve contemplar diferentes situações para permitir a demonstração das consultas e dos processos:
- Produtos de diferentes categorias;
- Produtos com e sem venda em doses;
- Produtos com estoque acima, no mínimo e abaixo do mínimo;
- Vendas com diferentes formas de pagamento;
- Vendas com pagamento dividido;
- Clientes sem compras;
- Clientes autorizados a comprar por fiado;
- Fiados em aberto e quitados;
- Recebimentos parciais de fiado;
- Compras de diferentes fornecedores;
- Lotes com datas de validade diferentes;
- Produtos vencidos ou próximos do vencimento;
- Movimentações de entrada, saída, perda e ajuste;
- Caixas com fechamentos diferentes.
Quantidade de registros por tabela
Tabela	Quantidade de registros	Justificativa
categoria	[PREENCHER]	Categorias dos produtos comercializados.
produto	[PREENCHER]	Variedade de produtos da adega.
estoque	[PREENCHER]	Um registro de estoque por produto.
funcionario	[PREENCHER]	Equipe aproximada de 3 a 4 pessoas.
escala	[PREENCHER]	Registros de turnos dos funcionários.
caixa	[PREENCHER]	Registros de abertura e fechamento.
cliente	[PREENCHER]	Clientes fictícios cadastrados.
venda	[PREENCHER]	Vendas fictícias em diferentes períodos.
item_venda	[PREENCHER]	Itens associados às vendas.
pagamento	[PREENCHER]	Pagamentos realizados nas vendas.
fiado	[PREENCHER]	Registros fictícios de fiado.
item_fiado	[PREENCHER]	Itens de venda associados ao fiado.
pagamento_fiado	[PREENCHER]	Recebimentos totais e parciais.
fornecedor	[PREENCHER]	Fornecedores fictícios.
compra	[PREENCHER]	Compras registradas.
item_compra	[PREENCHER]	Produtos e quantidades das compras.
lote	[PREENCHER]	Lotes e respectivas datas de validade.
movimentacao_estoque	[PREENCHER]	Entradas, saídas, perdas e ajustes.
log_acesso	[PREENCHER]	Registros de ações importantes.


As quantidades devem ser atualizadas após a execução dos comandos de inserção, utilizando consultas COUNT(*) em cada tabela.
5. Repositório GitHub
Repositório: [PREENCHER LINK DO REPOSITÓRIO].

A versão considerada para avaliação deve estar na branch main, conforme orientação do professor.

Organização dos arquivos
Artefato	Localização
Relatório Técnico Final	[`README.md`](README.md)
DER conceitual revisado	Diagramas/der_conceitual
Modelo lógico editável	[`Diagramas/modelo_logico.brm`](Diagramas/modelo_logico.brm)
Imagem do modelo lógico	[`Diagramas/modelo_logico.png`](Diagramas/modelo_logico.png)
Modelo lógico em texto	[`Docs/modelo_logico.md`](Docs/modelo_logico.md)
Normalização	[`Docs/normalizacao.md`](Docs/normalizacao.md)
Justificativa técnica	[`Docs/justificativa_tecnica.md`](Docs/justificativa_tecnica.md)
Dicionário de dados	[`Docs/dicionario_dados.html`](Docs/dicionario_dados.html)
Script SQL	[`Docs/script.sql`](Docs/script.sql)
Criação do banco	[`Docs/criacao_banco.sql`](Docs/criacao_banco.sql)
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
Integrante 2	Criação das tabelas e definição das restrições do banco.	Script de criação do banco.
Integrante 3	Preparação da massa de dados e comandos de manipulação.	Massa de dados, INSERT, UPDATE e DELETE.
Integrante 4	Consultas com JOIN, consultas gerenciais e consultas de auditoria.	Consultas SQL.
Integrante 5	Indicadores, BI e possibilidades de aplicação de IA.	KPIs, análise e rastreabilidade.


[CONFERIR E SUBSTITUIR “INTEGRANTE 2”, “INTEGRANTE 3”, “INTEGRANTE 4” E “INTEGRANTE 5” PELOS NOMES CORRETOS.]
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
Script SQL	[PREENCHER CONFORME O USO DO INTEGRANTE RESPONSÁVEL]	[PREENCHER].
Massa de dados	[PREENCHER CONFORME O USO DO INTEGRANTE RESPONSÁVEL]	[PREENCHER].
Consultas e KPIs	[PREENCHER CONFORME O USO DO INTEGRANTE RESPONSÁVEL]	[PREENCHER].
Apresentação	[PREENCHER CONFORME O USO DO GRUPO]	[PREENCHER].


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
- [ ] Quantidades reais aproximadas da organização confirmadas.
- [ ] Endereço, contato do responsável e evidências incluídos.
- [ ] Entrevista e observação presencial descritas.
- [ ] Problemas P1 a P5 relacionados às tabelas e consultas gerenciais.
- [ ] Processos, requisitos e regras revisados.
- [ ] DER conceitual revisado conforme a notação brModelo.
- [ ] Modelo lógico atualizado e compatível com o script SQL.
- [ ] PKs e FKs conferidas em todas as tabelas.
- [ ] Normalização e justificativas técnicas revisadas.
- [ ] Dicionário de dados atualizado em um único arquivo HTML.
- [ ] Script SQL completo e testado do início ao fim.
- [ ] Massa de dados fictícia e coerente com os processos.
- [ ] Consultas gerenciais e de auditoria identificadas por códigos.
- [ ] Tabela de rastreabilidade preenchida com os códigos reais das consultas.
- [ ] Uso de IA documentado por todos os integrantes.
- [ ] Histórico de commits equilibrado entre os integrantes.
- [ ] Slides preparados para a apresentação de 8 minutos.
- [ ] Todos os links e caminhos de arquivos conferidos na branch main.
- [ ] Campo fl_fiado_autorizado incluído no SQL, modelo lógico e dicionário de dados, ou registrado claramente como melhoria pendente.
- [ ] Limitações de implementação de PRODUTO–`ESTOQUE` e do controle de vencimento do fiado documentada
