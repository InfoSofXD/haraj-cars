-- =============================================
-- UPDATE STATUS SCHEMA TO INTEGER
-- =============================================
-- This script updates the cars table status column from boolean to integer
-- Run this in your Supabase SQL Editor

-- First, add a new integer status column
ALTER TABLE cars ADD COLUMN status_int INTEGER DEFAULT 1;

-- Update the new column based on the old boolean status
-- true = 1 (available), false = 2 (unavailable)
UPDATE cars SET status_int = CASE 
  WHEN status = true THEN 1 
  WHEN status = false THEN 2 
  ELSE 1 
END;

-- Drop the old boolean status column
ALTER TABLE cars DROP COLUMN status;

-- Rename the new column to status
ALTER TABLE cars RENAME COLUMN status_int TO status;

-- Add a check constraint to ensure valid status values
ALTER TABLE cars ADD CONSTRAINT check_status 
CHECK (status IN (1, 2, 3, 4));

-- Add a comment to document the status values
COMMENT ON COLUMN cars.status IS 'Car status: 1=Available, 2=Unavailable, 3=Auction, 4=Sold';

-- Update the index to use the new status column
DROP INDEX IF EXISTS idx_cars_status;
CREATE INDEX idx_cars_status ON cars(status);
