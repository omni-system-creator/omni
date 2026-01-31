ALTER TABLE [dbo].[sys_task] ADD [start_time] datetime2 NULL;

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'开始时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_task', @level2type = N'COLUMN', @level2name = N'start_time';
