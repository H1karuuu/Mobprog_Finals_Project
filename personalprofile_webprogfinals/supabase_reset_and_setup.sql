-- Clean Supabase setup for this app
-- Run this whole script once in Supabase SQL Editor

create extension if not exists pgcrypto;

-- ==================== TABLES ====================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  full_name text not null,
  bio text,
  email text,
  skills text,
  avatar_url text,
  cover_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  content text not null default '',
  image_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.friends (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  contact_info text,
  image_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.gallery (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  image_url text not null,
  caption text,
  created_at timestamptz not null default now()
);

-- Add missing columns if table already existed with older schema
alter table public.profiles add column if not exists username text;
alter table public.profiles add column if not exists full_name text;
alter table public.profiles add column if not exists bio text;
alter table public.profiles add column if not exists email text;
alter table public.profiles add column if not exists skills text;
alter table public.profiles add column if not exists avatar_url text;
alter table public.profiles add column if not exists cover_url text;

alter table public.posts add column if not exists image_url text;
alter table public.friends add column if not exists image_url text;
alter table public.gallery add column if not exists caption text;

-- backfill required values for older rows
update public.profiles
set username = coalesce(nullif(username, ''), 'user_' || substring(id::text, 1, 8))
where username is null or username = '';

update public.profiles
set full_name = coalesce(nullif(full_name, ''), username)
where full_name is null or full_name = '';

alter table public.profiles alter column username set not null;
alter table public.profiles alter column full_name set not null;

-- ==================== RLS ENABLE ====================
alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.friends enable row level security;
alter table public.gallery enable row level security;

-- ==================== DROP OLD POLICIES ====================
do $$
declare r record;
begin
  for r in select policyname from pg_policies where schemaname='public' and tablename='profiles' loop
    execute format('drop policy if exists %I on public.profiles', r.policyname);
  end loop;

  for r in select policyname from pg_policies where schemaname='public' and tablename='posts' loop
    execute format('drop policy if exists %I on public.posts', r.policyname);
  end loop;

  for r in select policyname from pg_policies where schemaname='public' and tablename='friends' loop
    execute format('drop policy if exists %I on public.friends', r.policyname);
  end loop;

  for r in select policyname from pg_policies where schemaname='public' and tablename='gallery' loop
    execute format('drop policy if exists %I on public.gallery', r.policyname);
  end loop;

  for r in select policyname from pg_policies where schemaname='storage' and tablename='objects' loop
    execute format('drop policy if exists %I on storage.objects', r.policyname);
  end loop;
end $$;

-- ==================== TABLE POLICIES ====================
create policy profiles_select_authenticated on public.profiles
for select to authenticated using (true);

create policy profiles_insert_own on public.profiles
for insert to authenticated with check (id::text = auth.uid()::text);

create policy profiles_update_own on public.profiles
for update to authenticated
using (id::text = auth.uid()::text)
with check (id::text = auth.uid()::text);

create policy posts_select_authenticated on public.posts
for select to authenticated using (true);

create policy posts_insert_own on public.posts
for insert to authenticated with check (user_id::text = auth.uid()::text);

create policy posts_update_own on public.posts
for update to authenticated
using (user_id::text = auth.uid()::text)
with check (user_id::text = auth.uid()::text);

create policy posts_delete_own on public.posts
for delete to authenticated using (user_id::text = auth.uid()::text);

create policy friends_select_own on public.friends
for select to authenticated using (user_id::text = auth.uid()::text);

create policy friends_insert_own on public.friends
for insert to authenticated with check (user_id::text = auth.uid()::text);

create policy friends_update_own on public.friends
for update to authenticated
using (user_id::text = auth.uid()::text)
with check (user_id::text = auth.uid()::text);

create policy friends_delete_own on public.friends
for delete to authenticated using (user_id::text = auth.uid()::text);

create policy gallery_select_own on public.gallery
for select to authenticated using (user_id::text = auth.uid()::text);

create policy gallery_insert_own on public.gallery
for insert to authenticated with check (user_id::text = auth.uid()::text);

create policy gallery_update_own on public.gallery
for update to authenticated
using (user_id::text = auth.uid()::text)
with check (user_id::text = auth.uid()::text);

create policy gallery_delete_own on public.gallery
for delete to authenticated using (user_id::text = auth.uid()::text);

-- ==================== STORAGE BUCKETS ====================
insert into storage.buckets (id, name, public)
values
  ('avatars', 'avatars', true),
  ('covers', 'covers', true),
  ('posts', 'posts', true),
  ('friends', 'friends', true),
  ('gallery', 'gallery', true)
on conflict (id) do update set public = excluded.public;

-- ==================== STORAGE POLICIES ====================
-- App saves files as: {user_id}/{filename}

create policy storage_read_images on storage.objects
for select to public
using (bucket_id in ('avatars','covers','posts','friends','gallery'));

create policy storage_insert_own_images on storage.objects
for insert to authenticated
with check (
  bucket_id in ('avatars','covers','posts','friends','gallery')
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy storage_update_own_images on storage.objects
for update to authenticated
using (
  bucket_id in ('avatars','covers','posts','friends','gallery')
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id in ('avatars','covers','posts','friends','gallery')
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy storage_delete_own_images on storage.objects
for delete to authenticated
using (
  bucket_id in ('avatars','covers','posts','friends','gallery')
  and (storage.foldername(name))[1] = auth.uid()::text
);

-- ==================== USER PROFILE TRIGGER ====================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into public.profiles (id, username, full_name, email)
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data->>'username', ''), 'user_' || substring(new.id::text, 1, 8)),
    coalesce(nullif(new.raw_user_meta_data->>'full_name', ''), coalesce(new.raw_user_meta_data->>'username', 'User')),
    new.email
  )
  on conflict (id) do update
  set
    email = excluded.email,
    updated_at = now();

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- Ensure existing users also have a profile row
insert into public.profiles (id, username, full_name, email)
select
  u.id,
  coalesce(nullif(u.raw_user_meta_data->>'username', ''), 'user_' || substring(u.id::text, 1, 8)),
  coalesce(nullif(u.raw_user_meta_data->>'full_name', ''), coalesce(u.raw_user_meta_data->>'username', 'User')),
  u.email
from auth.users u
where not exists (
  select 1 from public.profiles p where p.id = u.id
);
