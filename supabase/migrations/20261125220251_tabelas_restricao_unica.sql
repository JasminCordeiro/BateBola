-- Necessária para a restrição de exclusão de disponibilidades (uuid e smallint em GiST)
create extension if not exists btree_gist with schema extensions;

-- ---------------------------------------------------------------------
-- quadras (RF01, RF08, RF09)
--   unicidade: nome da quadra entre as não removidas
-- ---------------------------------------------------------------------
create table public.quadras (
  id          uuid primary key default gen_random_uuid(),
  nome        text not null check (char_length(btrim(nome)) between 1 and 80),
  descricao   text check (char_length(descricao) <= 500),
  ativa       boolean not null default true,
  excluida_em timestamptz,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create unique index quadras_nome_unico
  on public.quadras (lower(btrim(nome)))
  where excluida_em is null;

-- ---------------------------------------------------------------------
-- disponibilidades (RF09, CT07)
--   exclusão: impede janelas de horário sobrepostas na mesma quadra e dia
-- ---------------------------------------------------------------------
create table public.disponibilidades (
  id          uuid primary key default gen_random_uuid(),
  quadra_id   uuid not null references public.quadras (id) on delete cascade,
  dia_semana  smallint not null check (dia_semana between 0 and 6),
  hora_inicio smallint not null check (hora_inicio between 0 and 23),
  hora_fim    smallint not null check (hora_fim between 1 and 24),
  created_at  timestamptz not null default now(),
  constraint disponibilidades_intervalo_valido check (hora_fim > hora_inicio),
  constraint disponibilidades_sem_sobreposicao exclude using gist (
    quadra_id with =,
    dia_semana with =,
    (int4range(hora_inicio::int, hora_fim::int)) with &&
  )
);

-- ---------------------------------------------------------------------
-- agendamentos (RF03 a RF06, RF10, RF11)
--   unicidade: um horário de uma quadra só pode ser agendado uma vez (RF05, RNF08)
--   Duração fixa de 1 hora (P5, R6), por isso só existe hora_inicio.
-- ---------------------------------------------------------------------
create table public.agendamentos (
  id               uuid primary key default gen_random_uuid(),
  quadra_id        uuid not null references public.quadras (id) on delete restrict,
  data             date not null,
  hora_inicio      smallint not null check (hora_inicio between 0 and 23),
  hora_fim         smallint generated always as (hora_inicio + 1) stored,
  nome_cliente     text not null check (
                     char_length(btrim(nome_cliente)) between 5 and 120
                     and btrim(nome_cliente) ~ '\s'
                   ),
  telefone_cliente text not null check (telefone_cliente ~ '^[0-9]{10,11}$'),
  created_at       timestamptz not null default now(),

  constraint agendamentos_quadra_horario_unico unique (quadra_id, data, hora_inicio)
);

create index agendamentos_data_quadra_idx on public.agendamentos (data, quadra_id);
create index agendamentos_telefone_data_idx on public.agendamentos (telefone_cliente, data);