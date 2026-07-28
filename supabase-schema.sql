-- Ejecuta este archivo una sola vez en Supabase > SQL Editor.
-- Guarda un documento privado de la aplicación por cada usuario autenticado.

create table if not exists public.user_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.user_data enable row level security;

revoke all on table public.user_data from anon;
grant select, insert, update, delete on table public.user_data to authenticated;

drop policy if exists "Users can read their own fitness data" on public.user_data;
create policy "Users can read their own fitness data"
on public.user_data
for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "Users can create their own fitness data" on public.user_data;
create policy "Users can create their own fitness data"
on public.user_data
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update their own fitness data" on public.user_data;
create policy "Users can update their own fitness data"
on public.user_data
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "Users can delete their own fitness data" on public.user_data;
create policy "Users can delete their own fitness data"
on public.user_data
for delete
to authenticated
using ((select auth.uid()) = user_id);
