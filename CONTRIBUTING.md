# Como contribuir

Regras de trabalho do grupo no BateBola. Valem para código e documentação.

## 1. Escolher uma task

- As tasks ficam nas [issues](https://github.com/JasminCordeiro/BateBola/issues) e no [quadro do projeto](https://github.com/users/JasminCordeiro/projects/4).
- Cada task tem um ID (`T01` a `T63`) e pertence a um épico (pacote da EAP).
- A label `papel:*` mostra de qual papel é a task. Veja quem ocupa cada papel em [`docs/equipe.md`](docs/equipe.md).
- Ao começar, atribua a issue a você e mude o Status para **In Progress** no quadro.

### Uma task está pronta para começar quando (Definition of Ready)

- [ ] O "Pronto quando" está claro
- [ ] Tem estimativa em horas e papel definido
- [ ] As tasks de que ela depende estão concluídas, ou é possível usar dados simulados

## 2. Branches

A `main` é a versão publicada e só recebe código por pull request.

Crie uma branch por task, a partir da `main` atualizada:

| Tipo | Quando usar | Exemplo |
| --- | --- | --- |
| `feature/` | Funcionalidade nova | `feature/T27-funcao-reserva` |
| `fix/` | Correção de defeito | `fix/T39-limite-reservas` |
| `docs/` | Só documentação | `docs/T50-decisoes` |
| `chore/` | Configuração, CI, dependências | `chore/T06-ci` |

```bash
git checkout main
git pull
git checkout -b feature/T27-funcao-reserva
```

## 3. Commits

Mensagem curta, em português, no imperativo, com o tipo e o ID da task:

```
feat(T27): adiciona função de reserva no banco
fix(T39): corrige limite de 2 reservas por dia
docs(T50): registra decisões técnicas
chore(T06): configura CI no GitHub Actions
test(T35): testa reservas simultâneas
```

Faça commit e push todo dia, mesmo com a task pela metade (risco R06).

## 4. Pull requests

- Abra o PR assim que tiver algo para mostrar. Use **Draft** enquanto não estiver pronto.
- Escreva `Closes #<número da issue>` na descrição para a issue fechar sozinha no merge.
- Todo PR precisa de **1 revisão aprovada** de outra pessoa do grupo.
- O CI precisa passar (análise e testes), assim que a T06 estiver pronta.
- Quem revisa confere os critérios de aceitação da issue, não só o código.
- Use **Squash and merge** e apague a branch depois.

## 5. Task concluída (Definition of Done)

- [ ] Todos os critérios de aceitação da issue atendidos
- [ ] PR revisado e aprovado, CI passando
- [ ] Sem chaves ou senhas no código (só a chave pública `anon` do Supabase, por `--dart-define`)
- [ ] Textos da interface em português
- [ ] README ou `docs/` atualizados, se a task mudou como rodar ou configurar o projeto
- [ ] Campo **Horas reais** preenchido no quadro do projeto

## 6. Labels

| Label | Significado |
| --- | --- |
| `epico` | Issue pai de um pacote da EAP |
| `caminho-critico` | Atividade no caminho crítico: atraso aqui atrasa a entrega |
| `candidata-a-corte` | Pode sair do escopo se o prazo apertar |
| `risco:R01` a `risco:R10` | Ligada a um risco de [`docs/riscos.md`](docs/riscos.md) |
| `papel:*` | Papel responsável |
| `bug` | Defeito encontrado nos testes |
| `mudanca` | Solicitação de mudança de escopo ou prazo |
| `fora-do-escopo` | Fica para uma versão futura |

## 7. Mudanças de escopo

Funcionalidade nova ou mudança de prazo não entra direto no código. Abra uma issue com o template **Solicitação de mudança**. A PM avalia o impacto com o grupo antes de aprovar (risco R10).
