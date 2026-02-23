-- Run this in Supabase SQL Editor
-- It creates/updates tables, storage buckets, and RLS policies for image uploads.

create extension if not exists pgcrypto;

-- ==================== TABLES ====================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  username text unique,
  full_name text,
  bio text,
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

alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.friends enable row level security;
alter table public.gallery enable row level security;

-- ==================== TABLE POLICIES ====================

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'profiles' and policyname = 'profiles_select_authenticated'
  ) then
    create policy profiles_select_authenticated
      on public.profiles
      for select
      to authenticated
      using (true);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'profiles' and policyname = 'profiles_insert_own'
  ) then
    create policy profiles_insert_own
      on public.profiles
      for insert
      to authenticated
      with check (id = auth.uid());
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'profiles' and policyname = 'profiles_update_own'
  ) then
    create policy profiles_update_own
      on public.profiles
      for update
      to authenticated
      using (id = auth.uid())
      with check (id = auth.uid());
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'posts' and policyname = 'posts_select_authenticated'
  ) then
    create policy posts_select_authenticated
      on public.posts
      for select
      to authenticated
      using (true);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'posts' and policyname = 'posts_insert_own'
  ) then
    create policy posts_insert_own
      on public.posts
      for insert
      to authenticated
      with check (user_id = auth.uid());
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'posts' and policyname = 'posts_update_own'
  ) then
    create policy posts_update_own
      on public.posts
      for update
      to authenticated
      using (user_id = auth.uid())
      with check (user_id = auth.uid());
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'posts' and policyname = 'posts_delete_own'
  ) then
    create policy posts_delete_own
      on public.posts
      for delete
      to authenticated
      using (user_id = auth.uid());
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'friends' and policyname = 'friends_select_own'
  ) then
    create policy friends_select_own
      on public.friends
      for select
      to authenticated
      using (user_id = auth.uid());
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'friends' and policyname = 'friends_insert_own'
  ) then
    create policy friends_insert_own
      on public.friends
      for insert
      to authenticated
      with check (user_id = auth.uid());
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'friends' and policyname = 'friends_update_own'
  ) then
    create policy friends_update_own
      on public.friends
      for update
      to authenticated
      using (user_id = auth.uid())
      with check (user_id = auth.uid());
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'friends' and policyname = 'friends_delete_own'
  ) then
    create policy friends_delete_own
      on public.friends
      for delete
      to authenticated
      using (user_id = auth.uid());
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'gallery' and policyname = 'gallery_select_own'
  ) then
    create policy gallery_select_own
      on public.gallery
      for select
      to authenticated
      using (user_id = auth.uid());
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'gallery' and policyname = 'gallery_insert_own'
  ) then
    create policy gallery_insert_own
      on public.gallery
      for insert
      to authenticated
      with check (user_id = auth.uid());
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'gallery' and policyname = 'gallery_update_own'
  ) then
    create policy gallery_update_own
      on public.gallery
      for update
      to authenticated
      using (user_id = auth.uid())
      with check (user_id = auth.uid());
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'gallery' and policyname = 'gallery_delete_own'
  ) then
    create policy gallery_delete_own
      on public.gallery
      for delete
      to authenticated
      using (user_id = auth.uid());
  end if;
end $$;

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
-- Files are saved under: {user_id}/{filename}

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'storage' and tablename = 'objects' and policyname = 'storage_insert_own_images'
  ) then
    create policy storage_insert_own_images
      on storage.objects
      for insert
      to authenticated
      with check (
        bucket_id in ('avatars', 'covers', 'posts', 'friends', 'gallery')
        and (storage.foldername(name))[1] = auth.uid()::text
      );
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'storage' and tablename = 'objects' and policyname = 'storage_update_own_images'
  ) then
    create policy storage_update_own_images
      on storage.objects
      for update
      to authenticated
      using (
        bucket_id in ('avatars', 'covers', 'posts', 'friends', 'gallery')
        and (storage.foldername(name))[1] = auth.uid()::text
      )
      with check (
        bucket_id in ('avatars', 'covers', 'posts', 'friends', 'gallery')
        and (storage.foldername(name))[1] = auth.uid()::text
      );
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'storage' and tablename = 'objects' and policyname = 'storage_delete_own_images'
  ) then
    create policy storage_delete_own_images
      on storage.objects
      for delete
      to authenticated
      using (
        bucket_id in ('avatars', 'covers', 'posts', 'friends', 'gallery')
        and (storage.foldername(name))[1] = auth.uid()::text
      );
  end if;
end $$;
