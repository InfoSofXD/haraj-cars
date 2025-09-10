-- Verify database setup
-- Run these commands in your Supabase SQL Editor to check if everything is set up correctly

-- 1. Check if tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('cars', 'admin');

-- 2. Check admin table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'admin' 
AND table_schema = 'public';

-- 3. Check if admin user exists
SELECT * FROM admin;

-- 4. Check cars table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'cars' 
AND table_schema = 'public';

-- 5. Check RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE tablename IN ('cars', 'admin');

-- 6. If admin table is empty, insert default admin user
INSERT INTO admin (username, password) 
VALUES ('admin', 'admin123') 
ON CONFLICT (username) DO NOTHING;

-- 7. Verify admin user was created
SELECT * FROM admin; 