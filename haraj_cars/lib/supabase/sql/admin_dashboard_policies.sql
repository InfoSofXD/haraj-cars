-- =============================================
-- ADMIN DASHBOARD POLICIES AND FUNCTIONS
-- =============================================
-- This file contains policies and functions for admin dashboard access
-- Run this script in your Supabase SQL Editor to enable admin dashboard functionality

-- =============================================
-- FIX POSTS TABLE - ADD COMMENTS COLUMN
-- =============================================

-- Add comments count column to posts table
ALTER TABLE posts ADD COLUMN IF NOT EXISTS comments INTEGER DEFAULT 0;

-- Create function to update comments count
CREATE OR REPLACE FUNCTION update_post_comments_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE posts 
        SET comments = comments + 1 
        WHERE id = NEW.post_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE posts 
        SET comments = comments - 1 
        WHERE id = OLD.post_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update comments count
DROP TRIGGER IF EXISTS update_post_comments_count_trigger ON comments;
CREATE TRIGGER update_post_comments_count_trigger
    AFTER INSERT OR DELETE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_post_comments_count();

-- Update existing posts with current comments count
UPDATE posts 
SET comments = (
    SELECT COUNT(*) 
    FROM comments 
    WHERE comments.post_id = posts.id
);

-- =============================================
-- ADMIN POLICIES FOR AUTH USERS ACCESS
-- =============================================

-- Create a function to check if current user is admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    -- Check if current user exists in admin table
    RETURN EXISTS (
        SELECT 1 FROM admin 
        WHERE username = auth.jwt() ->> 'email'
        OR username = auth.jwt() ->> 'preferred_username'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create policies for auth.users access (admin only)
CREATE POLICY "Admins can read auth users" ON auth.users
    FOR SELECT USING (is_admin());

-- =============================================
-- DASHBOARD STATISTICS FUNCTIONS
-- =============================================

-- Function to get total user count
CREATE OR REPLACE FUNCTION get_user_count()
RETURNS INTEGER AS $$
BEGIN
    -- Check if user is admin
    IF NOT is_admin() THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;
    
    RETURN (SELECT COUNT(*) FROM auth.users);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get recent users
CREATE OR REPLACE FUNCTION get_recent_users(limit_count INTEGER DEFAULT 5)
RETURNS TABLE (
    id UUID,
    email TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    last_sign_in TIMESTAMP WITH TIME ZONE,
    email_confirmed BOOLEAN
) AS $$
BEGIN
    -- Check if user is admin
    IF NOT is_admin() THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;
    
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

-- Function to get admin count
CREATE OR REPLACE FUNCTION get_admin_count()
RETURNS INTEGER AS $$
BEGIN
    -- Check if user is admin
    IF NOT is_admin() THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;
    
    RETURN (SELECT COUNT(*) FROM admin);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get recent admins
CREATE OR REPLACE FUNCTION get_recent_admins(limit_count INTEGER DEFAULT 5)
RETURNS TABLE (
    id INTEGER,
    username TEXT,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    -- Check if user is admin
    IF NOT is_admin() THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;
    
    RETURN QUERY
    SELECT 
        a.id,
        a.username,
        a.created_at
    FROM admin a
    ORDER BY a.created_at DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get car statistics
CREATE OR REPLACE FUNCTION get_car_statistics()
RETURNS TABLE (
    total_cars INTEGER,
    available_cars INTEGER,
    auction_cars INTEGER,
    sold_cars INTEGER,
    unavailable_cars INTEGER,
    avg_price NUMERIC
) AS $$
DECLARE
    total_count INTEGER;
    available_count INTEGER;
    auction_count INTEGER;
    sold_count INTEGER;
    unavailable_count INTEGER;
    avg_price_val NUMERIC;
BEGIN
    -- Check if user is admin
    IF NOT is_admin() THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;
    
    -- Get total cars count
    SELECT COUNT(*) INTO total_count FROM cars;
    
    -- Get cars by status (handle both boolean and integer status)
    SELECT COUNT(*) INTO available_count 
    FROM cars 
    WHERE (status = true) OR (status = 1);
    
    SELECT COUNT(*) INTO auction_count 
    FROM cars 
    WHERE status = 3;
    
    SELECT COUNT(*) INTO sold_count 
    FROM cars 
    WHERE status = 4;
    
    SELECT COUNT(*) INTO unavailable_count 
    FROM cars 
    WHERE (status = false) OR (status = 2);
    
    -- Get average price
    SELECT COALESCE(AVG(price), 0) INTO avg_price_val FROM cars;
    
    RETURN QUERY
    SELECT 
        total_count,
        available_count,
        auction_count,
        sold_count,
        unavailable_count,
        avg_price_val;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get recent cars
CREATE OR REPLACE FUNCTION get_recent_cars(limit_count INTEGER DEFAULT 5)
RETURNS TABLE (
    car_id UUID,
    brand TEXT,
    model TEXT,
    year INTEGER,
    price NUMERIC,
    status INTEGER,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    -- Check if user is admin
    IF NOT is_admin() THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;
    
    RETURN QUERY
    SELECT 
        c.car_id,
        c.brand,
        c.model,
        c.year,
        c.price,
        CASE 
            WHEN c.status = true THEN 1
            WHEN c.status = false THEN 2
            ELSE c.status::INTEGER
        END as status,
        c.created_at
    FROM cars c
    ORDER BY c.created_at DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get recent posts
CREATE OR REPLACE FUNCTION get_recent_posts(limit_count INTEGER DEFAULT 5)
RETURNS TABLE (
    id UUID,
    text TEXT,
    likes INTEGER,
    comments INTEGER,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    -- Check if user is admin
    IF NOT is_admin() THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;
    
    RETURN QUERY
    SELECT 
        p.id,
        p.text,
        p.likes,
        p.comments,
        p.created_at
    FROM posts p
    ORDER BY p.created_at DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- GRANT PERMISSIONS
-- =============================================

-- Grant execute permissions on functions to authenticated users
GRANT EXECUTE ON FUNCTION get_user_count() TO authenticated;
GRANT EXECUTE ON FUNCTION get_recent_users(INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION get_admin_count() TO authenticated;
GRANT EXECUTE ON FUNCTION get_recent_admins(INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION get_car_statistics() TO authenticated;
GRANT EXECUTE ON FUNCTION get_recent_cars(INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION get_recent_posts(INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION is_admin() TO authenticated;

-- =============================================
-- VERIFICATION QUERIES
-- =============================================

-- Test the functions (uncomment to test)
-- SELECT get_user_count();
-- SELECT * FROM get_recent_users(3);
-- SELECT get_admin_count();
-- SELECT * FROM get_recent_admins(3);
-- SELECT * FROM get_car_statistics();
-- SELECT * FROM get_recent_cars(3);
-- SELECT * FROM get_recent_posts(3);
