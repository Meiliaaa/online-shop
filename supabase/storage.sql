
-- Create bucket for profile images
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-images', 'profile-images', true)
ON CONFLICT DO NOTHING;

-- Create policy to allow anonymous users to read profile images (since they're public)
CREATE POLICY "Public Access" ON storage.objects FOR SELECT
USING (bucket_id = 'profile-images');

-- Create policy to allow authenticated users to upload their own profile images
CREATE POLICY "Users can upload their own profile images" ON storage.objects
FOR INSERT WITH CHECK (
  auth.uid() IS NOT NULL
  AND bucket_id = 'profile-images'
  AND (storage.foldername(name))[1] = auth.uid()::text
);
