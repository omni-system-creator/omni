-- Add SystemSubtitle
INSERT INTO sys_config ("Category", "Key", "Type", "Value", "Description", "IsSystem", "CreatedAt", "IsOverridable")
SELECT 'Basic', 'SystemSubtitle', 0, 'JinLan OmniSystem', '系统副标题', true, CURRENT_TIMESTAMP, true
WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE "Key" = 'SystemSubtitle' AND "OrgId" IS NULL);

-- Add SystemFavicon
INSERT INTO sys_config ("Category", "Key", "Type", "Value", "Description", "IsSystem", "CreatedAt", "IsOverridable")
SELECT 'Basic', 'SystemFavicon', 4, '/logo.svg', '浏览器标签页图标', true, CURRENT_TIMESTAMP, true
WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE "Key" = 'SystemFavicon' AND "OrgId" IS NULL);
