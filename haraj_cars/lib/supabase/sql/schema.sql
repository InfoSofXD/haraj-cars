-- Create cars table
CREATE TABLE IF NOT EXISTS cars (
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

-- Create admin table
CREATE TABLE IF NOT EXISTS admin (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default admin user (username: admin, password: admin123)
INSERT INTO admin (username, password) VALUES ('admin', 'admin123') ON CONFLICT (username) DO NOTHING;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_cars_title ON cars(title);
CREATE INDEX IF NOT EXISTS idx_cars_price ON cars(price);
CREATE INDEX IF NOT EXISTS idx_cars_created_at ON cars(created_at);

-- Enable Row Level Security (RLS)
ALTER TABLE cars ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin ENABLE ROW LEVEL SECURITY;

-- Create policies for cars table (allow read for everyone, write for authenticated users)
CREATE POLICY "Allow public read access" ON cars FOR SELECT USING (true);
CREATE POLICY "Allow authenticated insert" ON cars FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow authenticated update" ON cars FOR UPDATE USING (true);
CREATE POLICY "Allow authenticated delete" ON cars FOR DELETE USING (true);

-- Create policies for admin table (allow read for everyone, write for authenticated users)
CREATE POLICY "Allow public read access" ON admin FOR SELECT USING (true);
CREATE POLICY "Allow authenticated insert" ON admin FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow authenticated update" ON admin FOR UPDATE USING (true);
CREATE POLICY "Allow authenticated delete" ON admin FOR DELETE USING (true); 