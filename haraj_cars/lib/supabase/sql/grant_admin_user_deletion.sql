-- =============================================
-- GRANT ADMIN PERMISSIONS FOR USER DELETION
-- =============================================
-- This file grants admin permissions to delete users from auth.users
-- Run this script in your Supabase SQL Editor.

-- =============================================
-- GRANT ADMIN PERMISSIONS
-- =============================================

-- Grant permission to delete users from auth.users table
GRANT DELETE ON auth.users TO authenticated;

-- Alternative: Create a function that can delete users with admin privileges
CREATE OR REPLACE FUNCTION delete_user_account(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    -- Check if the current user is an admin
    IF NOT EXISTS (
        SELECT 1 FROM admin 
        WHERE username = auth.jwt() ->> 'email'
    ) THEN
        RAISE EXCEPTION 'User not allowed - Admin access required';
    END IF;
    
    -- Delete the user from auth.users
    DELETE FROM auth.users WHERE id = user_id;
    
    -- Return true if deletion was successful
    RETURN FOUND;
EXCEPTION
    WHEN OTHERS THEN
        -- Log the error and return false
        RAISE LOG 'Error deleting user %: %', user_id, SQLERRM;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission on the delete function to authenticated users
GRANT EXECUTE ON FUNCTION delete_user_account(UUID) TO authenticated;

-- =============================================
-- VERIFICATION
-- =============================================

-- Test the function (uncomment to test)
-- SELECT delete_user_account('user-uuid-here');

-- Check current permissions
SELECT 
    table_schema,
    table_name,
    privilege_type,
    grantee
FROM information_schema.table_privileges 
WHERE table_name = 'users' AND table_schema = 'auth';

-- =============================================
-- NOTES
-- =============================================
-- 1. The first approach grants direct DELETE permission on auth.users
-- 2. The second approach creates a secure function that checks admin status
-- 3. Choose the approach that best fits your security requirements
-- 4. The function approach is more secure as it validates admin status
