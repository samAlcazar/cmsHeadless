CREATE TABLE fields (
    id SERIAL PRIMARY KEY,
    content_type_id INTEGER NOT NULL REFERENCES content_types(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    field_type VARCHAR(255) NOT NULL,
    is_required BOOLEAN DEFAULT FALSE,
    is_list BOOLEAN DEFAULT FALSE,
    default_value JSONB,
    options JSONB,
    relation_content_type_id INTEGER,
    position INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Para probar la subida a github