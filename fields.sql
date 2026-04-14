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
