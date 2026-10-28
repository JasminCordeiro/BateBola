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

- `main` é a versão publicada e só recebe código por pull request.
- Cada tarefa é feita em uma branch própria: `feature/agendamento`, `feature/painel`, `fix/limite-reservas` etc.
- Cada pull request é revisado por pelo menos uma pessoa (QA) antes do merge.

Padrão de commit:
```
feat: adiciona tela de horários
fix: corrige limite de 2 reservas por dia
docs: atualiza README
```

---

## 📄 Documentação do projeto

Os entregáveis de gerência de projeto ficam em [`docs/`](docs/):

- Documento de visão
- Gerenciamento do tempo (cronograma e Gantt)
- Gerenciamento de custos (planilha)
- Gerenciamento dos riscos

---

## 👥 Equipe

| Nome | Papel |
|---|---|

| Jasmin Andrade Cordeiro | |
| Eduarda Gomes Camilo | |
| Guilherme Ferreira Freitas | |
| Vitor Angelo dos Santos | |
| João Pedro Barbosa Lima | |

Papéis do projeto: Gerente de Projeto, Analista de Requisitos, Desenvolvedor Flutter, Designer UI/UX e Analista de Testes (QA).
