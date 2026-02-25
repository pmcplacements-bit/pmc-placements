// Supabase client setup
// Use UMD build for browser compatibility
const { createClient } = window.supabase;

export const supabase = createClient(
  'https://kflhmnyikwaznzkgeini.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtmbGhtbnlpa3dhem56a2dlaW5pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1NTQ5MDEsImV4cCI6MjA4MDEzMDkwMX0.nTkrtt4SQEYLq529ccYvnR46L1mbzBzagoVifP2VkWQ'
);

// Helper for table access
export const getTable = (table) => supabase.from(table);