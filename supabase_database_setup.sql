-- 🚀 Summer Walker Artist Portal Database Setup
-- Run this in your Supabase SQL Editor
-- This script is safe to run multiple times (idempotent)
-- It will add new columns to existing tables without breaking anything
--
-- 📋 BEFORE RUNNING THIS SCRIPT:
-- 1. Go to Supabase Dashboard → Authentication → Users
-- 2. Find the user you want to make an artist (or create one)
-- 3. Copy their User ID (UUID format)
-- 4. Replace the placeholder UUIDs in this script (search for "REPLACE THIS")
-- 5. Then run this script

-- Create profiles table (will exist already, so this won't modify it)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add new columns to existing profiles table (safe to run multiple times)
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS username TEXT UNIQUE;

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS bio TEXT;

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS avatar_url TEXT;

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS is_artist BOOLEAN DEFAULT false;

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS artist_verified BOOLEAN DEFAULT false;

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS social_links JSONB;

-- Enable Row Level Security (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Users can delete own profile" ON profiles;

-- Create policy to allow users to read their own profile
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

-- Create policy to allow users to update their own profile
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Create policy to allow users to insert their own profile
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Create policy to allow users to delete their own profile
CREATE POLICY "Users can delete own profile" ON profiles
  FOR DELETE USING (auth.uid() = id);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_profiles_updated_at 
    BEFORE UPDATE ON profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Create artist_stats table for tracking artist performance
CREATE TABLE IF NOT EXISTS artist_stats (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  artist_id UUID REFERENCES auth.users(id) NOT NULL,
  total_followers INTEGER DEFAULT 0,
  total_likes INTEGER DEFAULT 0,
  total_views INTEGER DEFAULT 0,
  total_revenue DECIMAL(10,2) DEFAULT 0.00,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on artist_stats table
ALTER TABLE artist_stats ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Artists can view own stats" ON artist_stats;
DROP POLICY IF EXISTS "Artists can update own stats" ON artist_stats;

-- Create policies for artist_stats table
CREATE POLICY "Artists can view own stats" ON artist_stats
  FOR SELECT USING (auth.uid() = artist_id);

CREATE POLICY "Artists can update own stats" ON artist_stats
  FOR UPDATE USING (auth.uid() = artist_id);

-- Create trigger for artist_stats table
CREATE TRIGGER update_artist_stats_updated_at 
    BEFORE UPDATE ON artist_stats 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Optional: Create additional tables for future features

-- Create content table for premium content
CREATE TABLE IF NOT EXISTS content (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  content_type TEXT NOT NULL, -- 'video', 'audio', 'image', 'text'
  file_url TEXT,
  thumbnail_url TEXT,
  is_premium BOOLEAN DEFAULT false,
  price DECIMAL(10,2),
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on content table
ALTER TABLE content ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Content creators can manage their content" ON content;
DROP POLICY IF EXISTS "Users can view public content" ON content;

-- Create policies for content table
CREATE POLICY "Content creators can manage their content" ON content
  FOR ALL USING (auth.uid() = created_by);

CREATE POLICY "Users can view public content" ON content
  FOR SELECT USING (is_premium = false);

-- Create user subscriptions table
CREATE TABLE IF NOT EXISTS user_subscriptions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  subscription_type TEXT NOT NULL, -- 'monthly', 'yearly', 'lifetime'
  status TEXT NOT NULL, -- 'active', 'cancelled', 'expired'
  start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  end_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on subscriptions table
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own subscriptions" ON user_subscriptions;
DROP POLICY IF EXISTS "Users can manage own subscriptions" ON user_subscriptions;

-- Create policies for subscriptions table
CREATE POLICY "Users can view own subscriptions" ON user_subscriptions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own subscriptions" ON user_subscriptions
  FOR ALL USING (auth.uid() = user_id);

-- Create trigger for content table
CREATE TRIGGER update_content_updated_at 
    BEFORE UPDATE ON content 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Create trigger for subscriptions table
CREATE TRIGGER update_subscriptions_updated_at 
    BEFORE UPDATE ON user_subscriptions 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Insert default artist profile for Summer Walker
-- ⚠️  IMPORTANT: Replace the user ID below with an actual user ID from your auth.users table
-- To find a user ID: Go to Supabase Dashboard → Authentication → Users → Copy the ID
INSERT INTO profiles (id, full_name, username, email, bio, is_artist, artist_verified, social_links)
VALUES (
  '965e834a-54b9-432b-b7e3-e4ddab55dc5a', -- ⚠️  REPLACE THIS WITH REAL USER ID
  'Summer Walker',
  'summerwalker',
  'admin@atreehousegroup.com',
  'Grammy-nominated R&B artist and songwriter',
  true,
  true,
  '{"instagram": "summerwalker", "twitter": "summerwalker", "tiktok": "summerwalker"}'
);

-- Insert default artist stats
-- ⚠️  IMPORTANT: Use the same user ID as above
INSERT INTO artist_stats (artist_id, total_followers, total_likes, total_views, total_revenue)
VALUES (
  '965e834a-54b9-432b-b7e3-e4ddab55dc5a', -- ⚠️  REPLACE THIS WITH REAL USER ID
  2800000,
  156000,
  89000000,
  2500000.00
);

-- Success message
SELECT '🎉 Summer Walker Artist Portal database setup complete!' as status;
