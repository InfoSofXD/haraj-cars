-- =============================================
-- UPDATE USER FUNCTIONS TO INCLUDE METADATA
-- =============================================
-- This file updates the user functions to include real name and phone from user metadata
-- Run this script in your Supabase SQL Editor.

-- Drop existing functions
DROP FUNCTION IF EXISTS get_simple_user_count();
DROP FUNCTION IF EXISTS get_all_users();

-- Function to get total user count
CREATE OR REPLACE FUNCTION get_simple_user_count()
RETURNS INTEGER AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM auth.users);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get all users with metadata
CREATE OR REPLACE FUNCTION get_all_users()
RETURNS TABLE (
    id UUID,
    email TEXT,
    full_name TEXT,
    phone TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    last_sign_in TIMESTAMP WITH TIME ZONE,
    email_confirmed BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.id,
        u.email::TEXT,
        COALESCE(u.raw_user_meta_data->>'full_name', 'Not provided')::TEXT as full_name,
        COALESCE(u.raw_user_meta_data->>'phone', 'Not provided')::TEXT as phone,
        u.created_at,
        u.last_sign_in_at,
        (u.email_confirmed_at IS NOT NULL) as email_confirmed
    FROM auth.users u
    ORDER BY u.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions on functions to authenticated users
GRANT EXECUTE ON FUNCTION get_simple_user_count() TO authenticated;
GRANT EXECUTE ON FUNCTION get_all_users() TO authenticated;

-- =============================================
-- VERIFICATION
-- =============================================

-- Test the functions
SELECT 'User count:' as info, get_simple_user_count() as count;
SELECT 'Sample users with metadata:' as info;
SELECT * FROM get_all_users() LIMIT 3;
