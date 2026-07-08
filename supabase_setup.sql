-- 1. Create profiles table if it doesn't exist
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  full_name text,
  username text,
  email text,
  avatar_url text,
  updated_at timestamp with time zone,
  security_question text,
  security_answer text
);

-- 2. Add Unique Constraint on username to prevent duplicates
alter table public.profiles drop constraint if exists unique_username;
alter table public.profiles add constraint unique_username unique (username);

-- 3. Enable Row Level Security (RLS)
alter table public.profiles enable row level security;

-- 4. Create RLS Policies
drop policy if exists "Allow public read access" on public.profiles;
create policy "Allow public read access" on public.profiles
  for select using (true);

drop policy if exists "Allow update for owners" on public.profiles;
create policy "Allow update for owners" on public.profiles
  for update using (auth.uid() = id);

-- 5. Trigger Function to automatically create a profile when a new user signs up
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, email, security_question, security_answer, updated_at)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', ''),
    new.email,
    coalesce(new.raw_user_meta_data->>'security_question', ''),
    coalesce(new.raw_user_meta_data->>'security_answer', ''),
    now()
  );
  return new;
end;
$$ language plpgsql security definer;

-- 6. Trigger attachment to auth.users
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 7. Function to allow users to delete their own accounts
create or replace function public.delete_user_account()
returns void as $$
begin
  delete from auth.users where id = auth.uid();
end;
$$ language plpgsql security definer;
