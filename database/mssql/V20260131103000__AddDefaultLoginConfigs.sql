IF NOT EXISTS (SELECT 1 FROM sys_config WHERE [Key] = 'DefaultUsername' AND OrgId IS NULL)
BEGIN
    INSERT INTO sys_config (Category, [Key], Type, Value, Description, IsSystem, IsOverridable, CreatedAt, UpdatedAt)
    VALUES ('Basic', 'DefaultUsername', 0, '', N'登录页默认用户名', 1, 1, GETDATE(), GETDATE());
END
GO

IF NOT EXISTS (SELECT 1 FROM sys_config WHERE [Key] = 'DefaultPassword' AND OrgId IS NULL)
BEGIN
    INSERT INTO sys_config (Category, [Key], Type, Value, Description, IsSystem, IsOverridable, CreatedAt, UpdatedAt)
    VALUES ('Basic', 'DefaultPassword', 0, '', N'登录页默认密码', 1, 1, GETDATE(), GETDATE());
END
GO
