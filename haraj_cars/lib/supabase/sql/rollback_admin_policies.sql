-- =============================================
-- ROLLBACK ADMIN DASHBOARD POLICIES
-- =============================================
-- This script reverses all changes made by admin_dashboard_policies.sql
-- Run this in your Supabase SQL Editor to undo everything

-- =============================================
-- REMOVE POLICIES FIRST (to avoid dependency issues)
-- =============================================

-- Drop the auth.users policy first
DROP POLICY IF EXISTS "Admins can read auth users" ON auth.users;

-- =============================================
-- REMOVE TRIGGERS AND FUNCTIONS
-- =============================================

-- Drop the comments count trigger and function
DROP TRIGGER IF EXISTS update_post_comments_count_trigger ON comments;
DROP FUNCTION IF EXISTS update_post_comments_count();

-- =============================================
-- REMOVE FUNCTIONS (after policies are removed)
-- =============================================

-- Drop all dashboard functions
DROP FUNCTION IF EXISTS get_user_count();
DROP FUNCTION IF EXISTS get_recent_users(INTEGER);
DROP FUNCTION IF EXISTS get_admin_count();
DROP FUNCTION IF EXISTS get_recent_admins(INTEGER);
DROP FUNCTION IF EXISTS get_car_statistics();
DROP FUNCTION IF EXISTS get_recent_cars(INTEGER);
DROP FUNCTION IF EXISTS get_recent_posts(INTEGER);
DROP FUNCTION IF EXISTS is_admin();

-- =============================================
-- REMOVE COLUMNS (OPTIONAL - BE CAREFUL!)
-- =============================================

-- WARNING: This will remove the comments column from posts table
-- Only run this if you want to completely remove the comments count feature
-- ALTER TABLE posts DROP COLUMN IF EXISTS comments;

-- =============================================
-- REVOKE PERMISSIONS
-- =============================================

-- Revoke execute permissions (if they were granted)
-- Note: These might not exist, so errors are expected
DO $$
BEGIN
    -- Try to revoke permissions, ignore errors if they don't exist
    BEGIN
        REVOKE EXECUTE ON FUNCTION get_user_count() FROM authenticated;
    EXCEPTION
        WHEN undefined_function THEN NULL;
    END;
    
    BEGIN
        REVOKE EXECUTE ON FUNCTION get_recent_users(INTEGER) FROM authenticated;
    EXCEPTION
        WHEN undefined_function THEN NULL;
    END;
    
    BEGIN
        REVOKE EXECUTE ON FUNCTION get_admin_count() FROM authenticated;
    EXCEPTION
        WHEN undefined_function THEN NULL;
    END;
    
    BEGIN
        REVOKE EXECUTE ON FUNCTION get_recent_admins(INTEGER) FROM authenticated;
    EXCEPTION
        WHEN undefined_function THEN NULL;
    END;
    
    BEGIN
        REVOKE EXECUTE ON FUNCTION get_car_statistics() FROM authenticated;
    EXCEPTION
        WHEN undefined_function THEN NULL;
    END;
    
    BEGIN
        REVOKE EXECUTE ON FUNCTION get_recent_cars(INTEGER) FROM authenticated;
    EXCEPTION
        WHEN undefined_function THEN NULL;
    END;
    
    BEGIN
        REVOKE EXECUTE ON FUNCTION get_recent_posts(INTEGER) FROM authenticated;
    EXCEPTION
        WHEN undefined_function THEN NULL;
    END;
    
    BEGIN
        REVOKE EXECUTE ON FUNCTION is_admin() FROM authenticated;
    EXCEPTION
        WHEN undefined_function THEN NULL;
    END;
END $$;

-- =============================================
-- VERIFICATION
-- =============================================

-- Check if functions are removed
SELECT 
    routine_name, 
    routine_type 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN (
    'get_user_count', 
    'get_recent_users', 
    'get_admin_count', 
    'get_recent_admins', 
    'get_car_statistics', 
    'get_recent_cars', 
    'get_recent_posts', 
    'is_admin'
);

-- Check if policies are removed
SELECT 
    schemaname, 
    tablename, 
    policyname 
FROM pg_policies 
WHERE policyname = 'Admins can read auth users';

-- =============================================
-- CLEANUP COMPLETE
-- =============================================

-- This script should have removed:
-- ✅ All dashboard functions
-- ✅ All triggers
-- ✅ All policies
-- ✅ All granted permissions
-- ⚠️  Comments column (commented out for safety)

-- Your app should now work as it did before!
