-- Fix cars table if there are constraint issues
-- Run this in your Supabase SQL Editor if you're getting id constraint errors

-- Drop and recreate the cars table with proper constraints
DROP TABLE IF EXISTS cars CASCADE;

CREATE TABLE cars (
    id SERIAL PRIMARY KEY,
    car_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'SAR',
    brand VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    year INTEGER NOT NULL,
    mileage INTEGER NOT NULL,
    transmission VARCHAR(20) NOT NULL,
    fuel_type VARCHAR(20) NOT NULL,
    engine_size VARCHAR(20) NOT NULL,
    horsepower INTEGER NOT NULL,
    drive_type VARCHAR(10) NOT NULL,
    exterior_color VARCHAR(50) NOT NULL,
    interior_color VARCHAR(50) NOT NULL,
    doors INTEGER NOT NULL,
    seats INTEGER NOT NULL,
    main_image TEXT,
    other_images TEXT[],
    contact VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_cars_price ON cars(price);
CREATE INDEX idx_cars_created_at ON cars(created_at);

-- Enable Row Level Security (RLS)
ALTER TABLE cars ENABLE ROW LEVEL SECURITY;

-- Create policies for cars table
CREATE POLICY "Allow public read access" ON cars FOR SELECT USING (true);
CREATE POLICY "Allow public insert" ON cars FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update" ON cars FOR UPDATE USING (true);
CREATE POLICY "Allow public delete" ON cars FOR DELETE USING (true);

-- Insert sample cars with brand names directly
INSERT INTO cars (car_id, description, price, currency, brand, model, year, mileage, transmission, fuel_type, engine_size, horsepower, drive_type, exterior_color, interior_color, doors, seats, contact) VALUES
    (gen_random_uuid(), 'Excellent condition Toyota Corolla with low mileage', 45000, 'SAR', 'Toyota', 'Corolla', 2018, 45000, 'Automatic', 'Petrol', '1.8L', 140, 'FWD', 'White', 'Black', 4, 5, '+966501234567'),
    (gen_random_uuid(), 'Well maintained Honda Civic with full service history', 52000, 'SAR', 'Honda', 'Civic', 2019, 38000, 'Automatic', 'Petrol', '1.5L', 130, 'FWD', 'Silver', 'Gray', 4, 5, '+966502345678'),
    (gen_random_uuid(), 'Luxury BMW X5 in perfect condition', 180000, 'SAR', 'BMW', 'X5', 2020, 25000, 'Automatic', 'Petrol', '3.0L', 340, 'AWD', 'Black', 'Beige', 5, 7, '+966503456789'),
    (gen_random_uuid(), 'Reliable Nissan Altima with great fuel economy', 48000, 'SAR', 'Nissan', 'Altima', 2018, 52000, 'Automatic', 'Petrol', '2.5L', 182, 'FWD', 'Blue', 'Black', 4, 5, '+966504567890'),
    (gen_random_uuid(), 'Sporty Mazda CX-5 with premium features', 75000, 'SAR', 'Mazda', 'CX-5', 2021, 18000, 'Automatic', 'Petrol', '2.5L', 187, 'AWD', 'Red', 'Black', 5, 5, '+966505678901');
