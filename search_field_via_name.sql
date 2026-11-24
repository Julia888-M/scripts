SELECT 
    t.name AS [Таблица],
    c.name AS [Колонка],
    ty.name AS [Тип данных],
    c.max_length AS [Длина],
    s.name AS [Схема]
FROM 
    sys.columns c
JOIN 
    sys.tables t ON c.object_id = t.object_id
JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
JOIN 
    sys.types ty ON c.user_type_id = ty.user_type_id
WHERE 
    c.name LIKE '%Order%'
ORDER BY 
    [Таблица], [Колонка];
