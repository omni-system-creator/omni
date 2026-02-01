-- Add LoginLogo
INSERT INTO sys_config ("Category", "Key", "Type", "Value", "Description", "IsSystem", "CreatedAt", "IsOverridable")
SELECT 'Basic', 'LoginLogo', 4, '', '登录页Logo图标', true, CURRENT_TIMESTAMP, true
WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE "Key" = 'LoginLogo' AND "OrgId" IS NULL);
