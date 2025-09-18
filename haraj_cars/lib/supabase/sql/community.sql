-- Community Posts and Comments Tables
-- =====================================

-- Create posts table
CREATE TABLE IF NOT EXISTS posts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    images TEXT[] DEFAULT '{}', -- Array of image URLs
    text TEXT NOT NULL,
    likes INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create comments table
CREATE TABLE IF NOT EXISTS comments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    comment TEXT NOT NULL,
    likes INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create posts_images storage bucket
INSERT INTO storage.buckets (id, name, public) 
VALUES ('posts-images', 'posts-images', true)
ON CONFLICT (id) DO NOTHING;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_comments_post_id ON comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_user_id ON comments(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON comments(created_at DESC);

-- Row Level Security (RLS) Policies
-- =================================

-- Enable RLS on posts table
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Enable RLS on comments table
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- Posts policies
-- Anyone can read posts
CREATE POLICY "Anyone can read posts" ON posts
    FOR SELECT USING (true);

-- Only authenticated users can insert posts
CREATE POLICY "Authenticated users can create posts" ON posts
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Only post creators can update their posts
CREATE POLICY "Users can update their own posts" ON posts
    FOR UPDATE USING (auth.uid() = created_by);

-- Only post creators can delete their posts
CREATE POLICY "Users can delete their own posts" ON posts
    FOR DELETE USING (auth.uid() = created_by);

-- Comments policies
-- Anyone can read comments
CREATE POLICY "Anyone can read comments" ON comments
    FOR SELECT USING (true);

-- Only authenticated users can insert comments
CREATE POLICY "Authenticated users can create comments" ON comments
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Only comment creators can update their comments
CREATE POLICY "Users can update their own comments" ON comments
    FOR UPDATE USING (auth.uid() = user_id);

-- Only comment creators can delete their comments
CREATE POLICY "Users can delete their own comments" ON comments
    FOR DELETE USING (auth.uid() = user_id);

-- Storage policies for posts-images bucket
-- =======================================

-- Anyone can view images
CREATE POLICY "Anyone can view post images" ON storage.objects
    FOR SELECT USING (bucket_id = 'posts-images');

-- Only authenticated users can upload images
CREATE POLICY "Authenticated users can upload post images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'posts-images' 
        AND auth.role() = 'authenticated'
    );

-- Only authenticated users can update their own images
CREATE POLICY "Users can update their own post images" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'posts-images' 
        AND auth.role() = 'authenticated'
    );

-- Only authenticated users can delete their own images
CREATE POLICY "Users can delete their own post images" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'posts-images' 
        AND auth.role() = 'authenticated'
    );

-- Functions for updating timestamps
-- =================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers to automatically update updated_at
CREATE TRIGGER update_posts_updated_at 
    BEFORE UPDATE ON posts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at 
    BEFORE UPDATE ON comments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to handle post likes
-- ============================

CREATE OR REPLACE FUNCTION increment_post_likes(post_uuid UUID)
RETURNS INTEGER AS $$
DECLARE
    new_likes INTEGER;
BEGIN
    UPDATE posts 
    SET likes = likes + 1 
    WHERE id = post_uuid 
    RETURNING likes INTO new_likes;
    
    RETURN COALESCE(new_likes, 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to handle comment likes
-- ================================

CREATE OR REPLACE FUNCTION increment_comment_likes(comment_uuid UUID)
RETURNS INTEGER AS $$
DECLARE
    new_likes INTEGER;
BEGIN
    UPDATE comments 
    SET likes = likes + 1 
    WHERE id = comment_uuid 
    RETURNING likes INTO new_likes;
    
    RETURN COALESCE(new_likes, 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
