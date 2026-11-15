-- ==============================================================================
-- 🚀 إعداد قاعدة بيانات Supabase للشات مع Firebase Auth
-- انسخ هذا الكود بالكامل والصقه في SQL Editor على Supabase ثم اضغط Run
-- ==============================================================================

-- 1. حذف الجداول القديمة لإعادة بنائها متوافقة 100% مع معرّفات Firebase (UIDs)
drop table if exists public.messages cascade;
drop table if exists public.chats cascade;
drop table if exists public.profiles cascade;

-- 2. إنشاء جدول الملفات الشخصية (Profiles) بمعرف نصي Firebase UID
create table public.profiles (
  id text primary key, -- معرّف المستخدم من Firebase Auth (String وليس UUID)
  name text not null,
  email text not null,
  is_online boolean default false,
  fcm_token text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. إنشاء جدول المحادثات (Chats)
create table public.chats (
  id text primary key, -- uid1_uid2
  last_message text default '',
  last_sender_id text default '',
  last_updated timestamp with time zone default timezone('utc'::text, now()),
  participants text[] not null,
  cleared_by text[] default array[]::text[]
);

-- 4. إنشاء جدول الرسائل (Messages)
create table public.messages (
  id uuid primary key default gen_random_uuid(),
  chat_id text references public.chats(id) on delete cascade not null,
  sender_id text not null, -- Firebase Auth UID
  sender_name text not null,
  receiver_id text not null, -- Firebase Auth UID
  text text default '',
  type text default 'text', -- 'text', 'image', 'video', 'audio'
  media_url text,
  media_duration integer,
  deleted_for text[] default array[]::text[],
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 5. تفعيل الصلاحيات (Row Level Security) للسماح بتطبيق الشات بالعمل
alter table public.profiles enable row level security;
alter table public.chats enable row level security;
alter table public.messages enable row level security;

create policy "Allow all on profiles" on public.profiles for all using (true) with check (true);
create policy "Allow all on chats" on public.chats for all using (true) with check (true);
create policy "Allow all on messages" on public.messages for all using (true) with check (true);

-- 6. تفعيل الشات المباشر الفوري (Realtime)
do $$
begin
  if not exists (
    select 1 from pg_publication_tables 
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'profiles'
  ) then
    alter publication supabase_realtime add table public.profiles;
  end if;

  if not exists (
    select 1 from pg_publication_tables 
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'chats'
  ) then
    alter publication supabase_realtime add table public.chats;
  end if;

  if not exists (
    select 1 from pg_publication_tables 
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'messages'
  ) then
    alter publication supabase_realtime add table public.messages;
  end if;
end $$;

-- 7. إعداد Storage Bucket للوسائط (chat_media)
insert into storage.buckets (id, name, public)
values ('chat_media', 'chat_media', true)
on conflict (id) do nothing;

drop policy if exists "Allow all on storage" on storage.objects;
create policy "Allow all on storage"
  on storage.objects for all
  using (bucket_id = 'chat_media')
  with check (bucket_id = 'chat_media');
