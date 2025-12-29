-- 1. Crea la tabella 'rooms' (stanze)
create table public.rooms (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  code text not null unique,
  status text default 'waiting' not null,
  player_order jsonb,
  current_player_index integer default 0,
  winner text,
  faker_name text,
  last_eliminated text,
  current_question text,
  ind integer,
  eliminated_players jsonb default '[]'::jsonb
);

-- 2. Crea la tabella 'players' (giocatori)
create table public.players (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  room_id uuid references public.rooms(id) on delete cascade not null,
  name text not null,
  is_host boolean default false,
  is_faker boolean default false,
  is_ready boolean default false,
  vote_target text
);

-- 3. Abilita RLS (Row Level Security)
alter table public.rooms enable row level security;
alter table public.players enable row level security;

-- 4. Crea policy per permettere operazioni pubbliche (per semplicita)
-- NOTA: In produzione dovresti creare policy piu restrittive!

create policy "Allow all operations on rooms" on public.rooms
  for all using (true) with check (true);

create policy "Allow all operations on players" on public.players
  for all using (true) with check (true);

-- 5. Abilita Realtime per le tabelle
alter publication supabase_realtime add table rooms;
alter publication supabase_realtime add table players;

-- 6. Crea indice per migliorare le performance
create index rooms_code_idx on public.rooms(code);
create index players_room_id_idx on public.players(room_id);
