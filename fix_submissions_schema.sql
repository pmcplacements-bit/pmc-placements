-- Add missing columns to submissions table for exam tracking and anti-cheat

-- Add violation_count column to track anti-cheat violations
ALTER TABLE submissions 
ADD COLUMN IF NOT EXISTS violation_count INTEGER DEFAULT 0;

-- Add auto_submitted column to track if exam was auto-submitted
ALTER TABLE submissions 
ADD COLUMN IF NOT EXISTS auto_submitted BOOLEAN DEFAULT false;

-- Ensure the violations table exists for detailed violation logging
CREATE TABLE IF NOT EXISTS violations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES students(id) ON DELETE CASCADE,
  exam_id UUID REFERENCES exams(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster violation queries
CREATE INDEX IF NOT EXISTS idx_violations_student_exam 
ON violations(student_id, exam_id);

CREATE INDEX IF NOT EXISTS idx_violations_timestamp 
ON violations(timestamp);

-- Enable Row Level Security on violations table
ALTER TABLE violations ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Students can only see their own violations
CREATE POLICY IF NOT EXISTS "Students can view own violations"
ON violations FOR SELECT
USING (auth.uid() = student_id);

-- RLS Policy: System can insert violations
CREATE POLICY IF NOT EXISTS "System can insert violations"
ON violations FOR INSERT
WITH CHECK (true);

-- RLS Policy: Admins/Teachers can view all violations
CREATE POLICY IF NOT EXISTS "Admins can view all violations"
ON violations FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.role IN ('admin', 'teacher')
  )
);

-- Add comment for documentation
COMMENT ON COLUMN submissions.violation_count IS 'Number of anti-cheat violations during exam (tab switch, fullscreen exit, etc.)';
COMMENT ON COLUMN submissions.auto_submitted IS 'Whether the exam was automatically submitted due to violations or timeout';
COMMENT ON TABLE violations IS 'Detailed log of all exam violations for anti-cheat monitoring';
