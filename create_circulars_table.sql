-- Create circulars table for managing student circulars/announcements

CREATE TABLE IF NOT EXISTS circulars (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('placement', 'academic', 'examination', 'general', 'urgent')),
  priority TEXT DEFAULT 'normal' CHECK (priority IN ('normal', 'high', 'urgent')),
  file_url TEXT,
  file_type TEXT,
  target_year INTEGER,
  target_dept TEXT,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_circulars_active ON circulars(is_active);
CREATE INDEX IF NOT EXISTS idx_circulars_category ON circulars(category);
CREATE INDEX IF NOT EXISTS idx_circulars_priority ON circulars(priority);
CREATE INDEX IF NOT EXISTS idx_circulars_target ON circulars(target_year, target_dept);
CREATE INDEX IF NOT EXISTS idx_circulars_created_at ON circulars(created_at DESC);

-- Enable Row Level Security
ALTER TABLE circulars ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Anyone can view active circulars" ON circulars;
DROP POLICY IF EXISTS "Admins can insert circulars" ON circulars;
DROP POLICY IF EXISTS "Admins can update circulars" ON circulars;
DROP POLICY IF EXISTS "Admins can delete circulars" ON circulars;

-- RLS Policy: Anyone can view active circulars
CREATE POLICY "Anyone can view active circulars"
ON circulars FOR SELECT
USING (is_active = true OR auth.uid() IS NOT NULL);

-- RLS Policy: Admins/Teachers can insert circulars
CREATE POLICY "Admins can insert circulars"
ON circulars FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.role IN ('admin', 'teacher')
  )
);

-- RLS Policy: Admins/Teachers can update circulars
CREATE POLICY "Admins can update circulars"
ON circulars FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.role IN ('admin', 'teacher')
  )
);

-- RLS Policy: Admins/Teachers can delete circulars
CREATE POLICY "Admins can delete circulars"
ON circulars FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.role IN ('admin', 'teacher')
  )
);

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_circulars_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_circulars_updated_at
BEFORE UPDATE ON circulars
FOR EACH ROW
EXECUTE FUNCTION update_circulars_updated_at();

-- Add comments for documentation
COMMENT ON TABLE circulars IS 'Stores circulars and announcements published to students';
COMMENT ON COLUMN circulars.title IS 'Title of the circular';
COMMENT ON COLUMN circulars.description IS 'Detailed description/content of the circular';
COMMENT ON COLUMN circulars.category IS 'Category: placement, academic, examination, general, urgent';
COMMENT ON COLUMN circulars.priority IS 'Priority level: normal, high, urgent';
COMMENT ON COLUMN circulars.file_url IS 'URL to uploaded image/PDF document';
COMMENT ON COLUMN circulars.target_year IS 'Target year (1-4) or NULL for all years';
COMMENT ON COLUMN circulars.target_dept IS 'Target department or NULL for all departments';
COMMENT ON COLUMN circulars.is_active IS 'Whether the circular is published and visible to students';
