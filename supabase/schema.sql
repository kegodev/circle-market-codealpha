-- Dedicated CodeAlpha commerce data in the existing Dinglo Supabase project.
create table if not exists public.shop_products (
 id bigint generated always as identity primary key,
 slug text not null unique,
 name text not null,
 category text not null,
 description text not null,
 price_cents integer not null check (price_cents > 0),
 stock integer not null default 0 check (stock >= 0),
 image_url text not null,
 featured boolean not null default false,
 active boolean not null default true
);
create table if not exists public.shop_orders (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id),
 status text not null default 'placed' check (status in ('placed','processing','fulfilled','cancelled')),
 total_cents integer not null check (total_cents >= 0),
 created_at timestamptz not null default now()
);
create table if not exists public.shop_order_items (
 id bigint generated always as identity primary key,
 order_id uuid not null references public.shop_orders(id) on delete cascade,
 product_id bigint not null references public.shop_products(id),
 product_name text not null,
 quantity integer not null check (quantity > 0),
 unit_price_cents integer not null check (unit_price_cents > 0)
);
create index if not exists shop_orders_user_created_idx on public.shop_orders(user_id, created_at desc);
create index if not exists shop_order_items_order_idx on public.shop_order_items(order_id);
alter table public.shop_products enable row level security;
alter table public.shop_orders enable row level security;
alter table public.shop_order_items enable row level security;
create policy "Anyone reads active products" on public.shop_products for select to anon, authenticated using (active);
create policy "Customers read own orders" on public.shop_orders for select to authenticated using ((select auth.uid()) = user_id);
create policy "Customers read own line items" on public.shop_order_items for select to authenticated using (exists (select 1 from public.shop_orders o where o.id = order_id and o.user_id = (select auth.uid())));
grant select on public.shop_products to anon, authenticated;
grant select on public.shop_orders, public.shop_order_items to authenticated;
-- No direct client writes to orders, items, or products.
revoke insert, update, delete on public.shop_products, public.shop_orders, public.shop_order_items from anon, authenticated;
create schema if not exists shop_private;
revoke all on schema shop_private from public;
grant usage on schema shop_private to authenticated;
create or replace function shop_private.place_order(p_items jsonb) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
 v_user uuid := (select auth.uid());
 v_order uuid;
 v_line jsonb;
 v_product public.shop_products%rowtype;
 v_quantity integer;
 v_total bigint := 0;
 v_ids bigint[] := '{}';
begin
 if v_user is null or coalesce((select (auth.jwt()->>'is_anonymous')::boolean), false) then
   raise exception 'Sign in to place an order';
 end if;
 if jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) not between 1 and 20 then
   raise exception 'Cart must contain 1 to 20 products';
 end if;
 -- Lock all requested products in a stable order to prevent concurrent stock overselling.
 perform 1 from public.shop_products p where p.id in
   (select (x->>'product_id')::bigint from jsonb_array_elements(p_items) x)
   order by p.id for update;
 insert into public.shop_orders(user_id,total_cents) values (v_user,0) returning id into v_order;
 for v_line in select * from jsonb_array_elements(p_items) loop
   if jsonb_typeof(v_line) <> 'object' or (v_line->>'product_id') !~ '^[0-9]{1,15}$'
      or (v_line->>'quantity') !~ '^[0-9]{1,2}$' then raise exception 'Invalid cart item'; end if;
   v_quantity := (v_line->>'quantity')::integer;
   if v_quantity not between 1 and 20 then raise exception 'Invalid quantity'; end if;
   if (v_line->>'product_id')::bigint = any(v_ids) then raise exception 'Duplicate product in cart'; end if;
   v_ids := array_append(v_ids, (v_line->>'product_id')::bigint);
   select * into v_product from public.shop_products
     where id = (v_line->>'product_id')::bigint and active;
   if not found or v_product.stock < v_quantity then raise exception 'A product is out of stock'; end if;
   update public.shop_products set stock = stock - v_quantity where id = v_product.id;
   insert into public.shop_order_items(order_id,product_id,product_name,quantity,unit_price_cents)
     values(v_order,v_product.id,v_product.name,v_quantity,v_product.price_cents);
   v_total := v_total + v_quantity::bigint * v_product.price_cents;
 end loop;
 if v_total > 2147483647 then raise exception 'Order exceeds maximum amount'; end if;
 update public.shop_orders set total_cents = v_total::integer where id = v_order;
 return jsonb_build_object('id',v_order,'status','placed','total_cents',v_total);
end; $$;
revoke all on function shop_private.place_order(jsonb) from public, anon;
grant execute on function shop_private.place_order(jsonb) to authenticated;
-- Exposed wrapper uses the caller's role; privileged logic lives only in a private schema.
create or replace function public.shop_place_order(p_items jsonb) returns jsonb
language sql security invoker set search_path = '' as $$
 select shop_private.place_order(p_items);
$$;
revoke all on function public.shop_place_order(jsonb) from public, anon;
grant execute on function public.shop_place_order(jsonb) to authenticated;
insert into public.shop_products(slug,name,category,description,price_cents,stock,image_url,featured) values
('linen-shirt','The Linen Shirt','Shirts','An easy, breathable button-up in soft natural linen.',64900,18,'/assets/linen-shirt.svg',true),
('studio-hoodie','Studio Hoodie','Layers','A relaxed heavyweight hoodie in muted sage.',89900,16,'/assets/studio-hoodie.svg',true),
('relaxed-trousers','Relaxed Trousers','Bottoms','A loose everyday fit with a comfortable, tailored finish.',79900,14,'/assets/relaxed-trousers.svg',false),
('everyday-tee','Everyday Tee','Shirts','A clean cotton essential for effortless layering.',34900,32,'/assets/everyday-tee.svg',false),
('canvas-jacket','Canvas Jacket','Layers','A sturdy, softly structured jacket for changing seasons.',119900,12,'/assets/canvas-jacket.svg',true),
('ribbed-knit','Ribbed Knit','Layers','A cozy textured knit for cooler days.',94900,15,'/assets/ribbed-knit.svg',false)
on conflict(slug) do nothing;
