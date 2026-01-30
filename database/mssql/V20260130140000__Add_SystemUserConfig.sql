IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sys_user_config]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[sys_user_config] (
  [Id] bigint NOT NULL IDENTITY,
  [UserId] bigint NOT NULL,
  [OrgId] bigint NOT NULL,
  [Key] nvarchar(100) NOT NULL,
  [Value] nvarchar(max),
  [Description] nvarchar(max),
  [CreatedAt] datetime2 NOT NULL DEFAULT GETDATE(),
  [UpdatedAt] datetime2 NULL,
  CONSTRAINT [PK_sys_user_config] PRIMARY KEY ([Id]),
  CONSTRAINT [FK_sys_user_config_sys_dept_OrgId] FOREIGN KEY ([OrgId]) REFERENCES [dbo].[sys_dept] ([Id]) ON DELETE CASCADE,
  CONSTRAINT [FK_sys_user_config_sys_user_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[sys_user] ([Id]) ON DELETE CASCADE
);

CREATE UNIQUE INDEX [IX_sys_user_config_UserId_OrgId_Key] ON [dbo].[sys_user_config] ([UserId], [OrgId], [Key]);
CREATE INDEX [IX_sys_user_config_OrgId] ON [dbo].[sys_user_config] ([OrgId]);

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'用户个性化配置表', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_config';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'主键ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_config', @level2type = N'COLUMN', @level2name = N'Id';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'用户ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_config', @level2type = N'COLUMN', @level2name = N'UserId';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'组织ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_config', @level2type = N'COLUMN', @level2name = N'OrgId';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'配置键', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_config', @level2type = N'COLUMN', @level2name = N'Key';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'配置值(JSON)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_config', @level2type = N'COLUMN', @level2name = N'Value';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'描述', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_config', @level2type = N'COLUMN', @level2name = N'Description';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'创建时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_config', @level2type = N'COLUMN', @level2name = N'CreatedAt';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'更新时间', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'sys_user_config', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
END
