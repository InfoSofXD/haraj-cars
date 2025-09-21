-- Add like tracking columns to posts and comments tables
-- =====================================================

-- Add liked_by column to posts table (JSON array of user IDs)
ALTER TABLE posts ADD COLUMN IF NOT EXISTS liked_by JSONB DEFAULT '[]'::jsonb;

-- Add liked_by column to comments table (JSON array of user IDs)  
ALTER TABLE comments ADD COLUMN IF NOT EXISTS liked_by JSONB DEFAULT '[]'::jsonb;

-- Create indexes for better performance on JSONB columns
CREATE INDEX IF NOT EXISTS idx_posts_liked_by ON posts USING GIN (liked_by);
CREATE INDEX IF NOT EXISTS idx_comments_liked_by ON comments USING GIN (liked_by);

-- Update the like count columns to be computed from liked_by array length
-- (This is optional - you can keep the likes column or remove it)
-- ALTER TABLE posts DROP COLUMN IF EXISTS likes;
-- ALTER TABLE comments DROP COLUMN IF EXISTS likes;

-- Add computed columns for like counts (if you want to keep them)
-- ALTER TABLE posts ADD COLUMN IF NOT EXISTS like_count INTEGER GENERATED ALWAYS AS (jsonb_array_length(liked_by)) STORED;
-- ALTER TABLE comments ADD COLUMN IF NOT EXISTS like_count INTEGER GENERATED ALWAYS AS (jsonb_array_length(liked_by)) STORED;
