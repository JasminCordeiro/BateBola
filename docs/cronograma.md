# Cronograma

Resumo do Gerenciamento do Tempo entregue no Moodle. O arquivo do GanttProject fica com a PM.

> **Replanejamento em andamento (T52, issue #64).** Em 24/11 o repositório ainda não tinha código, e o marco M2 (17/11) já passou. A nova data do M2 e a nova linha de base dependem da decisão do grupo sobre os cortes de escopo.

## Como o cronograma é gerenciado

- **Metodologia híbrida:** marcos e escopo mínimo fixos, com acompanhamento em ciclos semanais.
- **Ferramentas:** GanttProject para datas, dependências e caminho crítico; GitHub (issues e quadro do projeto) para as tasks.
- **Unidades:** duração em dias úteis; esforço em horas, a 4 h por pessoa por dia útil.
- **Calendário:** segunda a sexta; feriados de 12/10, 02/11 e 20/11 sem trabalho.
- **Controle:** reunião semanal compara o andamento com a linha de base. Desvios que afetam um marco viram solicitação de mudança.

## Marcos

| Marco | Data planejada | O que precisa estar pronto |
| --- | --- | --- |
| M1 – Planejamento concluído | 23/10/2026 | Visão, requisitos, EAP, cronograma, custos, riscos e qualidade (concluído) |
| M2 – Protótipo funcional | 17/11/2026 → **a replanejar** | Módulos do cliente e do proprietário funcionando |
| M3 – Entrega no Moodle | 04/12/2026 | Arquivo .zip com o PDF e o link do GitHub. Prazo final: 06/12/2026 |

## Linha de base original

| ID | Atividade | Dias | Início | Término |
| --- | --- | --- | --- | --- |
| 1.1–1.8 | Gerenciamento do projeto (visão, requisitos, EAP, cronograma, custos, riscos, qualidade) | 13 | 07/10 | 23/10 |
| 2.1 | Protótipo das telas | 4 | 16/10 | 21/10 |
| 2.2 | Modelagem do banco de dados | 2 | 16/10 | 19/10 |
| 2.3 | Configuração do ambiente (Flutter + GitHub) | 2 | 16/10 | 19/10 |
| 3.1 | Login do proprietário | 3 | 20/10 | 22/10 |
| 3.2 | Cadastro e gerenciamento de quadras | 5 | 22/10 | 28/10 |
| 3.3 | Disponibilização das quadras e horários | 4 | 29/10 | 04/11 |
| 4.1 | Consulta de quadras disponíveis | 2 | 23/10 | 26/10 |
| 4.2 | Consulta de horários disponíveis | 2 | 27/10 | 28/10 |
| 4.3 | Reserva de 1 hora (nome e telefone, sem login) | 4 | 05/11 | 10/11 |
| 4.4 | Regra de no máximo 2 horários por dia | 2 | 11/11 | 12/11 |
| 5.1 | Consulta de agendamentos | 2 | 11/11 | 12/11 |
| 5.2 | Relatório de locações por período | 3 | 13/11 | 17/11 |
| 6.1 | Testes funcionais | 3 | 18/11 | 23/11 |
| 6.2 | Correção de defeitos | 3 | 24/11 | 26/11 |
| 6.3 | Publicação da aplicação | 1 | 27/11 | 27/11 |
| 7.1 | Relatório final em PDF | 3 | 24/11 | 26/11 |
| 7.2 | Revisão e .zip | 1 | 30/11 | 30/11 |
| 7.3 | Reserva de contingência | 4 | 01/12 | 04/12 |

**Caminho crítico original:** 1.1 → 1.2 → 1.3 → 2.1 → 3.2 → 3.3 → 4.3 → 5.1 → 5.2 → 6.1 → 6.2 → 6.3 → 7.2 (36 dias úteis + 4 de reserva). As tasks desse caminho têm a label `caminho-critico`.

## Relação com o GitHub

Cada pacote da EAP virou um épico, e cada atividade foi dividida em tasks de até 2 dias:

| Épico | Pacotes da EAP | Issue |
| --- | --- | --- |
| Épico 0 – Ambiente e infraestrutura | 2.3 | #1 |
| Épico 1 – Projeto do sistema | 2.1, 2.2 | #2 |
| Épico 2 – Módulo do proprietário | 3.1–3.3 | #3 |
| Épico 3 – Módulo do cliente | 4.1–4.4 | #4 |
| Épico 4 – Consultas e relatórios | 5.1, 5.2 | #5 |
| Épico 5 – Testes e qualidade | 6.1–6.3 | #6 |
| Épico 6 – Gerência e encerramento | 1, 7.1, 7.2 | #7 |
