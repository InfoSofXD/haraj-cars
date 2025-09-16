-- =============================================
-- DATABASE VERIFICATION SCRIPT
-- =============================================
-- Run these commands to verify your database setup is correct

-- 1. Check if all tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('cars', 'brands', 'admin')
ORDER BY table_name;

-- 2. Check cars table structure
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'cars' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 3. Check brands table structure
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'brands' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 4. Check admin table structure
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'admin' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 5. Check RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE tablename IN ('cars', 'brands', 'admin')
ORDER BY tablename, policyname;

-- 6. Check sample data
SELECT 'Cars count:' as info, COUNT(*) as count FROM cars
UNION ALL
SELECT 'Brands count:', COUNT(*) FROM brands
UNION ALL
SELECT 'Admin count:', COUNT(*) FROM admin;

-- 7. Check storage bucket
SELECT name, public FROM storage.buckets WHERE name = 'car-images';

-- 8. If admin table is empty, insert default admin user
INSERT INTO admin (username, password) 
VALUES ('admin', 'admin123') 
ON CONFLICT (username) DO NOTHING;

-- 9. Verify admin user was created
SELECT * FROM admin;