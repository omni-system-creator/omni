-- Add SortOrder to SystemConfig
ALTER TABLE [sys_config] ADD [SortOrder] INT NOT NULL DEFAULT 0;
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'排序号', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_config', @level2type = N'COLUMN', @level2name = N'SortOrder';
GO
