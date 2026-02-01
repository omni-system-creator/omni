INSERT INTO [sys_permission] ([ParentId], [Name], [Code], [Type], [Path], [Component], [SortOrder], [IsVisible], [CreatedAt], [UpdatedAt])
SELECT TOP 1
    p.[Id], 
    N'科目管理', 
    'FinanceSubject', 
    'MENU', 
    '/finance/subject', 
    'views/finance/subject/Index.vue', 
    20, 
    1, 
    SYSDATETIME(), 
    SYSDATETIME()
FROM [sys_permission] p 
WHERE p.[Code] = 'finance' OR p.[Code] = 'Finance';
