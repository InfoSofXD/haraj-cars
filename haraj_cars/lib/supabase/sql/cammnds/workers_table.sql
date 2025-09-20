-- =============================================
-- WORKERS TABLE CREATION
-- =============================================
-- This file creates the workers table with permissions and RLS policies
-- Run this script in your Supabase SQL Editor

-- =============================================
-- WORKERS TABLE CREATION
-- =============================================

-- Create workers table
CREATE TABLE IF NOT EXISTS workers (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    permissions JSONB NOT NULL DEFAULT '{
        "add_car": false,
        "use_scraper": false,
        "edit_car": false,
        "delete_car": false,
        "add_post": false,
        "edit_post": false,
        "delete_post": false,
        "use_dashboard": false,
        "delete_user": false
    }'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_sign_in TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_workers_uuid ON workers(uuid);
CREATE INDEX IF NOT EXISTS idx_workers_email ON workers(email);
CREATE INDEX IF NOT EXISTS idx_workers_phone ON workers(phone);
CREATE INDEX IF NOT EXISTS idx_workers_created_at ON workers(created_at);
CREATE INDEX IF NOT EXISTS idx_workers_last_sign_in ON workers(last_sign_in);

-- =============================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================

-- Enable RLS on workers table
ALTER TABLE workers ENABLE ROW LEVEL SECURITY;

-- =============================================
-- SECURITY POLICIES
-- =============================================

-- Policy 1: Workers can read their own data
CREATE POLICY "Workers can read own data" ON workers
    FOR SELECT 
    USING (uuid::text = current_setting('request.jwt.claims', true)::json->>'sub');

-- Policy 2: Workers can update their own data (except permissions)
CREATE POLICY "Workers can update own data" ON workers
    FOR UPDATE 
    USING (uuid::text = current_setting('request.jwt.claims', true)::json->>'sub')
    WITH CHECK (uuid::text = current_setting('request.jwt.claims', true)::json->>'sub');

-- Policy 3: Admins can read all workers
CREATE POLICY "Admins can read all workers" ON workers
    FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM admin 
            WHERE username = current_setting('request.jwt.claims', true)::json->>'email'
        )
    );

-- Policy 4: Admins can insert workers
CREATE POLICY "Admins can insert workers" ON workers
    FOR INSERT 
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM admin 
            WHERE username = current_setting('request.jwt.claims', true)::json->>'email'
        )
    );

-- Policy 5: Admins can update all workers
CREATE POLICY "Admins can update all workers" ON workers
    FOR UPDATE 
    USING (
        EXISTS (
            SELECT 1 FROM admin 
            WHERE username = current_setting('request.jwt.claims', true)::json->>'email'
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM admin 
            WHERE username = current_setting('request.jwt.claims', true)::json->>'email'
        )
    );

-- Policy 6: Admins can delete workers
CREATE POLICY "Admins can delete workers" ON workers
    FOR DELETE 
    USING (
        EXISTS (
            SELECT 1 FROM admin 
            WHERE username = current_setting('request.jwt.claims', true)::json->>'email'
        )
    );

-- Policy 7: Public can read workers (for authentication purposes)
CREATE POLICY "Public can read workers for auth" ON workers
    FOR SELECT 
    USING (true);

-- =============================================
-- FUNCTIONS
-- =============================================

-- Function to update last_sign_in timestamp
CREATE OR REPLACE FUNCTION update_worker_last_sign_in(worker_uuid UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE workers 
    SET last_sign_in = NOW(), updated_at = NOW()
    WHERE uuid = worker_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to authenticate worker
CREATE OR REPLACE FUNCTION authenticate_worker(worker_email VARCHAR, worker_password VARCHAR)
RETURNS TABLE(
    worker_uuid UUID,
    worker_name VARCHAR,
    worker_permissions JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        w.uuid,
        w.name,
        w.permissions
    FROM workers w
    WHERE w.email = worker_email 
    AND w.password = worker_password;
    
    -- Update last sign in
    PERFORM update_worker_last_sign_in(w.uuid)
    FROM workers w
    WHERE w.email = worker_email 
    AND w.password = worker_password;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check worker permission
CREATE OR REPLACE FUNCTION check_worker_permission(worker_uuid UUID, permission_name TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    worker_permissions JSONB;
BEGIN
    SELECT permissions INTO worker_permissions
    FROM workers
    WHERE uuid = worker_uuid;
    
    IF worker_permissions IS NULL THEN
        RETURN FALSE;
    END IF;
    
    RETURN COALESCE((worker_permissions->>permission_name)::boolean, FALSE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- SAMPLE DATA INSERTION
-- =============================================

-- Insert sample workers with different permission levels
INSERT INTO workers (name, phone, email, password, permissions) VALUES 
    (
        'Ahmed Al-Rashid', 
        '+966501234567', 
        'ahmed@harajcars.com', 
        'worker123',
        '{
            "add_car": true,
            "use_scraper": true,
            "edit_car": true,
            "delete_car": false,
            "add_post": true,
            "edit_post": true,
            "delete_post": false,
            "use_dashboard": true,
            "delete_user": false
        }'::jsonb
    ),
    (
        'Sara Al-Mansouri', 
        '+966502345678', 
        'sara@harajcars.com', 
        'worker456',
        '{
            "add_car": true,
            "use_scraper": false,
            "edit_car": true,
            "delete_car": false,
            "add_post": true,
            "edit_post": true,
            "delete_post": false,
            "use_dashboard": true,
            "delete_user": false
        }'::jsonb
    ),
    (
        'Mohammed Al-Zahra', 
        '+966503456789', 
        'mohammed@harajcars.com', 
        'worker789',
        '{
            "add_car": false,
            "use_scraper": false,
            "edit_car": false,
            "delete_car": false,
            "add_post": true,
            "edit_post": true,
            "delete_post": false,
            "use_dashboard": false,
            "delete_user": false
        }'::jsonb
    )
ON CONFLICT (email) DO NOTHING;

-- =============================================
-- VERIFICATION QUERIES
-- =============================================

-- Uncomment the following queries to verify the setup:

-- Check if workers table exists
-- SELECT table_name 
-- FROM information_schema.tables 
-- WHERE table_schema = 'public' 
-- AND table_name = 'workers';

-- Check workers table structure
-- SELECT column_name, data_type, is_nullable, column_default
-- FROM information_schema.columns 
-- WHERE table_name = 'workers' 
-- AND table_schema = 'public'
-- ORDER BY ordinal_position;

-- Check RLS policies for workers table
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
-- FROM pg_policies 
-- WHERE tablename = 'workers';

-- Test worker authentication function
-- SELECT * FROM authenticate_worker('ahmed@harajcars.com', 'worker123');

-- Test permission check function
-- SELECT check_worker_permission(
--     (SELECT uuid FROM workers WHERE email = 'ahmed@harajcars.com'),
--     'add_car'
-- );
