-- Schema minimale per sincronizzare piano_allenamento_andrea.html con Supabase.
-- Pensato per una singola pagina statica: lo stato resta un JSON unico.
-- Nota: questa versione e' semplice, non blindata. Per dati sensibili aggiungere Supabase Auth.

create table if not exists public.plan_state (
  owner_key text not null,
  plan_id text not null,
  state jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (owner_key, plan_id)
);

alter table public.plan_state enable row level security;

drop policy if exists "single owner read" on public.plan_state;
drop policy if exists "single owner insert" on public.plan_state;
drop policy if exists "single owner update" on public.plan_state;

create policy "single owner read"
on public.plan_state
for select
to anon
using (owner_key = 'andrea');

create policy "single owner insert"
on public.plan_state
for insert
to anon
with check (owner_key = 'andrea');

create policy "single owner update"
on public.plan_state
for update
to anon
using (owner_key = 'andrea')
with check (owner_key = 'andrea');

do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'plan_state'
  ) then
    alter publication supabase_realtime add table public.plan_state;
  end if;
end $$;
