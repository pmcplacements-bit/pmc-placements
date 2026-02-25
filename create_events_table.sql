-- Create events table
CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_name TEXT NOT NULL,
  event_date DATE NOT NULL,
  event_time TIME NOT NULL,
  description TEXT,
  location TEXT,
  poster_url TEXT NOT NULL,
  category TEXT DEFAULT 'other' CHECK (category IN ('placement', 'workshop', 'seminar', 'cultural', 'sports', 'technical', 'other')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index on event_date for faster queries
CREATE INDEX idx_events_date ON events(event_date DESC);

-- Create index on category
CREATE INDEX idx_events_category ON events(category);

-- Enable Row Level Security
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- Policy: Allow public to read events (students can view)
CREATE POLICY "Allow public read access to events"
ON events FOR SELECT
TO public
USING (true);

-- Policy: Allow authenticated users (admin) to insert events
CREATE POLICY "Allow authenticated insert to events"
ON events FOR INSERT
TO authenticated
WITH CHECK (true);

-- Policy: Allow authenticated users (admin) to update events
CREATE POLICY "Allow authenticated update to events"
ON events FOR UPDATE
TO authenticated
USING (true);

-- Policy: Allow authenticated users (admin) to delete events
CREATE POLICY "Allow authenticated delete from events"
ON events FOR DELETE
TO authenticated
USING (true);

-- Create storage bucket for event posters (run separately in Supabase Storage)
-- Bucket name: "Event Posters" (with space) or "event-posters" (without space, recommended)

-- Storage policies (apply after creating bucket):
/*
-- Policy: Allow authenticated users to upload
CREATE POLICY "Allow authenticated uploads to event posters"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'Event Posters');

-- Policy: Allow public to read event posters
CREATE POLICY "Allow public reads from event posters"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'Event Posters');

-- Policy: Allow authenticated users to update
CREATE POLICY "Allow authenticated updates to event posters"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'Event Posters');

-- Policy: Allow authenticated users to delete
CREATE POLICY "Allow authenticated deletes from event posters"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'Event Posters');
*/
