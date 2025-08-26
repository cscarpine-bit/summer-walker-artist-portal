-- 🚀 Summer Walker Artist Portal Database Setup
-- Run this in your Supabase SQL Editor

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  bio TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to read their own profile
CREATE POLICY IF NOT EXISTS "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

-- Create policy to allow users to update their own profile
CREATE POLICY IF NOT EXISTS "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Create policy to allow users to insert their own profile
CREATE POLICY IF NOT EXISTS "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Create policy to allow users to delete their own profile
CREATE POLICY IF NOT EXISTS "Users can delete own profile" ON profiles
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

-- Create policies for content table
CREATE POLICY IF NOT EXISTS "Content creators can manage their content" ON content
  FOR ALL USING (auth.uid() = created_by);

CREATE POLICY IF NOT EXISTS "Users can view public content" ON content
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

-- Create policies for subscriptions table
CREATE POLICY IF NOT EXISTS "Users can view own subscriptions" ON user_subscriptions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can manage own subscriptions" ON user_subscriptions
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

-- Success message
SELECT '🎉 Summer Walker Artist Portal database setup complete!' as status;
