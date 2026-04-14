CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE content_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(100) NOT NULL UNIQUE,
    display_name VARCHAR(150) NOT NULL,
    description TEXT,

    collection_name VARCHAR(150),
    is_single BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

--FUNCTION CREATE
CREATE OR REPLACE FUNCTION create_content_type(
    p_name TEXT,
    p_display_name TEXT,
    p_description TEXT DEFAULT NULL,
    p_is_single BOOLEAN DEFAULT FALSE
)
RETURNS UUID AS $$
DECLARE
    new_id UUID;
BEGIN
    INSERT INTO content_types (name, display_name, description, is_single)
    VALUES (p_name, p_display_name, p_description, p_is_single)
    RETURNING id INTO new_id;

    RETURN new_id;
END;
$$ LANGUAGE plpgsql;

CREATE INDEX idx_entries_content_type 
ON entries(content_type_id);
