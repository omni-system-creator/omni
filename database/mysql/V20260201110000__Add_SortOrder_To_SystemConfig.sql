-- Add SortOrder to SystemConfig
ALTER TABLE `sys_config` ADD COLUMN `SortOrder` INT NOT NULL DEFAULT 0 COMMENT '排序号';

-- Update SortOrder for existing configs (Optional: set defaults if needed)
UPDATE `sys_config` SET `SortOrder` = 0;
