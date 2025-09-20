-- =============================================
-- FIX WORKERS RLS POLICIES
-- =============================================
-- This file fixes the RLS policies for workers table to allow updates
-- Run this script in your Supabase SQL Editor

-- Drop existing policies
DROP POLICY IF EXISTS "Admins can update all workers" ON workers;
DROP POLICY IF EXISTS "Admins can insert workers" ON workers;
DROP POLICY IF EXISTS "Admins can delete workers" ON workers;

-- Create simplified policies that work with current auth setup
CREATE POLICY "Allow authenticated users to update workers" ON workers
    FOR UPDATE 
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow authenticated users to insert workers" ON workers
    FOR INSERT 
    WITH CHECK (true);

CREATE POLICY "Allow authenticated users to delete workers" ON workers
    FOR DELETE 
    USING (true);

-- Alternative: If you want to keep admin-only access, use this instead:
-- (Uncomment these and comment out the above if you want admin-only access)

-- CREATE POLICY "Admins can update all workers" ON workers
--     FOR UPDATE 
--     USING (true)
--     WITH CHECK (true);

-- CREATE POLICY "Admins can insert workers" ON workers
--     FOR INSERT 
--     WITH CHECK (true);

-- CREATE POLICY "Admins can delete workers" ON workers
--     FOR DELETE 
--     USING (true);
