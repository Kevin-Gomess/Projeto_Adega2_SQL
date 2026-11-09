# Adega do Tonho — Entrega 2: Modelo Lógico, Implementação SQL e Apresentação Final

### Modelagem de um sistema de gestão de informações para uma organização de pequeno porte

> Relatório Técnico Final do grupo. Este arquivo é o `README.md` da raiz da branch `main` e segue a estrutura do esqueleto da Entrega 2. Os demais artefatos (DER, modelo lógico, dicionário de dados, levantamento, script SQL, massa de dados, consultas e slides) ficam em arquivos separados, com link nas seções abaixo.

> Pendências marcadas como **[PREENCHER]** ou **[CONFIRMAR]** dependem de informação do responsável pela adega, de prints da execução no MySQL ou de confirmação do grupo, e **não** foram inventadas.

---

## 1. Relatório Técnico Final

### Integrantes

| Nome completo do aluno | RGM | Usuário do GitHub |
| :---- | :---- | :---- |
| Kevin Gomes | 47796006 | [PREENCHER] |
| Brayan Antonio Daza Paredes | 50184857 | [PREENCHER] |
| Gabriel dos Santos Eufrasio | 49005260 | [PREENCHER] |
| Gabriel Gonçalves Moura | 48892009 | [PREENCHER] |
| Felipe Militão | 49331108 | [PREENCHER] |

### 1.1 Revisão do Modelo Conceitual

**Caracterização da organização**

- **Nome e natureza da organização:** Adega do Tonho, comércio de pequeno porte, com fins lucrativos, que vende bebidas, alimentos, produtos para narguilé, cigarros e outros itens de conveniência. É a mesma organização da Entrega 1, mantendo a continuidade do levantamento e da modelagem.
- **Contexto e porte:**
  - Tempo de funcionamento: cerca de 4 anos.
  - Pessoas envolvidas: 3 a 4 pessoas por dia.
  - Horário: segunda a quinta, das 13h às 23h; sexta a domingo, das 13h à meia-noite.
  - Produtos: refrigerantes, cervejas, bebidas alcoólicas, doces, salgadinhos, sucos, itens de mercearia, produtos para narguilé, cigarros e isqueiros. Algumas bebidas também são vendidas em doses.
  - Estrutura física: a frente é usada para atendimento e exposição; os fundos são o estoque.
    - Quantidade aproximada de produtos cadastrados: entre 100 e 300.
    - Média aproximada de vendas por dia: de 10 a 20 vendas por dia de terça a quinta; de sexta a domingo passa de 25 vendas por dia com facilidade. 
    - Quantidade aproximada de clientes autorizados a comprar no fiado: cerca de 30 pessoas.
    - Quantidade aproximada de compras com fornecedores: de 3 a 5 vezes por semana.
- **Problemas e necessidades identificados:** a crise operacional é que vendas comuns, estoque e fiado são controlados em caderno e no celular. Cada problema precisa aparecer no DER e ter ao menos uma consulta gerencial (ver a tabela de rastreabilidade na seção 1.6).

| Código | Problema identificado | Como o sistema poderá ajudar |
| :---- | :---- | :---- |
| P1 | Nas vendas comuns, não existe registro detalhado de cada produto vendido. | Registrar cada venda e seus respectivos itens, quantidades e preços. |
| P2 | Existem diferenças entre as quantidades anotadas e o estoque real. | Registrar entradas, saídas, perdas e ajustes de estoque. |
| P3 | Existe dificuldade para identificar quais produtos apresentam maior saída. | Consultar os produtos mais vendidos por período. |
| P4 | A identificação de produtos que estão acabando depende principalmente da observação visual. | Permitir o acompanhamento das quantidades disponíveis e dos limites mínimos de estoque. |
| P5 | O controle do fiado é realizado manualmente, dificultando o acompanhamento dos valores devidos e dos recebimentos. | Registrar clientes, vendas fiadas, valores devidos e pagamentos realizados. |

- **Escopo do sistema:** o banco reúne os dados de toda a adega, não só de um setor:
  - produtos, categorias, estoque e movimentações de estoque;
  - lotes e validade;
  - vendas, itens vendidos, pagamentos, doses e garrafas abertas;
  - clientes, fiado e recebimentos de fiado;
  - fornecedores, compras e itens comprados;
  - funcionários e escalas;
  - caixa (abertura, fechamento, suprimento, sangria e despesa);
  - registro de ações importantes para auditoria.

  O modelo conceitual possui 18 entidades de negócio. Na implementação lógica há 21 tabelas: as 18 entidades mais três tabelas de apoio criadas na implementação: `log_acesso` (auditoria), `garrafa_aberta` (volume restante das garrafas abertas para dose) e `movimentacao_caixa` (suprimentos, sangrias e despesas do caixa).
- **Justificativa da escolha:** a Adega do Tonho é uma organização real, de pequeno porte, com vendas, compras, pagamentos, controle de estoque e fiado. Um dos integrantes tem vínculo de trabalho com a adega e acompanha parte da rotina; esse vínculo facilitou o levantamento, mas **não dispensa a entrevista com o responsável no local** (ver o relato abaixo).
- **Evidências da organização** (arquivos JPG ou PNG dentro de [`evidencias/`](evidencias/)):
  - Endereço completo: R. Joaquim Meira de Siqueira, 772 - Jardim Nossa Sra. do Carmo, São Paulo - SP, 08275-490
  - Perfil no Google Meu Negócio (Google Business Profile): [PREENCHER LINK].
  - Site ou rede social: Não tem.
  - Fotos do local e da visita: fundo.jpeg, fundo.estoque.jpeg, fundo.estoque2.jpeg, fundo.estoque3.jpeg, balcao1.jpeg, balcao2.jpe, balcao3.jpeg, frente.jpeg.
- **Responsável pela organização:**
  - Nome: Eric .
  - Função: Dono .
  - Telefone para contato: [Não autorizado].

**Relato da entrevista**

- **Quem:** entrevistado Kevin, funcionario e gerente ; integrantes participantes Gabriel.
- **Quando e onde:** data [PREENCHER]; local: Adega do Tonho, no próprio estabelecimento.
- **Comprovação:** ao menos uma foto da entrevista no local, em JPG ou PNG, na pasta [`evidencias/`](evidencias/) 
- **O que foi levantado:** o levantamento completo, escrito pelo grupo, está em [`levantamento/levantamento.md`](levantamento/levantamento.md). Resumo:
  - Os preços são consultados em cadernos ou etiquetas.
  - Nas vendas comuns, o produto é entregue após o pagamento, mas não há registro detalhado de cada item vendido.
  - No fiado, são anotados os produtos retirados e os valores devidos.
  - As compras de fornecedores são anotadas no celular, com produtos e quantidades; na chegada, a conferência é item por item.
  - A falta de produtos é percebida olhando as prateleiras e o estoque.
  - Quando uma garrafa é aberta para vender doses, ela deixa de ser vendida como garrafa fechada.
  - Há diferença entre as quantidades anotadas e as encontradas no estoque.
  - O fiado é restrito a clientes conhecidos ou autorizados.
- **Achados da observação presencial:** a observação mostrou a organização dos produtos (frente e fundos), a consulta de preços, o atendimento, as anotações de compras e a conferência das mercadorias recebidas. 
- **O que mudou em relação à Entrega 1:** depois da avaliação, o grupo ampliou a cobertura dos processos com controle de abertura e fechamento de caixa, recebimento e quitação de fiado, validade por lote, perdas e quebras, escalas dos funcionários e registro de ações importantes. Esses itens entraram como **propostas de funcionamento do sistema**: não significa que a adega já os faça hoje. 

**Nível de detalhe — processos, requisitos e regras de negócio**

Os processos, requisitos e regras abaixo indicam os dados envolvidos (campos que aparecem no DER, no dicionário de dados e no modelo lógico), e não só frases genéricas. O detalhamento completo está nos arquivos da pasta [`levantamento/`](levantamento/).

**Processos de negócio**

Processos detalhados e fluxogramas: [`levantamento/processos.md`](levantamento/processos.md). A coluna *Origem* separa o que foi observado do que é proposta do sistema.

| Código | Processo | Descrição resumida | Origem | Representação no modelo |
| :---- | :---- | :---- | :---- | :---- |
| PR01 | Venda no balcão | Atendimento ao cliente, conferência dos preços, cálculo do valor e conclusão da venda. | Observado | VENDA, ITEM_VENDA, PRODUTO, FUNCIONARIO e CAIXA |
| PR02 | Pagamento de venda | Registro do pagamento por Pix, dinheiro, cartão ou fiado. O sistema também prevê pagamentos divididos. | Formas de pagamento observadas; divisão como proposta | PAGAMENTO e VENDA |
| PR03 | Venda fiada | Registro dos produtos retirados por clientes conhecidos ou autorizados e do valor que ficará pendente. | Registro de fiado observado; controles adicionais como proposta | CLIENTE, FIADO, ITEM_FIADO, VENDA e ITEM_VENDA |
| PR04 | Recebimento de fiado | Registro de pagamentos totais ou parciais e atualização do saldo devedor. | Proposta | FIADO, PAGAMENTO_FIADO e CAIXA |
| PR05 | Compra de produtos | Identificação da necessidade de reposição e realização do pedido ao fornecedor. | Observado | COMPRA, ITEM_COMPRA, FORNECEDOR e FUNCIONARIO |
| PR06 | Recebimento e conferência | Conferência dos produtos recebidos e identificação de divergências. | Observado | COMPRA, ITEM_COMPRA, FORNECEDOR e LOTE |
| PR07 | Controle de estoque | Acompanhamento das quantidades disponíveis e identificação da necessidade de reposição. | Observado; controle informatizado como proposta | PRODUTO e ESTOQUE |
| PR08 | Movimentação de estoque | Registro de entradas, saídas, abertura de garrafas para doses e ajustes. | Parcialmente observado; registro informatizado como proposta | MOVIMENTACAO_ESTOQUE, PRODUTO e FUNCIONARIO |
| PR09 | Perdas e validade | Registro de produtos quebrados, perdidos ou vencidos, com controle de validade por lote. | Proposta | LOTE, MOVIMENTACAO_ESTOQUE e PRODUTO |
| PR10 | Abertura e fechamento de caixa | Registro do valor inicial, movimentações, valor contado e possíveis diferenças no fechamento. | Proposta | CAIXA, VENDA e PAGAMENTO |
| PR11 | Cadastro de produtos | Organização das informações dos produtos, categorias, preços e características de venda. | Necessidade identificada no levantamento | PRODUTO e CATEGORIA |
| PR12 | Escala de funcionários | Registro dos dias, horários e funções dos funcionários. | Proposta | FUNCIONARIO e ESCALA |

*Processos típicos do tipo de organização que ficaram de fora, e por quê:*

| Processo provável | Justificativa |
| :---- | :---- |
| Entrega em domicílio | A adega não faz entrega e nem pretende fazer. |
| Folha de pagamento | Ainda não existe na adega; por isso ficou fora do sistema. |
| Programa de fidelidade | A adega não tem. |
| Emissão de documento fiscal pelo sistema | Não entrou como função do sistema proposto, mas a adega vai precisar quando tiver um sistema. Por enquanto o banco só guarda o número do documento. |

**Requisitos**

Levantamento completo: [`levantamento/Requisitos.md`](levantamento/Requisitos.md).

*Requisitos funcionais*

| Código | Requisito funcional |
| :---- | :---- |
| RF01 | O sistema deve permitir cadastrar produtos com nome, categoria, preço, código de barras, quando aplicável, e situação. |
| RF02 | O sistema deve permitir consultar produtos, preços e quantidades disponíveis em estoque. |
| RF03 | O sistema deve permitir controlar a quantidade disponível de cada produto. |
| RF04 | O sistema deve permitir registrar entradas de produtos, informando produto, quantidade, data e origem da entrada. |
| RF05 | O sistema deve permitir registrar saídas de produtos, identificando o motivo da movimentação. |
| RF06 | O sistema deve permitir registrar a abertura de garrafas destinadas à venda de doses como saída de estoque. |
| RF07 | O sistema deve permitir registrar vendas com data, funcionário, caixa, produtos, quantidades, preços unitários e valor total. |
| RF08 | O sistema deve permitir registrar uma ou mais formas de pagamento utilizadas em uma venda. |
| RF09 | O sistema deve permitir cadastrar clientes e registrar quais estão autorizados a realizar compras por fiado. O cliente é cadastrado bloqueado para fiado e só é liberado pelo gerente, que também define o limite. |
| RF10 | O sistema deve permitir registrar fiados vinculados a uma venda, identificando o cliente e os itens que ficaram pendentes. |
| RF11 | O sistema deve permitir registrar e consultar o limite de fiado de cada cliente e verificar o limite disponível antes de uma nova operação. |
| RF12 | O sistema deve permitir cadastrar fornecedores com seus dados de identificação e contato. |
| RF13 | O sistema deve permitir registrar compras de fornecedores, incluindo produtos, quantidades, preços e valores. |
| RF14 | O sistema deve permitir identificar produtos que estejam no estoque mínimo ou abaixo dele. |
| RF15 | O sistema deve permitir consultar os produtos com maior quantidade vendida em determinado período. |
| RF16 | O sistema deve permitir cadastrar funcionários e identificar os responsáveis pelas vendas, compras e movimentações de estoque. |
| RF17 | O sistema deve permitir registrar a abertura do caixa, informando o funcionário responsável e o valor inicial. |
| RF18 | O sistema deve permitir registrar o fechamento do caixa, calcular o valor esperado, comparar com o valor contado e registrar justificativas para diferenças. |
| RF19 | O sistema deve permitir registrar pagamentos totais ou parciais de fiado, atualizando o saldo devedor. |
| RF20 | O sistema deve permitir registrar lotes de produtos com suas respectivas quantidades e datas de validade. |
| RF21 | O sistema deve permitir identificar produtos vencidos ou próximos do vencimento. |
| RF22 | O sistema deve permitir cadastrar escalas dos funcionários, informando dia, horário e função. |
| RF23 | O sistema deve permitir registrar perdas, quebras e ajustes de estoque, identificando o motivo e o funcionário responsável. |
| RF24 | O sistema deve permitir registrar a conferência dos itens recebidos em compras e suas possíveis divergências. |
| RF25 | O sistema deve permitir registrar suprimentos, sangrias e despesas em dinheiro no caixa aberto, para que o valor esperado do fechamento considere essas movimentações. |
| RF26 | O sistema deve permitir controlar o volume restante de cada garrafa aberta para venda de doses, impedindo a venda de doses acima do volume disponível. |

*Requisitos não funcionais*

| Código | Requisito não funcional | Critério ou medida proposta |
| :---- | :---- | :---- |
| RNF01 | Facilidade de uso: a interface deve ser simples e intuitiva para os funcionários. | Avaliação de uso com funcionário da adega. |
| RNF02 | Rapidez: as consultas de produtos, preços e estoque devem apresentar resultados rapidamente. | Meta proposta de até 2 segundos para consultas comuns. |
| RNF03 | Integridade: os dados de vendas, compras e estoque devem permanecer consistentes. | Verificação por consultas de auditoria. |
| RNF04 | Segurança: o acesso às funcionalidades deve respeitar as permissões de cada usuário. | Perfis de atendente e gerente, se implementados. |
| RNF05 | Disponibilidade: as informações devem estar disponíveis durante o horário de funcionamento. | Meta proposta de até 15 minutos de indisponibilidade por semana no horário de funcionamento. |
| RNF06 | Cópia de segurança: o sistema deve permitir cópias de segurança dos dados. | Meta proposta de pelo menos uma cópia por dia. |
| RNF07 | Compatibilidade: o sistema deve permitir utilização em computadores e dispositivos móveis. | Testes em computador e celular. |
| RNF08 | Proteção de dados pessoais: os dados de clientes e funcionários devem ser tratados conforme a LGPD. | Acesso restrito e tratamento adequado dos dados. |
| RNF09 | Manutenibilidade: a estrutura deve facilitar futuras alterações e correções. | Organização das tabelas, relacionamentos e documentação. |

*Requisitos típicos de adega que ficaram de fora, e por quê:*

| Requisito provável | Justificativa |
| :---- | :---- |
| Emissão de nota fiscal eletrônica pelo sistema | Não entrou como função agora; o banco só guarda o número do documento fiscal (`nr_documento_fiscal`, `nr_nota_fiscal`). A adega vai precisar quando tiver um sistema. |
| Venda por entrega (delivery) | A adega não faz entrega e nem pretende fazer. |
| Programa de fidelidade e cupons | A adega não tem. |
| Integração com a maquininha de cartão | Fora do escopo do banco de dados; o sistema só registra a forma de pagamento. |
| Previsão de demanda por IA | Fica como ideia futura (seção 1.6), porque depende de histórico real da adega. |

**Regras de negócio**

Regras completas: [`levantamento/regras_de_negocio.md`](levantamento/regras_de_negocio.md). As regras *propostas* (não observadas) devem ser validadas com o responsável antes de serem tratadas como procedimentos vigentes na adega. O prazo do fiado fica em `fiado.dt_vencimento`; o número de dias (a massa de dados usa 30) ainda precisa ser confirmado.

| Código | Regra de negócio |
| :---- | :---- |
| RN01 | Uma venda pode ser paga em dinheiro, Pix, cartão de débito ou cartão de crédito. Também pode ter uma parte do valor lançada como fiado, desde que sejam atendidas as regras de autorização e limite do cliente. |
| RN02 | Toda venda deve possuir data e hora, funcionário responsável, caixa relacionado e pelo menos um item registrado. |
| RN03 | O valor total da venda deve corresponder à soma dos subtotais dos itens, considerando os descontos aplicados. |
| RN04 | Cada item de uma venda deve identificar o produto, o tipo de comercialização, a quantidade e o preço unitário aplicado no momento da venda. |
| RN05 | Toda movimentação de estoque deve identificar o produto, o tipo de movimentação, a quantidade, a data e o funcionário responsável. |
| RN06 | Quando uma garrafa for aberta para venda de doses, a abertura deve ser registrada como saída de uma unidade fechada do estoque, conforme o controle adotado para o produto. O volume restante da garrafa aberta é controlado em mililitros e cada dose vendida o reduz; não se vende dose acima do volume restante. |
| RN07 | Uma venda pode possuir mais de um registro de pagamento. A soma dos valores registrados nas diferentes formas de pagamento, incluindo a parcela destinada ao fiado, deve corresponder ao total da venda. O valor lançado como fiado deve gerar ou atualizar a conta correspondente do cliente. |
| RN08 | Para realizar uma operação com fiado, o cliente deve estar cadastrado e identificado no sistema. |
| RN09 | Toda conta de fiado deve estar relacionada à venda que originou o valor pendente e ao cliente responsável pela dívida. |
| RN10 | Cada cliente deve possuir um limite de crédito definido no cadastro. O valor pendente não pode ultrapassar o limite autorizado. |
| RN11 | Antes de registrar uma nova parcela no fiado, o sistema deve verificar se o cliente não está bloqueado e se possui limite disponível. O limite disponível corresponde ao limite cadastrado menos os valores ainda pendentes. |
| RN12 | Todo pagamento de fiado deve ser considerado no cálculo do valor já pago e do saldo pendente da conta. |
| RN13 | Cada recebimento de fiado deve registrar a conta correspondente, o valor recebido, a forma de pagamento, a data e o caixa responsável. |
| RN14 | Uma conta deve permanecer com situação ABERTO enquanto o valor pago for menor que o valor total devido. Quando o valor pago alcançar o valor total, a situação deve ser QUITADO. |
| RN15 | Produtos perdidos, quebrados, vencidos ou retirados por outros motivos devem ter sua saída registrada com a quantidade, a data, o motivo e o funcionário responsável. |
| RN16 | Toda correção manual de estoque deve registrar a quantidade movimentada, a data, o motivo e o funcionário responsável. |
| RN17 | O saldo do estoque deve refletir as entradas e saídas registradas nas movimentações. |
| RN18 | Produtos que exigem controle de validade devem possuir registro de lote e data de vencimento. |
| RN19 | Produtos com validade vencida não devem ser disponibilizados para venda e sua retirada deve ser registrada no estoque. |
| RN20 | Cada item de uma compra deve identificar o produto, a quantidade solicitada e o custo unitário. |
| RN21 | No recebimento de uma compra, a quantidade recebida deve ser conferida com a quantidade solicitada. Faltas, produtos incorretos ou avarias devem ser registrados. |
| RN22 | Toda abertura de caixa deve registrar o funcionário responsável, a data e hora e o valor inicial disponível. |
| RN23 | No fechamento, o valor contado deve ser comparado com o valor esperado. O valor esperado considera o troco inicial, as vendas e os recebimentos de fiado em dinheiro, os suprimentos e, como saída, as sangrias e despesas. Diferenças devem ser registradas e justificadas. |
| RN24 | Vendas e recebimentos de fiado devem ser relacionados ao caixa em que ocorreram, para permitir a conferência dos valores. |
| RN25 | Toda escala deve identificar o funcionário, o dia de trabalho, o horário de início, o horário de término e a função exercida. |
| RN26 | É proibido vender, fornecer ou entregar bebidas alcoólicas a crianças e adolescentes menores de 18 anos. A maioridade deve ser conferida antes da conclusão da venda. |
| RN27 | A comercialização de produtos fumígenos deve respeitar as restrições legais, incluindo a proibição de venda a menores de 18 anos, as advertências sanitárias obrigatórias e as regras de exposição dos produtos nos pontos de venda. |
| RN28 | As operações de venda e compra devem ter seus documentos fiscais registrados e emitidos conforme as obrigações aplicáveis ao enquadramento tributário e à legislação estadual da organização. |
| RN29 | Os dados pessoais de clientes e funcionários devem ser utilizados somente para finalidades relacionadas às atividades da organização, com acesso restrito e tratamento adequado conforme a LGPD. |
| RN30 | As operações importantes do sistema, como acessos, inclusões, alterações, exclusões e consultas a dados pessoais, devem possuir registro de auditoria, identificando o funcionário, a data, o tipo de evento e o registro envolvido. |

*Regras típicas de adega que ficaram de fora, e por quê:*

| Regra provável | Justificativa |
| :---- | :---- |
| Horário limite para venda de bebida alcoólica | Depende da lei do município; na adega não existe horário limite para isso. |
| Política de troca e devolução ao cliente | O cliente só precisa chegar com a nota de compra e mostrar o defeito. |
| Promoções e descontos por quantidade | Só existe desconto simples na venda (`venda.vl_desconto`); promoção só em época de festa. |
| Comissão de funcionários | Não tem comissão; só no fim do ano os funcionários ganham uma caixinha pelo ano trabalhado. |

**Notação do DER conceitual**

- Software em que o DER foi criado: brModelo [PREENCHER VERSÃO].
- O DER segue a notação do brModelo (entidades em retângulo, relacionamentos em losango, cardinalidades mínima e máxima, atributos identificadores como círculo preenchido) e **não** tem chaves estrangeiras; elas só aparecem no modelo lógico (seção 2).

**Caso A — mesma organização da Entrega 1**

### DER conceitual revisado

- **Arquivo oficial do brModelo:** [`Diagramas/der_conceitual`](Diagramas/der_conceitual).
- **Modelo lógico:** [`Diagramas/modelo_logico.brm`](Diagramas/modelo_logico.brm).

O DER conceitual oficial foi desenvolvido no brModelo. O modelo lógico apresenta a estrutura das entidades, atributos e relacionamentos utilizados na implementação do banco de dados.

As **18 entidades de negócio** do DER revisado:

CATEGORIA, PRODUTO, ESTOQUE, FUNCIONARIO, ESCALA, CAIXA, VENDA, ITEM_VENDA, PAGAMENTO, CLIENTE, FIADO, ITEM_FIADO, PAGAMENTO_FIADO, FORNECEDOR, COMPRA, ITEM_COMPRA, LOTE e MOVIMENTACAO_ESTOQUE.

`LOG_ACESSO`, `GARRAFA_ABERTA` e `MOVIMENTACAO_CAIXA` foram acrescentadas na implementação lógica, com finalidade técnica e de controle, e não são entidades de negócio do DER. [CONFERIR com o grupo: se preferirem, incluir `GARRAFA_ABERTA` e `MOVIMENTACAO_CAIXA` no DER para ele refletir 20 entidades de negócio.]

Para cada apontamento da correção da Entrega 1, o que foi feito:

| Apontamento da correção da E1 | O que mudou no trabalho | Por quê |
| :---- | :---- | :---- |
| DER apresentava apenas cardinalidades máximas. | Inclusão das cardinalidades mínimas e máximas nos relacionamentos. | Permitir compreender a participação obrigatória ou opcional das entidades. |
| Chaves estrangeiras apareciam no modelo conceitual. | Retirada das chaves estrangeiras do DER conceitual. | As FKs pertencem ao modelo lógico. |
| Relacionamentos de estoque e venda estavam inconsistentes. | A movimentação de estoque passou a representar entradas e saídas relacionadas aos produtos. | Evitar relacionamento direto inadequado entre venda e estoque. |
| Relacionamentos de pagamento apresentavam duplicidade. | Organização do pagamento da venda e do recebimento de fiado em estruturas próprias. | Diferenciar o pagamento da venda do recebimento posterior da dívida. |
| Faltavam relações com funcionários. | Inclusão das relações entre funcionários, vendas, compras, escalas e movimentações. | Identificar os responsáveis pelas operações. |
| O modelo não contemplava adequadamente validade e lotes. | Inclusão da entidade LOTE e de sua relação com os itens de compra e movimentações. | Permitir controlar diferentes datas de validade de um mesmo produto. |
| Não existia representação de caixa. | Inclusão da entidade CAIXA. | Permitir representar as operações de caixa previstas no sistema. |
| Processos de negócio estavam incompletos. | Ampliação do modelo para contemplar recebimento de fiado, caixa, perdas, validade e escala. | Aumentar a cobertura dos processos da organização. |


### 1.2 Conversão do Modelo Conceitual para o Modelo Lógico

- **Entidades → Tabelas:** cada entidade do DER virou uma tabela relacional (18 tabelas), mais três tabelas de apoio criadas na implementação (`log_acesso`, `garrafa_aberta` e `movimentacao_caixa`).
- **Atributos → Colunas:** cada atributo virou uma coluna, com tipo de dado, obrigatoriedade, unicidade e valores permitidos descritos no [dicionário de dados](docs/dicionario_dados.html). `vl_subtotal` (item de venda) e `vl_diferenca` (caixa) são colunas calculadas.
- **Relacionamentos → Chaves:**
  - Relacionamentos 1:N viraram chave estrangeira no lado N.
  - Relacionamentos 1:1 viraram chave estrangeira com `UNIQUE` (por exemplo `estoque.id_produto`).
  - Relacionamentos N:N viraram tabelas associativas, como `ITEM_VENDA` e `ITEM_COMPRA`.
  - `ITEM_FIADO` guarda `id_item_venda` (único), `vl_fiado` e `dt_lancamento`; produto, quantidade e preço são consultados em `ITEM_VENDA`. O valor `vl_fiado` diz quanto da linha foi para o fiado (no máximo o subtotal), o que permite pagamento dividido.
  - `ITEM_VENDA` guarda também `id_lote` (lote de onde saiu a unidade) e `id_garrafa_aberta` (garrafa de onde saiu a dose), ambos opcionais.
  - `FIADO` tem as FKs `id_venda` (UNIQUE: uma venda gera no máximo um fiado) e `id_cliente`. `PAGAMENTO` não tem `id_fiado`: a ligação é pela venda de origem. Os recebimentos posteriores ficam em `PAGAMENTO_FIADO` (FKs para `FIADO` e `CAIXA`). Não há relação direta entre `FIADO` e `ITEM_FIADO`; a ligação é por `ITEM_VENDA`.
  - `LOTE.id_item_compra` é FK sem UNIQUE: um item de compra pode gerar vários lotes.
  - `LOG_ACESSO.id_funcionario` aceita NULL (vínculo opcional).
- **Cardinalidades:** as cardinalidades mínimas e máximas do DER foram convertidas em obrigatoriedade da FK (mínima 1 = `NOT NULL`) e em unicidade (máxima 1 no lado referenciado). A tabela da seção 1.3 lista os 30 relacionamentos com suas cardinalidades.
- **Generalização/especialização:** o DER não tem generalização; nenhuma estratégia de conversão foi necessária.

*Decisões de conversão:*

- **Estoque:** a tabela `ESTOQUE` guarda a quantidade total de cada produto; o levantamento não identificou necessidade de controlar quantidades por local. A relação PRODUTO–ESTOQUE é 1:1: `estoque.id_produto` é `NOT NULL` e `UNIQUE`, e o trigger `trg_produto_cria_estoque` cria o estoque (zerado) a cada produto inserido, o que garante na prática a participação obrigatória.
- **Validade:** controlada por lote, pois um produto pode ter vários vencimentos.
- **Fiado:** é um registro ligado à venda de origem; os recebimentos ficam em tabela própria, então o pagamento da venda e a quitação da dívida são operações diferentes.
- **Autorização para fiado:** a regra diz que o fiado só vale para cliente conhecido e autorizado. No SQL isso é `cliente.fl_bloqueado`, que nasce com 1 (bloqueado). Só o gerente libera o cliente e define o limite, pela procedure `sp_autorizar_cliente_fiado`, e `sp_registrar_venda_fiado` recusa cliente bloqueado ou sem limite disponível. Por isso não foi criado o campo `fl_fiado_autorizado`.

### 1.3 Definição de Chaves Primárias e Estrangeiras

As chaves primárias identificam cada registro; as chaves estrangeiras criam os relacionamentos e mantêm a integridade referencial. A lista abaixo segue o modelo lógico e o [script SQL](docs/script.sql).

**Os 30 relacionamentos (chaves estrangeiras), com cardinalidade mínima e máxima de cada lado**

| Nº | Relacionamento | FK no SQL |
| :---- | :---- | :---- |
| 1 | Categoria (0,N) — Produto (1,1) | produto.id_categoria |
| 2 | Produto (1,1) — Estoque (1,1) | estoque.id_produto |
| 3 | Produto (0,N) — Movimentação de Estoque (1,1) | movimentacao_estoque.id_produto |
| 4 | Funcionário (0,N) — Movimentação de Estoque (1,1) | movimentacao_estoque.id_funcionario |
| 5 | Lote (0,N) — Movimentação de Estoque (0,1) | movimentacao_estoque.id_lote |
| 6 | Item da Compra (0,N) — Lote (1,1) | lote.id_item_compra |
| 7 | Funcionário (0,N) — Escala (1,1) | escala.id_funcionario |
| 8 | Funcionário (0,N) — Caixa (1,1) | caixa.id_funcionario |
| 9 | Funcionário (0,N) — Venda (1,1) | venda.id_funcionario |
| 10 | Caixa (0,N) — Venda (1,1) | venda.id_caixa |
| 11 | Venda (1,N) — Item da Venda (1,1) | item_venda.id_venda |
| 12 | Produto (0,N) — Item da Venda (1,1) | item_venda.id_produto |
| 13 | Venda (1,N) — Pagamento (1,1) | pagamento.id_venda |
| 14 | Cliente (0,N) — Fiado (1,1) | fiado.id_cliente |
| 15 | Fiado (0,N) — Pagamento do Fiado (1,1) | pagamento_fiado.id_fiado |
| 16 | Caixa (0,N) — Pagamento do Fiado (1,1) | pagamento_fiado.id_caixa |
| 17 | Venda (0,1) — Fiado (1,1) | fiado.id_venda |
| 18 | Item da Venda (0,1) — Item do Fiado (1,1) | item_fiado.id_item_venda |
| 19 | Fornecedor (0,N) — Compra (1,1) | compra.id_fornecedor |
| 20 | Funcionário (0,N) — Compra (1,1) | compra.id_funcionario |
| 21 | Compra (1,N) — Item da Compra (1,1) | item_compra.id_compra |
| 22 | Produto (0,N) — Item da Compra (1,1) | item_compra.id_produto |
| 23 | Funcionário (0,N) — Log de Acesso (0,1) | log_acesso.id_funcionario |
| 24 | Lote (0,N) — Item da Venda (0,1) | item_venda.id_lote |
| 25 | Garrafa Aberta (0,N) — Item da Venda (0,1) | item_venda.id_garrafa_aberta |
| 26 | Lote (0,N) — Garrafa Aberta (1,1) | garrafa_aberta.id_lote |
| 27 | Produto (0,N) — Garrafa Aberta (1,1) | garrafa_aberta.id_produto |
| 28 | Funcionário (0,N) — Garrafa Aberta (1,1) | garrafa_aberta.id_funcionario |
| 29 | Caixa (0,N) — Movimentação do Caixa (1,1) | movimentacao_caixa.id_caixa |
| 30 | Funcionário (0,N) — Movimentação do Caixa (1,1) | movimentacao_caixa.id_funcionario |

**Chaves primárias e referências principais de cada tabela**

| Tabela | Chave primária | Referências principais |
| :---- | :---- | :---- |
| categoria | id_categoria | — |
| produto | id_produto | id_categoria |
| estoque | id_estoque | id_produto |
| funcionario | id_funcionario | — |
| escala | id_escala | id_funcionario |
| caixa | id_caixa | id_funcionario |
| cliente | id_cliente | — |
| venda | id_venda | id_funcionario, id_caixa |
| item_venda | id_item_venda | id_venda, id_produto, id_lote (opcional), id_garrafa_aberta (opcional) |
| pagamento | id_pagamento | id_venda |
| fiado | id_fiado | id_cliente, id_venda |
| item_fiado | id_item_fiado | id_item_venda |
| pagamento_fiado | id_pagamento_fiado | id_fiado, id_caixa |
| fornecedor | id_fornecedor | — |
| compra | id_compra | id_fornecedor, id_funcionario |
| item_compra | id_item_compra | id_compra, id_produto |
| lote | id_lote | id_item_compra |
| movimentacao_estoque | id_movimentacao | id_produto, id_lote, id_funcionario |
| garrafa_aberta | id_garrafa_aberta | id_lote, id_produto, id_funcionario |
| movimentacao_caixa | id_movimentacao_caixa | id_caixa, id_funcionario |
| log_acesso | id_log | id_funcionario (FK, aceita NULL) |

**Pontos de atenção**

- `fiado.id_venda` é FK com UNIQUE: uma venda está ligada a no máximo um fiado.
- `item_fiado.id_item_venda` é FK com UNIQUE: um item de venda tem no máximo um item de fiado.
- `lote.id_item_compra` não tem UNIQUE: um item de compra pode originar vários lotes.
- `movimentacao_estoque.id_lote` aceita NULL: uma movimentação pode não ter lote.
- `pagamento` não tem FK direta para `fiado`.
- `item_venda.id_lote` e `item_venda.id_garrafa_aberta` aceitam NULL: o lote é exigido pelo trigger quando o produto controla validade e o item é UNIDADE; a garrafa é exigida quando o item é DOSE.
- `log_acesso.id_funcionario` aceita NULL.

### 1.4 Processo de Normalização (1FN, 2FN e 3FN)

Normalização detalhada, tabela por tabela: [`docs/normalizacao.md`](docs/normalizacao.md).

- **1FN:** cada coluna guarda um valor único. Uma venda tem vários produtos, então os itens foram separados em `ITEM_VENDA`, em vez de uma lista de produtos dentro de `VENDA`. O mesmo vale para as compras (`ITEM_COMPRA`).
- **2FN:** todas as tabelas usam chave primária de uma coluna, então não existe dependência parcial da chave. Dados de produto, categoria, fornecedor e funcionário ficam nas tabelas deles, e as tabelas de itens guardam só o que é da operação (quantidade, preço aplicado).
- **3FN:** nenhum atributo comum depende de outro atributo comum. Os dados da categoria não se repetem em cada produto vendido: ficam em `CATEGORIA`. Fornecedor, funcionário e cliente também ficam em tabelas próprias, ligadas por FK. O subtotal do item e a diferença do caixa são colunas calculadas, não digitadas.
- **Justificativa do processo:** a adega registra muitas operações sobre os mesmos produtos, clientes, funcionários e fornecedores. Sem normalizar, o nome ou o preço de um produto seria repetido em cada venda e qualquer correção geraria divergência.

### 1.5 Justificativas Técnicas das Decisões

Justificativas completas: [`docs/justificativa_tecnica.md`](docs/justificativa_tecnica.md).

- **Chaves primárias:** identificadores numéricos próprios (`id_produto`, `id_venda`, `id_cliente`…) em vez de nome, telefone ou CPF, que podem mudar e são sensíveis (LGPD). Facilitam as FKs.
- **Chaves estrangeiras:** implementam os relacionamentos: `produto.id_categoria` (produto de uma categoria), `item_venda.id_venda` e `item_venda.id_produto` (o que foi vendido em cada venda), `fiado.id_cliente` e `fiado.id_venda` (de quem é a dívida e que venda a gerou), `compra.id_fornecedor` (quem forneceu), `movimentacao_estoque.id_produto` (qual produto movimentou) e `log_acesso.id_funcionario` (quem fez a ação, quando se sabe). Todas são `RESTRICT`: histórico de venda e de estoque não pode sumir.
- **Restrições, com a regra de negócio que cada uma implementa:**
  - `NOT NULL` em dados obrigatórios (RN02, RN04, RN05).
  - `UNIQUE` em CPF, código de barras, CNPJ, `fiado.id_venda` e `item_fiado.id_item_venda` (RN08, RN09).
  - `CHECK` para preço e quantidades positivos, estoque não negativo, fiado com valor pago até o total (RN10, RN14), perda e ajuste com motivo (RN15, RN16), fechamento de caixa com valor contado (RN23), garrafa com ml restante entre 0 e o inicial (RN06).
  - `DEFAULT` em situações iniciais, como `cliente.fl_bloqueado = 1` (RN08, RN11).
- **Decisões arquiteturais:**
  - Estoque por produto, com quantidade total; validade separada por lote.
  - Itens de venda e de compra em tabelas próprias.
  - Fiado com registro próprio e recebimentos separados dos pagamentos da venda.
  - Caixa com abertura, fechamento e movimentos (suprimento, sangria, despesa).
  - Regras no próprio banco por triggers e procedures, para que não dependam só do sistema que vier a usar o banco.

*Regras garantidas no banco, e limitações:*

- A venda de unidade gera sozinha a saída de estoque (trigger `trg_item_venda_registra_saida`); o saldo do produto e do lote só muda por movimentação (`trg_movimentacao_atualiza_estoque`). A consulta A01 confere os saldos.
- O item de venda informa o lote (unidade) ou a garrafa aberta (dose); o trigger recusa lote de outro produto, vencido ou sem saldo.
- Produto vencido não é vendido, e a abertura de garrafa de lote vencido é recusada. O vencido que fica parado precisa ser baixado como PERDA por um funcionário; a consulta A18 lista esses lotes.
- O fiado tem prazo (`dt_vencimento`); o controle do que venceu é por consulta (G07 e A12). Não existe trigger que bloqueie sozinho o cliente em atraso: o gerente bloqueia por UPDATE em `cliente.fl_bloqueado`, e a A12 mostra quem está em atraso e não está bloqueado.
- A auditoria em `log_acesso` é gravada por triggers (cliente, fiado, recebimento de fiado, fechamento de caixa) e pela procedure `sp_registrar_evento_acesso` (login e consulta a dado pessoal), usando a variável `@id_funcionario_logado`, que a aplicação precisa definir. Se não definir, o evento é gravado sem funcionário.
- Alterações de preço e de outras tabelas não têm trigger de auditoria; ficam como melhoria futura.
- Cancelamento de venda: o banco permite `st_venda = 'CANCELADA'`, mas não devolve o estoque sozinho; a devolução é um ajuste de estoque feito pelo gerente.
- Os triggers usam `CURRENT_DATE()` do servidor para conferir validade e vencimento; por isso a massa de dados usa `SET TIMESTAMP` (ver seção 4).

### 1.6 Proposta de Arquitetura Analítica para BI e IA

Documento completo: [`docs/indicadores_kpis.md`](docs/indicadores_kpis.md).

- **Informações estratégicas:** produtos e categorias que mais saem, e em quais dias e horários; faturamento por período e por forma de pagamento; produtos no mínimo ou abaixo; valores pendentes de fiado e quem está em atraso; compras por fornecedor; produtos perto do vencimento; perdas e quebras; diferenças no fechamento do caixa.
- **Indicadores e métricas gerenciais (KPIs).** A meta de faturamento é a do dono, R$ 5.000 por mês; as demais metas de referência foram definidas por nós para uma adega pequena, olhando o ritmo de vendas que ele informou e a meta de faturamento de R$ 5.000 por mês (alguns meses a adega fica bem abaixo disso). São sugestões do grupo, para o gerente ajustar:

| Código | KPI | Fórmula | Período | Meta |
| :---- | :---- | :---- | :---- | :---- |
| KPI01 | Faturamento | soma de `venda.vl_total` das vendas CONCLUIDA | dia, mês | R$ 5.000 por mês; terça a quinta cerca de R$ 100 por dia; sexta a domingo mais de R$ 150 por dia |
| KPI02 | Ticket médio | faturamento ÷ número de vendas concluídas | mês | R$ 8 ou mais por venda (R$ 5.000 por mês dividido pelas vendas do mês) |
| KPI03 | Produtos mais vendidos | receita e quantidade de `item_venda` por produto | mês | os 10 mais vendidos nunca podem faltar na prateleira |
| KPI04 | Produtos no mínimo ou abaixo | produtos com `qt_atual <= qt_minima` | diário | no máximo 5 produtos no mínimo ou abaixo ao mesmo tempo, e nenhum dos 10 mais vendidos |
| KPI05 | Saldo de fiado em aberto | soma de (`vl_total` − `vl_pago`) dos fiados ABERTO | semanal | até R$ 500 em aberto (cerca de 10% do faturamento do mês) |
| KPI06 | Fiado vencido | fiados ABERTO com `dt_vencimento` anterior a hoje | semanal | até R$ 100 vencido e nenhum cliente com mais de 30 dias de atraso |
| KPI07 | Perdas e quebras | quantidade e valor das movimentações PERDA | mês | perdas de até 1% do faturamento do mês (uns R$ 50) |
| KPI08 | Diferença de caixa | soma de `caixa.vl_diferenca` dos caixas FECHADO | dia, mês | soma do mês entre -R$ 20 e +R$ 20, e nenhum caixa com diferença acima de R$ 5 |

- **Potencial dos dados para BI:** as tabelas de movimento (`venda`, `item_venda`, `pagamento`, `movimentacao_estoque`, `movimentacao_caixa`, `fiado`, `compra`, `caixa`) ligadas às de cadastro (`produto`, `categoria`, `funcionario`, `cliente`, `fornecedor`) alimentam painéis de vendas, estoque, fiado, caixa e compras. Cada consulta gerencial (G) vira um gráfico ou tabela de painel, e as consultas de auditoria (A) viram um painel de qualidade dos dados.
- **Aplicações analíticas e de IA:** nenhuma foi implementada neste trabalho; o banco não faz previsão sozinho. Possibilidades futuras, com histórico **real**: previsão de reposição de cada produto, previsão de dias e horários de pico para a escala, sugestão de limite de fiado pelo histórico de pagamento e alerta de produto parado. Treinar um modelo na massa fictícia só ensinaria as regras do gerador, não o comportamento da adega.

**Rastreabilidade**

Cada problema e cada KPI com as tabelas que o sustentam e a consulta do script que o responde (códigos em [`docs/consultas.sql`](docs/consultas.sql)):

| Problema ou KPI | Tabelas envolvidas | Consulta no script |
| :---- | :---- | :---- |
| P1 — Falta de registro detalhado das vendas | VENDA, ITEM_VENDA, PRODUTO | J01, G01, G02, G03, J07 |
| P2 — Diferenças no estoque | ESTOQUE, MOVIMENTACAO_ESTOQUE | G13, A01, A19 |
| P3 — Dificuldade para identificar produtos com maior saída | ITEM_VENDA, PRODUTO | G04 |
| P4 — Identificação de produtos com baixa quantidade | ESTOQUE, PRODUTO | G05 |
| P5 — Controle manual do fiado | FIADO, CLIENTE, PAGAMENTO_FIADO | G06, G07, A07 a A11 |
| KPI01 — Faturamento por período | VENDA | G01, G01b |
| KPI02 — Ticket médio | VENDA | G02 |
| KPI03 — Produtos mais vendidos | ITEM_VENDA, PRODUTO | G04 |
| KPI04 — Produtos no estoque mínimo | ESTOQUE, PRODUTO | G05 |
| KPI05 — Saldo de fiado | FIADO, PAGAMENTO_FIADO | G06 |
| KPI06 — Fiados vencidos | FIADO, CLIENTE | G07 |
| KPI07 — Perdas e quebras | MOVIMENTACAO_ESTOQUE, LOTE, PRODUTO | G08 |
| KPI08 — Diferença de caixa | CAIXA, VENDA, PAGAMENTO, MOVIMENTACAO_CAIXA | G09, G09b |

---

## 2. Modelo Lógico Relacional

- **SGBD:** MySQL 8.0.16 ou superior (os `CHECK` só são aplicados a partir dessa versão).
- **Software em que o modelo lógico foi criado:** brModelo 3.3 (gerado e salvo com o próprio programa, a partir do `docs/script.sql`).
- **Arquivo editável do brModelo:** [`diagramas/modelo_logico.brm`](diagramas/modelo_logico.brm) (abre no brModelo 3.x; 21 tabelas e 30 ligações).
- **Imagem do modelo lógico:** [`diagramas/modelo_logico.png`](diagramas/modelo_logico.png) (exportada na notação do brModelo, com as 21 tabelas).
- **Modelo lógico em texto:** [`docs/modelo_logico.md`](docs/modelo_logico.md); 

![Modelo lógico da Adega do Tonho](diagramas/modelo_logico.png)

O modelo contém 21 tabelas, com colunas e tipos de dados, chaves primárias (PK), chaves estrangeiras (FK) e as cardinalidades já convertidas (tabela da seção 1.3). O que o diagrama não mostra (`NOT NULL`, `UNIQUE`, `CHECK`, `DEFAULT`) está no [dicionário de dados](docs/dicionario_dados.html) e implementado no [script SQL](docs/script.sql).

---

## 3. Script SQL Completo

O script é o arquivo [`docs/script.sql`](docs/script.sql) (MySQL 8.0.16 ou superior). Ele cria o banco, as 21 tabelas, as constraints, os 33 triggers e as 6 procedures. Não existe outro arquivo de criação.

**Ordem de execução e arquivos:**

| Ordem | Arquivo | O que faz |
| :---: | :--- | :--- |
| 1 | [`docs/script.sql`](docs/script.sql) | `CREATE DATABASE`, `CREATE TABLE`, constraints, triggers e procedures |
| 2 | [`docs/massa_de_dados.sql`](docs/massa_de_dados.sql) | `INSERT INTO`: massa de dados fictícia (seção 4) |
| 4 | [`docs/consultas.sql`](docs/consultas.sql) | `SELECT` com `JOIN` (J), consultas gerenciais (G) e de auditoria (A) |
| — | [`docs/exemplos_basicos.sql`](docs/_criação.sql) | Exemplos simples de manipulação |
O script contempla as etapas pedidas, nesta ordem lógica: (1) `CREATE DATABASE`; (2) `CREATE TABLE`; (3) constraints (PK, FK, `NOT NULL`, `UNIQUE`, `CHECK`); (4) `INSERT INTO` (massa); (5) `SELECT` com `JOIN`; (6) `UPDATE`; (7) `DELETE`; (8) consultas gerenciais; (9) consultas de auditoria. Os itens 6 e 7 estão em `testes.sql` (dentro de `START TRANSACTION … ROLLBACK`, para não alterar a massa).

**Consultas gerenciais e de auditoria:** cada uma tem um cabeçalho com o código (`G01`…, `A01`…), a pergunta em português e o que atende, como neste exemplo:

```sql
-- G05 — Quais produtos estão no estoque mínimo ou abaixo?
-- Atende: P4 e KPI04

-- A07 — Existe fiado cujo total não bate com a soma dos valores lançados nas linhas?
-- Verifica: RN09 e RN07
```

As consultas gerenciais respondem aos problemas P1 a P5 e aos KPIs da seção 1.6; as de auditoria devem voltar **vazias** quando os dados estão certos (exceção declarada: A18, que lista lote vencido ainda com saldo). São essas as consultas usadas na demonstração da apresentação.

**Testes de execução** (preencher depois de rodar no MySQL):

> Até aqui o script, a massa e as consultas foram conferidos apenas por **simulação** (banco equivalente sem triggers nem procedures). A execução real no MySQL ainda precisa ser feita e anotada abaixo.

- Criação do banco a partir de um banco vazio: [PREENCHER].
- Criação de todas as tabelas, triggers e procedures: [PREENCHER].
- Inserção da massa de dados: [PREENCHER].
- Execução das consultas e dos testes: [PREENCHER].
- Erros encontrados e correções realizadas: [PREENCHER].
- Evidências (prints): [`evidencias/`](evidencias/).

---

## 4. Massa de Dados

Arquivo: [`docs/massa_de_dados.sql`](docs/massa_de_dados.sql). Rodar depois do `script.sql`, em banco recém-criado, uma única vez.

- **Dados fictícios.** Nenhum nome, CPF, CNPJ, telefone ou valor é real; os CPFs e CNPJs são inventados. A massa é coerente com as operações modeladas (vendas, compras, fiado, caixa, validade).
- **Como foi gerada:** na ordem em que a adega funciona (cadastra, compra, recebe, abre o caixa, vende, lança fiado, recebe fiado, fecha o caixa), passando pelos triggers e procedures. Por isso ela **não** insere direto em estoque, saída de venda, fiado nem item de fiado: o banco preenche. O uso de IA está registrado na seção 6.
- **`SET TIMESTAMP`:** como os triggers usam `CURRENT_DATE()` para conferir validade e vencimento, a massa usa `SET TIMESTAMP` para o relógio do MySQL seguir a data simulada (03/08/2026 a 01/11/2026) e volta ao relógio real no fim. Esse comando exige usuário com permissão (root no Workbench local tem).

**Justificativa do volume de dados**

A massa simula cerca de 3 meses de funcionamento (03/08/2026 a 01/11/2026) com 4 funcionários, 105 produtos, 5 fornecedores e 30 clientes cadastrados no fiado. O volume segue os números informados (seção 1.1):

| Número informado | Como a massa o reflete |
| :---- | :---- |
| 100 a 300 produtos | 105 produtos (o piso da faixa, para a massa não ficar inflada) |
| 10 a 20 vendas por dia de terça a quinta | 10 a 20 vendas por dia de terça a quinta (média de cerca de 14 a 15) |
| Mais de 25 vendas por dia de sexta a domingo | 25 a 38 vendas por dia de sexta a domingo (média de cerca de 27 a 31) |
| Cerca de 30 clientes no fiado | 30 clientes cadastrados; 101 fiados no período |
| Compras de 3 a 5 vezes por semana | 1 pedido por semana a cada um dos 5 fornecedores (68 compras em 13 semanas, cerca de 5 por semana) |

A segunda-feira não foi informada; a massa usa de 8 a 14 vendas. Esses números ainda precisam da confirmação do responsável e, se mudarem, o volume deve ser ajustado.

**Variedade dos dados**

- Produtos de 8 categorias, com e sem venda em dose (6 vendidos em dose);
- produtos com estoque acima do mínimo, no mínimo e abaixo dele;
- vendas com formas de pagamento diferentes e pagamento dividido;
- vendas canceladas (31) e descontos;
- clientes bloqueados (4) e autorizados no fiado, com fiado em aberto, vencido e quitado, e recebimentos parciais;
- compras de 5 fornecedores, com recebimento parcial (divergência) e uma compra cancelada;
- clientes que nunca usaram o fiado (2 dos 30);
- lotes com validades diferentes, inclusive vencidos;
- movimentações de entrada, saída de venda, saída de dose, perda, ajuste e devolução ao fornecedor;
- caixas com fechamento certo, com sobra e com falta, e suprimentos, sangrias e despesas;
- registros de auditoria (login, falha de login, consulta de dado pessoal, aprovação, alteração).

**Quantidade de registros por tabela**

| Tabela | Quantidade | Justificativa pelo volume e pelas regras |
| :---- | :---- | :---- |
| categoria | 8 | Categorias dos produtos comercializados. |
| produto | 105 | Variedade de produtos (faixa informada: 100 a 300), 6 deles também vendidos em dose. |
| estoque | 105 | Um registro de estoque por produto, criado pelo trigger. |
| funcionario | 4 | Equipe de 4 pessoas (1 gerente e 3 atendentes). |
| escala | 208 | Turnos de 13h às 23h (meia-noite de sexta a domingo) nos 91 dias. |
| caixa | 91 | Um caixa por dia; o último fica aberto. |
| cliente | 30 | Cerca de 30 clientes no fiado (número informado); 4 bloqueados. |
| venda | 1858 | Vendas fictícias (1.827 concluídas e 31 canceladas) em 3 meses, no ritmo informado por dia da semana. |
| item_venda | 3405 | Itens das vendas, em unidade e em dose. |
| pagamento | 2123 | Pagamentos (inclui a parte FIADO lançada pela procedure). |
| fiado | 101 | Fiados: 25 em aberto e 76 quitados. |
| item_fiado | 187 | Linhas de venda alocadas ao fiado pela procedure. |
| pagamento_fiado | 87 | Recebimentos totais e parciais. |
| fornecedor | 5 | Fornecedores fictícios (CNPJs inventados). |
| compra | 68 | Pedidos aos 5 fornecedores, cerca de 5 por semana: 46 recebidos, 21 recebidos parcialmente e 1 cancelado. |
| item_compra | 635 | Produtos e quantidades das compras. |
| lote | 477 | Lotes com validades diferentes, inclusive vencidos. |
| movimentacao_estoque | 4141 | Entradas, saídas de venda e de dose, perdas, ajustes e devolução. |
| garrafa_aberta | 14 | Garrafas abertas para vender doses. |
| movimentacao_caixa | 70 | Suprimentos, sangrias e despesas do caixa. |
| log_acesso | 936 | Logins, alterações e aprovações registradas pelos triggers e procedures. |

As quantidades acima vêm da simulação; depois de rodar no MySQL, conferir com `SELECT COUNT(*)` em cada tabela.

---

## 5. Repositório GitHub

- **Repositório:** [PREENCHER LINK DO REPOSITÓRIO]. A versão avaliada é a da branch `main`.

**Organização dos arquivos**

| Artefato | Localização |
| :---- | :---- |
| Relatório Técnico Final | [`README.md`](README.md) |
| DER conceitual revisado | [`diagramas/der_conceitual`](diagramas/). apoio: [`.png`](diagramas/der_conceitual.png) e [`.md`](diagramas/der_conceitual.md) |
| Modelo lógico (editável, brModelo) | [`diagramas/modelo_logico.brm`](diagramas/modelo_logico.brm) |
| Modelo lógico (imagem) | [`diagramas/modelo_logico.png`](diagramas/modelo_logico.png) |
| Modelo lógico (texto) | [`docs/modelo_logico.md`](docs/modelo_logico.md) |
| Normalização | [`docs/normalizacao.md`](docs/normalizacao.md) |
| Justificativa técnica | [`docs/justificativa_tecnica.md`](docs/justificativa_tecnica.md) |
| Dicionário de dados (HTML único) | [`docs/dicionario_dados.html`](docs/dicionario_dados.html) |
| Script SQL | [`docs/script.sql`](docs/script.sql) |
| Massa de dados | [`docs/massa_de_dados.sql`](docs/massa_de_dados.sql) |
| Consultas (J, G e A) | [`docs/consultas.sql`](docs/consultas.sql) |
| Exemplos SQL | [`docs/exemplos_basicos.sql`](docs/exemplos_basicos.sql) |
| Indicadores, BI e IA | [`docs/indicadores_kpis.md`](docs/indicadores_kpis.md) |
| Levantamento | [`levantamento/levantamento.md`](levantamento/levantamento.md) |
| Requisitos | [`levantamento/Requisitos.md`](levantamento/Requisitos.md) |
| Processos de negócio | [`levantamento/processos.md`](levantamento/processos.md) |
| Regras de negócio | [`levantamento/regras_de_negocio.md`](levantamento/regras_de_negocio.md) |
| Evidências da organização e da entrevista (JPG/PNG) | [`evidencias/`](evidencias/) |

**Histórico de commits e colaboração**

Os commits devem ser feitos pelos próprios integrantes, cada um com a própria conta do GitHub, de forma equilibrada e ao longo do tempo (não um único commit final). O nome configurado em cada conta deve ser compatível com o nome da tabela de Integrantes. [COMPLEMENTAR: informar como foi a divisão dos commits e conferir o usuário do GitHub de cada integrante.]

**Divisão de tarefas**
| **Integrante** | **Responsabilidade** | **Arquivos ou atividades** |
|---|---|---|
| **Kevin Gomes** | Revisão do DER, modelo lógico, chaves, normalização, justificativa técnica, README e organização da documentação. | Modelo lógico, normalização, justificativa técnica e README. |
| **Brayan Antonio Daza Paredes** | Implementação da estrutura do banco de dados, criação das tabelas, definição das chaves primárias e estrangeiras e aplicação das restrições. | `script.sql` – criação do banco, tabelas, PKs, FKs e restrições. |
| **Gabriel dos Santos Eufrasio** | Elaboração e inserção da massa de dados fictícios, execução de operações de atualização e exclusão e realização de testes no banco de dados. | `massa_dados.sql` – INSERT, UPDATE, DELETE e testes de integridade. |
| **Gabriel Gonçalves Moura** | Desenvolvimento de consultas SQL para extração de informações, utilização de JOINs, consultas gerenciais e verificações para auditoria. | `consultas.sql` – SELECT, JOIN e consultas gerenciais. |
| **Felipe Militão** | Definição de indicadores de desempenho (KPIs), análise de informações de vendas e estoque e elaboração de propostas de utilização de Business Intelligence (BI). | Indicadores (KPIs), análise de vendas e estoque e propostas de BI. |
---

## 6. Uso de Inteligência Artificial

Ferramentas de IA foram usadas como **apoio** à organização, revisão e conferência do trabalho. As informações sobre a Adega do Tonho vêm do levantamento do grupo; a IA não substituiu a pesquisa de campo.

**Resumo dos usos**

| Etapa | Ferramenta | Utilização |
| :---- | :---- | :---- |
| Revisão do DER | ChatGPT | Apoio na análise dos relacionamentos, cardinalidades e entidades. |
| Modelo lógico | ChatGPT | Apoio na conversão das entidades em tabelas e na organização das chaves. |
| Normalização | ChatGPT | Apoio na compreensão e justificativa das formas normais. |
| README e documentação | ChatGPT | Organização do conteúdo conforme o esqueleto fornecido pelo professor. |
| Processos, requisitos e regras | ChatGPT | Apoio na revisão e ampliação dos documentos. |
| Conferência entre arquivos | Claude | Comparação do script SQL com modelo lógico, dicionário de dados, normalização, requisitos, regras e README; lista de divergências e correções. |
| Script SQL | [PREENCHER conforme o uso do integrante responsável] | [PREENCHER]. |
| Massa de dados | Claude | Apoio na criação de um gerador de dados fictícios que respeita os triggers e procedures do script; o grupo deve revisar e rodar no MySQL. |
| Consultas e KPIs | Claude | Apoio na escrita das consultas J, G e A, dos testes e do documento de indicadores; o grupo deve rodar e conferir os resultados. |
| Apresentação | [PREENCHER conforme o uso do grupo] | [PREENCHER]. |

**Registro 1 — Revisão do DER e do modelo lógico (ChatGPT)**

| Item | Registro |
| :---- | :---- |
| Ferramenta e etapa | ChatGPT; revisão do DER e conversão para o modelo lógico |
| Motivação | Revisar os apontamentos da avaliação da Entrega 1 e apoiar a conversão do modelo conceitual para o lógico |
| Prompt(s) utilizados | Pedidos para revisar os arquivos do projeto, achar inconsistências entre DER, modelo lógico e script SQL, conferir relacionamentos e organizar PKs e FKs. [COLAR o texto exato dos prompts] |
| Resposta recebida | Sugestões de ajuste em entidades, relacionamentos, cardinalidades, chaves e organização das tabelas |
| Fontes consultadas e verificadas | Esqueleto da Entrega 2, avaliação da Entrega 1 e arquivos do próprio grupo |
| Trechos rejeitados ou corrigidos | Sugestões com duplicação de informação no controle do fiado e relacionamentos inconsistentes foram revistas |
| Justificativa da escolha final | Mantidas as decisões coerentes com o levantamento e com a estrutura do banco |
| Reflexão crítica | A IA ajudou a achar problemas e organizar a documentação, mas algumas sugestões apresentavam como realidade da adega processos que ainda são propostas do sistema |

**Registro 2 — README, processos, requisitos e regras (ChatGPT)**

| Item | Registro |
| :---- | :---- |
| Ferramenta e etapa | ChatGPT; redação do relatório e revisão de processos, requisitos e regras |
| Motivação | Organizar o relatório conforme o modelo do professor e revisar os documentos da Entrega 1 |
| Prompt(s) utilizados | Pedidos para revisar os documentos da Entrega 1, ampliar processos incompletos e organizar o README no esqueleto da Entrega 2. [COLAR o texto exato dos prompts] |
| Resposta recebida | Sugestões de estrutura, revisão de textos, processos propostos e organização de requisitos e regras |
| Fontes consultadas e verificadas | Documentos do grupo, avaliação do professor e esqueleto da Entrega 2 |
| Trechos rejeitados ou corrigidos | O que não foi confirmado pela organização foi marcado como proposta ou pendente de validação |
| Justificativa da escolha final | Mantido o que corresponde ao levantamento; as propostas ficaram identificadas separadamente |
| Reflexão crítica | A IA pode sugerir processos comuns de outras adegas que não existem na Adega do Tonho; o grupo precisa conferir com o responsável |

**Registro 3 — Conferência entre arquivos, massa de dados, consultas e testes (Claude)**

| Item | Registro |
| :---- | :---- |
| Ferramenta e etapa | Claude; conferência entre os arquivos do repositório, geração da massa de dados, consultas J/G/A, testes e documento de indicadores |
| Motivação | Garantir que script SQL, modelo lógico, dicionário, normalização, levantamento e README digam a mesma coisa, e ter massa e consultas que respeitem os triggers do banco |
| Prompt(s) utilizados | "Confira se as informações batem uma com a outra; se não bater, me fale o que está errado, corrija e mande a correção, pois quero um trabalho perfeito." [COMPLEMENTAR com os outros prompts] |
| Resposta recebida | Lista de divergências (o SQL tinha 21 tabelas e a documentação 18 ou 19, havia dois scripts de estrutura, a massa não respeitava os triggers, arquivos vazios) e arquivos corrigidos |
| Fontes consultadas e verificadas | O `script.sql` do próprio grupo; a consistência entre arquivos foi conferida por programa (dicionário contra o SQL) e a massa foi conferida em um banco equivalente sem triggers (simulação) |
| Trechos rejeitados ou corrigidos | [PREENCHER após rodar no MySQL: o que o grupo ajustou] |
| Justificativa da escolha final | Mantida a versão do `script.sql` do grupo como referência e a documentação alinhada a ele |
| Reflexão crítica | A conferência foi por simulação: triggers, procedures e `SET TIMESTAMP` não foram executados em MySQL real. O volume da massa é estimado, não confirmado com a adega. O grupo precisa rodar e revisar tudo |

---

## 7. Apresentação Corporativa Final

Pitch de 8 minutos, com slides limpos e sem blocos longos de texto. Roteiro completo, com falas e perguntas para ensaio: [`docs/roteiro_apresentacao.md`](docs/roteiro_apresentacao.md).

- Arquivo dos slides: [PREENCHER CAMINHO OU LINK].
- Ferramenta utilizada: [PREENCHER].
- Tempo: 8 minutos.

| Ordem | Conteúdo | Tempo sugerido |
| :---- | :---- | :---- |
| 1 | Contextualização da Adega do Tonho e dos problemas identificados. | 1 minuto |
| 2 | Apresentação da solução proposta. | 1 minuto |
| 3 | Apresentação do modelo lógico, tabelas e relacionamentos. | 1 minuto e 30 segundos |
| 4 | Demonstração da implementação SQL em execução. | 1 minuto e 30 segundos |
| 5 | Demonstração das consultas gerenciais e de auditoria. | 1 minuto e 30 segundos |
| 6 | Potencial de utilização de BI e IA. | 45 segundos |
| 7 | Benefícios para a tomada de decisão da organização. | 45 segundos |

**Participação e defesa:** todos os integrantes participam da apresentação e estão presentes na defesa do modelo lógico; cada pergunta é respondida por quem a recebeu. Cada integrante conhece e explica a parte pela qual ficou responsável e as decisões tomadas.
