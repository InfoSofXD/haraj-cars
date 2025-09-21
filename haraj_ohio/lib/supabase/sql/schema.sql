-- =============================================
-- HARAJ CARS DATABASE SCHEMA
-- =============================================
-- This file contains the complete database schema for the Haraj Cars application
-- Run this script in your Supabase SQL Editor to set up the entire database

-- =============================================
-- TABLES CREATION
-- =============================================

-- Cars table - Main table for storing car listings
CREATE TABLE IF NOT EXISTS cars (
    id SERIAL PRIMARY KEY,
    car_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL,
    brand TEXT NOT NULL,
    model TEXT NOT NULL,
    year INTEGER NOT NULL,
    mileage INTEGER NOT NULL,
    transmission TEXT NOT NULL,
    fuel_type TEXT NOT NULL,
    engine TEXT NOT NULL,
    horsepower INTEGER NOT NULL,
    drive_type TEXT NOT NULL,
    exterior_color TEXT NOT NULL,
    interior_color TEXT NOT NULL,
    doors INTEGER NOT NULL,
    seats INTEGER NOT NULL,
    main_image TEXT,
    other_images TEXT[],
    contact TEXT NOT NULL,
    vin TEXT,
    show_at TIMESTAMP WITH TIME ZONE,
    un_show_at TIMESTAMP WITH TIME ZONE,
    auction_start_at TIMESTAMP WITH TIME ZONE,
    auction_end_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    delete_at TIMESTAMP WITH TIME ZONE,
    status BOOLEAN DEFAULT true
);

-- Brands table - Reference table for car brands
CREATE TABLE IF NOT EXISTS brands (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Admin table - For admin user management
CREATE TABLE IF NOT EXISTS admin (
    id SERIAL PRIMARY KEY,
    username VARCHAR NOT NULL,
    password VARCHAR NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- SAMPLE DATA INSERTION
-- =============================================

-- Insert popular car brands
INSERT INTO brands (name) VALUES 
    ('Toyota'),
    ('Honda'),
    ('Nissan'),
    ('Mazda'),
    ('Subaru'),
    ('Mitsubishi'),
    ('Lexus'),
    ('Infiniti'),
    ('Acura'),
    ('BMW'),
    ('Mercedes-Benz'),
    ('Audi'),
    ('Volkswagen'),
    ('Porsche'),
    ('Volvo'),
    ('Ford'),
    ('Chevrolet'),
    ('Dodge'),
    ('Jeep'),
    ('Hyundai')
ON CONFLICT (name) DO NOTHING;

-- Insert default admin user
INSERT INTO admin (username, password) VALUES ('admin', 'admin123') ON CONFLICT (username) DO NOTHING;

-- Insert sample cars
INSERT INTO cars (car_id, description, price, brand, model, year, mileage, transmission, fuel_type, engine, horsepower, drive_type, exterior_color, interior_color, doors, seats, contact, vin, status) VALUES
    (gen_random_uuid(), 'Excellent condition Toyota Corolla with low mileage', 45000, 'Toyota', 'Corolla', 2018, 45000, 'Automatic', 'Petrol', '1.8L', 140, 'FWD', 'White', 'Black', 4, 5, '+966501234567', '1HGBH41JXMN109186', true),
    (gen_random_uuid(), 'Well maintained Honda Civic with full service history', 52000, 'Honda', 'Civic', 2019, 38000, 'Automatic', 'Petrol', '1.5L', 130, 'FWD', 'Silver', 'Gray', 4, 5, '+966502345678', '2HGBH41JXMN109187', true),
    (gen_random_uuid(), 'Luxury BMW X5 in perfect condition', 180000, 'BMW', 'X5', 2020, 25000, 'Automatic', 'Petrol', '3.0L', 340, 'AWD', 'Black', 'Beige', 5, 7, '+966503456789', '3HGBH41JXMN109188', true),
    (gen_random_uuid(), 'Reliable Nissan Altima with great fuel economy', 48000, 'Nissan', 'Altima', 2018, 52000, 'Automatic', 'Petrol', '2.5L', 182, 'FWD', 'Blue', 'Black', 4, 5, '+966504567890', '4HGBH41JXMN109189', true),
    (gen_random_uuid(), 'Sporty Mazda CX-5 with premium features', 75000, 'Mazda', 'CX-5', 2021, 18000, 'Automatic', 'Petrol', '2.5L', 187, 'AWD', 'Red', 'Black', 5, 5, '+966505678901', '5HGBH41JXMN109190', true);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

-- Cars table indexes
CREATE INDEX IF NOT EXISTS idx_cars_price ON cars(price);
CREATE INDEX IF NOT EXISTS idx_cars_created_at ON cars(created_at);
CREATE INDEX IF NOT EXISTS idx_cars_brand ON cars(brand);
CREATE INDEX IF NOT EXISTS idx_cars_model ON cars(model);
CREATE INDEX IF NOT EXISTS idx_cars_year ON cars(year);
CREATE INDEX IF NOT EXISTS idx_cars_status ON cars(status);

-- Brands table indexes
CREATE INDEX IF NOT EXISTS idx_brands_name ON brands(name);

-- =============================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================

-- Enable RLS on all tables
ALTER TABLE cars ENABLE ROW LEVEL SECURITY;
ALTER TABLE brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin ENABLE ROW LEVEL SECURITY;

-- =============================================
-- SECURITY POLICIES
-- =============================================

-- Cars table policies
CREATE POLICY "Allow public read access" ON cars FOR SELECT USING (true);
CREATE POLICY "Allow authenticated insert" ON cars FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow authenticated update" ON cars FOR UPDATE USING (true);
CREATE POLICY "Allow authenticated delete" ON cars FOR DELETE USING (true);

-- Brands table policies (read-only for public)
CREATE POLICY "Allow public read access" ON brands FOR SELECT USING (true);

-- Admin table policies
CREATE POLICY "Allow public read access" ON admin FOR SELECT USING (true);
CREATE POLICY "Allow authenticated insert" ON admin FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow authenticated update" ON admin FOR UPDATE USING (true);
CREATE POLICY "Allow authenticated delete" ON admin FOR DELETE USING (true);

-- =============================================
-- STORAGE SETUP
-- =============================================

-- Create storage bucket for car images
INSERT INTO storage.buckets (id, name, public) 
VALUES ('car-images', 'car-images', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for car images
CREATE POLICY "Public Access" ON storage.objects
FOR SELECT USING (bucket_id = 'car-images');

CREATE POLICY "Authenticated users can upload" ON storage.objects
FOR INSERT WITH CHECK (bucket_id = 'car-images');

CREATE POLICY "Authenticated users can update" ON storage.objects
FOR UPDATE USING (bucket_id = 'car-images');

CREATE POLICY "Authenticated users can delete" ON storage.objects
FOR DELETE USING (bucket_id = 'car-images');

-- =============================================
-- VERIFICATION QUERIES
-- =============================================

-- Uncomment the following queries to verify the setup:

-- Check if all tables exist
-- SELECT table_name 
-- FROM information_schema.tables 
-- WHERE table_schema = 'public' 
-- AND table_name IN ('cars', 'brands', 'admin');

-- Check cars table structure
-- SELECT column_name, data_type, is_nullable
-- FROM information_schema.columns 
-- WHERE table_name = 'cars' 
-- AND table_schema = 'public';

-- Check brands table structure
-- SELECT column_name, data_type, is_nullable
-- FROM information_schema.columns 
-- WHERE table_name = 'brands' 
-- AND table_schema = 'public';

-- Check admin table structure
-- SELECT column_name, data_type, is_nullable
-- FROM information_schema.columns 
-- WHERE table_name = 'admin' 
-- AND table_schema = 'public';

-- Check RLS policies
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
-- FROM pg_policies 
-- WHERE tablename IN ('cars', 'brands', 'admin');