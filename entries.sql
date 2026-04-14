CREATE TABLE entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    content_type_id UUID NOT NULL 
        REFERENCES content_types(id) ON DELETE CASCADE,

    slug TEXT UNIQUE,

    data JSONB NOT NULL,

    status TEXT DEFAULT 'draft',

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    published_at TIMESTAMP
);
