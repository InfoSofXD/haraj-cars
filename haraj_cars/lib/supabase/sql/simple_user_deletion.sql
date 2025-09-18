-- =============================================
-- SIMPLE USER DELETION FUNCTION
-- =============================================
-- This file creates a simple function to delete users without admin table dependency
-- Run this script in your Supabase SQL Editor.

-- Drop existing function if it exists
DROP FUNCTION IF EXISTS delete_user_account(UUID);

-- Create a simple user deletion function
CREATE OR REPLACE FUNCTION delete_user_account(user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    -- Delete the user from auth.users
    DELETE FROM auth.users WHERE id = user_id;
    
    -- Get the number of deleted rows
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    -- Return true if at least one row was deleted
    RETURN deleted_count > 0;
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

-- Test the function (uncomment to test with a real user ID)
-- SELECT delete_user_account('user-uuid-here');

-- Check if function was created successfully
SELECT 
    routine_name, 
    routine_type,
    security_type
FROM information_schema.routines 
WHERE routine_name = 'delete_user_account';

-- =============================================
-- NOTES
-- =============================================
-- 1. This function removes the admin table dependency
-- 2. It directly deletes from auth.users table
-- 3. Returns true if deletion was successful, false otherwise
-- 4. Uses SECURITY DEFINER to run with elevated privileges
