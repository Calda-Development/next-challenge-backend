--
-- Enums
--
create type pizza_type as ENUM('vegetarian', 'vegan', 'meat', 'spicy');

create type role as ENUM('user', 'admin');

--
-- Tables
--
create table public.users_data (
  id uuid not null,
  email text null,
  created_at timestamp with time zone not null default now(),
  constraint users_data_pkey primary key (id),
  constraint users_data_id_fkey foreign key (id) references auth.users (id) on update cascade on delete cascade
) tablespace pg_default;

create table public.user_roles (
  user_id uuid not null,
  role role not null,
  constraint user_roles_pkey primary key (user_id),
  constraint user_roles_user_id_fkey foreign key (user_id) references users_data (id) on update cascade on delete cascade
) tablespace pg_default;

create table public.pizzas (
  id uuid default gen_random_uuid () not null,
  name text null,
  price smallint not null default '0'::smallint,
  image_url text null,
  description text null,
  type pizza_type null,
  constraint pizzas_pkey primary key (id)
) tablespace pg_default;

create table public.add_ons (
  id uuid default gen_random_uuid () not null,
  name text not null,
  price smallint default '0'::smallint not null,
  constraint add_ons_pkey primary key (id)
) tablespace pg_default;

create table public.orders (
  id uuid default gen_random_uuid () not null,
  user_id uuid not null,
  created_at timestamp with time zone not null default now(),
  constraint order_pkey primary key (id),
  constraint order_user_id_fkey foreign key (user_id) references users_data (id) on update cascade on delete set null
) tablespace pg_default;

create table public.order_lines (
  id uuid default gen_random_uuid () not null,
  order_id uuid not null,
  pizza_id uuid not null,
  price smallint not null,
  quantity smallint default '0'::smallint not null,
  add_ons jsonb null,
  constraint order_lines_pkey primary key (id),
  constraint order_lines_order_id_fkey foreign key (order_id) references orders (id) on update cascade on delete cascade,
  constraint order_lines_pizza_id_fkey foreign key (pizza_id) references pizzas (id) on update cascade on delete set null
) tablespace pg_default;

create table public.order_lines_add_ons (
  order_line_id uuid not null,
  add_on_id uuid not null,
  primary key (order_line_id, add_on_id),
  constraint order_lines_add_ons_order_line_id_fkey foreign key (order_line_id) references order_lines (id) on update cascade on delete cascade,
  constraint order_lines_add_ons_add_on_id_fkey foreign key (add_on_id) references add_ons (id) on update cascade on delete set null
) tablespace pg_default;

--
-- Database functions
--
create function public.handle_new_user_creation () RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER
set
  search_path to '' as $$
begin
  insert into public.users_data (id, email)
  values (new.id, new.email);

  insert into public.user_roles (user_id, role)
  values (new.id, 'user');

  return new;
end;
$$;

create trigger on_auth_user_creation
after INSERT on auth.users for EACH row
execute FUNCTION public.handle_new_user_creation ();

create function public.custom_access_token_hook (event jsonb) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
set
  search_path to '' as $$
declare
  u_role public.role;
  claims jsonb;
begin
  select role
  into u_role
  from public.user_roles
  where user_id = (event->>'user_id')::uuid;

  claims := coalesce(event->'claims', '{}'::jsonb);
  claims := jsonb_set(claims, '{user_role}', to_jsonb(u_role));

  event := jsonb_set(event, '{claims}', claims);

  return event;
end;
$$;