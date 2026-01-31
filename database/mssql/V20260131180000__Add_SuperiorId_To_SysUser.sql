ALTER TABLE [sys_user] ADD [SuperiorId] bigint NULL;
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'上级用户ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user', @level2type = N'COLUMN', @level2name = N'SuperiorId';
GO
ALTER TABLE [sys_user] ADD CONSTRAINT [FK_sys_user_sys_user_SuperiorId] FOREIGN KEY ([SuperiorId]) REFERENCES [sys_user] ([Id]);
GO
