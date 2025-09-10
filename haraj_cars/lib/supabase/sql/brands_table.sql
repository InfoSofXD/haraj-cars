-- Create brands table
CREATE TABLE IF NOT EXISTS brands (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert 20 popular car brands
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

-- Enable Row Level Security
ALTER TABLE brands ENABLE ROW LEVEL SECURITY;

-- Create policies for brands table (allow read for everyone)
CREATE POLICY "Allow public read access" ON brands FOR SELECT USING (true);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_brands_name ON brands(name); 