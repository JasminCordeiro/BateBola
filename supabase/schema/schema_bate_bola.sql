create extension if not exists btree_gist with schema extensions;

-- ---------------------------------------------------------------------
-- 1. Proprietário (RF07) — usuários do Auth com acesso à área restrita.
-- ---------------------------------------------------------------------

--    O e-mail fica em auth.users (não duplicar aqui).
create table public.proprietarios (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  nome       text not null check (char_length(btrim(nome)) between 1 and 120),
  created_at timestamptz not null default now()
);

create or replace function public.is_proprietario()
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.proprietarios p where p.user_id = (select auth.uid())
  );
$$;

-- ---------------------------------------------------------------------
-- 2. Quadras (RF01, RF08, RF09)
-- --------------------------------------------------------------------- 

--    ativa       = disponível/indisponível para agendamento (RF09)
--    excluida_em = remoção lógica (RF08), preserva o histórico dos relatórios
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

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger quadras_set_updated_at
  before update on public.quadras
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- 3. Disponibilidade semanal da quadra (RF09, CT07)
-- --------------------------------------------------------------------- 

--    Janelas de horas cheias por dia da semana (0 = domingo ... 6 = sábado)
--    hora_fim é exclusiva: janela 8–12 libera os horários 8, 9, 10 e 11
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
-- 4. Clientes (RF03, R5, R7)
-- --------------------------------------------------------------------- 

--    O cliente NÃO tem conta no Auth: é uma tabela comum, identificada pelo telefone (só dígitos, com DDD — P4). Só nome e telefone (LGPD)
create table public.clientes (
  id         uuid primary key default gen_random_uuid(),
  nome       text not null check (
               char_length(btrim(nome)) between 5 and 120
               and btrim(nome) ~ '\s'
             ),
  telefone   text not null check (telefone ~ '^[0-9]{10,11}$'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint clientes_telefone_unico unique (telefone)
);

create trigger clientes_set_updated_at
  before update on public.clientes
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- 5. Agendamentos (RF03, RF04, RF05, RF06, RF10, RF11)
-- ---------------------------------------------------------------------

--    Duração fixa de 1 hora (P5, R6), por isso só existe hora_inicio
create table public.agendamentos (
  id          uuid primary key default gen_random_uuid(),
  quadra_id   uuid not null references public.quadras (id) on delete restrict,
  cliente_id  uuid not null references public.clientes (id) on delete restrict,
  data        date not null,
  hora_inicio smallint not null check (hora_inicio between 0 and 23),
  hora_fim    smallint generated always as (hora_inicio + 1) stored,
  created_at  timestamptz not null default now(),

  -- RF05 / RNF08: o banco é a fonte da verdade contra duplicidade, mesmo com
  -- acessos simultâneos (CT05, risco R01)
  constraint agendamentos_quadra_horario_unico unique (quadra_id, data, hora_inicio)
);

create index agendamentos_data_quadra_idx on public.agendamentos (data, quadra_id);
create index agendamentos_cliente_data_idx on public.agendamentos (cliente_id, data);

-- ---------------------------------------------------------------------
-- 6. Regras de negócio no banco (valem para qualquer caminho de escrita)
-- ---------------------------------------------------------------------
create or replace function public.validar_agendamento()
returns trigger
language plpgsql security definer
set search_path = ''
as $$
declare
  v_agora timestamp := (now() at time zone 'America/Sao_Paulo');
  v_total integer;
begin
  -- Serializa agendamentos do mesmo cliente no mesmo dia, para que dois pedidos simultâneos não passem juntos do limite de 2 (RF04).
  perform pg_advisory_xact_lock(
    hashtextextended(new.cliente_id::text || ':' || new.data::text, 0)
  );

  if not exists (
    select 1 from public.quadras q
    where q.id = new.quadra_id and q.ativa and q.excluida_em is null
  ) then
    raise exception 'Esta quadra não está disponível para agendamento.'
      using errcode = 'P0001', detail = 'QUADRA_INDISPONIVEL';
  end if;

  if not exists (
    select 1 from public.disponibilidades d
    where d.quadra_id = new.quadra_id
      and d.dia_semana = extract(dow from new.data)::smallint
      and new.hora_inicio >= d.hora_inicio
      and new.hora_inicio + 1 <= d.hora_fim
  ) then
    raise exception 'Este horário está fora do período de funcionamento da quadra.'
      using errcode = 'P0001', detail = 'FORA_DA_DISPONIBILIDADE';
  end if;

  if (new.data + make_time(new.hora_inicio::int, 0, 0)) <= v_agora then
    raise exception 'Não é possível agendar um horário que já passou.'
      using errcode = 'P0001', detail = 'HORARIO_PASSADO';
  end if;

  -- Horizonte máximo de antecedência (30 dias)
  if new.data > (v_agora::date + 30) then
    raise exception 'Só é possível agendar com até 30 dias de antecedência.'
      using errcode = 'P0001', detail = 'HORIZONTE_EXCEDIDO';
  end if;

  select count(*) into v_total
  from public.agendamentos a
  where a.cliente_id = new.cliente_id
    and a.data = new.data;

  if v_total >= 2 then
    raise exception 'O limite é de 2 horários por dia para o mesmo telefone.'
      using errcode = 'P0001', detail = 'LIMITE_DIARIO';
  end if;

  return new;
end;
$$;

create trigger agendamentos_validar
  before insert on public.agendamentos
  for each row execute function public.validar_agendamento();

-- ---------------------------------------------------------------------
-- 7. Funções expostas ao cliente (sem login)
--    O cliente nunca lê as tabelas agendamentos e clientes (RNF07).
-- ---------------------------------------------------------------------

-- RF02 / CT01: horários livres de uma quadra em uma data
create or replace function public.horarios_disponiveis(p_quadra_id uuid, p_data date)
returns table (hora_inicio smallint, hora_fim smallint)
language sql stable security definer
set search_path = ''
as $$
  select h::smallint, (h + 1)::smallint
  from public.quadras q
  join public.disponibilidades d
    on d.quadra_id = q.id
   and d.dia_semana = extract(dow from p_data)::smallint
  cross join lateral generate_series(d.hora_inicio, d.hora_fim - 1) as h
  where q.id = p_quadra_id
    and q.ativa
    and q.excluida_em is null
    and not exists (
      select 1 from public.agendamentos a
      where a.quadra_id = q.id and a.data = p_data and a.hora_inicio = h
    )
    and (p_data + make_time(h, 0, 0)) > (now() at time zone 'America/Sao_Paulo')
  order by h;
$$;

-- RF03 / RF06 / CT02–CT05: cria/reaproveita o cliente, agenda e devolve a confirmação
create or replace function public.agendar_horario(
  p_quadra_id   uuid,
  p_data        date,
  p_hora_inicio smallint,
  p_nome        text,
  p_telefone    text
)
returns table (
  agendamento_id uuid,
  quadra_nome    text,
  data           date,
  hora_inicio    smallint,
  hora_fim       smallint
)
language plpgsql security definer
set search_path = ''
as $$
#variable_conflict use_column
declare
  v_tel        text := regexp_replace(coalesce(p_telefone, ''), '\D', '', 'g');
  v_cliente_id uuid;
  v_id         uuid;
begin
  if char_length(btrim(coalesce(p_nome, ''))) < 5 or btrim(coalesce(p_nome, '')) !~ '\s' then
    raise exception 'Informe o nome completo e o telefone.'
      using errcode = 'P0001', detail = 'DADOS_OBRIGATORIOS';
  end if;

  -- Aceita "+55 31 99999-0000": remove o código do país para que o mesmo
  -- telefone sempre vire a mesma chave (senão o limite diário seria burlado).
  if char_length(v_tel) in (12, 13) and v_tel like '55%' then
    v_tel := substr(v_tel, 3);
  end if;

  if v_tel !~ '^[0-9]{10,11}$' then
    raise exception 'Informe um telefone válido, com DDD.'
      using errcode = 'P0001', detail = 'DADOS_OBRIGATORIOS';
  end if;

  -- Cliente identificado pelo telefone (P4). Se o telefone já existe, mantém o
  -- primeiro nome registrado: evita que alguém troque o nome de outra pessoa
  -- usando o telefone dela. O proprietário pode corrigir nomes (UPDATE).
  insert into public.clientes (nome, telefone)
  values (btrim(p_nome), v_tel)
  on conflict (telefone) do nothing
  returning id into v_cliente_id;

  if v_cliente_id is null then
    select c.id into v_cliente_id from public.clientes c where c.telefone = v_tel;
  end if;

  insert into public.agendamentos (quadra_id, data, hora_inicio, cliente_id)
  values (p_quadra_id, p_data, p_hora_inicio, v_cliente_id)
  returning public.agendamentos.id into v_id;

  return query
    select a.id, q.nome, a.data, a.hora_inicio, a.hora_fim
    from public.agendamentos a
    join public.quadras q on q.id = a.quadra_id
    where a.id = v_id;

exception
  when unique_violation then
    raise exception 'Este horário não está mais disponível.'
      using errcode = 'P0001', detail = 'HORARIO_OCUPADO';
end;
$$;

-- ---------------------------------------------------------------------
-- 8. Permissões e RLS (RNF06, RNF07)
-- ---------------------------------------------------------------------
revoke all on function public.validar_agendamento() from public, anon, authenticated;
revoke all on function public.horarios_disponiveis(uuid, date) from public;
revoke all on function public.agendar_horario(uuid, date, smallint, text, text) from public;
revoke all on function public.is_proprietario() from public;

grant execute on function public.horarios_disponiveis(uuid, date) to anon, authenticated;
grant execute on function public.agendar_horario(uuid, date, smallint, text, text) to anon, authenticated;
grant execute on function public.is_proprietario() to anon, authenticated;

alter table public.proprietarios    enable row level security;
alter table public.quadras          enable row level security;
alter table public.disponibilidades enable row level security;
alter table public.agendamentos     enable row level security;

revoke all on public.proprietarios    from anon, authenticated;
revoke all on public.agendamentos     from anon, authenticated;
revoke all on public.disponibilidades from anon;

-- GRANTs explícitos: projetos novos do Supabase não expõem tabelas do schema public à Data API automaticamente. O RLS abaixo continua filtrando as linhas.
grant select on public.quadras to anon, authenticated;
grant insert, update, delete on public.quadras to authenticated;
grant select, insert, update, delete on public.disponibilidades to authenticated;
grant select, delete on public.agendamentos to authenticated;

-- proprietarios: sem policy = ninguém lê pela API (só funções security definer)

create policy quadras_publico_le on public.quadras
  for select to anon, authenticated
  using (ativa and excluida_em is null);

create policy quadras_proprietario_tudo on public.quadras
  for all to authenticated
  using ((select public.is_proprietario()))
  with check ((select public.is_proprietario()));

create policy disponibilidades_proprietario_tudo on public.disponibilidades
  for all to authenticated
  using ((select public.is_proprietario()))
  with check ((select public.is_proprietario()));

-- agendamentos: só o proprietário lê e remove (RF10, RF11, RNF07). Ninguém insere pela API direta: o cliente usa agendar_horario().
create policy agendamentos_proprietario_le on public.agendamentos
  for select to authenticated
  using ((select public.is_proprietario()));

create policy agendamentos_proprietario_apaga on public.agendamentos
  for delete to authenticated
  using ((select public.is_proprietario()));

-- clientes: só o proprietário lê, corrige o nome ou apaga (LGPD). Quem cria é a função agendar_horario(); o telefone não pode ser alterado diretamente.
alter table public.clientes enable row level security;
revoke all on public.clientes from anon, authenticated;
grant select, delete on public.clientes to authenticated;
grant update (nome) on public.clientes to authenticated;

create policy clientes_proprietario_le on public.clientes
  for select to authenticated
  using ((select public.is_proprietario()));

create policy clientes_proprietario_atualiza on public.clientes
  for update to authenticated
  using ((select public.is_proprietario()))
  with check ((select public.is_proprietario()));

create policy clientes_proprietario_apaga on public.clientes
  for delete to authenticated
  using ((select public.is_proprietario()));