-- =========================================
-- 1. Crear content type: post
-- =========================================

SELECT create_content_type(
    'post',
    'Post',
    'Blog posts',
    FALSE
) AS post_id \gset

-- Ahora tienes :post_id disponible

-- =========================================
-- 2. Crear fields
-- =========================================

SELECT create_field(:post_id, 'title', 'Título', 'string', TRUE);
SELECT create_field(:post_id, 'content', 'Contenido', 'richtext');
SELECT create_field(:post_id, 'cover', 'Portada', 'image');
SELECT create_field(:post_id, 'status', 'Estado', 'string', FALSE, FALSE, NULL, '{"values":["draft","published"]}');

-- =========================================
-- 3. Insertar entries (datos fake)
-- =========================================

SELECT create_entry(
    :post_id,
    '{
        "title": "Primer post",
        "content": "Contenido de prueba...",
        "status": "published"
    }'::jsonb,
    'published',
    'primer-post'
);

SELECT create_entry(
    :post_id,
    '{
        "title": "Segundo post",
        "content": "Otro contenido...",
        "status": "draft"
    }'::jsonb,
    'draft',
    'segundo-post'
);

-- =========================================
-- 4. Consultar entries
-- =========================================

SELECT 
    id,
    slug,
    status,
    data
FROM entries
WHERE content_type_id = :post_id;

-- =========================================
-- 5. Consulta tipo API (flatten JSON)
-- =========================================

SELECT 
    id,
    slug,
    status,
    data->>'title' AS title,
    data->>'content' AS content
FROM entries
WHERE content_type_id = :post_id;

-- =========================================
-- 6. Filtro tipo búsqueda
-- =========================================

SELECT 
    id,
    data->>'title' AS title
FROM entries
WHERE content_type_id = :post_id
AND data->>'title' ILIKE '%Primer%';
