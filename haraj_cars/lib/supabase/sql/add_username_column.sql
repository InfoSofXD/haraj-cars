-- =============================================
-- ADD USERNAME COLUMN TO USERS TABLE
-- =============================================
-- This script adds the username column to the users table
-- Run this in your Supabase SQL Editor

-- Add username column to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS username TEXT UNIQUE;

-- Create index for username for better performance
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

-- Update the create_user_profile function to include username
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO users (id, email, username, full_name, phone, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'username', ''),
        COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'phone', ''),
        COALESCE(NEW.raw_user_meta_data->>'role', 'client')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Insert default admin with username
INSERT INTO users (id, email, username, full_name, phone, role, is_active)
VALUES (
    gen_random_uuid(),
    'admin@harajcars.com',
    'admin',
    'Default Admin',
    '+1234567890',
    'super_admin',
    true
) ON CONFLICT (username) DO NOTHING;

-- Verify the changes
SELECT 'Username column added successfully' as status;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'users' 
AND table_schema = 'public'
AND column_name = 'username';
