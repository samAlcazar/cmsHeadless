-- =========================================
-- 0. Crear usuario de prueba
-- =========================================

INSERT INTO users (username, email, password_hash, first_name, last_name)
VALUES ('admin', 'admin@example.com', 'hash_de_prueba', 'Admin', 'User')
RETURNING id AS user_id \gset

-- =========================================
-- 1. Crear content type: post
-- =========================================

SELECT create_content_type(
    'post',
    'Post',
    'Blog posts',
    FALSE,
    :'user_id'
) AS post_id \gset

-- Ahora tienes :post_id disponible

-- =========================================
-- 2. Crear fields
-- =========================================

SELECT create_field('79f187e4-0ed5-4622-a69f-2a64a99c4162', 'title', 'Título', 'string', TRUE);
SELECT create_field('79f187e4-0ed5-4622-a69f-2a64a99c4162', 'content', 'Contenido', 'richtext');
SELECT create_field('79f187e4-0ed5-4622-a69f-2a64a99c4162', 'cover', 'Portada', 'image');
SELECT create_field('79f187e4-0ed5-4622-a69f-2a64a99c4162', 'status', 'Estado', 'string', FALSE, FALSE, NULL, '{"values":["draft","published"]}');


-- =========================================
-- 3. Crear autores
-- =========================================

INSERT INTO authors (name, slug, bio, role, twitter, email)
VALUES
    ('Carlos Pérez', 'carlos-perez', 'Editor general', 'editor', '@carlosperez', 'carlos@example.com'),
    ('María García', 'maria-garcia', 'Reportera de política', 'reporter', '@mariagarcia', 'maria@example.com')
RETURNING id;

-- =========================================
-- 4. Insertar entries (datos fake)
-- =========================================

SELECT create_entry(
    '79f187e4-0ed5-4622-a69f-2a64a99c4162',
    '{
        "title": "Primer post",
        "content": "Contenido de prueba...",
        "status": "published"
    }'::jsonb,
    'published',
    'primer-post',
    :'user_id'
) AS entry1_id \gset

SELECT create_entry(
    '79f187e4-0ed5-4622-a69f-2a64a99c4162',
    '{
        "title": "Segundo post",
        "content": "Otro contenido...",
        "status": "draft"
    }'::jsonb,
    'draft',
    'segundo-post',
    :'user_id'
) AS entry2_id \gset

-- =========================================
-- 5. Asignar autores a entries
-- =========================================

SELECT add_entry_author(:'entry1_id', (SELECT id FROM authors WHERE slug = 'carlos-perez'), 0);
SELECT add_entry_author(:'entry1_id', (SELECT id FROM authors WHERE slug = 'maria-garcia'), 1);
SELECT add_entry_author(:'entry2_id', (SELECT id FROM authors WHERE slug = 'maria-garcia'), 0);

-- =========================================
-- 6. Agregar medios externos y asociarlos
-- =========================================

INSERT INTO media (external_url, provider, media_type, title, caption)
VALUES
    ('https://www.youtube.com/watch?v=abc123', 'youtube', 'video', 'Video reportaje', 'Entrevista exclusiva'),
    ('https://imgur.com/foto456', 'imgur', 'image', 'Foto portada', 'Imagen principal del artículo')
RETURNING id;

SELECT attach_media_to_entry(
    :'entry1_id',
    (SELECT id FROM media WHERE provider = 'youtube' LIMIT 1),
    'embed',
    0
);

SELECT attach_media_to_entry(
    :'entry1_id',
    (SELECT id FROM media WHERE provider = 'imgur' LIMIT 1),
    'featured',
    0
);

-- =========================================
-- 7. Consultar entries con autores
-- =========================================

SELECT
    e.id,
    e.slug,
    e.status,
    e.data->>'title' AS title,
    jsonb_agg(jsonb_build_object('name', a.name, 'role', a.role)) AS autores
FROM entries e
JOIN entry_authors ea ON ea.entry_id = e.id
JOIN authors a ON a.id = ea.author_id
WHERE e.content_type_id = '79f187e4-0ed5-4622-a69f-2a64a99c4162'
GROUP BY e.id
ORDER BY e.created_at DESC;

-- =========================================
-- 8. Consultar entries con medios
-- =========================================

SELECT
    e.id,
    e.data->>'title' AS title,
    jsonb_agg(jsonb_build_object(
        'url', m.external_url,
        'type', m.media_type,
        'usage', em.usage
    )) AS medios
FROM entries e
JOIN entry_media em ON em.entry_id = e.id
JOIN media m ON m.id = em.media_id
WHERE e.content_type_id = '79f187e4-0ed5-4622-a69f-2a64a99c4162'
GROUP BY e.id;

-- =========================================
-- 9. Consulta completa (todo junto)
-- =========================================

SELECT
    e.id,
    e.slug,
    e.status,
    e.data->>'title' AS title,
    e.data->>'content' AS content,
    jsonb_agg(DISTINCT jsonb_build_object('name', a.name, 'role', a.role)) FILTER (WHERE a.id IS NOT NULL) AS autores,
    jsonb_agg(DISTINCT jsonb_build_object('url', m.external_url, 'usage', em.usage)) FILTER (WHERE m.id IS NOT NULL) AS medios
FROM entries e
LEFT JOIN entry_authors ea ON ea.entry_id = e.id
LEFT JOIN authors a ON a.id = ea.author_id
LEFT JOIN entry_media em ON em.entry_id = e.id
LEFT JOIN media m ON m.id = em.media_id
WHERE e.content_type_id = '79f187e4-0ed5-4622-a69f-2a64a99c4162'
GROUP BY e.id
ORDER BY e.created_at DESC;
