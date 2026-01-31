-- Add SystemSubtitle
IF NOT EXISTS (SELECT 1 FROM sys_config WHERE [Key] = 'SystemSubtitle' AND OrgId IS NULL)
BEGIN
    INSERT INTO sys_config (Category, [Key], Type, Value, Description, IsSystem, CreatedAt, IsOverridable)
    VALUES ('Basic', 'SystemSubtitle', 0, 'JinLan OmniSystem', N'系统副标题', 1, GETDATE(), 1);
END
GO

-- Add SystemFavicon
IF NOT EXISTS (SELECT 1 FROM sys_config WHERE [Key] = 'SystemFavicon' AND OrgId IS NULL)
BEGIN
    INSERT INTO sys_config (Category, [Key], Type, Value, Description, IsSystem, CreatedAt, IsOverridable)
    VALUES ('Basic', 'SystemFavicon', 4, '/logo.svg', N'浏览器标签页图标', 1, GETDATE(), 1);
END
GO
