-- Create Student Files bucket for storing resumes and certificates
-- Run this in Supabase Storage section or via SQL if bucket doesn't exist

-- Note: Bucket creation is typically done via Supabase Dashboard UI:
-- 1. Go to Storage in Supabase Dashboard
-- 2. Click "Create bucket"
-- 3. Name: "Student Files"
-- 4. Set as Public or Private based on your needs

-- Storage policies for Student Files bucket

-- Allow students to upload their own files
CREATE POLICY "Students can upload their own files" ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = 'Student Files' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow students to read their own files
CREATE POLICY "Students can read their own files" ON storage.objects
FOR SELECT
USING (
  bucket_id = 'Student Files' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow students to update their own files
CREATE POLICY "Students can update their own files" ON storage.objects
FOR UPDATE
USING (
  bucket_id = 'Student Files' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow students to delete their own files
CREATE POLICY "Students can delete their own files" ON storage.objects
FOR DELETE
USING (
  bucket_id = 'Student Files' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow admins/authenticated users to read all files
CREATE POLICY "Admins can read all student files" ON storage.objects
FOR SELECT
USING (
  bucket_id = 'Student Files' 
  AND auth.role() = 'authenticated'
);

-- If you want public read access (for resume sharing with companies):
CREATE POLICY "Public read access to student files" ON storage.objects
FOR SELECT
USING (bucket_id = 'Student Files');
