-- =============================================
-- FIX USER FUNCTIONS TYPE MISMATCH
-- =============================================
-- This file fixes the type mismatch error in user functions
-- Run this script in your Supabase SQL Editor to fix the issue

-- =============================================
-- DROP EXISTING FUNCTIONS
-- =============================================

-- Drop the existing functions that have type issues
DROP FUNCTION IF EXISTS get_simple_user_count();
DROP FUNCTION IF EXISTS get_all_users();

-- =============================================
-- CREATE FIXED USER FUNCTIONS
-- =============================================

-- Fixed user count function
CREATE OR REPLACE FUNCTION get_simple_user_count()
RETURNS INTEGER AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM auth.users);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fixed get all users function with proper type casting
CREATE OR REPLACE FUNCTION get_all_users()
RETURNS TABLE (
    id UUID,
    email TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    last_sign_in TIMESTAMP WITH TIME ZONE,
    email_confirmed BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.email::TEXT,  -- Explicit cast to TEXT
        u.created_at,
        u.last_sign_in_at,
        (u.email_confirmed_at IS NOT NULL) as email_confirmed
    FROM auth.users u
    ORDER BY u.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- GRANT PERMISSIONS
-- =============================================

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION get_simple_user_count() TO authenticated;
GRANT EXECUTE ON FUNCTION get_all_users() TO authenticated;

-- =============================================
-- TEST THE FUNCTIONS
-- =============================================

-- Uncomment to test:
-- SELECT get_simple_user_count();
-- SELECT * FROM get_all_users() LIMIT 5;

-- =============================================
-- VERIFICATION
-- =============================================

-- Check function signatures
SELECT 
    r.routine_name, 
    p.data_type,
    p.parameter_name,
    p.parameter_mode
FROM information_schema.routines r
LEFT JOIN information_schema.parameters p ON r.specific_name = p.specific_name
WHERE r.routine_name IN ('get_simple_user_count', 'get_all_users')
ORDER BY r.routine_name, p.ordinal_position;
