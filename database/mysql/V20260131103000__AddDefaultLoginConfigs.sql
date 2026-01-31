INSERT INTO sys_config (Category, `Key`, Type, Value, Description, IsSystem, IsOverridable, CreatedAt, UpdatedAt)
SELECT 'Basic', 'DefaultUsername', 0, '', '登录页默认用户名', 1, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE `Key` = 'DefaultUsername' AND OrgId IS NULL);

INSERT INTO sys_config (Category, `Key`, Type, Value, Description, IsSystem, IsOverridable, CreatedAt, UpdatedAt)
SELECT 'Basic', 'DefaultPassword', 0, '', '登录页默认密码', 1, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE `Key` = 'DefaultPassword' AND OrgId IS NULL);