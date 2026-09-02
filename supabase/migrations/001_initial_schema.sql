-- Diniz Fornecedor: schema inicial para Supabase
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role text not null default 'admin' check (role in ('admin','editor')),
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null default 'Variedades',
  condition text not null default 'Novo' check (condition in ('Novo','Seminovo')),
  color text,
  specification text,
  price numeric(12,2) not null default 0,
  compare_at_price numeric(12,2),
  description text,
  stock_status text not null default 'Disponível' check (stock_status in ('Disponível','Esgotado')),
  featured boolean not null default false,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.product_images (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  storage_path text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.banners (
  id uuid primary key default gen_random_uuid(),
  title text,
  subtitle text,
  storage_path text,
  active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references public.products(id) on delete set null,
  name text,
  city text,
  phone text,
  message text,
  created_at timestamptz not null default now()
);

create table if not exists public.store_settings (
  id boolean primary key default true,
  store_name text not null default 'Diniz Fornecedor',
  whatsapp_number text,
  support_hours text default 'Seg–Sáb, 9h às 19h',
  hero_title text default 'Em destaque no catálogo.',
  hero_subtitle text,
  updated_at timestamptz not null default now()
);
insert into public.store_settings (id) values (true) on conflict (id) do nothing;

alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.product_images enable row level security;
alter table public.banners enable row level security;
alter table public.leads enable row level security;
alter table public.store_settings enable row level security;

create policy "Public can read active products" on public.products for select using (active = true);
create policy "Public can read product images" on public.product_images for select using (true);
create policy "Public can read active banners" on public.banners for select using (active = true);
create policy "Public can read settings" on public.store_settings for select using (true);
create policy "Anyone can create leads" on public.leads for insert with check (true);

create or replace function public.is_admin() returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role in ('admin','editor'));
$$;
create policy "Admins manage products" on public.products for all using (public.is_admin()) with check (public.is_admin());
create policy "Admins manage product images" on public.product_images for all using (public.is_admin()) with check (public.is_admin());
create policy "Admins manage banners" on public.banners for all using (public.is_admin()) with check (public.is_admin());
create policy "Admins read leads" on public.leads for select using (public.is_admin());
create policy "Admins manage settings" on public.store_settings for all using (public.is_admin()) with check (public.is_admin());
create policy "Users read own profile" on public.profiles for select using (auth.uid() = id);

insert into public.products (name, category, condition, color, specification, price, compare_at_price, featured, description)
select * from (values
  ('iPhone 13','Apple','Novo','Branco','128 GB',2799,3299,true,'Aparelho novo, com nota fiscal e garantia de fábrica.'),
  ('Galaxy S23','Samsung','Novo','Preto','128 GB',2399,2899,true,'Performance premium e câmera avançada para sua loja.'),
  ('iPhone 15','Apple','Seminovo','Azul','128 GB',3499,null,false,'Produto revisado e pronto para uso.'),
  ('Redmi Note 13','Xiaomi','Novo','Verde','256 GB',1299,null,false,'Ótimo giro para sua loja com excelente custo-benefício.')
) as seed(name,category,condition,color,specification,price,compare_at_price,featured,description)
where not exists (select 1 from public.products);

-- Crie um bucket público chamado product-images no Storage e um bucket banners.
