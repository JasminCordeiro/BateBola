# 🎾 BateBola

Sistema web para **agendamento de quadras de tênis**, feito em Flutter Web com Supabase.

Clientes consultam as quadras e reservam horários sem precisar criar conta. Proprietários fazem login para cadastrar quadras, acompanhar as reservas e gerar relatórios.

> Trabalho prático da disciplina **CSI405 – Gerência de Projetos de Software**
> Universidade Federal de Ouro Preto (UFOP) · ICEA/DECSI · 2026/2
> Prof. Igor Muzetti Pereira

---

## ✨ Funcionalidades

### Cliente (sem login)
- Consultar as quadras disponíveis
- Ver os horários livres de cada quadra por data
- Reservar um horário de **1 hora** informando **nome e telefone**
- Limite de **2 reservas por dia** por telefone

### Proprietário (com login)
- Entrar com e-mail e senha
- Cadastrar, editar e desativar quadras
- Definir os horários de funcionamento
- Consultar as reservas de cada quadra
- Gerar **relatório por período**, com as reservas e os clientes

---

## 🛠️ Tecnologias

| Camada | Ferramenta |
|---|---|
| Interface | [Flutter](https://flutter.dev) (Web) |
| Banco de dados e login | [Supabase](https://supabase.com) (PostgreSQL + Auth) |
| Hospedagem | GitHub Pages |
| Protótipo | Figma |
| Cronograma | GanttProject |

---

## 📁 Estrutura

```
batebola/
├── lib/
│   ├── main.dart
│   ├── app/            # rotas e tema
│   ├── core/           # cliente Supabase, utilitários, widgets comuns
│   └── features/
│       ├── quadras/        # cliente: lista de quadras
│       ├── agendamento/    # cliente: horários e reserva
│       ├── auth/           # proprietário: login
│       ├── painel/         # proprietário: quadras e reservas
│       └── relatorios/     # proprietário: relatório por período
├── supabase/
│   ├── migrations/     # criação das tabelas e regras de acesso
│   └── seed.sql        # dados de exemplo
├── test/
├── docs/               # entregáveis do projeto
└── web/
```

---

## 🚀 Como rodar

### Pré-requisitos
- Flutter 3.x instalado (`flutter doctor` sem erros)
- Google Chrome
- Um projeto criado no [Supabase](https://supabase.com)

### 1. Clonar
```bash
git clone https://github.com/JasminCordeiro/batebola.git
cd batebola
flutter pub get
```

### 2. Configurar o Supabase
1. No painel do Supabase, abra **SQL Editor**.
2. Rode, em ordem, os arquivos de `supabase/migrations/`.
3. (Opcional) Rode o `supabase/seed.sql` para ter quadras de exemplo.
4. Em **Project Settings → API**, copie a **Project URL** e a **anon public key**.

### 3. Executar
```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://SEU-PROJETO.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=SUA_ANON_KEY
```

> ⚠️ Nunca coloque a chave `service_role` no código nem no repositório. O app usa apenas a chave pública (`anon`).

---

## 🌐 Publicação

O deploy é feito no GitHub Pages:

```bash
flutter build web --base-href /batebola/ \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

Endereço: **https://jasmincordeiro.github.io/batebola/**

---

## 🌿 Fluxo de trabalho

- As tarefas ficam nas [issues](https://github.com/JasminCordeiro/BateBola/issues) e no [quadro do projeto](https://github.com/users/JasminCordeiro/projects/4).
- `main` é a versão publicada e só recebe código por pull request.
- Cada tarefa é feita em uma branch própria, com o ID da task: `feature/T27-funcao-reserva`, `fix/T39-limite-reservas` etc.
- Cada pull request é revisado por pelo menos uma pessoa antes do merge.

Padrão de commit:
```
feat(T26): adiciona tela de horários
fix(T39): corrige limite de 2 reservas por dia
docs(T50): registra decisões técnicas
```

As regras completas estão em [`CONTRIBUTING.md`](CONTRIBUTING.md).

---

## 📄 Documentação do projeto

Resumos dos entregáveis de gerência de projeto, em [`docs/`](docs/):

- [Visão e requisitos](docs/visao.md)
- [Decisões técnicas](docs/decisoes.md)
- [Equipe e papéis](docs/equipe.md)
- [Cronograma](docs/cronograma.md)
- [Custos](docs/custos.md)
- [Riscos](docs/riscos.md)

---

## 👥 Equipe

| Nome | Papel |
|---|---|
| Eduarda Gomes Camilo | UI/UX Designer |
| Guilherme Ferreira Freitas | Dev banco de dados / back-end |
| Jasmin Andrade Cordeiro | Product Manager e Dev geral |
| João Pedro Barbosa Lima | Dev geral (integração e qualidade) |
| Vitor Angelo dos Santos | Dev front-end |
