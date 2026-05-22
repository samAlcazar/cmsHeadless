CREATE TABLE entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    content_type_id UUID NOT NULL 
        REFERENCES content_types(id) ON DELETE CASCADE,

    slug TEXT UNIQUE,

    data JSONB NOT NULL,

    status TEXT DEFAULT 'draft',

    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    published_at TIMESTAMP
);

-- FUNCTION CREATE
CREATE OR REPLACE FUNCTION create_entry(
    p_content_type_id UUID,
    p_data JSONB,
    p_status TEXT DEFAULT 'draft',
    p_slug TEXT DEFAULT NULL,
    p_created_by UUID DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    new_id UUID;
BEGIN
    INSERT INTO entries (
        content_type_id,
        data,
        status,
        slug,
        created_by
    )
    VALUES (
        p_content_type_id,
        p_data,
        p_status,
        p_slug,
        p_created_by
    )
    RETURNING id INTO new_id;

    RETURN new_id;
END;
$$ LANGUAGE plpgsql;

CREATE INDEX idx_entries_content_type 
ON entries(content_type_id);

CREATE INDEX idx_entries_data 
ON entries USING GIN (data);

ALTER TABLE entries ADD COLUMN deleted_at TIMESTAMP;

SELECT * FROM entries
