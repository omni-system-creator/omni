-- Add SortOrder column to sys_config table
ALTER TABLE [sys_config] ADD [SortOrder] INT NOT NULL DEFAULT 0;
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'排序号', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'SortOrder';

-- Update SortOrder for existing configs
UPDATE [sys_config] SET [SortOrder] = 0;

-- Add ExternalLinks system configuration
INSERT INTO sys_config (Category, [Key], Type, Value, Description, IsSystem, IsOverridable, SortOrder, CreatedAt)
VALUES ('Basic', 'ExternalLinks', 6, '[{"icon":"ri:github-fill","url":"https://github.com/omni-system-creator/omni","tooltip":"GitHub 仓库","sort":1},{"icon":"simple-icons:gitee","url":"https://gitee.com/kinglan_gitee/omni","tooltip":"Gitee 仓库","sort":2}]', '外部链接配置(JSON数组: icon, url, tooltip, sort)', 0, 1, 999, GETDATE());
