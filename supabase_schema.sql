-- Hawaii 2026 cloud sync schema for Supabase.
-- Run this in the Supabase SQL Editor for the project connected to index.html.

create extension if not exists pgcrypto;

create table if not exists public.trip_notes (
  id uuid primary key default gen_random_uuid(),
  trip_key text not null,
  day_id text not null,
  content text not null default '',
  updated_at timestamptz not null default now(),
  unique (trip_key, day_id)
);

create table if not exists public.trip_expenses (
  id uuid primary key default gen_random_uuid(),
  trip_key text not null,
  day_id text not null,
  description text not null,
  amount numeric(10, 2) not null check (amount >= 0),
  created_at timestamptz not null default now()
);

create table if not exists public.trip_photos (
  id uuid primary key default gen_random_uuid(),
  trip_key text not null,
  day_id text not null,
  name text not null,
  path text not null,
  public_url text not null,
  created_at timestamptz not null default now()
);

alter table public.trip_notes enable row level security;
alter table public.trip_expenses enable row level security;
alter table public.trip_photos enable row level security;

grant select, insert, update, delete on public.trip_notes to anon;
grant select, insert, update, delete on public.trip_expenses to anon;
grant select, insert, update, delete on public.trip_photos to anon;

drop policy if exists "Trip notes shared access" on public.trip_notes;
drop policy if exists "Trip expenses shared access" on public.trip_expenses;
drop policy if exists "Trip photos shared access" on public.trip_photos;

create policy "Trip notes shared access"
on public.trip_notes
for all
to anon
using (trip_key = 'c5cc15b6430ca720613daef384c58149870660959a4ecbb76ba3b55ba02ad77e')
with check (trip_key = 'c5cc15b6430ca720613daef384c58149870660959a4ecbb76ba3b55ba02ad77e');

create policy "Trip expenses shared access"
on public.trip_expenses
for all
to anon
using (trip_key = 'c5cc15b6430ca720613daef384c58149870660959a4ecbb76ba3b55ba02ad77e')
with check (trip_key = 'c5cc15b6430ca720613daef384c58149870660959a4ecbb76ba3b55ba02ad77e');

create policy "Trip photos shared access"
on public.trip_photos
for all
to anon
using (trip_key = 'c5cc15b6430ca720613daef384c58149870660959a4ecbb76ba3b55ba02ad77e')
with check (trip_key = 'c5cc15b6430ca720613daef384c58149870660959a4ecbb76ba3b55ba02ad77e');

alter table public.trip_notes replica identity full;
alter table public.trip_expenses replica identity full;
alter table public.trip_photos replica identity full;

do $$
begin
  alter publication supabase_realtime add table public.trip_notes;
exception
  when duplicate_object then null;
end $$;

do $$
begin
  alter publication supabase_realtime add table public.trip_expenses;
exception
  when duplicate_object then null;
end $$;

do $$
begin
  alter publication supabase_realtime add table public.trip_photos;
exception
  when duplicate_object then null;
end $$;

insert into storage.buckets (id, name, public)
values ('hawaii-trip-photos', 'hawaii-trip-photos', true)
on conflict (id) do update set public = true;

drop policy if exists "Trip photo files can be read" on storage.objects;
drop policy if exists "Trip photo files can be uploaded" on storage.objects;
drop policy if exists "Trip photo files can be deleted" on storage.objects;

create policy "Trip photo files can be read"
on storage.objects
for select
to anon
using (bucket_id = 'hawaii-trip-photos');

create policy "Trip photo files can be uploaded"
on storage.objects
for insert
to anon
with check (
  bucket_id = 'hawaii-trip-photos'
  and name like 'c5cc15b6430ca720613daef384c58149870660959a4ecbb76ba3b55ba02ad77e/%'
);

create policy "Trip photo files can be deleted"
on storage.objects
for delete
to anon
using (
  bucket_id = 'hawaii-trip-photos'
  and name like 'c5cc15b6430ca720613daef384c58149870660959a4ecbb76ba3b55ba02ad77e/%'
);
