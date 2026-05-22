CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE authors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(150) NOT NULL,
    slug VARCHAR(150) UNIQUE NOT NULL,

    bio TEXT,
    avatar_url TEXT,
    email VARCHAR(255),

    role VARCHAR(50),                   -- reporter, columnist, photographer, editor

    twitter VARCHAR(255),
    instagram VARCHAR(255),

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE entry_authors (
    entry_id UUID NOT NULL REFERENCES entries(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES authors(id) ON DELETE CASCADE,
    position INTEGER DEFAULT 0,

    PRIMARY KEY (entry_id, author_id)
);

-- FUNCTION: assign author to entry
CREATE OR REPLACE FUNCTION add_entry_author(
    p_entry_id UUID,
    p_author_id UUID,
    p_position INTEGER DEFAULT 0
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO entry_authors (entry_id, author_id, position)
    VALUES (p_entry_id, p_author_id, p_position)
    ON CONFLICT (entry_id, author_id) DO NOTHING;
END;
$$ LANGUAGE plpgsql;
