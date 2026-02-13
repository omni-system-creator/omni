-- Add SortOrder column to sys_config table
ALTER TABLE "sys_config" ADD COLUMN "SortOrder" INT NOT NULL DEFAULT 0;
COMMENT ON COLUMN "sys_config"."SortOrder" IS '排序号';

-- Update SortOrder for existing configs
UPDATE "sys_config" SET "SortOrder" = 0;

-- Add ExternalLinks system configuration
INSERT INTO sys_config ("Category", "Key", "Type", "Value", "Description", "IsSystem", "IsOverridable", "SortOrder", "CreatedAt")
VALUES ('Basic', 'ExternalLinks', 6, '[{"icon":"ri:github-fill","url":"https://github.com/omni-system-creator/omni","tooltip":"GitHub 仓库","sort":1},{"icon":"simple-icons:gitee","url":"https://gitee.com/kinglan_gitee/omni","tooltip":"Gitee 仓库","sort":2}]', '外部链接配置(JSON数组: icon, url, tooltip, sort)', false, true, 999, CURRENT_TIMESTAMP);
