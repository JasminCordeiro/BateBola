# Riscos

Resumo do Plano de Gerenciamento de Riscos entregue no Moodle. O registro é revisado na reunião semanal e antes de cada marco. As issues ligadas a um risco têm a label `risco:Rxx`.

**Grau** = probabilidade × impacto (1 a 3 cada): 1–2 baixo, 3–4 moderado, 6 alto, 9 crítico.

| ID | Risco | Grau | Resposta principal | Sinal de alerta | Responsável |
| --- | --- | --- | --- | --- | --- |
| R02 | Atraso na integração Flutter + Supabase (login, banco, regras de acesso) | Crítico | Prova de conceito logo no início (T08); telas com dados simulados enquanto isso | Prova de conceito não funciona ou login atrasa | Dev banco / back-end |
| R01 | Falha no controle de reservas simultâneas (mesmo horário ou mais de 2 por dia) | Alto | Restrição única e regra de 2 por dia no banco (T14, T27); testar o CT05 cedo | CT05 falha ou aparecem reservas duplicadas | Dev banco / back-end |
| R03 | Estimativas otimistas atrasam o caminho crítico | Alto | Acompanhamento semanal e reestimativa por três pontos; 4 dias de reserva | Atividade crítica atrasa mais de 1 dia | PM |
| R04 | Mudança ou interpretação diferente dos requisitos pelo professor | Alto | Decisões registradas por escrito; escopo congelado a partir do protótipo | Professor pede mudança de escopo | PM |
| R05 | Integrante indisponível (provas ou outras demandas) | Alto | Substituto para cada atividade crítica; commits diários | Alguém fica fora por mais de 2 dias | PM |
| R06 | Perda de código ou conflitos no Git | Moderado | Branch por task, PR com revisão, `main` protegida, push diário | Conflitos frequentes ou código sem push há mais de 1 dia | Dev geral |
| R07 | Limite do Supabase gratuito ou pausa por falta de uso | Moderado | Scripts do banco no repositório; usar o sistema toda semana; cópia dos dados | Aviso de pausa ou uso perto do limite | Dev banco / back-end |
| R09 | Usabilidade ou desempenho ruins no celular | Moderado | Validar o protótipo; testar em 2 celulares e 3 navegadores; teste com usuários | Usuário não conclui a reserva em 3 telas ou página leva mais de 3 s | UI/UX Designer |
| R10 | Funcionalidades fora do escopo entram no desenvolvimento | Moderado | Documento de visão como linha de base; toda novidade passa por solicitação de mudança | Alguém começa algo que não está no backlog | PM |
| R08 | Falha na publicação perto da entrega ou das apresentações (11 e 15/12) | Moderado | Publicar desde o início e a cada merge (T07) | Publicação falha ou difere da versão local | Dev geral |

## Reservas

- **Cronograma:** 4 dias úteis (01/12 a 04/12).
- **Custos:** R$ 3.387,02 (10% do subtotal). O valor monetário esperado dos riscos é R$ 4.617,53, acima da reserva; a mitigação de R02 e R03 é a prioridade.

## Riscos secundários

- Simplificar a integração (contingência de R02) pode gerar questionamento do professor (R04).
- Trabalhar em paralelo para recuperar prazo (contingência de R03) aumenta conflitos de código (R06).
- Contratar o plano pago do Supabase (contingência de R07) consome a reserva de custos.
