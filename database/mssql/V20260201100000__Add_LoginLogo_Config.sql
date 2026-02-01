-- Add LoginLogo
IF NOT EXISTS (SELECT 1 FROM sys_config WHERE [Key] = 'LoginLogo' AND OrgId IS NULL)
BEGIN
    INSERT INTO sys_config (Category, [Key], Type, Value, Description, IsSystem, CreatedAt, IsOverridable)
    VALUES ('Basic', 'LoginLogo', 4, '', N'登录页Logo图标', 1, GETDATE(), 1);
END
GO
