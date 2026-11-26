SET local check_function_bodies = off;

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON SEQUENCES FROM "anon";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON SEQUENCES FROM "authenticated";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON SEQUENCES FROM "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON FUNCTIONS FROM "anon";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON FUNCTIONS FROM "authenticated";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON FUNCTIONS FROM "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON TABLES FROM "anon";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON TABLES FROM "authenticated";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON TABLES FROM "service_role";

CREATE EXTENSION "btree_gist" SCHEMA "extensions";

CREATE TABLE "public"."agendamentos" (
  "id"               uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "quadra_id"        uuid                     NOT NULL,
  "data"             date                     NOT NULL,
  "hora_inicio"      smallint                 NOT NULL,
  "hora_fim"         smallint                 GENERATED ALWAYS AS ((hora_inicio + 1)) STORED,
  "nome_cliente"     text                     NOT NULL,
  "telefone_cliente" text                     NOT NULL,
  "created_at"       timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "agendamentos_hora_inicio_check" CHECK (((hora_inicio >= 0) AND (hora_inicio <= 23))),
  CONSTRAINT "agendamentos_nome_cliente_check"
    CHECK ((((char_length(btrim(nome_cliente)) >= 5) AND (char_length(btrim(nome_cliente)) <= 120)) AND (btrim(nome_cliente) ~ '\s'::text))),
  CONSTRAINT "agendamentos_pkey" PRIMARY KEY (id),
  CONSTRAINT "agendamentos_quadra_horario_unico" UNIQUE (quadra_id, DATA, hora_inicio),
  CONSTRAINT "agendamentos_telefone_cliente_check" CHECK ((telefone_cliente ~ '^[0-9]{10,11}$'::text))
);

ALTER TABLE "public"."agendamentos"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."agendamentos" FROM "anon";

CREATE TABLE "public"."disponibilidades" (
  "id"          uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "quadra_id"   uuid                     NOT NULL,
  "dia_semana"  smallint                 NOT NULL,
  "hora_inicio" smallint                 NOT NULL,
  "hora_fim"    smallint                 NOT NULL,
  "created_at"  timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "disponibilidades_dia_semana_check" CHECK (((dia_semana >= 0) AND (dia_semana <= 6))),
  CONSTRAINT "disponibilidades_hora_fim_check" CHECK (((hora_fim >= 1) AND (hora_fim <= 24))),
  CONSTRAINT "disponibilidades_hora_inicio_check" CHECK (((hora_inicio >= 0) AND (hora_inicio <= 23))),
  CONSTRAINT "disponibilidades_intervalo_valido" CHECK ((hora_fim > hora_inicio)),
  CONSTRAINT "disponibilidades_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."disponibilidades"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."disponibilidades" FROM "anon";

CREATE TABLE "public"."proprietarios" (
  "user_id"    uuid                     NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "proprietarios_pkey" PRIMARY KEY (user_id)
);

ALTER TABLE "public"."proprietarios"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."proprietarios" FROM "anon", "authenticated";

CREATE TABLE "public"."quadras" (
  "id"          uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "nome"        text                     NOT NULL,
  "descricao"   text,
  "ativa"       boolean                  NOT NULL DEFAULT true,
  "excluida_em" timestamp with time zone,
  "created_at"  timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"  timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "quadras_descricao_check" CHECK ((char_length(descricao) <= 500)),
  CONSTRAINT "quadras_nome_check" CHECK (((char_length(btrim(nome)) >= 1) AND (char_length(btrim(nome)) <= 80))),
  CONSTRAINT "quadras_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."quadras"
  ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.agendar_horario (
  p_quadra_id   uuid,
  p_data        date,
  p_hora_inicio smallint,
  p_nome        text,
  p_telefone    text
)
  RETURNS TABLE (
    agendamento_id uuid,
    quadra_nome    text,
    data           date,
    hora_inicio    smallint,
    hora_fim       smallint
  )
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
#variable_conflict use_column
declare
  v_tel text := regexp_replace(coalesce(p_telefone, ''), '\D', '', 'g');
  v_id  uuid;
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

  insert into public.agendamentos (quadra_id, data, hora_inicio, nome_cliente, telefone_cliente)
  values (p_quadra_id, p_data, p_hora_inicio, btrim(p_nome), v_tel)
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
$function$;

REVOKE ALL ON FUNCTION "public"."agendar_horario"(uuid, date, smallint, text, text) FROM PUBLIC, "service_role";

CREATE OR REPLACE FUNCTION public.horarios_disponiveis (
  p_quadra_id uuid,
  p_data      date
)
  RETURNS TABLE (
    hora_inicio smallint,
    hora_fim    smallint
  )
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
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
$function$;

REVOKE ALL ON FUNCTION "public"."horarios_disponiveis"(uuid, date) FROM PUBLIC, "service_role";

CREATE OR REPLACE FUNCTION public.is_proprietario()
  RETURNS boolean
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
  select exists (
    select 1 from public.proprietarios p where p.user_id = (select auth.uid())
  );
$function$;

REVOKE ALL ON FUNCTION "public"."is_proprietario"() FROM PUBLIC, "service_role";

CREATE OR REPLACE FUNCTION public.set_updated_at()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  AS $function$
begin
  new.updated_at := now();
  return new;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."set_updated_at"() FROM "anon", "authenticated", "service_role";

CREATE OR REPLACE FUNCTION public.validar_agendamento()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_agora timestamp := (now() at time zone 'America/Sao_Paulo');
  v_total integer;
begin

  -- Serializa agendamentos do mesmo telefone no mesmo dia
  -- Evita que dois pedidos simultâneos passem juntos do limite de 2 (RF04).
  perform pg_advisory_xact_lock(
    hashtextextended(new.telefone_cliente || ':' || new.data::text, 0)
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
  -- Ajuste o número se o proprietário quiser.
  if new.data > (v_agora::date + 30) then
    raise exception 'Só é possível agendar com até 30 dias de antecedência.'
      using errcode = 'P0001', detail = 'HORIZONTE_EXCEDIDO';
  end if;

  select count(*) into v_total
  from public.agendamentos a
  where a.telefone_cliente = new.telefone_cliente
    and a.data = new.data;

  if v_total >= 2 then
    raise exception 'O limite é de 2 horários por dia para o mesmo telefone.'
      using errcode = 'P0001', detail = 'LIMITE_DIARIO';
  end if;

  return new;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."validar_agendamento"() FROM PUBLIC, "anon", "authenticated", "service_role";

ALTER TABLE "public"."disponibilidades"
  ADD CONSTRAINT "disponibilidades_sem_sobreposicao" EXCLUDE USING gist (quadra_id WITH =, dia_semana WITH =, int4range((hora_inicio)::integer, (hora_fim)::integer) WITH &&);

ALTER TABLE "public"."proprietarios"
  ADD CONSTRAINT "proprietarios_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE "public"."agendamentos"
  ADD CONSTRAINT "agendamentos_quadra_id_fkey" FOREIGN KEY (quadra_id) REFERENCES public.quadras(id) ON DELETE RESTRICT;

ALTER TABLE "public"."disponibilidades"
  ADD CONSTRAINT "disponibilidades_quadra_id_fkey" FOREIGN KEY (quadra_id) REFERENCES public.quadras(id) ON DELETE CASCADE;

CREATE INDEX agendamentos_data_quadra_idx ON public.agendamentos USING btree (DATA, quadra_id);

CREATE INDEX agendamentos_telefone_data_idx ON public.agendamentos USING btree (telefone_cliente, DATA);

CREATE UNIQUE INDEX quadras_nome_unico ON public.quadras USING btree (lower(btrim(nome)))
  WHERE (excluida_em IS NULL);

CREATE TRIGGER agendamentos_validar
  BEFORE INSERT ON public.agendamentos
  FOR EACH ROW
  EXECUTE FUNCTION public.validar_agendamento();

CREATE TRIGGER quadras_set_updated_at
  BEFORE UPDATE ON public.quadras
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE POLICY "agendamentos_proprietario_apaga" ON "public"."agendamentos"
  FOR DELETE
  TO "authenticated"
  USING (( SELECT public.is_proprietario() AS is_proprietario));

CREATE POLICY "agendamentos_proprietario_le" ON "public"."agendamentos"
  FOR SELECT
  TO "authenticated"
  USING (( SELECT public.is_proprietario() AS is_proprietario));

CREATE POLICY "disponibilidades_proprietario_tudo" ON "public"."disponibilidades"
  FOR ALL
  TO "authenticated"
  USING (( SELECT public.is_proprietario() AS is_proprietario))
  WITH CHECK (( SELECT public.is_proprietario() AS is_proprietario));

CREATE POLICY "quadras_proprietario_tudo" ON "public"."quadras"
  FOR ALL
  TO "authenticated"
  USING (( SELECT public.is_proprietario() AS is_proprietario))
  WITH CHECK (( SELECT public.is_proprietario() AS is_proprietario));

CREATE POLICY "quadras_publico_le" ON "public"."quadras"
  FOR SELECT
  TO "anon", "authenticated"
  USING ((ativa AND (excluida_em IS NULL)));

COMMENT ON EXTENSION "btree_gist" IS 'support for indexing common datatypes in GiST';

GRANT EXECUTE ON FUNCTION "public"."agendar_horario"(uuid, date, smallint, text, text) TO "anon", "authenticated";

REVOKE ALL ON FUNCTION "public"."agendar_horario"(uuid, date, smallint, text, text) FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."agendar_horario"(uuid, date, smallint, text, text) TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."horarios_disponiveis"(uuid, date) TO "anon", "authenticated";

REVOKE ALL ON FUNCTION "public"."horarios_disponiveis"(uuid, date) FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."horarios_disponiveis"(uuid, date) TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."is_proprietario"() TO "anon", "authenticated";

REVOKE ALL ON FUNCTION "public"."is_proprietario"() FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."is_proprietario"() TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."set_updated_at"() TO PUBLIC;

REVOKE ALL ON FUNCTION "public"."set_updated_at"() FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."set_updated_at"() TO "postgres";

REVOKE ALL ON FUNCTION "public"."validar_agendamento"() FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."validar_agendamento"() TO "postgres";

REVOKE ALL ON TABLE "public"."agendamentos" FROM "authenticated";

GRANT DELETE, SELECT ON TABLE "public"."agendamentos" TO "authenticated";

REVOKE ALL ON TABLE "public"."agendamentos" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."agendamentos" TO "postgres";

REVOKE ALL ON TABLE "public"."agendamentos" FROM "service_role";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."agendamentos" TO "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."disponibilidades" TO "authenticated";

REVOKE ALL ON TABLE "public"."disponibilidades" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."disponibilidades" TO "postgres";

REVOKE ALL ON TABLE "public"."disponibilidades" FROM "service_role";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."disponibilidades" TO "service_role";

REVOKE ALL ON TABLE "public"."proprietarios" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."proprietarios" TO "postgres";

REVOKE ALL ON TABLE "public"."proprietarios" FROM "service_role";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."proprietarios" TO "service_role";

REVOKE ALL ON TABLE "public"."quadras" FROM "anon";

GRANT MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."quadras" TO "anon";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."quadras" TO "authenticated";

REVOKE ALL ON TABLE "public"."quadras" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."quadras" TO "postgres";

REVOKE ALL ON TABLE "public"."quadras" FROM "service_role";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."quadras" TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLES TO "anon";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLES TO "authenticated";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLES TO "service_role";

