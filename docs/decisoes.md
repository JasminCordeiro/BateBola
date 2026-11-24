# Decisões técnicas

Aprovadas pelo grupo em 24/11/2026 (task T50, issue #62). Para mudar uma decisão, abra uma **Solicitação de mudança**.

| # | Decisão | Escolha | Por quê |
| --- | --- | --- | --- |
| 1 | Versão do Flutter | Versão estável atual, fixada para todos e registrada no README e no CI | Versões diferentes quebram o build entre máquinas |
| 2 | Acesso ao Supabase | Pacote oficial `supabase_flutter` | Cobre banco, login e chamadas de função |
| 3 | Gerenciamento de estado | Riverpod | Bom para dados assíncronos e fácil de testar |
| 4 | Rotas | `go_router` | Rotas por URL e proteção da área do proprietário |
| 5 | URL no GitHub Pages | Com `#` | Sem `#`, recarregar uma página interna dá 404 no Pages |
| 6 | Regras de reserva | Função no banco (RPC) + restrição única por quadra, data e hora | Atende o RNF08 e o risco R01, mesmo com acessos simultâneos |
| 7 | Data e hora | Data + hora inteira (0–23) | Horários são sempre de 1 hora cheia; evita erros de fuso |
| 8 | Migrações | Supabase CLI, SQL em `supabase/migrations` | Permite recriar o banco se o projeto for pausado (R07) |
| 9 | Idioma e datas | `intl` + `flutter_localizations`, pt-BR, fuso America/Sao_Paulo | Atende o RNF11 |
| 10 | Máscara de telefone | `mask_text_input_formatter` | O telefone padronizado identifica o cliente no limite de 2 por dia |
| 11 | Exportar relatório | Só na tela; CSV opcional (T33) | O RF11 não exige arquivo |
| 12 | Testes | `flutter_test` + `mocktail` e testes da função no banco | CT04 e CT05 dependem das regras do banco |
| 13 | CI/CD | GitHub Actions: análise e testes em cada PR, publicação no Pages a cada merge | Publicar cedo e sempre reduz o risco R08 |

## Pendente

- Canal de comunicação do grupo (WhatsApp, Discord ou Slack).

## Pontos de atenção

- **Privacidade (RNF07):** o cliente não tem login, então o app usa a chave pública do Supabase. As regras de acesso (RLS) deixam o público ver só os horários ocupados, nunca nome e telefone.
- **Chaves:** a chave pública (`anon`) pode ir no app. A chave `service_role` nunca vai para o código nem para o repositório.
- **Reservas falsas:** sem login, alguém pode reservar com telefones inventados. Risco aceito nesta versão.
- **Pausa do Supabase gratuito:** o projeto pausa após uma semana sem uso (R07). Abrir o sistema antes das apresentações de 11 e 15/12.
- **Desempenho (RNF05):** o Flutter Web demora no primeiro carregamento em celulares simples. Medir cedo com o app publicado.
- **Endereço no Pages:** o build precisa de `--base-href` com o nome do repositório, senão a página publicada abre em branco.
