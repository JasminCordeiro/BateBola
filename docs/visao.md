# Visão do produto e requisitos

Resumo do Documento de Visão v1.2 (28/10/2026), entregue no Moodle. É a linha de base do escopo: o que não está aqui só entra por **Solicitação de mudança**.

## Problema

Em muitos espaços esportivos, o aluguel de quadras de tênis é combinado por telefone, mensagem ou caderno. O cliente não sabe quais horários estão livres, e o proprietário perde tempo com atendimento, corre o risco de marcar duas pessoas no mesmo horário e não tem histórico confiável das locações.

**Solução:** um sistema web em que o cliente consulta quadras e horários livres e reserva 1 hora informando só nome e telefone. O proprietário cadastra as quadras, define quando ficam disponíveis, consulta as reservas e gera relatórios por período.

## Premissas

| ID | Premissa |
| --- | --- |
| P1 | Aplicação Flutter Web responsiva, sem publicação em lojas de aplicativos |
| P2 | Supabase e hospedagem disponíveis; plano gratuito suficiente no desenvolvimento |
| P3 | Um único espaço esportivo, com um proprietário e uma ou mais quadras |
| P4 | O cliente é identificado pelo telefone; o limite de 2 horários por dia é por telefone |
| P5 | Horários de 1 hora cheia (ex.: 08:00 às 09:00), dentro do funcionamento definido pelo proprietário |
| P6 | Sem pagamento pelo sistema; o pagamento é combinado com o proprietário |
| P7 | A conta do proprietário é criada pela equipe; não há cadastro aberto de proprietários |
| P8 | O acesso à internet é responsabilidade dos usuários |
| P9 | 5 integrantes, 4 horas por dia útil cada |

## Restrições

| ID | Restrição |
| --- | --- |
| R1 | Entrega até 06/12/2026, com protótipo funcional para a apresentação |
| R2 | Aplicação web em Flutter |
| R3 | No máximo 5 integrantes |
| R4 | Orçamento limitado: ferramentas gratuitas sempre que possível |
| R5 | O cliente não cria conta; informa só nome completo e telefone |
| R6 | Cada reserva tem 1 hora; no máximo 2 horários por dia por cliente |
| R7 | Só nome e telefone do cliente são coletados (LGPD) |
| R8 | Código no GitHub, com link no relatório final |

## Requisitos funcionais

| ID | Requisito | Perfil |
| --- | --- | --- |
| RF01 | Consultar quadras disponíveis, com nome e descrição | Cliente |
| RF02 | Consultar os horários livres de uma quadra numa data | Cliente |
| RF03 | Reservar 1 hora informando nome completo e telefone, sem login | Cliente |
| RF04 | Impedir mais de 2 horários por dia para o mesmo cliente | Cliente |
| RF05 | Impedir duas reservas para a mesma quadra no mesmo horário | Cliente |
| RF06 | Mostrar a confirmação com quadra, data e horário | Cliente |
| RF07 | Login do proprietário com e-mail e senha | Proprietário |
| RF08 | Cadastrar, editar e remover (desativar) quadras | Proprietário |
| RF09 | Definir dias e horários de funcionamento de cada quadra e deixá-la indisponível | Proprietário |
| RF10 | Consultar as reservas, com filtro por data e por quadra | Proprietário |
| RF11 | Relatório de locações por período, com quadra, data, horário, nome e telefone | Proprietário |

## Histórias de usuário (escopo desta versão)

| ID | Como um | Eu quero | Para | Issue |
| --- | --- | --- | --- | --- |
| HU01 | cliente | consultar as quadras disponíveis | escolher onde quero jogar | #43 |
| HU02 | cliente | consultar os horários livres de uma quadra numa data | encontrar um horário que sirva | #44 |
| HU03 | cliente | reservar 1 hora informando só nome e telefone | garantir a quadra sem criar conta | #46, #47 |
| HU04 | cliente | ver a confirmação com quadra, data e horário | ter certeza de que a reserva foi feita | #48 |
| HU05 | proprietário | que cada cliente reserve no máximo 2 horários por dia | dar oportunidade a mais clientes | #47 |
| HU06 | proprietário | fazer login | acessar com segurança a área de gerenciamento | #34 |
| HU07 | proprietário | cadastrar, editar e remover quadras | manter a lista de quadras atualizada | #37, #38 |
| HU08 | proprietário | definir os dias e horários de cada quadra | controlar quando ela pode ser reservada | #39 |
| HU09 | proprietário | consultar as reservas realizadas | organizar o uso das quadras | #49 |
| HU10 | proprietário | gerar um relatório das locações de um período | saber quem alugou cada quadra | #50 |

Os critérios de aceitação de cada história estão nas issues. As histórias HU11 a HU40 (administrador, pagamento, convites, avaliações, limpeza, manutenção e check-in) estão fora do escopo e ficam registradas na issue #71.

## Cenários de teste

| ID | Cenário | História |
| --- | --- | --- |
| CT01 | Horário já reservado não aparece como livre | HU02 |
| CT02 | Reserva com sucesso mostra a confirmação e ocupa o horário | HU03, HU04 |
| CT03 | Reserva sem telefone é recusada | HU03 |
| CT04 | Terceiro horário no mesmo dia é recusado; outro dia é permitido | HU05 |
| CT05 | Duas pessoas reservando o mesmo horário: só a primeira é registrada | HU03 |
| CT06 | Login com senha certa entra; com senha errada mostra erro | HU06 |
| CT07 | Quadra nova com horário de funcionamento aparece para o cliente | HU07, HU08 |
| CT08 | Relatório do período lista as locações e o total, sem reservas de fora | HU10 |

O texto completo de cada cenário (Dado/Quando/Então) está nas issues das histórias.

## Requisitos não funcionais

| ID | Tipo | Requisito |
| --- | --- | --- |
| RNF01 | Plataforma | Aplicação web em Flutter |
| RNF02 | Compatibilidade | Versões atuais do Chrome, Edge, Firefox e Safari |
| RNF03 | Responsividade | Celulares a partir de 360 px, tablets e computadores |
| RNF04 | Usabilidade | Reserva concluída em no máximo 3 telas, sem criar conta |
| RNF05 | Desempenho | Consultas de quadras e horários em até 3 segundos no 4G |
| RNF06 | Segurança | Área do proprietário só com login; HTTPS; senhas não guardadas em texto aberto |
| RNF07 | Privacidade | Só nome e telefone, visíveis apenas ao proprietário (LGPD) |
| RNF08 | Consistência | O mesmo horário não pode ser reservado duas vezes, mesmo com acessos simultâneos |
| RNF09 | Disponibilidade | Disponível 24 horas por dia, hospedado em nuvem |
| RNF10 | Manutenibilidade | Código no GitHub, com instruções de execução no README |
| RNF11 | Idioma | Interface toda em português do Brasil |
