-- Create resources table for document management
CREATE TABLE IF NOT EXISTS resources (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    file_name TEXT NOT NULL,
    original_name TEXT NOT NULL,
    file_type TEXT NOT NULL,
    file_size TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    allocated_students TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX idx_resources_uploaded_at ON resources(uploaded_at DESC);

-- Add RLS (Row Level Security) policies
ALTER TABLE resources ENABLE ROW LEVEL SECURITY;

-- Allow all operations for authenticated users (admins)
CREATE POLICY "Allow all for authenticated users" ON resources
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- Allow students to read resources they're allocated to
CREATE POLICY "Students can view their allocated resources" ON resources
    FOR SELECT
    USING (
        auth.uid()::text = ANY(allocated_students)
        OR auth.role() = 'authenticated'
    );

COMMENT ON TABLE resources IS 'Stores uploaded documents and their student allocations';
COMMENT ON COLUMN resources.allocated_students IS 'Array of student IDs who have access to this resource';
