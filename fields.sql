CREATE TABLE fields (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    content_type_id UUID NOT NULL 
        REFERENCES content_types(id) ON DELETE CASCADE,

    name VARCHAR(100) NOT NULL,
    display_name VARCHAR(150) NOT NULL,

    field_type VARCHAR(50) NOT NULL,

    is_required BOOLEAN DEFAULT FALSE,
    is_list BOOLEAN DEFAULT FALSE,

    default_value JSONB,
    options JSONB,

    relation_content_type_id UUID,

    position INTEGER DEFAULT 0,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    CONSTRAINT unique_field_per_type 
    UNIQUE (content_type_id, name)
);

-- FUNCTION CREATE
CREATE OR REPLACE FUNCTION create_field(
    p_content_type_id UUID,
    p_name TEXT,
    p_display_name TEXT,
    p_field_type TEXT,
    p_is_required BOOLEAN DEFAULT FALSE,
    p_is_list BOOLEAN DEFAULT FALSE,
    p_default_value JSONB DEFAULT NULL,
    p_options JSONB DEFAULT NULL,
    p_relation_content_type_id UUID DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    new_id UUID;
BEGIN
    INSERT INTO fields (
        content_type_id,
        name,
        display_name,
        field_type,
        is_required,
        is_list,
        default_value,
        options,
        relation_content_type_id
    )
    VALUES (
        p_content_type_id,
        p_name,
        p_display_name,
        p_field_type,
        p_is_required,
        p_is_list,
        p_default_value,
        p_options,
        p_relation_content_type_id
    )
    RETURNING id INTO new_id;

    RETURN new_id;
END;
$$ LANGUAGE plpgsql;
