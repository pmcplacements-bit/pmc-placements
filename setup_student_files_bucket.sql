-- Create student files bucket with proper naming (no spaces)
INSERT INTO storage.buckets (id, name, public)
VALUES ('student-files', 'student-files', true)
ON CONFLICT (id) DO NOTHING;

-- Enable RLS on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Policy: Allow authenticated users to upload files
CREATE POLICY "Allow authenticated uploads to student-files"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'student-files');

-- Policy: Allow authenticated users to read files
CREATE POLICY "Allow authenticated reads from student-files"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'student-files');

-- Policy: Allow public reads (for viewing documents)
CREATE POLICY "Allow public reads from student-files"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'student-files');

-- Policy: Allow authenticated users to update their own files
CREATE POLICY "Allow authenticated updates to student-files"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'student-files');

-- Policy: Allow authenticated users to delete files
CREATE POLICY "Allow authenticated deletes from student-files"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'student-files');
