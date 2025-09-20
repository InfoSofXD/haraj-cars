-- =============================================
-- ENHANCED ADMIN SECURITY
-- =============================================
-- This file contains enhanced security measures for admin dashboard access
-- Run this AFTER the main admin_dashboard_policies.sql

-- =============================================
-- ENHANCED ADMIN AUTHENTICATION
-- =============================================

-- Drop and recreate with enhanced security
DROP FUNCTION IF EXISTS is_admin();

CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
DECLARE
    user_email TEXT;
    user_role TEXT;
    admin_exists BOOLEAN;
BEGIN
    -- Check if user is authenticated
    user_role := auth.role();
    IF user_role != 'authenticated' THEN
        RETURN FALSE;
    END IF;
    
    -- Get user email from JWT
    user_email := auth.jwt() ->> 'email';
    IF user_email IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Check if user exists in admin table with additional validation
    SELECT EXISTS(
        SELECT 1 FROM admin 
        WHERE username = user_email
        AND created_at IS NOT NULL
        AND username IS NOT NULL
    ) INTO admin_exists;
    
    RETURN admin_exists;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- AUDIT LOGGING
-- =============================================

-- Create audit log table
CREATE TABLE IF NOT EXISTS admin_audit_log (
    id SERIAL PRIMARY KEY,
    admin_email TEXT NOT NULL,
    action TEXT NOT NULL,
    function_name TEXT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ip_address INET,
    user_agent TEXT
);

-- Enable RLS on audit log
ALTER TABLE admin_audit_log ENABLE ROW LEVEL SECURITY;

-- Only admins can read audit logs
CREATE POLICY "Admins can read audit logs" ON admin_audit_log
    FOR SELECT USING (is_admin());

-- Function to log admin actions
CREATE OR REPLACE FUNCTION log_admin_action(
    action_name TEXT,
    function_name TEXT
)
RETURNS VOID AS $$
DECLARE
    admin_email TEXT;
BEGIN
    -- Only log if user is admin
    IF is_admin() THEN
        admin_email := auth.jwt() ->> 'email';
        
        INSERT INTO admin_audit_log (admin_email, action, function_name)
        VALUES (admin_email, action_name, function_name);
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- ENHANCED DASHBOARD FUNCTIONS WITH AUDIT
-- =============================================

-- Enhanced user count function with audit
CREATE OR REPLACE FUNCTION get_user_count()
RETURNS INTEGER AS $$
DECLARE
    user_count INTEGER;
BEGIN
    -- Check admin privileges
    IF NOT is_admin() THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;
    
    -- Log the action
    PERFORM log_admin_action('VIEW_USER_COUNT', 'get_user_count');
    
    -- Get user count
    SELECT COUNT(*) INTO user_count FROM auth.users;
    
    RETURN user_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enhanced recent users function with audit
CREATE OR REPLACE FUNCTION get_recent_users(limit_count INTEGER DEFAULT 5)
RETURNS TABLE (
    id UUID,
    email TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    last_sign_in TIMESTAMP WITH TIME ZONE,
    email_confirmed BOOLEAN
) AS $$
BEGIN
    -- Check admin privileges
    IF NOT is_admin() THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;
    
    -- Log the action
    PERFORM log_admin_action('VIEW_RECENT_USERS', 'get_recent_users');
    
    -- Return recent users
    RETURN QUERY
    SELECT 
        u.id,
        u.email,
        u.created_at,
        u.last_sign_in_at,
        (u.email_confirmed_at IS NOT NULL) as email_confirmed
    FROM auth.users u
    ORDER BY u.created_at DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- RATE LIMITING
-- =============================================

-- Create rate limiting table
CREATE TABLE IF NOT EXISTS admin_rate_limit (
    admin_email TEXT PRIMARY KEY,
    request_count INTEGER DEFAULT 1,
    last_request TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    blocked_until TIMESTAMP WITH TIME ZONE
);

-- Function to check rate limit
CREATE OR REPLACE FUNCTION check_rate_limit()
RETURNS BOOLEAN AS $$
DECLARE
    admin_email TEXT;
    current_time TIMESTAMP WITH TIME ZONE;
    rate_limit_record RECORD;
    max_requests INTEGER := 100; -- Max 100 requests per hour
    time_window INTERVAL := '1 hour';
BEGIN
    admin_email := auth.jwt() ->> 'email';
    current_time := NOW();
    
    -- Get current rate limit record
    SELECT * INTO rate_limit_record 
    FROM admin_rate_limit 
    WHERE admin_email = check_rate_limit.admin_email;
    
    -- If no record exists, create one
    IF NOT FOUND THEN
        INSERT INTO admin_rate_limit (admin_email, request_count, last_request)
        VALUES (admin_email, 1, current_time);
        RETURN TRUE;
    END IF;
    
    -- Check if admin is blocked
    IF rate_limit_record.blocked_until IS NOT NULL AND 
       current_time < rate_limit_record.blocked_until THEN
        RETURN FALSE;
    END IF;
    
    -- Reset if time window has passed
    IF current_time - rate_limit_record.last_request > time_window THEN
        UPDATE admin_rate_limit 
        SET request_count = 1, last_request = current_time, blocked_until = NULL
        WHERE admin_email = check_rate_limit.admin_email;
        RETURN TRUE;
    END IF;
    
    -- Check if limit exceeded
    IF rate_limit_record.request_count >= max_requests THEN
        UPDATE admin_rate_limit 
        SET blocked_until = current_time + INTERVAL '1 hour'
        WHERE admin_email = check_rate_limit.admin_email;
        RETURN FALSE;
    END IF;
    
    -- Increment request count
    UPDATE admin_rate_limit 
    SET request_count = request_count + 1, last_request = current_time
    WHERE admin_email = check_rate_limit.admin_email;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- ENHANCED SECURITY POLICIES
-- =============================================

-- Enhanced admin table security
CREATE POLICY "Only admins can read admin table" ON admin
    FOR SELECT USING (is_admin());

-- Enhanced audit log security
CREATE POLICY "Only admins can read audit logs" ON admin_audit_log
    FOR SELECT USING (is_admin());

-- =============================================
-- SECURITY MONITORING
-- =============================================

-- Function to get security alerts
CREATE OR REPLACE FUNCTION get_security_alerts()
RETURNS TABLE (
    alert_type TEXT,
    message TEXT,
    severity TEXT,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    -- Check admin privileges
    IF NOT is_admin() THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;
    
    -- Return security alerts (you can customize these)
    RETURN QUERY
    SELECT 
        'Failed Login Attempts' as alert_type,
        'Multiple failed admin login attempts detected' as message,
        'HIGH' as severity,
        NOW() - INTERVAL '1 hour' as created_at
    WHERE EXISTS (
        SELECT 1 FROM admin_audit_log 
        WHERE action = 'FAILED_LOGIN' 
        AND timestamp > NOW() - INTERVAL '1 hour'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- GRANT PERMISSIONS
-- =============================================

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION log_admin_action(TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION check_rate_limit() TO authenticated;
GRANT EXECUTE ON FUNCTION get_security_alerts() TO authenticated;

-- =============================================
-- VERIFICATION
-- =============================================

-- Test enhanced security (uncomment to test)
-- SELECT is_admin();
-- SELECT check_rate_limit();
-- SELECT * FROM get_security_alerts();
