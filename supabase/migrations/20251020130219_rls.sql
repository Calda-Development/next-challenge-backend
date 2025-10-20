ALTER TABLE public.add_ons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_lines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_lines_add_ons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pizzas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users_data ENABLE ROW LEVEL SECURITY;

CREATE POLICY pizzas_read_policy
ON public.pizzas
FOR SELECT
TO anon
USING (true);

CREATE POLICY pizzas_admin_full_access
ON public.pizzas
FOR ALL
TO authenticated
USING (
  auth.jwt()->>'user_role' = 'admin'
)
WITH CHECK (
  auth.jwt()->>'user_role' = 'admin'
);

CREATE POLICY add_ons_read_policy
ON public.add_ons
FOR SELECT
TO anon
USING (true);

CREATE POLICY add_ons_admin_full_access
ON public.add_ons
FOR ALL
TO authenticated
USING (
  auth.jwt()->>'user_role' = 'admin'
)
WITH CHECK (
  auth.jwt()->>'user_role' = 'admin'
);

CREATE POLICY users_data_read_access
ON public.users_data
FOR SELECT
TO authenticated
USING (
  id = auth.uid()
);

CREATE POLICY users_data_update_access
ON public.users_data
FOR UPDATE
TO authenticated
USING (
  id = auth.uid()
)
WITH CHECK (
  id = auth.uid()
);

CREATE POLICY users_data_admin_full_access
ON public.users_data
FOR ALL
TO authenticated
USING (
  auth.jwt()->>'user_role' = 'admin'
)
WITH CHECK (
  auth.jwt()->>'user_role' = 'admin'
);

CREATE POLICY user_roles_readonly
ON public.user_roles
FOR SELECT
TO authenticated
USING (
  user_id = auth.uid()
);

CREATE POLICY orders_admin_read_access
ON public.orders
FOR SELECT
TO authenticated
USING (
  auth.jwt()->>'user_role' = 'admin'
);

CREATE POLICY orders_users_read_access
ON public.orders
FOR SELECT
TO authenticated
USING (
  user_id = auth.uid()
);

CREATE POLICY orders_users_write_access
ON public.orders
FOR INSERT
TO authenticated
WITH CHECK (
  user_id = auth.uid()
);

CREATE POLICY order_lines_admin_read_access
ON public.order_lines
FOR SELECT
TO authenticated
USING (
  auth.jwt()->>'user_role' = 'admin'
);

CREATE POLICY order_lines_users_read_access
ON public.order_lines
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM public.orders o
    WHERE o.id = order_lines.order_id
      AND o.user_id = auth.uid()
  )
);

CREATE POLICY order_lines_users_write_access
ON public.order_lines
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.orders o
    WHERE o.id = order_lines.order_id
      AND o.user_id = auth.uid()
  )
);

CREATE POLICY order_lines_add_ons_admin_read_access
ON public.order_lines_add_ons
FOR SELECT
TO authenticated
USING (
  auth.jwt()->>'user_role' = 'admin'
);

CREATE POLICY order_lines_add_ons_users_read_access
ON public.order_lines_add_ons
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM public.order_lines ol
    JOIN public.orders o ON o.id = ol.order_id
    WHERE ol.id = order_lines_add_ons.order_line_id
      AND o.user_id = auth.uid()
  )
);

CREATE POLICY order_lines_add_ons_users_write_access
ON public.order_lines_add_ons
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.order_lines ol
    JOIN public.orders o ON o.id = ol.order_id
    WHERE ol.id = order_lines_add_ons.order_line_id
      AND o.user_id = auth.uid()
  )
);