-- ============================================================
-- NoteShare Supabase Database Schema
-- Designed for single-college launch with multi-college scaling
-- Safe to run multiple times (fully idempotent)
-- ============================================================

-- ─── COLLEGES TABLE ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS colleges (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  city TEXT,
  state TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed default college (safe to re-run)
INSERT INTO colleges (id, name, city, state)
VALUES ('rcoem', 'RCOEM, Nagpur', 'Nagpur', 'Maharashtra')
ON CONFLICT (id) DO NOTHING;

-- ─── USERS TABLE ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  avatar_url TEXT DEFAULT '',
  college TEXT NOT NULL REFERENCES colleges(id),
  branch TEXT NOT NULL,
  semester TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'student',          -- student | admin
  upload_count INT DEFAULT 0,
  download_count INT DEFAULT 0,
  rating DOUBLE PRECISION DEFAULT 0.0,
  points INT DEFAULT 0,
  rank INT DEFAULT 0,
  community_score INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── NOTES TABLE ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  subject TEXT NOT NULL,
  semester TEXT NOT NULL,
  branch TEXT NOT NULL,
  college TEXT NOT NULL REFERENCES colleges(id),
  description TEXT DEFAULT '',
  uploader_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  uploader_name TEXT NOT NULL,
  uploader_avatar TEXT DEFAULT '',
  uploader_branch TEXT DEFAULT '',
  uploader_semester TEXT DEFAULT '',
  rating DOUBLE PRECISION DEFAULT 0.0,
  download_count INT DEFAULT 0,
  review_count INT DEFAULT 0,
  file_url TEXT,
  preview_url TEXT,
  file_type TEXT NOT NULL DEFAULT 'pdf',       -- pdf | image | document
  status TEXT NOT NULL DEFAULT 'pending',       -- pending | approved | rejected
  category TEXT NOT NULL DEFAULT 'regular',     -- regular | shortNotes | importantQuestions | previousYearPapers
  upload_date TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for fast filtering
CREATE INDEX IF NOT EXISTS idx_notes_college   ON notes(college);
CREATE INDEX IF NOT EXISTS idx_notes_branch    ON notes(branch);
CREATE INDEX IF NOT EXISTS idx_notes_semester  ON notes(semester);
CREATE INDEX IF NOT EXISTS idx_notes_subject   ON notes(subject);
CREATE INDEX IF NOT EXISTS idx_notes_status    ON notes(status);
CREATE INDEX IF NOT EXISTS idx_notes_category  ON notes(category);
CREATE INDEX IF NOT EXISTS idx_notes_uploader  ON notes(uploader_id);
CREATE INDEX IF NOT EXISTS idx_notes_downloads ON notes(download_count DESC);

-- ─── DOWNLOADS TABLE ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS downloads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  note_id UUID NOT NULL REFERENCES notes(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  download_date TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_downloads_note ON downloads(note_id);
CREATE INDEX IF NOT EXISTS idx_downloads_user ON downloads(user_id);

-- ─── SAVED NOTES TABLE ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS saved_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  note_id UUID NOT NULL REFERENCES notes(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  saved_date TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(note_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_saved_notes_user ON saved_notes(user_id);

-- ─── REVIEWS TABLE ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  note_id UUID NOT NULL REFERENCES notes(id) ON DELETE CASCADE,
  reviewer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  reviewer_name TEXT NOT NULL,
  reviewer_avatar TEXT DEFAULT '',
  rating DOUBLE PRECISION NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT DEFAULT '',
  date TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reviews_note     ON reviews(note_id);
CREATE INDEX IF NOT EXISTS idx_reviews_reviewer ON reviews(reviewer_id);

-- ─── HELPER FUNCTIONS ───────────────────────────────────────

-- Increment download count on a note
CREATE OR REPLACE FUNCTION increment_download_count(note_id_param UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE notes SET download_count = download_count + 1 WHERE id = note_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Increment upload count for a user
CREATE OR REPLACE FUNCTION increment_upload_count(user_id_param UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE users SET upload_count = upload_count + 1 WHERE id = user_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if current user is admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recalculate user points:
--   points = (upload_count * 10) + (total downloads received * 2) + community_score
CREATE OR REPLACE FUNCTION recalculate_user_points(user_id_param UUID)
RETURNS VOID AS $$
DECLARE
  uploads INT;
  total_downloads INT;
  comm_score INT;
BEGIN
  SELECT upload_count, community_score INTO uploads, comm_score
  FROM users WHERE id = user_id_param;

  SELECT COALESCE(SUM(download_count), 0) INTO total_downloads
  FROM notes WHERE uploader_id = user_id_param AND status = 'approved';

  UPDATE users SET
    points = (uploads * 10) + (total_downloads * 2) + comm_score,
    download_count = total_downloads
  WHERE id = user_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── TRIGGERS ───────────────────────────────────────────────

-- Auto-update updated_at on users table
CREATE OR REPLACE FUNCTION handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_users_updated_at ON users;
CREATE TRIGGER set_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION handle_updated_at();

-- Auto-update note review_count and rating when a review is inserted.
-- CRITICAL: reviewer cannot UPDATE notes via RLS, so the trigger does it.
CREATE OR REPLACE FUNCTION handle_review_stats()
RETURNS TRIGGER AS $$
DECLARE
  avg_rat DOUBLE PRECISION;
  rev_count INT;
BEGIN
  SELECT COUNT(*), COALESCE(ROUND(AVG(rating)::numeric, 1), 0)
    INTO rev_count, avg_rat
    FROM reviews
    WHERE note_id = NEW.note_id;

  UPDATE notes SET
    review_count = rev_count,
    rating = avg_rat
  WHERE id = NEW.note_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS update_note_review_stats ON reviews;
CREATE TRIGGER update_note_review_stats
  AFTER INSERT ON reviews
  FOR EACH ROW
  EXECUTE FUNCTION handle_review_stats();

-- Auto-recalculate uploader points after each download
CREATE OR REPLACE FUNCTION handle_download_points()
RETURNS TRIGGER AS $$
DECLARE
  uploader UUID;
BEGIN
  SELECT uploader_id INTO uploader FROM notes WHERE id = NEW.note_id;
  IF uploader IS NOT NULL THEN
    PERFORM recalculate_user_points(uploader);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS recalculate_points_on_download ON downloads;
CREATE TRIGGER recalculate_points_on_download
  AFTER INSERT ON downloads
  FOR EACH ROW
  EXECUTE FUNCTION handle_download_points();

-- ─── ROW LEVEL SECURITY (RLS) ───────────────────────────────

ALTER TABLE colleges   ENABLE ROW LEVEL SECURITY;
ALTER TABLE users      ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes      ENABLE ROW LEVEL SECURITY;
ALTER TABLE downloads  ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews    ENABLE ROW LEVEL SECURITY;

-- Colleges: public read only
DROP POLICY IF EXISTS "Colleges are viewable by everyone" ON colleges;
CREATE POLICY "Colleges are viewable by everyone" ON colleges FOR SELECT USING (true);

-- Users
DROP POLICY IF EXISTS "Users are viewable by everyone" ON users;
DROP POLICY IF EXISTS "Users can update own profile"   ON users;
DROP POLICY IF EXISTS "Users can insert own profile"   ON users;
CREATE POLICY "Users are viewable by everyone" ON users FOR SELECT USING (true);
CREATE POLICY "Users can update own profile"   ON users FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can insert own profile"   ON users FOR INSERT WITH CHECK (auth.uid() = id);

-- Notes
DROP POLICY IF EXISTS "Notes are viewable"             ON notes;
DROP POLICY IF EXISTS "Approved notes are viewable"    ON notes;
DROP POLICY IF EXISTS "Admins can view all notes"      ON notes;
DROP POLICY IF EXISTS "Authenticated users can upload" ON notes;
DROP POLICY IF EXISTS "Uploaders can update own notes" ON notes;
DROP POLICY IF EXISTS "Admins can moderate notes"      ON notes;
CREATE POLICY "Notes are viewable" ON notes FOR SELECT
  USING (status = 'approved' OR uploader_id = auth.uid() OR is_admin());
CREATE POLICY "Authenticated users can upload" ON notes FOR INSERT
  WITH CHECK (auth.uid() = uploader_id);
CREATE POLICY "Uploaders can update own notes" ON notes FOR UPDATE
  USING (auth.uid() = uploader_id);
CREATE POLICY "Admins can moderate notes" ON notes FOR UPDATE
  USING (is_admin());

-- Downloads
DROP POLICY IF EXISTS "Users can read own downloads" ON downloads;
DROP POLICY IF EXISTS "Users can insert downloads"   ON downloads;
CREATE POLICY "Users can read own downloads" ON downloads FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert downloads"   ON downloads FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Saved notes
DROP POLICY IF EXISTS "Users can read own saved" ON saved_notes;
DROP POLICY IF EXISTS "Users can save notes"     ON saved_notes;
DROP POLICY IF EXISTS "Users can unsave notes"   ON saved_notes;
CREATE POLICY "Users can read own saved" ON saved_notes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can save notes"     ON saved_notes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can unsave notes"   ON saved_notes FOR DELETE USING (auth.uid() = user_id);

-- Reviews
DROP POLICY IF EXISTS "Reviews are viewable"    ON reviews;
DROP POLICY IF EXISTS "Authenticated can review" ON reviews;
CREATE POLICY "Reviews are viewable"    ON reviews FOR SELECT USING (true);
CREATE POLICY "Authenticated can review" ON reviews FOR INSERT WITH CHECK (auth.uid() = reviewer_id);

-- ─── STORAGE BUCKET ─────────────────────────────────────────

INSERT INTO storage.buckets (id, name, public)
VALUES ('notes-files', 'notes-files', true)
ON CONFLICT (id) DO NOTHING;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage' AND tablename = 'objects'
      AND policyname = 'Authenticated users can upload files'
  ) THEN
    CREATE POLICY "Authenticated users can upload files" ON storage.objects
      FOR INSERT WITH CHECK (bucket_id = 'notes-files' AND auth.role() = 'authenticated');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage' AND tablename = 'objects'
      AND policyname = 'Public read access on notes files'
  ) THEN
    CREATE POLICY "Public read access on notes files" ON storage.objects
      FOR SELECT USING (bucket_id = 'notes-files');
  END IF;
END$$;
