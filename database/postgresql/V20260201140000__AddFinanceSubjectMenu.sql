INSERT INTO "sys_permission" ("ParentId", "Name", "Code", "Type", "Path", "Component", "SortOrder", "IsVisible", "CreatedAt", "UpdatedAt")
SELECT 
    p."Id", 
    '科目管理', 
    'FinanceSubject', 
    'MENU', 
    '/finance/subject', 
    'views/finance/subject/Index.vue', 
    20, 
    TRUE, 
    CURRENT_TIMESTAMP, 
    CURRENT_TIMESTAMP
FROM "sys_permission" p 
WHERE p."Code" = 'finance' OR p."Code" = 'Finance'
LIMIT 1;
