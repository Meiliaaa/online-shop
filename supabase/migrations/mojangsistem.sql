CREATE TABLE IF NOT EXISTS public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number VARCHAR NOT NULL,
  user_id UUID REFERENCES auth.users(id),
  product_id UUID REFERENCES public.products(id),
  quantity INTEGER NOT NULL,
  total_price NUMERIC NOT NULL,
  order_date DATE DEFAULT CURRENT_DATE,
  buyer_name VARCHAR NOT NULL,
  buyer_email VARCHAR NOT NULL,
  buyer_phone VARCHAR,
  payment_method VARCHAR,
  payment_status VARCHAR DEFAULT 'unpaid',
  payment_proof TEXT,
  status VARCHAR DEFAULT 'pending',
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
INSERT INTO storage.buckets (id, name, public)
VALUES ('order_files', 'order_files', true)
ON CONFLICT (id) DO NOTHING;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User melihat order sendiri"
  ON public.orders
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "User menambah order sendiri"
  ON public.orders
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "User update order sendiri"
  ON public.orders
  FOR UPDATE
  USING (auth.uid() = user_id);
-- Boleh akses file bukti pembayaran
CREATE POLICY "Public access ke order_files"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'order_files');

-- User upload file bukti pembayaran
CREATE POLICY "User upload file bukti bayar"
  ON storage.objects
  FOR INSERT
  WITH CHECK (bucket_id = 'order_files');
CREATE TABLE IF NOT EXISTS public.saved_products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  product_id UUID REFERENCES public.products(id) NOT NULL,
  saved_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, product_id)
);
ALTER TABLE public.saved_products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User lihat wishlist sendiri" 
  ON public.saved_products 
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "User simpan wishlist" 
  ON public.saved_products 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "User hapus wishlist" 
  ON public.saved_products 
  FOR DELETE 
  USING (auth.uid() = user_id);
