-- Update students table with additional placement-related fields
ALTER TABLE public.students 
ADD COLUMN IF NOT EXISTS passport_available BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS aadhar_number TEXT,
ADD COLUMN IF NOT EXISTS resume_url TEXT,
ADD COLUMN IF NOT EXISTS my_strength TEXT,
ADD COLUMN IF NOT EXISTS my_weakness TEXT,
ADD COLUMN IF NOT EXISTS my_ambition TEXT,
ADD COLUMN IF NOT EXISTS hobbies TEXT,
ADD COLUMN IF NOT EXISTS certificates JSONB DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS leetcode_link TEXT,
ADD COLUMN IF NOT EXISTS github_link TEXT,
ADD COLUMN IF NOT EXISTS profile_updated_at TIMESTAMP WITH TIME ZONE;

-- Add comments for documentation
COMMENT ON COLUMN students.passport_available IS 'Whether student has a passport';
COMMENT ON COLUMN students.aadhar_number IS 'Student Aadhar card number';
COMMENT ON COLUMN students.resume_url IS 'URL to student resume in Student Files bucket';
COMMENT ON COLUMN students.my_strength IS 'Student strengths';
COMMENT ON COLUMN students.my_weakness IS 'Student weaknesses';
COMMENT ON COLUMN students.my_ambition IS 'Student career ambitions';
COMMENT ON COLUMN students.hobbies IS 'Student hobbies and interests';
COMMENT ON COLUMN students.certificates IS 'Array of certificates with name and URL: [{name: string, url: string}]';
COMMENT ON COLUMN students.leetcode_link IS 'Optional LeetCode profile link';
COMMENT ON COLUMN students.github_link IS 'Optional GitHub profile link';

-- Create index for faster profile lookups
CREATE INDEX IF NOT EXISTS idx_students_profile_updated ON students(profile_updated_at DESC);
