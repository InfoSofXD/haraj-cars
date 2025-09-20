-- =============================================
-- SIMPLE USER FUNCTIONS
-- =============================================
-- Simple functions to get users and count them
-- No complex admin policies, just basic functionality

-- =============================================
-- SIMPLE USER COUNT FUNCTION
-- =============================================

CREATE OR REPLACE FUNCTION get_simple_user_count()
RETURNS INTEGER AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM auth.users);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- SIMPLE GET ALL USERS FUNCTION
-- =============================================

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
        u.email,
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
-- SELECT * FROM get_all_users();
