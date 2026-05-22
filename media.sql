CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    external_url TEXT NOT NULL,

    provider VARCHAR(50) NOT NULL,      -- youtube, vimeo, imgur, custom
    media_type VARCHAR(50) NOT NULL,    -- video, image, audio, embed

    title VARCHAR(255),
    caption TEXT,
    alt TEXT,
    credits VARCHAR(255),

    width INTEGER,
    height INTEGER,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- usage: featured (imagen principal), gallery, embed
CREATE TABLE entry_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    entry_id UUID NOT NULL REFERENCES entries(id) ON DELETE CASCADE,
    media_id UUID NOT NULL REFERENCES media(id) ON DELETE CASCADE,

    usage VARCHAR(50) DEFAULT 'gallery',
    position INTEGER DEFAULT 0
);

CREATE INDEX idx_entry_media_entry ON entry_media(entry_id);
CREATE INDEX idx_entry_media_usage ON entry_media(usage);

-- FUNCTION: attach media to entry
CREATE OR REPLACE FUNCTION attach_media_to_entry(
    p_entry_id UUID,
    p_media_id UUID,
    p_usage TEXT DEFAULT 'gallery',
    p_position INTEGER DEFAULT 0
)
RETURNS UUID AS $$
DECLARE
    new_id UUID;
BEGIN
    INSERT INTO entry_media (entry_id, media_id, usage, position)
    VALUES (p_entry_id, p_media_id, p_usage, p_position)
    RETURNING id INTO new_id;

    RETURN new_id;
END;
$$ LANGUAGE plpgsql;
