CREATE TABLE entries (
    id SERIAL PRIMARY KEY,
    content_type_id INTEGER NOT NULL REFERENCES content_types(id) ON DELETE CASCADE,

    slug TEXT UNIQUE,

    data JSONB NOT NULL,

    status TEXT DEFAULT 'draft', -- draft | published | archived

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    published_at TIMESTAMP
);