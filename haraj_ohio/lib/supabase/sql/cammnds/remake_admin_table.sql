-- =============================================
-- REMAKE ADMIN TABLE
-- =============================================
-- This script drops the old admin table and creates a new admins table
-- Run this single command in your Supabase SQL Editor

-- Drop the old admin table
DROP TABLE IF EXISTS admin CASCADE;

-- Create new admins table
CREATE TABLE admins (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_sign_in TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_admins_email ON admins(email);
CREATE INDEX idx_admins_phone ON admins(phone);
CREATE INDEX idx_admins_created_at ON admins(created_at);
CREATE INDEX idx_admins_last_sign_in ON admins(last_sign_in);

-- Enable RLS on admins table
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for admins table
CREATE POLICY "Allow public read access for auth" ON admins
    FOR SELECT 
    USING (true);

CREATE POLICY "Allow authenticated users to insert admins" ON admins
    FOR INSERT 
    WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update admins" ON admins
    FOR UPDATE 
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow authenticated users to delete admins" ON admins
    FOR DELETE 
    USING (true);

-- Insert default admin user
INSERT INTO admins (name, phone, email, password) VALUES 
    ('System Administrator', '+966501234567', 'admin@harajcars.com', 'admin123')
ON CONFLICT (email) DO NOTHING;

-- Create function to update last_sign_in timestamp for admins
CREATE OR REPLACE FUNCTION update_admin_last_sign_in(admin_email VARCHAR)
RETURNS VOID AS $$
BEGIN
    UPDATE admins 
    SET last_sign_in = NOW(), updated_at = NOW()
    WHERE email = admin_email;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to authenticate admin
CREATE OR REPLACE FUNCTION authenticate_admin(email_param VARCHAR, password_param VARCHAR)
RETURNS TABLE(
    admin_id INTEGER,
    admin_name VARCHAR,
    admin_email VARCHAR,
    admin_phone VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id,
        a.name,
        a.email,
        a.phone
    FROM admins a
    WHERE a.email = email_param 
    AND a.password = password_param;
    
    -- Update last sign in
    PERFORM update_admin_last_sign_in(email_param);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
